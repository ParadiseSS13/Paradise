/obj/vehicle/ambulance/dejavu
	name = "ambulance"
	desc = "what the paramedic uses to run over people to take to medbay."
	icon_state = "docwagon2"
	key_type = /obj/item/key/ambulance/dejavu

/datum/action/ambulancedejavu_alarm
	name = "Toggle Sirens"
	icon_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "docwagon2"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/toggle_cooldown = 10
	var/cooldown = 0

/datum/action/ambulancedejavu_alarm/Trigger()
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

/datum/looping_sound/ambulancedejavu_alarm
    start_length = 0
    mid_sounds = list('sound/items/dejavu.ogg' = 1)
    mid_length = 14
    volume = 100

/obj/item/key/ambulance/dejavu
	name = "ambulance key"
	desc = "A keyring with a small steel key, and tag with a red cross on it."
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
