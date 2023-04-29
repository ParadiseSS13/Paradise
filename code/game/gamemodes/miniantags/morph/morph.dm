#define MORPHED_SPEED 2.5
#define ITEM_EAT_COST 5
#define MORPHS_ANNOUNCE_THRESHOLD 5

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
	speed = 1.5
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	move_resist = MOVE_FORCE_STRONG // Fat being
	ventcrawler = 2
	tts_seed = "Treant"

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
	attacktext = "кусает"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)

	var/playstyle_string = "<b><font size=3 color='red'>You are a morph.</font><br> As an abomination created primarily with changeling cells, \
							you may take the form of anything nearby by shift-clicking it. This process will alert any nearby \
							observers, and can only be performed once every five seconds.<br> While morphed, you move faster, but do \
							less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you. \
							You can restore yourself to your original form while morphed by shift-clicking yourself.<br> \
							Finally, you can attack any item or dead creature to consume it - creatures will restore 1/3 of your max health.</b>"

	var/can_reproduce = FALSE
	/// If the morph is disguised or not
	var/morphed = FALSE
	/// If the morph is ready to perform an ambush
	var/ambush_prepared = FALSE
	/// How much damage a successful ambush attack does
	var/ambush_damage = 25
	/// How much weaken a successful ambush attack applies
	var/ambush_weaken = 3
	/// The spell the morph uses to morph
	var/obj/effect/proc_holder/spell/targeted/click/mimic/morph/mimic_spell
	/// The ambush action used by the morph
	var/obj/effect/proc_holder/spell/targeted/morph_spell/ambush/ambush_spell
	/// The spell the morph uses to pass through airlocks
	var/obj/effect/proc_holder/spell/targeted/click/morph_spell/pass_airlock/pass_airlock_spell

	/// How much the morph has gathered in terms of food. Used to reproduce and such
	var/gathered_food = 20 // Start with a bit to use abilities


/mob/living/simple_animal/hostile/morph/proc/check_morphs()
	if((length(GLOB.morphs_alive_list) >= MORPHS_ANNOUNCE_THRESHOLD) && (!GLOB.morphs_announced))
		GLOB.command_announcement.Announce("Внимание! Зафиксированы множественные биоугрозы 6 уровня на [station_name()]. Необходима ликвидация угрозы для продолжения безопасной работы.", "Отдел Центрального Командования по биологическим угрозам.", 'sound/AI/commandreport.ogg')
		GLOB.morphs_announced = TRUE
		cancel_call_proc(usr)
	else
		return

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	mimic_spell = new
	AddSpell(mimic_spell)
	ambush_spell = new
	AddSpell(ambush_spell)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/click/morph_spell/open_vent)
	pass_airlock_spell = new
	AddSpell(pass_airlock_spell)
	GLOB.morphs_alive_list += src
	check_morphs()

/**
 * This proc enables or disables morph reproducing ability
 *
 * Arguments
 * * boolean - TRUE = enabled, FALSE = disabled
 */
/mob/living/simple_animal/hostile/morph/proc/enable_reproduce(boolean)
	if(boolean)
		can_reproduce = TRUE
		AddSpell(new /obj/effect/proc_holder/spell/targeted/morph_spell/reproduce)
	else
		can_reproduce = FALSE
		RemoveSpell(/obj/effect/proc_holder/spell/targeted/morph_spell/reproduce)

/mob/living/simple_animal/hostile/morph/Stat(Name, Value)
	..()
	if(statpanel("Status"))
		stat(null, "Food Stored: [gathered_food]")
		return TRUE

/mob/living/simple_animal/hostile/morph/wizard
	name = "magical morph"
	real_name = "magical morph"
	desc = "A revolting, pulsating pile of flesh. This one looks somewhat.. magical."

/mob/living/simple_animal/hostile/morph/wizard/New()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall)


/mob/living/simple_animal/hostile/morph/proc/try_eat(atom/movable/item)
	var/food_value = calc_food_gained(item)
	if(food_value + gathered_food < 0)
		to_chat(src, "<span class='warning'>You can't force yourself to eat more disgusting items. Eat some living things first.</span>")
		return
	var/eat_self_message
	if(food_value < 0)
		eat_self_message = "<span class='warning'>You start eating [item]... disgusting....</span>"
	else
		eat_self_message = "<span class='notice'>You start eating [item].</span>"
	visible_message("<span class='warning'>[src] starts eating [target]!</span>", eat_self_message, "You hear loud crunching!")
	if(do_after(src, 3 SECONDS, target = item))
		if(food_value + gathered_food < 0)
			to_chat(src, "<span class='warning'>You can't force yourself to eat more disgusting items. Eat some living things first.</span>")
			return
		eat(item)

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/item)
	if(item && item.loc != src)
		visible_message("<span class='warning'>[src] swallows [item] whole!</span>")

		item.extinguish_light()
		item.forceMove(src)
		var/food_value = calc_food_gained(item)
		add_food(food_value)
		if(food_value > 0)
			adjustHealth(-food_value)
		add_attack_logs(src, item, "morph ate")
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/proc/calc_food_gained(mob/living/living)
	if(!istype(living))
		return -ITEM_EAT_COST // Anything other than a tasty mob will make me sad ;(
	var/gained_food = max(5, 10 * living.mob_size) // Tiny things are worth less
	if(ishuman(living) && !ismonkeybasic(living))
		gained_food += 10 // Humans are extra tasty

	return gained_food

