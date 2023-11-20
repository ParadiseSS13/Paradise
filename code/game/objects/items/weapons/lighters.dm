// Basic lighters
/obj/item/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/lighter_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lighter_righthand.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 4
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	attack_verb = null
	resistance_flags = FIRE_PROOF
	var/lit = FALSE
	/// Cooldown until the next turned on message/sound can be activated
	var/next_on_message
	/// Cooldown until the next turned off message/sound can be activated
	var/next_off_message

/obj/item/lighter/random/New()
	..()
	var/color = pick("r","c","y","g")
	icon_state = "lighter-[color]"

/obj/item/lighter/attack_self(mob/living/user)
	. = ..()
	if(!lit)
		turn_on_lighter(user)
	else
		turn_off_lighter(user)

/obj/item/lighter/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	else
		return TRUE

/obj/item/lighter/proc/turn_on_lighter(mob/living/user)
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY
	force = 5
	damtype = BURN
	hitsound = 'sound/items/welder.ogg'
	attack_verb = list("burnt", "singed")

	update_icon()
	attempt_light(user)
	set_light(2)
	START_PROCESSING(SSobj, src)

/obj/item/lighter/proc/attempt_light(mob/living/user)
	if(prob(75) || issilicon(user)) // Robots can never burn themselves trying to light it.
		to_chat(user, "<span class='notice'>You light [src].</span>")
	else if(HAS_TRAIT(user, TRAIT_BADASS))
		to_chat(user, "<span class='notice'>[src]'s flames lick your hand as you light it, but you don't flinch.</span>")
	else
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
		if(affecting.receive_damage(0, 5))		//INFERNO
			H.UpdateDamageIcon()
		to_chat(user,"<span class='notice'>You light [src], but you burn your hand in the process.</span>")
	if(world.time > next_on_message)
		playsound(src, 'sound/items/lighter/plastic_strike.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS

/obj/item/lighter/proc/turn_off_lighter(mob/living/user)
	lit = FALSE
	w_class = WEIGHT_CLASS_TINY
	hitsound = "swing_hit"
	force = 0
	attack_verb = null //human_defense.dm takes care of it

	update_icon()
	if(user)
		show_off_message(user)
	set_light(0)
	STOP_PROCESSING(SSobj, src)

/obj/item/lighter/extinguish_light(force)
	if(!force)
		return
	turn_off_lighter()

/obj/item/lighter/proc/show_off_message(mob/living/user)
	to_chat(user, "<span class='notice'>You shut off [src].")
	if(world.time > next_off_message)
		playsound(src, 'sound/items/lighter/plastic_close.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS

/obj/item/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!isliving(M))
		return
	M.IgniteMob()
	if(!ismob(M))
		return

	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_selected == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/lighter/zippo))
				cig.light("<span class='rose'>[user] whips [src] out and holds it for [M]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds [src] out for [M], and lights [cig].</span>")
			playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
			M.update_inv_wear_mask()
	else
		..()

/obj/item/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)
	return

/obj/item/lighter/update_icon_state()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	return ..()

/obj/item/lighter/update_overlays()
	item_state = "[initial(item_state)][lit ? "-on" : ""]"
	return ..()

// Zippo lighters
/obj/item/lighter/zippo
	name = "zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"

/obj/item/lighter/zippo/turn_on_lighter(mob/living/user)
	. = ..()
	if(world.time > next_on_message)
		user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
		playsound(src.loc, 'sound/items/zippolight.ogg', 25, 1)
		next_on_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You light [src].</span>")

/obj/item/lighter/zippo/turn_off_lighter(mob/living/user)
	. = ..()
	if(!user)
		return

	if(world.time > next_off_message)
		user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow.")
		playsound(src.loc, 'sound/items/zippoclose.ogg', 25, 1)
		next_off_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You shut off [src].")

/obj/item/lighter/zippo/show_off_message(mob/living/user)
	return

/obj/item/lighter/zippo/attempt_light(mob/living/user)
	return

//EXTRA LIGHTERS
/obj/item/lighter/zippo/nt_rep
	name = "gold engraved zippo"
	desc = "An engraved golden Zippo lighter with the letters NT on it."
	icon_state = "zippo-nt"
	item_state = "zippo-gold"

/obj/item/lighter/zippo/blue
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon_state = "zippo-blue"
	item_state = "zippo-blue"

/obj/item/lighter/zippo/black
	name = "black zippo lighter"
	desc = "A black zippo lighter."
	icon_state = "zippo-black"
	item_state = "zippo-black"

/obj/item/lighter/zippo/engraved
	name = "engraved zippo lighter"
	desc = "A intricately engraved zippo lighter."
	icon_state = "zippo-engraved"

/obj/item/lighter/zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon_state = "zippo-gonzo"
	item_state = "zippo-red"

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1"
	attack_verb = null

/obj/item/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		matchburnout()
	if(location)
		location.hotspot_expose(700, 5)
		return

/obj/item/match/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	matchignite()

/obj/item/match/extinguish_light(force)
	if(!force)
		return
	matchburnout()

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		lit = TRUE
		icon_state = "match_lit"
		damtype = "fire"
		force = 3
		hitsound = 'sound/items/welder.ogg'
		item_state = "cigon"
		name = "lit match"
		desc = "A match. This one is lit."
		attack_verb = list("burnt","singed")
		START_PROCESSING(SSobj, src)
		update_icon()
		return TRUE

/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		damtype = "brute"
		force = initial(force)
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt match"
		desc = "A match. This one has seen better days."
		attack_verb = list("flicked")
		STOP_PROCESSING(SSobj, src)
		return TRUE

/obj/item/match/dropped(mob/user)
	matchburnout()
	. = ..()

/obj/item/match/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [initial(name)] while it's lit!</span>") // initial(name) so it doesn't say "lit" twice in a row
		return FALSE
	else
		return TRUE

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!isliving(M))
		return ..()
	if(lit && M.IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(M)] on fire")
		log_game("[key_name(user)] set [key_name(M)] on fire")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.a_intent == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='notice'>[cig] is already lit.</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/match/unathi))
				if(prob(50))
					cig.light("<span class='rose'>[user] spits fire at [M], lighting [cig] and nearly burning [user.p_their()] face!</span>")
					matchburnout()
				else
					cig.light("<span class='rose'>[user] spits fire at [M], burning [user.p_their()] face and lighting [cig] in the process.</span>")
					var/obj/item/organ/external/head/affecting = M.get_organ("head")
					affecting.receive_damage(0, 5)
					M.UpdateDamageIcon()
				playsound(user.loc, 'sound/effects/unathiignite.ogg', 40, FALSE)

			else
				cig.light("<span class='notice'>[user] holds [src] out for [M], and lights [cig].</span>")
			playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	else
		..()

/obj/item/match/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user) && burnt)
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(SLOT_HUD_WEAR_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/firebrand
	name = "firebrand"
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 20 //40 seconds

/obj/item/match/firebrand/New()
	..()
	matchignite()

/obj/item/match/unathi
	name = "small blaze"
	desc = "A little flame of your own, currently located dangerously in your mouth."
	icon_state = "match_unathi"
	attack_verb = null
	force = 0
	flags = DROPDEL | ABSTRACT
	origin_tech = null
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY //to prevent it going to pockets

/obj/item/match/unathi/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/match/unathi/matchburnout()
	if(!lit)
		return
	lit = FALSE //to avoid a qdel loop
	qdel(src)

/obj/item/match/unathi/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
