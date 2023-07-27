/obj/item/clothing
	name = "clothing"
	max_integrity = 200
	integrity_failure = 80
	resistance_flags = FLAMMABLE
	var/list/species_restricted = null //Only these species can wear this kit.
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
	var/alt_desc = null
	var/flash_protect = FLASH_PROTECTION_NONE		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = FLASH_PROTECTION_NONE				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = FALSE					//but seperated to allow items to protect but not impair vision, like space helmets

	var/visor_flags = NONE			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = NONE		//same as visor_flags, but for flags_inv
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_DARKNESSVIEW | VISOR_INVISVIEW //what to toggle when toggled with weldingvisortoggle()

	var/can_toggle = FALSE
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0
	var/species_disguise = null
	var/magical = FALSE
	var/dyeable = FALSE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/update_icon_state()
	if(!can_toggle)
		return
	/// Done as such to not break chameleon gear since you can't rely on initial states
	icon_state = "[replacetext("[icon_state]", "_up", "")][up ? "_up" : ""]"
	return TRUE

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	to_chat(user, "<span class='notice'>You adjust \the [src] [up ? "up" : "down"].</span>")

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)
	update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M as mob, slot)

	//if we can't equip the item anyway, don't bother with species_restricted (also cuts down on spam)
	if(!..())
		return 0

	// Skip species restriction checks on non-equipment slots
	if(slot in list(slot_r_hand, slot_l_hand, slot_in_backpack, slot_l_store, slot_r_store))
		return 1

	if(species_restricted && ishuman(M))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.dna.species)
			if(exclusive)
				if(!(H.dna.species.name in species_restricted))
					wearable = 1
			else
				if(H.dna.species.name in species_restricted)
					wearable = 1

			if(!wearable)
				to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")
				return 0

	return 1

/obj/item/clothing/proc/refit_for_species(target_species)
	//Set species_restricted list
	switch(target_species)
		if("Human", "Skrell")	//humanoid bodytypes
			species_restricted = list("exclude","Unathi","Tajaran","Diona","Vox","Drask")
		else
			species_restricted = list(target_species)

	//Set icon
	if(sprite_sheets && (target_species in sprite_sheets))
		icon_override = sprite_sheets[target_species]
	else
		icon_override = initial(icon_override)

	if(sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

/**
  * Used for any clothing interactions when the user is on fire. (e.g. Cigarettes getting lit.)
  */
/obj/item/clothing/proc/catch_fire() //Called in handle_fire()
	return

//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 2
	slot_flags = SLOT_EARS
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/ears.dmi') //We read you loud and skree-er.

/obj/item/clothing/ears/attack_hand(mob/user)
	if(!user)
		return

	if(loc != user || !ishuman(user))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.l_ear != src && H.r_ear != src)
		..()
		return

	if(!usr.canUnEquip(src))
		return

	var/obj/item/clothing/ears/O
	if(slot_flags & SLOT_TWOEARS )
		O = (H.l_ear == src ? H.r_ear : H.l_ear)
		user.unEquip(O)
		if(!istype(src, /obj/item/clothing/ears/offear))
			qdel(O)
			O = src
	else
		O = src

	user.unEquip(src)

	if(O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

	if(istype(src, /obj/item/clothing/ears/offear))
		qdel(src)


/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "block"
	slot_flags = SLOT_EARS | SLOT_TWOEARS

/obj/item/clothing/ears/offear/New(obj/O)
	. = ..()
	name = O.name
	desc = O.desc
	icon = O.icon
	icon_state = O.icon_state
	dir = O.dir


//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	materials = list(MAT_GLASS = 250)
	var/vision_flags = 0
	var/see_in_dark = 0 //Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0
	var/lighting_alpha

	var/list/color_view = null//overrides client.color while worn
	var/prescription = 0
	var/prescription_upgradable = FALSE
	var/over_mask = FALSE //Whether or not the eyewear is rendered above the mask. Purely cosmetic.
	strip_delay = 20			//	   but seperated to allow items to protect but not impair vision, like space helmets
	put_on_delay = 25
	resistance_flags = NONE

/*
 * SEE_SELF  // can see self, no matter what
 * SEE_MOBS  // can see all mobs, no matter what
 * SEE_OBJS  // can see all objs, no matter what
 * SEE_TURFS // can see all turfs (and areas), no matter what
 * SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
 *           // in a lit area (via pixel_x,y or smooth movement), can see those pixels
 * BLIND     // can't see anything
*/

/obj/item/clothing/glasses/verb/adjust_eyewear() //Adjust eyewear to be worn above or below the mask.
	set name = "Adjust Eyewear"
	set category = "Object"
	set desc = "Adjust your eyewear to be worn over or under a mask."
	set src in usr

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if(user.incapacitated()) //Dead spessmen adjust no glasses. Resting/buckled ones do, though
		return

	var/action_fluff = "You adjust \the [src]"
	if(user.glasses == src)
		if(!user.canUnEquip(src))
			to_chat(usr, "[src] is stuck to you!")
			return
		if(attack_hand(user)) //Remove the glasses for this action. Prevents logic-defying instances where glasses phase through your mask as it ascends/descends to another plane of existence.
			action_fluff = "You remove \the [src] and adjust it"

	over_mask = !over_mask
	to_chat(user, "<span class='notice'>[action_fluff] to be worn [over_mask ? "over" : "under"] a mask.</span>")

//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	///Carn: for grammarically correct text-parsing
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	var/transfer_prints = FALSE
	///Master pickpocket?
	var/pickpocket = 0
	var/clipped = 0
	///Do they protect the wearer from poison ink?
	var/safe_from_poison = FALSE
	strip_delay = 20
	put_on_delay = 40

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi'
		)

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return // return TRUE to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wirecutters))
		if(!clipped)
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] snips the fingertips off [src].</span>","<span class='warning'>You snip the fingertips off [src].</span>")
			clipped = TRUE
			name = "mangled [name]"
			desc = "[desc] They have had the fingertips cut off of them."
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] have already been clipped!</span>")
		return
	else
		return ..()