/mob/living/simple_animal/hostile/morph/proc/use_food(amount)
	if(amount > gathered_food)
		return FALSE
	add_food(-amount)
	return TRUE

/**
 * Adds the given amount of food to the gathered food and updates the actions.
 * Does not include a check to see if it goes below 0 or not
 */
/mob/living/simple_animal/hostile/morph/proc/add_food(amount)
	gathered_food += amount
	update_action_buttons_icon()

/mob/living/simple_animal/hostile/morph/proc/assume()
	morphed = TRUE

	//Morph is weaker initially when disguised
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = MORPHED_SPEED
	ambush_spell.updateButtonIcon()
	pass_airlock_spell.updateButtonIcon()
	move_resist = MOVE_FORCE_DEFAULT // They become more fragile and easier to move

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		return
	morphed = FALSE

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	speed = initial(speed)
	if(ambush_prepared)
		to_chat(src, "<span class='warning'>The ambush potential has faded as you take your true form.</span>")
	failed_ambush()
	pass_airlock_spell.updateButtonIcon()
	move_resist = MOVE_FORCE_STRONG // Return to their fatness


/mob/living/simple_animal/hostile/morph/proc/prepare_ambush()
	ambush_prepared = TRUE
	to_chat(src, "<span class='sinister'>You are ready to ambush any unsuspected target. Your next attack will hurt a lot more and weaken the target! Moving will break your focus. Standing still will perfect your disguise.</span>")
	apply_status_effect(/datum/status_effect/morph_ambush)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/on_move)

/mob/living/simple_animal/hostile/morph/proc/failed_ambush()
	ambush_prepared = FALSE
	ambush_spell.updateButtonIcon()
	mimic_spell.perfect_disguise = FALSE // Reset the perfect disguise
	remove_status_effect(/datum/status_effect/morph_ambush)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/mob/living/simple_animal/hostile/morph/proc/perfect_ambush()
	mimic_spell.perfect_disguise = TRUE // Reset the perfect disguise
	to_chat(src, "<span class='sinister'>You've perfected your disguise. Making you indistinguishable from the real form!</span>")


/mob/living/simple_animal/hostile/morph/proc/on_move()
	failed_ambush()
	to_chat(src, "<span class='warning'>You moved out of your ambush spot!</span>")


/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()
	if(stat == DEAD && gibbed)
		for(var/atom/movable/eaten_thing in src)
			eaten_thing.forceMove(loc)
			if(prob(90))
				step(eaten_thing, pick(GLOB.alldirs))
	// Only execute the below if we successfully died
	if(!.)
		return FALSE
	GLOB.morphs_alive_list -= src

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/attacker)
	if(ambush_prepared)
		to_chat(attacker, "<span class='warning'>[src] feels a bit different from normal... it feels more.. </span><span class='userdanger'>SLIMEY?!</span>")
		ambush_attack(attacker, TRUE)
		return TRUE
	else if (!morphed)
		to_chat(attacker, "<span class='warning'>Touching [src] with your hands hurts you!</span>")
		var/obj/item/organ/external/affecting = attacker.get_organ("[attacker.hand ? "l" : "r" ]_hand")
		affecting.receive_damage(20)
		add_food(5)

	restore_form()
	return ..()

/mob/living/simple_animal/hostile/morph/proc/restore_form()
	if (morphed)
		return mimic_spell.restore_form(src);

