/obj/item/clothing
	name = "clothing"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	integrity_failure = 80
	resistance_flags = FLAMMABLE
	permeability_coefficient = 0.8
	/// Only these species can wear this kit.
	var/list/species_restricted
	/// If set to a sprite path, replaces the sprite for monitor heads
	var/icon_monitor = null
	/// Can the wearer see reagents inside transparent containers while it's equipped?
	var/scan_reagents = FALSE
	/// Can the wearer see reagents inside any container and identify blood types while it's equipped?
	var/scan_reagents_advanced = FALSE
	var/alt_desc = null
	var/flash_protect = FLASH_PROTECTION_NONE		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = FLASH_PROTECTION_NONE				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = FALSE					//but seperated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = NONE			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = NONE		//same as visor_flags, but for flags_inv
	var/visor_flags_cover = NONE	//for cover flags
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
	/// Do we block AI tracking?
	var/blockTracking
	/// Detective Work, used for allowing a given atom to leave its fibers on stuff. Allowed by default
	var/can_leave_fibers = TRUE
	/// Detective Work, firing a ballistic weapon will add a signature to this var
	var/gunshot_residue

/obj/item/clothing/update_icon_state()
	if(!can_toggle)
		return
	icon_state = "[initial(icon_state)][up ? "_up" : ""]"
	return TRUE

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	to_chat(user, "<span class='notice'>You adjust \the [src] [up ? "up" : "down"].</span>")

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	update_action_buttons()
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
/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = FALSE)

	//if we can't equip the item anyway, don't bother with species_restricted (also cuts down on spam)
	if(!..())
		return FALSE

	// Skip species restriction checks on non-equipment slots
	if(slot & (ITEM_SLOT_RIGHT_HAND | ITEM_SLOT_LEFT_HAND | ITEM_SLOT_IN_BACKPACK | ITEM_SLOT_LEFT_POCKET | ITEM_SLOT_RIGHT_POCKET))
		return TRUE

	if(species_restricted && ishuman(M))

		var/wearable = FALSE
		var/exclusive = FALSE
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = TRUE

		if(H.dna.species)
			if(exclusive)
				if(!(H.dna.species.name in species_restricted))
					wearable = TRUE
			else
				if(H.dna.species.name in species_restricted)
					wearable = TRUE

			if(!wearable)
				to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")
				return FALSE

	return TRUE

/**
  * Used for any clothing interactions when the user is on fire. (e.g. Cigarettes getting lit.)
  */
/obj/item/clothing/proc/catch_fire() //Called in handle_fire()
	return

//////////////////////////////
// MARK: EARS
//////////////////////////////
// Currently only used for headsets and earmuffs.
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 2
	slot_flags = ITEM_SLOT_BOTH_EARS
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/ears.dmi', //We read you loud and skree-er.
		"Kidan" = 'icons/mob/clothing/species/kidan/ears.dmi'
		)

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

	user.drop_item_to_ground(src)

	if(src)
		user.put_in_hands(src)
		add_fingerprint(user)

/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = WEIGHT_CLASS_HUGE
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "block"

/obj/item/clothing/ears/offear/New(obj/O)
	. = ..()
	name = O.name
	desc = O.desc
	icon = O.icon
	icon_state = O.icon_state
	dir = O.dir

//////////////////////////////
// MARK: GLASSES
//////////////////////////////
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	inhand_icon_state = "glasses"
	flags_cover = GLASSESCOVERSEYES
	slot_flags = ITEM_SLOT_EYES
	materials = list(MAT_GLASS = 250)
	strip_delay = 2 SECONDS
	put_on_delay = 2.5 SECONDS
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
	)
	var/vision_flags = 0
	var/see_in_dark = 0 //Base human is 2
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0
	var/lighting_alpha

	var/list/color_view = null//overrides client.color while worn
	var/prescription = FALSE
	var/prescription_upgradable = FALSE
	/// Overrides colorblindness when interacting with wires
	var/correct_wires = FALSE
	var/over_mask = FALSE //Whether or not the eyewear is rendered above the mask. Purely cosmetic.
	/// If TRUE, will hide the wearer's examines from other players.
	var/hide_examine = FALSE
	new_attack_chain = TRUE

