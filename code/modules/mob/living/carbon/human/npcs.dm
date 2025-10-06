/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	worn_icon = 'icons/mob/clothing/under/misc.dmi'
	species_restricted = list("Monkey")
	species_exception = list(/datum/species/monkey)

/mob/living/carbon/human/monkey/punpun/Initialize(mapload)
	. = ..()
	name = "Pun Pun"
	real_name = name
	equip_to_slot(new /obj/item/clothing/under/punpun(src), ITEM_SLOT_JUMPSUIT)

/mob/living/carbon/human/monkey/teeny/Initialize(mapload)
	. = ..()
	name = "Mr. Teeny"
	real_name = name
	resize = 0.8
	update_transform()

/mob/living/carbon/human/monkey/magic
	/// Stores the timer ID of the timer that happens in Life() to prevent multiple of the same timer happening.
	var/return_timer

/mob/living/carbon/human/monkey/magic/Initialize(mapload)
	. = ..()
	var/headwear = pick(/obj/item/clothing/head/wizard, /obj/item/clothing/head/wizard/red, /obj/item/clothing/head/wizard/black)

	name = pick(GLOB.wizard_first)
	if(prob(20))
		name = "[name] [pick(GLOB.wizard_second)]"
	if(prob(0.1))
		name = "MERLIN THE MAGNIFICENT"
		headwear = /obj/item/clothing/head/wizard // he's gotta wear blue, ya know?
		resize = 2
		update_transform()
	real_name = name

	equip_to_slot_or_del(new headwear(src), ITEM_SLOT_HEAD)
	RegisterSignal(src, list(COMSIG_HUMAN_ATTACKED, COMSIG_HOSTILE_ATTACKINGTARGET), PROC_REF(ouch))

	for(var/trait in list(TRAIT_RESISTHEAT, TRAIT_NOBREATH, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE))
		ADD_TRAIT(src, trait, MAGIC_TRAIT)

/mob/living/carbon/human/monkey/magic/proc/ouch(mob/living/victim, mob/living/attacker)
	SIGNAL_HANDLER
	if(src == attacker)
		return // I'm afraid you do not get a free blink
	if(blink_away())
		return COMPONENT_CANCEL_ATTACK_CHAIN // prevent people from attacking the monkey

/mob/living/carbon/human/monkey/magic/proc/blink_away()
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return

	// A monkey, with a blink spell? Preposterous
	playsound(get_turf(src), 'sound/magic/blink.ogg', 50, TRUE)

	var/list/turfs = list()
	var/list/target_turfs = range(src, 5) - range(src, 1)
	for(var/turf/T in target_turfs)
		if(isspaceturf(T))
			continue
		if(T.is_blocked_turf())
			continue
		if(T.x > world.maxx - 5 || T.x < 5)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy - 5 || T.y < 5)
			continue
		if(islava(T) || ischasm(T))
			continue
		turfs += T

	var/turf/picked = pick(turfs)
	if(!picked || !isturf(picked))
		return

	visible_message("<span class='warning'>[src] blinks away!</span>", "<span class='danger'>Your instincts kick in, and you blink away!</span>")
	INVOKE_ASYNC(src, PROC_REF(after_the_attack), picked)

	playsound(get_turf(src), 'sound/magic/blink.ogg', 50, TRUE)
	return_timer = null
	return TRUE

/mob/living/carbon/human/monkey/magic/proc/after_the_attack(turf/picked)
	forceMove(picked)

	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread()
	smoke.set_up(1, FALSE, src)
	smoke.start()

/mob/living/carbon/human/monkey/magic/proc/i_want_to_go_home()
	if(client || !istype(loc, /turf/simulated/floor/plating/asteroid))
		return
	blink_away()

/mob/living/carbon/human/monkey/magic/Life(seconds, times_fired)
	. = ..()
	if(!client && !return_timer && prob(10) && istype(loc, /turf/simulated/floor/plating/asteroid))
		return_timer = addtimer(CALLBACK(src, PROC_REF(i_want_to_go_home)), 5 MINUTES)
		// I'm out out the wizard's den, I want to go back inside!

/mob/living/carbon/human/monkey/magic/mind_checks()
	if(!..())
		return FALSE
	mind.AddSpell(new /datum/spell/turf_teleport/blink(null))
	mind.special_role = SPECIAL_ROLE_WIZARD
