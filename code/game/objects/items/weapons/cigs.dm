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
	throw_speed = 0.5
	item_state = "cigoff"
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
	/// What trash item the cigarette makes when it burns out.
	var/type_butt = /obj/item/cigbutt
	/// How long does the cigarette last before going out?
	var/smoketime = 150
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
			light("<span class='notice'>[user] coldly lights [src] with the burning body of [M]. Clearly, [user.p_they()] offer[user.p_s()] the warmest of regards...</span>")
		else
			// The fire will light it in your hands by itself, but if you whip out the cig and click yourself fast enough, this will happen. TRULY you have your priorities stright.
			light("<span class='notice'>[user] quickly whips out [src] and nonchalantly lights it with [user.p_their()] own burning body. Clearly, [user.p_they()] [user.p_have()] [user.p_their()] priorities straight...</span>")
		return TRUE

	if(istype(M) && user.zone_selected == "mouth" && !M.wear_mask)
		user.unEquip(src, TRUE)
		M.equip_to_slot_if_possible(src, SLOT_HUD_WEAR_MASK)
		if(M != user)
			user.visible_message(
				"<span class='notice'>[user] slips \a [name] into the mouth of [M].</span>",
				"<span class='notice'>You slip [src] into the mouth of [M].</span>"
					)
		else
			to_chat(user, "<span class='notice'>You put [src] into your mouth.</span>")
		return TRUE
	return ..()

/obj/item/clothing/mask/cigarette/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [initial(name)] while it's lit!</span>") // initial(name) so it doesn't say "lit" twice in a row
		return FALSE
	return TRUE

/obj/item/clothing/mask/cigarette/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	light()

/obj/item/clothing/mask/cigarette/catch_fire()
	if(!lit)
		light("<span class='warning'>[src] is lit by the flames!</span>")

/obj/item/clothing/mask/cigarette/proc/lighter_interaction(obj/item/I, mob/user, mob/living/carbon/target)
	if(lit)
		to_chat(user, "<span class='warning'>\The [initial(name)] is already lit!</span>")
		return FALSE
	
	if(!I.cigarette_lighter_act())
		return
	
	// Do not light cigars or pipes unless the lighting item is sufficiently cultured.
	if(!I.can_light_cigars && (istype(I, /obj/item/clothing/mask/cigarette/pipe) || istype(/obj/item/clothing/mask/cigarette/cigar)))
		user.visible_message(cigar_light_failure)
		return
	
	// If you screw up lighting the cig, do not light the cig.
	if(bad_outcome)
		return
	
	if(user == target)
		light(light_own_cig)
	else
		light(light_other_cig)
	
