#!/usr/bin/tclsh
#
# Generate C header with register descriptions extracted from YAML register
# description.
#
# Martin Aberg, 2015

package require yaml

proc format_offset {reg {addr 0}} {
  format " * %#06x | %-6s | %s\n" $addr [dict get $reg name] [dict get $reg brief]
}

proc format_fields {name reg} {
  set width [dict get $reg width]
  set regname "${name}_[dict get $reg name]"

  append r "/* [dict get $reg brief] */\n"
  if [dict exists $reg fields] {
    foreach field [dict get $reg fields] {
      append r "/* [dict get $field brief] */\n"
      set regfieldname [string toupper "${regname}_[dict get $field name]"]
      set lobit [dict get $field pos]
      set w 1
      if [dict exists $field width] {
        set w [dict get $field width]
      }
      set hibit [expr {$lobit + $w - 1}]
      set mask [expr {((1<<($hibit+1))-1) - ((1<<$lobit)-1)}]
      set maskf [format "0x%08x" $mask]
      append r "#define ${regfieldname}_BIT [dict get $field pos]\n"
      append r "#define ${regfieldname} $maskf\n"
    }
  } else {
    append r "\n"
  }
  return $r
}

proc format_fieldcomment {field} {
  set p [dict get $field pos]
  if [dict exists $field width] {
    set w [dict get $field width]
  } else {
    set w 1
  }
  if {1 == $w} {
    set bits [dict get $field pos]
  } else {
    set bits [format "%d-%d" [expr {$p + $w - 1}] $p]
  }
  format " * %-6s | %-6s | %s\n" $bits [dict get $field name] [dict get $field brief]
}

proc format_reg {reg {addr 0}} {
  set width [dict get $reg width]

  append r "  /** @brief [dict get $reg brief]"
  if [dict exists $reg fields] {
    append r "\n"
    append r "   *\n"
    append r "   * Bit    | Name   | Description\n"
    append r "   * [string repeat - 6] | [string repeat - 6] | [string repeat - 40]\n"
    foreach field [dict get $reg fields] {
      append r "  [format_fieldcomment $field]"
    }
    append r "   */\n"
  } else {
    append r " */\n"
  }
  append r "  uint${width}_t [dict get $reg name];"
  append r [format "  /* %#06x */" $addr]
  incr addr [expr {$width/8}]
  list $r $addr
}

if {$argc < 1} {
  puts "Use $argv0 FILE"
  exit;
}

set core [::yaml::yaml2dict -file $argv]

set cname [string toupper [dict get $core name]]
set cbrief [dict get $core brief]

append fileheader "/** @file\n"
append fileheader " *\n"
append fileheader " * @brief Register description for\n"
append fileheader " * $cname - $cbrief\n"
append fileheader " */\n\n"
append fileheader "#ifndef _${cname}_REGS_H_\n"
append fileheader "#define _${cname}_REGS_H_\n"
append fileheader "\n"
append fileheader "#include <stdint.h>\n"

append filefooter "#endif\n"

append structheader "struct [string tolower $cname]_regs \{\n"
append structfooter "\};\n"

append offsetheader "/** @brief $cname registers\n"
append offsetheader " *\n"
append offsetheader " * Offset | Name   | Description\n"
append offsetheader " * [string repeat - 6] | [string repeat - 6] | [string repeat - 40]"
append offsetfooter " */\n"

set addr 0
foreach reg [dict get $core regs] {
  append offsetbody [format_offset $reg $addr]
  set r [format_reg $reg $addr]
  set addr [lindex $r 1]
  append structbody "[lindex $r 0]\n\n"
}

puts $fileheader

puts $offsetheader
puts -nonewline $offsetbody
puts $offsetfooter

puts -nonewline $structheader
puts -nonewline $structbody
puts $structfooter

foreach reg [dict get $core regs] {
  set r [format_fields $cname $reg]
  puts $r
}
puts $filefooter
