
if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded logs 1.0 [list source [file join $dir logs.tcl]]

