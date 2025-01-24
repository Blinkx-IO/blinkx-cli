const options = @import("build_options");
pub const Mode = enum { DEV, PROD };
const is_prod = options.production_mode;
// Define a configuration structure with default values.
pub const Config = struct {
    apikey: []const u8 = "",

    //Content item structures
    itemid: u16,
    collectionid: u16 = undefined,
    version: []const u8 = undefined,
    page_url: []const u8 = undefined,
    body: []const u8 = undefined,
    /// This is a comptime variable that can be set to .DEV or .PROD
    mode: Mode = .DEV,
    // endpoint: []const u8 = "https://api.blinkx.com/v1",
    endpoint: []const u8 = "http://localhost:8080/api/v1",
    ai_endpoint: []const u8 = "https://ai.blinkx.workers.dev",

    //Accounts structures
    signup: bool = false,
    signup_url: []const u8 = "https://blinkx.io/signup",

    pub fn init() Config {
        var mode: Mode = .DEV;
        if (is_prod) {
            mode = .PROD;
        }
        return Config{
            .itemid = 0, // You can set default values here
            .apikey = "APIKEYNOTSET",
            .mode = mode,
            .signup = false,
            .endpoint = if (mode == .DEV) "http://localhost:8080/api/v1" else "https://api.blinkx.com/v1",
            .ai_endpoint = if (mode == .DEV) "https://ai.blinkx.workers.dev" else "https://ai.blinkx.com",
        };
    }
};

pub var config = Config.init();
