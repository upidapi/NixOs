s = 20
m = 100 # $(brightnessctl max); 
for i in range(s + 1):
    c = m / s * i # $(brightnessctl get); 
    b = 1 + 1 / s
    p = (b ** (c / m * s) - 1) / (b ** s - 1)
    print(round(p * m))
