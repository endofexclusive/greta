#
# Copyright (C) 2013 Martin Åberg
#
# This program is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General
# Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
TOP_LEVEL = greta
PLATFORM = greta_board
FPGA = xc3s50an-4-tqg144
VHDLS = \
  greta_pkg.vhdl \
	$(TOP_LEVEL).vhdl \
	dcm_greta.vhdl \
  bus_interface/bus_interface.vhdl \
  fast/fast.vhdl \
  disk/disk.vhdl \
  sdram/sdram.vhdl

all: $(TOP_LEVEL).bit

report: $(TOP_LEVEL).twr

.PHONY: prog
prog: $(TOP_LEVEL).bit
	djtgcfg prog -d JtagHs1 -i 0 -f ${TOP_LEVEL}.bit

$(TOP_LEVEL).xsvf: platforms/$(PLATFORM)/platform.batch $(TOP_LEVEL).bit
	echo "setPreference -pref KeepSVF:True" > temp.batch
	cat $< | sed s#\$${XILINX}#$(subst \,/,$(XILINX))#g >> temp.batch
	impact -batch temp.batch
	rm -f temp.batch

$(TOP_LEVEL).bit: platforms/$(PLATFORM)/platform.ut $(TOP_LEVEL).ncd
	bitgen -w -d -intstyle ise -f $+

$(TOP_LEVEL).twr: $(TOP_LEVEL).ncd platforms/$(PLATFORM)/platform.ucf
	trce -intstyle ise -v 3 -s 4 -n 3 -fastpaths -xml $(TOP_LEVEL).twx $< -o $@ $(TOP_LEVEL).pcf -ucf platforms/$(PLATFORM)/platform.ucf

$(TOP_LEVEL).ncd: $(TOP_LEVEL)_map.ncd
	par -w -intstyle ise -ol high $(PARFLAGS) $< $@ $(TOP_LEVEL).pcf

$(TOP_LEVEL)_map.ncd: $(TOP_LEVEL).ngd
	map -intstyle ise -p $(FPGA) $(MAPFLAGS) -ir off -pr off -c 100 -o $@ $< $(TOP_LEVEL).pcf

$(TOP_LEVEL).ngd: $(TOP_LEVEL).ngc platforms/$(PLATFORM)/platform.ucf
	ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc platforms/$(PLATFORM)/platform.ucf -p $(FPGA) $< $@

$(TOP_LEVEL).ngc: platforms/$(PLATFORM)/platform.xst $(TOP_LEVEL).prj
	mkdir -p xst/projnav.tmp
	xst -intstyle ise -ifn $< -ofn $(TOP_LEVEL).syr

$(TOP_LEVEL).prj: $(VHDLS)
	for i in $+; do echo "vhdl work \"$$i\""; done > $@

.PHONY: clean
clean:
	rm -rf *.svf *.xsvf *.csvf _ngo *.bgn *.drc *.ncd *.ntrc_log *.prj *.twr *.csv *.html fx2fpga_xdb _xmsgs *.bit *.gise *.ngc *.pad *.ptwx *.twx *.ngm *.txt *.xml *.xrpt *.bld *.ise *.ngd *.par *.stx *.map *.twr auto_project_xdb *.cmd_log *.lso *.ngr *.pcf *.syr *.unroutes *.xpi *.mrp xst *.log *.cmd *.xwbt iseconfig xlnx_auto_0_xdb

