/obj/vehicle/ambulance
	name = "ambulance"
	desc = "what the paramedic uses to run over people to take to medbay."
	icon_state = "docwagon2"
	keytype = /obj/item/key/ambulance


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


/obj/vehicle/ambulance/attackby(obj/item/I, mob/user, params)
	//add ambulance bed hookup here
	..()

/obj/vehicle/ambulance/RunOver(var/mob/living/carbon/human/H)
	var/mob/living/carbon/human/D = buckled_mob
	var/list/parts = list("head", "chest", "l_leg", "r_leg", "l_arm", "r_arm")

	H.apply_effects(5, 5)
	for(var/i = 0, i < rand(1,3), i++)
		H.apply_damage(rand(1,5), BRUTE, pick(parts))

	visible_message("<span class='warning'> \The [src] ran over [H]!</span>")
	msg_admin_attack("[key_name_admin(D)] ran over [key_name_admin(H)]")


/obj/structure/stool/bed/amb_trolley
	name = "ambulance train trolley"
	icon = 'icons/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	anchored = 0

/obj/structure/stool/bed/amb_trolley/MouseDrop(obj/over_object as obj)
	..()