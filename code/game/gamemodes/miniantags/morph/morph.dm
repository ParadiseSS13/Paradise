#define MORPHED_SPEED 2.5
#define ITEM_EAT_COST 5

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 1.5
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	pass_flags = PASSTABLE
	move_resist = MOVE_FORCE_STRONG // Fat being
	ventcrawler = VENTCRAWLER_ALWAYS

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	minbodytemp = 0
	maxHealth = 150
	health = 150
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/food/meat/slab = 2)
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/morph

	/// If the morph is disguised or not
	var/morphed = FALSE
	/// If the morph is ready to perform an ambush
	var/ambush_prepared = FALSE
	/// How much damage a successful ambush attack does
	var/ambush_damage = 25
	/// How much weaken a successful ambush attack applies
	var/ambush_weaken = 6 SECONDS
	/// The spell the morph uses to morph
	var/datum/spell/mimic/morph/mimic_spell
	/// The ambush action used by the morph
	var/datum/spell/morph_spell/ambush/ambush_spell
	/// The spell the morph uses to pass through airlocks
	var/datum/spell/morph_spell/pass_airlock/pass_airlock_spell

	/// How much the morph has gathered in terms of food. Used to reproduce and such
	var/gathered_food = 20 // Start with a bit to use abilities

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	mimic_spell = new
	AddSpell(mimic_spell)
	ambush_spell = new
	AddSpell(ambush_spell)
	AddSpell(new /datum/spell/morph_spell/reproduce)
	AddSpell(new /datum/spell/morph_spell/open_vent)
	pass_airlock_spell = new
	AddSpell(pass_airlock_spell)

/mob/living/simple_animal/hostile/morph/Destroy()
	QDEL_NULL(mimic_spell)
	QDEL_NULL(ambush_spell)
	QDEL_NULL(pass_airlock_spell)
	return ..()

/mob/living/simple_animal/hostile/morph/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Food Stored:", "[gathered_food]")

/mob/living/simple_animal/hostile/morph/wizard
	name = "magical morph"
	real_name = "magical morph"
	desc = "A revolting, pulsating pile of flesh. This one looks somewhat.. magical."

/mob/living/simple_animal/hostile/morph/wizard/Initialize(mapload)
	. = ..()
	AddSpell(new /datum/spell/smoke)
	AddSpell(new /datum/spell/forcewall)


