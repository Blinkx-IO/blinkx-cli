const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");
const json = std.json;

const requests = @import("requests.zig");

const Body = struct {
    components: ?[]Component = null,
    html: ?[]const u8 = null,
    css: ?[]const u8 = null,
};

//TODO: make an enum for type
const Component = struct {
    type: []const u8,
    components: ?[]Component = null,
    content: ?[]const u8 = null,
};

//TODO: add seo fields
const SeoFields = struct {};

pub const ContentItem = struct {
    item_id: i64,
    title: ?[]const u8 = null,
    content_type: ?[]const u8 = null,
    body: ?Body = null,
    status: ?[]const u8 = null,
    author: ?[]const u8 = null,
    page_url: ?[]const u8 = null,
    seo_fields: ?[]const u8 = null,
    published_date: ?[]const u8 = null,

    // pub fn jsonStringify(self: @This(), allocator: std.mem.Allocator, options: std.json.StringifyOptions) ![]const u8 {
    //     return std.json.stringifyAlloc(allocator, self, options);
    // }
};

// Reference the model config directly
pub fn contentCommand(r: *CliBuilder.AppRunner) !CliBuilder.Command {
    const message =
        \\ Get content by itemid, collectionid, version, page_url, body
        \\  
        \\ Example: 
        \\ 
        \\ Get content by itemid
        \\ 
        \\ $ blinkx content --itemid 123
        \\ 
        \\ Get content by collectionid
        \\ 
        \\ $ blinkx content --projectid 123
        \\ 
    ;

    return CliBuilder.Command{
        .name = "content",
        .description = CliBuilder.Description{
            .one_line = "Get content from Blinkx",
            .detailed = message,
        },
        .options = try r.allocOptions(&.{
            CliBuilder.Option{
                .long_name = "itemid",
                .help = "content to display by itemid",
                .value_ref = r.mkRef(&model.config.itemid),
                .value_name = "INT",
                .short_alias = 'i',
            },
            CliBuilder.Option{
                .long_name = "projectid",
                .help = "content to display by project id",
                .value_ref = r.mkRef(&model.config.collectionid),
                .value_name = "INT",
                .short_alias = 'p',
            },
            CliBuilder.Option{
                .long_name = "version",
                .help = "content to display by version",
                .value_ref = r.mkRef(&model.config.version),
                .value_name = "STRING",
                .short_alias = 'v',
            },
            CliBuilder.Option{
                .long_name = "page_url",
                .help = "content to display by page url",
                .value_ref = r.mkRef(&model.config.page_url),
                .value_name = "STRING",
                .short_alias = 'u',
            },
            CliBuilder.Option{
                .long_name = "body",
                .help = "specific content to display in request body as a list of options html, components, css, assets, fonts, styles separated by commas ie html,components,css if not set all fields will be returned",
                .value_ref = r.mkRef(&model.config.body),
                .value_name = "STRING",
                .short_alias = 'b',
            },
        }),
        .target = CliBuilder.CommandTarget{
            .action = CliBuilder.CommandAction{
                .exec = GetContentItem,
                //Use this if you want to accept positional arguments
                // .positional_args = CliBuilder.PositionalArgs{
                //     .optional = try r.allocPositionalArgs(&.{CliBuilder.PositionalArg{
                //         .name = "itemid",
                //         .help = "content to display by itemid",
                //         .value_ref = r.mkRef(&model.config.itemid),
                //     }}),
                // },
            },
        },
    };
}
pub fn GetContentItem() !void {
    const allocator = std.heap.page_allocator;
    const url = try std.fmt.allocPrint(allocator, "{s}/content-item?item_id={d}", .{
        model.config.endpoint,
        model.config.itemid,
    });
    if (model.config.mode == .DEV) {
        std.log.debug("Itemid is {d}", .{model.config.itemid});
        std.log.debug("URL is {s}", .{url});
    }

    var req = try requests.Req.init(allocator, model.config.apikey);
    const response = try req.get(url);
    // Print the raw response for debugging
    std.debug.print("\n=== Raw JSON Response ===\n{s}\n=== End Response ===\n", .{response});

    // Try parsing with more detailed error handling
    const parsed = json.parseFromSlice(ContentItem, allocator, response, .{
        .ignore_unknown_fields = true,
    }) catch |err| {
        std.debug.print("JSON Parse Error: {}\n", .{err});
        return err;
    };
    defer parsed.deinit();
    std.log.debug("ContentItem: {s}", .{parsed.value.status.?});
}
