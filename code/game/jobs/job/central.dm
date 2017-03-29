
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
	l_ear = /obj/item/device/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/gun/energy/pulse/pistol = 1,
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/implanter/death_alarm = 1
	)

	implants = list(/obj/item/weapon/implant/loyalty)

	backpack = /obj/item/weapon/storage/backpack/satchel



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

	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/deathsquad/officer
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/beret/centcom/officer/navy
	l_ear = /obj/item/device/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/centcom
	pda = /obj/item/device/pda/centcom
	backpack_contents = list(
		/obj/item/weapon/implanter/dust = 1,
		/obj/item/weapon/gun/energy/pulse/pistol/m1911 = 1,
		/obj/item/weapon/implanter/death_alarm = 1
	)

	implants = list(/obj/item/weapon/implant/loyalty)

	backpack = /obj/item/weapon/storage/backpack/satchel