/*
 * SEE_SELF  // can see self, no matter what
 * SEE_MOBS  // can see all mobs, no matter what
 * SEE_OBJS  // can see all objs, no matter what
 * SEE_TURFS // can see all turfs (and areas), no matter what
 * SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
 *           // in a lit area (via pixel_x,y or smooth movement), can see those pixels
 * BLIND     // can't see anything
*/

/obj/item/clothing/glasses/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to adjust if it fits over or under your mask.</span>"

/obj/item/clothing/glasses/AltClick(mob/living/carbon/human/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !istype(user))
		return

	over_mask = !over_mask
	if(user.glasses == src)
		user.update_inv_glasses()
	to_chat(user, "<span class='notice'>You adjust [src] to be worn [over_mask ? "over" : "under"] a mask.</span>")

//////////////////////////////
// MARK: GLOVES
//////////////////////////////
/obj/item/clothing/gloves
	name = "gloves"
	///Carn: for grammarically correct text-parsing
	gender = PLURAL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	permeability_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	attack_verb = list("challenged")
	strip_delay = 2 SECONDS
	put_on_delay = 4 SECONDS
	dyeing_key = DYE_REGISTRY_GLOVES

	var/transfer_prints = FALSE
	///Master pickpocket?
	var/pickpocket = FALSE
	var/clipped = FALSE
	///Do they protect the wearer from poison ink?
	var/safe_from_poison = FALSE

	///Amount of times touching something with these gloves will spill blood on it
	var/transfer_blood = 0

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi'
		)

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return // return TRUE to cancel attack_hand()

/obj/item/clothing/gloves/attackby__legacy__attackchain(obj/item/W, mob/user, params)
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

//////////////////////////////
// MARK: SUIT SENSORS
//////////////////////////////
/**
 * Tries to turn the sensors off. Returns TRUE if it succeeds
 */
/obj/item/clothing/under/proc/turn_sensors_off()
	if(has_sensor != SUIT_SENSOR_BINARY)
		return FALSE
	sensor_mode = SUIT_SENSOR_OFF
	return TRUE

