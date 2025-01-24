const std = @import("std");
const model = @import("../model.zig");

pub const Req = struct {
    const Self = @This();
    const Allocator = std.mem.Allocator;

    allocator: Allocator,
    client: std.http.Client,
    // headers: []std.http.Header,
    headers: std.http.Client.Request.Headers,
    apikey: []const u8 = "",

    pub fn init(allocator: Allocator, apikey: []const u8) !Self {
        const c = std.http.Client{ .allocator = allocator };
        // const auth_header = "Bearer " ++ .apikey;
        // Create the authorization header string
        const auth_header = try std.fmt.allocPrint(allocator, "Bearer {s}", .{apikey});
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

    pub fn get(self: *Self, url: []const u8) ![]const u8 {
        const uri = try std.Uri.parse(url);
        const header_buffer = try self.allocator.alloc(u8, 8192);
        // 8KB buffer
        defer self.allocator.free(header_buffer);
        var req = try self.client.open(.GET, uri, .{ .headers = self.headers, .server_header_buffer = header_buffer });
        defer req.deinit();

        try req.send();
        try req.wait();

        const res = try req.reader().readAllAlloc(self.allocator, 1024 * 1024);

        return res;
    }

    pub fn post(self: *Self, url: []const u8, body: ?[]const u8) ![]const u8 {
        const headers = std.http.Client.Request.Headers{
            .authorization = self.headers.authorization,
            .content_type = .{ .override = "application/json" },
        };
        if (model.config.mode == .DEV) {
            std.log.debug("Running in DEV mode with endpoint: {s}", .{model.config.endpoint});
            std.log.debug("Headers: {any}", .{headers});
            std.log.debug("URL: {s}", .{url});
        }
        // Dynamically allocate header buffer
        const header_buffer = try self.allocator.alloc(u8, 8192);
        // 8KB buffer
        defer self.allocator.free(header_buffer);
        const uri = try std.Uri.parse(url);
        // if (uri.scheme == null or uri.host == null) {
        //     return error.InvalidUrl;
        // }
        var req = try self.client.open(.POST, uri, .{ .headers = headers, .server_header_buffer = header_buffer });
        defer req.deinit();

        if (body) |b| {
            try req.writeAll(b);
        } else {
            std.log.debug("No body provided", .{});
        }

        try req.send();
        try req.wait();

        const res = try req.reader().readAllAlloc(self.allocator, 1024 * 1024);
        return res;
    }
};
