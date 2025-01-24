const std = @import("std");
const util = @import("util.zig");
const CliBuilder = @import("zig-cli");
const content = @import("endpoints/content.zig");
const accounts = @import("endpoints/accounts.zig");
const ai = @import("endpoints/ai.zig");
const model = @import("model.zig");

pub fn main() !void {
    var r = try CliBuilder.AppRunner.init(std.heap.page_allocator);

    //This is only for testing in dev mode
    if (model.config.mode == .DEV) {
        std.log.debug("Running in DEV mode with endpoint: {s}", .{model.config.endpoint});
    }
    const detailedDescription =
        \\ Sign up for a free account at https://blinkx.io
        \\
        \\ API documentation: https://blinkx.io/api-browser 
        \\
        \\ Note: Some operations require a valid API key to be set
        \\ either via BLINKX_APIKEY environment variable or --apikey flag
        \\
    ;
    const app = CliBuilder.App{
        .command = CliBuilder.Command{
            .name = "blinkx",
            .description = CliBuilder.Description{
                .one_line = "A CLI for Blinkx CMS",
                .detailed = detailedDescription,
            },
            .options = &.{
                // Might be better to just have this as a defautl value
                // Define an Option for the "host" command-line argument.
                .{
                    .long_name = "apikey",
                    .short_alias = 'a',
                    .help = "apikey to display",
                    .envvar = "BLINKX_APIKEY",
                    .required = true,
                    .value_ref = r.mkRef(&model.config.apikey),
                },
            },

            .target = CliBuilder.CommandTarget{
                .subcommands = &.{ try content.contentCommand(&r), try accounts.accountsCommand(&r), try ai.aiCommand() },
            },
        },
    };

    return r.run(&app);
}

fn run_server() !void {
    std.log.debug("Running server", .{});
}
