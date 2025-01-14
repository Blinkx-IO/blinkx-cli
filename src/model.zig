// Define a configuration structure with default values.
pub const Config = struct {
    host: []const u8 = "localhost",
    itemid: u16,
    apikey: []const u8 = "",
    /// This is a comptime variable that can be set to .DEV or .PROD
    mode: enum { DEV, PROD } = .DEV,
    endpoint: []const u8 = "https://api.blinkx.com/v1",
    ai_endpoint: []const u8 = "https://ai.blinkx.workers.dev",
};

// Create a comptime instance of the configuration
pub var config = Config{
    .itemid = 0, // You can set default values here
    .apikey = "APIKEYNOTSET",
    .mode = .DEV,
    //This endpoint is our staging server unitl we promote to production
    .endpoint = "https://rest.preview.blinkcms.com/v1",
    //This endpoint is our production server but the domain will change
    .ai_endpoint = "https://ai.blinkx.workers.dev",
};
