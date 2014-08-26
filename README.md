dis_se
======

Implementation of "Programmable Processor Pipeline for Replacing Specialized Modules in Many-Modules SoC". All files are licensed under the BSD License mentioned in LICENSE, except stated otherwise.

The project is synthesizable with ISE 10 and ISE 14 and has been tested on an XC3S700A. Just add all the vhdl files in the vhdl folder and the bmm and ucf files from the xlnx folder.

The compiler needs ragel (http://www.complang.org/ragel/) and go (http://golang.org/) to compile. Makefiles are provided. Usage: `asm input.asm > input.mem`
