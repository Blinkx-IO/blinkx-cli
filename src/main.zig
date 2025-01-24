const std = @import("std");
const util = @import("util.zig");
const CliBuilder = @import("zig-cli");
const content = @import("endpoints/content.zig");
const model = @import("model.zig");

pub fn main() !void {
    var r = try CliBuilder.AppRunner.init(std.heap.page_allocator);

    //This is only for testing in dev mode
    if (model.config.mode == .DEV) {
        std.log.debug("Running in DEV mode with endpoint: {s}", .{model.config.endpoint});
    }

    const app = CliBuilder.App{
        .command = CliBuilder.Command{
            .name = "blinkx",
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
                .subcommands = &.{try content.contentCommand(&r)},
            },
        },
    };

    return r.run(&app);
}

fn run_server() !void {
    std.log.debug("Running server", .{});
}
