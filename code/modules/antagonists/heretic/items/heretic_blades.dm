
/obj/item/melee/sickly_blade
	name = "\improper sickly blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "eldritch_blade"
	inhand_icon_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BELT
	sharp = TRUE
	force = 20
	throwforce = 10
	toolspeed = 0.375
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor_penetration_percentage = 35
	attack_verb = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	new_attack_chain = TRUE
	var/after_use_message = ""

/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(!check_usability(user))
		return

	. += SPAN_NOTICE("You can shatter the blade to teleport to a random, (mostly) safe location by <b>activating it in-hand</b>.")

/// Checks if the passed mob can use this blade without being stunned
/obj/item/melee/sickly_blade/proc/check_usability(mob/living/user)
	return IS_HERETIC_OR_MONSTER(user)

/obj/item/melee/sickly_blade/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK
	if(!check_usability(user))
		to_chat(user, SPAN_DANGER("You feel a pulse of alien intellect lash out at your mind!"))
		var/mob/living/carbon/human/human_user = user
		human_user.Weaken(5 SECONDS)
		return FINISH_ATTACK

/obj/item/melee/sickly_blade/activate_self(mob/user)
	if(..())
		return
	seek_safety(user)

/// Attempts to teleport the passed mob to somewhere safe on the station, if they can use the blade.
/obj/item/melee/sickly_blade/proc/seek_safety(mob/user)
	to_chat(user, SPAN_WARNING("You begin to break the blade..."))
	if(!do_after(user, 1 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE))
		to_chat(user, SPAN_WARNING("You fail to break the blade!"))
		return
	var/turf/safe_turf = find_safe_turf(blacklist_areas = GLOB.blacklisted_heretic_areas)
	var/turf/blade_turf = get_turf(user)
	var/area/our_area = get_area(blade_turf)
	if(isnull(safe_turf) || !is_teleport_allowed(blade_turf.z) || our_area.tele_proof)
		to_chat(user, SPAN_WARNING("You shatter [src], but your plea goes unanswered."))
		playsound(src, "shatter", 70, TRUE)
		qdel(src)
		return
	if(check_usability(user) && isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(/datum/status_effect/broken_blade, icon_state)
		if(do_teleport(living_user, safe_turf))
			to_chat(living_user, SPAN_WARNING("As you shatter [src], you feel a gust of energy flow through your body. [after_use_message]"))
		else
			to_chat(living_user, SPAN_WARNING("You shatter [src], but your plea goes unanswered."))
	else
		to_chat(user,SPAN_WARNING("You shatter [src]."))
	playsound(src, "shatter", 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)

/obj/item/melee/sickly_blade/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target, src)

/obj/item/melee/sickly_blade/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, interacting_with, src)
	return ITEM_INTERACT_COMPLETE

// Path of Rust's blade
/obj/item/melee/sickly_blade/rust
	name = "\improper rusted blade"
	desc = "This crescent blade is decrepit, wasting to rust. \
		Yet still it bites, ripping flesh and bone with jagged, rotten teeth."
	icon_state = "rust_blade"
	inhand_icon_state = "rust_blade"
	after_use_message = "The Rusted Hills hear your call..."

// Path of Ash's blade
/obj/item/melee/sickly_blade/ash
	name = "\improper ashen blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. \
		Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	inhand_icon_state = "ash_blade"
	after_use_message = "The Nightwatcher hears your call..."
	resistance_flags = FIRE_PROOF

// Path of Flesh's blade
/obj/item/melee/sickly_blade/flesh
	name = "\improper bloody blade"
	desc = "A crescent blade born from a fleshwarped creature. \
		Keenly aware, it seeks to spread to others the suffering it has endured from its dreadful origins."
	icon_state = "flesh_blade"
	inhand_icon_state = "flesh_blade"
	after_use_message = "The Marshal hears your call..."

