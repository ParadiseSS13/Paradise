/datum/martial_art/muscle_implant
	name = "Empowered muscle implant fighting"
	weight = 1

/datum/martial_art/muscle_implant/harm_act(mob/living/carbon/human/user, mob/living/carbon/human/target)
	MARTIAL_ARTS_ACT_CHECK

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to hurt [target]!</span>")
		return FALSE

	var/punch_damage = 13 // So the magic numbers are explained user bit more
	var/picked_hit_type = pick("punch", "smash", "kick")
	var/is_emp = HAS_TRAIT(user, MUSCLE_SPASMS)

	if(is_emp) // I am sorry
		var/temp = user
		user = target
		target = temp

	if(ishuman(target))
		if(target.check_shields(user, punch_damage, "[user]'s' [picked_hit_type]"))
			user.do_attack_animation(target)
			playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			return FALSE

	if(is_emp)
		target.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	else
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(target.loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(target.loc, 'sound/weapons/genhit2.ogg', 50, 1)

	target.apply_damage(punch_damage, BRUTE, user.zone_selected)

	if(!IS_HORIZONTAL(user)) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, rand(1, 2), 0.5, user)

	target.visible_message(
		"<span class='danger'>[user] [picked_hit_type]ed [target]!</span>",
		"<span class='danger'>You're [picked_hit_type]ed by [user]!</span>",
		"<span class='danger'>You hear user sickening sound of flesh hitting flesh!</span>",
	)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	to_chat(user, "<span class='danger'>You [picked_hit_type] [target]!</span>")

	return TRUE
