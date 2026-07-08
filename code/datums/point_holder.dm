/// Completely generic resource handler
/datum/point_holder
	VAR_PRIVATE/max_points = INFINITY
	VAR_PRIVATE/points = 0

/datum/point_holder/proc/has_points(atleast)
	if(points >= atleast)
		return points

/datum/point_holder/proc/is_full()
	return points == max_points

/// Returns the number of points needed to fill the holder.
/datum/point_holder/proc/how_empty()
	return max_points - points

/// Returns the % (0-100) of how full the holder is.
/datum/point_holder/proc/percent(step = 1)
	if(max_points == INFINITY)
		return 0
	return round((points / max_points) * 100, step)

/datum/point_holder/proc/adjust_points(num, check_enough)
	if(num > 0)
		return add_points(num)

	else if(num < 0)
		return remove_points(num, check_enough)

	return 0

/// Add points. Returns the number of points added.
/datum/point_holder/proc/add_points(num)
	if(points == max_points)
		return 0

	var/old = points
	points = min(max_points, points + num)
	return points - old

/// Removes points. Returns the number of points removed.
/datum/point_holder/proc/remove_points(num, check_enough)
	if(check_enough && (points < num))
		return 0

	if(points == 0)
		return 0

	var/old = points
	points = max(0, points - num)
	return old - points

/datum/point_holder/proc/set_max_points(new_max)
	max_points = new_max
	points = min(max_points, points)

/datum/point_holder/proc/get_max_points()
	return max_points

/datum/point_holder/infinite

/datum/point_holder/infinite/add_points(num)
	return 0

/datum/point_holder/infinite/has_points(atleast)
	return INFINITY

/datum/point_holder/infinite/remove_points(num, check_enough)
	return 0

/datum/point_holder/infinite/set_max_points(new_max)
	max_points = new_max
