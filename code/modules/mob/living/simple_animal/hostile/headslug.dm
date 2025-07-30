#define EGG_INCUBATION_DEAD_CYCLE 120
#define EGG_INCUBATION_LIVING_CYCLE 200
/mob/living/simple_animal/hostile/headslug
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headslug"
	icon_living = "headslug"
	icon_dead = "headslug_dead"
	icon = 'icons/mob/mob.dmi'
	health = 60
	maxHealth = 60
	melee_damage_lower = 30
	melee_damage_upper = 35
	melee_damage_type = STAMINA
	attacktext = "gnaws"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = TRUE
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = 0
	speak_emote = list("squeaks")
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	a_intent = INTENT_HARM
	speed = 0.3
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	var/datum/mind/origin
	var/egg_layed = FALSE
	sentience_type = SENTIENCE_OTHER
	contains_xeno_organ = TRUE
	ignore_generic_organs = TRUE
	surgery_container = /datum/xenobiology_surgery_container/headslug

/mob/living/simple_animal/hostile/headslug/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/internal/body_egg/changeling_egg/egg = new(victim)
	egg.insert(victim)
	if(origin)
		egg.origin = origin
	else if(mind) // Let's make this a feature
		egg.origin = mind
	for(var/obj/item/organ/internal/I in src)
		I.forceMove(egg)
	visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
	egg_layed = TRUE

/mob/living/simple_animal/hostile/headslug/AltClickOn(mob/living/carbon/carbon_target)
	if(egg_layed || !istype(carbon_target) || !Adjacent(carbon_target) || ismachineperson(carbon_target))
		return ..()
	if(carbon_target.stat != DEAD && !do_mob(src, carbon_target, 5 SECONDS, hidden = TRUE))
		return
	if(HAS_TRAIT(carbon_target, TRAIT_XENO_HOST))
		to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
		return
	if(!carbon_target.get_int_organ_datum(ORGAN_DATUM_HEART))
		to_chat(src, "<span class='userdanger'>There's no heart for us to infest!</span>")
		return
	Infect(carbon_target)
	to_chat(src, "<span class='userdanger'>With our egg laid, our death approaches rapidly...</span>")
	addtimer(CALLBACK(src, PROC_REF(death)), 25 SECONDS)

/mob/living/simple_animal/hostile/headslug/projectile_hit_check(obj/item/projectile/P)
	return (stat || FALSE)

/obj/item/organ/internal/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	origin_tech = "biotech=7" // You need to be really lucky to obtain it.
	var/datum/mind/origin
	var/time = 0

/obj/item/organ/internal/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in everyone
	time++
	if(time >= 30 && prob(40))
		owner.bleed(5)
	if(time >= 60 && prob(10))
		to_chat(owner, pick("<span class='danger'>We feel great!</span>", "<span class='danger'>Something hurts for a moment but it's gone now.</span>", "<span class='danger'>You feel like you should go to a dark place.</span>", "<span class='danger'>You feel really tired.</span>"))
		owner.adjustToxLoss(30)
	if(time >= 90 && prob(15))
		to_chat(owner, pick("<span class='danger'>Something hurts.</span>", "<span class='danger'>Someone is thinking, but it's not you.</span>", "<span class='danger'>You feel at peace.</span>", "<span class='danger'>Close your eyes.</span>"))
		owner.apply_damage(50, STAMINA)
	if(time >= EGG_INCUBATION_DEAD_CYCLE && owner.stat == DEAD || time >= EGG_INCUBATION_LIVING_CYCLE)
		Pop()
		STOP_PROCESSING(SSobj, src)
		qdel(src)

/obj/item/organ/internal/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/human/monkey/M = new(owner)
	LAZYADD(owner.stomach_contents, M)

	for(var/obj/item/organ/internal/I in src)
		I.insert(M, 1)

	if(origin && origin.current && (origin.current.stat == DEAD))
		origin.transfer_to(M)
		var/datum/antagonist/changeling/cling = IS_CHANGELING(M)
		if(cling.can_absorb_dna(owner))
			cling.absorb_dna(owner)

		cling.update_languages()

		// When they became a headslug, power typepaths were added to this list, so we need to make new ones from the paths.
		for(var/power_path in cling.acquired_powers)
			cling.give_power(new power_path, M, FALSE)
			cling.acquired_powers -= power_path

		var/datum/action/changeling/evolution_menu/E = locate() in cling.acquired_powers

		// Add purchasable powers they have back to the evolution menu's purchased list.
		for(var/datum/action/changeling/power as anything in cling.acquired_powers)
			if(power.power_type == CHANGELING_PURCHASABLE_POWER)
				E.purchased_abilities += power.type

		cling.give_power(new /datum/action/changeling/humanform)
		M.key = origin.key
		M.revive() // better make sure some weird shit doesn't happen, because it has in the pas
		M.forceMove(get_turf(owner)) // So that they are not stuck inside
	if(!ishuman(owner))
		owner.gib()
		return

	owner.bleed(BLOOD_VOLUME_NORMAL)
	var/datum/organ/our_heart_datum = owner.get_int_organ_datum(ORGAN_DATUM_HEART)
	var/obj/item/organ/internal/our_heart = our_heart_datum.linked_organ
	var/obj/item/organ/external/heart_location = owner.get_organ(our_heart.parent_organ)
	owner.apply_damage(300, BRUTE, our_heart.parent_organ)
	heart_location.fracture()
	heart_location.disembowel(our_heart.parent_organ)

#undef EGG_INCUBATION_DEAD_CYCLE
#undef EGG_INCUBATION_LIVING_CYCLE
