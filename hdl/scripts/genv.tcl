#!/usr/bin/tclsh
#
# Generate VHDL package with register descriptions extracted from YAML register
# description.
#
# Martin Aberg, 2015

package require yaml

proc format_offset {reg {addr 0}} {
  set id [string toupper "[dict get $reg name]_OFFSET"]
  format "  constant %-21s: std_logic_vector(31 downto 0) := x\"%08x\";\n" $id $addr
}

proc format_decheader {reg} {
  return "  function decode(vec : std_logic_vector) return [dict get $reg name]_reg"
}

proc format_encheader {reg} {
  return "  function encode(rec : [dict get $reg name]_reg) return std_logic_vector"
}

proc getrange {field} {
  if [dict exists $field width] {
    set w [dict get $field width]
  } else {
    set w 1
  }
  set lo [dict get $field pos]
  set hi [expr {$lo + $w - 1}]
  if {$lo == $hi} {
    return [format "(%2d)" $lo]
  } else {
    return [format "(%2d downto %2d)" $hi $lo]
  }
}

proc format_dec {reg} {
  set r "[format_decheader $reg] is\n"
  append r "    variable rec : [dict get $reg name]_reg;\n"
  append r "  begin\n"
  foreach field [dict get $reg fields] {
    set name [string tolower [dict get $field name]]
    append r [format "    rec.%-8s:= vec%s;\n" $name [getrange $field]]
  }
  append r "    return rec;\n"
  append r "  end;\n"
}

proc format_enc {reg} {
  set r "[format_encheader $reg] is\n"
  set hibit [expr {[dict get $reg width] - 1}]
  append r "    variable vec : std_logic_vector($hibit downto 0) := (others => '0');\n"
  append r "  begin\n"
  foreach field [dict get $reg fields] {
    set name [string tolower [dict get $field name]]
    append r [format "    vec%-15s:= rec.%s;\n" [getrange $field] $name]
  }
  append r "    return vec;\n"
  append r "  end;\n"
}

proc format_field {field} {
  if [dict exists $field width] {
    set w [dict get $field width]
  } else {
    set w 1
  }
  if {1 == $w} {
    set bits [dict get $field pos]
    set fieldtype "std_logic"
  } else {
    set fieldtype [format "std_logic_vector(%2d downto 0)" [expr {$w - 1}]]
  }
  set fieldname [string tolower [dict get $field name]]
  append r "    -- [dict get $field brief]\n"
  append r [format "    %-8s: %s;\n" $fieldname $fieldtype]
}

# Construct a full record.
proc format_rec {reg {addr 0}} {
  # This is width of full register.
  set width [dict get $reg width]

  append r "  -- [dict get $reg brief]\n"
  append r "  type [dict get $reg name]_reg is record\n"
  foreach field [dict get $reg fields] {
    append r "[format_field $field]"
  }

  append r "  end record;\n"

  incr addr [expr {$width/8}]
  list $r $addr
}

if {$argc < 1} {
  puts "Use $argv0 FILE"
  exit;
}

set core [::yaml::yaml2dict -file $argv]

set cname [string tolower [dict get $core name]]
set cbrief [dict get $core brief]

append fileheader "-- Register description for\n"
append fileheader "-- [string toupper $cname] - $cbrief\n\n"
append fileheader "library ieee;\n"
append fileheader "use ieee.std_logic_1164.all;\n"
append pkgheader "package ${cname}_regs is\n"
append pkgfooter "end;\n"

set addr 0
foreach reg [dict get $core regs] {
  append offsets [format_offset $reg $addr]
  set r [format_rec $reg $addr]
  append recs "[lindex $r 0]\n"
  lappend encheaders [format_encheader $reg]
  lappend decheaders [format_decheader $reg]
  set addr [lindex $r 1]
}

puts $fileheader

puts $pkgheader
puts $offsets
puts -nonewline $recs
puts "  -- Encode record to std_logic_vector."
foreach enc $encheaders { puts "$enc;" }
puts "\n  -- Decode std_logic_vector to record."
foreach dec $decheaders { puts "$dec;" }
puts ""
puts $pkgfooter

# Generate package body

append bodyheader "package body ${cname}_regs is\n"
append bodyfooter "end;\n"

puts $bodyheader

foreach reg [dict get $core regs] {
  puts [format_dec $reg]
}

foreach reg [dict get $core regs] {
  puts [format_enc $reg]
}

puts $bodyfooter
