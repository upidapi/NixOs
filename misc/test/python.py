

s = 20
m = 255 # $(brightnessctl max); 
c = 0


def t(d):
    b = 1 + 1 / s
    p = (b ** (c / m * s + d) - 1) / (b ** s - 1)
    return round(p * m)

for i in range(s + 1):
    # print(c)
    # c = a(1)
    c = m / s * i # $(brightnessctl get); 
    b = 1 + 1 / s
    p = (b ** (c / m * s) - 1) / (b ** s - 1)
    print(round(p * m))
