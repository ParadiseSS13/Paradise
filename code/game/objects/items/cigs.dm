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
	icon = 'icons/obj/clothing/smoking.dmi'
	icon_state = "cig"
	lefthand_file = 'icons/mob/inhands/smoking_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/smoking_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	attack_verb = null
	container_type = INJECTABLE
	new_attack_chain = TRUE
	/// Is the cigarette lit?
	var/lit = FALSE
	/// Do we require special items to be lit?
	var/list/fancy_lighters = list()
	/// What trash item the cigarette makes when it burns out.
	var/butt_type = /obj/item/cigbutt
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
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 60
	reagents.set_reacting(FALSE) // so it doesn't react until you light it
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	smoketime = reagents.total_volume * 2.5
	update_appearance(UPDATE_NAME|UPDATE_ICON)

/obj/item/clothing/mask/cigarette/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][lit ? "_on" : ""]"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_mask()
		H.update_inv_l_hand()
		H.update_inv_r_hand()

/obj/item/clothing/mask/cigarette/update_name()
	. = ..()
	if(!lit)
		name = initial(name)
	else
		name = "lit [name]"

/obj/item/clothing/mask/cigarette/activate_self(mob/user)
	if(..())
		return

	if(lit)
		extinguish_cigarette(user)

/obj/item/clothing/mask/cigarette/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/reagent_containers/syringe))
		return ..()

	if(used.cigarette_lighter_act(user, user, src))
		return ITEM_INTERACT_COMPLETE

	// Catch any item that has no `cigarette_lighter_act()` but logically should be able to work as a lighter due to being hot.
	if(used.get_heat())
		//Give a generic light message.
		user.visible_message(
			"<span class='notice'>[user] lights [src] with [used]</span>",
			"<span class='notice'>You light [src] with [used].</span>"
		)
		light(user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/clothing/mask/cigarette/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/item/reagent_containers/glass))
		return ..()

	var/obj/item/reagent_containers/glass/glass = target
	var/transfered = glass.reagents.trans_to(src, chem_volume)
	if(transfered)
		to_chat(user, "<span class='notice'>You dip [src] into [target].</span>")
		return ITEM_INTERACT_COMPLETE

	// Either the beaker was empty, or the cigarette was full
	if(!glass.reagents.total_volume)
		to_chat(user, "<span class='notice'>[target] is empty.</span>")
	else
		to_chat(user, "<span class='notice'>[src] is full.</span>")
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/mask/cigarette/pre_attack(atom/atom_target, mob/living/user, params)
	if(!ismob(atom_target))
		return ..()

	var/mob/living/target = atom_target
	if(target.on_fire)
		user.do_attack_animation(target)
		if(target != user)
			user.visible_message(
				"<span class='notice'>[user] coldly lights [src] with the burning body of [target]. Clearly, [user.p_they()] offer[user.p_s()] the warmest of regards...</span>",
				"<span class='notice'>You coldly light [src] with the burning body of [target].</span>"
			)
		else
			// The fire will light it in your hands by itself, but if you whip out the cig and click yourself fast enough, this will happen. TRULY you have your priorities stright.
			user.visible_message(
				"<span class='notice'>[user] quickly whips out [src] and nonchalantly lights it with [user.p_their()] own burning body. Clearly, [user.p_they()] [user.p_have()] [user.p_their()] priorities straight.</span>",
				"<span class='notice'>You quickly whip out [src] and nonchalantly light it with your own burning body. Clearly, you have your priorities straight.</span>"
			)
		light(user, user)
		return FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK

	// The above section doesn't check for carbons to allow ALL burning bodies to be used.
	if(!iscarbon(target))
		return ..()

	// If the target has no cig, try to give them the cig.
	var/mob/living/carbon_target = target
	if(user.zone_selected == "mouth" && !carbon_target.wear_mask && user.a_intent == INTENT_HELP)
		user.drop_item_to_ground(src, force = TRUE)
		carbon_target.equip_to_slot_if_possible(src, ITEM_SLOT_MASK)
		if(target != user)
			user.visible_message(
				"<span class='notice'>[user] slips \a [name] into the mouth of [carbon_target].</span>",
				"<span class='notice'>You slip [src] into the mouth of [carbon_target].</span>"
			)
		else
			to_chat(user, "<span class='notice'>You put [src] into your mouth.</span>")
		return FINISH_ATTACK

	// If they DO have a cig, try to light it with your own cig.
	if(cigarette_lighter_act(user, carbon_target))
		return FINISH_ATTACK

	return ..()

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