/obj/item/clothing/under/proc/set_sensors(mob/user)
	if(!Adjacent(user) && !user.Adjacent(src))
		to_chat(user, "<span class='warning'>You are too far away!</span>")
		return

	if(!isrobot(user) && (!ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		to_chat(user, "<span class='warning'>You can't use your hands!</span>")
		return

	if(has_sensor >= 2)
		to_chat(user, "<span class='warning'>The controls are locked.</span>")
		return

	if(has_sensor <= SUIT_SENSOR_OFF)
		to_chat(user, "<span class='warning'>This suit does not have any sensors.</span>")
		return

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = tgui_input_list(user, "Select a sensor mode:", "Suit Sensor Mode", modes, modes[sensor_mode + 1])
	// If they walk away after the menu is already open.
	if(!Adjacent(user) && !user.Adjacent(src))
		to_chat(user, "<span class='warning'>You have moved too far away!</span>")
		return
		// If your hands get lopped off or cuffed after the menu is open.
	if(!isrobot(user) && (!ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		to_chat(user, "<span class='warning'>You can't use your hands!</span>")
		return
	if(!switchMode)
		return
	sensor_mode = modes.Find(switchMode) - 1

	if(loc == user)
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				to_chat(user, "You disable your suit's remote sensing equipment.")
			if(SUIT_SENSOR_BINARY)
				to_chat(user, "Your suit will now report whether you are alive or dead.")
			if(SUIT_SENSOR_VITAL)
				to_chat(user, "Your suit will now report your vital lifesigns.")
			if(SUIT_SENSOR_TRACKING)
				to_chat(user, "Your suit will now report your vital lifesigns as well as your coordinate position.")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.w_uniform == src)
				H.update_suit_sensors()
		return

	if(ismob(loc))
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				for(var/mob/V in viewers(user, 1))
					V.show_message("<span class='warning'>[user] disables [loc]'s remote sensing equipment.</span>", 1)
			if(SUIT_SENSOR_BINARY)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] turns [loc]'s remote sensors to binary.", 1)
			if(SUIT_SENSOR_VITAL)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [loc]'s sensors to track vitals.", 1)
			if(SUIT_SENSOR_TRACKING)
				for(var/mob/V in viewers(user, 1))
					V.show_message("[user] sets [loc]'s sensors to maximum.", 1)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.w_uniform == src)
				H.update_suit_sensors()

/obj/item/clothing/under/AltClick(mob/user)
	set_sensors(user)

//////////////////////////////
// MARK: HEAD
//////////////////////////////
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/HUDType = null

	var/vision_flags = 0
	var/see_in_dark = 0
	var/lighting_alpha
	/// the head clothing that this item may be attached to.
	var/obj/item/clothing/under/has_under = null
	/// the attached hats to this hat.
	var/list/attached_hats = list()
	/// if this hat can have hats placed on top of it.
	var/can_have_hats = FALSE
	/// if this hat can be a hat of a hat. Hat^2
	var/can_be_hat = TRUE


/obj/item/clothing/head/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(!length(attached_hats))
		return
	var/obj/item/clothing/head/hat
	if(length(attached_hats) > 1)
		var/pick = radial_menu_helper(usr, src, attached_hats, custom_check = FALSE, require_near = TRUE)
		if(!pick || !istype(pick, /obj/item/clothing/head) || !Adjacent(usr))
			return
		hat = pick
	else
		hat = attached_hats[1]
	remove_hat(user, hat)

/obj/item/clothing/head/Destroy()
	if(is_equipped())
		var/mob/M = loc
		for(var/obj/item/clothing/head/H as anything in attached_hats)
			H.on_removed(M)
	else
		for(var/obj/item/clothing/head/H as anything in attached_hats)
			H.forceMove(get_turf(src))
	attached_hats = null
	return ..()

/obj/item/clothing/head/dropped(mob/user, silent)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_HEAD) == src)
		for(var/obj/item/clothing/head/hat as anything in attached_hats)
			hat.attached_unequip()

/obj/item/clothing/head/examine(mob/user)
	. = ..()
	for(var/obj/item/clothing/head/hat as anything in attached_hats)
		. += "\A [hat] is placed neatly on top."
		. += "<span class='notice'><b>Alt-Shift-Click</b> to remove an accessory.</span>"

//when user attached a hat to H (another hat)
/obj/item/clothing/head/proc/on_attached(obj/item/clothing/head/H, mob/user as mob)
	if(!istype(H))
		return
	has_under = H
	forceMove(has_under)
	has_under.overlays += worn_icon_state
	has_under.actions += actions

	for(var/datum/action/A in actions)
		if(has_under.is_equipped())
			var/mob/M = has_under.loc
			A.Grant(M)

	if(user)
		to_chat(user, "<span class='notice'>You attach [src] to [has_under].</span>")
	add_fingerprint(user)

/obj/item/clothing/head/proc/on_removed(mob/user)
	if(!has_under)
		return
	has_under.overlays -= icon_state
	has_under.actions -= actions

	for(var/datum/action/A in actions)
		if(ismob(has_under.loc))
			var/mob/M = has_under.loc
			A.Remove(M)

	has_under = null
	if(user)
		user.put_in_hands(src)
		add_fingerprint(user)

/obj/item/clothing/head/proc/detach_hat(obj/item/clothing/head/hat, mob/user)
	attached_hats -= hat
	hat.on_removed(user)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()

