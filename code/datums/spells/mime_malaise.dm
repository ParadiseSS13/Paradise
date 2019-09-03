/obj/effect/proc_holder/spell/targeted/touch/mime_malaise
	name = "Mime Malaise"
	desc = "A spell popular with theater nerd wizards and contrarian pranksters, this spell will put on a mime costume on the target, \
		stun them so that they may contemplate Art, and silence them. \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/mime_malaise
	school = "transmutation"

	charge_max = 300
	clothes_req = 1
	cooldown_min = 100 //50 deciseconds reduction per rank
	action_icon_state = "mime"

/obj/item/melee/touch_attack/mime_malaise
	name = "mime hand"
	desc = "..."
	catchphrase = null
	on_use_sound = null
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/mime_malaise/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.lying || user.handcuffed)
		return

	var/datum/effect_system/smoke_spread/s = new
	s.set_up(5, 0, target)
	s.start()

	var/mob/living/carbon/human/H = target
	H.mimetouched()
	..()

/mob/living/carbon/human/proc/mimetouched()
	Weaken(7)
	Stun(7)
	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed mime outfit. Replace with mime robes if we add those.
		unEquip(wear_mask, TRUE)
		unEquip(w_uniform, TRUE)
		unEquip(wear_suit, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/mime, slot_wear_mask, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/under/mime, slot_w_uniform, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/suspenders, slot_wear_suit, TRUE, TRUE)
		Silence(7)
	else
		qdel(wear_mask)
		qdel(w_uniform)
		qdel(wear_suit)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/mime/nodrop, slot_wear_mask, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/under/mime/nodrop, slot_w_uniform, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/suspenders/nodrop, slot_wear_suit, TRUE, TRUE)
		dna.SetSEState(MUTEBLOCK , TRUE, TRUE)
		genemutcheck(src, MUTEBLOCK , null, MUTCHK_FORCED)
		dna.default_blocks.Add(MUTEBLOCK)