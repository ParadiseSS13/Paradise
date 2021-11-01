/obj/vehicle/ambulance
	name = "ambulance"
	desc = "This is what the paramedic uses to run over people they need to take to medbay."
	icon_state = "docwagon2"
	key_type = /obj/item/key/ambulance
	var/obj/structure/bed/amb_trolley/bed = null
	var/datum/action/ambulance_alarm/AA
	var/datum/looping_sound/ambulance_alarm/soundloop
	/// Base move delay
	var/base_move_delay = 1
	/// Delay when boosting
	var/boost_move_delay = 0.5
	/// Delay when emped
	var/emp_move_delay = 5
	var/emped = FALSE

/obj/vehicle/ambulance/Initialize(mapload)
	. = ..()
	AA = new(src)
	soundloop = new(list(src), FALSE)
	vehicle_move_delay = base_move_delay

/obj/vehicle/ambulance/Destroy()
	QDEL_NULL(AA)
	QDEL_NULL(soundloop)
	return ..()

/datum/action/ambulance_alarm
	name = "Toggle Sirens"
	icon_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "docwagon2"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/toggle_cooldown = 40
	var/cooldown = 0


/datum/action/ambulance_alarm/Trigger()
	if(!..())
		return FALSE

	var/obj/vehicle/ambulance/A = target

	if(!istype(A) || !A.soundloop)
		return FALSE

	if(A.emped)
		return FALSE

	if(world.time < cooldown + toggle_cooldown)
		return FALSE

	cooldown = world.time

	toggle()

/// Force-toggle the ambulance alarm
/datum/action/ambulance_alarm/proc/toggle()
	var/obj/vehicle/ambulance/A = target

	if(!istype(A) || !A.soundloop)
		return FALSE

	if(A.soundloop.muted)
		// Go faster when we're using the alarm, we're in a hurry!
		A.vehicle_move_delay = A.boost_move_delay
		A.soundloop.start()
		A.set_light(4,3,"#F70027")
	else
		A.vehicle_move_delay = A.base_move_delay
		A.soundloop.stop()
		A.set_light(0)

/datum/looping_sound/ambulance_alarm
    start_length = 0
    mid_sounds = list('sound/items/weeoo1.ogg' = 1)
    mid_length = 14
    volume = 100


/obj/vehicle/ambulance/post_buckle_mob(mob/living/M)
    . = ..()
    if(has_buckled_mobs())
        AA.Grant(M)
    else
        AA.Remove(M)

/obj/vehicle/ambulance/post_unbuckle_mob(mob/living/M)
	AA.Remove(M)
	return ..()

/obj/vehicle/ambulance/proc/emp_restore()
	emped = FALSE
	vehicle_move_delay = base_move_delay

/obj/vehicle/ambulance/emp_act(severity)
	if(emped)
		// Might as well make it stack
		vehicle_move_delay += 1
		visible_message("<span class='warning'>The slight whine from [src] only grows louder!</span>",
		"<span class='warning'>An electrical whine seems to have grown louder.</span>")
		return

	emped = TRUE

	// Turn the lights off
	if(!soundloop.muted)
		AA.toggle()

	vehicle_move_delay = emp_move_delay

	visible_message("<span class='warning'>You hear an electrical whine from [src], its motors locking up!</span>",
		"<span class='warning'>You hear an electrical whine, like a motor being jammed.</span>")

	addtimer(CALLBACK(src, .proc/emp_restore), 30 SECONDS)


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
		bed.Move(oldloc, get_dir(bed, oldloc), actual_movedelay())
		bed.dir = Dir
		if(bed.has_buckled_mobs())
			for(var/m in bed.buckled_mobs)
				var/mob/living/buckled_mob = m
				buckled_mob.setDir(Dir)

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
