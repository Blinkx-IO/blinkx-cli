const options = @import("build_options");
pub const Mode = enum { DEV, PROD };
/// Verbose or JSON output for the Project AI Plan
pub const PlanType = enum { JSON, VERBOSE };
/// Content can only be retrieved by ID or URL
pub const ContentOption = enum { ID, URL };

pub const AiAction = enum { plan, chat, edit };

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

    //AI structures
    prompt: []const u8 = "Give me a description of the content item",
    plan_type: PlanType = .JSON,
    ai_action: AiAction = .plan,
    file: []const u8 = undefined,
    content_item: []const u8 = undefined,
    //Positional arguments for ai command
    // build_plan: bool = false,

    pub fn init() Config {
        var mode: Mode = .DEV;
        if (is_prod) {
            mode = .PROD;
        }
        return Config{
            .itemid = 0, // You can set default values here
            // .apikey = "APIKEYNOTSET",
            .mode = mode,
            .signup = false,
            .endpoint = if (mode == .DEV) "http://localhost:8080/api/v1" else "https://api.blinkx.com/v1",
            .ai_endpoint = if (mode == .DEV) "https://ai.blinkx.workers.dev" else "https://ai.blinkx.workers.dev",
        };
    }
};

pub var config = Config.init();
