#define REAGENT_TIME_RATIO 2.5

/*
CONTENTS:
1. CIGARETTES
2. CIGARS
3. HOLO-CIGAR
4. PIPES
5. ROLLING

CIGARETTE PACKETS ARE IN FANCY.DM
LIGHTERS ARE IN LIGHTERS.DM
*/

//////////////////
//FINE SMOKABLES//
//////////////////

/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	item_state = "cigoff"
	throw_speed = 0.5
	slot_flags = SLOT_FLAG_MASK
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	attack_verb = null
	container_type = INJECTABLE
	/// Is the cigarette lit?
	var/lit = FALSE
	/// Lit cigarette sprite.
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	/// Unlit cigarette sprite.
	var/icon_off = "cigoff"
	/// Do we require special items to be lit?
	var/list/fancy_lighters = list()
	/// What trash item the cigarette makes when it burns out.
	var/type_butt = /obj/item/cigbutt
	/// How long does the cigarette last before going out? Decrements by 1 every cycle.
	var/smoketime = 150 // 300 seconds.
	/// The cigarette's total reagent capacity.
	var/chem_volume = 60
	/// A list of the types and amounts of reagents in the cigarette.
	var/list/list_reagents = list("nicotine" = 40)
	/// Has anyone taken any reagents from the cigarette? The first tick gives a bigger dose.
	var/first_puff = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi')

/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 30
	reagents.set_reacting(FALSE) // so it doesn't react until you light it
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	smoketime = reagents.total_volume * 2.5

/obj/item/clothing/mask/cigarette/Destroy()
	QDEL_NULL(reagents)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/cigarette/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/M, mob/living/user, def_zone)
	if(istype(M) && M.on_fire)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(M)
		if(M != user)
			user.visible_message(
				"<span class='notice'>[user] coldly lights [src] with the burning body of [M]. Clearly, [user.p_they()] offer[user.p_s()] the warmest of regards...</span>",
				"<span class='notice'>You coldly light [src] with the burning body of [M].</span>"
			)
		else
			// The fire will light it in your hands by itself, but if you whip out the cig and click yourself fast enough, this will happen. TRULY you have your priorities stright.
			user.visible_message(
				"<span class='notice'>[user] quickly whips out [src] and nonchalantly lights it with [user.p_their()] own burning body. Clearly, [user.p_they()] [user.p_have()] [user.p_their()] priorities straight.</span>",
				"<span class='notice'>You quickly whip out [src] and nonchalantly light it with your own burning body. Clearly, you have your priorities straight.</span>"
			)
		light(user, user)
		return TRUE

/obj/item/clothing/mask/cigarette/afterattack(atom/target, mob/living/user, proximity)
	if(!proximity)
		return

	if(ismob(target))
		// If the target has no cig, try to give them the cig.
		var/mob/living/carbon/M = target
		if(istype(M) && user.zone_selected == "mouth" && !M.wear_mask && user.a_intent == INTENT_HELP)
			user.unEquip(src, TRUE)
			M.equip_to_slot_if_possible(src, SLOT_HUD_WEAR_MASK)
			if(target != user)
				user.visible_message(
					"<span class='notice'>[user] slips \a [name] into the mouth of [M].</span>",
					"<span class='notice'>You slip [src] into the mouth of [M].</span>"
				)
			else
				to_chat(user, "<span class='notice'>You put [src] into your mouth.</span>")
			return TRUE

		// If they DO have a cig, try to light it with your own cig.
		if(!cigarette_lighter_act(user, M))
			return ..()

	// You can dip cigarettes into beakers.
	if(istype(target, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/glass = target
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)
			to_chat(user, "<span class='notice'>You dip [src] into [glass].</span>")
			return

		// Either the beaker was empty, or the cigarette was full
		if(!glass.reagents.total_volume)
			to_chat(user, "<span class='notice'>[glass] is empty.</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")

	return ..()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message(
			"<span class='notice'>[user] calmly drops and treads on [src], putting it out instantly.</span>",
			"<span class='notice'>You calmly drop and tread on [src], putting it out instantly.</span>",
			"<span class='notice'>You hear a foot being brought down on something, and the tiny fizzling of an ember going out.</span>"
		)
		die()
	return ..()

/obj/item/clothing/mask/cigarette/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold \the [initial(name)] while it's lit!</span>") // initial(name) so it doesn't say "lit" twice in a row
		return FALSE
	return TRUE

/obj/item/clothing/mask/cigarette/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	light()

/obj/item/clothing/mask/cigarette/catch_fire()
	if(!lit)
		visible_message("<span class='warning'>[src] is lit by the flames!</span>")
		light()

/obj/item/clothing/mask/cigarette/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!lit)
		to_chat(user, "<span class='warning'>You cannot light [cig] with [src] because you need a lighter to light [src] before you can use [src] as a lighter to light [cig]... This seems a little convoluted.</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='notice'>[user] presses [src] against [cig] until it lights. Seems oddly recursive...</span>",
			"<span class='notice'>You press [src] against [cig] until it lights. Seems oddly recursive...</span>"
		)
	else
		user.visible_message(
			"<span class='notice'>[user] presses [src] until it lights. Sharing is caring!</span>",
			"<span class='notice'>You press [src] against [cig] until it lights. Sharing is caring!</span>"
		)
	cig.light(user, target)
	return TRUE

