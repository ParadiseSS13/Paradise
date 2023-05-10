/obj/item/hardsuit_taser_proof
	name = "Набор улучшения ТПРГ-1"
	desc = "Данное улучшение позволяет хардсьюту поглащать слабые энергетические снаряды."
	icon = 'icons/obj/hardsuits_modules.dmi'
	icon_state = "powersink"
	var/obj/item/clothing/suit/space/hardsuit/hardsuit = null
	var/ert_mindshield_locked = FALSE

/obj/item/hardsuit_taser_proof/ert_locked
	name = "Набор улучшения ТПРГ-1"
	desc = "Данное улучшение позволяет хардсьюту поглащать слабые энергетические снаряды. Для использования хардсьюта необходим ЕРТ МЩ имплант."
	ert_mindshield_locked = TRUE

/obj/item/storage/box/ert_taser_proof
	name = "Taser Proof Upgrade Box"
	desc = "A Exclusive and Expensive upgrade for Hardsuits."
	icon_state = "box_ert"
	var/ert_locked = FALSE

/obj/item/storage/box/ert_taser_proof/ert_locked
	name = "Taser Proof Upgrade Box"
	desc = "A Exclusive and Expensive upgrade for Hardsuits. Requires ERT MindShield implant."
	icon_state = "box_ert"
	ert_locked = TRUE

/obj/item/storage/box/ert_taser_proof/populate_contents()
	if(!ert_locked)
		for(var/I in 1 to 7)
			new /obj/item/hardsuit_taser_proof(src)
	else
		for(var/I in 1 to 7)
			new /obj/item/hardsuit_taser_proof/ert_locked(src)

/obj/item/hardsuit_taser_proof/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!hardsuit)
		return FALSE
	if(!hardsuit.suittoggled)
		return FALSE
	var/obj/item/projectile/P = hitby
	if(P.shockbull)
		return TRUE
	return FALSE