/**
 * Tries to turn the sensors off. Returns TRUE if it succeeds
 */
/obj/item/clothing/under/proc/turn_sensors_off()
	if(has_sensor != SUIT_SENSOR_BINARY)
		return FALSE
	sensor_mode = SUIT_SENSOR_OFF
	return TRUE

/obj/item/clothing/under/proc/set_sensors(mob/user as mob)
	if(!user.Adjacent(src) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(has_sensor >= 2)
		to_chat(user, "The controls are locked.")
		return
	if(has_sensor <= SUIT_SENSOR_OFF)
		to_chat(user, "This suit does not have any sensors.")
		return

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes

	if(!user.Adjacent(src))
		to_chat(user, "<span class='warning'>You have moved too far away!</span>")
		return
	if(!ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't use your hands!</span>")
		return

	sensor_mode = modes.Find(switchMode) - 1

	if(src.loc == user)
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				to_chat(user, "You disable your suit's remote sensing equipment.")
			if(SUIT_SENSOR_BINARY)
				to_chat(user, "Your suit will now report whether you are live or dead.")
			if(SUIT_SENSOR_VITAL)
				to_chat(user, "Your suit will now report your vital lifesigns.")
			if(SUIT_SENSOR_TRACKING)
				to_chat(user, "Your suit will now report your vital lifesigns as well as your coordinate position.")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.update_suit_sensors()

	else if(ismob(src.loc))
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				for(var/mob/V in viewers(user, 1))
					V.show_message("<span class='warning'>[user] disables [src.loc]'s remote sensing equipment.</span>", 1)
			if(SUIT_SENSOR_BINARY)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] turns [src.loc]'s remote sensors to binary.", 1)
			if(SUIT_SENSOR_VITAL)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [src.loc]'s sensors to track vitals.", 1)
			if(SUIT_SENSOR_TRACKING)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [src.loc]'s sensors to maximum.", 1)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.w_uniform == src)
				H.update_suit_sensors()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr

	set_sensors(usr)

/obj/item/clothing/under/AltShiftClick(mob/user)
	set_sensors(user)

//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	var/blockTracking // Do we block AI tracking?
	var/HUDType = null

	var/vision_flags = 0
	var/see_in_dark = 0
	var/lighting_alpha

/obj/item/clothing/head/update_icon_state()
	if(..())
		item_state = "[replacetext("[item_state]", "_up", "")][up ? "_up" : ""]"

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	var/adjusted_flags = null
	strip_delay = 40
	put_on_delay = 40

//Proc that moves gas/breath masks out of the way
/obj/item/clothing/mask/proc/adjustmask(mob/user)
	var/mob/living/carbon/human/H = usr //Used to check if the mask is on the head, to check if the hands are full, and to turn off internals if they were on when the mask was pushed out of the way.
	if(user.incapacitated()) //This check allows you to adjust your masks while you're buckled into chairs or beds.
		return

	up = !up
	update_icon(UPDATE_ICON_STATE)

	if(!up)
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		permeability_coefficient = initial(permeability_coefficient)
		to_chat(user, "<span class='notice'>You push \the [src] back into place.</span>")
		slot_flags = initial(slot_flags)
		if(flags_inv != initial(flags_inv))
			if(initial(flags_inv) & HIDEFACE) //If the mask is one that hides the face and can be adjusted yet lost that trait when it was adjusted, make it hide the face again.
				flags_inv |= HIDEFACE
		if(flags != initial(flags))
			if(initial(flags) & AIRTIGHT) //If the mask is airtight and thus, one that you'd be able to run internals from yet can't because it was adjusted, make it airtight again.
				flags |= AIRTIGHT
		if(flags_cover != initial(flags_cover))
			if(initial(flags_cover) & MASKCOVERSMOUTH) //If the mask covers the mouth when it's down and can be adjusted yet lost that trait when it was adjusted, make it cover the mouth again.
				flags_cover |= MASKCOVERSMOUTH
		if(H.head == src)
			if(isnull(user.get_item_by_slot(slot_bitfield_to_slot(slot_flags))))
				user.unEquip(src)
				user.equip_to_slot(src, slot_bitfield_to_slot(slot_flags))
			else if(flags_inv == HIDEFACE) //Means that only things like bandanas and balaclavas will be affected since they obscure the identity of the wearer.
				if(H.l_hand && H.r_hand) //If both hands are occupied, drop the object on the ground.
					user.unEquip(src)
				else //Otherwise, put it in an available hand, the active one preferentially.
					user.unEquip(src)
					user.put_in_hands(src)
	else
		to_chat(user, "<span class='notice'>You push \the [src] out of the way.</span>")
		gas_transfer_coefficient = null
		permeability_coefficient = null
		if(adjusted_flags)
			slot_flags = adjusted_flags
		if(ishuman(user) && H.internal && !H.get_organ_slot("breathing_tube") && user.wear_mask == src) /*If the user was wearing the mask providing internals on their face at the time it was adjusted, turn off internals.
																Otherwise, they adjusted it while it was in their hands or some such so we won't be needing to turn off internals.*/
			H.internal = null
			H.update_action_buttons_icon()
		if(flags_inv & HIDEFACE) //Means that only things like bandanas and balaclavas will be affected since they obscure the identity of the wearer.
			flags_inv &= ~HIDEFACE /*Done after the above to avoid having to do a check for initial(src.flags_inv == HIDEFACE).
									This reveals the user's face since the bandana will now be going on their head.*/
		if(flags_cover & MASKCOVERSMOUTH) //Mask won't cover the mouth any more since it's been pushed out of the way. Allows for CPRing with adjusted masks.
			flags_cover &= ~MASKCOVERSMOUTH
		if(flags & AIRTIGHT) //If the mask was airtight, it won't be anymore since you just pushed it off your face.
			flags &= ~AIRTIGHT
		if(user.wear_mask == src)
			if(isnull(user.get_item_by_slot(slot_bitfield_to_slot(slot_flags))))
				user.unEquip(src)
				user.equip_to_slot(src, slot_bitfield_to_slot(slot_flags))
			else if(initial(flags_inv) == HIDEFACE) //Means that you won't have to take off and put back on simple things like breath masks which, realistically, can just be pulled down off your face.
				if(H.l_hand && H.r_hand) //If both hands are occupied, drop the object on the ground.
					user.unEquip(src)
				else //Otherwise, put it in an available hand, the active one preferentially.
					user.unEquip(src)
					user.put_in_hands(src)
	H.wear_mask_update(src, toggle_off = up)
	usr.update_inv_wear_mask()
	usr.update_inv_head()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

// Changes the speech verb when wearing a mask if a value is returned
/obj/item/clothing/mask/proc/change_speech_verb()
	return

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammatically correct text-parsing
	var/chained = FALSE
	var/can_cut_open = FALSE
	var/cut_open = FALSE
	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0, BLOOD_BASE_ALPHA = BLOODY_FOOTPRINT_BASE_ALPHA)

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/shoes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/shoes.dmi'
		)

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/match) && src.loc == user)
		var/obj/item/match/M = I
		if(!M.lit && !M.burnt) // Match isn't lit, but isn't burnt.
			user.visible_message("<span class='warning'>[user] strikes a [M] on the bottom of [src], lighting it.</span>","<span class='warning'>You strike [M] on the bottom of [src] to light it.</span>")
			M.matchignite()
			playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, 1)
			return
		if(M.lit && !M.burnt)
			user.visible_message("<span class='warning'>[user] crushes [M] into the bottom of [src], extinguishing it.</span>","<span class='warning'>You crush [M] into the bottom of [src], extinguishing it.</span>")
			M.dropped()
		return

	if(istype(I, /obj/item/wirecutters))
		if(can_cut_open)
			if(!cut_open)
				playsound(src.loc, I.usesound, 100, 1)
				user.visible_message("<span class='warning'>[user] cuts open the toes of [src].</span>","<span class='warning'>You cut open the toes of [src].</span>")
				cut_open = TRUE
				update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)
			else
				to_chat(user, "<span class='notice'>[src] have already had [p_their()] toes cut open!</span>")
		return
	else
		return ..()

