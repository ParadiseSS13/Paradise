/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/rig_restrict_helmet = 0 // Stops the user from equipping a rig helmet without attaching it to the suit first.
	var/scan_reagents = 0 //Can the wearer see reagents while it's equipped?

	/*
		Sprites used when the clothing item is refit. This is done by setting icon_override.
		For best results, if this is set then sprite_sheets should be null and vice versa, but that is by no means necessary.
		Ideally, sprite_sheets_refit should be used for "hard" clothing items that can't change shape very well to fit the wearer (e.g. helmets, hardsuits),
		while sprite_sheets should be used for "flexible" clothing items that do not need to be refitted (e.g. vox wearing jumpsuits).
	*/
	var/list/sprite_sheets_refit = null
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

	var/flash_protect = 0		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = 0				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//but seperated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		//same as visor_flags, but for flags_inv

	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0

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
				to_chat(M, "\red Your species cannot wear [src].")
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
			qdel(O)
			O = src
	else
		O = src

	user.unEquip(src)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

	if(istype(src,/obj/item/clothing/ears/offear))
		qdel(src)

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
	strip_delay = 15
	put_on_delay = 25

//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2.0
	flags = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	materials = list(MAT_GLASS = 250)
	var/emagged = 0
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	var/color_view = null//overrides client.color while worn
	strip_delay = 20			//	   but seperated to allow items to protect but not impair vision, like space helmets
	put_on_delay = 25
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
	strip_delay = 20
	put_on_delay = 40
	species_restricted = list("exclude","Unathi","Tajaran","Wryn")
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/gloves.dmi'
		)

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(!clipped)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] snips the fingertips off [src].</span>","<span class='warning'>You snip the fingertips off [src].</span>")
			clipped = 1
			name = "mangled [name]"
			desc = "[desc] They have had the fingertips cut off of them."
			if("exclude" in species_restricted)
				species_restricted -= "Unathi"
				species_restricted -= "Tajaran"
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] have already been clipped!</span>")
		return
	else
		..()

/obj/item/clothing/gloves/proc/Touch()
	return

