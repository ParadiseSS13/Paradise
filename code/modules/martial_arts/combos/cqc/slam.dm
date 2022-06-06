/datum/martial_combo/cqc/slam
	name = "Слэм"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Бросает оппонента на землю, сбивая его с ног."
	combo_text_override = "Захват, смена рук, вред"

/datum/martial_combo/cqc/slam/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(!target.IsWeakened() && !target.resting && !target.lying)
		target.visible_message("<span class='warning'>[user] броса[pluralize_ru(user.gender,"ет","ют")] [target] на землю!</span>", \
						  	"<span class='userdanger'>[user] бросил[pluralize_ru(user.gender,"","и")] вас на землю!</span>")
		playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, 1, -1)
		target.apply_damage(10, BRUTE)
		target.Weaken(2)
		add_attack_logs(user, target, "Melee attacked with martial-art [src] :  Slam", ATKLOG_ALL)
		return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
