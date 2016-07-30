# Copyright (C) 2016 Martin Åberg
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

GHDL_FLAGS = \
	--ieee=standard --std=93 --vital-checks --warn-binding \
	--warn-reserved --warn-library --warn-vital-generic \
	--warn-delayed-checks --warn-body --warn-specs --warn-unused \
	--workdir=simulation --work=work --mb-comments

simulation: tb_${MODULE}.vhdl $(VHDLS) $(VHDLS_SIM)
	mkdir -p simulation
	ghdl -i ${GHDL_FLAGS} $^
	ghdl -m ${GHDL_FLAGS} tb_${MODULE}
	mv tb_${MODULE} simulation
	./simulation/tb_${MODULE} --assert-level=error --wave=simulation/tb_${MODULE}.ghw
	touch $@

waves: simulation
	gtkwave -a tb_${MODULE}.gtkw simulation/tb_${MODULE}.ghw

.PHONY: simulation-clean
simulation-clean:
	rm -rf simulation *.o

