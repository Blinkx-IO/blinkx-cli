const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");

const requests = @import("requests.zig");
// Reference the model config directly
pub fn contentCommand(r: *CliBuilder.AppRunner) !CliBuilder.Command {
    const message =
        \\ This is a multiline
        \\ string in Zig.
        \\ Each line starts with 
    ;

    return CliBuilder.Command{
        .name = "content",
        .description = CliBuilder.Description{
            .one_line = "Get content",
            .detailed = message,
        },
        // .options = &.{
        //     .{
        //         .long_name = "content",
        //         .short_alias = 'c',
        //         .help = "content to display",
        //         .value_ref = r.mkRef(&model.config.itemid),
        //     },
        // },
        .target = CliBuilder.CommandTarget{
            .action = CliBuilder.CommandAction{
                .exec = getContent,
                .positional_args = CliBuilder.PositionalArgs{
                    .optional = try r.mkSlice(CliBuilder.PositionalArg, &.{
                        CliBuilder.PositionalArg{
                            .name = "content3",
                            // .short_alias = 'c',
                            .help = "content to display",
                            .value_ref = r.mkRef(&model.config.apikey),
                            // .value_ref = r.mkRef(&model.config.itemid),
                        },
                    }),
                    //     // .required = try r.mkSlice(CliBuilder.PositionalArg, &.{
                    //     //     CliBuilder.PositionalArg{
                    //     //         .name = "content2",
                    //     //         .help = "content to display",
                    //     //         // .value_ref = r.mkRef(&model.config.itemid),
                    //     //     },
                    //     // }),
                },
            },
        },
    };
}
pub fn contentCommand2() !CliBuilder.Command {
    return CliBuilder.Command{
        .name = "content2",
        // .options = &.{
        //     .{
        //         .long_name = "content",
        //         .short_alias = 'c',
        //         .help = "content to display",
        //         // .required = true,
        //         .value_ref = r.mkRef(&model.config.itemid),
        //     },
        // },
        .target = CliBuilder.CommandTarget{
            .action = CliBuilder.CommandAction{
                .exec = getContent,
            },
        },
    };
}
pub fn getContent() !void {
    //item_id
    //collection_id
    //page_url
    //version
    //body
    //{"html", "components", "css", "assets", "fonts", "styles"}
    std.log.debug("Getting content with itemid: {s}", .{model.config.apikey});
}
