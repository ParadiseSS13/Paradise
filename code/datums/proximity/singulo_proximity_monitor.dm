/datum/proximity_monitor/advanced/singulo

/datum/proximity_monitor/advanced/singulo/on_entered(turf/source, atom/movable/entered, turf/old_loc)
	. = ..()
	if(!isprojectile(entered))
		return

	var/angle_to_singulo = ATAN2(host.y - source.y, host.x - source.x)
	var/distance_to_singulo = get_dist(source, host)

	var/obj/item/projectile/P = entered
	var/distance = distance_to_singulo
	var/projectile_angle = P.Angle
	var/angle_to_projectile = angle_to_singulo
	if(angle_to_projectile == 180)
		angle_to_projectile = -180
	angle_to_projectile -= projectile_angle
	if(angle_to_projectile > 180)
		angle_to_projectile -= 360
	else if(angle_to_projectile < -180)
		angle_to_projectile += 360

	if(distance == 0)
		qdel(P)
		return
	projectile_angle += angle_to_projectile / (distance ** 2)
	P.damage += 10 / distance
	P.set_angle(projectile_angle)
