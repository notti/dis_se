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
ax1 = fig.add_subplot(221, xlim=(0, 256), ylim=(-100, 100))
line1, = ax1.plot([], [], lw=1)
ax2 = fig.add_subplot(222, xlim=(0, 256), ylim=(-127, 127))
line2, = ax2.plot([], [], lw=1)
ax3 = fig.add_subplot(212, xlim=(0.01, 0.5), ylim=(-40, 10))
ax3.set_xscale('log', basex=10)
line3, = ax3.plot([], [], lw=1)

y3 = np.array([])
x1 = np.array([])

mp = MP()

def init():
    line1.set_data([], [])
    line2.set_data([], [])
    line3.set_data([], [])
    return line1, line2, line3,

def animate(i):
    global y3, x1
    if i == frames[0]:
        y3 = np.array([])
        x1 = np.array([])
    x = np.arange(i/4)
    y1 = np.sin(2 * np.pi * 10 * x/i)*79
    y2 = []
    for j in range(17):
        mp.load(0)
        mp.unload()
    for j in y1:
        mp.load(j)
        y2.append(mp.unload())
    y2 = np.array(y2) 
    A = 20*math.log10(np.amax(y2)/np.amax(y1))
    y3 = np.append(y3, A)
    x1 = np.append(x1, 20/i)
    line1.set_data(x, y1)
    line2.set_data(x, y2)
    line3.set_data(x1, y3)
    return line1, line2, line3, 

frames = np.logspace(1.8, 3, num=80)

anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=frames, interval=100, blit=True, repeat=False)
plt.show()
