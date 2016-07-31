#!/usr/bin/tclsh
#
# Print register descriptions extracted from YAML register description.
#
# Martin Aberg, 2015

package require yaml

proc pretty {core} {
  append r "name:  [dict get $core name]\n"
  append r "brief: [dict get $core brief]\n"
  append r "regs:\n"
  foreach reg [dict get $core regs] {
    append r "  name:  [dict get $reg name]\n"
    append r "  brief: [dict get $reg brief]\n"
    append r "  width: [dict get $reg width]\n"
    if [dict exists $reg fields] {
      foreach field [dict get $reg fields] {
        append r "    pos: [dict get $field pos]"
        if [dict exists $field width] {
          append r ", width: [dict get $field width]"
        }
        append r " - [dict get $field name]"
        append r ": [dict get $field brief]\n"
      }
    }
    append r "\n"
  }
  return $r
}

if {$argc < 1} {
  puts "Use $argv0 FILE"
  exit;
}
set d [::yaml::yaml2dict -file $argv]

puts [pretty $d]