/mob/living/simple_animal/hostile/morph/proc/try_eat(atom/movable/A)
	var/food_value = calc_food_gained(A)
	if(food_value + gathered_food < 0)
		to_chat(src, "<span class='warning'>You can't force yourself to eat more disgusting items. Eat some living things first.</span>")
		return
	var/eat_self_message
	if(food_value < 0)
		eat_self_message = "<span class='warning'>You start eating [A]... disgusting....</span>"
	else
		eat_self_message = "<span class='notice'>You start eating [A].</span>"
	visible_message("<span class='warning'>[src] starts eating [target]!</span>", eat_self_message, "You hear loud crunching!")
	if(do_after(src, 3 SECONDS, target = A))
		if(food_value + gathered_food < 0)
			to_chat(src, "<span class='warning'>You can't force yourself to eat more disgusting items. Eat some living things first.</span>")
			return
		eat(A)

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		visible_message("<span class='warning'>[src] swallows [A] whole!</span>")

		var/mob/living/carbon/human/H = A
		if(istype(H) && H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			U.turn_sensors_off()

		A.pulledby?.stop_pulling()
		A.extinguish_light()
		A.forceMove(src)
		var/food_value = calc_food_gained(A)
		add_food(food_value)
		if(food_value > 0)
			adjustHealth(-food_value)
		add_attack_logs(src, A, "morph ate")
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/proc/calc_food_gained(mob/living/L)
	if(!istype(L))
		return -ITEM_EAT_COST // Anything other than a tasty mob will make me sad ;(
	var/gained_food = max(5, 10 * L.mob_size) // Tiny things are worth less
	if(ishuman(L) && !ismonkeybasic(L))
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
	for(var/datum/action/spell_action/action in actions)
		action.build_all_button_icons()


/mob/living/simple_animal/hostile/morph/proc/assume()
	morphed = TRUE

	//Morph is weaker initially when disguised
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = MORPHED_SPEED
	ambush_spell.build_all_button_icons()
	pass_airlock_spell.build_all_button_icons()
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
	pass_airlock_spell.build_all_button_icons()
	move_resist = MOVE_FORCE_STRONG // Return to their fatness


/mob/living/simple_animal/hostile/morph/proc/prepare_ambush()
	ambush_prepared = TRUE
	to_chat(src, "<span class='sinister'>You are ready to ambush any unsuspected target. Your next attack will hurt a lot more and weaken the target! Moving will break your focus. Standing still will perfect your disguise.</span>")
	apply_status_effect(/datum/status_effect/morph_ambush)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/mob/living/simple_animal/hostile/morph/proc/failed_ambush()
	ambush_prepared = FALSE
	ambush_spell.build_all_button_icons()
	mimic_spell.perfect_disguise = FALSE // Reset the perfect disguise
	remove_status_effect(/datum/status_effect/morph_ambush)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	add_to_all_human_data_huds()

/mob/living/simple_animal/hostile/morph/proc/perfect_ambush()
	mimic_spell.perfect_disguise = TRUE // Reset the perfect disguise
	to_chat(src, "<span class='sinister'>You've perfected your disguise. Making you indistinguishable from the real form!</span>")
	remove_from_all_data_huds()

/mob/living/simple_animal/hostile/morph/proc/on_move()
	failed_ambush()
	to_chat(src, "<span class='warning'>You moved out of your ambush spot!</span>")

/mob/living/simple_animal/hostile/morph/add_ventcrawl()
	. = ..()
	on_move()

/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()
	add_to_all_human_data_huds()
	if(stat == DEAD && gibbed)
		eject_contents()
	// Only execute the below if we successfully died
	if(!.)
		return FALSE

/mob/living/simple_animal/hostile/morph/proc/eject_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/mob/living/simple_animal/hostile/morph/crowbar_act(mob/living/user, obj/item/I)
	if(stat != DEAD)
		return CONTINUE_ATTACK
	if(user.a_intent != INTENT_HELP)
		return CONTINUE_ATTACK
	if(!contents.len)
		to_chat(user, "<span class='warning'>[src] doesnt have anything left inside it!</span>")
		return ITEM_INTERACT_COMPLETE
	playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
	visible_message(
		"<span class='warning'>[src] begins to pry open the morph's massive jaws!</span>", 
		"<span class='danger'>You begin to pry open the morph's massive jaws!</span>", 
		"<span class='warning'>You hear wet, meaty tearing nearby!</span>"
	)
	if(do_after_once(user, 8 SECONDS, target = src))
		eject_contents()
		playsound(loc, 'sound/effects/splat.ogg', 50, TRUE, -1)
	return ITEM_INTERACT_COMPLETE

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/M)
	if(ambush_prepared)
		to_chat(M, "<span class='warning'>[src] feels a bit different from normal... it feels more.. </span><span class='userdanger'>SLIMEY?!</span>")
		ambush_attack(M, TRUE)
	else
		return ..()

/mob/living/simple_animal/hostile/morph/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		if(length(contents))
			. += "<span class='notice'>You can use <b>ALT + Click</b> to eject anything the morph may have eaten.</span>"
		else if(in_range(user, src))
			. += "<span class='warning'>\The [src] seems to have nothing left inside of it!</span>"
#define MORPH_ATTACKED if((. = ..()) && morphed) mimic_spell.restore_form(src)

