/obj/vehicle/ambulance
	name = "ambulance"
	desc = "what the paramedic uses to run over people to take to medbay."
	icon_state = "docwagon2"
	keytype = /obj/item/key/ambulance
	var/obj/structure/bed/amb_trolley/bed = null
	var/datum/action/ambulance_alarm/AA
	var/datum/looping_sound/ambulance_alarm/soundloop

/obj/vehicle/ambulance/New()
	. = ..()
	AA = new(src)
	soundloop = new(list(src), FALSE)

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

	if(world.time < cooldown + toggle_cooldown)
		return FALSE

	cooldown = world.time

	if(A.soundloop.muted)
		A.soundloop.start()
		A.set_light(4,3,"#F70027")
	else
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
	. = ..()
	AA.Remove(M)

/obj/item/key/ambulance
	name = "ambulance key"
	desc = "A keyring with a small steel key, and tag with a red cross on it."
	icon_state = "keydoc"


/obj/vehicle/ambulance/handle_vehicle_offsets()
	..()
	if(buckled_mob)
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
		bed.Move(oldloc)
		bed.dir = Dir
		if(bed.buckled_mob)
			bed.buckled_mob.dir = Dir

/obj/structure/bed/amb_trolley
	name = "ambulance train trolley"
	icon = 'icons/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	anchored = FALSE
	throw_pressure_limit = INFINITY //Throwing an ambulance trolley can kill the process scheduler.

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