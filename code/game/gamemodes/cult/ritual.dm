/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon_state = "blood_dagger"
	item_state = "blood_dagger"
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	armour_penetration_flat = 35
	sprite_sheets_inhand = null // Override parent

/obj/item/melee/cultblade/dagger/adminbus
	name = "ritual dagger of scribing, +1"
	desc = "VERY fast culto scribing at incredible high speed!"
	force = 16
	toolspeed = 0.1

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(dagger_icon, "blood_dagger")
	item_state = GET_CULT_DATA(dagger_icon, "blood_dagger")

/obj/item/melee/cultblade/dagger/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || user.stat == DEAD)
		. += "<span class='cult'>A dagger gifted by [GET_CULT_DATA(entity_title3, "your god")]. Allows the scribing of runes and access to the knowledge archives of the cult of [GET_CULT_DATA(entity_name, "your god")].</span>"
		. += "<span class='cultitalic'>Striking another cultist with it will purge holy water from them.</span>"
		. += "<span class='cultitalic'>Striking a noncultist will tear their flesh, additionally, if you recently downed them with cult magic it will stun them completely.</span>"

/obj/item/melee/cultblade/dagger/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(IS_CULTIST(target))
		if(target.reagents && target.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			if(target == user) // Targeting yourself
				to_chat(user, "<span class='warning'>You can't remove holy water from yourself!</span>")

			else // Targeting someone else
				to_chat(user, "<span class='cult'>You remove the taint from [target].</span>")
				to_chat(target, "<span class='cult'>[user] removes the taint from your body.</span>")
				target.reagents.del_reagent("holywater")
				add_attack_logs(user, target, "Hit with [src], removing the holy water from them")

		return FINISH_ATTACK

/obj/item/melee/cultblade/dagger/activate_self(mob/user)
	if(..())
		return

	if(IS_CULTIST(user))
		scribe_rune(user)
	else
		to_chat(user, "<span class='warning'>[src] is covered in unintelligible shapes and markings.</span>")
