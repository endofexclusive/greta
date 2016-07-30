# Copyright (C) 2013, 2016 Martin Åberg
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

HDLDIR=..
MODULE=fast
PLATFORM=greta_board
FPGA = xc3s50an-4-tqg144
VHDLS = \
	$(MODULE).vhdl \
	$(HDLDIR)/greta_pkg.vhdl

all: synthesis simulation

include $(HDLDIR)/ghdl.mk

synthesis: ${VHDLS}
	mkdir -p synthesis
	for i in $+; do echo "vhdl work \"../$$i\""; done > synthesis/${MODULE}.prj
	echo "set -tmpdir \"xst/projnav.tmp\"" > synthesis/${PLATFORM}.xst
	echo "set -xsthdpdir \"xst\"" >> synthesis/${PLATFORM}.xst
	echo "run" >> synthesis/${PLATFORM}.xst
	echo "-ifn ${MODULE}.prj" >> synthesis/${PLATFORM}.xst
	echo "-ifmt mixed" >> synthesis/${PLATFORM}.xst
	echo "-ofn ${MODULE}" >> synthesis/${PLATFORM}.xst
	echo "-ofmt NGC" >> synthesis/${PLATFORM}.xst
	echo "-p $(FPGA)" >> synthesis/${PLATFORM}.xst
	echo "-top ${MODULE}" >> synthesis/${PLATFORM}.xst
	echo "-opt_mode Speed" >> synthesis/${PLATFORM}.xst
	echo "-opt_level 1" >> synthesis/${PLATFORM}.xst
	mkdir -p synthesis/xst/projnav.tmp
	cd synthesis && xst -intstyle ise -ifn ${PLATFORM}.xst -ofn ${MODULE}.syr
	grep --color=auto WARNING synthesis/${MODULE}.syr
	grep -d skip WARNINGS synthesis/* | grep -Eq "XST_NUMBER_OF_WARNINGS\" value=\"0\""
	touch $@

.PHONY: clean
clean: simulation-clean
	rm -rf synthesis

