import serial
import sys
import math
import struct

packer = struct.Struct('b')

ser = serial.Serial(sys.argv[1], 115200, timeout=5)

# INIT
while True:
    ser.write(b'\x55')
    ser.write(b'\xAA')
    if ser.read(1) == b'1':
        break

print('INIT')

#LOAD
for i in range(256):
    ser.write(packer.pack(int(math.sin(2*math.pi*i/30)*128)))
    ser.write(packer.pack(0))

#UNLOAD
for i in range(256):
    res_R = packer.unpack(ser.read(1))[0]
    res_I = packer.unpack(ser.read(1))[0]
    print(res_R, ',', res_I)