/obj/item/clothing/head/proc/remove_hat(mob/user, obj/item/clothing/head/hat)
	if(!(hat in attached_hats))
		return
	if(!isliving(user))
		return
	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	detach_hat(hat, user)
	to_chat(user, "<span class='notice'>You remove [hat] from [src].</span>")

/obj/item/clothing/head/proc/attached_unequip(mob/user) // If we need to do something special when clothing is removed from the user
	return

/obj/item/clothing/head/proc/attached_equip(mob/user) // If we need to do something special when clothing is removed from the user
	return

/*
  * # can_attach_hat
  *
  * Arguments:
  * * Hat - The clothing/head object being checked. MUST BE TYPE /obj/item/clothing/head
*/
/obj/item/clothing/head/proc/can_attach_hat(obj/item/clothing/head/hat)
	return length(attached_hats) < 1 && can_have_hats && hat.can_be_hat // this hat already has a hat or cannot be a hat of a hat!

/obj/item/clothing/head/proc/attach_hat(obj/item/clothing/head/hat, mob/user, unequip = FALSE)
	if(can_attach_hat(hat))
		if(unequip && !user.drop_item_to_ground(hat)) // Make absolutely sure this hat is removed from hands
			return FALSE

		attached_hats += hat
		hat.on_attached(src, user)

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_head()

		return TRUE
	else if(hat.has_under)
		return FALSE
	else
		to_chat(user, "<span class='notice'>You cannot place [hat] ontop of [src].</span>")

	return FALSE

/obj/item/clothing/head/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/head) && can_have_hats)
		attach_hat(I, user, TRUE)

	return ..()

//////////////////////////////
// MARK: MASK
//////////////////////////////
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	put_on_delay = 4 SECONDS
	permeability_coefficient = 0.7

	var/adjusted_flags = null

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
			if(isnull(user.get_item_by_slot(slot_flags)))
				user.drop_item_to_ground(src)
				user.equip_to_slot(src, slot_flags)
			else if(flags_inv == HIDEFACE) //Means that only things like bandanas and balaclavas will be affected since they obscure the identity of the wearer.
				if(H.l_hand && H.r_hand) //If both hands are occupied, drop the object on the ground.
					user.drop_item_to_ground(src)
				else //Otherwise, put it in an available hand, the active one preferentially.
					user.drop_item_to_ground(src)
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
			if(isnull(user.get_item_by_slot(slot_flags)))
				user.drop_item_to_ground(src)
				user.equip_to_slot(src, slot_flags)
			else if(initial(flags_inv) == HIDEFACE) //Means that you won't have to take off and put back on simple things like breath masks which, realistically, can just be pulled down off your face.
				if(H.l_hand && H.r_hand) //If both hands are occupied, drop the object on the ground.
					user.drop_item_to_ground(src)
				else //Otherwise, put it in an available hand, the active one preferentially.
					user.drop_item_to_ground(src)
					user.put_in_hands(src)
	H.wear_mask_update(src, toggle_off = up)
	usr.update_inv_wear_mask()
	usr.update_inv_head()
	update_action_buttons()

//////////////////////////////
// MARK: SHOES
//////////////////////////////
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammatically correct text-parsing

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_SHOES
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_SHOES

	permeability_coefficient = 0.4

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/shoes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/shoes.dmi'
	)

	var/chained = FALSE
	var/can_cut_open = FALSE
	var/cut_open = FALSE
	var/no_slip = FALSE
	var/knife_slot = FALSE
	var/obj/item/kitchen/knife/combat/hidden_blade


	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0, BLOOD_BASE_ALPHA = BLOODY_FOOTPRINT_BASE_ALPHA)

/obj/item/clothing/shoes/equipped(mob/user, slot)
	. = ..()
	if(!no_slip || slot != ITEM_SLOT_SHOES)
		return
	ADD_TRAIT(user, TRAIT_NOSLIP, UID())

