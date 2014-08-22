import serial
import sys
import math
import struct
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation


def BIT_INVERSE(x):
    x = ((x & 0x55) << 1) | ((x & 0xAA) >> 1)
    x = ((x & 0x33) << 2) | ((x & 0xCC) >> 2)
    x = ((x & 0x0F) << 4) | ((x & 0xF0) >> 4)
    return x

def FIX_MUL(a, b):
    c = (a * b) >> 6
    c = (c >> 1) + (c & 0x1)
    return c

N_SINE = 256
N_LOG_SINE = 8
SINE = [int(math.sin(2*math.pi*x/N_SINE)*128) for x in range(N_SINE)]

def fft_fix(R, I, n, inverse):
    for i in range(1,n):
        j = BIT_INVERSE(i)
        if j <= i:
            continue
        R[i], R[j] = R[j], R[i]
        I[i], I[j] = I[j], I[i]

    l = 1 #FFT step
    k = N_LOG_SINE - 1 #????
    while l < n:
        step = l << 1
        for m in range(l):
            j = m << k
            wr = SINE[j+N_SINE//4]
            wi = -SINE[j]
            wr >>= 1 #shift
            wi >>= 1 #shift
            for i in range(m, n, step):
                j = i + l
                tr = FIX_MUL(wr, R[j]) - FIX_MUL(wi, I[j])
                ti = FIX_MUL(wr, I[j]) + FIX_MUL(wi, R[j])
                qr = R[i]
                qi = I[i]
                qr >>= 1 #shift
                qi >>= 1 #shift
                R[j] = qr - tr
                R[i] = qr + tr
                I[j] = qi - ti
                I[i] = qi + ti
        k -= 1
        l = step


class MP:
    packer = struct.Struct('b')
    ser = serial.Serial(sys.argv[1], 115200, timeout=1)

    def __init__(self):
        while True:
            self.ser.write(b'\x55')
            self.ser.write(b'\xAA')
            if self.ser.read(1) == b'1':
                break
        print('INIT')

    def load(self, data):
        for i in data:
            self.ser.write(self.packer.pack(int(i)))
            self.ser.write(self.packer.pack(0))

    def unload(self):
        ret = []
        for i in range(256):
            res_R = self.packer.unpack(self.ser.read(1))[0]
            res_I = self.packer.unpack(self.ser.read(1))[0]
            ret.append(math.sqrt(res_R * res_R + res_I * res_I))
        return ret

fig = plt.figure()
ax1 = fig.add_subplot(411, xlim=(0, 256), ylim=(-128, 128))
line1, = ax1.plot([], [], lw=1)
ax2 = fig.add_subplot(412, xlim=(0, 256), ylim=(0, 60))
line2, = ax2.plot([], [], 'r-', lw=1)
ax3 = fig.add_subplot(413, xlim=(0, 256), ylim=(0, 60))
line3, = ax3.plot([], [], lw=1)
ax4 = fig.add_subplot(414, xlim=(0, 256), ylim=(0, 60))
line4, = ax4.plot([], [], lw=1)

mp = MP()

def init():
    line1.set_data([], [])
    line2.set_data([], [])
    line3.set_data([], [])
    return line1, line2, line3, line4, 

def animate(i):
    x = np.arange(256)
    y1 = np.sin(2 * np.pi * 10 * x/i)*127
    mp.load(y1)
    y2 = mp.unload()
    y3 = np.absolute(np.fft.fft(y1))/256
    R = list(y1.astype(int))
    I = [0]*256
    fft_fix(R, I, 256, False)
    y4 = []
    for i in range(256):
        y4.append(math.sqrt(R[i]*R[i] + I[i]*I[i]))
    line1.set_data(x, y1)
    line2.set_data(x, y2)
    line3.set_data(x, y4)
    line4.set_data(x, y3)
    return line1, line2, line3, line4, 

frames = np.logspace(1.5, 3, num=100)

anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=frames, interval=100, blit=True)
plt.show()