// Path of Void's blade
/obj/item/melee/sickly_blade/void
	name = "\improper void blade"
	desc = "Devoid of any substance, this blade reflects nothingness. \
		It is a real depiction of purity, and chaos that ensues after its implementation."
	icon_state = "void_blade"
	inhand_icon_state = "void_blade"
	after_use_message = "The Aristocrat hears your call..."
	var/chilling = FALSE
	var/cooling_power = 40000

/obj/item/melee/sickly_blade/void/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/item/melee/sickly_blade/void/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/melee/sickly_blade/void/examine(mob/user)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!heretic_datum)
		return
	. += "<span class='info'>We may touch the blade to ourself to call forth an aspect of winter's end."

/obj/item/melee/sickly_blade/void/dropped(mob/user, silent)
	. = ..()
	chilling = FALSE

/obj/item/melee/sickly_blade/void/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return

	if(user == target)
		if(chilling)
			to_chat(user, SPAN_WARNING("We are already calling forth the patient end."))
			return FINISH_ATTACK
		else
			chilling = TRUE
			to_chat(user, SPAN_WARNING("We begin to bring forth a fragment of winter."))
			while(chilling)
				if(!do_after_once(user, 10 SECONDS, TRUE, src, TRUE, FALSE, TRUE, SPAN_WARNING("We finish channeling winter.")))
					chilling = FALSE
		return FINISH_ATTACK

/obj/item/melee/sickly_blade/void/process()
	if(!chilling)
		return
	var/datum/milla_safe/void_blade/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/void_blade

/datum/milla_safe/void_blade/on_run(obj/item/melee/sickly_blade/void/blade)
	var/turf/T = get_turf(blade)
	var/datum/gas_mixture/env = get_turf_air(T)
	var/initial_temperature = env.temperature()
	var/target_temp = 100

	if(!issimulatedturf(T) || T.density)
		return
	if(initial_temperature <= target_temp) //Can we actually cool this?
		return

	var/amount_cooled = initial_temperature - blade.cooling_power / env.heat_capacity()
	env.set_temperature(max(amount_cooled, target_temp))

// Path of the Blade's... blade.
// Opting for /dark instead of /blade to avoid "sickly_blade/blade".
/obj/item/melee/sickly_blade/dark
	name = "\improper sundered blade"
	desc = "A galliant blade, sundered and torn. \
		Furiously, the blade cuts. Silver scars bind it forever to its dark purpose."
	icon_state = "dark_blade"
	base_icon_state = "dark_blade"
	inhand_icon_state = "dark_blade"
	after_use_message = "The Torn Champion hears your call..."
	///If our blade is currently infused with the mansus grasp
	var/infused = FALSE

/obj/item/melee/sickly_blade/dark/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!infused || target == user || !isliving(target))
		return
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/mob/living/living_target = target
	if(!heretic_datum)
		return

	//Apply our heretic mark
	var/datum/heretic_knowledge/mark/blade_mark/mark_to_apply = heretic_datum.get_knowledge(/datum/heretic_knowledge/mark/blade_mark)
	if(!mark_to_apply)
		return
	mark_to_apply.create_mark(user, living_target)

	//Remove the infusion from any blades we own (and update their sprite)
	for(var/obj/item/melee/sickly_blade/dark/to_infuse in user.get_contents())
		to_infuse.infused = FALSE
		to_infuse.update_appearance(UPDATE_ICON)
	user.update_inv_l_hand()
	user.update_inv_r_hand()

	if(!check_behind(user, living_target))
		return
	// We're officially behind them, apply effects
	living_target.Weaken(1.5 SECONDS)
	living_target.apply_damage(10, BRUTE)
	playsound(living_target, 'sound/weapons/guillotine.ogg', 100, TRUE)

/obj/item/melee/sickly_blade/dark/dropped(mob/user, silent)
	. = ..()
	if(infused)
		infused = FALSE
		update_appearance(UPDATE_ICON)

/obj/item/melee/sickly_blade/dark/update_icon_state()
	. = ..()
	if(infused)
		icon_state = base_icon_state + "_infused"
		inhand_icon_state = base_icon_state + "_infused"
	else
		icon_state = base_icon_state
		inhand_icon_state = base_icon_state

