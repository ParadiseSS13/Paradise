/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	inhand_icon_state = "flashlight"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 200, MAT_GLASS = 100)
	actions_types = list(/datum/action/item_action/toggle_light)
	light_color = "#ffffd0"
	var/on = FALSE
	/// Luminosity when turned on.
	var/brightness_on = 4
	var/togglesound = 'sound/weapons/empty.ogg'
	new_attack_chain = TRUE

/obj/item/flashlight/Initialize(mapload)
	. = ..()
	update_brightness()

/obj/item/flashlight/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/flashlight/proc/update_brightness()
	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_icon()

/obj/item/flashlight/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	if(!isturf(user.loc))
		to_chat(user, "You cannot toggle [src] while obscured by [user.loc].") // To prevent some lighting anomalities.
		return ITEM_INTERACT_COMPLETE
	on = !on
	playsound(user, togglesound, 100, 1)
	update_brightness()
	update_action_buttons()
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/flashlight/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	add_fingerprint(user)
	if(istype(target, /obj/structure/ai_core/deactivated))
		to_chat(user, SPAN_NOTICE("You can already tell there's no AI in this core, but you shine [src] at it anyway. It doesn't respond."))
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	if(!ismob(target))
		return ..()

	if(!(on && user.zone_selected == "eyes"))
		return ..()

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50)) // Too dumb to use flashlight properly.
		return ..() // Just hit them in the head.

	if(!(ishuman(user) || SSticker) && SSticker.mode.name != "monkey") // Don't have necessary dexterity.
		to_chat(user, SPAN_NOTICE("You don't have the dexterity to do this!"))
		return ITEM_INTERACT_COMPLETE

	var/mob/living/carbon/human/human_target = target
	if(istype(human_target) && \
		((human_target.head && human_target.head.flags_cover & HEADCOVERSEYES) || \
		(human_target.wear_mask && human_target.wear_mask.flags_cover & MASKCOVERSEYES) || \
		(human_target.glasses && human_target.glasses.flags_cover & GLASSESCOVERSEYES)))
		// Mob has protective eyewear.
		var/blocking_target = "glasses"
		if(human_target.wear_mask && human_target.wear_mask.flags_cover & MASKCOVERSEYES)
			blocking_target = "mask"
		if(human_target.head && human_target.head.flags_cover & HEADCOVERSEYES)
			blocking_target = "helmet"
		to_chat(user, SPAN_NOTICE("You're going to need to remove the [blocking_target] first."))
		return ITEM_INTERACT_COMPLETE

	if(target == user) // They're using it on themselves.
		if(human_target.flash_eyes(visual = TRUE))
			target.visible_message(SPAN_NOTICE("[target] directs [src] to [target.p_their()] eyes."),
								SPAN_NOTICE("You wave the light in front of your eyes! Trippy!"))
		else
			target.visible_message(SPAN_NOTICE("[target] directs [src] to [target.p_their()] eyes."),
								SPAN_NOTICE("You wave the light in front of your eyes."))
			add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	user.visible_message(SPAN_NOTICE("[user] directs [src] to [target]'s eyes."),
						SPAN_NOTICE("You direct [src] to [target]'s eyes."))

	if(issilicon(target))
		var/mob/living/silicon/robot/silicon_target = target
		var/datum/robot_component/camera/camera
		add_fingerprint(user)
		if(isrobot(target))
			camera = silicon_target.get_component("camera")
			if(!camera)
				to_chat(user, SPAN_WARNING("[target]'s camera is missing!"))
				return ITEM_INTERACT_COMPLETE
		if(silicon_target.stat == DEAD || (camera && camera.component_disabled))
			to_chat(user, SPAN_WARNING("[target]'s camera doesn't respond to the light!"))
			return ITEM_INTERACT_COMPLETE
		to_chat(user, SPAN_NOTICE("[target]'s camera aperture makes a series of clicks as it adjusts to the light."))
		return ITEM_INTERACT_COMPLETE

	if(!istype(human_target)) // Aliens are unaffected.
		return ITEM_INTERACT_COMPLETE

	if(!human_target.bodyparts_by_name["head"])
		to_chat(user, SPAN_WARNING("You can't find [target]'s [ismachineperson(target) ? "camera" : "eyes"] because they have no head!"))
		return ITEM_INTERACT_COMPLETE

	add_fingerprint(user)
	var/obj/item/organ/internal/eyes/eyes = human_target.get_int_organ(/obj/item/organ/internal/eyes)
	if(!eyes)
		to_chat(user, SPAN_WARNING("[target] has no [ismachineperson(target) ? "camera" : "eyes"]!"))
		return ITEM_INTERACT_COMPLETE

	if(human_target.stat == DEAD || HAS_TRAIT(human_target, TRAIT_BLIND)) // Target is dead or fully blind.
		to_chat(user, SPAN_NOTICE("[target]'s [ismachineperson(target) ? "camera doesn't" : "pupils don't"] respond to the light!"))
		return ITEM_INTERACT_COMPLETE

	if(HAS_TRAIT(target, TRAIT_XRAY_VISION) || eyes.see_in_dark >= 3)
		// Target has X-RAY vision or has a tapetum lucidum.
		// (extreme nightvision, i.e. Vulp/Tajara with COLOURBLIND & their monkey forms)
		if(ismachineperson(target))
			to_chat(user, SPAN_NOTICE("[target]'s camera lens reflects the light eerily!"))
		else
			to_chat(user, SPAN_NOTICE("[target]'s pupils glow eerily!"))
		return ITEM_INTERACT_COMPLETE

	if(human_target.flash_eyes(visual = TRUE))
		to_chat(user, SPAN_NOTICE("[target]'s [ismachineperson(target) ? "camera aperture narrows" : "pupils narrow"]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/flashlight/extinguish_light(force = FALSE)
	if(on)
		on = FALSE
		update_brightness()

/obj/item/flashlight/pen
	name = "penlight"
	desc = "A pen, and a light. Used by medical staff."
	icon_state = "penlight"
	worn_icon_state = "pen"
	inhand_icon_state = "pen"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BOTH_EARS
	brightness_on = 2
	var/colour = "blue" // Ink color

/obj/item/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	inhand_icon_state = "seclite"
	force = 9 // Not as good as a stun baton.
	brightness_on = 5 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'

/obj/item/flashlight/drone
	name = "low-power flashlight"
	desc = "A miniature lamp, that might be used by small robots."
	icon_state = "penlight"
	brightness_on = 2
	w_class = WEIGHT_CLASS_TINY

// the desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	inhand_icon_state = "lamp"
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	materials = list()
	on = TRUE
	light_color = "#fff4bb"

/obj/item/flashlight/lamp/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("You can <b>Alt-Click</b> [src] to turn it on/off.")

// green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	inhand_icon_state = "lampgreen"
	light_color = "#AAFFAA"

/obj/item/flashlight/lamp/green/off
	on = FALSE

/obj/item/flashlight/lamp/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	activate_self(user)

//Bananalamp
/obj/item/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = "Only a clown would think to make a ghetto banana-shaped lamp. Even has a goofy pullstring."
	icon_state = "bananalamp"
	inhand_icon_state = "lampgreen"
	light_color = "#f7ff57"

// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	brightness_on = 8
	light_color = "#ff0000"
	icon_state = "flare"
	inhand_icon_state = "flare"
	togglesound = 'sound/goonstation/misc/matchstick_light.ogg'
	/// This var will get checked in Initialize() and if it's true, it'll get set to a randomized fuel value.
	/// If it's 0, it'll simply remain a used up flare.
	var/fuel = TRUE
	var/on_damage = 7
	var/produce_heat = 1500
	var/fuel_lower = 800
	var/fuel_upp = 1000

/obj/item/flashlight/flare/Initialize(mapload)
	. = ..()
	if(fuel)
		fuel = rand(fuel_lower, fuel_upp)
	update_icon()

/obj/item/flashlight/flare/update_icon_state()
	inhand_icon_state = "[initial(inhand_icon_state)][on ? "-on" : ""]"
	if(!fuel)
		icon_state = "[initial(icon_state)]-empty"
		return
	..()

/obj/item/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos && produce_heat)
		pos.hotspot_expose(produce_heat, 1)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/flare/proc/turn_off()
	on = FALSE
	force = initial(force)
	damtype = initial(damtype)
	hitsound = "swing_hit"
	attack_verb = list()
	update_brightness()

/obj/item/flashlight/flare/activate_self(mob/user)
	// Usual checks
	if(!fuel)
		to_chat(user, SPAN_WARNING("[src] is already burnt out!"))
		return ITEM_INTERACT_COMPLETE
	if(on)
		to_chat(user, SPAN_WARNING("[src] is already lit!"))
		return ITEM_INTERACT_COMPLETE

	// All good, turn it on.
	if(..())
		user.visible_message(SPAN_NOTICE("[user] activates [src]."), SPAN_NOTICE("You activate [src]."))
		if(produce_heat)
			force = on_damage
			damtype = "fire"
			hitsound = 'sound/items/welder.ogg'
			attack_verb = list("burnt", "singed")
		START_PROCESSING(SSobj, src)
		return ITEM_INTERACT_COMPLETE

/obj/item/flashlight/flare/used
	fuel = 0

/obj/item/flashlight/flare/glowstick/used
	fuel = 0

/obj/item/flashlight/flare/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user) && !fuel)
		C.stored_comms["metal"] += 1
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/flashlight/flare/get_heat()
	return produce_heat * on * 1000

