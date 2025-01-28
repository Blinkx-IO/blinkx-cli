const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");
const json = std.json;
const requests = @import("requests.zig");

pub fn deinitValue(value: std.json.Value, allocator: std.mem.Allocator) void {
    switch (value) {
        .object => |o| o.deinit(),
        .array => |a| a.deinit(),
        .string => |s| allocator.free(s),
        .number_string => |s| allocator.free(s),
        .null, .bool, .integer, .float => {},
    }
}

// const Value = json.Value;
/// Represents the body content of a content item
const Body = struct {
    /// Array of component blocks that make up the content
    components: ?[]Component = null,
    /// HTML representation of the content
    html: ?[]const u8 = null,
    /// CSS styles associated with the content
    css: ?[]const u8 = null,

    pub fn toJson(self: Body, allocator: std.mem.Allocator) !std.json.Value {
        var map = std.json.ObjectMap.init(allocator);

        if (self.html) |html| {
            try map.put("html", std.json.Value{ .string = html });
        }

        if (self.css) |css| {
            try map.put("css", std.json.Value{ .string = css });
        }

        if (self.components) |components| {
            var components_array = std.json.Array.init(allocator);
            for (components) |component| {
                try components_array.append(try component.toJson(allocator));
            }
            try map.put("components", std.json.Value{ .array = components_array });
        }

        return std.json.Value{ .object = map };
    }
};

/// Represents a component block within the content
const Component = struct {
    /// The type of component (e.g., "text", "image", etc.)
    type: ?[]const u8,
    /// Nested components within this component
    components: ?[]Component = null,
    /// Raw content of the component
    content: ?[]const u8 = null,

    pub fn toJson(self: Component, allocator: std.mem.Allocator) !std.json.Value {
        var map = std.json.ObjectMap.init(allocator);

        if (self.type) |comp_type| {
            try map.put("type", std.json.Value{ .string = comp_type });
        }

        if (self.content) |content| {
            try map.put("content", std.json.Value{ .string = content });
        }

        if (self.components) |components| {
            var components_array = std.json.Array.init(allocator);
            for (components) |component| {
                try components_array.append(try component.toJson(allocator));
            }
            try map.put("components", std.json.Value{ .array = components_array });
        }

        return std.json.Value{ .object = map };
    }
};

/// Container for SEO-related fields
const SeoFields = struct {};

/// Represents a content item in the Blinkx CMS
pub const ContentItem = struct {
    /// The unique identifier for the content item
    item_id: u32,
    /// The title of the content item
    title: ?[]const u8 = null,
    /// The type of content (e.g., "visual-builder", "markdown", etc.)
    content_type: ?[]const u8 = null,
    /// The main content body containing components and rendered HTML/CSS
    body: ?Body = null,
    /// The current status of the content item (e.g., "Published", "Draft")
    status: ?[]const u8 = null,
    /// The username of the content item's author
    author: ?[]const u8 = null,
    /// The URL-friendly path where this content is accessible
    page_url: ?[]const u8 = null,
    /// The date when the content item was published
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
                .exec = ContentItemCommand,
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
//NOTE: Now that we got the json working we need pass cli flags to change the query params in the get request
pub fn GetContentItem() !void {
    const allocator = std.heap.page_allocator;
    const url = try std.fmt.allocPrint(allocator, "{s}/content-item?item_id={d}", .{
        model.config.endpoint,
        model.config.itemid,
    });

    defer allocator.free(url);
    if (model.config.mode == .DEV) {
        std.log.debug("Itemid is {d}", .{model.config.itemid});
        std.log.debug("URL is {s}", .{url});
    }

    var req = try requests.Req.init(allocator, model.config.apikey);
    const response = try req.get(url, null);
    defer allocator.free(response);
    // Print the raw response for debugging
    if (model.config.mode == .DEV) {
        std.debug.print("\n=== Raw JSON Response ===\n{s}\n=== End Response ===\n", .{response});
    }

    //NOTE : This is a dynamic way to parse the json response
    // // Try parsing with more detailed error handling
    // const parsed = json.parseFromSlice(Value, allocator, response, .{
    //     .ignore_unknown_fields = true,
    // }) catch |err| {
    //     std.debug.print("JSON Parse Error: {}\n", .{err});
    //     return err;
    // };
    // defer parsed.deinit();
    // var root = parsed.value;
    // const title = root.object.get("title").?;
    // std.log.debug("ContentItem: {s}", .{title.string});

    const parsedFromStruct = json.parseFromSlice(ContentItem, allocator, response, .{
        .ignore_unknown_fields = true,
    }) catch |err| {
        std.debug.print("JSON Parse Error: {}\n", .{err});
        return err;
    };
    defer parsedFromStruct.deinit();
    std.log.debug("ContentItem: {s}", .{parsedFromStruct.value.body.?.html.?});

    //ptint out the components
    //Figure  out how to defer memory freeing here th deinitvlaue funciton is not workin
    //
    const body_json = try parsedFromStruct.value.body.?.toJson(allocator);
    //error: expected type '*array_hash_map.ArrayHashMapWithAllocator if the deinitvlaue funcitonis used
    // error if the object is called directly theres a panic error when using the cli
    const body_str = try std.json.stringifyAlloc(allocator, body_json, .{ .whitespace = .indent_2 });
    defer allocator.free(body_str);
    // defer deinitValue(body_json, allocator);
    // body_json.object.
    std.log.debug("Body: {s}", .{body_str});

    //TODO : Determin  based on cli flags what to use data for
    // Potential to get ai functions to call this function ie take this content and edit it
}

fn ContentItemCommand() !void {
    try GetContentItem();
}
