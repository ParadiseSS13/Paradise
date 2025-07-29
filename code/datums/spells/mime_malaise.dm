/datum/spell/touch/mime_malaise
	name = "Mime Malaise"
	desc = "A spell popular with theater nerd wizards and contrarian pranksters. This spell will put on a mime costume on the target, \
		stun them so that they may contemplate Art, and silence them. \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/mime_malaise

	base_cooldown = 300
	cooldown_min = 100 //50 deciseconds reduction per rank
	action_icon_state = "mime_curse"

/obj/item/melee/touch_attack/mime_malaise
	name = "mime hand"
	desc = "..."
	catchphrase = null
	on_use_sound = null
	icon_state = "fleshtostone"

/obj/item/melee/touch_attack/mime_malaise/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || target == user || blocked_by_antimagic || !ishuman(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/datum/effect_system/smoke_spread/s = new
	s.set_up(5, FALSE, target)
	s.start()

	var/mob/living/carbon/human/H = target
	H.mimetouched()
	handle_delete(user)

/mob/living/carbon/human/proc/mimetouched()
	Weaken(14 SECONDS)
	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed mime outfit. Replace with mime robes if we add those.
		drop_item_to_ground(wear_mask, force = TRUE)
		drop_item_to_ground(w_uniform, force = TRUE)
		drop_item_to_ground(wear_suit, force = TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/mime, ITEM_SLOT_MASK, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/under/rank/civilian/mime, ITEM_SLOT_JUMPSUIT, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/suspenders, ITEM_SLOT_OUTER_SUIT, TRUE, TRUE)
		Silence(14 SECONDS)
	else
		qdel(wear_mask)
		qdel(w_uniform)
		qdel(wear_suit)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/mime/nodrop, ITEM_SLOT_MASK, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/under/rank/civilian/mime/nodrop, ITEM_SLOT_JUMPSUIT, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/suspenders/nodrop, ITEM_SLOT_OUTER_SUIT, TRUE, TRUE)
		dna.SetSEState(GLOB.muteblock , TRUE, TRUE)
		singlemutcheck(src, GLOB.muteblock, MUTCHK_FORCED)
		dna.default_blocks.Add(GLOB.muteblock)
