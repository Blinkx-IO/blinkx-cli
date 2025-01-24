const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");

const requests = @import("requests.zig");

pub fn accountsCommand(r: *CliBuilder.AppRunner) !CliBuilder.Command {
    const message =
        \\ Manage Blinkx CMS accounts and authentication
        \\
        \\ Examples:
        \\
        \\ Get signup URL for new account:
        \\ $ blinkx accounts signup
        \\
        \\ View account information:
        \\ $ blinkx accounts
        \\
        \\ Note: Some operations require a valid API key to be set
        \\ either via BLINKX_APIKEY environment variable or --apikey flag
        \\
    ;
    return CliBuilder.Command{
        .name = "accounts",
        .description = CliBuilder.Description{
            .one_line = "Get/Sign up for accounts from Blinkx",
            .detailed = message,
        },
        // .options = try r.allocOptions(&.{
        //     CliBuilder.Option{
        //         .long_name = "signup",
        //         .help = "content to display by itemid",
        //         .value_ref = r.mkRef(&model.config.itemid),
        //         .value_name = "INT",
        //         .short_alias = 's',
        //     },
        // }),
        .target = CliBuilder.CommandTarget{
            .action = CliBuilder.CommandAction{
                .exec = HandleAccount,
                //Use this if you want to accept positional arguments
                //NOTE: Think about what makes sense here
                .positional_args = CliBuilder.PositionalArgs{
                    .optional = try r.allocPositionalArgs(&.{CliBuilder.PositionalArg{
                        .name = "signup",
                        .help = "get signup url",
                        .value_ref = r.mkRef(&model.config.signup),
                    }}),
                },
            },
        },
    };
}
//TODO: Create this endpoint in the api

// pub fn NewAccount() !void {
//     const allocator = std.heap.page_allocator;
//     const url = try std.fmt.allocPrint(allocator, "{s}/accounts/new", .{
//         model.config.endpoint,
//     });
//     if (model.config.mode == .DEV) {
//         // std.log.debug("Signup is {d}", .{model.config.signup});
//         std.log.debug("URL is {s}", .{url});
//     }
//
//     var req = try requests.Req.init(allocator, model.config.apikey);
//     const response = try req.get(url);
//     std.log.debug("Response: {s}", .{response});
// }
pub fn NewAccount() !void {
    std.debug.print("{s}", .{model.config.signup_url});
}

fn HandleAccount() !void {}