/obj/item/clothing/shoes/dropped(mob/user)
	..()
	if(!no_slip)
		return
	var/mob/living/carbon/human/H = user
	if(!user)
		return
	if(H.get_item_by_slot(ITEM_SLOT_SHOES) == src)
		REMOVE_TRAIT(H, TRAIT_NOSLIP, UID())

/obj/item/clothing/shoes/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/match) && src.loc == user)
		var/obj/item/match/M = I
		if(!M.lit && !M.burnt) // Match isn't lit, but isn't burnt.
			user.visible_message("<span class='warning'>[user] strikes a [M] on the bottom of [src], lighting it.</span>","<span class='warning'>You strike [M] on the bottom of [src] to light it.</span>")
			M.matchignite()
			playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, 1)
			return
		if(M.lit && !M.burnt && M.w_class <= WEIGHT_CLASS_SMALL)
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

	if(istype(I, /obj/item/kitchen/knife/combat))
		if(!knife_slot)
			to_chat(user, "<span class='notice'>There is no place to put [I] in [src]!</span>")
			return
		if(hidden_blade)
			to_chat(user, "<span class='notice'>There is already something in [src]!</span>")
			return
		if(!user.drop_item_to_ground(I))
			return
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(45) && user.get_item_by_slot(ITEM_SLOT_SHOES) == src)

			var/stabbed_foot = pick("l_foot", "r_foot")
			user.visible_message("<span class='notice'>[user] tries to place [I] into [src] but stabs their own foot!</span>", \
			"<span class='warning'>You go to put [I] into [src], but miss the boot and stab your own foot!</span>")
			user.apply_damage(I.force, BRUTE, stabbed_foot)
			user.drop_item(I)
			return
		user.visible_message("<span class='notice'>[user] places [I] into their [name]!</span>", \
			"<span class='notice'>You place [I] into the side of your [name]!</span>")
		I.forceMove(src)
		hidden_blade = I
		return

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

/obj/item/clothing/shoes/AltClick(mob/user)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !knife_slot)
		return
	if(!hidden_blade)
		to_chat(user, "<span class='warning'>There's nothing in your [name]!</span>")
		return

	if(user.get_active_hand() && user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need an empty hand to pull out [hidden_blade]!</span>")
		return

	user.visible_message("<span class='notice'>[user] pulls [hidden_blade] from their [name]!</span>", \
		"<span class='notice'>You draw [hidden_blade] from your [name]!</span>")
	user.put_in_hands(hidden_blade)
	hidden_blade.add_fingerprint(user)
	hidden_blade = null

/obj/item/clothing/shoes/examine(mob/user)
	. = ..()
	if(knife_slot)
		. += "<span class='notice'>You can <b>Alt-Click</b> [src] to remove a stored knife. Use the knife on the shoes to place one in [src].</span>"
		if(hidden_blade)
			. += "<span class='notice'>Your boot has a [hidden_blade.name] hidden inside of it!</span>"

//////////////////////////////
// MARK: SUIT
//////////////////////////////
/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits.dmi'
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_OUTER_SUIT
	permeability_coefficient = 0.75

	var/fire_resist = T0C + 100
	var/blood_overlay_type = "suit"
	var/suit_toggled = FALSE
	var/suit_adjusted = FALSE
	var/ignore_suitadjust = TRUE
	var/adjust_flavour = null
	var/list/hide_tail_by_species = null
	/// Maximum weight class of an item in the suit storage slot.
	var/max_suit_w = WEIGHT_CLASS_BULKY
	///How long to break out of the suits
	var/breakouttime
	/// How many inserts can you put into the suit
	var/insert_max = 1
	/// Currently applied inserts
	var/list/inserts = list()
	/// Is there a mobility mesh inserted?
	var/mobility_meshed = FALSE
	/// What's the total slowdown from inserts?
	var/insert_slowdown = 0


/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	setup_shielding()
	RegisterSignal(src, COMSIG_INSERT_ATTACH, PROC_REF(attach_insert))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(detach_insert))

