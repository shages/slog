     @@@@@@   @@@        @@@@@@    @@@@@@@@
    @@@@@@@   @@@       @@@@@@@@  @@@@@@@@@
    !@@       @@!       @@!  @@@  !@@
    !@!       !@!       !@!  @!@  !@!
    !!@@!!    @!!       @!@  !@!  !@! @!@!@
     !!@!!!   !!!       !@!  !!!  !!! !!@!!
         !:!  !!:       !!:  !!!  :!!   !!:
        !:!    :!:      :!:  !:!  :!:   !::
    :::: ::    :: ::::  ::::: ::   ::: ::::
    :: : :    : :: : :   : :  :    :: :: :

slog
====
Simple logger package. Requires Tcl 8.4 or newer.

API
---

### Variables

#### `slog::level`
Integer value indicating the logging verbosity level

| Value | Logging level |
| ----- | ------------- |
|  -1   | DEBUG         |
|   0   | INFO (default)|
|   1   | WARN          |
|   2   | ERROR         |

### Core Procedures
For Tcl 8.5 or higher, namespace ensemble is created so the colons can be
omitted.

#### `slog::get_levels`
Returns the list of logging levels in sorted order of verbosity
```tcl
% slog::get_levels
debug info warn error
```

#### `slog::set_level level`
Set the logging level by name (debug | info | warn | error)
```tcl
% slog::set_level debug
-1
```

#### `slog::debug message`
Prints message with DEBUG prefix
Suppressed if slog::level is info (0) or higher
```tcl
% slog::debug "Hello"
2017-01-05T15:17:09 - DEBUG - Hello
```

#### `slog::info message`
Prints message with INFO prefix
Suppressed if slog::level is warn (1) or higher
```tcl
% slog::info "Hello"
2017-01-05T15:17:09 - INFO  - Hello
```

#### `slog::warn message`
Prints message with WARN prefix
Suppressed if slog::level is error (2) or higher
```tcl
% slog::info "Hello"
2017-01-05T15:17:09 - WARN  - Hello
```

#### `slog::error message`
Prints message with ERROR prefix
Never suppressed
```tcl
% slog::info "Hello"
2017-01-05T15:17:09 - ERROR - Hello
```

#### `slog::msg level message`
Prints a message prefixed by the date, time, level (text), and message

Used by other message commands to print message with formatting
```tcl
% slog::msg huh? "Hello"
2017-01-05T15:17:09 - huh?  - Hello
```

### Profiling
*slog* can record simple runtime with its profile* procedures. Runtime data is
stored in the tcl array `slog::profile_data`, indexed by a user-entered
"label."

Example:
```tcl
package require slog

slog::profile_mark inital_setup

sleep 2
slog::profile_mark "A"

sleep 3
slog::profile_mark "B"

sleep 1
slog::profile_reset_time
sleep 1
# two seconds have passed, but only recorded 1
slog::profile_mark "C"

slog::profile_summary
# slog Profile Summary
# ---------------------------------------------
#         inital_setup : 11.60s
#                    A : 4.02s
#                    B : 6.00s
#                    C : 2.00s
# ---------------------------------------------

slog::profile_clear_data
slog::profile_summary
# slog Profile Summary
# ---------------------------------------------
# ---------------------------------------------
```

#### `slog::profile_reset_time`
Reset the profiler's last known time

#### `slog::profile_mark label`
Record the runtime

#### `slog::profile_summary [sort_method]`
Pretty print summary of runtime data. Labels can optionally be sorted with the
`sort_method` argument:

* none (default) - Labels printed in original marked order
* ascending - Labels sorted by ascending runtime
* descending - Labels sorted by descending runtime

#### `slog::profile_clear_data`
Clear all profile data
