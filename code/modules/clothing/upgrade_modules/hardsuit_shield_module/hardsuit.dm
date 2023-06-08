/obj/item/clothing/suit/space/hardsuit
	var/obj/item/hardsuit_shield/shield = null

/obj/item/clothing/suit/space/hardsuit/New()
	. = ..()
	if(shield && ispath(shield))
		shield = new shield(src)
		shield.hardsuit = src

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/hardsuit_shield))
		var/obj/item/hardsuit_shield/new_shield = I
		if(shield)
			to_chat(user, "<span class='warning'>[src] already has a shield installed.</span>")
			return
		if(src == user.get_item_by_slot(slot_wear_suit))
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return
		if(user.unEquip(new_shield))
			new_shield.forceMove(src)
			shield = new_shield
			shield.hardsuit = src
			to_chat(user, "<span class='notice'>You successfully install the shield upgrade into [src].</span>")
			return

/obj/item/clothing/suit/space/hardsuit/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(shield)
		var/blocked = shield.hit_reaction(owner, hitby, attack_text, final_block_chance, damage, attack_type)
		if(blocked)
			return TRUE
	. = ..()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(shield)
		STOP_PROCESSING(SSobj, shield)
	return ..()

/obj/item/clothing/suit/space/hardsuit/special_overlays()
	. = ..()
	if(shield)
		return mutable_appearance('icons/effects/effects.dmi', shield.shield_state, MOB_LAYER + 0.01)

/obj/item/clothing/suit/space/hardsuit/multitool_act(mob/user, obj/item/I)
	. = ..()
	if(shield)
		shield.multitool_act(user, I)

//////Shielded Hardsuits

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	shield = /obj/item/hardsuit_shield

//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/syndi/shielded
	desc = "An advanced hardsuit with built in energy shielding and jetpack."
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/shielded
	jetpack = /obj/item/tank/jetpack/suit
	shield = /obj/item/hardsuit_shield/syndi
	resistance_flags = ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 20, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/shielded
	desc = "An advanced hardsuit helmet with built in energy shielding."
	resistance_flags = ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 20, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)

//////Wizard Versions
/obj/item/clothing/suit/space/hardsuit/wizard/shielded
	shield = /obj/item/hardsuit_shield/wizard

/obj/item/clothing/suit/space/hardsuit/wizard/arch/shielded
	shield = /obj/item/hardsuit_shield/wizard/arch

/obj/item/wizard_armour_charge
	name = "battlemage shield charges"
	desc = "A powerful rune that will increase the number of hits a suit of battlemage armour can take before failing.."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"

/obj/item/wizard_armour_charge/afterattack(obj/item/clothing/suit/space/hardsuit/wizard/W, mob/user)
	. = ..()
	if(!istype(W))
		to_chat(user, "<span class='warning'>The rune can only be used on battlemage armour!</span>")
		return
	if(!W.shield)
		to_chat(user, "<span class='warning'>No shield detected on this armour!</span>")
		return
	if(W == user.get_item_by_slot(slot_wear_suit))
		to_chat(user, "<span class='warning'>You cannot replenish charges to [W] while wearing it.</span>")
		return
	W.shield.current_charges += 8
	W.shield.shield_state = "[W.shield.shield_on]"
	playsound(loc, 'sound/magic/charge.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You charge [W]. It can now absorb [W.shield.current_charges] hits.</span>")
	qdel(src)
