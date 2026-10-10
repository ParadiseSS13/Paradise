/mob/living/basic/megafauna/vox_quill
	name = "Quill Kiritaya"
	desc = "A large primalis wielding a spikethrower and strange armor. They feel... powerful."
	health = 400
	maxHealth = 400
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "vox_quill"
	icon_living = "vox_quill"
	icon_dead = "vox_quill"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_EPIC
	speak_emote = list("trills", "chirps", "tones")
	death_sound = 'sound/voice/shriek1.ogg'
	melee_attack_cooldown_min = 0.75 SECONDS
	damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.6, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 25
	melee_damage_upper = 35
	obj_damage = 100
	attack_verb_simple = "slash"
	attack_verb_continuous = "slashes"
	attack_sound = 'sound/weapons/blade1.ogg'
	response_help_continuous = "hugs"
	response_help_continuous = "hug"
	response_harm_continuous = "attacks"
	response_harm_simple = "attack"
	is_ranged = TRUE
	projectile_type = /obj/projectile/bullet/spike
	projectile_sound = 'sound/weapons/bladeslice.ogg'
	ranged_burst_count = 2
	ranged_burst_interval = 0.5 SECONDS
	ranged_cooldown = 1 SECONDS
	move_force = MOVE_FORCE_NORMAL
	see_in_dark = 20 // I see you
	step_type = FOOTSTEP_MOB_SHOE
	initial_traits = list(TRAIT_NOFIRE, TRAIT_SPACEWALK, TRAIT_MAGPULSE)
	blood_color = "#2299FC"
	loot = list(
		/obj/item/salvage/loot/vox,
		/obj/item/salvage/loot/vox,
		/obj/item/salvage/loot/vox,
		/obj/item/salvage/loot/vox,
		/obj/item/salvage/loot/vox,
		/obj/item/salvage/loot/vox,
		/obj/item/salvage/loot/dogtags/captain)
	faction = list("vox_raider")
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/vox_quill/stomp,
		/datum/action/cooldown/mob_cooldown/bluespace_horror/charge,
		)
	/// Do we explode on death?
	var/do_death_explosion = TRUE

/mob/living/basic/megafauna/vox_quill/check_eye_prot()
	return 2

/mob/living/basic/megafauna/vox_quill/check_ear_prot()
	return 2

/mob/living/basic/megafauna/vox_quill/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/megafauna/vox_quill/death(gibbed)
	transform = transform.Turn(90)
	if(do_death_explosion)
		death_explosion()
	. = ..()

/mob/living/basic/megafauna/vox_quill/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			adjustBruteLoss(75)

		if(EXPLODE_HEAVY)
			adjustBruteLoss(25)

		if(EXPLODE_LIGHT)
			adjustBruteLoss(10)

/mob/living/basic/megafauna/vox_quill/proc/death_explosion()
	visible_message(SPAN_USERDANGER("[src] starts beeping ominously!"))
	for(var/i in 1 to 4)
		playsound(loc, 'sound/items/timer.ogg', 30, 0)
		sleep(1 SECONDS)
	explosion(loc, 3, 6, 12, 20, flame_range = 20, cause = "Vox Quill Death Explosion")
	qdel(src)

/mob/living/basic/megafauna/vox_quill/devour(mob/living/L)
	return

/mob/living/basic/megafauna/vox_quill/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(a_intent == INTENT_HARM)
		return ..()
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		try_open_airlock(A)
		return
	if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/A = target
		if(A.density)
			A.open()
		else
			A.close()
		return
	if(iswallturf(target))
		return // We're not on kill intent. Don't smash.
	if(ismachinery(target)) // We can interface with machines!
		var/obj/machinery/machine = target
		machine.attack_hand(src)
		return

/mob/living/basic/megafauna/vox_quill/proc/try_open_airlock(obj/machinery/door/airlock/D)
	if(D.operating)
		return
	if(D.welded)
		to_chat(src, SPAN_WARNING("The door is welded."))
	else if(D.locked)
		to_chat(src, SPAN_WARNING("The door is bolted."))
	else if(D.allowed(src))
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE
	visible_message(SPAN_DANGER("[src] forces the door!"))
	playsound(src.loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(D.density)
		D.open(TRUE)
	else
		D.close(TRUE)
