/datum/martial_combo/krav_maga/leg_sweep
	name = "Leg Sweep"
	explaination_text = "Trips the victim, rendering them prone and unable to move for a short time."

/datum/martial_combo/krav_maga/leg_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target.stat || target.IsWeakened())
		return FALSE
	target.visible_message("<span class='warning'>[user] leg sweeps [target]!</span>", \
					  	"<span class='userdanger'>[user] leg sweeps you!</span>")
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	target.apply_damage(5, BRUTE)
	objective_damage(user, target, 5, BRUTE)
	target.Weaken(2)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Leg Sweep", ATKLOG_ALL)
	user.mind.martial_art.in_stance = FALSE
	return MARTIAL_COMBO_DONE_CLEAR_COMBOS
