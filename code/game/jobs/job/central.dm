
// General-purpose CC official. Can hear out grievances, investigate cases, issue demotions, etc.
/datum/job/ntnavyofficer
	title = "Nanotrasen Navy Officer"
	flag = CENTCOM
	department_flag = CENTCOM
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/centcom
	access = list()
	minimal_access = list()
	admin_only = 1

/datum/job/ntnavyofficer/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/rank/centcom/officer(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/centcom(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/gloves/color/white(H), slot_gloves)
	H.equip_or_collect(new /obj/item/device/radio/headset/centcom(H), slot_l_ear)
	H.equip_or_collect(new /obj/item/clothing/head/beret/centcom/officer(H), slot_head)
	H.equip_or_collect(new /obj/item/device/pda/centcom(H), slot_wear_pda)
	H.equip_or_collect(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
	H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/gun/energy/pulse/pistol(H), slot_in_backpack)

	H.equip_or_collect(new /obj/item/weapon/implanter/dust(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/implanter/death_alarm(H), slot_in_backpack)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	H.sec_hud_set_implants()
	return 1

/datum/job/ntnavyofficer/get_access()
	return get_centcom_access(title)


// CC Officials who lead ERTs, Death Squads, etc.
/datum/job/ntspecops
	title = "Special Operations Officer"
	flag = CENTCOM
	department_flag = CENTCOM
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/centcom
	access = list()
	minimal_access = list()
	admin_only = 1
	spawn_ert = 1

/datum/job/ntspecops/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/syndicate/combat(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/combat(H), slot_shoes)
	H.equip_or_collect(new /obj/item/clothing/gloves/combat(H), slot_gloves)
	H.equip_or_collect(new /obj/item/device/radio/headset/centcom(H), slot_l_ear)
	H.equip_or_collect(new /obj/item/clothing/head/beret/centcom/officer/navy(H), slot_head)
	H.equip_or_collect(new /obj/item/device/pda/centcom(H), slot_wear_pda)
	H.equip_or_collect(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
	H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_or_collect(new /obj/item/clothing/suit/space/deathsquad/officer(H), slot_wear_suit)
	H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/implanter/dust(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/gun/energy/pulse/pistol/m1911(H), slot_belt)
	H.equip_or_collect(new /obj/item/weapon/implanter/death_alarm(H), slot_in_backpack)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	H.sec_hud_set_implants()
	return 1

/datum/job/ntspecops/get_access()
	return get_centcom_access(title)
