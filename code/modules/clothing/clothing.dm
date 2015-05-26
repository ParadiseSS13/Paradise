/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/rig_restrict_helmet = 0 // Stops the user from equipping a rig helmet without attaching it to the suit first.

	/*
		Sprites used when the clothing item is refit. This is done by setting icon_override.
		For best results, if this is set then sprite_sheets should be null and vice versa, but that is by no means necessary.
		Ideally, sprite_sheets_refit should be used for "hard" clothing items that can't change shape very well to fit the wearer (e.g. helmets, hardsuits),
		while sprite_sheets should be used for "flexible" clothing items that do not need to be refitted (e.g. vox wearing jumpsuits).
	*/
	var/list/sprite_sheets_refit = null

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M as mob, slot)

	//if we can equip the item anyway, don't bother with species_restricted (aslo cuts down on spam)
	if (!..())
		return 0

	if(species_restricted && istype(M,/mob/living/carbon/human))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.species)
			if(exclusive)
				if(!(H.species.name in species_restricted))
					wearable = 1
			else
				if(H.species.name in species_restricted)
					wearable = 1

			if(!wearable)
				M << "\red Your species cannot wear [src]."
				return 0

	return 1

/obj/item/clothing/proc/refit_for_species(var/target_species)
	//Set species_restricted list
	switch(target_species)
		if("Human", "Skrell")	//humanoid bodytypes
			species_restricted = list("exclude","Unathi","Tajaran","Diona","Vox","Wryn")
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets && (target_species in sprite_sheets))
		icon_override = sprite_sheets[target_species]
	else
		icon_override = initial(icon_override)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = 1.0
	throwforce = 2
	slot_flags = SLOT_EARS

/obj/item/clothing/ears/attack_hand(mob/user as mob)
	if (!user) return

	if (src.loc != user || !istype(user,/mob/living/carbon/human))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.l_ear != src && H.r_ear != src)
		..()
		return

	if(flags & NODROP)
		return

	var/obj/item/clothing/ears/O
	if(slot_flags & SLOT_TWOEARS )
		O = (H.l_ear == src ? H.r_ear : H.l_ear)
		user.unEquip(O)
		if(!istype(src,/obj/item/clothing/ears/offear))
			del(O)
			O = src
	else
		O = src

	user.unEquip(src)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

	if(istype(src,/obj/item/clothing/ears/offear))
		del(src)

/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = 5.0
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "block"
	slot_flags = SLOT_EARS | SLOT_TWOEARS

	New(var/obj/O)
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		dir = O.dir

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags = EARBANGPROTECT


//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2.0
	flags = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	var/flash_protect = 0		//Mal: What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = 0				//Mal: Sets the item's level of visual impairment tint, normally set to the same as flash_protect
								//	   but seperated to allow items to protect but not impair vision, like space helmets
	species_restricted = list("exclude","Kidan")
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/


//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2.0
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	var/transfer_prints = FALSE
	var/pickpocket = 0 //Master pickpocket?
	var/clipped = 0
	species_restricted = list("exclude","Unathi","Tajaran","Wryn")

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(clipped == 0)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			user.visible_message("\red [user] snips the fingertips off [src].","\red You snip the fingertips off [src].")
			clipped = 1
			if("exclude" in species_restricted)
				name = "mangled [name]"
				desc = "[desc] They have had the fingertips cut off of them."
				species_restricted -= "Unathi"
				species_restricted -= "Tajaran"
		else if(clipped == 1)
			user << "<span class='notice'>[src] have already been clipped!</span>"
			update_icon()
		return
		..()

/obj/item/clothing/gloves/proc/Touch()
	return

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/under/proc/set_sensors(mob/usr as mob)
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat || usr.restrained()) return
	if(has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(has_sensor <= 0)
		usr << "This suit does not have any sensors."
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		usr << "You have moved too far away."
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				usr << "You disable your suit's remote sensing equipment."
			if(1)
				usr << "Your suit will now report whether you are live or dead."
			if(2)
				usr << "Your suit will now report your vital lifesigns."
			if(3)
				usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
	else if (istype(src.loc, /mob))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("\red [usr] disables [src.loc]'s remote sensing equipment.", 1)
			if(1)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] turns [src.loc]'s remote sensors to binary.", 1)
			if(2)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] sets [src.loc]'s sensors to track vitals.", 1)
			if(3)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] sets [src.loc]'s sensors to maximum.", 1)

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	var/loose = 10 // probability (0..100) of coming off your head when you fall over or lay down
	var/blockTracking // Do we block AI tracking?
	var/flash_protect = 0
	var/tint = 0

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	var/mask_adjusted = 0
	var/ignore_maskadjust = 1
	var/adjusted_flags = null
	var/flash_protect = 0
	var/tint = 0

