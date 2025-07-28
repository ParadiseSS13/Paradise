/obj/vehicle/ambulance
	name = "ambulance"
	desc = "This is what the paramedic uses to run over people they need to take to medbay."
	icon_state = "docwagon2"
	key_type = /obj/item/key/ambulance
	var/siren_on = FALSE
	var/obj/structure/bed/amb_trolley/bed = null
	var/datum/action/ambulance_alarm/AA
	var/datum/looping_sound/ambulance_alarm/soundloop

/obj/vehicle/ambulance/Initialize(mapload)
	. = ..()
	AA = new(src)
	soundloop = new(list(src), FALSE)

/obj/vehicle/ambulance/Destroy()
	QDEL_NULL(AA)
	QDEL_NULL(soundloop)
	return ..()

/datum/action/ambulance_alarm
	name = "Toggle Sirens"
	button_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "docwagon2"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/toggle_cooldown = 40
	var/cooldown = 0


/datum/action/ambulance_alarm/Trigger(left_click)
	if(!..())
		return FALSE

	var/obj/vehicle/ambulance/A = target

	if(!istype(A) || !A.soundloop)
		return FALSE

	if(world.time < cooldown + toggle_cooldown)
		return FALSE

	cooldown = world.time

	if(A.soundloop.muted)
		A.siren_on = TRUE
		A.soundloop.start()
		A.set_light(4,3,"#F70027")
	else
		A.siren_on = FALSE
		A.soundloop.stop()
		A.set_light(0)


/datum/looping_sound/ambulance_alarm
	start_length = 0
	mid_sounds = list('sound/items/weeoo1.ogg' = 1)
	mid_length = 14


/obj/vehicle/ambulance/post_buckle_mob(mob/living/M)
	. = ..()
	if(has_buckled_mobs())
		AA.Grant(M)
	else
		AA.Remove(M)

/obj/vehicle/ambulance/post_unbuckle_mob(mob/living/M)
	AA.Remove(M)
	return ..()

/obj/item/key/ambulance
	name = "ambulance key"
	desc = "A keyring with a small steel key, and tag with a green cross on it."
	icon_state = "keydoc"


/obj/vehicle/ambulance/handle_vehicle_offsets()
	..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			switch(buckled_mob.dir)
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 7
				if(WEST)
					buckled_mob.pixel_x = 13
					buckled_mob.pixel_y = 7
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4
				if(EAST)
					buckled_mob.pixel_x = -13
					buckled_mob.pixel_y = 7

/obj/vehicle/ambulance/Move(newloc, Dir)
	var/oldloc = loc
	if(bed && !Adjacent(bed))
		bed = null
	. = ..()
	if(bed && get_dist(oldloc, loc) <= 2)
		bed.Move(oldloc, get_dir(bed, oldloc), (last_move_diagonal? 2 : 1) * (vehicle_move_delay + GLOB.configuration.movement.human_delay))
		bed.dir = Dir
		if(bed.has_buckled_mobs())
			for(var/m in bed.buckled_mobs)
				var/mob/living/buckled_mob = m
				buckled_mob.setDir(Dir)

/obj/vehicle/ambulance/Bump(atom/movable/M)
	if(has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			if(L.mind && HAS_TRAIT(L.mind, TRAIT_SPEED_DEMON))
				if(isobj(M))
					var/obj/O = M
					if(!O.anchored)
						step(M, dir)
				else if(ismob(M) && siren_on)
					run_over(M)
					break

/obj/vehicle/ambulance/proc/run_over(mob/living/M)
	var/directional_blocked = FALSE
	var/turf/T = get_step(M.loc, turn(dir, 90))
	if(check_density(T))
		T = get_step(M.loc, turn(dir, -90))
		if(check_density(T))
			directional_blocked = TRUE
		else
			step(M, turn(dir, -90))
	else
		step(M, turn(dir, 90))
	playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
	if(directional_blocked || (emagged == TRUE && installed_vtec == TRUE)) // GET OUT OF THE WAY, ASSHOLE!
		M.KnockDown(2 SECONDS)

/obj/vehicle/ambulance/proc/check_density(turf/T)
	if(T.density)
		return TRUE
	for(var/atom/movable/thing in T.contents)
		if(thing.density)
			return TRUE
	return FALSE

/obj/vehicle/ambulance/emag_act(mob/user)
	emagged = TRUE
	visible_message("[src] sputters and fizzles as the safeties are shorted out!")
	do_sparks(3, 0, src)

/obj/vehicle/ambulance/examine(mob/user)
	. = ..()
	if(emagged && in_range(src, user))
		. += "<span class='danger'>The safeties seem to have been shorted out!</span>"

/obj/structure/bed/amb_trolley
	name = "ambulance train trolley"
	icon = 'icons/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	anchored = FALSE

/obj/structure/bed/amb_trolley/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Drag [src]'s sprite over the ambulance to (de)attach it.</span>"

/obj/structure/bed/amb_trolley/MouseDrop(obj/over_object as obj)
	..()
	if(istype(over_object, /obj/vehicle/ambulance))
		var/obj/vehicle/ambulance/amb = over_object
		if(amb.bed)
			amb.bed = null
			to_chat(usr, "You unhook the bed to the ambulance.")
		else
			amb.bed = src
			to_chat(usr, "You hook the bed to the ambulance.")
