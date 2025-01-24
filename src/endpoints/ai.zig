const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");
const requests = @import("requests.zig");

/// Template for creating new endpoint commands
/// Replace 'template' with your endpoint name
// pub fn templateCommand(r: *CliBuilder.AppRunner) !CliBuilder.Command {
pub fn aiCommand() !CliBuilder.Command {
    const message =
        \\ Description of your endpoint functionality
        \\
        \\ Examples:
        \\
        \\ Basic usage:
        \\ $ blinkx template
        \\
        \\ With options:
        \\ $ blinkx template --option value
        \\
        \\ With subcommand:
        \\ $ blinkx template subcommand
        \\
        \\ Note: Some operations require a valid API key to be set
        \\ either via BLINKX_APIKEY environment variable or --apikey flag
        \\
    ;

    return CliBuilder.Command{
        .name = "ai", // Replace with your command name
        .description = CliBuilder.Description{
            .one_line = "AI operations from Blinkx",
            .detailed = message,
        },
        // Example of command options
        // .options = try r.allocOptions(&.{
        //     CliBuilder.Option{
        //         .long_name = "option-name",
        //         .help = "Description of the option",
        //         .value_ref = r.mkRef(&model.config.your_config_field),
        //         .value_name = "TYPE",  // INT, TEXT, etc
        //         .short_alias = 'o',
        //     },
        // }),
        .target = CliBuilder.CommandTarget{
            .action = CliBuilder.CommandAction{
                .exec = handleAi,
                // Example of positional arguments
                // .positional_args = CliBuilder.PositionalArgs{
                //     .optional = try r.allocPositionalArgs(&.{CliBuilder.PositionalArg{
                //         .name = "arg-name",
                //         .help = "Description of argument",
                //         .value_ref = r.mkRef(&model.config.your_config_field),
                //     }}),
                // },
            },
        },
    };
}

//TODO: Needs to handle streaming the response and outputing promppt to allow user to create or edit a file
pub fn handleAi() !void {
    // Example of making an API request
    const allocator = std.heap.page_allocator;

    // Example URL construction
    const url = try std.fmt.allocPrint(allocator, "{s}/your/endpoint", .{
        model.config.endpoint,
    });
    defer allocator.free(url);

    // Debug logging example
    if (model.config.mode == .DEV) {
        std.log.debug("URL is {s}", .{url});
    }

    // Example of making a request
    var req = try requests.Req.init(allocator, model.config.apikey);
    const response = try req.get(url);
    std.log.debug("Response: {s}", .{response});

    // Example of direct output
    // std.debug.print("Output: {s}\n", .{response});
}
