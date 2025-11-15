# Logger — Lightweight Logger for FiveM

## Import

Make sure to start mate-logger before your resource.

Add this line to your resource:
```lua
shared_script '@mate-grid/init.lua'
```


## Overview

Logging utility for Fivem.
Provides colored log levels, resource-level configuration, optional prefixes, suppression filters, and commands to manage runtime settings.

## Features

- Light/dark mode toggle
- Live previews
- Fullscreen mode
- Cross platform

## Features

### Log Levels
Supports multiple log levels for organized output:
- `info`
- `error`
- `success`
- `warn`
- `debug`

Example:
```lua
Logger:Info("Server started")
Logger:Error("Something went wrong")
Logger:Debug():Info("Message")
```

### Per-Resource Configuration

Customize logger behavior per resource:

Enable/disable logging

Toggle timestamp output

Define default prefixes

Example:

```lua
Logger:SetConfig("my-resource", {
    enabled = true,
    showTime = false,
    prefixes = { "CORE" }
})
```

### Per-Message Settings

Override prefixes or attach suppression IDs on individual logs:
```lua
Logger:Info("User verified", {
    lSettings = {
        prefixes = { "Auth" },
        subPrefix = { "Security" },
        id = "auth-verify"
    }
})
```

### Log Suppression

Hide noisy logs dynamically during runtime:

```lua
Logger:SuppressLog("auth-verify")
Logger:UnSuppressLog("auth-verify")
```

### Built-In Commands

Configure logging without restarting the server:

log_suppress <id>
log_unsuppress <id>
log_enable <resource>
log_disable <resource>
log_config <resource> <key> <true|false>


### Automatic Table Serialization

Tables are formatted automatically:

```lua
Logger:Debug("User data:", { id = 12, name = "John" })

Output: [[
    User data: {
        id = 12,
        name = "John"
    },
]]
```


## License

[MIT](https://choosealicense.com/licenses/mit/)