/obj/item/clothing/mask/cigarette/proc/extinguish_cigarette(mob/user)
	user.visible_message(
		"<span class='notice'>[user] calmly drops and treads on [src], putting it out instantly.</span>",
		"<span class='notice'>You calmly drop and tread on [src], putting it out instantly.</span>",
		"<span class='notice'>You hear a foot being brought down on something, and the tiny fizzling of an ember going out.</span>"
	)
	die()

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

/obj/item/clothing/mask/cigarette/proc/light(mob/living/user, mob/living/target)
	if(lit)
		return

	lit = TRUE
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
			M.drop_item_to_ground(src, force = TRUE)
		qdel(src)
		return

	// Fuel explodes, too, but much less violently.
	if(reagents.get_reagent_amount("fuel"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(M))
			M.drop_item_to_ground(src, force = TRUE)
		qdel(src)
		return

	// If there is no target, the user is probably lighting their own cig.
	if(isnull(target))
		target = user

	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(C.wear_mask == src) // Don't update if it's just in their hand
			C.wear_mask_update(src)
	set_light(2, 0.25, "#E38F46")
	update_appearance(UPDATE_NAME|UPDATE_ICON)
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
		location.hotspot_expose(700, 1)
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
	var/obj/item/butt = new butt_type(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		// Only put the butt in the user's mouth if there's already a cig there.
		if(M.wear_mask == src)
			M.drop_item_to_ground(src, force = TRUE) //Force the un-equip so the overlays update
			butt.slot_flags |= ITEM_SLOT_MASK // Temporarily allow it to go on masks
			M.equip_to_slot_if_possible(butt, ITEM_SLOT_MASK)
			butt.slot_flags &= ~ITEM_SLOT_MASK
		else
			M.drop_item_to_ground(src, force = TRUE)

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
	list_reagents = list("nicotine" = 40, pick("fuel", "saltpetre", "synaptizine", "green_vomit", "potass_iodide", "msg", "lexorin", "mannitol", \
	"spaceacillin" ,"cryoxadone" ,"holywater", "tea" ,"egg" ,"haloperidol" ,"mutagen" ,"omnizine", "carpet", "aranesp", "cryostylane", "chocolate", \
	"bilk", "cheese", "rum", "blood", "charcoal", "coffee", "ectoplasm", "space_drugs", "milk", "mutadone", "antihol", "teporone", "insulin", "salbutamol", "toxin") = 20)
	..()

/obj/item/clothing/mask/cigarette/candy
	name = "candy cigarette"
	desc = "A stick of candy imitating a real cigarette. The words 'do not expose to heat' are written in very small letters around the base."

/obj/item/clothing/mask/cigarette/candy/interact_with_atom(atom/A, mob/living/user, list/modifiers)
	if(..())
		return

	if(!ishuman(A))
		return

	var/mob/living/carbon/human/target = A
	if(target != user)
		user.visible_message(
			"<span_class='notice'>You begin to feed [target] [src].</span>",
			"<span_class='warning'>[user] begins to feed [target] [src]!</span>"
		)
		if(!do_after(user, 5 SECONDS, target = target))
			return ITEM_INTERACT_COMPLETE

	else
		to_chat(user, "<span_class='notice'>You eat [src].</span>")

	playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)

	// A SPICY candy!
	if(lit)
		target.adjust_nutrition(2)
		target.reagents.add_reagent("sugar", 2, reagtemp = 373)
		target.reagents.add_reagent("ash", 3, reagtemp = 373)
		target.reagents.add_reagent("nicotine", 3, reagtemp = 373)
		var/obj/item/organ/external/head/target_head = target.get_organ("head")
		if(target_head.receive_damage(0, 15)) // OH GOD IT BURNS WHY DID I EAT THIS!?
			target.UpdateDamageIcon()
			to_chat(target, "<span_class='notice'>You can taste burnt sugar, ash, burning chemicals, and your own burning flesh...</span>")
			to_chat(target, "<span_class='userdanger'>OH FUCK! IT BURNS!</span>")
			target.emote("scream")
		add_attack_logs(user, target, "Fed a burning candy cigarette.")
	else
		target.adjust_nutrition(5)
		target.reagents.add_reagent("sugar", 5)
		to_chat(target, "<span_class='notice'>You can taste sugar, and a hint of chemicals.</span>")

	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/mask/cigarette/syndicate
	name = "suspicious cigarette"
	desc = "An evil-looking cigarette. It smells of donk pockets."
	icon_state = "syndie_cig"
	butt_type = /obj/item/cigbutt/syndie
	list_reagents = list("nicotine" = 40, "omnizine" = 20)

/obj/item/clothing/mask/cigarette/medical_marijuana
	name = "medical marijuana cigarette"
	desc = "A cigarette containing specially-bread cannabis that has been engineered to only contain CBD, for medical use. The lack of THC makes it fully legal under Space Law."
	icon_state = "medical_weed_cig"
	list_reagents = list("cbd" = 60)

/obj/item/clothing/mask/cigarette/robustgold
	name = "\improper Robust Gold cigarette"
	desc = "A premium cigarette smoked by the truly robust, contains real gold."
	list_reagents = list("nicotine" = 40, "gold" = 1)

/obj/item/clothing/mask/cigarette/shadyjims
	list_reagents = list("nicotine" = 40, "lipolicide" = 7.5, "ammonia" = 2, "atrazine" = 1, "toxin" = 1.5)

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper. It carries the unmistakable smell of cannabis."
	icon_state = "spliff"
	butt_type = /obj/item/cigbutt/roach
	list_reagents = list("thc" = 40, "cbd" = 20)

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	. = ..()
	scatter_atom()

/obj/item/clothing/mask/cigarette/rollie/custom
	desc = "A roll of dried plant matter wrapped in thin paper."
	list_reagents = list()

/obj/item/clothing/mask/cigarette/carcinoma
	name = "\improper Carcinoma Angel cigarette"
	desc = "A truly evil looking cigarette. The smell of tobacco is so overpowering that you can practically feel the cancer forming inside you already."
	icon_state = "death_cig"
	butt_type = /obj/item/cigbutt/death

/obj/item/clothing/mask/cigarette/carcinoma/New()
	list_reagents = list("nicotine" = 40, "dnicotine" = 10, pick("carpotoxin", "toxin", "atrazine") = 1)
	..()

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/smoking.dmi'
	icon_state = "cig_butt"
	w_class = WEIGHT_CLASS_TINY
	scatter_distance = 10

/obj/item/cigbutt/syndie
	name = "suspicious cigarette butt"
	desc = "A manky old cigarette butt with an evil look about it."
	icon_state = "syndie_cig_butt"

/obj/item/cigbutt/death
	name = "dark cigarette butt"
	desc = "A manky old cigarette butt, it did its part in the job of killing someone's lungs."
	icon_state = "death_cig_butt"

/obj/item/cigbutt/Initialize(mapload)
	. = ..()
	scatter_atom()
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
	scatter_distance = 5

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	scatter_atom()

//////////////////////////////
// MARK: ROLLING
//////////////////////////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE

/obj/item/rollingpaper/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/food/grown))
		return ..()

	var/obj/item/food/grown/plant = used
	if(!plant.dry)
		to_chat(user, "<span class='warning'>You need to dry this first!</span>")
		return ITEM_INTERACT_COMPLETE

	user.unequip(src, TRUE)
	var/obj/item/clothing/mask/cigarette/rollie/custom/custom_rollie = new (get_turf(user))
	// Don't stuff the entire tin into a single cig, you barbarian!
	if(istype(used, /obj/item/food/grown/tobacco/pre_dried))
		custom_rollie.desc = "Dried tobacco rolled up in a thin piece of paper."
		if(plant.reagents.total_volume > custom_rollie.chem_volume)
			to_chat(user, "<span class='notice'>You pour some of [plant] into a rolling paper.</span>")
			plant.reagents.trans_to(custom_rollie, 40)
			plant.update_appearance(UPDATE_ICON)
		else
			to_chat(user, "<span class='notice'>You empty [plant] into a rolling paper.</span>")
			plant.reagents.trans_to(custom_rollie, plant.reagents.total_volume)
			user.unequip(plant, TRUE)
			qdel(plant)
			user.put_in_active_hand(new /obj/item/trash/tobacco_tin)
	else
		user.unequip(plant, TRUE)
		custom_rollie.reagents.maximum_volume = plant.reagents.total_volume
		plant.reagents.trans_to(custom_rollie, plant.reagents.total_volume)
		to_chat(user, "<span class='notice'>You roll the [plant.name] into a rolling paper.</span>")
		custom_rollie.desc = "Dried [plant.name] rolled up in a thin piece of paper."
		qdel(plant)
	custom_rollie.smoketime = custom_rollie.reagents.total_volume * REAGENT_TIME_RATIO
	user.put_in_hands(custom_rollie)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/food/grown/tobacco/pre_dried
	name = "\improper King's Own tobacco"
	desc = "A tin of loose-leaf tobacco for filling pipes and hand-rolled cigarettes."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "pipe_tobacco"
	seed = null
	trash = /obj/item/trash/tobacco_tin
	dry = TRUE
	tastes = list("tobacco" = 1, "herbs" = 2, "spices" = 2)
	volume = 240
	list_reagents = list("nicotine" = 240) // One of these has to fill an entire pipe. This is also the same nicotine found in a pack of 6 normal cigarettes.

