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

/obj/item/energy_shuriken
	name = "energy shuriken"
	desc = "An ancient weapon, redefined. The blade hums with an electric edge, using itself as fuel."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "energy-shuriken"
	inhand_icon_state = "eshield0"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 5
	throwforce = 30 // This is never used on mobs since this has a 100% embed chance.
	throw_speed = 4
	embedded_pain_multiplier = 4
	w_class = WEIGHT_CLASS_SMALL
	embed_chance = 100
	embedded_fall_chance = 0
	sharp = TRUE
	resistance_flags = FIRE_PROOF

/obj/item/energy_shuriken/Initialize(mapload)
	. = ..()
	// Only lasts so long. Delete self after some time.
	addtimer(CALLBACK(src, PROC_REF(qdel)), 30 SECONDS)

/obj/item/energy_shuriken/throw_impact(atom/target)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	H.apply_damage(60, STAMINA)

/obj/item/shuriken_printer
	name = "shuriken printer"
	desc = "An advanced, tiny autofabricator that slowly creates and stores energy shurikens."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "shuriken-pouch"
	inhand_icon_state = "eshield0"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF

	new_attack_chain = TRUE
	/// What is the maximum number of energy shurikens the printer can hold?
	var/maximum_stars = 4
	/// What is the current number of energy shurikens the printer is holding?
	var/current_stars = 2
	/// How long the cooldown is to print more shurikens
	var/printing_time = 30 SECONDS
	/// Timer used to print stars
	var/fabrication_timer

/obj/item/shuriken_printer/Initialize(mapload)
	. = ..()
	fabrication_timer = addtimer(CALLBACK(src, PROC_REF(print_star)), 30 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/obj/item/shuriken_printer/activate_self(mob/user)
	..()
	var/obj/item/energy_shuriken/star = new /obj/item/energy_shuriken(get_turf(src), src)
	user.put_in_hands(star)
	to_chat(user, SPAN_NOTICE("You draw [star] from [src].")) // No period on purpose.

/obj/item/shuriken_printer/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It has [current_stars] stored.")

/obj/item/shuriken_printer/proc/print_star()
	if(current_stars < maximum_stars)
		current_stars++
