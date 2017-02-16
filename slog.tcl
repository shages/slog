
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
    namespace export profile_mark
    namespace export profile_summary
    namespace export profile_reset_time
    namespace export profile_clear_data
    if {[lindex [split [::info patchlevel] "."] 1] > 4} {
        namespace ensemble create
    }

    variable level 0
    # -1    DEBUG
    #  0    INFO
    #  1    WARN
    #  2    ERROR
    variable profile_data
    variable profile_last_time

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

    proc msg {level text} {
        set t [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
        set message ""
        foreach snippet $text {
            set message [concat $message $snippet]
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

    proc get_time {} {
        if {[lindex [split [::info patchlevel] "."] 1] > 4} {
            return [clock milliseconds]
        } else {
            return [clock clicks -milliseconds]
        }
    }

    proc profile_mark {label} {
        # Mark the end of a section of code, and record the runtime
        #
        # If the key already exists by this name, sum the runtime
        #
        # Arguments:
        # label     The name (string) of the code block. Used for dict key.
        #
        # Returns:
        # runtime of this code block
        variable profile_labels
        variable profile_data
        variable profile_last_time

        # Measure time
        set now [get_time]
        set runtime [expr {$now - $profile_last_time}]
        set profile_last_time $now

        # Update profile data with runtime
        if {[::info exists profile_data($label)]} {
            set profile_data($label) [expr {$profile_data($label) + $runtime}]
        } else {
            lappend profile_labels $label
            set profile_data($label) $runtime
        }
        return $runtime
    }

    proc profile_summary {{sort_method "none"}} {
        # Pretty print the runtime profile data
        #
        # Usage:
        #   sort [sort_method]
        #
        # Arguments:
        # sort      Sorting method ["none" | "runtime_ascending" | "runtime_descending"]
        #
        # Returns: Nothing
        variable profile_labels
        variable profile_data

        set labels $profile_labels

        # Sort data
        if {$sort_method ne "none"} {
            # Convert to nested list
            set data {}
            foreach {label value} [array get profile_data] {
                lappend data [list $label $value]
            }
            # Sort
            if {$sort_method eq "ascending"} {
                set data [lsort -real -increasing -index 1 $data]
            } elseif {$sort_method eq "descending"} {
                set data [lsort -real -decreasing -index 1 $data]
            }
            # Extract only the label
            set labels {}
            foreach pair $data {
                lappend labels [lindex $pair 0]
            }
        }

        puts "slog Profile Summary"
        puts "---------------------------------------------"
        foreach label $labels {
            puts [format "%20s : %0.2fs" \
                $label \
                [expr {$profile_data($label) / 1000.0}]]
        }
        puts "---------------------------------------------"
    }

    proc profile_reset_time {} {
        # Reset the profile last known time
        variable profile_last_time
        set profile_last_time [get_time]
    }

    proc profile_clear_data {} {
        # Clear all recorded profile marks and reset time
        variable profile_labels
        variable profile_data

        set profile_labels [list]
        array unset profile_data
        profile_reset_time
    }
}

set slog::profile_last_time [slog::get_time]
set slog::profile_labels [list]