//Proc that moves gas/breath masks out of the way
/obj/item/clothing/mask/proc/adjustmask(var/mob/user)
	if(!ignore_maskadjust)
		if(!user.canmove || user.stat || user.restrained())
			return
		if(src.mask_adjusted == 1)
			src.icon_state = initial(icon_state)
			gas_transfer_coefficient = initial(gas_transfer_coefficient)
			permeability_coefficient = initial(permeability_coefficient)
			user << "You push \the [src] back into place."
			src.mask_adjusted = 0
			slot_flags = initial(slot_flags)
		else
			src.icon_state += "_up"
			user << "You push \the [src] out of the way."
			gas_transfer_coefficient = null
			permeability_coefficient = null
			src.mask_adjusted = 1
			if(adjusted_flags)
				slot_flags = adjusted_flags
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.internal)
					if(H.internals)
						H.internals.icon_state = "internal0"
					H.internal = null
		usr.update_inv_wear_mask()

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0
	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude","Unathi","Tajaran","Wryn")

/obj/item/proc/negates_gravity()
	return 0

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	siemens_coefficient = 0.9

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL
	item_state = "s_helmet"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Vox","Wryn")
	loose = 0 // What kind of idiot designs a pressurized suit where the helmet can fall off?
	flash_protect = 2

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank)
	slowdown = 2
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT||HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0.9
	species_restricted = list("exclude","Diona","Vox","Wryn")

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/list/accessories = list()
	var/displays_id = 1
	var/rolled_down = 0
	var/basecolor

/obj/item/clothing/under/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(istype(A))
		.=1
	else
		return 0
	if(accessories.len && (A.slot in list("utility","armband")))
		for(var/obj/item/clothing/accessory/AC in accessories)
			if (AC.slot == A.slot)
				return 0

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(can_attach_accessory(A))
			user.drop_item()
			accessories += A
			A.on_attached(src, user)

			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()

			return
		else
			user << "<span class='notice'>You cannot attach more accessories of this type to [src].</span>"

	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attackby(I, user, params)
		return

	..()

/obj/item/clothing/under/attack_hand(mob/user as mob)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(accessories.len && src.loc == user)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attack_hand(user)
		return

	if (ishuman(usr) && src.loc == user)	//make it harder to accidentally undress yourself
		return

	..()

/obj/item/clothing/under/MouseDrop(obj/over_object as obj)
	if (ishuman(usr))
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (!(src.loc == usr))
			return

		if (!( usr.restrained() ) && !( usr.stat ) && ( over_object ))
			switch(over_object.name)
				if("r_hand")
					usr.unEquip(src)
					usr.put_in_r_hand(src)
				if("l_hand")
					usr.unEquip(src)
					usr.put_in_l_hand(src)
			src.add_fingerprint(usr)
			return
	return

/obj/item/clothing/under/examine()
	set src in view()
	..()
	switch(src.sensor_mode)
		if(0)
			usr << "Its sensors appear to be disabled."
		if(1)
			usr << "Its binary life sensors appear to be enabled."
		if(2)
			usr << "Its vital tracker appears to be enabled."
		if(3)
			usr << "Its vital tracker and tracking beacon appear to be enabled."
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			usr << "\A [A] is attached to it."

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat) return
	if(src.has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(src.has_sensor <= 0)
		usr << "This suit does not have any sensors."
		return 0
	src.sensor_mode += 1
	if(src.sensor_mode > 3)
		src.sensor_mode = 0
	switch(src.sensor_mode)
		if(0)
			usr << "You disable your suit's remote sensing equipment."
		if(1)
			usr << "Your suit will now report whether you are live or dead."
		if(2)
			usr << "Your suit will now report your vital lifesigns."
		if(3)
			usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
	..()

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	if(copytext(_color,-2) != "_d")
		basecolor = _color
	usr << "DEBUG:[basecolor]"
	if(basecolor + "_d_s" in icon_states('icons/mob/uniform.dmi'))
		_color = _color == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
		usr.update_inv_w_uniform()
	else
		usr << "<span class='notice'>You cannot roll down the uniform!</span>"

/obj/item/clothing/under/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!(A in accessories))
		return

	A.on_removed(user)
	accessories -= A
	usr.update_inv_w_uniform()

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return
	if(!accessories.len) return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in accessories
	else
		A = accessories[1]
	src.remove_accessory(usr,A)

/obj/item/clothing/under/rank/New()
	sensor_mode = pick(0,1,2,3)
	..()

/obj/item/clothing/under/emp_act(severity)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()

