/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/dualsaber
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	hitsound = "swing_hit"
	icon_state = "dualsaber0"
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	armor_penetration_flat = 10
	armor_penetration_percentage = 50
	origin_tech = "magnets=4;syndicate=5"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	light_power = 2
	needs_permit = TRUE
	var/hacked = FALSE
	var/blade_color
	var/brightness_on = 2
	var/colormap = list(
		red = LIGHT_COLOR_RED,
		blue = LIGHT_COLOR_LIGHTBLUE,
		green = LIGHT_COLOR_GREEN,
		purple = LIGHT_COLOR_PURPLE,
		rainbow = LIGHT_COLOR_WHITE,
	)
	var/force_unwielded = 3
	var/force_wielded = 34
	var/wieldsound = 'sound/weapons/saberon.ogg'
	var/unwieldsound = 'sound/weapons/saberoff.ogg'
	new_attack_chain = TRUE

/obj/item/dualsaber/Initialize(mapload)
	. = ..()
	if(!blade_color)
		blade_color = pick("red", "blue", "green", "purple")
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.25, \
		_parryable_attack_types = ALL_ATTACK_TYPES, \
		_parry_cooldown = (4 / 3) SECONDS, /* 0.33 seconds of parry cooldown for 75% uptime. */ \
		_requires_two_hands = TRUE)
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		force_unwielded = force_unwielded, \
		wieldsound = wieldsound, \
		unwieldsound = unwieldsound, \
		attacksound = 'sound/weapons/blade1.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
		only_sharp_when_wielded = TRUE)

/obj/item/dualsaber/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "dualsaber[blade_color]1"
		set_light(brightness_on, l_color=colormap[blade_color])
	else
		icon_state = "dualsaber0"
		set_light(0)

/obj/item/dualsaber/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(cigarette_lighter_act(user, target))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/dualsaber/pre_attack(atom/target, mob/living/user, params)
	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, SPAN_WARNING("You grip the blade too hard and accidentally drop it!"))
		if(HAS_TRAIT(src, TRAIT_WIELDED))
			user.drop_item_to_ground(src)
			return FINISH_ATTACK
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && HAS_TRAIT(src, TRAIT_WIELDED) && prob(40) && force)
		to_chat(user, SPAN_WARNING("You twirl around a bit before losing your balance and impaling yourself on [src]!"))
		user.take_organ_damage(20, 25)
		return FINISH_ATTACK

	if((HAS_TRAIT(src, TRAIT_WIELDED)) && prob(50))
		INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)
		return ..()

/obj/item/dualsaber/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, SPAN_WARNING("You need to activate [src] before you can light anything with it!"))
		return TRUE

	if(target == user)
		user.visible_message(
			SPAN_DANGER("[user] flips through the air and spins [src] wildly! It brushes against [user.p_their()] [cig] and sets it alight!"),
			SPAN_NOTICE("You flip through the air and twist [src] so it brushes against [cig], lighting it with the blade."),
			SPAN_DANGER("You hear an energy blade slashing something!")
		)
	else
		user.visible_message(
			SPAN_DANGER("[user] flips through the air and slashes at [user] with [src]! The blade barely misses, brushing against [user.p_their()] [cig] and setting it alight!"),
			SPAN_NOTICE("You flip through the air and slash [src] at [cig], lighting it for [target]."),
			SPAN_DANGER("You hear an energy blade slashing something!")
		)
	user.do_attack_animation(target)
	playsound(user.loc, hitsound, 50, TRUE)
	cig.light(user, target)
	INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)
	return TRUE

/obj/item/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.SpinAnimation(7, 1)
		sleep(1)

/obj/item/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return FALSE
	. = ..()
	if(!.) // They did not block the attack.
		return

	if(attack_type == THROWN_PROJECTILE_ATTACK)
		if(!isitem(hitby))
			return TRUE
		var/obj/item/TT = hitby
		//Timer set to 0.2 seconds to ensure item finshes the throwing to prevent double embeds
		addtimer(CALLBACK(TT, TYPE_PROC_REF(/atom/movable, throw_at), locateUID(TT.thrownby), 10, 4, owner), 0.2 SECONDS)
		return TRUE
	if(isitem(hitby))
		melee_attack_chain(owner, hitby.loc)
	else
		melee_attack_chain(owner, hitby)
	return TRUE

// In case it just so happens that it is still activated on the ground, prevents hulk from picking it up.
/obj/item/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, SPAN_WARNING("You can't pick up such a dangerous item with your meaty hands without losing fingers, better not to!"))
		return TRUE

/obj/item/dualsaber/green
	blade_color = "green"

/obj/item/dualsaber/red
	blade_color = "red"

/obj/item/dualsaber/purple
	blade_color = "purple"

/obj/item/dualsaber/blue
	blade_color = "blue"

/obj/item/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	if(user && HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, SPAN_WARNING("You lack the grace to wield this!"))
		return COMPONENT_TWOHANDED_BLOCK_WIELD
	w_class = w_class_on

/obj/item/dualsaber/proc/on_unwield()
	w_class = initial(w_class)

/obj/item/dualsaber/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return TRUE

/obj/item/dualsaber/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!hacked)
		hacked = TRUE
		to_chat(user, SPAN_WARNING("2XRNBW_ENGAGE"))
		blade_color = "rainbow"
		update_icon()
	else
		to_chat(user, SPAN_WARNING("It's starting to look like a triple rainbow - no, nevermind."))