/obj/item/clothing/shoes/update_name()
	. = ..()
	if(!cut_open)
		return
	name = "mangled [initial(name)]"

/obj/item/clothing/shoes/update_desc()
	. = ..()
	if(!cut_open)
		return
	desc = "[initial(desc)] They have had their toes opened up."

/obj/item/clothing/shoes/update_icon_state()
	if(!cut_open)
		return
	icon_state = "[icon_state]_opentoe"
	item_state = "[item_state]_opentoe"

/obj/item/proc/negates_gravity()
	return

//Suit
/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits.dmi'
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/suit_toggled = FALSE
	var/suit_adjusted = FALSE
	var/ignore_suitadjust = TRUE
	var/adjust_flavour = null
	var/list/hide_tail_by_species = null
	/// Maximum weight class of an item in the suit storage slot.
	var/max_suit_w = WEIGHT_CLASS_BULKY

//Proc that opens and closes jackets.
/obj/item/clothing/suit/proc/adjustsuit(mob/user)
	if(ignore_suitadjust)
		to_chat(user, "<span class='notice'>You attempt to button up the velcro on \the [src], before promptly realising how foolish you are.</span>")
		return
	if(user.incapacitated())
		return

	if(HAS_TRAIT(user, TRAIT_HULK))
		if(user.canUnEquip(src)) //Checks to see if the item can be unequipped. If so, lets shred. Otherwise, struggle and fail.
			if(contents) //If the suit's got any storage capability...
				for(var/obj/item/O in contents) //AVOIDING ITEM LOSS. Check through everything that's stored in the jacket and see if one of the items is a pocket.
					if(istype(O, /obj/item/storage/internal)) //If it's a pocket...
						if(O.contents) //Check to see if the pocket's got anything in it.
							for(var/obj/item/I in O.contents) //Dump the pocket out onto the floor below the user.
								user.unEquip(I,1)

			user.visible_message("<span class='warning'>[user] bellows, [pick("shredding", "ripping open", "tearing off")] [user.p_their()] jacket in a fit of rage!</span>","<span class='warning'>You accidentally [pick("shred", "rend", "tear apart")] [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")]!</span>")
			user.unEquip(src)
			qdel(src) //Now that the pockets have been emptied, we can safely destroy the jacket.
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
			user.update_inv_wear_suit()
			return
		else
			to_chat(user, "<span class='warning'>You yank and pull at \the [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")], however you are unable to change its state!</span>")//Yep, that's all they get. Avoids having to snowflake in a cooldown.
			return

	if(suit_adjusted)
		var/flavour = "close"
		icon_state = copytext(icon_state, 1, findtext(icon_state, "_open")) /*Trims the '_open' off the end of the icon state, thus avoiding a case where jackets that start open will end up with a suffix of _open_open if adjusted twice, since their initial state is _open. */
		item_state = copytext(item_state, 1, findtext(item_state, "_open"))
		if(adjust_flavour)
			flavour = "[copytext(adjust_flavour, 3, length(adjust_flavour) + 1)] up" //Trims off the 'un' at the beginning of the word. unzip -> zip, unbutton->button.
		to_chat(user, "You [flavour] \the [src].")
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		var/flavour = "open"
		icon_state += "_open"
		item_state += "_open"
		if(adjust_flavour)
			flavour = "[adjust_flavour]"
		to_chat(user, "You [flavour] \the [src].")
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()

	suit_adjusted = !suit_adjusted
	update_icon(UPDATE_ICON_STATE)
	user.update_inv_wear_suit()