/*
	if(istype(I, /obj/item/lighter/zippo))
		var/obj/item/lighter/zippo/zip = I
		if(zip.lit)
			if(target == user)
				light("<span class='rose'>With a single flick of [user.p_their()] wrist, [user] smoothly lights [user.p_their()] [name] with [I]. Damn [user.p_theyre()] cool.</span>")
			else
				light("<span class='rose'>[user] whips [I] out and holds it for [target]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] lights [src] with. Damn [user.p_theyre()] cool.</span>")
			return TRUE
		return failed_to_light(I, user)

	if(istype(I, /obj/item/match))
		var/obj/item/match/Match = I
		if(Match.lit)
			if(target == user)
				light("<span class='notice'>[user] lights [user.p_their()] [name] with [I].</span>")
			else
				light("<span class='notice'>[user] holds [I] out for [target], and lights [src].</span>")
			return TRUE
		return failed_to_light(I, user)

	if(istype(src, /obj/item/clothing/mask/cigarette/cigar) || istype(src, /obj/item/clothing/mask/cigarette/pipe))
		// Cigars and pipes are too cultured to allow themselves to be lit by the BARBARIC means below.
		to_chat(user, "<span class='warning'>[src] straight out <b>REFUSES</b> to be lit by such uncivilized means!</span>")
		return FALSE

	if(istype(I, /obj/item/lighter))
		var/obj/item/lighter/light = I
		if(light.lit)
			if(target == user)
				light("<span class='notice'>After some fiddling, [user] manages to light [user.p_their()] [name] with [I].</span>")
			else
				light("<span class='notice'>After some fiddling, [user] manages to light [src] with [I] for [target].</span>")
			return TRUE
		return failed_to_light(I, user)

	if(istype(I, /obj/item/match/unathi))
		var/obj/item/match/unathi/liz_fire = I
		if(liz_fire.lit)
			if(target == user)
				light("<span class='rose'>[user] spits fire at [user.p_their()] [name], igniting it.</span>")
			else
				if(prob(50))
					light("<span class='rose'>[user] spits fire at [target], lighting [name] and nearly burning [target.p_their()] face!</span>")
				else
					light("<span class='rose'>[user] spits fire at [target], burning [target.p_their()] face and lighting [src] in the process!</span>")
					var/obj/item/organ/external/head/affecting = target.get_organ("head")
					affecting.receive_damage(0, 5)
					target.UpdateDamageIcon()
			playsound(user.loc, 'sound/effects/unathiignite.ogg', 40, FALSE)
			liz_fire.matchburnout()
			return TRUE
		return failed_to_light(I, user)

	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = I
		if(welder.tool_enabled)
			if(target == user)
				light("<span class='notice'>[user] casually lights [src] with [I], what a badass.</span>")
			else
				light("<span class='notice'>[user] holds out [I] out for [target], and casually lights [name]. What a badass.</span>")
			return TRUE
		return failed_to_light(I, user)

	if(istype(I, /obj/item/assembly/igniter))
		if(target == user)
			light("<span class='notice'>[user] presses [I] against [src], and activates it, lighting [user.p_their()] [name] in a shower of sparks!</span>")
		else
			light("<span class='notice'>[user] presses [I] against [src] in the mouth of [target], and activates it, lighting [target.p_their()] [name] in a shower of sparks!</span>")
		I.attack_self()	// Make sparks fly!
		return TRUE

	if(istype(I, /obj/item/cautery) || istype(I, /obj/item/scalpel/laser))
		if(target == user)
			light("<span class='notice'>[user] presses [I] against [user.p_their()] [name] until it lights.</span>")
		else
			light("<span class='notice'>[user] presses [I] against [src] in the mouth of [target] until it lights.</span>")
		return TRUE

	if(istype(I, /obj/item/pen/edagger) || istype(I, /obj/item/melee/energy))
		// The cleaving saw is an energy weapon and I hate it.
		if(istype(I, /obj/item/melee/energy/cleaving_saw))
			return FALSE
		var/obj/item/pen/edagger/dagger = I
		var/obj/item/melee/energy/sword = I
		if(dagger.active || sword.active)
			if(target == user)
				light("<span class='warning'>[user] makes a violent slashing motion, barely missing [user.p_their()] nose as light flashes. \
				[user.p_they(TRUE)] lights [user.p_their()] [name] with [I] in the process.</span>")
			else
				light("<span class='warning'>[user] makes a violent slashing motion, barely missing the nose of [target] as light flashes. \
				[user.p_they(TRUE)] lights [src] in the mouth of [target] with [I] in the process.</span>")
			return TRUE
		return failed_to_light(I, user)

	if(istype(I, /obj/item/gun/magic/wand/fireball))
		var/obj/item/gun/magic/wand/fireball/fireball = I
		if(fireball.charges)
			if(prob(50) || user.mind.assigned_role == "Wizard")
				if(target == user)
					light("<span class='warning'>Holy shit! Did [user] just manage to light [user.p_their()] [name] with [I], with only moderate eyebrow singing!?</span>")
				else
					light("<span class='warning'>Holy shit! Did [user] just manage to light [src] in the mouth of [target] with [I], only moderately singing [target.p_their()] eyebrows!?</span>")
				return TRUE

			user.visible_message("<span class='danger'>Unsure which end of [I] is which, [user] fails to light [src].</span>")
			explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
			fireball.charges--
			return FALSE
		
	if(istype(I, /obj/item/storm_staff))
		if(target == user)
			light("<span class='warning'>[user] holds [I] up to [user.p_their()] [name] and shoots a tiny bolt of lightning that sets it alight!</span>")
		else
			light("<span class='warning'>[user] points [I] at [target] and shoots a tiny bolt of lightning that sets [target.p_their()] [name] alight!</span>")
		playsound(target, 'sound/magic/lightningbolt.ogg', 20, TRUE)
		return TRUE
*/

