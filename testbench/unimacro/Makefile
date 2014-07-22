GHDLFLAGS = --ieee=synopsys -fexplicit -Wc,-m32 -Wa,--32 -Wl,-m32 --warn-no-vital-generic
LIBS = -P../unisim
WORK = --work=unimacro

OBJ = unimacro_VCOMP.o


all: $(OBJ)

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $(LIBS) $(WORK) $<

clean:
	rm -rf unimacro-obj93.cf *o *s

vpath %.vhd $(XILINXBASE)/unimacro

.PHONY: clean
.SUFFIXES:
.SUFFIXES: .vhd

unimacro_VCOMP.o: BRAM_SDP_MACRO.o  BRAM_SINGLE_MACRO.o  BRAM_TDP_MACRO.o  FIFO_DUALCLOCK_MACRO.o  FIFO_SYNC_MACRO.o