/obj/item/food/grown/tobacco/pre_dried/examine_more(mob/user)
	. = ..()
	. += "A unique verity of hardy, arid tobacco grown on the Vulpkanin world of Strend in the Kelunian system. \
	The strain was developed from varieties imported from Kelune by the first colonists, and is now considered a luxury brand."
	. += ""
	. += "Sun-dried, finely shredded, and infused with herbs and spices; it has a pleasant but difficult to pin down flavor.\
	Whilst intended for use in pipes or hand-rolled cigarettes, some have been known to use it as dip or snuff."

/obj/item/food/grown/tobacco/pre_dried/On_Consume(mob/M, mob/user)
	update_icon(UPDATE_ICON_STATE)
	..()

/obj/item/food/grown/tobacco/pre_dried/update_icon_state()
	. = ..()
	if(reagents.total_volume < 240)
		icon_state = "pipe_tobacco_open"

/obj/item/trash/tobacco_tin
	name = "empty tobacco tin"
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "pipe_tobacco_empty"

//////////////////////////////
// MARK: CIGARS
//////////////////////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "\improper Nano Cigar"
	desc = "A huge, brown roll of dried and fermented tobacco, manufactured by Nanotrasen's Robust Tobacco subsidiary."
	icon_state = "cigar"
	fancy_lighters = list(/obj/item/match, /obj/item/lighter/zippo)
	butt_type = /obj/item/cigbutt/cigarbutt
	smoketime = 300
	chem_volume = 140
	list_reagents = list("nicotine" = 120)

