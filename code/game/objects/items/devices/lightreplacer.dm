
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

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3


/obj/item/lightreplacer
	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with broken or working light bulbs, or sheets of glass."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "electronic"
	belt_icon = "light_replacer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	origin_tech = "magnets=3;engineering=4"
	force = 8
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

/obj/item/lightreplacer/examine(mob/user)
	. = ..()
	. += status_string()

/obj/item/lightreplacer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(uses >= max_uses)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		else if(G.use(decrement))
			AddUses(increment)
			to_chat(user, "<span class='notice'>You insert a piece of glass into [src]. You have [uses] light\s remaining.</span>")
			return
		else
			to_chat(user, "<span class='warning'>You need one sheet of glass to replace lights!</span>")
		return

	if(istype(I, /obj/item/shard))
		if(uses >= max_uses)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		if(!user.unEquip(I))
			return
		AddUses(round(increment * 0.75))
		to_chat(user, "<span class='notice'>You insert a shard of glass into [src]. You have [uses] light\s remaining.</span>")
		qdel(I)
		return

	if(istype(I, /obj/item/light))
		var/obj/item/light/L = I
		if(L.status == 0) // LIGHT OKAY
			if(uses < max_uses)
				if(!user.unEquip(L))
					return
				AddUses(1)
				qdel(L)
		else
			if(!user.unEquip(L))
				return
			to_chat(user, "<span class='notice'>You insert [L] into [src].</span>")
			AddShards(1, user)
			qdel(L)
		return

	if(isstorage(I))
		var/obj/item/storage/S = I
		var/found_lightbulbs = FALSE
		var/replaced_something = TRUE

		for(var/obj/item/IT in S.contents)
			if(istype(IT, /obj/item/light))
				var/obj/item/light/L = IT
				found_lightbulbs = TRUE
				if(uses >= max_uses)
					break
				if(L.status == LIGHT_OK)
					replaced_something = TRUE
					AddUses(1)
					qdel(L)

				else if(L.status == LIGHT_BROKEN || L.status == LIGHT_BURNED)
					replaced_something = TRUE
					AddShards(1, user)
					qdel(L)

		if(!found_lightbulbs)
			to_chat(user, "<span class='warning'>[S] contains no bulbs.</span>")
			return

		if(!replaced_something && uses == max_uses)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return

		to_chat(user, "<span class='notice'>You fill [src] with lights from [S]. " + status_string() + "</span>")
		return
	return ..()

/obj/item/lightreplacer/emag_act(user as mob)
	if(!emagged)
		emagged = !emagged
		playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

/obj/item/lightreplacer/attack_self(mob/user)
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
		to_chat(user, "<span class='notice'>[src] has fabricated a new bulb from the broken glass it has stored. It now has [uses] uses.</span>")
		playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	return new_bulbs

/obj/item/lightreplacer/proc/Charge(mob/user)
	charge += 1
	if(charge > 3)
		AddUses(1)
		charge = 1

/obj/item/lightreplacer/proc/ReplaceLight(obj/machinery/light/target, mob/living/U)
	if(target.status != LIGHT_OK)
		if(CanUse(U))
			if(!Use(U))
				return
			to_chat(U, "<span class='notice'>You replace the light [target.fitting] with [src].</span>")

			if(target.status != LIGHT_EMPTY)
				AddShards(1, U)
				target.status = LIGHT_EMPTY

			var/obj/item/light/replacement = target.light_type
			target.status = LIGHT_OK
			target.switchcount = 0
			target.rigged = emagged
			target.brightness_range = initial(replacement.brightness_range)
			target.brightness_power = initial(replacement.brightness_power)
			target.brightness_color = initial(replacement.brightness_color)
			target.on = target.has_power()
			target.update(TRUE, TRUE, FALSE)

		else
			to_chat(U, "[src]'s refill light blinks red.")
			return
	else
		to_chat(U, "<span class='warning'>There is a working [target.fitting] already inserted!</span>")
		return

/obj/item/lightreplacer/proc/CanUse(mob/living/user)
	add_fingerprint(user)
	if(uses > 0)
		return 1
	else
		return 0

/obj/item/lightreplacer/afterattack(atom/T, mob/U, proximity)
	. = ..()
	if(!proximity && !bluespace_toggle)
		return
	if(!isturf(T))
		return
	if(get_dist(src, T) >= (U.client.maxview() + 2)) // To prevent people from using it over cameras
		return

	var/used = FALSE
	for(var/atom/A in T)
		if(!CanUse(U))
			break
		used = TRUE
		if(istype(A, /obj/machinery/light))
			if(!proximity)  // only beams if at a distance
				U.Beam(A, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
				playsound(src, 'sound/items/pshoom.ogg', 40, 1)
			ReplaceLight(A, U)

	if(!used)
		to_chat(U, "[src]'s refill light blinks red.")

/obj/item/lightreplacer/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	J.myreplacer = src
	J.put_in_cart(src, user)

/obj/item/lightreplacer/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return

/obj/item/lightreplacer/cyborg/cyborg_recharge(coeff, emagged)
	for(var/I in 1 to coeff)
		Charge()

/obj/item/lightreplacer/bluespace
	name = "bluespace light replacer"
	desc = "A modified light replacer that zaps lights into place. Refill with broken or working light bulbs, or sheets of glass."
	icon_state = "lightreplacer_blue0"
	bluespace_toggle = TRUE

/obj/item/lightreplacer/bluespace/emag_act()
	return  // long range explosions are stupid

#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED
