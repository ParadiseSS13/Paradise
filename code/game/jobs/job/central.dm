
// General-purpose CC official. Can hear out grievances, investigate cases, issue demotions, etc.
/datum/job/ntnavyofficer
	title = "Nanotrasen Navy Officer"
	flag = CENTCOM
	department_flag = CENTCOM
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ffdddd"
	access = list()
	minimal_access = list()
	admin_only = 1
	outfit = /datum/outfit/job/ntnavyofficer

/datum/job/ntnavyofficer/get_access()
	return get_centcom_access(title)

/datum/outfit/job/ntnavyofficer
	name = "Nanotrasen Navy Officer"
	jobtype = /datum/job/ntnavyofficer

	uniform = /obj/item/clothing/under/rank/centcom/officer
	gloves =  /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/officer
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	belt = /obj/item/gun/energy/pulse/pistol
	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/dust
	)
	backpack = /obj/item/storage/backpack/satchel
	box = /obj/item/storage/box/centcomofficer
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	)

/datum/outfit/job/ntnavyofficer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.mind.offstation_role = TRUE

// CC Officials who lead ERTs, Death Squads, etc.
/datum/job/ntspecops
	title = "Special Operations Officer"
	flag = CENTCOM
	department_flag = CENTCOM
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ffdddd"
	access = list()
	minimal_access = list()
	admin_only = 1
	spawn_ert = 1
	outfit = /datum/outfit/job/ntspecops

/datum/job/ntspecops/get_access()
	return get_centcom_access(title)

/datum/outfit/job/ntspecops
	name = "Special Operations Officer"
	jobtype = /datum/job/ntspecops
	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/space/deathsquad/officer
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/military/assault
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/helmet/space/deathsquad/beret
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	r_pocket = /obj/item/storage/box/matches
	box = /obj/item/storage/box/centcomofficer
	backpack = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/clothing/shoes/magboots/advance = 1,
		/obj/item/storage/box/zipties = 1
	)
	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/dust
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/xray,
		/obj/item/organ/internal/cyberimp/brain/anti_stun,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/obj/item/organ/internal/cyberimp/arm/combat/centcom
	)

/datum/outfit/job/ntspecops/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.mind.offstation_role = TRUE