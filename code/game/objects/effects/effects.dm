
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	burn_state = LAVA_PROOF | FIRE_PROOF
	resistance_flags = INDESTRUCTIBLE
	anchored = 1
	can_be_hit = FALSE

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/fire_act()
	return

/obj/effect/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	return FALSE