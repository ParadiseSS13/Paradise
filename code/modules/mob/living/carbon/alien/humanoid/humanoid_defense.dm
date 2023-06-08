/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if(INTENT_HARM)
				var/damage = rand(1, 9)
				if(prob(90))
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] ударил[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>", \
							"<span class='userdanger'>[M] ударил[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>")
					if((stat != DEAD) && (damage > 9||prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(2)
						visible_message("<span class='danger'>[M] ослабил[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>", \
								"<span class='userdanger'>[M] ослабил[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>", \
								"<span class='danger'>Вы слышите, как кто-то упал.</span>")
					adjustBruteLoss(damage)
					add_attack_logs(M, src, "Melee attacked with fists")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] попытал[genderize_ru(M.gender,"ся","ась","ось","ись")] ударить [src.name]!</span>")

			if(INTENT_DISARM)
				if(!lying)
					if(prob(5))//Very small chance to push an alien down.
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_attack_logs(M, src, "Pushed over")
						visible_message("<span class='danger'>[M] опрокинул[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>", \
								"<span class='userdanger'>[M] опрокинул[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>")
					else
						if(prob(50))
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[M] обезоружил[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>", \
								"<span class='userdanger'>[M] обезоружил[genderize_ru(M.gender,"","а","о","и")] [src.name]!</span>")
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='danger'>[M] попытал[genderize_ru(M.gender,"ся","ась","ось","ись")] обезоружить [src.name]!</span>")

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
