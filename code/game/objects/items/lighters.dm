// MARK: LIGHTERS
/obj/item/lighter
	name = "cheap lighter"
	desc = "A cheap cigarette lighter. It gets the job done, barely."
	icon = 'icons/obj/lighter.dmi'
	lefthand_file = 'icons/mob/inhands/lighter_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lighter_righthand.dmi'
	icon_state = "lighter-g"
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	attack_verb = null
	resistance_flags = FIRE_PROOF
	var/lit = FALSE
	/// Cooldown until the next turned on message/sound can be activated
	var/next_on_message
	/// Cooldown until the next turned off message/sound can be activated
	var/next_off_message
	/// Our lighter color suffix. => `[base_icon_state]-[lightercolor]` => `lighter-r`
	var/lighter_color
	var/is_a_zippo = FALSE

/obj/item/lighter/random
	base_icon_state = "lighter"

/obj/item/lighter/random/Initialize(mapload)
	. = ..()
	lighter_color = pick("r","c","y","g")
	update_icon()

/obj/item/lighter/attack_self__legacy__attackchain(mob/living/user)
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
	damtype = initial(damtype)
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

/obj/item/lighter/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(cigarette_lighter_act(user, target))
		return

	if(lit && target.IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(target)] on fire")
		log_game("[key_name(user)] set [key_name(target)] on fire")

	return ..()

/obj/item/lighter/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	// Otherwise the later parts of this proc can be passed to the zippo and cause a runtime.
	if(is_a_zippo)
		return cig

	if(!cig)
		return !isnull(cig)

	if(!lit)
		to_chat(user, "<span class='warning'>You need to light [src] before it can be used to light anything!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='notice'>After some fiddling, [user] manages to light [user.p_their()] [cig] with [src].</span>",
			"<span class='notice'>After some fiddling, you manage to light [cig] with [src].</span>,"
		)
	else
		user.visible_message(
			"<span class='notice'>After some fiddling, [user] manages to light [cig] for [target] with [src].</span>",
			"<span class='notice'>After some fiddling, you manage to light [cig] for [target] with [src].</span>"
		)
	cig.light(user, target)
	return TRUE

/obj/item/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 1)
	return

/obj/item/lighter/update_icon_state()
	icon_state = "[base_icon_state ? "[base_icon_state]" : initial(icon_state)][lighter_color ? "-[lighter_color]" : ""][lit ? "-on" : ""]"

/obj/item/lighter/update_overlays()
	inhand_icon_state = "[base_icon_state ? "[base_icon_state]" : initial(inhand_icon_state)][lighter_color ? "-[lighter_color]" : ""][lit ? "-on" : ""]"

/obj/item/lighter/get_heat()
	return lit * 1500

//  ZIPPO LIGHTERS

/obj/item/lighter/zippo
	name = "zippo lighter"
	desc = "A premium cigarette lighter, for cool and distinguished individuals."
	icon_state = "zippo"
	inhand_icon_state = "zippo"
	is_a_zippo = TRUE
	throwforce = 4