/obj/item/clothing/mask/cigarette/attackby(obj/item/I, mob/living/user, params)
	if(I.cigarette_lighter_act(user, user, src))
		return

	// Catch any item that has no cigarette_lighter_act but logically should be able to work as a lighter due to being hot.
	if(I.get_heat())
		//Give a generic light message.
		user.visible_message(
			"<span class='notice'>[user] lights [src] with [I]</span>",
			"<span class='notice'>You light [src] with [I].</span>"
		)
		light(user)

/obj/item/clothing/mask/cigarette/proc/light(mob/living/user, mob/living/target)
	if(lit)
		return

	lit = TRUE
	name = "lit [name]"
	attack_verb = list("burnt", "singed")
	hitsound = 'sound/items/welder.ogg'
	damtype = BURN
	force = 4
	var/mob/M = loc

	// Plasma explodes when exposed to fire.
	if(reagents.get_reagent_amount("plasma"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(M))
			M.unEquip(src, TRUE)
		qdel(src)
		return

	// Fuel explodes, too, but much less violently.
	if(reagents.get_reagent_amount("fuel"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(M))
			M.unEquip(src, TRUE)
		qdel(src)
		return

	// If there is no target, the user is probably lighting their own cig.
	if(isnull(target))
		target = user

	// If there is also no user, the cig is being lit by atmos or something.
	if(target)
		target.update_inv_wear_mask()
		target.update_inv_l_hand()
		target.update_inv_r_hand()

	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(C.wear_mask == src) // Don't update if it's just in their hand
			C.wear_mask_update(src)
	set_light(2, 0.25, "#E38F46")
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	return TRUE

/obj/item/clothing/mask/cigarette/process()
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(reagents.total_volume <= 0 || smoketime < 1)
		die()
		return
	smoke()

/obj/item/clothing/mask/cigarette/extinguish_light(force)
	if(!force)
		return
	die()

/obj/item/clothing/mask/cigarette/proc/smoke()
	var/turf/location = get_turf(src)
	var/is_being_smoked = FALSE
	// Check whether this is actually in a mouth, being smoked
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(src == C.wear_mask)
			// There used to be a species check here, but synthetics can smoke now
			is_being_smoked = TRUE
	if(location)
		location.hotspot_expose(700, 5)
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(is_being_smoked) // if it's being smoked, transfer reagents to the mob
			var/mob/living/carbon/C = loc
			for(var/datum/reagent/R in reagents.reagent_list)
				reagents.trans_id_to(C, R.id, first_puff ? 1 : max(REAGENTS_METABOLISM / length(reagents.reagent_list), 0.1)) //transfer at least .1 of each chem
			first_puff = FALSE
			if(!reagents.total_volume) // There were reagents, but now they're gone
				to_chat(C, "<span class='notice'>Your [name] loses its flavor.</span>")
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	set_light(0)
	var/obj/item/butt = new type_butt(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		M.unEquip(src, TRUE)		//Force the un-equip so the overlays update
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/item/clothing/mask/cigarette/get_heat()
	return lit * 1000

//////////////////////////////
// MARK: CIGARETTES
//////////////////////////////
/obj/item/clothing/mask/cigarette/menthol
	list_reagents = list("nicotine" = 40, "menthol" = 20)

/obj/item/clothing/mask/cigarette/random

/obj/item/clothing/mask/cigarette/random/New()
	list_reagents = list("nicotine" = 40, pick("fuel","saltpetre","synaptizine","green_vomit","potass_iodide","msg","lexorin","mannitol","spaceacillin","cryoxadone","holywater","tea","egg","haloperidol","mutagen","omnizine","carpet","aranesp","cryostylane","chocolate","bilk","cheese","rum","blood","charcoal","coffee","ectoplasm","space_drugs","milk","mutadone","antihol","teporone","insulin","salbutamol","toxin") = 20)
	..()

/obj/item/clothing/mask/cigarette/syndicate
	list_reagents = list("nicotine" = 40, "omnizine" = 20)

/obj/item/clothing/mask/cigarette/medical_marijuana
	list_reagents = list("thc" = 20, "cbd" = 40)

/obj/item/clothing/mask/cigarette/robustgold
	list_reagents = list("nicotine" = 40, "gold" = 1)

/obj/item/clothing/mask/cigarette/shadyjims
	list_reagents = list("nicotine" = 40, "lipolicide" = 7.5, "ammonia" = 2, "atrazine" = 1, "toxin" = 1.5)

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"
	list_reagents = list("thc" = 40, "cbd" = 20)

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/custom
	list_reagents = list()

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/cigbutt/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	transform = turn(transform, rand(0, 360))

/obj/item/cigbutt/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

//////////////////////////////
// MARK: ROLLING
//////////////////////////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(target, /obj/item/food/grown))
		return ..()

	var/obj/item/food/grown/plant = target
	if(!plant.dry)
		to_chat(user, "<span class='warning'>You need to dry this first!</span>")
		return

	user.unEquip(plant, TRUE)
	user.unEquip(src, TRUE)
	var/obj/item/clothing/mask/cigarette/rollie/custom/custom_rollie = new (get_turf(user))
	custom_rollie.reagents.maximum_volume = plant.reagents.total_volume
	plant.reagents.trans_to(custom_rollie, plant.reagents.total_volume)
	custom_rollie.smoketime = custom_rollie.reagents.total_volume * 2.5

	user.put_in_active_hand(custom_rollie)
	to_chat(user, "<span class='notice'>You roll the [plant.name] into a rolling paper.</span>")
	custom_rollie.desc = "Dried [plant.name] rolled up in a thin piece of paper."

	qdel(plant)
	qdel(src)

//////////////////////////////
// MARK: CIGARS
//////////////////////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "\improper Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	item_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	throw_speed = 0.5
	fancy_lighters = list(/obj/item/match, /obj/item/lighter/zippo)
	type_butt = /obj/item/cigbutt/cigarbutt
	smoketime = 300
	chem_volume = 120
	list_reagents = list("nicotine" = 120)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "\improper Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 450
	chem_volume = 180
	list_reagents = list("nicotine" = 180)

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

//////////////////////////////
// MARK: HOLO-CIGAR
//////////////////////////////
/obj/item/clothing/mask/holo_cigar
	name = "Holo-Cigar"
	desc = "A sleek electronic cigar imported straight from Sol. You feel badass merely glimpsing it..."
	icon_state = "holocigaroff"
	/// Is the holo-cigar lit?
	var/enabled = FALSE
	/// Tracks if this is the first cycle smoking the cigar.
	var/has_smoked = FALSE

/obj/item/clothing/mask/holo_cigar/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/holo_cigar/update_icon_state()
	. = ..()
	icon_state = "holocigar[enabled ? "on" : "off"]"

/obj/item/clothing/mask/holo_cigar/examine(mob/user)
	. = ..()
	if(enabled)
		. += "[src] hums softly as it synthesizes nicotine."
	else
		. += "[src] seems to be inactive."

/obj/item/clothing/mask/holo_cigar/process()
	if(!iscarbon(loc))
		return

	var/mob/living/carbon/C = loc
	if(C.wear_mask != src)
		return

	if(!has_smoked)
		C.reagents.add_reagent("nicotine", 2)
		has_smoked = TRUE
	else
		C.reagents.add_reagent("nicotine", REAGENTS_METABOLISM)

/obj/item/clothing/mask/holo_cigar/equipped(mob/user, slot, initial)
	. = ..()
	if(enabled && slot == SLOT_HUD_WEAR_MASK)
		if(!HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
			ADD_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR)
			to_chat(user, "<span class='notice'>You feel more badass while smoking [src].</span>")

/obj/item/clothing/mask/holo_cigar/dropped(mob/user, silent)
	. = ..()
	has_smoked = FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
		REMOVE_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR)
		to_chat(user, "<span class='notice'>You feel less badass.</span>")

/obj/item/clothing/mask/holo_cigar/attack_self(mob/user)
	. = ..()
	if(enabled)
		enabled = FALSE
		to_chat(user, "<span class='notice'>You disable the holo-cigar.</span>")
		STOP_PROCESSING(SSobj, src)
	else
		enabled = TRUE
		to_chat(user, "<span class='notice'>You enable the holo-cigar.</span>")
		START_PROCESSING(SSobj, src)

	update_appearance(UPDATE_ICON_STATE)

//////////////////////////////
// MARK: PIPES
//////////////////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	fancy_lighters = list(/obj/item/match, /obj/item/lighter/zippo)
	smoketime = 500
	chem_volume = 200
	list_reagents = list("nicotine" = 200)

/obj/item/clothing/mask/cigarette/pipe/die()
	return

/obj/item/clothing/mask/cigarette/pipe/light()
	if(!lit)
		lit = TRUE
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
			lit = FALSE
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask()
		STOP_PROCESSING(SSobj, src)
		return
	smoke()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user) // Extinguishes the pipe.
	if(lit)
		user.visible_message(
			"<span class='notice'>[user] puts out [src].</span>",
			"<span class='notice'>You put out [src].</span>"
		)
		lit = FALSE
		first_puff = TRUE
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return

// Refill the pipe
/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/grown))
		var/obj/item/food/grown/O = I
		if(O.dry)
			if(reagents.total_volume == reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[src] is full!</span>")
				return
			O.reagents.trans_to(src, chem_volume)
			to_chat(user, "<span class='notice'>You stuff the [O.name] into the pipe.</span>")
			smoketime = max(reagents.total_volume * REAGENT_TIME_RATIO, smoketime)
			qdel(O)
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
		return

	return ..()

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 0 //there is nothing to smoke initially
	chem_volume = 160
	list_reagents = list()

#undef REAGENT_TIME_RATIO
