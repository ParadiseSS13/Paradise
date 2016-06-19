/obj/vehicle/ambulance
	name = "ambulance"
	desc = "what the paramedic uses to run over people to take to medbay."
	icon_state = "docwagon2"
	keytype = /obj/item/key/ambulance
	var/obj/structure/stool/bed/amb_trolley/bed = null


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
	. = ..()
	if(bed && get_dist(oldloc, loc) <= 2)
		bed.Move(oldloc)
		bed.dir = Dir
		if(bed.buckled_mob)
			bed.buckled_mob.dir = Dir

/obj/structure/stool/bed/amb_trolley
	name = "ambulance train trolley"
	icon = 'icons/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	anchored = 0

/obj/structure/stool/bed/amb_trolley/MouseDrop(obj/over_object as obj)
	..()
	if(istype(over_object, /obj/vehicle/ambulance))
		var/obj/vehicle/ambulance/amb = over_object
		if(amb.bed)
			amb.bed = null
			to_chat(usr, "You unhook the bed to the ambulance.")
		else
			amb.bed = src
			to_chat(usr, "You hook the bed to the ambulance.")