const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");
const requests = @import("requests.zig");

const writer = std.io.getStdOut().writer();

// Catppuccin Mocha color palette
const Color = struct {
    // Special
    const reset = "\x1b[0m";
    // Base colors
    const rosewater = "\x1b[38;2;245;224;220m";
    const flamingo = "\x1b[38;2;242;205;205m";
    const pink = "\x1b[38;2;245;194;231m";
    const mauve = "\x1b[38;2;203;166;247m";
    const red = "\x1b[38;2;243;139;168m";
    const maroon = "\x1b[38;2;235;160;172m";
    const peach = "\x1b[38;2;250;179;135m";
    const yellow = "\x1b[38;2;249;226;175m";
    const green = "\x1b[38;2;166;227;161m";
    const teal = "\x1b[38;2;148;226;213m";
    const sky = "\x1b[38;2;137;220;235m";
    const sapphire = "\x1b[38;2;116;199;236m";
    const blue = "\x1b[38;2;137;180;250m";
    const lavender = "\x1b[38;2;180;190;254m";
    const text = "\x1b[38;2;205;214;244m";
    const subtext1 = "\x1b[38;2;186;194;222m";
    const overlay1 = "\x1b[38;2;110;115;141m";
};
/// Template for creating new endpoint commands
/// Replace 'template' with your endpoint name
pub fn aiCommand(r: *CliBuilder.AppRunner) !CliBuilder.Command {
    // pub fn aiCommand() !CliBuilder.Command {
    const message =
        \\ AI-powered operations for content creation and management
        \\
        \\ Examples:
        \\
        \\ Generate a project plan:
        \\ $ blinkx ai plan --prompt "Create a pet ecom store" --plan-type json
        \\
        \\ Chat with context from a file:
        \\ $ blinkx ai chat --prompt "Explain this code" --file ./src/main.zig
        \\
        \\ Edit with content item context:
        \\ $ blinkx ai edit --prompt "Update the hero section" --content-item 123
        \\
        \\ Available Actions:
        \\   plan    - Generate a structured project plan
        \\   chat    - Interactive chat with context
        \\   edit    - AI-assisted content editing
        \\
        \\ Options:
        \\   -p, --prompt         Text prompt for AI operation
        \\   -t, --plan-type      Output format (VERBOSE or JSON)
        \\   -f, --file           Attach a file for context
        \\   -c, --content-item   Include Blinkx content item for context
        \\
        \\ Note: Requires a valid API key via BLINKX_APIKEY environment variable or --apikey flag
        \\
    ;

    return CliBuilder.Command{
        .name = "ai", // Replace with your command name
        .description = CliBuilder.Description{
            .one_line = "AI operations from Blinkx",
            .detailed = message,
        },
        // Example of command options
        .options = try r.allocOptions(&.{
            CliBuilder.Option{
                .long_name = "prompt",
                .help = "Description of the option",
                .value_ref = r.mkRef(&model.config.prompt),
                .value_name = "TEXT", // INT, TEXT, etc
                .short_alias = 'p',
            },
            CliBuilder.Option{
                .long_name = "plan-type",
                .help = "Verbose or JSON output for the Project AI Plan",
                .value_ref = r.mkRef(&model.config.plan_type),
                .value_name = "VERBOSE, JSON",
                .short_alias = 't',
            },
            CliBuilder.Option{
                .long_name = "file",
                .help = "Any files to be attached to prompt",
                .value_ref = r.mkRef(&model.config.file),
                .value_name = "FILE",
                .short_alias = 'f',
            },
            CliBuilder.Option{
                .long_name = "content-item",
                .help = "Content item from your blinkx project to be attached to prompt",
                .value_ref = r.mkRef(&model.config.content_item),
                .value_name = "CONTENT_ITEM",
                .short_alias = 'c',
            },
        }),
        .target = CliBuilder.CommandTarget{
            .action = CliBuilder.CommandAction{
                .exec = handleAi,
                .positional_args = CliBuilder.PositionalArgs{
                    .optional = try r.allocPositionalArgs(&.{CliBuilder.PositionalArg{
                        .name = "action",
                        .help = "Action to perform - plan, chat, edit",
                        .value_ref = r.mkRef(&model.config.ai_action),
                    }}),
                },
            },
        },
    };
}

