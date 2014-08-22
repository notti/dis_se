import serial
import sys
import math
import struct
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation


class MP:
    packer = struct.Struct('b')
    ser = serial.Serial(sys.argv[1], 115200, timeout=1)

    def load(self, data):
        self.ser.write(self.packer.pack(int(data)))

    def unload(self):
        return self.packer.unpack(self.ser.read(1))[0]

fig = plt.figure()
ax1 = fig.add_subplot(211, xlim=(0, 64), ylim=(-100, 100))
line1, = ax1.plot([], [], lw=1)
ax2 = fig.add_subplot(212, xlim=(0, 64), ylim=(-100, 100))
line2, = ax2.plot([], [], lw=1)

mp = MP()

y1 = np.array([], dtype=int)
y2 = np.array([], dtype=int)

for i in range(16):
    mp.load(0)
    mp.unload()

def init():
    line1.set_data([], [])
    line2.set_data([], [])
    return line1, line2, 

def animate(i):
    global y1, y2
    if i == 1:
        y1 = np.array([], dtype=int)
        y2 = np.array([], dtype=int)
    x = np.arange(i)
    val = 0
    if i//32%2:
        val = 79
    mp.load(val)
    y1 = np.append(y1, val)
    y2 = np.append(y2, mp.unload())
    line1.set_data(x, y1)
    line2.set_data(x, y2)
    return line1, line2, 

frames = range(1, 64)

anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=frames, interval=50, blit=True, repeat=False)
plt.show()