/mob/living/simple_animal/hostile/morph/attack_by(obj/item/O, mob/living/user, params)
	if(user.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(user, "<span class='warning'>You try to use [O] on [src]... it seems different than no-</span>")
		ambush_attack(user, TRUE)
		return FINISH_ATTACK

	MORPH_ATTACKED

/mob/living/simple_animal/hostile/morph/attack_animal(mob/living/simple_animal/M)
	if(M.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(M, "<span class='notice'>You nuzzle [src].</span><span class='danger'> And [src] nuzzles back!</span>")
		ambush_attack(M, TRUE)
		return TRUE
	MORPH_ATTACKED

/mob/living/simple_animal/hostile/morph/attack_hulk(mob/living/carbon/human/user, does_attack_animation) // Me SMASH
	MORPH_ATTACKED

/mob/living/simple_animal/hostile/morph/attack_larva(mob/living/carbon/alien/larva/L)
	MORPH_ATTACKED

/mob/living/simple_animal/hostile/morph/attack_alien(mob/living/carbon/alien/humanoid/M)
	MORPH_ATTACKED

/mob/living/simple_animal/hostile/morph/attack_tk(mob/user)
	MORPH_ATTACKED

/mob/living/simple_animal/hostile/morph/attack_slime(mob/living/simple_animal/slime/M)
	MORPH_ATTACKED

#undef MORPH_ATTACKED

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
	visible_message("<span class='danger'>[src] suddenly leaps towards [L]!</span>", "<span class='warning'>You strike [L] when [L.p_they()] least expected it!</span>", "You hear a horrible crunch!")

	mimic_spell.restore_form(src)

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
	. = ..()
	if(. && !morphed)
		var/list/things = list()
		for(var/atom/movable/A in oview(src))
			if(mimic_spell.valid_target(A, src))
				things += A
		if(!length(things))
			return
		var/atom/movable/T = pick(things)
		mimic_spell.take_form(new /datum/mimic_form(T, src), src)
		prepare_ambush() // They cheat okay

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			try_eat(L)
			return TRUE
		if(ambush_prepared)
			ambush_attack(L)
			return TRUE // No double attack
	else if(isitem(target)) // Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			try_eat(I)
			return TRUE
	. = ..()
	if(. && morphed)
		mimic_spell.restore_form(src)


/mob/living/simple_animal/hostile/morph/proc/make_morph_antag(give_default_objectives = TRUE)
	mind.assigned_role = SPECIAL_ROLE_MORPH
	mind.special_role = SPECIAL_ROLE_MORPH
	SSticker.mode.traitors |= mind
	var/list/messages = list()
	messages.Add("<b><font size=3 color='red'>You are a morph.</font><br></b>")
	messages.Add("<span class='sinister'>You hunger for living beings and desire to procreate. Achieve this goal by ambushing unsuspecting pray using your abilities.</span>")
	messages.Add("<span class='specialnotice'>As an abomination created primarily with changeling cells you may take the form of anything nearby by using your <span class='specialnotice bold'>Mimic ability.</span></span>")
	messages.Add("<span class='specialnotice'>The transformation will not go unnoticed for bystanding observers.</span>")
	messages.Add("<span class='specialnotice bold'>While morphed</span><span class='specialnotice'>, you move slower and do less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you.</span>")
	messages.Add("<span class='specialnotice'>From this form you can however <span class='specialnotice bold'>Prepare an Ambush</span> using your ability.</span>")
	messages.Add("<span class='specialnotice'>This will allow you to deal a lot of damage the first hit. And if they touch you then even more.</span>")
	messages.Add("<span class='specialnotice'>Finally, you can attack any item or dead creature to consume it - creatures will restore 1/3 of your max health and will add to your stored food while eating items will reduce your stored food.</span>")
	messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Morph)</span>")
	SEND_SOUND(src, sound('sound/magic/mutate.ogg'))
	if(give_default_objectives)
		mind.add_mind_objective(/datum/objective/morph_eat)
		mind.add_mind_objective(/datum/objective/morph_procreate)
		messages.Add(mind.prepare_announce_objectives(FALSE))

	to_chat(src, chat_box_red(messages.Join("<br>")))

/datum/objective/morph_eat
	explanation_text = "Eat as many living beings as possible to still the hunger within you."
	completed = TRUE
	needs_target = FALSE

/datum/objective/morph_procreate
	explanation_text = "Split yourself in as many other morphs as possible!"
	completed = TRUE
	needs_target = FALSE

#undef MORPHED_SPEED
#undef ITEM_EAT_COST
