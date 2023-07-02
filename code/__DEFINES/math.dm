#define NUM_E 2.71828183

#define PI 3.1415
#define INFINITY 1e31 //closer than enough

#define SHORT_REAL_LIMIT 16777216

//"fancy" math for calculating time in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(percent ratio)
//collapsed to percent_of_tick_used * tick_lag
#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)
#define TICK_USAGE_TO_MS(starting_tickusage) (TICK_DELTA_TO_MS(TICK_USAGE_REAL - starting_tickusage))

#define PERCENT(val) (round((val)*100, 0.1))
#define CLAMP01(x) (clamp(x, 0, 1))

//time of day but automatically adjusts to the server going into the next day within the same round.
//for when you need a reliable time number that doesn't depend on byond time.
#define REALTIMEOFDAY (world.timeofday + (MIDNIGHT_ROLLOVER * MIDNIGHT_ROLLOVER_CHECK))
#define MIDNIGHT_ROLLOVER_CHECK ( GLOB.rollovercheck_last_timeofday != world.timeofday ? update_midnight_rollover() : GLOB.midnight_rollovers )

#define SIMPLE_SIGN(X)	((X) < 0 ? -1 : 1)

#define SIGN(x) ( (x)!=0 ? (x) / abs(x) : 0 )

#define CEILING(x, y) ( -round(-(x) / (y)) * (y) )

// round() acts like floor(x, 1) by default but can't handle other values
#define FLOOR(x, y) ( round((x) / (y)) * (y) )

// Similar to clamp but the bottom rolls around to the top and vice versa. min is inclusive, max is exclusive
#define WRAP(val, min, max) clamp(( min == max ? min : (val) - (round(((val) - (min))/((max) - (min))) * ((max) - (min))) ),min,max)

// Real modulus that handles decimals
#define MODULUS(x, y) ( (x) - (y) * round((x) / (y)) )

// Cotangent
#define COT(x) (1 / tan(x))

// Secant
#define SEC(x) (1 / cos(x))

// Cosecant
#define CSC(x) (1 / sin(x))

#define ATAN2(x, y) ( !(x) && !(y) ? 0 : (y) >= 0 ? arccos((x) / sqrt((x)*(x) + (y)*(y))) : -arccos((x) / sqrt((x)*(x) + (y)*(y))) )

#define HYPOTENUSE(Ax, Ay, Bx, By)	(sqrt(((Ax) - (Bx))**2 + ((Ay) - (By))**2))

// Greatest Common Divisor - Euclid's algorithm
/proc/Gcd(a, b)
	return b ? Gcd(b, (a) % (b)) : a

// Least Common Multiple
#define Lcm(a, b) (abs(a) / Gcd(a, b) * abs(b))

#define INVERSE(x) ( 1/(x) )

// Used for calculating the radioactive strength falloff
#define INVERSE_SQUARE(initial_strength,cur_distance,initial_distance) ( (initial_strength)*((initial_distance)**2/(cur_distance)**2) )

#define ISABOUTEQUAL(a, b, deviation) (deviation ? abs((a) - (b)) <= deviation : abs((a) - (b)) <= 0.1)

#define ISEVEN(x) (x % 2 == 0)

#define ISODD(x) (x % 2 != 0)

// Returns true if val is from min to max, inclusive.
#define ISINRANGE(val, min, max) (min <= val && val <= max)

// Same as above, exclusive.
#define ISINRANGE_EX(val, min, max) (min < val && val < max)

#define ISINTEGER(x) (round(x) == x)

#define ISMULTIPLE(x, y) ((x) % (y) == 0)

// Performs a linear interpolation between a and b.
// Note that amount=0 returns a, amount=1 returns b, and
// amount=0.5 returns the mean of a and b.
#define LERP(a, b, amount) ( amount ? ((a) + ((b) - (a)) * (amount)) : a )

// Returns the nth root of x.
#define ROOT(n, x) ((x) ** (1 / (n)))

#define TODEGREES(radians) ((radians) * 57.2957795)

#define TORADIANS(degrees) ((degrees) * 0.0174532925)

/// Gets shift x that would be required the bitflag (1<<x)
#define TOBITSHIFT(bit) ( log(2, bit) )

// Will filter out extra rotations and negative rotations
// E.g: 540 becomes 180. -180 becomes 180.
#define SIMPLIFY_DEGREES(degrees) (MODULUS((degrees), 360))

#define GET_ANGLE_OF_INCIDENCE(face, input) (MODULUS((face) - (input), 360))

//A logarithm that converts an integer to a number scaled between 0 and 1.
//Currently, this is used for hydroponics-produce sprite transforming, but could be useful for other transform functions.
#define TRANSFORM_USING_VARIABLE(input, max) ( sin((90*(input))/(max))**2 )

#define EXP_DISTRIBUTION(desired_mean) ( -(1/(1/desired_mean)) * log(rand(1, 1000) * 0.001) )

#define LORENTZ_DISTRIBUTION(x, s) ( s*tan(TODEGREES(PI*(rand()-0.5))) + x )
#define LORENTZ_CUMULATIVE_DISTRIBUTION(x, y, s) ( (1/PI)*TORADIANS(arctan((x-y)/s)) + 1/2 )

#define RULE_OF_THREE(a, b, x) ((a*x)/b)
// )

/// Converts a probability/second chance to probability/seconds_per_tick chance
/// For example, if you want an event to happen with a 10% per second chance, but your proc only runs every 5 seconds, do `if(prob(100*SPT_PROB_RATE(0.1, 5)))`
#define SPT_PROB_RATE(prob_per_second, seconds_per_tick) (1 - (1 - (prob_per_second)) ** (seconds_per_tick))

/// Like SPT_PROB_RATE but easier to use, simply put `if(SPT_PROB(10, 5))`
#define SPT_PROB(prob_per_second_percent, seconds_per_tick) (prob(100*SPT_PROB_RATE((prob_per_second_percent)/100, (seconds_per_tick))))
// )
