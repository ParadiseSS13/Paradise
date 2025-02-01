/obj/machinery/cooker/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "fryer_off"
	thiscooktype = "deep fried"
	burns = TRUE
	firechance = 100
	cooktime = 200
	foodcolor = "#FFAD33"
	officon = "fryer_off"
	onicon = "fryer_on"
	openicon = "fryer_open"
	has_specials = TRUE
	upgradeable = TRUE

/obj/machinery/cooker/deepfryer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/deepfryer(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/cooker/deepfryer/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/deepfryer(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/cooker/deepfryer/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		E += L.rating
	E -= 2		//Standard parts is 0 (1+1-2), Tier 4 parts is 6 (4+4-2)
	cooktime = (200 - (E * 20))		//Effectively each laser improves cooktime by 20 per rating beyond the first (200 base, 80 max upgrade)

/obj/machinery/cooker/deepfryer/gettype()
	var/obj/item/food/deepfryholder/type = new(get_turf(src))
	return type

/obj/machinery/cooker/deepfryer/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/reagent_containers/glass) || istype(used, /obj/item/reagent_containers/drinks/ice))
		var/ice_amount = used.reagents.get_reagent_amount("ice")
		if(ice_amount)
			used.reagents.remove_all(used.reagents.total_volume)
			add_attack_logs(user, src, "poured [ice_amount]u ice into")
			user.visible_message(
				"<span class='warning'>[user] pours [used] into [src], and it seems to fizz a bit.</span>",
				"<span class='warning'>You pour [used] into [src], and it seems to fizz a bit.</span>",
				"You hear a splash, and a sizzle."
			)

			playsound(src, 'sound/goonstation/misc/drinkfizz.ogg', 25)
			addtimer(CALLBACK(src, PROC_REF(boil_leadup), user), 4 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(make_foam), ice_amount), 5 SECONDS)

			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/cooker/deepfryer/proc/boil_leadup(mob/user)
	visible_message(
		"<span class='danger'>[src] starts to bubble and froth unnervingly!</span>",
		"<span class='danger'>You hear a growling and intimidating bubbling!</span>"
	)

	playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 75)
	to_chat(user, "<span class='userdanger'>Are you sure that was such a good idea?</span>")

/obj/machinery/cooker/deepfryer/examine(mob/user)
	. = ..()
	if(emagged)
		. += "<span class='warning'>The heating element is smoking slightly.</span>"

/obj/machinery/cooker/deepfryer/emag_act()
	if(!emagged)
		to_chat(usr, "<span class='warning'>You short out the fryer's safeties, allowing non-food objects to be placed in the oil.</span>")
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		emagged = TRUE
		return TRUE

/obj/machinery/cooker/deepfryer/special_attack_shove(mob/living/target, mob/living/attacker)
	target.visible_message(
		"<span class='danger'>[attacker] shoves [target] against [src], and [target] reaches into the hot oil trying to catch [target.p_their()] fall!</span>",
		"<span class='userdanger'>[attacker] shoves you into [src], your hands landing in hot oil!</span>",
		"<span class='danger'>You hear a splash and a loud sizzle.</span>"
	)
	target.apply_damage(10, BURN, BODY_ZONE_PRECISE_L_HAND)
	target.apply_damage(10, BURN, BODY_ZONE_PRECISE_R_HAND)
	playsound(src, 'sound/goonstation/misc/drinkfizz.ogg', 25)
	return FALSE

/obj/machinery/cooker/deepfryer/special_attack(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/head/head = target.get_organ("head")
	if(!istype(head))
		to_chat(user, "<span class='warning'>This person doesn't have a head!</span>")
		return FALSE  // you'll probably get smacked against it
	target.visible_message(
		"<span class='danger'>[user] dunks [target]'s face into [src]!</span>",
		"<span class='userdanger'>[user] dunks your face into [src]!</span>",
		"<span class='danger'>You hear a splash and a loud sizzle.</span>"
	)
	playsound(src, "sound/machines/kitchen/deep_fryer_emerge.ogg", 100)
	target.emote("scream")
	target.apply_damage(45, BURN, "head") // 45 fire damage and disfigurement because your face was just deep fried!
	head.disfigure()
	add_attack_logs(user, target, "Deep-fried with [src]")
	return TRUE

/// Make foam consisting of burning oil.
/obj/machinery/cooker/deepfryer/proc/make_foam(ice_amount)
	if(!reagents)
		create_reagents()
	// the cooking oil should spread through the foam.
	// when it gets added, it's at 1000 degrees so it quickly fireflashes and reacts to form inert cooking oil.
	reagents.add_reagent("cooking_oil", ice_amount * 2, reagtemp = 1000, no_react = TRUE)
	reagents.chem_temp = 1000
	var/datum/effect_system/foam_spread/oil/S = new()
	S.set_up(ice_amount * 2, loc, reagents, FALSE)
	S.temperature = 1000
	S.start()


/obj/machinery/cooker/deepfryer/checkSpecials(obj/item/I)
	if(!I)
		return 0
	for(var/Type in subtypesof(/datum/deepfryer_special))
		var/datum/deepfryer_special/P = new Type()
		if(!P.validate(I))
			continue
		return P
	return 0

/obj/machinery/cooker/deepfryer/cookSpecial(special)
	if(!special)
		return 0
	var/datum/deepfryer_special/recipe = special
	if(!recipe.output)
		return 0
	new recipe.output(get_turf(src))

//////////////////////////////////
//		Deepfryer Special		//
//		Interaction Datums		//
//////////////////////////////////

/datum/deepfryer_special
	var/input		//Thing that goes in
	var/output		//Thing that comes out

/datum/deepfryer_special/proc/validate(obj/item/I)
	return istype(I, input)

/datum/deepfryer_special/shrimp
	input = /obj/item/food/shrimp
	output = /obj/item/food/fried_shrimp

/datum/deepfryer_special/banana
	input = /obj/item/food/grown/banana
	output = /obj/item/food/friedbanana

/datum/deepfryer_special/fries
	input = /obj/item/food/rawsticks
	output = /obj/item/food/fries

/datum/deepfryer_special/corn_chips
	input = /obj/item/food/grown/corn
	output = /obj/item/food/cornchips

/datum/deepfryer_special/fried_tofu
	input = /obj/item/food/tofu
	output = /obj/item/food/fried_tofu

/datum/deepfryer_special/chimichanga
	input = /obj/item/food/burrito
	output = /obj/item/food/chimichanga

/datum/deepfryer_special/potato_chips
	input = /obj/item/food/grown/potato/wedges
	output = /obj/item/food/chips

/datum/deepfryer_special/carrotfries
	input = /obj/item/food/grown/carrot/wedges
	output = /obj/item/food/carrotfries

/datum/deepfryer_special/onionrings
	input = /obj/item/food/sliced/onion_slice
	output = /obj/item/food/onionrings

/datum/deepfryer_special/fried_vox
	input = /obj/item/organ/external
	output = /obj/item/food/fried_vox

/datum/deepfryer_special/fried_vox/validate(obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/E = I
	return istype(E.dna.species, /datum/species/vox)

/obj/machinery/cooker/deepfryer/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 30)
