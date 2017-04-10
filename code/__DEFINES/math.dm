#define PI 3.1415
#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define INFINITY 1e31 //closer then enough

//atmos
#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa
#define T0C  273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

#define Clamp(x, y, z)			 	((x) <= (y) ? (y) : ((x) >= (z) ? (z) : (x)))
#define CLAMP01(x) 					(Clamp((x), 0, 1))
#define SIMPLE_SIGN(X)				((X) < 0 ? -1 : 1)
#define SIGN(X)						((X) ? SIMPLE_SIGN(X) : 0)
#define hypotenuse(Ax, Ay, Bx, By)	(sqrt(((Ax) - (Bx))**2 + ((Ay) - (By))**2))
#define Ceiling(x)					(-round(-(x)))
#define Tan(x)						(sin(x) / cos(x))
#define Cot(x)						(1 / Tan(x))
#define Csc(x)						(1 / sin(x))
#define Sec(x)						(1 / cos(x))
#define Floor(x)					(round(x))
#define Inverse(x)					(1 / (x))
#define IsEven(x)					((x) % 2 == 0)
#define IsOdd(x)					((x) % 2 == 1)
#define IsInRange(val, min, max)	((min) <= (val) && (val) <= (max))
#define IsInteger(x)				(Floor(x) == (x))
#define IsMultiple(x, y)			((x) % (y) == 0)
#define Lcm(a, b)					(abs(a) / Gcd((a), (b)) * abs(b))
#define Root(n, x)					((x) ** (1 / (n)))
#define ToDegrees(radians)			((radians) * 57.2957795)			// 180 / Pi
#define ToRadians(degrees)			((degrees) * 0.0174532925)			// Pi / 180