
package require Tcl 8.4

package provide slog 1.0

namespace eval slog {
    namespace export get_levels
    namespace export set_level
    namespace export msg
    namespace export debug
    namespace export info
    namespace export warn
    namespace export error
    if {[lindex [split [info patchlevel] "."] 1] > 4} {
        namespace ensemble create
    }

    variable level 0
    # -1    DEBUG
    #  0    INFO
    #  1    WARN
    #  2    ERROR

    proc get_levels {} {
        return {debug info warn error}
    }

    proc set_level {level_str} {
        variable level
        switch -exact -- [string tolower $level_str] {
            debug   { set level -1 }
            info    { set level 0 }
            warn    { set level 1 }
            error   { set level 2 }
            default { puts "FATAL: Couldn't set info level" }
        }
        return $level
    }

    proc msg {level args} {
        set t [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
        set message ""
        foreach arg $args {
            set message [concat $message $arg]
        }
        puts [format "%s - %-5s - %s" $t $level $message]
    }

    proc debug {args} {
        variable level
        if {-1 >= $level} {
            msg DEBUG $args
        }
    }

    proc info {args} {
        variable level
        if {0 >= $level} {
            msg INFO $args
        }
    }

    proc warn {args} {
        variable level
        if {1 >= $level} {
            msg WARN $args
        }
    }

    proc error {args} {
        variable level
        if {2 >= $level} {
            msg ERROR $args
        }
    }
}
