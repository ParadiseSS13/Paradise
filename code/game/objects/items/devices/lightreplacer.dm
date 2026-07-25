
// Light Replacer (LR)
//
// ABOUT THE DEVICE
//
// This is a device supposedly to be used by Janitors and Janitor Cyborgs which will
// allow them to easily replace lights. This was mostly designed for Janitor Cyborgs since
// they don't have hands or a way to replace lightbulbs.
//
// HOW IT WORKS
//
// You attack a light fixture with it, if the light fixture is broken it will replace the
// light fixture with a working light; the broken light is then placed on the floor for the
// user to then pickup with a trash bag. If it's empty then it will just place a light in the fixture.
//
// HOW TO REFILL THE DEVICE
//
// It will need to be manually refilled with lights.
// If it's part of a robot module, it will charge when the Robot is inside a Recharge Station.
//
// EMAGGED FEATURES
//
// NOTICE: The Cyborg cannot use the emagged Light Replacer and the light's explosion was nerfed. It cannot create holes in the station anymore.
//
// I'm not sure everyone will react the emag's features so please say what your opinions are of it.
//
// When emagged it will rig every light it replaces, which will explode when the light is on.
// This is VERY noticable, even the device's name changes when you emag it so if anyone
// examines you when you're holding it in your hand, you will be discovered.
// It will also be very obvious who is setting all these lights off, since only Janitor Borgs and Janitors have easy
// access to them, and only one of them can emag their device.
//
// The explosion cannot insta-kill anyone with 30% or more health.
/obj/item/lightreplacer
	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with broken or working light bulbs, or sheets of glass."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	belt_icon = "light_replacer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "magnets=3;engineering=4"
	force = 8
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 3000)
	var/max_uses = 20
	var/uses = 10
	/// How much to increase per each glass?
	var/increment = 5
	/// How much to take from the glass?
	var/decrement = 1
	var/charge = 1
	/// Eating used bulbs gives us bulb shards
	var/bulb_shards = 0
	/// when we get this many shards, we get a free bulb.
	var/shards_required = 4
	/// It can replace lights at a distance?
	var/bluespace_toggle = FALSE
	new_attack_chain = TRUE

/obj/item/lightreplacer/examine(mob/user)
	. = ..()
	. += status_string()

/obj/item/lightreplacer/item_interaction(mob/user, obj/item/used, list/modifiers)
	if(uses >= max_uses)
		to_chat(user, SPAN_WARNING("[src] is full!"))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/stack = used

		if(stack.use(decrement))
			AddUses(increment)
			to_chat(user, SPAN_NOTICE("You insert some glass into [src]. You have [uses] light\s remaining."))
		else
			to_chat(user, SPAN_WARNING("You need one sheet of glass to replace lights!"))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/shard))
		if(!user.drop_item_to_ground(used))
			to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
			return ITEM_INTERACT_COMPLETE

		AddUses(increment)
		to_chat(user, SPAN_NOTICE("You insert a shard of glass into [src]. You have [uses] light\s remaining."))
		qdel(used)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/light))
		var/obj/item/light/bulb = used
		if(!user.drop_item_to_ground(bulb))
			to_chat(user, SPAN_WARNING("[bulb] is stuck to your hand!"))
			return ITEM_INTERACT_COMPLETE

		if(bulb.status == LIGHT_OK)
			AddUses(1)
			to_chat(user, SPAN_NOTICE("You insert [bulb] into [src]. You have [uses] light\s remaining."))
		else
			AddShards(1, user)
			to_chat(user, SPAN_NOTICE("You insert [bulb] into [src]. You have [uses] light\s remaining."))
		qdel(bulb)
		return ITEM_INTERACT_COMPLETE

	if(isstorage(used))
		var/obj/item/storage/container = used
		var/found_lightbulbs = FALSE
		var/replaced_something = TRUE

		for(var/obj/item/IT in container.contents)
			if(istype(IT, /obj/item/light))
				var/obj/item/light/bulb = IT
				found_lightbulbs = TRUE
				if(uses >= max_uses)
					break
				if(bulb.status == LIGHT_OK)
					replaced_something = TRUE
					AddUses(1)
					qdel(bulb)

				else if(bulb.status == LIGHT_BROKEN || bulb.status == LIGHT_BURNED)
					replaced_something = TRUE
					AddShards(1, user)
					qdel(bulb)

		if(!found_lightbulbs)
			to_chat(user, SPAN_WARNING("[container] contains no bulbs!"))
			return ITEM_INTERACT_COMPLETE

		if(!replaced_something && uses == max_uses)
			to_chat(user, SPAN_WARNING("[src] is full!"))
			return ITEM_INTERACT_COMPLETE

		to_chat(user, SPAN_NOTICE("You fill [src] with lights from [container]. " + status_string() + ""))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/lightreplacer/emag_act(user as mob)
	if(!emagged)
		emagged = !emagged
		playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
		return TRUE

