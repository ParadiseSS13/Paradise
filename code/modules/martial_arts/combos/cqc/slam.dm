/datum/martial_combo/cqc/slam
	name = "Slam"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Slam opponent into the ground, knocking them down."
	combo_text_override = "Grab, switch hands, Harm"

/datum/martial_combo/cqc/slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.IsWeakened() && !target.resting && !target.lying)
		target.visible_message("<span class='warning'>[user] slams [target] into the ground!</span>", \
						  	"<span class='userdanger'>[user] slams you into the ground!</span>")
		playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, 1, -1)
		target.apply_damage(10, BRUTE)
		target.Weaken(2)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Slam", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