// pub fn createRequestBody(allocator: std.mem.Allocator, prompt: []const u8, req_type: []const u8) ![]const u8 {
//     var json = std.json.Value{
//         .object = std.json.ObjectMap.init(allocator),
//     };
//
//     try json.object.put("prompt", std.json.Value{ .string = prompt });
//     try json.object.put("type", std.json.Value{ .string = req_type });
//
//     return try std.json.stringify(json, .{}, allocator);
// }
pub fn plan() !void {
    // Create arena allocator for all temporary allocations
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    if (model.config.mode == .DEV) {
        std.log.debug("Planning AI", .{});
    }

    const url = try std.fmt.allocPrint(allocator, "{s}/plan", .{
        model.config.ai_endpoint,
    });
    // No need for defer free when using arena

    // Create JSON body
    // var json = std.json.Value{
    //     .object = std.json.ObjectMap.init(allocator),
    // };
    // var jsonBody = std.json.ObjectMap.init(allocator);
    //
    // try jsonBody.put("prompt", std.json.Value{ .string = model.config.prompt });
    // // verbose | json
    // try jsonBody.put("planType", std.json.Value{ .string = "json" });
    //
    // // const body = try std.json.stringify(jsonBody, .{}, allocator);
    //
    // const body = try std.json.stringifyAlloc(allocator, jsonBody, .{});

    // const body =
    //     \\{ "prompt": "Create a pet ecom store", "planType": "json" }
    // ;
    // const body =
    //     \\ {
    //     \\  "prompt": "Create a pet ecom store",
    //     \\  "planType": "json"
    //     \\ }
    // ;
    const plan_type_str = switch (model.config.plan_type) {
        .JSON => "json",
        .VERBOSE => "verbose",
    };
    const body = try std.fmt.allocPrint(allocator,
        \\{{"prompt":"{s}","planType":"{s}"}}
    , .{ model.config.prompt, plan_type_str });
    // Debug logging
    if (model.config.mode == .DEV) {
        std.log.debug("URL is {s}", .{url});
        std.log.debug("Body being sent is {s}", .{body});
    }

    // Make request
    var req = try requests.Req.init(allocator, model.config.apikey);
    // const response = try req.post(url, body, null);
    const response = try req.post_fetch(url, body);

    // std.log.debug("Response: {s}", .{response});
    // Add green color for output
    try writer.print("\x1b[32mOutput: {s}\x1b[0m\n", .{response.items});
    // Example of direct output
    // std.debug.print("Output: {s}\n", .{response.items});
}

pub fn chat() !void {
    std.log.debug("Chatting with AI", .{});
}
pub fn edit() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();
    const url = try std.fmt.allocPrint(arena_allocator, "{s}/edit", .{
        model.config.ai_endpoint,
        // model.config.content_item, //TODO : might need to be of type string or int
    });

    if (model.config.mode == .DEV) {
        std.log.debug("Editing AI", .{});
        std.log.debug("Edit URL is {s}", .{url});
    }

    const body = try std.fmt.allocPrint(arena_allocator,
        \\{{"prompt":"{s}"}}
    , .{model.config.prompt});
    // Make request
    var req = try requests.Req.init(arena_allocator, model.config.apikey);
    // const response = try req.post(url, body, null);
    const response = try req.post_fetch(url, body);

    // std.log.debug("Response: {s}", .{response});
    // Add green color for output
    try writer.print("\x1b[32mOutput: {s}\x1b[0m\n", .{response.items});
}

///TODO: Needs to handle streaming the response and outputing promppt to allow user to create or edit a file
pub fn handleAi() !void {
    //Check acton
    switch (model.config.ai_action) {
        .plan => try plan(),
        .chat => try chat(),
        .edit => try edit(),
        //else => std.log.debug("Invalid action please use plan, chat, or edit", .{}),
    }
}
