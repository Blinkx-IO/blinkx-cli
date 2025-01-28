const std = @import("std");
const requests = @import("endpoints/requests.zig");
const model = @import("model.zig");
const ctn = @import("endpoints/content.zig");
/// Re-export the Request type for documentation
pub const Req = requests.Req;

/// Re-export the Config type and Mode enum for documentation
pub const Config = model.Config;
pub const Mode = model.Mode;
/// Re-export ContentItem and related types for documentation
pub const ContentItem = ctn.ContentItem;
pub const Body = ctn.Body;
pub const Component = ctn.Component;
pub const SeoFields = ctn.SeoFields;

/// Initialize a new HTTP request client
///
/// Parameters:
///  - allocator: Memory allocator for request operations
///  - apikey: API key for authentication
pub fn initReq(allocator: std.mem.Allocator, apikey: []const u8) !Req {
    return Req.init(allocator, apikey);
}

/// Initialize configuration with specified mode
///
/// Parameters:
///  - mode: Operating mode (DEV or PROD)
pub fn initConfig(mode: Mode) Config {
    return Config.init(mode);
}

/// Get the current configuration
pub fn getConfig() Config {
    return model.config;
}

/// Get the current operating mode
pub fn getMode() Mode {
    return model.config.mode;
}

/// Test if we're in development mode
pub fn isDev() bool {
    return model.config.mode == .DEV;
}

/// Test if we're in production mode
pub fn isProd() bool {
    return model.config.mode == .PROD;
}