// PYRO CLAWS
/obj/item/pyro_claws
	name = "hardplasma energy claws"
	desc = "The power of the sun, in the claws of your hand."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "pyro_claws"
	flags = ABSTRACT | NODROP | DROPDEL
	force = 22
	damtype = BURN
	armor_penetration_percentage = 50
	sharp = TRUE
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list(
		"Vox" = 'icons/mob/clothing/species/vox/held.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/held.dmi'
	)
	toolspeed = 0.5
	var/lifetime = 60 SECONDS
	var/next_spark_time
	new_attack_chain = TRUE

/obj/item/pyro_claws/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/forces_doors_open)
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.5, \
		_parryable_attack_types = ALL_ATTACK_TYPES)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/pyro_claws/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/pyro_claws/customised_abstract_text(mob/living/carbon/owner)
	return SPAN_WARNING("[owner.p_they(TRUE)] [owner.p_have(FALSE)] energy claws extending [owner.p_their(FALSE)] wrists.")

/obj/item/pyro_claws/process()
	lifetime -= 2 SECONDS
	if(lifetime <= 0)
		visible_message(SPAN_WARNING("[src] slides back into the depths of [loc]'s wrists."))
		do_sparks(rand(1, 6), 1, loc)
		qdel(src)
		return
	if(prob(15))
		do_sparks(rand(1, 6), 1, loc)

/obj/item/pyro_claws/door_force_try_message(obj/machinery/door/door, mob/user)
	user.visible_message(
		SPAN_WARNING("[user] jams [user.p_their()] [name] into the airlock and starts prying it open!"),
		SPAN_WARNING("You start forcing the airlock open."),
		SPAN_HEAR("You hear a metal screeching sound.")
	)

/obj/item/pyro_claws/door_force_success_message(obj/machinery/door/door, mob/user)
	user.visible_message(
		SPAN_WARNING("[user] forces the airlock open with [user.p_their()] [name]!"),
		SPAN_WARNING("You force open the airlock."),
		SPAN_HEAR("You hear a metal screeching come to a halt.")
	)

/obj/item/pyro_claws/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(prob(60) && world.time > next_spark_time)
		do_sparks(rand(1, 6), 1, loc)
		next_spark_time = world.time + 0.8 SECONDS
	return NONE

/obj/item/clothing/gloves/color/black/pyro_claws
	name = "Fusion gauntlets"
	desc = "A pair of heavy combat gauntlets that project lethal energy claws via the power of a captive pyroclastic anomaly core."
	icon_state = "pyro"
	inhand_icon_state = null
	worn_icon_state = null
	can_be_cut = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	dyeable = FALSE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 4000, MAT_TITANIUM = 4000, MAT_PLASMA = 8000)
	var/on_cooldown = FALSE
	var/obj/item/assembly/signaler/anomaly/pyro/core
	var/next_spark_time

/obj/item/clothing/gloves/color/black/pyro_claws/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/gloves/color/black/pyro_claws/examine(mob/user)
	. = ..()
	if(core)
		. += SPAN_NOTICE("[src] are fully operational!")
	else
		. += SPAN_WARNING("It is missing a pyroclastic anomaly core.")

/obj/item/clothing/gloves/color/black/pyro_claws/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_GLOVES)
		return TRUE

/obj/item/clothing/gloves/color/black/pyro_claws/ui_action_click(mob/user)
	if(!core)
		to_chat(user, SPAN_NOTICE("[src] has no core to power it!"))
		return
	if(on_cooldown)
		to_chat(user, SPAN_NOTICE("[src] is on cooldown!"))
		return
	if((user.l_hand && !user.drop_l_hand()) || (user.r_hand && !user.drop_r_hand()))
		to_chat(user, SPAN_NOTICE("[src] are unable to deploy the blades with the items in your hands!"))
		return
	var/obj/item/W = new /obj/item/pyro_claws
	user.visible_message(
		SPAN_WARNING("[user] deploys [W] from [user.p_their()] wrists in a shower of sparks!"),
		SPAN_NOTICE("You deploy [W] from your wrists!"),
		SPAN_HEAR("You hear the shower of sparks!")
	)
	user.put_in_hands(W)
	on_cooldown = TRUE
	set_nodrop(TRUE, user)
	addtimer(CALLBACK(src, PROC_REF(reboot)), 2 MINUTES)
	if(world.time > next_spark_time)
		do_sparks(rand(1,6), 1, loc)
		next_spark_time = world.time + 0.8 SECONDS

/obj/item/clothing/gloves/color/black/pyro_claws/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/item/clothing/gloves/color/black/pyro_claws/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/assembly/signaler/anomaly/pyro))
		return ..()

	if(core)
		to_chat(user, SPAN_NOTICE("[src] already has a [used]!"))
		return ITEM_INTERACT_COMPLETE

	if(!user.drop_item())
		to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You insert [used] into [src], and [src] starts to warm up."))
	used.forceMove(src)
	core = used
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/gloves/color/black/pyro_claws/proc/reboot()
	on_cooldown = FALSE
	set_nodrop(FALSE, loc)
	atom_say("Internal plasma canisters recharged. Gloves sufficiently cooled")