/obj/item/clothing/suit/equipped(mob/living/carbon/human/user, slot) //Handle tail-hiding on a by-species basis.
	..()
	if(ishuman(user) && hide_tail_by_species && slot == slot_wear_suit)
		if(user.dna.species.name in hide_tail_by_species)
			if(!(flags_inv & HIDETAIL)) //Hide the tail if the user's species is in the hide_tail_by_species list and the tail isn't already hidden.
				flags_inv |= HIDETAIL
		else
			if(!(initial(flags_inv) & HIDETAIL) && (flags_inv & HIDETAIL)) //Otherwise, remove the HIDETAIL flag if it wasn't already in the flags_inv to start with.
				flags_inv &= ~HIDETAIL

/obj/item/clothing/suit/ui_action_click(mob/user) //This is what happens when you click the HUD action button to adjust your suit.
	if(!ignore_suitadjust)
		adjustsuit(user)
	else
		..() //This is required in order to ensure that the UI buttons for items that have alternate functions tied to UI buttons still work.

/obj/item/clothing/suit/proc/special_overlays() // Does it have special overlays when worn?
	return FALSE

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	w_class = WEIGHT_CLASS_NORMAL
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | THICKMATERIAL
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	item_state = "s_helmet"
	permeability_coefficient = 0.01
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 50, FIRE = 200, ACID = 115)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE
	dog_fashion = null