// GLOWSTICKS

/obj/item/flashlight/flare/glowstick
	name = "green glowstick"
	desc = "A military-grade glowstick."
	brightness_on = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	inhand_icon_state = null
	togglesound = 'sound/effects/bone_break_1.ogg'
	produce_heat = FALSE
	fuel_lower = 1600
	fuel_upp = 2000
	blocks_emissive = FALSE

/obj/item/flashlight/flare/glowstick/Initialize(mapload)
	. = ..()
	light_color = color

/obj/item/flashlight/flare/glowstick/update_icon_state()
	if(!fuel)
		icon_state = "glowstick-empty"

/obj/item/flashlight/flare/glowstick/update_overlays()
	. = ..()
	if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		. += glowstick_overlay

/obj/item/flashlight/flare/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED

/obj/item/flashlight/flare/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE

/obj/item/flashlight/flare/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE

/obj/item/flashlight/flare/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW

/obj/item/flashlight/flare/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK

/obj/item/flashlight/flare/glowstick/emergency
	name = "emergency glowstick"
	desc = "A cheap looking, mass produced glowstick. You can practically feel it was made on a tight budget."
	color = LIGHT_COLOR_BLUE
	fuel_lower = 30
	fuel_upp = 90

/obj/item/flashlight/flare/extinguish_light(force = FALSE)
	if(force)
		fuel = 0
		visible_message(SPAN_DANGER("[src] burns up rapidly!"))
	else
		visible_message(SPAN_DANGER("[src] dims slightly before scattering the shadows around it."))

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	icon_state = "torch"
	inhand_icon_state = "torch"
	w_class = WEIGHT_CLASS_BULKY
	brightness_on = 7
	light_color = LIGHT_COLOR_ORANGE
	on_damage = 10

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "A glowing ball of what appears to be amber."
	icon_state = "slime-on"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_TINY
	brightness_on = 6
	light_color = "#FFBF00"
	materials = list()
	on = TRUE //Bio-luminesence has one setting, on.

