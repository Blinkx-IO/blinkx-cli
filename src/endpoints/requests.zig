const std = @import("std");
const model = @import("../model.zig");

const Req = struct {
    const Self = @This();
    const Allocator = std.mem.Allocator;

    allocator: Allocator,
    client: std.http.Client,
    headers: []std.http.Header,

    pub fn init(allocator: Allocator) !Self {
        const c = std.http.Client{ .allocator = allocator };
        return Self{
            .allocator = allocator,
            .client = c,
            .headers = &[_]std.http.Header{
                // .{
                //     .name = "Content-Type",
                //     .value = "application/json",
                // },
                .{
                    .name = "Authorization",
                    .value = "Bearer " ++ model.config.apikey,
                },
            },
        };
    }

    pub fn deinit(self: *Self) void {
        self.client.deinit();
    }

    pub fn get(self: *Self, url: []const u8) ![]const u8 {
        const uri = try std.Uri.parse(url);
        var req = try self.client.open(.GET, uri, .{ .headers = self.headers });
        defer req.deinit();

        try req.send(.{});
        try req.wait();

        const res = try req.reader().readAllAlloc(self.allocator, 1024 * 1024);
        return res;
    }

    pub fn post(self: *Self, url: []const u8, body: ?[]const u8) ![]const u8 {
        const headers = &[_]std.http.Header{
            self.headers[0], // Authorization header
            .{
                .name = "Content-Type",
                .value = "application/json",
            },
        };

        const uri = try std.Uri.parse(url);
        var req = try self.client.open(.POST, uri, .{ .headers = headers });
        defer req.deinit();

        if (body) |b| {
            try req.writeAll(b);
        } else {
            std.log.debug("No body provided", .{});
        }

        try req.send(.{});
        try req.wait();

        const res = try req.reader().readAllAlloc(self.allocator, 1024 * 1024);
        return res;
    }
};

//Example of using the request struct functionality
pub fn testReq() !void {
    const Data = struct {
        key: []const u8,
        value: i32,
    };

    const data = Data{
        .key = "example",
        .value = 42,
    };
    const allocator = std.heap.page_allocator;
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();
    try std.json.stringify(data, .{}, string.writer());
    const req = try Req.init(allocator);
    const url = "https://api.blinkx.com/v1/content/item/31/data";
    const response = try req.post(url, string.items);
    std.log.debug("Response: {s}", .{response});
}
// // Example usage function
// pub fn fetchData() !void {
//     var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
//     defer arena.deinit();
//     const allocator = arena.allocator();
//
//     const response = try makeRequest(allocator);
//     std.log.debug("Response: {s}", .{response});
// }
