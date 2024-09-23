/datum/martial_art/muscle_implant
	name = "Empowered Muscle Implant Fighting"
	weight = 1
	/// Are we EMP'ed?
	var/is_emped = FALSE
	/// How much damage should our punches deal
	var/punch_damage = 13

/datum/martial_art/muscle_implant/harm_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	MARTIAL_ARTS_ACT_CHECK

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to hurt [target]!</span>")
		return FALSE
	var/picked_hit_type = pick("punch", "smash")
	if(ishuman(target) && target.check_shields(user, punch_damage, "[user]'s' [picked_hit_type]"))
		user.do_attack_animation(target)
		playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		return FALSE
	if(is_emped)
		do_the_punch(user, user)
	else
		do_the_punch(user, target)
	playsound(target.loc, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	playsound(target.loc, 'sound/weapons/genhit2.ogg', 50, TRUE)

	return TRUE

/datum/martial_art/muscle_implant/proc/do_the_punch(mob/living/carbon/human/puncher, mob/living/carbon/human/punchee)
	puncher.do_attack_animation(punchee, ATTACK_EFFECT_SMASH)
	add_attack_logs(puncher, punchee, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	punchee.apply_damage(punch_damage, BRUTE, puncher.zone_selected)

	if(!IS_HORIZONTAL(puncher)) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(punchee, puncher.dir)
		punchee.throw_at(throw_target, rand(1, 2), 0.5, puncher)

	var/picked_hit_type = pick("punch", "smash", "kick")
	punchee.visible_message(
		"<span class='danger'>[puncher] [picked_hit_type]ed [punchee]!</span>",
		"<span class='danger'>You're [picked_hit_type]ed by [puncher]!</span>",
		"<span class='danger'>You hear a sickening sound of flesh hitting flesh!</span>"
	)

	if(puncher == punchee)
		to_chat(puncher, "<span class='danger'>You [picked_hit_type] yourself!</span>")
	else
		to_chat(puncher, "<span class='danger'>You [picked_hit_type] [punchee]!</span>")

/datum/martial_art/muscle_implant/proc/emp_act(severity, mob/owner)
	is_emped = TRUE
	to_chat(owner, "<span class='danger'>Your arms spasm wildly!</span>")
	addtimer(CALLBACK(src, PROC_REF(reboot), owner), (18 / severity) SECONDS)

/datum/martial_art/muscle_implant/proc/reboot(mob/owner)
	is_emped = FALSE
	to_chat(owner, "<span class='danger'>Your arms stop spasming.</span>")