/obj/item/clothing/under/proc/set_sensors(mob/user as mob)
	var/mob/M = user
	if (istype(M, /mob/dead/)) return
	if (user.stat || user.restrained()) return
	if(has_sensor >= 2)
		to_chat(user, "The controls are locked.")
		return 0
	if(has_sensor <= 0)
		to_chat(user, "This suit does not have any sensors.")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(user, src) > 1)
		to_chat(user, "You have moved too far away.")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == user)
		switch(sensor_mode)
			if(0)
				to_chat(user, "You disable your suit's remote sensing equipment.")
			if(1)
				to_chat(user, "Your suit will now report whether you are live or dead.")
			if(2)
				to_chat(user, "Your suit will now report your vital lifesigns.")
			if(3)
				to_chat(user, "Your suit will now report your vital lifesigns as well as your coordinate position.")
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.update_suit_sensors()

	else if (istype(src.loc, /mob))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(user, 1))
					V.show_message("\red [user] disables [src.loc]'s remote sensing equipment.", 1)
			if(1)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] turns [src.loc]'s remote sensors to binary.", 1)
			if(2)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [src.loc]'s sensors to track vitals.", 1)
			if(3)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [src.loc]'s sensors to maximum.", 1)
		if(istype(src,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			if(H.w_uniform == src)
				H.update_suit_sensors()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)
	..()

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	var/blockTracking // Do we block AI tracking?
	var/HUDType = null
	var/darkness_view = 0
	var/vision_flags = 0
	var/see_darkness = 1
	var/can_toggle = null

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	var/mask_adjusted = 0
	var/ignore_maskadjust = 1
	var/adjusted_flags = null
	strip_delay = 40
	put_on_delay = 40

//Proc that moves gas/breath masks out of the way
/obj/item/clothing/mask/proc/adjustmask(var/mob/user)
	var/mob/living/carbon/human/H = usr //Used to check if the mask is on the head, to check if the hands are full, and to turn off internals if they were on when the mask was pushed out of the way.
	if(!ignore_maskadjust)
		if(user.incapacitated()) //This check allows you to adjust your masks while you're buckled into chairs or beds.
			return
		if(mask_adjusted)
			icon_state = copytext(icon_state, 1, findtext(icon_state, "_up")) /*Trims the '_up' off the end of the icon state, thus reverting to the most recent previous state.
																				Had to use this instead of initial() because initial reverted to the wrong state.*/
			gas_transfer_coefficient = initial(gas_transfer_coefficient)
			permeability_coefficient = initial(permeability_coefficient)
			to_chat(user, "You push \the [src] back into place.")
			mask_adjusted = 0
			slot_flags = initial(slot_flags)
			if(flags_inv != initial(flags_inv))
				if(initial(flags_inv) & HIDEFACE) //If the mask is one that hides the face and can be adjusted yet lost that trait when it was adjusted, make it hide the face again.
					flags_inv |= HIDEFACE
			if(flags != initial(flags))
				if(initial(flags) & MASKCOVERSMOUTH) //If the mask covers the mouth when it's down and can be adjusted yet lost that trait when it was adjusted, make it cover the mouth again.
					flags |= MASKCOVERSMOUTH
				if(initial(flags) & AIRTIGHT) //If the mask is airtight and thus, one that you'd be able to run internals from yet can't because it was adjusted, make it airtight again.
					flags |= AIRTIGHT
			if(H.head == src)
				if(flags_inv == HIDEFACE) //Means that only things like bandanas and balaclavas will be affected since they obscure the identity of the wearer.
					if(H.l_hand && H.r_hand) //If both hands are occupied, drop the object on the ground.
						user.unEquip(src)
					else //Otherwise, put it in an available hand, the active one preferentially.
						src.loc = user
						H.head = null
						user.put_in_hands(src)
		else
			icon_state += "_up"
			to_chat(user, "You push \the [src] out of the way.")
			gas_transfer_coefficient = null
			permeability_coefficient = null
			mask_adjusted = 1
			if(adjusted_flags)
				slot_flags = adjusted_flags
			if(ishuman(user))
				if(H.internal)
					if(user.wear_mask == src) /*If the user was wearing the mask providing internals on their face at the time it was adjusted, turn off internals.
												Otherwise, they adjusted it while it was in their hands or some such so we won't be needing to turn off internals.*/
						if(H.internals)
							H.internals.icon_state = "internal0"
						H.internal = null
			if(flags_inv & HIDEFACE) //Means that only things like bandanas and balaclavas will be affected since they obscure the identity of the wearer.
				flags_inv &= ~HIDEFACE /*Done after the above to avoid having to do a check for initial(src.flags_inv == HIDEFACE).
										This reveals the user's face since the bandana will now be going on their head.*/
			if(flags & MASKCOVERSMOUTH) //Mask won't cover the mouth any more since it's been pushed out of the way. Allows for CPRing with adjusted masks.
				flags &= ~MASKCOVERSMOUTH
			if(flags & AIRTIGHT) //If the mask was airtight, it won't be anymore since you just pushed it off your face.
				flags &= ~AIRTIGHT
			if(user.wear_mask == src)
				if(initial(flags_inv) == HIDEFACE) //Means that you won't have to take off and put back on simple things like breath masks which, realistically, can just be pulled down off your face.
					if(H.l_hand && H.r_hand) //If both hands are occupied, drop the object on the ground.
						user.unEquip(src)
					else //Otherwise, put it in an available hand, the active one preferentially.
						src.loc = user
						user.wear_mask = null
						user.put_in_hands(src)
		usr.update_inv_wear_mask()
		usr.update_inv_head()

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammatically correct text-parsing
	var/chained = 0
	var/can_cut_open = 0
	var/cut_open = 0
	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	var/silence_steps = 0
	var/shoe_sound_footstep = 1
	var/shoe_sound = null

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude","Unathi","Tajaran","Wryn")
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/shoes.dmi'
		)

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/match) && src.loc == user)
		var/obj/item/weapon/match/M = I
		if(!M.lit) // Match isn't lit, but isn't burnt.
			M.lit = 1
			M.icon_state = "match_lit"
			processing_objects.Add(M)
			M.update_icon()
			user.visible_message("<span class='warning'>[user] strikes a [M] on the bottom of [src], lighting it.</span>","<span class='warning'>You strike the [M] on the bottom of [src] to light it.</span>")
			playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, 1)
		else if(M.lit == 1) // Match is lit, not extinguished.
			M.dropped()
			user.visible_message("<span class='warning'>[user] crushes the [M] into the bottom of [src], extinguishing it.</span>","<span class='warning'>You crush the [M] into the bottom of [src], extinguishing it.</span>")
		else // Match has been previously lit and extinguished.
			to_chat(user, "<span class='notice'>The [M] has already been extinguished.</span>")
		return

	if(istype(I, /obj/item/weapon/wirecutters))
		if(can_cut_open)
			if(!cut_open)
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] cuts open the toes of [src].</span>","<span class='warning'>You cut open the toes of [src].</span>")
				cut_open = 1
				icon_state = "[icon_state]_opentoe"
				item_state = "[item_state]_opentoe"
				name = "mangled [name]"
				desc = "[desc] They have had their toes opened up."
				if("exclude" in species_restricted)
					species_restricted -= "Unathi"
					species_restricted -= "Tajaran"
				update_icon()
			else
				to_chat(user, "<span class='notice'>[src] have already had their toes cut open!</span>")
			return
	else
		..()

/obj/item/clothing/shoes/proc/step_action(var/mob/living/carbon/human/H) //squeek squeek
	if(shoe_sound)
		var/turf/T = get_turf(H)

		if(!istype(H) || !istype(T))
			return 0

		if(H.m_intent == "run")
			if(shoe_sound_footstep >= 2)
				if(T.shoe_running_volume)
					playsound(src, shoe_sound, T.shoe_running_volume, 1)
				shoe_sound_footstep = 0
			else
				shoe_sound_footstep++
		else if(T.shoe_walking_volume)
			playsound(src, shoe_sound, T.shoe_walking_volume, 1)

	return 1

