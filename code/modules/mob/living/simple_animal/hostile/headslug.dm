#define EGG_INCUBATION_DEAD_TIME 120
#define EGG_INCUBATION_LIVING_TIME 200

/mob/living/simple_animal/hostile/headslug
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headslug"
	icon_living = "headslug"
	icon_dead = "headslug_dead"
	icon = 'icons/mob/mob.dmi'
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "грызёт"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = TRUE
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = 0
	speak_emote = list("squeaks")
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	ventcrawler = 2
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	a_intent = INTENT_HARM
	var/datum/mind/origin
	var/egg_layed = FALSE
	sentience_type = SENTIENCE_OTHER
	holder_type = /obj/item/holder/headslug


/mob/living/simple_animal/hostile/headslug/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		. += span_deadsay("It appears to be dead.")


/mob/living/simple_animal/hostile/headslug/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/internal/body_egg/changeling_egg/egg = new(victim)

	egg.insert(victim)
	if(origin)
		egg.origin = origin
	else if(mind) // Let's make this a feature
		egg.origin = mind

	visible_message(span_warning("[src] plants something in [victim]'s flesh!"), \
					span_danger("We inject our egg into [victim]'s body!"))


/mob/living/simple_animal/hostile/headslug/AltClickOn(mob/living/carbon/carbon_target)
	if(egg_layed || !istype(carbon_target) || carbon_target.stat != DEAD || !Adjacent(carbon_target) || issmall(carbon_target))
		return ..()

	changeNext_move(CLICK_CD_MELEE)

	if(carbon_target.stat != DEAD)
		to_chat(src, span_warning("Our target should be dead to infest it!"))
		return

	if(!do_mob(src, carbon_target, 5 SECONDS))
		return

	if(QDELETED(carbon_target) || egg_layed)
		return

	if(carbon_target.stat != DEAD)
		to_chat(src, span_warning("Our target is not dead anymore!"))
		return

	if(HAS_TRAIT(carbon_target, TRAIT_XENO_HOST))
		to_chat(src, span_userdanger("A foreign presence repels us from this body. Perhaps we should try to infest another body?"))
		return

	face_atom(carbon_target)
	do_attack_animation(carbon_target)
	playsound(src.loc, 'sound/creatures/terrorspiders/spit2.ogg', 30, TRUE)
	Infect(carbon_target)
	to_chat(src, span_userdanger("With our egg laid, our death approaches rapidly..."))
	addtimer(CALLBACK(src, PROC_REF(death)), 10 SECONDS)


/obj/item/organ/internal/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	origin_tech = "biotech=7" // You need to be really lucky to obtain it.
	var/datum/mind/origin
	var/time = 0


/obj/item/organ/internal/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in everyone
	time++
	if(time >= 30 && prob(30))
		owner.bleed(5)

	if(time >= 60 && prob(5))
		to_chat(owner, pick(span_danger("We feel great!"), span_danger("Something hurts for a moment but it's gone now."), \
							span_danger("You feel like you should go to a dark place."), span_danger("You feel really tired.")))

	if(time >= 90 && prob(5))
		to_chat(owner, pick(span_danger("Something hurts."), span_danger("Someone is thinking, but it's not you."), \
							span_danger("You feel at peace."), span_danger("Close your eyes.")))
		owner.adjustToxLoss(5)

	if((time >= EGG_INCUBATION_DEAD_TIME && owner.stat == DEAD) || time >= EGG_INCUBATION_LIVING_TIME)
		Pop()
		STOP_PROCESSING(SSobj, src)
		qdel(src)


/obj/item/organ/internal/body_egg/changeling_egg/proc/Pop()

	var/mob/living/carbon/human/lesser/monkey/monka = new(owner)
	LAZYADD(owner.stomach_contents, monka)

	if(origin?.current)
		origin.transfer_to(monka)

		var/datum/antagonist/changeling/cling = monka.mind.has_antag_datum(/datum/antagonist/changeling)
		if(cling.can_absorb_dna(owner))
			cling.absorb_dna(owner)

		cling.give_power(new /datum/action/changeling/humanform)

		monka.key = origin.key
		monka.revive() // better make sure some weird shit doesn't happen, because it has in the past
	owner.gib()


#undef EGG_INCUBATION_DEAD_TIME
#undef EGG_INCUBATION_LIVING_TIME
