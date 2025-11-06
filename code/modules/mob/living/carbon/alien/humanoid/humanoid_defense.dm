/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to hurt [src]!</span>")
			return FALSE
		..(user, TRUE)
		adjustBruteLoss(10)
		var/hitverb = "punched"
		if(mob_size < MOB_SIZE_LARGE)
			Stun(2 SECONDS)
			throw_at(get_edge_target_turf(user, get_dir(user, src)), 3, 7)
			hitverb = "slammed"
		playsound(loc, "punch", 25, TRUE, -1)
		visible_message("<span class='danger'>[user] has [hitverb] [src]!</span>", "<span class='userdanger'>[user] has [hitverb] [src]!</span>")
		return TRUE

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if(INTENT_HARM)
				var/damage = rand(1, 9)
				if(prob(90))
					playsound(loc, "punch", 25, TRUE, -1)
					visible_message("<span class='danger'>[M] has punched [src]!</span>", \
							"<span class='userdanger'>[M] has punched [src]!</span>")
					if((stat != DEAD) && (damage > 9||prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(4 SECONDS)
						visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
								"<span class='userdanger'>[M] has weakened [src]!</span>", \
								"<span class='danger'>You hear someone fall.</span>")
					adjustBruteLoss(damage)
					add_attack_logs(M, src, "Melee attacked with fists")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
					visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")

			if(INTENT_DISARM)
				if(!IS_HORIZONTAL(src))
					if(prob(5))//Very small chance to push an alien down.
						Paralyse(4 SECONDS)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
						add_attack_logs(M, src, "Pushed over")
						visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
								"<span class='userdanger'>[M] has pushed down [src]!</span>")
					else
						if(prob(50))
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
								"<span class='userdanger'>[M] has disarmed [src]!</span>")
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
							visible_message("<span class='danger'>[M] has attempted to disarm [src]!</span>")

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon && !get_active_hand())
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
