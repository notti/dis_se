GHDLFLAGS = --ieee=synopsys -fexplicit -Wc,-m32 -Wa,--32 -Wl,-m32 --warn-no-vital-generic
LIBS =
WORK = --work=unisim

OBJ = unisim_VCOMP.o unisim_SMODEL.o unisim_virtex5_SMODEL.o unisim_VPKG.o unisim_VITAL.o


all: $(OBJ)

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $(LIBS) $(WORK) $<

clean:
	rm -rf unisim-obj93.cf *.o *.s

vpath %.vhd $(XILINXBASE)/unisims

.PHONY: clean
.SUFFIXES:
.SUFFIXES: .vhd

unisim_VITAL.o: unisim_VPKG.o
unisim_SMODEL.o: unisim_VCOMP.o
unisim_virtex5_SMODEL.o: unisim_VCOMP.o