/obj/item/lighter/zippo/turn_on_lighter(mob/living/user)
	. = ..()
	if(world.time > next_on_message)
		user.visible_message(
			"<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>",
			"<span class='rose'>Without breaking your stride, you flip open and light [src] in one smooth movement.</span>",
			"<span class='rose'>You hear a zippo being lit.</span>"
		)
		playsound(src.loc, 'sound/items/zippolight.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You light [src].</span>")

/obj/item/lighter/zippo/turn_off_lighter(mob/living/user)
	. = ..()
	if(!user)
		return

	if(world.time > next_off_message)
		user.visible_message(
			"<span class='rose'>You hear a quiet click as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow.</span>",
			"<span class='rose'>You shut off [src] without even looking at what you're doing.</span>",
			"<span class='rose'>You hear a quiet click as a zippo lighter is shut off. Wow.</span>"
		)
		playsound(loc, 'sound/items/zippoclose.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You shut off [src].</span>")

/obj/item/lighter/zippo/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!lit)
		to_chat(user, "<span class='warning'>You need to light [src] before it can be used to light anything!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='rose'>With a single flick of [user.p_their()] wrist, [user] smoothly lights [user.p_their()] [cig.name] with [src]. Damn [user.p_theyre()] cool.</span>",
			"<span class='rose'>With a single flick of your wrist, you smoothly light [cig] with [src].</span>"
		)
	else
		user.visible_message(
			"<span class='rose'>[user] whips [src] out and holds it for [target]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light [cig] with. Damn [user.p_theyre()] cool.</span>",
			"<span class='rose'>You whip [src] out and hold it for [target]. Your arm is as steady as the unflickering flame you light [cig] with.</span>"
		)
	cig.light(user, target)
	return TRUE

/obj/item/lighter/zippo/show_off_message(mob/living/user)
	return

/obj/item/lighter/zippo/attempt_light(mob/living/user)
	return

/obj/item/lighter/zippo/nt_rep
	name = "gold engraved zippo"
	desc = "A golden Zippo lighter with the letter \"N\" engraved on the front."
	icon_state = "zippo-nt"
	inhand_icon_state = "zippo-gold"

/obj/item/lighter/zippo/blue
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon_state = "zippo-blue"
	inhand_icon_state = "zippo-blue"

/obj/item/lighter/zippo/black
	name = "black zippo lighter"
	desc = "A black zippo lighter."
	icon_state = "zippo-black"
	inhand_icon_state = "zippo-black"

/obj/item/lighter/zippo/engraved
	name = "engraved zippo lighter"
	desc = "A intricately engraved zippo lighter."
	icon_state = "zippo-engraved"

/obj/item/lighter/zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon_state = "zippo-gonzo"
	inhand_icon_state = "zippo-red"

// MARK: MATCHES

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
	var/is_unathi_fire = FALSE
	scatter_distance = 10

/obj/item/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		matchburnout()
	if(location)
		location.hotspot_expose(700, 1)
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
		inhand_icon_state = "cig_on"
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
		inhand_icon_state = "cig_off"
		name = "burnt match"
		desc = "A match. This one has seen better days."
		attack_verb = list("flicked")
		STOP_PROCESSING(SSobj, src)
		scatter_atom()
		transform = turn(transform, rand(0, 360))
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

/obj/item/match/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(cigarette_lighter_act(user, target))
		return

	if(lit && target.IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(target)] on fire")
		log_game("[key_name(user)] set [key_name(target)] on fire")

	return ..()

/obj/item/match/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()

	// Otherwise the later parts of this proc can be passed to the unathi's blaze and cause a runtime.
	if(is_unathi_fire)
		return cig

	if(!cig)
		return !isnull(cig)

	if(!lit)
		to_chat(user, "<span class='warning'>You need to light [src] before it can be used to light anything!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='notice'>[user] lights [user.p_their()] [cig] with [src].</span>",
			"<span class='notice'>You light [cig] with [src].</span>"
		)
	else
		user.visible_message(
			"<span class='notice'>[user] holds [src] out for [target], and lights [cig].</span>",
			"<span class='notice'>You hold [src] out for [target], and light [user.p_their()] [cig].</span>"
		)
	cig.light(user, target)
	matchburnout()
	return TRUE

/obj/item/match/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user) && burnt)
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/match/get_heat()
	return lit * 1000

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
	flags = DROPDEL | ABSTRACT
	origin_tech = null
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY //to prevent it going to pockets
	is_unathi_fire = TRUE

/obj/item/match/unathi/cigarette_lighter_act(mob/living/target, mob/living/user, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!lit)
		to_chat(user, "<span class='userdanger'>If you can see this message, please make an issue report to GitHub, something bad has happened.</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='rose'>[user] spits fire at [user.p_their()] [cig.name], igniting it.</span>",
			"<span class='rose'>You spit fire at [cig], igniting it.</span>",
			"<span class='warning'>You hear a brief burst of flame!</span>"
		)
	else
		if(prob(50))
			user.visible_message(
				"<span class='rose'>[user] spits fire at [target], lighting [cig] in [target.p_their()] mouth and nearly burning [target.p_their()] face!</span>",
				"<span class='rose'>You spit fire at [target], lighting [cig] in [target.p_their()] mouth and nearly burning [target.p_their()] face!</span>",
				"<span class='warning'>You hear a brief burst of flame!</span>"
			)
		else
			user.visible_message(
				"<span class='rose'>[user] spits fire at [target], burning [target.p_their()] face and lighting [cig] in the process!</span>",
				"<span class='rose'>You spit fire at [target], burning [target.p_their()] face and lighting [cig] in the process!</span>",
				"<span class='warning'>You hear a brief burst of flame!</span>"
			)
			var/obj/item/organ/external/head/affecting = target.get_organ("head")
			affecting.receive_damage(0, 5)
			target.UpdateDamageIcon()
	cig.light(user, target)
	playsound(user.loc, 'sound/effects/unathiignite.ogg', 40, FALSE)
	matchburnout()
	return TRUE

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