/obj/item/flashlight/slime/Initialize(mapload)
	. = ..()
	set_light(brightness_on)
	spawn(1) //Might be sloppy, but seems to be necessary to prevent further runtimes and make these work as intended... don't judge me!
		update_brightness()
		icon_state = initial(icon_state)

/obj/item/flashlight/slime/activate_self(mob/user)
	if(!user)
		return ..()
	return //Bio-luminescence does not toggle.

/obj/item/flashlight/slime/extinguish_light(force = FALSE)
	if(force)
		visible_message(SPAN_DANGER("[src] withers away."))
		qdel(src)
	else
		visible_message(SPAN_DANGER("[src] dims slightly before scattering the shadows around it."))

/obj/item/flashlight/emp
	origin_tech = "magnets=3;syndicate=1"

	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0

/obj/item/flashlight/emp/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/flashlight/emp/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(on && user.zone_selected == "eyes") // call original attack proc only if aiming at the eyes
		return ..()

/obj/item/flashlight/emp/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK
	if(emp_cur_charges <= 0)
		to_chat(user, SPAN_WARNING("\The [src] needs time to recharge!"))
		return FINISH_ATTACK

/obj/item/flashlight/emp/attack(mob/living/target, mob/living/carbon/human/user)
	if(..())
		return FINISH_ATTACK
	emp_cur_charges -= 1
	target.visible_message(
		SPAN_DANGER("[user] blinks [src] at [target]!"),
		SPAN_USERDANGER("[user] blinks [src] at you!")
	)
	if(ismob(target))
		add_attack_logs(user, target, "Hit with EMP-light")
	to_chat(user, SPAN_NOTICE("[src] now has [emp_cur_charges] charge\s."))
	target.emp_act(EMP_HEAVY)

/// invisible lighting source
/obj/item/flashlight/spotlight
	name = "disco light"
	desc = "Groovy..."
	icon_state = null
	light_color = null
	brightness_on = 0
	light_power = 10
	alpha = 0
	layer = 0
	on = TRUE
	anchored = TRUE
	var/range = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/flashlight/eyelight
	name = "eyelight"
	desc = "This shouldn't exist outside of someone's head, how are you seeing this?"
	light_range = 15
	flags = CONDUCT | DROPDEL
	actions_types = list()