// Path of Cosmos's blade
/obj/item/melee/sickly_blade/cosmic
	name = "\improper cosmic blade"
	desc = "A mote of celestial resonance, shaped into a star-woven blade. \
		An iridescent exile, carving radiant trails, desperately seeking unification."
	icon_state = "cosmic_blade"
	inhand_icon_state = "cosmic_blade"
	after_use_message = "The Stargazer hears your call..."

// Path of Knock's blade
/obj/item/melee/sickly_blade/lock
	name = "\improper key blade"
	desc = "A blade and a key, a key to what? \
		What grand gates does it open?"
	icon_state = "key_blade"
	inhand_icon_state = "key_blade"
	after_use_message = "The Stewards hear your call..."
	tool_behaviour = TOOL_CROWBAR
	usesound = 'sound/items/crowbar.ogg' //Maybe something else?
	toolspeed = 0.5

// Path of Moon's blade
/obj/item/melee/sickly_blade/moon
	name = "\improper moon blade"
	desc = "A blade of iron, reflecting the truth of the earth: All join the troupe one day. \
		A troupe bringing joy, carving smiles on their faces if they want one or not."
	icon_state = "moon_blade"
	inhand_icon_state = "moon_blade"
	after_use_message = "The Moon hears your call..."

// Path of Nar'Sie's blade
// What!? This blade is given to cultists as an altar item when they sacrifice a heretic.
// It is also given to the heretic themself if they sacrifice a cultist.
/obj/item/melee/sickly_blade/cursed
	name = "\improper cursed blade"
	desc = "A dark blade, cursed to bleed forever. In constant struggle between the eldritch and the dark, it is forced to accept any wielder as its master. \
		Its eye's cornea drips blood endlessly into the ground, yet its piercing gaze remains on you. Cultists can scribe runes faster with it."
	force = 25
	throwforce = 15
	icon_state = "cursed_blade"
	inhand_icon_state = "cursed_blade"
	toolspeed = 0.5

/obj/item/melee/sickly_blade/cursed/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/melee/sickly_blade/cursed/check_usability(mob/living/user)
	if(!isliving(user))
		return FALSE
	if(IS_HERETIC_OR_MONSTER(user) || IS_CULTIST(user))
		return TRUE
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_mob = user
	if(prob(15))
		to_chat(human_mob, SPAN_CULTLARGE("[pick("\"An untouched mind? Amusing.\"", "\" I suppose it isn't worth the effort to stop you.\"", "\"Go ahead. I don't care.\"", "\"You'll be mine soon enough.\"")]"))
		human_mob.apply_damage(5, BURN, user.get_active_hand())
		playsound(src, 'sound/weapons/sear.ogg', 25, TRUE)
		to_chat(human_mob, SPAN_DANGER("Your hand sizzles.")) // Nar nar might not care but their essence still doesn't like you
	else if(prob(15))
		to_chat(human_mob, SPAN_HIEROPHANT("LW'NAFH'NAHOR UH'ENAH'YMG EPGOKA AH NAFL MGEMPGAH'EHYE"))
		to_chat(human_mob, SPAN_DANGER("Horrible, unintelligible utterances flood your mind!"))
		human_mob.apply_status_effect(/datum/status_effect/stacking/heretic_insanity, 2)
	return TRUE

/obj/item/melee/sickly_blade/cursed/equipped(mob/user, slot)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		after_use_message = "The Mansus hears your call..."
	else if(IS_CULTIST(user))
		after_use_message = "Nar'Sie hears your call..."
	else
		after_use_message = null

/obj/item/melee/sickly_blade/cursed/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!heretic_datum)
		return NONE

	// Can only carve runes with it if off combat mode.
	if(isfloorturf(target) && user.a_intent == INTENT_HELP)
		heretic_datum.try_draw_rune(user, target, drawing_time = 8 SECONDS)
		return ITEM_INTERACT_COMPLETE
	return NONE

/obj/item/melee/sickly_blade/cursed/AltClick(mob/user)
	. = ..()
	if(IS_CULTIST(user))
		scribe_rune(user)
