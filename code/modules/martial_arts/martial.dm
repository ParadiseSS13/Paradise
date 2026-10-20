#define HAS_COMBOS LAZYLEN(combos)
#define COMBO_ALIVE_TIME 5 SECONDS // How long the combo stays alive when no new attack is done

/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	var/temporary = FALSE
	var/owner_UID
	/// The permanent style.
	var/datum/martial_art/base = null
	/// Chance to deflect projectiles while on throw mode.
	var/deflection_chance = 0
	/// Can it reflect projectiles in a random direction?
	var/reroute_deflection = FALSE
	var/help_verb = null
	/// Set to TRUE to prevent users of this style from using guns (sleeping carp, highlander). They can still pick them up, but not fire them.
	var/no_guns = FALSE
	/// Message to tell the style user if they try and use a gun while no_guns = TRUE (DISHONORABRU!)
	var/no_guns_message = ""

	/// If the martial art has it's own explaination verb.
	var/has_explaination_verb = FALSE

	/// What combos can the user do? List of combo types.
	var/list/combos = list()
	/// What combos are currently (possibly) being performed.
	var/list/datum/martial_art/current_combos = list()
	/// Stores the timer_id for the combo timeout timer
	var/combo_timer
	/// If the user is preparing a martial arts stance.
	var/in_stance = FALSE
	/// If the martial art allows parrying.
	var/can_parry = FALSE
	/// Set to TRUE to prevent users of this style from using stun batons (and stunprods)
	var/no_baton = FALSE
	/// The priority of which martial art is picked from all the ones someone knows, the higher the number, the higher the priority.
	var/weight = 0
	/// Message displayed when someone uses a baton when its forbidden by a martial art
	var/no_baton_reason = "Your martial arts training prevents you from wielding batons."
	/// Whether or not you can grab someone while horizontal with this Martial Art
	var/can_horizontally_grab = TRUE

/datum/martial_art/New()
	. = ..()
	reset_combos()

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_DISARM, A, D)

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_HARM, A, D)

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_GRAB, A, D)

/datum/martial_art/proc/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_HELP, A, D)

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return !HAS_TRAIT(H, TRAIT_PACIFISM)

/datum/martial_art/proc/act(step, mob/living/carbon/human/user, mob/living/carbon/human/target, could_start_new_combo = TRUE)
	if(!can_use(user))
		return MARTIAL_ARTS_CANNOT_USE
	if(combo_timer)
		deltimer(combo_timer)

	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combos)), COMBO_ALIVE_TIME, TIMER_UNIQUE | TIMER_STOPPABLE)

	if(HAS_COMBOS)
		streak += intent_to_streak(step)
		var/mob/living/carbon/human/owner = locateUID(owner_UID)
		if(istype(owner) && !QDELETED(owner))
			if(owner.hud_used)
				owner.hud_used.combo_display.update_icon(ALL, streak)
			return check_combos(step, user, target, could_start_new_combo)
	return FALSE

/datum/martial_art/proc/reset_combos(mob/living/carbon/human/H)
	current_combos.Cut()
	streak = ""
	var/mob/living/carbon/human/owner
	if(H)
		owner = H
	else
		owner = locateUID(owner_UID)
	if(istype(owner) && !QDELETED(owner))
		owner.hud_used.combo_display.update_icon(ALL, streak)
	for(var/combo_type in combos)
		current_combos.Add(new combo_type())

/datum/martial_art/proc/check_combos(step, mob/living/carbon/human/user, mob/living/carbon/human/target, could_start_new_combo = TRUE)
	. = FALSE
	for(var/thing in current_combos)
		var/datum/martial_combo/MC = thing
		if(!MC.check_combo(step, target))
			current_combos -= MC	// It failed so remove it
		else
			switch(MC.progress_combo(user, target, src))
				if(MARTIAL_COMBO_FAIL)
					current_combos -= MC
				if(MARTIAL_COMBO_DONE_NO_CLEAR)
					. = MARTIAL_ARTS_ACT_SUCCESS
					current_combos -= MC
				if(MARTIAL_COMBO_DONE)
					reset_combos()
					return MARTIAL_ARTS_ACT_SUCCESS
				if(MARTIAL_COMBO_DONE_BASIC_HIT)
					basic_hit(user, target)
					reset_combos()
					return MARTIAL_ARTS_ACT_SUCCESS
				if(MARTIAL_COMBO_DONE_CLEAR_COMBOS)
					combos.Cut()
					reset_combos()
					return MARTIAL_ARTS_ACT_SUCCESS
	if(!LAZYLEN(current_combos))
		reset_combos()
		if(HAS_COMBOS && could_start_new_combo)
			act(step, user, target, could_start_new_combo = FALSE)

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A, mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)
	var/datum/unarmed_attack/attack = A.get_unarmed_attack()

	var/atk_verb = "[pick(attack.attack_verb)]"
	if(IS_HORIZONTAL(D))
		atk_verb = "kick"

	switch(atk_verb)
		if("kick")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		else
			A.do_attack_animation(D, attack.animation_type)

	if(!damage)
		playsound(D.loc, attack.miss_sound, 25, TRUE, -1)
		D.visible_message(SPAN_WARNING("[A] has attempted to [atk_verb] [D]!"))
		return FALSE

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, attack.attack_sound, 25, TRUE, -1)
	D.visible_message(SPAN_DANGER("[A] has [atk_verb]ed [D]!"), \
								SPAN_USERDANGER("[A] has [atk_verb]ed [D]!"))

	D.apply_damage(damage, BRUTE, affecting, armor_block)

	add_attack_logs(A, D, "Melee attacked with martial-art [src]", (damage > 0) ? null : ATKLOG_ALL)

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message(SPAN_DANGER("[A] has weakened [D]!!"), \
								SPAN_USERDANGER("[A] has weakened [D]!"))
		D.apply_effect(8 SECONDS, WEAKEN, armor_block)
	return TRUE

