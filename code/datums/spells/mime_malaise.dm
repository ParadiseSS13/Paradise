/obj/effect/proc_holder/spell/touch/mime_malaise
	name = "Mime Malaise"
	desc = "A spell popular with theater nerd wizards and contrarian pranksters, this spell will put on a mime costume on the target, \
		stun them so that they may contemplate Art, and silence them. \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/mime_malaise
	school = "transmutation"

	base_cooldown = 30 SECONDS
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	clothes_req = TRUE

	action_icon_state = "mime_curse"


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
	s.set_up(5, FALSE, target)
	s.start()

	var/mob/living/carbon/human/H = target
	H.mimetouched()
	..()


/mob/living/carbon/human/proc/mimetouched()
	Weaken(14 SECONDS)
	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed mime outfit. Replace with mime robes if we add those.
		drop_item_ground(wear_mask, force = TRUE)
		drop_item_ground(w_uniform, force = TRUE)
		drop_item_ground(wear_suit, force = TRUE)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime, slot_wear_mask)
		equip_to_slot_or_del(new /obj/item/clothing/under/mime, slot_w_uniform)
		equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders, slot_wear_suit)
		Silence(14 SECONDS)
	else
		qdel(wear_mask)
		qdel(w_uniform)
		qdel(wear_suit)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime/nodrop, slot_wear_mask)
		equip_to_slot_or_del(new /obj/item/clothing/under/mime/nodrop, slot_w_uniform)
		equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders/nodrop, slot_wear_suit)
		dna.SetSEState(GLOB.muteblock, TRUE, TRUE)
		genemutcheck(src, GLOB.muteblock, null, MUTCHK_FORCED)
		dna.default_blocks.Add(GLOB.muteblock)