/obj/item/clothing/mask/cigarette/cigar/examine_more(mob/user)
	. = ..()
	. += "Don't let the advertising fool you, this thing is a bargain basement, bottom-of-the-barrel product and the smoking experience it offers is little better than an oversized Robust cigarette."
	. += ""
	. += "It still makes you look like a mafia boss, however."

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto Cigar"
	desc = "A premium brand of cigar widely exported and enjoyed across the Orion Sector. There's little more that you could want from a cigar"
	icon_state = "gold_cigar"
	butt_type = /obj/item/cigbutt/cigarbutt/gold

/obj/item/clothing/mask/cigarette/cigar/cohiba/examine_more(mob/user)
	..()
	. = list()
	. += "Lovingly machine rolled using carefully selected strains of tobacco grown in massive hydroponics warehouses in orbit around the death world of Venus, Sol. \
	It goes through a range of carefully selected flavours as it is smoked, providing a novel and enjoyable experience throughout."

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "\improper Premium Havanian Cigar"
	desc = "A luxury cigar imported straight from Sol. Only fit for the best of the best. You feel badass merely glimpsing it..."
	icon_state = "gold_cigar"
	smoketime = 450
	chem_volume = 200
	list_reagents = list("nicotine" = 180)
	butt_type = /obj/item/cigbutt/cigarbutt/gold