/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	slowdown = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 50, FIRE = 200, ACID = 115)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	put_on_delay = 80
	resistance_flags = NONE
	hide_tail_by_species = null
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/under/misc.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/misc.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/misc.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/misc.dmi'
		)

	///For the crew computer 2 = unable to change mode
	var/has_sensor = TRUE
	var/sensor_mode = SENSOR_OFF
	var/random_sensor = TRUE
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/list/accessories = list()
	var/displays_id = TRUE
	var/rolled_down = FALSE
	var/basecolor

/obj/item/clothing/under/rank/Initialize(mapload)
	. = ..()
	if(random_sensor)
		sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_VITALS, SENSOR_COORDS)

/obj/item/clothing/under/Destroy()
	QDEL_LIST_CONTENTS(accessories)
	return ..()


/obj/item/clothing/under/dropped(mob/user, silent)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_w_uniform) == src)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attached_unequip()

/obj/item/clothing/under/equipped(mob/user, slot, initial)
	..()
	if(!ishuman(user))
		return
	if(slot == slot_w_uniform)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attached_equip()

/*
  * # can_attach_accessory
  *
  * Arguments:
  * * A - The accessory object being checked. MUST BE TYPE /obj/item/clothing/accessory
*/
/obj/item/clothing/under/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(length(accessories) >= MAX_EQUIPABLE_ACCESSORIES) //this is neccesary to prevent chat spam when examining clothing
		return FALSE
	for(var/obj/item/clothing/accessory/AC in accessories)
		if((A.slot in list(ACCESSORY_SLOT_UTILITY, ACCESSORY_SLOT_ARMBAND)) && AC.slot == A.slot)
			return FALSE
		if(!A.allow_duplicates && AC.type == A.type)
			return FALSE
	return TRUE

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory))
		attach_accessory(I, user, TRUE)

	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attackby(I, user, params)
		return TRUE

	. = ..()