/obj/item/proc/negates_gravity()
	return 0

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/suit_adjusted = 0
	var/ignore_suitadjust = 1
	var/adjust_flavour = null

//Proc that opens and closes jackets.
/obj/item/clothing/suit/proc/adjustsuit(var/mob/user)
	if(!ignore_suitadjust)
		if(!user.incapacitated())
			if(!(HULK in user.mutations))
				if(suit_adjusted)
					var/flavour = "close"
					icon_state = copytext(icon_state, 1, findtext(icon_state, "_open")) /*Trims the '_open' off the end of the icon state, thus avoiding a case where jackets that start open will
																							end up with a suffix of _open_open if adjusted twice, since their initial state is _open. */
					item_state = copytext(item_state, 1, findtext(item_state, "_open"))
					if(adjust_flavour)
						flavour = "[copytext(adjust_flavour, 3, lentext(adjust_flavour) + 1)] up" //Trims off the 'un' at the beginning of the word. unzip -> zip, unbutton->button.
					to_chat(user, "You [flavour] \the [src].")
					suit_adjusted = 0 //Suit is no longer adjusted.
				else
					var/flavour = "open"
					icon_state += "_open"
					item_state += "_open"
					if(adjust_flavour)
						flavour = "[adjust_flavour]"
					to_chat(user, "You [flavour] \the [src].")
					suit_adjusted = 1 //Suit's adjusted.
			else
				if(user.canUnEquip(src)) //Checks to see if the item can be unequipped. If so, lets shred. Otherwise, struggle and fail.
					if(contents) //If the suit's got any storage capability...
						for(var/obj/item/O in contents) //AVOIDING ITEM LOSS. Check through everything that's stored in the jacket and see if one of the items is a pocket.
							if(istype(O, /obj/item/weapon/storage/internal)) //If it's a pocket...
								if(O.contents) //Check to see if the pocket's got anything in it.
									for(var/obj/item/I in O.contents) //Dump the pocket out onto the floor below the user.
										user.unEquip(I,1)

					user.visible_message("<span class='warning'>[user] bellows, [pick("shredding", "ripping open", "tearing off")] their jacket in a fit of rage!</span>","<span class='warning'>You accidentally [pick("shred", "rend", "tear apart")] \the [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")]!</span>")
					user.unEquip(src)
					qdel(src) //Now that the pockets have been emptied, we can safely destroy the jacket.
					user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
				else
					to_chat(user, "<span class='warning'>You yank and pull at \the [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")], however you are unable to change its state!</span>")//Yep, that's all they get. Avoids having to snowflake in a cooldown.

					return
			user.update_inv_wear_suit()
	else
		to_chat(user, "<span class='notice'>You attempt to button up the velcro on \the [src], before promptly realising how retarded you are.</span>")

/obj/item/clothing/suit/verb/openjacket(var/mob/user) //The verb you can use to adjust jackets.
	set name = "Open/Close Jacket"
	set category = "Object"
	set src in usr
	if(!isliving(usr))
		return
	if(usr.stat)
		return
	adjustsuit(user)

/obj/item/clothing/suit/ui_action_click() //This is what happens when you click the HUD action button to adjust your suit.
	if(!ignore_suitadjust)
		adjustsuit(usr)
	else ..() //This is required in order to ensure that the UI buttons for items that have alternate functions tied to UI buttons still work.

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
	species_restricted = list("exclude","Diona","Vox","Wryn")
	flash_protect = 2
	strip_delay = 50
	put_on_delay = 50

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
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	put_on_delay = 80
	species_restricted = list("exclude","Diona","Vox","Wryn")

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/uniform.dmi'
		)
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
			user.unEquip(I) // Make absolutely sure this accessory is removed from hands
			accessories += A
			A.on_attached(src, user)

			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()

			return
		else
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")

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

/obj/item/clothing/under/examine(mob/user)
	..(user)
	switch(src.sensor_mode)
		if(0)
			to_chat(user, "Its sensors appear to be disabled.")
		if(1)
			to_chat(user, "Its binary life sensors appear to be enabled.")
		if(2)
			to_chat(user, "Its vital tracker appears to be enabled.")
		if(3)
			to_chat(user, "Its vital tracker and tracking beacon appear to be enabled.")
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			to_chat(user, "\A [A] is attached to it.")


/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr

	if(!istype(usr, /mob/living) || usr.incapacitated())
		return

	if(copytext(item_color,-2) != "_d")
		basecolor = item_color
	if(basecolor + "_d_s" in icon_states('icons/mob/uniform.dmi'))
		item_color = item_color == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
		usr.update_inv_w_uniform()
	else
		to_chat(usr, "<span class='notice'>You cannot roll down the uniform!</span>")

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

