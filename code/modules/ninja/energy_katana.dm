/obj/item/katana/energy
	name = "energy katana"
	desc = "A plastitanium katana with a reinforced emitter edge. A ninja's most reliable tool."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "energy_katana"
	force = 30
	embed_chance = 75
	throwforce = 20
	armor_penetration_percentage = 50
	armor_penetration_flat = 10
	hitsound = 'sound/weapons/blade1.ogg'

	new_attack_chain = TRUE

/obj/item/katana/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(!.) // they did not block the attack
		return
	if(isprojectile(hitby))
		var/obj/projectile/P = hitby
		if(P.reflectability == REFLECTABILITY_ENERGY)
			owner.visible_message(SPAN_DANGER("[owner] parries [attack_text] with [src]!"))
			add_attack_logs(P.firer, src, "hit by [P.type] but got parried by [src]")
			return -1
		owner.visible_message(SPAN_DANGER("[owner] blocks [attack_text] with [src]!"))
		playsound(src, 'sound/weapons/effects/ric3.ogg', 100, TRUE)
		return TRUE
	return TRUE
