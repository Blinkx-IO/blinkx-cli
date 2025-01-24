const std = @import("std");
const model = @import("../model.zig");
const CliBuilder = @import("zig-cli");

const requests = @import("requests.zig");
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
    std.log.debug("Response: {s}", .{response});
}
