/obj/item/clothing/suit/space/hardsuit
	var/obj/item/hardsuit_taser_proof/taser_proof = null

/obj/item/clothing/suit/space/hardsuit/New()
	. = ..()
	if(taser_proof && ispath(taser_proof))
		taser_proof = new taser_proof(src)
		taser_proof.hardsuit = src

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/hardsuit_taser_proof))
		var/obj/item/hardsuit_taser_proof/new_taser_proof = I
		if(taser_proof)
			to_chat(user, "<span class='warning'>[src] already has a taser proof.</span>")
			return
		if(src == user.get_item_by_slot(slot_wear_suit)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return
		if(user.unEquip(new_taser_proof))
			new_taser_proof.forceMove(src)
			taser_proof = new_taser_proof
			taser_proof.hardsuit = src
			to_chat(user, "<span class='notice'>You successfully install the taser proof upgrade into [src].</span>")
			return

/obj/item/clothing/suit/space/hardsuit/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(taser_proof)
		var/blocked = taser_proof.hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)
		if(blocked)
			return TRUE
	. = ..()

/obj/item/clothing/suit/space/hardsuit/ToggleHelmet()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(taser_proof && taser_proof.ert_mindshield_locked)
			if(isertmindshielded(H))
				to_chat(H, "<span class='notice'>Access granted, identity verified...</span>")
			else
				to_chat(H, "<span class='warning'>Access denied. The user is not identified!</span>")
				return
	. = ..()

//////Taser-proof Hardsuits

/obj/item/clothing/suit/space/hardsuit/deathsquad
	taser_proof = /obj/item/hardsuit_taser_proof/ert_locked
