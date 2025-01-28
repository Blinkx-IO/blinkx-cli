const std = @import("std");
const util = @import("util.zig");
const CliBuilder = @import("zig-cli");
const content = @import("endpoints/content.zig");
const accounts = @import("endpoints/accounts.zig");
const ai = @import("endpoints/ai.zig");
const model = @import("model.zig");

pub fn main() !void {
    var r = try CliBuilder.AppRunner.init(std.heap.page_allocator);
    // Catppuccin Mocha colors (ANSI escape codes)
    const colors = struct {
        const rosewater = "38;2;245;224;220"; // #f5e0dc
        const mauve = "38;2;203;166;247"; // #cba6f7
        const green = "38;2;166;227;161"; // #a6e3a1
        const red = "38;2;243;139;168"; // #f38ba8
        const blue = "38;2;137;180;250"; // #89b4fa
    };
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
                .subcommands = &.{ try content.contentCommand(&r), try accounts.accountsCommand(&r), try ai.aiCommand(&r) },
            },
        },
        .version = "0.0.2",
        .author = "Blinkx",
        .help_config = .{
            .color_usage = .auto,
            .color_app_name = colors.mauve, // Mauve for app name
            .color_section = colors.blue, // Blue for sections
            .color_option = colors.green, // Green for options
            .color_error = colors.red, // Red for errors

        },
    };
    return r.run(&app);
}

fn run_server() !void {
    std.log.debug("Running server", .{});
}
