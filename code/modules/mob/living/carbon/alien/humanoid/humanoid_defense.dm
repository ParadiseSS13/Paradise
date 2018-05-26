/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if(INTENT_HARM)
				var/damage = rand(1, 9)
				if(prob(90))
					if(HULK in M.mutations)//HULK SMASH
						damage = 15
						spawn(0)
							Paralyse(1)
							step_away(src, M, 15)
							sleep(3)
							step_away(src, M, 15)
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] has punched [src]!</span>", \
							"<span class='userdanger'>[M] has punched [src]!</span>")
					if((stat != DEAD) && (damage > 9||prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(2)
						visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
								"<span class='userdanger'>[M] has weakened [src]!</span>", \
								"<span class='danger'>You hear someone fall.</span>")
					adjustBruteLoss(damage)
					add_attack_logs(M, src, "Melee attacked with fists")
					updatehealth()
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")

			if(INTENT_DISARM)
				if(!lying)
					if(prob(5))//Very small chance to push an alien down.
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_attack_logs(M, src, "Pushed over")
						visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
								"<span class='userdanger'>[M] has pushed down [src]!</span>")
					else
						if(prob(50))
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
								"<span class='userdanger'>[M] has disarmed [src]!</span>")
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='danger'>[M] has attempted to disarm [src]!</span>")

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()