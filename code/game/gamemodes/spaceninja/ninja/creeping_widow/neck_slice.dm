/datum/martial_combo/ninja_martial_art/neck_slice
	name = "Neck Slice"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Opponent must be on the ground. Instantly kills him if you have a katana in your inactive hand and if you are focused. Consumes your focus for a long time after use."

/datum/martial_combo/ninja_martial_art/neck_slice/perform_combo(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/ninja_martial_art/creeping_widow)
	if(!ishuman(target))	// Комбо работает только на гуманоидов
		return MARTIAL_COMBO_DONE_BASIC_HIT
	if(target.IsWeakened() || target.resting || target.stat)
		if(creeping_widow.my_energy_katana && user.get_inactive_hand() == creeping_widow.my_energy_katana)
			if(creeping_widow.has_focus)
				user.say("悪気はないんだ...")
				creeping_widow.has_focus = 0
				var/cooldown = 3000
				user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
				if(!isgolem(target))
					playsound(get_turf(target), 'sound/weapons/katana-slice-loud.ogg', 75, TRUE, -1)
					target.visible_message("<span class='warning'>[user] cuts [target] throat with [creeping_widow.my_energy_katana]!</span>", \
									"<span class='userdanger'>[user] cuts your throat with [creeping_widow.my_energy_katana]!</span>")
					for(var/bodypart in target.bodyparts)
						var/obj/item/organ/external/current_organ = bodypart
						if(current_organ.limb_name == "head")
							current_organ.droplimb()	// Просто отрезаем голову. Можешь жить без головы? Значит тебе повезло! Или тебя добьют руками...
							break
				else
					playsound(get_turf(target), 'sound/weapons/blade_unsheath.ogg', 75, TRUE, -1)
					target.visible_message("<span class='warning'>[user] tries to cut [target] throat with [creeping_widow.my_energy_katana]! But fails!</span>", \
									"<span class='userdanger'>[user] tried to cut your throat with [creeping_widow.my_energy_katana]! But fails!</span>")
					cooldown = 300	// Меньше кд после использования, при провале отрезания головы
				add_attack_logs(user, target, "Melee attacked with martial-art [creeping_widow.name] :  Neck Slice")
				// Мгновенное убийство - большое кд! Если конечно это не провальная попытка отрезать голову голему
				addtimer(CALLBACK(creeping_widow, /datum/martial_art/ninja_martial_art/.proc/regain_focus, user), cooldown)
				return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_DONE_BASIC_HIT
