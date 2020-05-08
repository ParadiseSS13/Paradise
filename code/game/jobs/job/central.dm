
// General-purpose CC official. Can hear out grievances, investigate cases, issue demotions, etc.
/datum/job/ntnavyofficer
	title = "Nanotrasen Navy Officer"
	flag = JOB_CENTCOM
	department_flag = JOB_CENTCOM // This gets its job as its own flag because admin jobs dont have flags
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
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
	)
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
	flag = JOB_CENTCOM
	department_flag = JOB_CENTCOM // This gets its job as its own flag because admin jobs dont have flags
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
	uniform = /obj/item/clothing/under/rank/centcom/captain
	suit = /obj/item/clothing/suit/space/deathsquad/officer
	back = /obj/item/storage/backpack/ert/security
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


// Mentor+ role for instructing new players
/datum/job/ntinstructor
	title = "Nanotrasen Instructor"
	flag = JOB_CENTCOM
	department_flag = JOB_CENTCOM
	total_positions = 1
	spawn_positions = 0
	supervisors = "the admins"
	selection_color = "#ffdddd"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_WEAPONS)
	mentor_only = TRUE
	outfit = /datum/outfit/job/ntinstructor

/datum/outfit/job/ntinstructor
	name = "Nanotrasen Instructor"
	jobtype = /datum/job/ntinstructor

	uniform = /obj/item/clothing/under/rank/centcom/representative // formal NT uniform
	shoes = /obj/item/clothing/shoes/centcom // fancy shoes
	head = /obj/item/clothing/head/beret/blue // generic blue beret
	l_ear = /obj/item/radio/headset/heads/ntinstructor //
	glasses =  /obj/item/clothing/glasses/hud/health/sunglasses // same as blueshield
	id = /obj/item/card/id/centcom
	belt = /obj/item/storage/belt/utility/full/multitool
	implants = list(
		/obj/item/implant/mindshield,
		/obj/item/implant/dust
	)
	backpack = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1,
		/obj/item/pinpointer/crew = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/laser_pointer/blue = 1

	)
	box = /obj/item/storage/box/centcominstructor

/datum/outfit/job/ntinstructor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.mind.offstation_role = TRUE