const std = @import("std");
const model = @import("../model.zig");
const writer = std.io.getStdOut().writer();
/// HTTP Request handler for the Blinkx API
pub const Req = struct {
    const Self = @This();
    /// Shorthand for memory allocator type
    const Allocator = std.mem.Allocator;

    /// Memory allocator for request operations
    allocator: Allocator,
    /// HTTP client instance for making requests
    client: std.http.Client,
    /// HTTP headers for requests, including authorization
    headers: std.http.Client.Request.Headers,
    /// API key for authentication, stored without 'Bearer' prefix
    apikey: []const u8 = "",

    pub fn init(allocator: Allocator, apikey: []const u8) !Self {
        const c = std.http.Client{ .allocator = allocator };
        // const auth_header = "Bearer " ++ .apikey;
        // Create the authorization header string
        const auth_header = try std.fmt.allocPrint(allocator, "Bearer {s}", .{apikey});
        // defer allocator.free(auth_header);
        return Self{
            .allocator = allocator,
            .client = c,
            .apikey = apikey,
            .headers = .{
                .authorization = .{ .override = auth_header },

                // try std.fmt.allocprint(allocator, "Bearer {s}", .{apikey}),
            },
        };
    }

    pub fn deinit(self: *Self) void {
        // self.allocator.free(self.headers.authorization);
        if (self.headers.authorization == .value) {
            self.allocator.free(self.headers.authorization.value);
        }
        self.client.deinit();
    }

    pub fn get(self: *Self, url: []const u8, buffer_size: ?usize) ![]const u8 {
        const uri = try std.Uri.parse(url);
        const header_buffer = try self.allocator.alloc(u8, buffer_size orelse 8192);
        // 8KB buffer
        // defer self.allocator.free(header_buffer);
        var req = try self.client.open(.GET, uri, .{ .headers = self.headers, .server_header_buffer = header_buffer });
        defer req.deinit();

        try req.send();
        try req.wait();

        const res = try req.reader().readAllAlloc(self.allocator, 1024 * 1024);
        return res;
    }

    pub fn post_fetch(self: *Self, url: []const u8, body: ?[]const u8) !std.ArrayList(u8) {
        const bearer = try std.fmt.allocPrint(self.allocator, "Bearer {s}", .{model.config.apikey});
        defer self.allocator.free(bearer);
        const headers = &[_]std.http.Header{
            .{ .name = "Authorization", .value = bearer },
            // if we wanted to do a post request with JSON payload we would add
            .{ .name = "Content-Type", .value = "application/json" },
        };
        // const headers = std.http.Client.Request.Headers{
        //     .authorization = self.headers.authorization,
        //     .content_type = .{ .override = "application/json" },
        // };

        // const header_buffer = try self.allocator.alloc(u8, buffer_size orelse 8192);
        // defer self.allocator.free(header_buffer);
        var response_body = std.ArrayList(u8).init(self.allocator);
        // const uri = try std.Uri.parse(url);
        //TODO : Handle all status error codes etc
        _ = try self.client.fetch(.{
            .method = .POST,
            .extra_headers = headers,
            .response_storage = .{ .dynamic = &response_body },
            .location = .{ .url = url },
            .payload = body orelse null,
        });
        // try writer.print("Response Status: {d}\n Response Body:{s}\n", .{ response.status, response_body.items });
        //
        return response_body;
    }

    pub fn post(self: *Self, url: []const u8, body: ?[]const u8, buffer_size: ?usize) ![]const u8 {
        const headers = std.http.Client.Request.Headers{
            .authorization = self.headers.authorization,
            .content_type = .{ .override = "application/json" },
        };

        if (model.config.mode == .DEV) {
            std.log.debug("Running in DEV mode with endpoint: {s}", .{model.config.endpoint});
            std.log.debug("Headers: {any}", .{headers});
            std.log.debug("URL: {s}", .{url});
        }

        const header_buffer = try self.allocator.alloc(u8, buffer_size orelse 8192);
        defer self.allocator.free(header_buffer);

        const uri = try std.Uri.parse(url);

        var req = try self.client.open(.POST, uri, .{
            .headers = headers,
            .server_header_buffer = header_buffer,
            // Set the content length if we have a body
            // .transfer_encoding = if (body) |b| .{ .content_length = b.len } else .none,
        });
        defer req.deinit();

        // Send headers first
        req.send() catch |err| {
            std.debug.print("Error: {any}\n", .{err});
        };

        // Write body if we have one
        if (body) |b| {
            // req.transfer_encoding.content_length = b.len;
            req.transfer_encoding = .{ .content_length = b.len };
            var wtr = req.writer();
            try wtr.writeAll(b);
            // Mark the body as complete
            try req.finish();
        }

        // if (model.config.mode == .DEV) {
        // }

        // Wait for response
        req.wait() catch |err| {
            std.debug.print("Wait Error: {any}\n", .{err});
        };

        // Read response
        const res = try req.reader().readAllAlloc(self.allocator, 1024 * 1024);
        return res;
    }
};