/obj/item/clothing/mask/cigarette/cigar/havana/examine_more(mob/user)
	..()
	. = list()
	. += "One of a handful of brands made using tobacco grown in Cuba on Earth, the core of the Trans-Solar Federation. \
	Each of these hand-rolled cigars is carefully put together by master cigar rollers using various strains of tobacco that has been cultivated for hundreds of years to ensure \
	the best consistency and flavour possible."
	. += ""
	. += "Due to a mixture of limited manufacturing capacity, high quality, brand prestige, and export taxes, \
	these cigars are too expensive for all but the most wealthy to smoke with any degree of regularity."

/obj/item/clothing/mask/cigarette/cigar/havana/equipped(mob/user, slot, initial)
	. = ..()
	if(lit && slot == ITEM_SLOT_MASK)
		grant_badass(user)

/obj/item/clothing/mask/cigarette/cigar/havana/light(mob/living/user)
	..()
	if(!HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
		grant_badass(user)

/obj/item/clothing/mask/cigarette/cigar/havana/proc/grant_badass(mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
		ADD_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR)
		to_chat(user, "<span class='notice'>You feel more badass while smoking [src].</span>")

/obj/item/clothing/mask/cigarette/cigar/havana/dropped(mob/user, silent)
	. = ..()
	if(HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
		REMOVE_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR)
		to_chat(user, "<span class='notice'>You feel less badass.</span>")

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigar_butt"

/obj/item/cigbutt/cigarbutt/gold
	icon_state = "gold_cigar_butt"

//////////////////////////////
// MARK: HOLO-CIGAR
//////////////////////////////
/obj/item/clothing/mask/holo_cigar
	name = "holo-cigar"
	desc = "A sleek electronic cigar imported straight from Sol. You feel badass merely glimpsing it..."
	icon = 'icons/obj/clothing/smoking.dmi'
	icon_state = "holo_cigar"
	lefthand_file = 'icons/mob/inhands/smoking_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/smoking_righthand.dmi'
	new_attack_chain = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi')
	/// Is the holo-cigar lit?
	var/enabled = FALSE
	/// Tracks if this is the first cycle smoking the cigar.
	var/has_smoked = FALSE

/obj/item/clothing/mask/holo_cigar/activate_self(mob/user)
	if(..())
		return

	if(enabled)
		enabled = FALSE
		to_chat(user, "<span class='notice'>You disable the holo-cigar.</span>")
		STOP_PROCESSING(SSobj, src)
	else
		enabled = TRUE
		to_chat(user, "<span class='notice'>You enable the holo-cigar.</span>")
		START_PROCESSING(SSobj, src)

	update_appearance(UPDATE_NAME|UPDATE_ICON)

/obj/item/clothing/mask/holo_cigar/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/holo_cigar/update_icon_state()
	. = ..()
	icon_state = "holo_cigar[enabled ? "_on" : ""]"

/obj/item/clothing/mask/holo_cigar/update_name()
	. = ..()
	name = "[enabled ? "active " : ""]holo-cigar"

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
	if(enabled && slot == ITEM_SLOT_MASK)
		if(!HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
			ADD_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR)
			to_chat(user, "<span class='notice'>You feel more badass while smoking [src].</span>")

/obj/item/clothing/mask/holo_cigar/dropped(mob/user, silent)
	. = ..()
	has_smoked = FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR))
		REMOVE_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR)
		to_chat(user, "<span class='notice'>You feel less badass.</span>")