/**
 * Wrapper proc to apply shielding through AddComponent().
 * Called in /obj/item/clothing/Initialize().
 * Override with an AddComponent(/datum/component/shielded, args) call containing the desired shield statistics.
 * See /datum/component/shielded documentation for a description of the arguments
 **/
/obj/item/clothing/suit/proc/setup_shielding()
	return

/obj/item/clothing/suit/examine(mob/user)
	. = ..()
	if(length(inserts))
		. += "<span class='notice'>Has [length(inserts)] inserts attached.</span>"
		. += "<span class='notice'>Inserts can be removed with Alt-Click.</span>"

///Hierophant card shielding. Saves me time.
/obj/item/clothing/suit/proc/setup_hierophant_shielding()
	var/datum/component/shielded/shield = GetComponent(/datum/component/shielded)
	if(!shield)
		AddComponent(/datum/component/shielded, recharge_start_delay = 0 SECONDS, shield_icon = "shield-hierophant", run_hit_callback = CALLBACK(src, PROC_REF(hierophant_shield_damaged)))
		return
	if(shield.shield_icon == "shield-hierophant") //If the hierophant shield has been used, recharge it. Otherwise, it's a shielded component we don't want to touch
		shield.current_charges = 3

/// A proc for callback when the shield breaks, since I am stupid and want custom effects.
/obj/item/clothing/suit/proc/hierophant_shield_damaged(mob/living/wearer, attack_text, new_current_charges)
	wearer.visible_message("<span class='danger'>[attack_text] is deflected in a burst of dark-purple sparks!</span>")
	new /obj/effect/temp_visual/cult/sparks/hierophant(get_turf(wearer))
	playsound(wearer,'sound/magic/blind.ogg', 200, TRUE, -2)
	if(new_current_charges == 0)
		wearer.visible_message("<span class='danger'>The runed shield around [wearer] suddenly disappears!</span>")

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
								user.drop_item_to_ground(I, force = TRUE)

			user.visible_message("<span class='warning'>[user] bellows, [pick("shredding", "ripping open", "tearing off")] [user.p_their()] jacket in a fit of rage!</span>","<span class='warning'>You accidentally [pick("shred", "rend", "tear apart")] [src] with your [pick("excessive", "extreme", "insane", "monstrous", "ridiculous", "unreal", "stupendous")] [pick("power", "strength")]!</span>")
			user.drop_item_to_ground(src)
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
		if(adjust_flavour)
			flavour = "[copytext(adjust_flavour, 3, length(adjust_flavour) + 1)] up" //Trims off the 'un' at the beginning of the word. unzip -> zip, unbutton->button.
		to_chat(user, "You [flavour] \the [src].")
		update_action_buttons()
	else
		var/flavour = "open"
		icon_state += "_open"
		if(adjust_flavour)
			flavour = "[adjust_flavour]"
		to_chat(user, "You [flavour] \the [src].")
		update_action_buttons()

	suit_adjusted = !suit_adjusted
	update_icon(UPDATE_ICON_STATE)
	user.update_inv_wear_suit()

/obj/item/clothing/suit/equipped(mob/living/carbon/human/user, slot) //Handle tail-hiding on a by-species basis.
	..()
	if(ishuman(user) && hide_tail_by_species && slot == ITEM_SLOT_OUTER_SUIT)
		if("modsuit" in hide_tail_by_species)
			return
		if(user.dna.species.sprite_sheet_name in hide_tail_by_species)
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

/obj/item/clothing/suit/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	..()
	if(istype(I, /obj/item/smithed_item/insert))
		SEND_SIGNAL(src, COMSIG_INSERT_ATTACH, I, user)