/mob/living/simple_animal/hostile/morph/attackby(obj/item/item, mob/living/user)
	if (stat == DEAD)
		restore_form()
		return ..()

	if(user.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(user, "<span class='warning'>You try to use [item] on [src]... it seems different than no-</span>")
		ambush_attack(user, TRUE)
		return TRUE

	if (!morphed && istype(user, /mob/living/silicon/robot))
		var/food_value = calc_food_gained(item)
		if(food_value + gathered_food > 0)
			to_chat(user, "<span class='warning'>Attacking [src] damaging your systems!</span>")
			var/mob/living/silicon/robot/borg = user
			borg.adjustBruteLoss(70)
			add_food(-5)
		return ..()

	if (!morphed && prob(50))
		var/food_value = calc_food_gained(item)
		if(food_value + gathered_food > 0)
			to_chat(user, "<span class='warning'>[src] just ate your [item]!</span>")
			user.unEquip(item)
			eat(item)
			return ..()

	restore_form()
	return ..()

/mob/living/simple_animal/hostile/morph/attack_animal(mob/living/simple_animal/animal)
	if(animal.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(animal, "<span class='notice'>You nuzzle [src].</span><span class='danger'> And [src] nuzzles back!</span>")
		ambush_attack(animal, TRUE)
		return TRUE
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_larva(mob/living/carbon/alien/larva/L)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_alien(mob/living/carbon/alien/humanoid/M)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_tk(mob/user)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_slime(mob/living/simple_animal/slime/M)
	restore_form()


/mob/living/simple_animal/hostile/morph/proc/ambush_attack(mob/living/dumbass, touched)
	ambush_prepared = FALSE
	var/total_weaken = ambush_weaken
	var/total_damage = ambush_damage
	if(touched) // Touching a morph while he's ready to kill you is a bad idea
		total_weaken *= 2
		total_damage *= 2

	dumbass.Weaken(total_weaken)
	dumbass.apply_damage(total_damage, BRUTE)
	add_attack_logs(src, dumbass, "morph ambush attacked")
	do_attack_animation(dumbass, ATTACK_EFFECT_BITE)
	visible_message("<span class='danger'>[src] suddenly leaps towards [dumbass]!</span>", "<span class='warning'>You strike [dumbass] when [dumbass.p_they()] least expected it!</span>", "You hear a horrible crunch!")

	restore_form()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/item)
	var/list/not_allowed = list(/obj/screen, /obj/singularity, /mob/living/simple_animal/hostile/morph)
	return !is_type_in_list(item, not_allowed)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
	. = ..()
	if(. && !morphed)
		var/list/things = list()
		for(var/atom/movable/item_in_view in view(src))
			if(istype(item_in_view, /obj) && allowed(item_in_view))
				things += item_in_view
		var/atom/movable/picked_thing = pick(things)
		if (picked_thing)
			mimic_spell.take_form(new /datum/mimic_form(picked_thing, src), src)
			prepare_ambush() // They cheat okay

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/living = target
		if(living.stat == DEAD)
			try_eat(living)
			return TRUE
		if(ambush_prepared)
			ambush_attack(living)
			return TRUE // No double attack
	else if(istype(target,/obj/item)) // Eat items just to be annoying
		var/obj/item/item = target
		if(!item.anchored)
			try_eat(item)
			return TRUE
	. = ..()
	if(. && morphed)
		restore_form()


/mob/living/simple_animal/hostile/morph/proc/make_morph_antag(give_default_objectives = TRUE)
	enable_reproduce(TRUE)
	mind.assigned_role = SPECIAL_ROLE_MORPH
	mind.special_role = SPECIAL_ROLE_MORPH
	SSticker.mode.traitors |= mind
	to_chat(src, "<b><font size=3 color='red'>You are a morph.</font><br></b>")
	to_chat(src, "<span class='sinister'>You hunger for living beings and desire to procreate. Achieve this goal by ambushing unsuspecting pray using your abilities.</span>")
	to_chat(src, "<span class='specialnotice'>As an abomination created primarily with changeling cells you may take the form of anything nearby by using your <span class='specialnoticebold'>Mimic ability</span>.</span>")
	to_chat(src, "<span class='specialnotice'>The transformation will not go unnoticed for bystanding observers.</span>")
	to_chat(src, "<span class='specialnoticebold'>While morphed</span><span class='specialnotice'>, you move slower and do less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you.</span>")
	to_chat(src, "<span class='specialnotice'>From this form you can however <span class='specialnoticebold'>Prepare an Ambush</span> using your ability.</span>")
	to_chat(src, "<span class='specialnotice'>This will allow you to deal a lot of damage the first hit. And if they touch you then even more.</span>")
	to_chat(src, "<span class='specialnotice'>Finally, you can attack any item or dead creature to consume it - creatures will restore 1/3 of your max health and will add to your stored food while eating items will reduce your stored food</span>.")

	SEND_SOUND(src, sound('sound/magic/mutate.ogg'))
	if(give_default_objectives)
		var/datum/objective/eat = new /datum/objective
		eat.owner = mind
		eat.explanation_text = "Eat as many living beings as possible to still the hunger within you."
		eat.completed = TRUE
		mind.objectives += eat
		var/datum/objective/procreate = new /datum/objective
		procreate.owner = mind
		procreate.explanation_text = "Split yourself in as many other [name]'s as possible!"
		procreate.completed = TRUE
		mind.objectives += procreate
		mind.announce_objectives()

#undef MORPHED_SPEED
#undef ITEM_EAT_COST
#undef MORPHS_ANNOUNCE_THRESHOLD
