// Credits to Nickr5 for the useful procs I've taken from his library resource.

#define MATH_E 2.71828183
#define SQRT2 1.41421356

/proc/Atan2(x, y)
	if(!x && !y) return 0
	var/a = arccos(x / sqrt(x*x + y*y))
	return y >= 0 ? a : -a

// Greatest Common Divisor - Euclid's algorithm
/proc/Gcd(a, b)
	return b ? Gcd(b, a % b) : a

/proc/IsAboutEqual(a, b, deviation = 0.1)
	return abs(a - b) <= deviation

// Performs a linear interpolation between a and b.
// Note that amount=0 returns a, amount=1 returns b, and
// amount=0.5 returns the mean of a and b.
/proc/Lerp(a, b, amount = 0.5)
	return a + (b - a) * amount

/proc/Mean(...)
	var/values 	= 0
	var/sum		= 0
	for(var/val in args)
		values++
		sum += val
	return sum / values

// The quadratic formula. Returns a list with the solutions, or an empty list
// if they are imaginary.
/proc/SolveQuadratic(a, b, c)
	ASSERT(a)
	. = list()
	var/d		= b*b - 4 * a * c
	var/bottom  = 2 * a
	if(d < 0) return
	var/root = sqrt(d)
	. += (-b + root) / bottom
	if(!d) return
	. += (-b - root) / bottom

// Will filter out extra rotations and negative rotations
// E.g: 540 becomes 180. -180 becomes 180.
/proc/SimplifyDegrees(degrees)
	degrees = degrees % 360
	if(degrees < 0)
		degrees += 360
	return degrees

// min is inclusive, max is exclusive
/proc/Wrap(val, min, max)
	var/d = max - min
	var/t = Floor((val - min) / d)
	return val - (t * d)

//A logarithm that converts an integer to a number scaled between 0 and 1 (can be tweaked to be higher).
//Currently, this is used for hydroponics-produce sprite transforming, but could be useful for other transform functions.
/proc/TransformUsingVariable(input, inputmaximum, scaling_modifier = 0)

	var/inputToDegrees = (input/inputmaximum)*180 //Converting from a 0 -> 100 scale to a 0 -> 180 scale. The 0 -> 180 scale corresponds to degrees
	var/size_factor = ((-cos(inputToDegrees) +1) /2) //returns a value from 0 to 1

	return size_factor + scaling_modifier //scale mod of 0 results in a number from 0 to 1. A scale modifier of +0.5 returns 0.5 to 1.5
	//world<< "Transform multiplier of [src] is [size_factor + scaling_modifer]"

/proc/RaiseToPower(num, power)
    if(!power) return 1
    return (power-- > 1 ? num * RaiseToPower(num, power) : num)

//converts a uniform distributed random number into a normal distributed one
//since this method produces two random numbers, one is saved for subsequent calls
//(making the cost negligble for every second call)
//This will return +/- decimals, situated about mean with standard deviation stddev
//68% chance that the number is within 1stddev
//95% chance that the number is within 2stddev
//98% chance that the number is within 3stddev...etc
GLOBAL_VAR(gaussian_next)
#define ACCURACY 10000
/proc/gaussian(mean, stddev)
	var/R1;var/R2;var/working
	if(GLOB.gaussian_next != null)
		R1 = GLOB.gaussian_next
		GLOB.gaussian_next = null
	else
		do
			R1 = rand(-ACCURACY,ACCURACY)/ACCURACY
			R2 = rand(-ACCURACY,ACCURACY)/ACCURACY
			working = R1*R1 + R2*R2
		while(working >= 1 || working==0)
		working = sqrt(-2 * log(working) / working)
		R1 *= working
		GLOB.gaussian_next = R2 * working
	return (mean + stddev * R1)
#undef ACCURACY



// oof, what a mouthful
// Used in status_procs' "adjust" to let them modify a status effect by a given
// amount, without inadverdently increasing it in the wrong direction
/proc/directional_bounded_sum(orig_val, modifier, bound_lower, bound_upper)
	var/new_val = orig_val + modifier
	if(modifier > 0)
		if(new_val > bound_upper)
			new_val = max(orig_val, bound_upper)
	else if(modifier < 0)
		if(new_val < bound_lower)
			new_val = min(orig_val, bound_lower)
	return new_val

// sqrt, but if you give it a negative number, you get 0 instead of a runtime
/proc/sqrtor0(num)
	if(num < 0)
		return 0
	return sqrt(num)

/proc/round_down(num)
	if(round(num) != num)
		return round(num--)
	else return num

// Returns a list where [1] is all x values and [2] is all y values that overlap between the given pair of rectangles
/proc/get_overlap(x1, y1, x2, y2, x3, y3, x4, y4)
	var/list/region_x1 = list()
	var/list/region_y1 = list()
	var/list/region_x2 = list()
	var/list/region_y2 = list()

	// These loops create loops filled with x/y values that the boundaries inhabit
	// ex: list(5, 6, 7, 8, 9)
	for(var/i in min(x1, x2) to max(x1, x2))
		region_x1["[i]"] = TRUE
	for(var/i in min(y1, y2) to max(y1, y2))
		region_y1["[i]"] = TRUE
	for(var/i in min(x3, x4) to max(x3, x4))
		region_x2["[i]"] = TRUE
	for(var/i in min(y3, y4) to max(y3, y4))
		region_y2["[i]"] = TRUE

	return list(region_x1 & region_x2, region_y1 & region_y2)