/obj/item/clothing/suit/proc/detach_insert(atom/source, mob/user)
	SIGNAL_HANDLER // COMSIG_CLICK_ALT
	if(!Adjacent(user))
		return
	if(!length(inserts))
		to_chat(user, "<span class='notice'>Your suit has no inserts to remove.</span>")
		return
	INVOKE_ASYNC(src, PROC_REF(finish_detach_insert), user)

/obj/item/clothing/suit/proc/finish_detach_insert(mob/user)
	var/obj/item/smithed_item/insert/old_insert
	if(length(inserts) == 1)
		old_insert = inserts[1]
	else
		old_insert = tgui_input_list(user, "Select an insert", src, inserts)
	if(!istype(old_insert, /obj/item/smithed_item/insert))
		return
	old_insert.on_detached()
	user.put_in_hands(old_insert)

/obj/item/clothing/suit/proc/attach_insert(obj/source_item, obj/item/smithed_item/insert/new_insert, mob/user)
	SIGNAL_HANDLER // COMSIG_INSERT_ATTACH
	if(!Adjacent(user))
		return
	if(!istype(new_insert))
		return
	if(length(inserts) == insert_max)
		to_chat(user, "<span class='notice'>Your suit has no slots to add an insert.</span>")
		return
	if(new_insert.flags & NODROP || !user.transfer_item_to(new_insert, src))
		to_chat(user, "<span class='warning'>[new_insert] is stuck to your hand!</span>")
		return
	inserts += new_insert
	new_insert.on_attached(src)

/obj/item/clothing/suit/proc/resist_restraints(mob/living/carbon/user, break_restraints)
	var/effective_breakout_time = breakouttime
	if(break_restraints)
		effective_breakout_time = 5 SECONDS

	if(user.has_status_effect(STATUS_EFFECT_REMOVE_CUFFS))
		to_chat(user, "<span class='notice'>You are already trying to [break_restraints ? "break" : "remove"] your restraints.</span>")
		return
	user.apply_status_effect(STATUS_EFFECT_REMOVE_CUFFS)

	user.visible_message("<span class='warning'>[user] attempts to [break_restraints ? "break" : "remove"] [src]!</span>", "<span class='notice'>You attempt to [break_restraints ? "break" : "remove"] [src]...</span>")
	to_chat(user, "<span class='notice'>(This will take around [DisplayTimeText(effective_breakout_time)] and you need to stand still.)</span>")

	if(!do_after(user, effective_breakout_time, FALSE, user, hidden = TRUE))
		user.remove_status_effect(STATUS_EFFECT_REMOVE_CUFFS)
		to_chat(user, "<span class='warning'>You fail to [break_restraints ? "break" : "remove"] [src]!</span>")
		return

	user.remove_status_effect(STATUS_EFFECT_REMOVE_CUFFS)
	if(loc != user || user.buckled)
		return

	user.visible_message("<span class='danger'>[user] manages to [break_restraints ? "break" : "remove"] [src]!</span>", "<span class='notice'>You successfully [break_restraints ? "break" : "remove"] [src].</span>")
	user.drop_item_to_ground(src)

//////////////////////////////
// MARK: SPACE SUIT
//////////////////////////////
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "space"
	inhand_icon_state = "s_helmet"
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | THICKMATERIAL
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	permeability_coefficient = 0.01
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 50, FIRE = 200, ACID = 115)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
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
	inhand_icon_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
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
	insert_max = 0 // No inserts for space suits

//////////////////////////////
// MARK: UNDER CLOTHES
//////////////////////////////
/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/under/misc.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	slot_flags = ITEM_SLOT_JUMPSUIT
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	dyeing_key = DYE_REGISTRY_UNDER
	strip_delay = 6 SECONDS
	put_on_delay = 6 SECONDS

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

/obj/item/clothing/under/rank
	inhand_icon_state = "bl_suit"

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
	if(H.get_item_by_slot(ITEM_SLOT_JUMPSUIT) == src)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attached_unequip()