/datum/martial_art/proc/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	if(!H.mind)
		return
	for(var/datum/martial_art/MA in H.mind.known_martial_arts)
		if(istype(MA, src))
			return
	if(has_explaination_verb)
		add_verb(H, /mob/living/carbon/human/proc/martial_arts_help)
	temporary = make_temporary
	owner_UID = H.UID()
	H.mind.known_martial_arts.Add(src)
	H.mind.martial_art = get_highest_weight(H)

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	var/datum/martial_art/MA = src
	if(!H.mind)
		return
	if(H.hud_used)
		reset_combos()
	deltimer(combo_timer)
	H.mind.known_martial_arts.Remove(MA)
	H.mind.martial_art = get_highest_weight(H)
	remove_verb(H, /mob/living/carbon/human/proc/martial_arts_help)

///	Returns the martial art with the highest weight from all the ones someone knows.
/datum/martial_art/proc/get_highest_weight(mob/living/carbon/human/H)
	var/datum/martial_art/highest_weight = null
	for(var/datum/martial_art/MA in H.mind.known_martial_arts)
		if(!highest_weight || MA.weight > highest_weight.weight)
			highest_weight = MA
	return highest_weight

/mob/living/carbon/human/proc/martial_arts_help()
	set name = "Show Info"
	set desc = "Gives information about the martial arts you know."
	set category = "Martial Arts"
	var/mob/living/carbon/human/H = usr
	if(istype(H))
		H.mind.martial_art.give_explaination(H)
		return
	if(isobserver(H) || iscameramob(H))
		to_chat(usr, SPAN_WARNING("You shouldn't have access to this verb. Report this as a bug to the github please."))
		return
	if(isanimal(H))
		to_chat(usr, SPAN_NOTICE("Your beastial form isn't compatible with any martial arts you know."))
		return
	if(issilicon(H))
		to_chat(usr, SPAN_NOTICE("Your malformed steel body can barely perform basic tasks, let alone complex martial arts."))
		return
	if(isalien(H))
		to_chat(usr, SPAN_NOTICE("The hivemind's fighting style has been blessed upon you, you have no need for this useless style."))
		return

/datum/martial_art/proc/give_explaination(user = usr)
	explaination_header(user)
	explaination_combos(user)
	explaination_footer(user)

// Put after the header and before the footer in the explaination text
/datum/martial_art/proc/explaination_combos(user)
	if(HAS_COMBOS)
		for(var/combo_type in combos)
			var/datum/martial_combo/MC = new combo_type()
			MC.give_explaination(user)

// Put on top of the explaination text
/datum/martial_art/proc/explaination_header(user)
	return

// Put below the combos in the explaination text
/datum/martial_art/proc/explaination_footer(user)
	return

/datum/martial_art/proc/try_deflect(mob/user)
		return prob(deflection_chance)

/datum/martial_art/proc/intent_to_streak(intent)
	switch(intent)
		if(MARTIAL_COMBO_STEP_HARM)
			return "E" // these hands are rated E for everyone
		if(MARTIAL_COMBO_STEP_DISARM)
			return "D"
		if(MARTIAL_COMBO_STEP_GRAB)
			return "G"
		if(MARTIAL_COMBO_STEP_HELP)
			return "H"

/atom/movable/screen/combo
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = UI_COMBO
	layer = ABOVE_HUD_LAYER
	var/streak

/atom/movable/screen/combo/proc/clear_streak()
	cut_overlays()
	streak = ""
	icon_state = ""

/atom/movable/screen/combo/update_icon(updates, _streak)
	streak = _streak
	return ..()

/atom/movable/screen/combo/update_overlays()
	. = list()
	for(var/i in 1 to length(streak))
		var/intent_text = copytext(streak, i, i + 1)
		var/image/intent_icon = image(icon, src, "combo_[intent_text]")
		intent_icon.pixel_x = 16 * (i - 1) - 8 * length(streak)
		. += intent_icon

/atom/movable/screen/combo/update_icon_state()
	icon_state = ""
	if(!streak)
		return
	icon_state = "combo"


#undef HAS_COMBOS
#undef COMBO_ALIVE_TIME
