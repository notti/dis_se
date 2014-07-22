XILINXBASE = /opt/Xilinx/10.1/ISE/vhdl/src

GHDL = ghdl

GHDLFLAGS = --ieee=synopsys -fexplicit -Wc,-m32 -Wa,--32 -Wl,-m32
LIBS = -Punisim -Punimacro
WORK = --work=work

tb_mp_decode_fetch.o: mp_decode_fetch.o 

%: %.o
	$(GHDL) -e $(GHDLFLAGS) $(LIBS) $(WORK) $@

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $(LIBS) $(WORK) $<

%.ghw: %
	./$< --wave=$@

export 

unisim:
	$(MAKE) -C unisim

unimacro: unisim
	$(MAKE) -C unimacro

prereq: unisim unimacro
	touch prereq

clean-unisim:
	$(MAKE) -C unisim clean
clean-unimacro:
	$(MAKE) -C unimacro clean

clean: clean-unisim clean-unimacro
	rm -rf prereq
	rm -rf work-obj93.cf
	rm -rf *.o *.s

vpath %.vhd ../vhdl:.

.PHONY: clean clean-unisim clean-unimacro unisim unimacro
.SUFFIXES:
.SUFFIXES: .vhd .o .ghw

mp_decode_fetch.o: procedures.o