/obj/item/clothing/under/equipped(mob/user, slot, initial)
	..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_JUMPSUIT)
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
		if((A.slot & (ACCESSORY_SLOT_UTILITY | ACCESSORY_SLOT_ARMBAND)) && (AC.slot & A.slot))
			return FALSE
		if(!A.allow_duplicates && AC.type == A.type)
			return FALSE
	return TRUE

/obj/item/clothing/under/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory))
		attach_accessory(I, user, TRUE)

	if(length(accessories))
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attackby__legacy__attackchain(I, user, params)
		return TRUE

	. = ..()

/obj/item/clothing/under/serialize()
	var/data = ..()
	var/list/accessories_list = list()
	data["accessories"] = accessories_list
	for(var/obj/item/clothing/accessory/A in accessories)
		accessories_list.len++
		accessories_list[length(accessories_list)] = A.serialize()

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
		if(unequip && !user.drop_item_to_ground(A)) // Make absolutely sure this accessory is removed from hands
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
			. += "<span class='notice'><b>Alt-Click</b> to toggle the sensors mode.</span>"
	else
		. += "This suit does not have any sensors."

	if(length(accessories))
		for(var/obj/item/clothing/accessory/A in accessories)
			. += "\A [A] is attached to it."
			. += "<span class='notice'><b>Alt-Shift-Click</b> to remove an accessory.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> to roll down this jumpsuit.</span>"

/// Suffix for jumpsuits used in .dmi files when rolled down
#define JUMPSUIT_ROLLED_DOWN_SUFFIX "_d"

/obj/item/clothing/under/proc/roll_undersuit(mob/living/carbon/human/user)
	if(copytext(icon_state, -length(JUMPSUIT_ROLLED_DOWN_SUFFIX)) != JUMPSUIT_ROLLED_DOWN_SUFFIX)
		base_icon_state = icon_state

	var/current_worn_icon = LAZYACCESS(sprite_sheets, user.dna.species.sprite_sheet_name) || worn_icon || 'icons/mob/clothing/under/misc.dmi'
	if(!icon_exists(current_worn_icon, "[base_icon_state][JUMPSUIT_ROLLED_DOWN_SUFFIX]_s"))
		to_chat(user, "<span class='notice'>You cannot roll down this uniform!</span>")
		return

	rolled_down = !rolled_down
	if(rolled_down)
		body_parts_covered &= ~(UPPER_TORSO | LOWER_TORSO | ARMS)
	else
		body_parts_covered = initial(body_parts_covered)
	worn_icon_state = "[base_icon_state][rolled_down ? "[JUMPSUIT_ROLLED_DOWN_SUFFIX]" : ""]"
	user.update_inv_w_uniform()

#undef JUMPSUIT_ROLLED_DOWN_SUFFIX

/obj/item/clothing/under/CtrlShiftClick(mob/living/carbon/human/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !istype(user))
		to_chat(user, "<span class='notice'>You cannot roll down the uniform!</span>")
		return

	if(user.get_item_by_slot(ITEM_SLOT_JUMPSUIT) != src)
		to_chat(user, "<span class='notice'>You must wear the uniform to adjust it!</span>")
		return

	roll_undersuit(user)

/obj/item/clothing/under/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(!length(accessories))
		return
	var/obj/item/clothing/accessory/A
	if(length(accessories) > 1)
		var/pick = radial_menu_helper(usr, src, accessories, custom_check = FALSE, require_near = TRUE)
		if(!pick)
			return
		A = pick
	else
		A = accessories[1]
	remove_accessory(user, A)

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
	if(length(accessories))
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()

/obj/item/clothing/obj_destruction(damage_flag)
	if(damage_flag == BOMB || damage_flag == MELEE)
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else
		..()

/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = UPPER_TORSO
	slot_flags = ITEM_SLOT_NECK

/obj/item/clothing/clean_blood(radiation_clean = FALSE)
	. = ..()
	gunshot_residue = null
