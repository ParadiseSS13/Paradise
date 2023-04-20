/**
 * # Energy Katana
 *
 * The space ninja's katana.
 *
 * The katana that only space ninja spawns with.  Comes with 40 force and throwforce, along with a signature special jaunting system.
 * Upon clicking on a tile when clicking with disarm intent, the user will teleport to that tile, assuming their target was not dense.
 * The katana has 3 dashes stored at maximum, and upon using the dash, it will return 20 seconds after it was used.
 * It also has a special feature where if it is tossed at a space ninja who owns it (determined by the ninja suit), the ninja will catch the katana instead of being hit by it.
 *
 */
/obj/item/melee/energy_katana
	name = "energy katana"
	desc = "A katana infused with strong energy."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "energy_katana_green"
	item_state = "energy_katana_green"
	var/color_style = "green"
	force = 40
	throwforce = 20
	block_chance = 50
	armour_penetration = 50
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	slot_flags = SLOT_BACK | SLOT_BELT
	sharp = TRUE
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/datum/action/innate/dash/ninja/jaunt

/obj/item/melee/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(jaunt)
	return ..()

/obj/item/melee/energy_katana/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/energy_katana/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(user && user.a_intent == INTENT_DISARM && !target.density)
		jaunt.teleport(user, target)
		if(user.client)
			user.client.mouse_pointer_icon = file(jaunt.update_cursor())
		jaunt.update_action_style(color_style)

/obj/item/melee/energy_katana/pickup(mob/living/user)
	. = ..()
	if(user && user.client)
		jaunt.Grant(user, src)
		user.client.mouse_pointer_icon = file(jaunt.update_cursor())
		jaunt.update_action_style(color_style)
		user.update_icons()
		playsound(get_turf(src), 'sound/items/unsheath.ogg', 25, TRUE, 5)

/obj/item/melee/energy_katana/dropped(mob/user)
	. = ..()
	if(user && user.client)
		jaunt.Remove(user)
		user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
		user.update_icons()

//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself(nope) or someone tries
//To throw it at the ninja
/obj/item/melee/energy_katana/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/hit_human = hit_atom
		if(istype(hit_human.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/ninja_suit = hit_human.wear_suit
			if(ninja_suit.energyKatana && ninja_suit.energyKatana == src)
				returnToOwner(hit_human, 0, 1)
				return
	..()

/obj/item/melee/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(jaunt)
	return ..()

/**
 * Proc called when the katana is recalled to its space ninja.
 *
 * Proc called when space ninja is hit with its suit's katana or the recall ability is used.
 * Arguments:
 * * user - To whom the katana is returning to.
 * * doSpark - whether or not the katana will spark when it returns.
 * * caught - boolean for whether or not the katana was caught or was teleported back.
 */
/obj/item/melee/energy_katana/proc/returnToOwner(mob/living/carbon/human/user, doSpark = TRUE, caught = FALSE)
	if(!istype(user))
		return
	forceMove(get_turf(user))

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, TRUE, 5)

	var/msg = ""

	if(user.put_in_active_hand(src))
		msg = "Your Energy Katana teleports into your hand!"
	else if(user.equip_to_slot_if_possible(src, slot_belt, 0, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else if(user.equip_to_slot_if_possible(src, slot_back, 0, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself at your back as it does so!</span>"
	else
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		to_chat(user, span_notice("[msg]"))

/obj/item/melee/energy_katana/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] пронза[pluralize_ru(user.gender,"ет","ют")] свой живот с помощью [src]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ется","ются")] совершить сеппуку!"))
	return BRUTELOSS

/datum/action/innate/dash/ninja
	name = "Energy Dash"
	desc = "Teleport to the targeted location. Just use your katana in a disarming manner"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "arrows_3"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	current_charges = 3
	max_charges = 3
	charge_rate = 200
	recharge_sound = 'sound/weapons/knife_on_knife.ogg'
	beam_effect = "ninja_blink"

/datum/action/innate/dash/ninja/proc/update_cursor()
	switch(current_charges)
		if(3)
			return "icons/misc/mouse_pointers/ninja_cursor_three.dmi"
		if(2)
			return "icons/misc/mouse_pointers/ninja_cursor_two.dmi"
		if(1)
			return "icons/misc/mouse_pointers/ninja_cursor_one.dmi"
		if(0)
			return "icons/misc/mouse_pointers/ninja_cursor_off.dmi"

/datum/action/innate/dash/ninja/proc/update_action_style(color_style)
	button_icon_state = "arrows_[clamp(current_charges, 0, max_charges)]" //Защита от потери иконок при админ абузе
	background_icon_state = "background_[color_style]_active"
	if(current_charges == 0)
		background_icon_state = "background_[color_style]"
	UpdateButtonIcon()

/datum/action/innate/dash/ninja/apply_unavailable_effect()
	return

/datum/action/innate/dash/ninja/charge()
	. = ..()
	if(owner && owner.client)
		owner.client.mouse_pointer_icon = file(update_cursor())
		var/obj/item/melee/energy_katana/katana = dashing_item
		update_action_style(katana.color_style)

/// Катана для взломанного борга. У них нет интентов и рук как таковых.
/// Так что блинки сами по себе работать не будут.
/// Плюс урезанный урон
/obj/item/melee/energy_katana/borg
	name = "robotic energy katana"
	desc = "A katana infused with strong energy. Integrated inside a robot! Cyborg ninja's doesn't sound so funny anymore?"
	// Борг-ниндзя - чёрно-красный. Катана тоже будет красной
	icon_state = "energy_katana_red"
	item_state = "energy_katana_red"
	force = 30
	block_chance = 40
	armour_penetration = 40
