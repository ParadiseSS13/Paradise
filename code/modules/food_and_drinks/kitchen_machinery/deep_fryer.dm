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
	var/obj/item/reagent_containers/food/snacks/deepfryholder/type = new(get_turf(src))
	return type

/obj/machinery/cooker/deepfryer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks/ice))
		var/ice_amount = I.reagents.get_reagent_amount("ice")
		if(ice_amount)
			I.reagents.remove_all(I.reagents.total_volume)
			add_attack_logs(user, src, "poured [ice_amount]u ice into")
			user.visible_message(
				"<span class='warning'>[user] pours [I] into [src], and it seems to fizz a bit.</span>",
				"<span class='warning'>You pour [I] into [src], and it seems to fizz a bit.</span>",
				"You hear a splash, and a sizzle."
			)

			playsound(src, 'sound/goonstation/misc/drinkfizz.ogg', 25)
			addtimer(CALLBACK(src, .proc/boil_leadup, user), 4 SECONDS)
			addtimer(CALLBACK(src, .proc/make_foam, ice_amount), 5 SECONDS)

			return TRUE

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
		return

/obj/machinery/cooker/deepfryer/special_attack(obj/item/grab/G, mob/user)
	if(ishuman(G.affecting))
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return 0
		var/mob/living/carbon/human/C = G.affecting
		var/obj/item/organ/external/head/head = C.get_organ("head")
		if(!head)
			to_chat(user, "<span class='warning'>This person doesn't have a head!</span>")
			return 0
		C.visible_message("<span class='danger'>[user] dunks [C]'s face into [src]!</span>", \
						"<span class='userdanger'>[user] dunks your face into [src]!</span>")
		C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		C.apply_damage(25, BURN, "head") //25 fire damage and disfigurement because your face was just deep fried!
		head.disfigure()
		add_attack_logs(user, G.affecting, "Deep-fried with [src]")
		qdel(G) //Removes the grip so the person MIGHT have a small chance to run the fuck away and to prevent rapid dunks.
		return 0
	return 0

/// Make foam consisting of burning oil.
/obj/machinery/cooker/deepfryer/proc/make_foam(ice_amount)
	if(!reagents)
		create_reagents()
	// the cooking oil should spread through the foam.
	// when it gets added, it's at 1000 degrees so it quickly fireflashes and reacts to form inert cooking oil.
	reagents.add_reagent("cooking_oil", ice_amount * 2, reagtemp = 1000)
	reagents.chem_temp = 1000
	var/datum/effect_system/foam_spread/S = new()
	S.set_up(ice_amount * 2, loc, reagents, FALSE)
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
	input = /obj/item/reagent_containers/food/snacks/shrimp
	output = /obj/item/reagent_containers/food/snacks/fried_shrimp

/datum/deepfryer_special/banana
	input = /obj/item/reagent_containers/food/snacks/grown/banana
	output = /obj/item/reagent_containers/food/snacks/friedbanana

/datum/deepfryer_special/fries
	input = /obj/item/reagent_containers/food/snacks/rawsticks
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/deepfryer_special/corn_chips
	input = /obj/item/reagent_containers/food/snacks/grown/corn
	output = /obj/item/reagent_containers/food/snacks/cornchips

/datum/deepfryer_special/fried_tofu
	input = /obj/item/reagent_containers/food/snacks/tofu
	output = /obj/item/reagent_containers/food/snacks/fried_tofu

/datum/deepfryer_special/chimichanga
	input = /obj/item/reagent_containers/food/snacks/burrito
	output = /obj/item/reagent_containers/food/snacks/chimichanga

/datum/deepfryer_special/potato_chips
	input = /obj/item/reagent_containers/food/snacks/grown/potato/wedges
	output = /obj/item/reagent_containers/food/snacks/chips

/datum/deepfryer_special/carrotfries
	input = /obj/item/reagent_containers/food/snacks/grown/carrot/wedges
	output = /obj/item/reagent_containers/food/snacks/carrotfries

/datum/deepfryer_special/onionrings
	input = /obj/item/reagent_containers/food/snacks/onion_slice
	output = /obj/item/reagent_containers/food/snacks/onionrings

/datum/deepfryer_special/fried_vox
	input = /obj/item/organ/external
	output = /obj/item/reagent_containers/food/snacks/fried_vox

/datum/deepfryer_special/fried_vox/validate(obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/E = I
	return istype(E.dna.species, /datum/species/vox)

/obj/machinery/cooker/deepfryer/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 30)