/obj/item/lightreplacer/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	for(var/obj/machinery/light/target in user.loc)
		ReplaceLight(target, user)
	to_chat(user, status_string())

/obj/item/lightreplacer/update_name()
	. = ..()
	if(emagged)
		name = "shortcircuited [initial(name)]"
	else
		name = initial(name)

/obj/item/lightreplacer/update_icon_state()
	icon_state = "lightreplacer[emagged]"
	belt_icon = emagged ? "light_replacer_red" : "light_replacer"

/obj/item/lightreplacer/proc/status_string()
	return "It has [uses] light\s remaining (plus [bulb_shards] fragment\s)."

/obj/item/lightreplacer/proc/Use(mob/user)
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	AddUses(-1)
	return 1

// Negative numbers will subtract
/obj/item/lightreplacer/proc/AddUses(amount = 1)
	uses = clamp(uses + amount, 0, max_uses)

/obj/item/lightreplacer/proc/AddShards(amount = 1, user)
	bulb_shards += amount
	var/new_bulbs = round(bulb_shards / shards_required)
	if(new_bulbs > 0)
		AddUses(new_bulbs)
	bulb_shards = bulb_shards % shards_required
	if(new_bulbs != 0)
		to_chat(user, SPAN_NOTICE("[src] has fabricated a new bulb from the broken glass it has stored. It now has [uses] uses."))
		playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	return new_bulbs

/obj/item/lightreplacer/proc/Charge(mob/user)
	charge += 1
	if(charge > 3)
		AddUses(1)
		charge = 1

/obj/item/lightreplacer/proc/ReplaceLight(obj/machinery/light/target, mob/living/user)
	if(target.status != LIGHT_OK)
		if(CanUse(user))
			if(!Use(user))
				return
			if(target.status != LIGHT_EMPTY)
				AddShards(1, user)
				target.status = LIGHT_EMPTY
			target.fix(user, src, emagged)

		else
			to_chat(user, SPAN_WARNING("[src]'s refill light blinks red!"))
			return
	else
		to_chat(user, SPAN_WARNING("There is a working [target.fitting] already inserted!"))
		return

/obj/item/lightreplacer/proc/CanUse(mob/living/user)
	add_fingerprint(user)
	if(uses > 0)
		return 1
	else
		return 0

/obj/item/lightreplacer/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(isitem(target))
		item_interaction(user, target)
		return ITEM_INTERACT_COMPLETE

	var/turf/replace_turf = get_turf(target)
	if(!istype(replace_turf))
		return ITEM_INTERACT_COMPLETE

	if(replace_lights_on_turf(replace_turf, user))
		return ITEM_INTERACT_COMPLETE

/obj/item/lightreplacer/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!bluespace_toggle)
		return ITEM_INTERACT_COMPLETE

	var/turf/replace_turf = get_turf(target)
	if(!istype(replace_turf))
		return ITEM_INTERACT_COMPLETE

	if(get_dist(src, target) >= (user.client.maxview() + 2)) // To prevent people from using it over cameras.
		return ITEM_INTERACT_COMPLETE

	replace_lights_on_turf(replace_turf, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/lightreplacer/proc/replace_lights_on_turf(turf/replace_turf, mob/living/user)
	if(!istype(replace_turf))
		return FALSE

	var/used = FALSE
	for(var/atom/each_atom in replace_turf)
		if(!CanUse(user))
			to_chat(user, SPAN_WARNING("[src]'s refill light blinks red!"))
			break
		if(!istype(each_atom, /obj/machinery/light))
			continue
		if(!each_atom.Adjacent(user))  // only beams if at a distance
			user.Beam(each_atom, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
			playsound(src, 'sound/items/pshoom.ogg', 40, 1)
		ReplaceLight(each_atom, user)
		used = TRUE
	if(used)
		return TRUE

/obj/item/lightreplacer/cyborg/cyborg_recharge(coeff, emagged)
	for(var/I in 1 to coeff)
		Charge()

/obj/item/lightreplacer/bluespace
	name = "bluespace light replacer"
	desc = "A modified light replacer that zaps lights into place. Refill with broken or working light bulbs, or sheets of glass."
	icon_state = "lightreplacer_blue"
	belt_icon = "light_replacer_blue"
	bluespace_toggle = TRUE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 6000, MAT_BLUESPACE = 300)

/obj/item/lightreplacer/bluespace/update_icon_state() // Does not have an emagged icon state
	icon_state = "lightreplacer_blue"
	belt_icon = "lightreplacer_blue"

/obj/item/lightreplacer/bluespace/emag_act()
	return  // long range explosions are stupid
