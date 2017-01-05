
package require Tcl 8.5

package provide logs 1.0

namespace eval logs {
    namespace export get_levels
    namespace export set_level

    variable level 0
    # -1    DEBUG
    #  0    INFO
    #  1    WARN
    #  2    ERROR

    proc get_levels {} {
        return {debug info warn error}
    }

    proc set_level {lvl} {
        variable level
        switch -exact -- [string tolower $lvl] {
            debug   { set level -1 }
            info    { set level 0 }
            warn    { set level 1 }
            error   { set level 2 }
            default { puts "FATAL: Couldn't set info level" }
        }
        return $level
    }

    proc msg {lvl args} {
        set t [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
        puts [format "%s - %-5s - %s" $t $lvl [concat {*}$args]]
    }

    proc debug {args} {
        variable level
        if {-1 >= $level} {
            msg DEBUG {*}$args
        }
    }

    proc info {args} {
        variable level
        if {0 >= $level} {
            msg INFO {*}$args
        }
    }

    proc warn {args} {
        variable level
        if {1 >= $level} {
            msg WARN {*}$args
        }
    }

    proc error {args} {
        variable level
        if {2 >= $level} {
            msg ERROR {*}$args
        }
    }
}


