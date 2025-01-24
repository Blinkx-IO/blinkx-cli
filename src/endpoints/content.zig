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
        .options = try r.allocOptions(&.{
            CliBuilder.Option{
                .long_name = "itemid",
                .help = "content to display by itemid",
                .value_ref = r.mkRef(&model.config.itemid),
                .value_name = "INT",
                .required = true,
                .short_alias = 'i',
            },
            CliBuilder.Option{
                .long_name = "projectid",
                .help = "content to display by project id",
                .value_ref = r.mkRef(&model.config.collectionid),
                .value_name = "INT",
                .short_alias = 'p',
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
    std.log.debug("Response: {s}", .{response});
}
