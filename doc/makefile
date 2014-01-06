.PHONY: all
all: ../greta.pdf

../greta.pdf: greta.tex \
  hw_overview.eps \
  hdl_overview.eps \
  ../hdl/greta_pkg.vhdl \
  ../hdl/greta.vhdl \
  ../hdl/bus_interface/bus_interface.vhdl \
  ../hdl/sdram/sdram.vhdl \
  ../hdl/fast/fast.vhdl \
  ../hdl/disk/disk.vhdl \
  schematic.pdf \
  mounted_components2.jpg \
  greta_connected2.jpg \
  greta_1_00_top.png \
  greta_1_00_bottom.png \
  email.png
	pdflatex $<
	pdflatex $<
	mv greta.pdf ../


clean:
	rm -rf *.aux *.log ../greta.pdf *.toc *.out hw_overview-eps-converted-to.pdf hdl_overview-eps-converted-to.pdf
