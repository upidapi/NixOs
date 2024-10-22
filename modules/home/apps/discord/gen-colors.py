"""
use to generate the colors from two colors: dark, light
"""


import numpy as np
import matplotlib.pyplot as plt


def get_data():
    # taken from discords colors
    raw = """\
        --primary-100: hsl(200 0% 97.6%);
        --primary-130: hsl(220 13% 95.5%);
        --primary-160: hsl(210 11.1% 92.9%);
        --primary-200: hsl(216 9.8% 90%);
        --primary-230: hsl(210 9.1% 87.1%);
        --primary-260: hsl(214 8.4% 83.7%);
        --primary-300: hsl(210 9.3% 78.8%);
        --primary-330: hsl(215 8.8% 73.3%);
        --primary-345: hsl(214 8.4% 67.5%);
        --primary-360: hsl(214 8.1% 61.2%);
        --primary-400: hsl(223 5.8% 52.9%);
        --primary-430: hsl(229 4.8% 44.9%);
        --primary-460: hsl(228 5.2% 38%);
        --primary-500: hsl(228 6% 32.5%);
        --primary-530: hsl(227 6.5% 27.3%);
        --primary-560: hsl(225 6.7% 23.5%);
        --primary-600: hsl(223 6.7% 20.6%);
        --primary-630: hsl(220 6.5% 18%);
        --primary-645: hsl(220 7% 16.9%);
        --primary-660: hsl(228 6.7% 14.7%);
        --primary-700: hsl(225 6.3% 12.5%);
        --primary-730: hsl(225 7.1% 11%);
        --primary-760: hsl(220 6.4% 9.2%);
        --primary-800: hsl(220 8.1% 7.3%);
        --primary-830: hsl(240 4% 4.9%);
        --primary-860: hsl(240 7.7% 2.5%);
        --primary-900: hsl(245 0% 0.8%);\
    """

    # --primary-400: hsl(223 5.8% 52.9%);
    # --primary-400-hsl: 223 calc(var(--saturation-factor, 1) * 5.8%) 52.9%;

    data = []
    for line in raw.split("\n"):
        res = line.strip().split(" ")
        # print(res)

        data.append(list(map(float, [
            res[0][len("--primary-"):-len(":")],
            res[1][len("hsl("):],
            res[2][:-len("%")],
            res[3][:-len("%);")],
        ])))

    """
    data = [(100, 200, 0, 97.6),
    (130, 220, 13, 95.5),
    (160, 210, 11.1, 92.9),
    (200, 216, 9.8, 90),
    (230, 210, 9.1, 87.1),
    (260, 214, 8.4, 83.7),
    (300, 210, 9.3, 78.8),
    (330, 215, 8.8, 73.3),
    (345, 214, 8.4, 67.5),
    (360, 214, 8.1, 61.2),
    (400, 223, 5.8, 52.9),
    (430, 229, 4.8, 44.9),
    (460, 228, 5.2, 38),
    (500, 228, 6, 32.5),
    (530, 227, 6.5, 27.3),
    (560, 225, 6.7, 23.5),
    (600, 223, 6.7, 20.6),
    (630, 220, 6.5, 18),
    (645, 220, 7, 16.9),
    (660, 228, 6.7, 14.7),
    (700, 225, 6.3, 12.5),
    (730, 225, 7.1, 11),
    (760, 220, 6.4, 9.2),
    (800, 220, 8.1, 7.3),
    (830, 240, 4, 4.9),
    (860, 240, 7.7, 2.5),
    (900, 245, 0, 0.8)]
    """

    return data


data = get_data()
labels = np.array([d[0] for d in data])
lightness_values = np.array([d[3] for d in data])

# Fit a polynomial of degree 10
degree = 8 # arbitrary
coefficients = np.polyfit(labels, lightness_values, degree)

# Create a polynomial function using the coefficients
polynomial = np.poly1d(coefficients)


def plot():
    # Generate x values for plotting the fitted polynomial
    x_fit = np.linspace(min(labels), max(labels), 100)
    y_fit = polynomial(x_fit)

    # Plot the original data and the fitted polynomial curve
    plt.scatter(labels, lightness_values, label='Data', color='red')
    plt.plot(x_fit, y_fit, label=f'Fitted {degree}th Degree Polynomial', color='blue')
    plt.xlabel('Labels')
    plt.ylabel('Lightness Values')
    plt.title('10th Degree Polynomial Fit to Data')
    plt.legend()
    plt.grid()

    plt.show()

# plot()

# Print the coefficients of the polynomial
# print("Polynomial coefficients (from highest degree to lowest):")
# print(polynomial(100))
# print(coefficients)


# 100 * 0.08 * x = 0

def interpolate(a, b): 
    # make sure that the first and last one correlate
    # to a and b
    # a[3] /= (100 - 2.4) / 100 
    # b[3] /= (100 - 0.8) / 100
    a[3] /= polynomial(data[0][0]) / 100 
    b[3] /= (100 - polynomial(data[-1][0])) / 100
    # a = (100, 200, 14, 97.6 + 2.4)
    # b = (900, 245, 4, 0.8 - 0.8)
    
    out = []
    for dat in data:
        d = dat[0]
        p = (d - 100) / 800 # normalize to 0..1
        pp = polynomial(d) / 100

        out.append([
            d,
            a[1] + (b[1] - a[1]) * p,
            a[2] + (b[2] - a[2]) * p,
            a[3] * pp + b[3] * (1 - pp)
        ])
    
    
    for x in out: 
        hsl_part = f"{x[1]:.0f} {x[2]:.1f}% {x[3]:.1f}%"
        print(f"--primary-{x[0]:.0f}: hsl({hsl_part});")
        print(f"--primary-{x[0]:.0f}-hsl: {hsl_part};")


# discord defaults
# interpolate(
#     [100, 200, 14, 97.6],
#     [900, 245, 4, 0.8]
# )

interpolate(
    [100, 200,  40, 90.6], # dark
    [900, 245, 4, -5] # light
)

# x * p + y * (1 - p)
# x * p + y - yp