/obj/item/clothing/mask/cigarette/proc/failed_to_light(obj/item/I, mob/living/user)
	to_chat(user, "<span class='warning'>You need to turn on [I] before you can use it as a lighter!</span>")
	return FALSE

/obj/item/clothing/mask/cigarette/attackby(obj/item/I, mob/user, mob/living/carbon/M, params)
	// If the cig is being clicked directly, we treat it as the user's cig.
	if(!ismob(M))
		M = user
	if(lighter_interaction(I, user, M) == TRUE)
		user.update_inv_wear_mask()
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	..()

/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity)
	..()
	if(!proximity)
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")

/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(!lit)
		lit = TRUE
		name = "lit [name]"
		attack_verb = list("burnt", "singed")
		hitsound = 'sound/items/welder.ogg'
		damtype = "fire"
		force = 4
		var/mob/M = loc
		if(reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
			var/datum/effect_system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			if(ismob(M))
				M.unEquip(src, TRUE)
			qdel(src)
			return
		if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
			var/datum/effect_system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
			e.start()
			if(ismob(M))
				M.unEquip(src, TRUE)
			qdel(src)
			return
		reagents.set_reacting(TRUE)
		reagents.handle_reactions()
		icon_state = icon_on
		item_state = icon_on
		if(flavor_text)
			M.visible_message(flavor_text)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if(C.wear_mask == src) // Don't update if it's just in their hand
				C.wear_mask_update(src)
		set_light(2, 0.25, "#E38F46")
		START_PROCESSING(SSobj, src)
		playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)

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

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on [src], putting it out instantly.</span>")
		die()
	return ..()

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

/obj/item/clothing/mask/cigarette/proc/can_light_fancy(obj/item/lighting_item)
	return (istype(lighting_item, /obj/item/match) || istype(lighting_item, /obj/item/lighter/zippo))

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
	list_reagents = list("thc" = 40, "cbd" = 20)

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

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/custom
	list_reagents = list()


/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

//////////////////////////////
// MARK: CIGARS
//////////////////////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "\improper Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
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

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/cigbutt/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/cigbutt/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

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
	smoketime = 500
	chem_volume = 200
	list_reagents = list("nicotine" = 200)

/obj/item/clothing/mask/cigarette/pipe/die()
	return

/obj/item/clothing/mask/cigarette/pipe/light(flavor_text = null)
	if(!lit)
		lit = TRUE
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
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
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		lit = FALSE
		first_puff = TRUE
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return

// Refill the pipe
/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/snacks/grown))
		var/obj/item/food/snacks/grown/O = I
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
	if(istype(target, /obj/item/food/snacks/grown))
		var/obj/item/food/snacks/grown/O = target
		if(O.dry)
			user.unEquip(target, TRUE)
			user.unEquip(src, TRUE)
			var/obj/item/clothing/mask/cigarette/rollie/custom/R = new /obj/item/clothing/mask/cigarette/rollie/custom(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>You roll the [target.name] into a rolling paper.</span>")
			R.desc = "Dried [target.name] rolled up in a thin piece of paper."
			qdel(target)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to dry this first!</span>")
	else
		..()

#undef REAGENT_TIME_RATIO
