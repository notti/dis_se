XILINXBASE = /opt/Xilinx/10.1/ISE/vhdl/src

GHDL = ghdl

GHDLFLAGS = --ieee=synopsys -fexplicit -Wc,-m32 -Wa,--32 -Wl,-m32
LIBS = -Punisim -Punimacro
WORK = --work=work



%: %.o
	$(GHDL) -e $(GHDLFLAGS) $(LIBS) $(WORK) $@

%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $(LIBS) $(WORK) $<

tb_serial.ghw tb_p4mem1k8t.ghw tb_mp.ghw tb_mp_writeback.ghw tb_mp_stage3.ghw tb_mp_stage2.ghw tb_mp_stage1.ghw tb_complex_alu.ghw tb_simple_alu.ghw tb_shift.ghw tb_mp_decode_fetch.ghw tb_mp_indirect_fetch.ghw: %.ghw: %
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

shift_ra.o: procedures.o
shift_rl.o: procedures.o
mp_decode_fetch.o: procedures.o
mp_indirect_fetch.o: procedures.o
tb_mp_decode_fetch.o: mp_decode_fetch.o procedures.o
tb_mp_indirect_fetch.o: mp_indirect_fetch.o procedures.o
tb_shift.o: shift_ra.o shift_rl.o procedures.o
tb_simple_alu.o: simple_alu.o procedures.o
simple_alu.o: shift_ra.o shift_rl.o procedures.o
tb_complex_alu.o: complex_alu.o procedures.o
complex_alu.o: shift_ra.o shift_rl.o procedures.o
tb_mp_stage1.o: mp_stage1.o
mp_stage1.o: complex_alu.o procedures.o
tb_mp_stage2.o: mp_stage2.o
mp_stage2.o: simple_alu.o procedures.o
tb_mp_stage3.o: mp_stage3.o
mp_stage3.o: simple_alu.o procedures.o
tb_mp_writeback.o: mp_writeback.o procedures.o
mp_writeback.o: procedures.o
mp.o: procedures.o r6w2mem1k8.o mp_decode_fetch.o mp_indirect_fetch.o mp_stage1.o mp_stage2.o mp_stage3.o mp_writeback.o
r3w1mem.o: procedures.o
tb_mp.o: procedures.o mp.o
tb_p4mem1k8T.o: procedures.o p4mem1k8T.o
p4mem1k8T.o: procedures.o p4mem1k8.o
p4mem1k8.o: procedures.o
r6w2mem1k8.o: procedures.o p4mem1k8.o
fifo.o: procedures.o
rs232.o: procedures.o
serial.o: procedures.o fifo.o rs232.o
tb_serial.o: procedures.o serial.o
