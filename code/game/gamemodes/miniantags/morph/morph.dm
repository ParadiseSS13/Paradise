#define MORPHED_SPEED 2

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = 2

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	minbodytemp = 0
	maxHealth = 150
	health = 150
	environment_smash = 1
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = 0
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)

	var/morphed = FALSE
	/// If the morph is ready to perform an ambush
	var/ambush_prepared = FALSE
	/// How much damage a successful ambush attack does
	var/ambush_damage = 25
	/// How much weaken a successful ambush attack applies
	var/ambush_weaken = 3
	// TODO
	var/playstyle_string = "<b><font size=3 color='red'>You are a morph.</font><br>As an abomination created primarily with changeling cells, \
							you may take the form of anything nearby by using your <span class='specialnoticebold'>Mimic ability</span>. \
							This process will alert any nearby observers and can only be performed once every five seconds.<br>\
							<span class='specialnoticebold'>While morphed</span>, you move slower and do less damage.\
							In addition, anyone within three tiles will note an uncanny wrongness if examining you.<br>\
							In this form you can however <span class='specialnoticebold'>prepare an ambush</span> using your ability. \
							This will allow you to deal a lot of damage the first hit. And if they touch you then even more.<br>\
							Finally, you can attack any item or dead creature to consume it - creatures will restore 1/3 of your max health.</b>"
	/// The spell the morph uses to morph
	var/obj/effect/proc_holder/spell/targeted/click/mimic/morph/mimic_spell
	var/datum/action/morph_ambush/ambush_action

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MAGIC_MIMIC_CHANGE_FORM, .proc/assume)
	RegisterSignal(src, COMSIG_MAGIC_MIMIC_RESTORE_FORM, .proc/restore)
	mimic_spell = new
	AddSpell(mimic_spell)
	ambush_action = new
	ambush_action.Grant(src)

/mob/living/simple_animal/hostile/morph/wizard
	name = "magical morph"
	real_name = "magical morph"
	desc = "A revolting, pulsating pile of flesh. This one looks somewhat.. magical."

/mob/living/simple_animal/hostile/morph/wizard/New()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall)

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		visible_message("<span class='warning'>[src] swallows [A] whole!</span>")
		A.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/proc/assume()
	morphed = TRUE

	//Morph is weaker initially when disguising
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = MORPHED_SPEED
	ambush_action.UpdateButtonIcon()


/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		return
	morphed = FALSE

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	speed = initial(speed)
	if(ambush_prepared)
		ambush_prepared = FALSE
		to_chat(src, "<span class='warning'>The ambush potential has faded as you take your true form.</span>")
	ambush_action.UpdateButtonIcon()

/mob/living/simple_animal/hostile/morph/proc/prepare_ambush()
	ambush_prepared = TRUE
	to_chat(src, "<span class='sinister'>You are ready to ambush any unsuspected target. Your next attack will hurt a lot more and weaken the target! Moving will break your focus.</span>")

/mob/living/simple_animal/hostile/morph/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(ambush_prepared)
		ambush_prepared = FALSE
		to_chat(src, "<span class='warning'>You moved out of your ambush spot!</span>")
		ambush_action.UpdateButtonIcon()

/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()
	if(stat == DEAD && gibbed)
		for(var/atom/movable/AM in src)
			AM.forceMove(loc)
			if(prob(90))
				step(AM, pick(GLOB.alldirs))
	// Only execute the below if we successfully died
	if(!.)
		return FALSE

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/M)
	if(ambush_prepared)
		to_chat(M, "<span class='warning'>[src] feels a bit different from normal... it feels more.. </span><span class='userdanger'>SLIMEY?!</span>")
		ambush_attack(M, TRUE)
	else
		return ..()

/mob/living/simple_animal/hostile/morph/attack_hulk(mob/living/carbon/human/user, does_attack_animation)
	. = ..()
	if(. && morphed)
		mimic_spell.restore_form(src)

/mob/living/simple_animal/hostile/morph/attackby(obj/item/O, mob/living/user)
	. = ..()
	if(. && morphed)
		mimic_spell.restore_form(src)

/mob/living/simple_animal/hostile/morph/proc/ambush_attack(mob/living/L, touched)
	ambush_prepared = FALSE
	var/total_weaken = ambush_weaken
	var/total_damage = ambush_damage
	if(touched) // Touching a morph while he's ready to kill you is a bad idea
		total_weaken *= 2
		total_damage *= 2

	L.Weaken(total_weaken)
	L.apply_damage(total_damage, BRUTE)
	add_attack_logs(src, L, "morph ambush attacked")
	do_attack_animation(L, ATTACK_EFFECT_BITE)
	visible_message("<span class='danger'>[src] Suddenly leaps towards [L]!</span>", "<span class='warning'>You strike [L] when [L.p_they()] least expected it!</span>")

	mimic_spell.restore_form(src)

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(var/list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/movable/A in view(src))
			if(mimic_spell.valid_target(A, src))
				things += A
		var/atom/movable/T = pick(things)
		mimic_spell.take_form(new /datum/mimic_form(T, src), src)
		prepare_ambush() // They cheat okay

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-50)
			return
		if(ambush_prepared)
			ambush_attack(L)
	else if(istype(target,/obj/item)) // Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			if(do_after(src, 20, target = I))
				eat(I)
			return
	. = ..()
	if(. && morphed)
		mimic_spell.restore_form(src)

/datum/action/morph_ambush
	name = "Prepare Ambush"
	desc = "Prepare an ambush. Dealing significantly more damage on the first hit and you will weaken the target. Only works while morphed. If the target tries to use you with their hands then you will do even more damage."
	var/preparing = FALSE
	var/prepared = FALSE

/datum/action/morph_ambush/IsAvailable()
	var/mob/living/simple_animal/hostile/morph/M = owner
	if(!istype(M) || !M.morphed || M.ambush_prepared)
		return FALSE
	return ..()

/datum/action/morph_ambush/Trigger()
	if(!..())
		return
	var/mob/living/simple_animal/hostile/morph/M = owner
	to_chat(M, "<span class='sinister'>You start preparing an ambush.</span>")
	if(!do_after(owner, 4 SECONDS, FALSE, owner, list(CALLBACK(src, .proc/prepare_check), FALSE)))
		if(!M.morphed)
			to_chat(M, "<span class='warning'>You need to stay morphed to prepare the ambush!</span>")
			return
		to_chat(M, "<span class='warning'>You need to stay still to prepare the ambush!</span>")
		return
	M.prepare_ambush()

/datum/action/morph_ambush/proc/prepare_check()
	var/mob/living/simple_animal/hostile/morph/M = owner
	return !M.morphed

#undef MORPHED_SPEED
