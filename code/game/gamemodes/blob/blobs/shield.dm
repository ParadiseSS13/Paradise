/obj/structure/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "Some blob creature thingy"
	health = 75 
	fire_resist = 2
	var/maxHealth = 75 

/obj/structure/blob/shield/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return

/obj/structure/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/shield/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0

/obj/structure/blob/shield/reflective
	name = "reflective blob"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	icon_state = "blob_idle_glow"
	brute_resist = 0
	health = 50
	maxHealth = 50
	flags_2 = CHECK_RICOCHET_1
	var/reflect_chance = 80 //80% chance to reflect

/obj/structure/blob/shield/reflective/handle_ricochet(obj/item/projectile/P)
	if(P.is_reflectable && prob(reflect_chance))
		var/P_turf = get_turf(P)
		var/face_direction = get_dir(src, P_turf)
		var/face_angle = dir2angle(face_direction)
		var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
		if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
			return FALSE
		var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
		P.setAngle(new_angle_s)
		P.firer = src //so people who fired the lasers are not immune to them when it reflects
		visible_message("<span class='warning'>[P] reflects off [src]!</span>")
		return -1// complete projectile permutation 
	else
		playsound(src, P.hitsound, 50, 1)
		visible_message("<span class='danger'>[src] is hit by \a [P]!</span>")
		take_damage(P.damage, P.damage_type)
		
/obj/structure/blob/shield/reflective/bullet_act()
	return