//////////////////////////////
// MARK: PIPES
//////////////////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A fancy smoking pipe carved from polished morta, otherwise known as bog wood. Preferred by sophisticated gentlemen and those posing as sophisticated gentlemen."
	icon_state = "pipe"
	fancy_lighters = list(/obj/item/match, /obj/item/lighter/zippo)
	smoketime = 500
	chem_volume = 220
	list_reagents = list("nicotine" = 200)

/obj/item/clothing/mask/cigarette/pipe/activate_self(mob/user)
	if(..())
		return

	if(lit)
		extinguish_cigarette(user)

/obj/item/clothing/mask/cigarette/pipe/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/food/grown))
		return ..()

	var/obj/item/food/grown/filler = used
	if(!filler.dry)
		to_chat(user, "<span class='warning'>You need to dry this first!</span>")
		return ITEM_INTERACT_COMPLETE

	if(reagents.total_volume == reagents.maximum_volume)
		to_chat(user, "<span class='warning'>[src] is full!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/food/grown/tobacco/pre_dried))
		to_chat(user, "<span class='notice'>You empty [filler] into the pipe.</span>")
		if((chem_volume - reagents.total_volume) >= filler.reagents.total_volume)
			filler.reagents.trans_to(src, chem_volume)
			user.unequip(filler, TRUE)
			qdel(filler)
			user.put_in_active_hand(new /obj/item/trash/tobacco_tin)
		else
			to_chat(user, "<span class='notice'>You pour some of [filler] into the pipe.</span>")
			filler.reagents.trans_to(src, clamp(filler.reagents.total_volume, 0, (chem_volume - reagents.total_volume)))
			filler.update_icon(UPDATE_ICON_STATE)
	else
		to_chat(user, "<span class='notice'>You stuff the [filler.name] into the pipe.</span>")
		filler.reagents.trans_to(src, chem_volume)
		qdel(filler)

	smoketime = max(reagents.total_volume * REAGENT_TIME_RATIO, smoketime)
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/mask/cigarette/pipe/light()
	if(!lit)
		lit = TRUE
		damtype = "fire"
		update_appearance(UPDATE_NAME|UPDATE_ICON)
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
		update_appearance(UPDATE_NAME|UPDATE_ICON)
		STOP_PROCESSING(SSobj, src)
		return

	smoke()

/obj/item/clothing/mask/cigarette/pipe/extinguish_cigarette(mob/user)
	user.visible_message(
		"<span class='notice'>[user] puts out [src].</span>",
		"<span class='notice'>You put out [src].</span>"
	)
	lit = FALSE
	first_puff = TRUE
	update_appearance(UPDATE_NAME|UPDATE_ICON)
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/cigarette/pipe/die()
	return

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cob_pipe"
	smoketime = 0 //there is nothing to smoke initially
	chem_volume = 160
	list_reagents = list()

#undef REAGENT_TIME_RATIO