/obj/item/clothing/under/serialize()
	var/data = ..()
	var/list/accessories_list = list()
	data["accessories"] = accessories_list
	for(var/obj/item/clothing/accessory/A in accessories)
		accessories_list.len++
		accessories_list[accessories_list.len] = A.serialize()

	return data

/obj/item/clothing/under/deserialize(list/data)
	for(var/thing in accessories)
		remove_accessory(src, thing)
	for(var/thing in data["accessories"])
		if(islist(thing))
			var/obj/item/clothing/accessory/A = list_to_object(thing, src)
			A.has_suit = src
			accessories += A
	..()

/obj/item/clothing/under/proc/attach_accessory(obj/item/clothing/accessory/A, mob/user, unequip = FALSE)
	if(can_attach_accessory(A))
		if(unequip && !user.unEquip(A)) // Make absolutely sure this accessory is removed from hands
			return FALSE

		accessories += A
		A.on_attached(src, user)

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()

		return TRUE
	else
		to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")

	return FALSE

/obj/item/clothing/under/proc/detach_accessory(obj/item/clothing/accessory/A, mob/user)
	accessories -= A
	A.on_removed(user)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_w_uniform()

/obj/item/clothing/under/examine(mob/user)
	. = ..()

	if(has_sensor >= 1)
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SUIT_SENSOR_BINARY)
				. += "Its binary life sensors appear to be enabled."
			if(SUIT_SENSOR_VITAL)
				. += "Its vital tracker appears to be enabled."
			if(SUIT_SENSOR_TRACKING)
				. += "Its vital tracker and tracking beacon appear to be enabled."
		if(has_sensor == 1)
			. += "Alt-shift-click to toggle the sensors mode."
	else
		. += "This suit does not have any sensors."

	if(length(accessories))
		for(var/obj/item/clothing/accessory/A in accessories)
			. += "\A [A] is attached to it."
		. += "Alt-click to remove an accessory."


/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.stat) return

	var/mob/living/carbon/human/H = usr

	if(!usr.incapacitated())
		if(copytext(item_color,-2) != "_d")
			basecolor = item_color

		if(usr.get_item_by_slot(slot_w_uniform) != src)
			to_chat(usr, "<span class='notice'>You must wear the uniform to adjust it!</span>")

		else
			if((basecolor + "_d_s") in icon_states(H.w_uniform.sprite_sheets[H.dna.species.name]))
				if(H.w_uniform.sprite_sheets[H.dna.species.name] && icon_exists(H.w_uniform.sprite_sheets[H.dna.species.name], "[basecolor]_d_s"))
					item_color = item_color == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
					usr.update_inv_w_uniform()

			else
				if(H.w_uniform.sprite_sheets["Human"] && icon_exists(H.w_uniform.sprite_sheets["Human"], "[basecolor]_d_s"))
					item_color = item_color == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
					usr.update_inv_w_uniform()
				else
					to_chat(usr, "<span class='notice'>You cannot roll down this uniform!</span>")

	else
		to_chat(usr, "<span class='notice'>You cannot roll down the uniform!</span>")

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	handle_accessories_removal()

/obj/item/clothing/under/proc/handle_accessories_removal()
	if(!isliving(usr))
		return
	if(usr.incapacitated())
		return
	if(!Adjacent(usr))
		return
	if(!accessories.len)
		return
	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in accessories
	else
		A = accessories[1]
	remove_accessory(usr,A)

/obj/item/clothing/under/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!(A in accessories))
		return
	if(!isliving(user))
		return
	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	detach_accessory(A, user)
	to_chat(user, "<span class='notice'>You remove [A] from [src].</span>")

/obj/item/clothing/under/emp_act(severity)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()

/obj/item/clothing/under/AltClick()
	handle_accessories_removal()

/obj/item/clothing/obj_destruction(damage_flag)
	if(damage_flag == BOMB || damage_flag == MELEE)
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else
		..()
