# Blinkx CLI

A command-line interface for Blinkx CMS, written in Zig.

**⚠️ WORK IN PROGRESS - NOT FOR PRODUCTION USE**

## ⚠️ IMPORTANT VERSION REQUIREMENT ⚠️

This project requires:
- **Zig version: 0.14.0-dev.2851+b074fb7dd**

It is strongly recommended to use [ZVM (Zig Version Manager)](https://github.com/tristanisham/zvm) to manage your Zig and ZLS versions.

## Installation

1. Install Zig
2. Clone the repository
3. Run `zig build`
4. Run the executable from `zig-out/bin/blinkx`

## Dependencies

This project uses the following external libraries:

- [zig-cli](https://github.com/sam701/zig-cli) - A command line argument parser for Zig
  - Author: [sam701](https://github.com/sam701)
  - License: MIT
  - Used for CLI argument parsing and command structure

## Environment Variables

- `BLINKX_APIKEY`: Your Blinkx API key (can also be provided via --apikey flag)

## Usage
```bash
$ ./zig-out/bin/blinkx --help
Usage: blinkx [OPTIONS] [COMMAND]

A CLI for Blinkx CMS

Options:
  -h, --help                   Print this help message
  -a, --apikey TEXT           API key for authentication (required)
  --version                   Print version information (v0.0.2)

Commands:
  content                     Get content from Blinkx
  accounts                    Account operations from Blinkx
  ai                         AI operations from Blinkx

$ ./zig-out/bin/blinkx content --help
Get content from Blinkx

Options:
  -i, --itemid INT           Content to display by itemid
  -p, --projectid INT        Content to display by project id
  -v, --version STRING       Content to display by version
  -u, --page_url STRING      Content to display by page url
  -b, --body STRING          Specific content fields to display (comma-separated)
                            Options: html,components,css,assets,fonts,styles

$ ./zig-out/bin/blinkx ai --help
AI operations from Blinkx

Options:
  -p, --prompt TEXT          Description of the option

$ ./zig-out/bin/blinkx accounts --help
Account operations from Blinkx
```

## Development Mode


The CLI runs in development mode by default, which:
- Uses local development endpoints (http://localhost:8080/api/v1)
- Provides additional debug logging
- Sets development-specific default values

To use production mode:
- Set production endpoints (https://api.blinkx.com/v1)
- Disable debug logging
- Use production-specific values
Get content by item ID:
```bash
$ blinkx content --itemid 123
```

Get specific content fields:
```bash
$ blinkx content --itemid 123 --body "html,components,css"
```

Get content by project ID:
```bash
$ blinkx content --projectid 456
```
### License

This project is licensed under the MIT License - see the LICENSE file for details.
