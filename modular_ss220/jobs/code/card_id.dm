/mob/living/carbon/human/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon = 'icons/mob/hud/sechud.dmi'
	if(wear_id && (wear_id.get_job_name() in GLOB.all_jobs_ss220))
		holder.icon = 'modular_ss220/jobs/icons/hud.dmi'
	. = ..()

/obj/item/get_job_name() //Used in secHUD icon generation
	var/assignmentName = get_ID_assignment(if_no_id = "Unknown")
	var/rankName = get_ID_rank(if_no_id = "Unknown")

	var/list/titles = GLOB.all_jobs_ss220

	if(assignmentName in titles) //Check if the job has a hud icon
		return assignmentName
	if(rankName in titles)
		return rankName

	. = ..()

GLOBAL_LIST_INIT(card_skins_ss220, list(
	"intern", "student", "trainee", "cadet",	// novice
))

GLOBAL_LIST_INIT(card_skins_donor_ss220, list(
	"barber", "bath", "casino", "waiter", "acolyte", "deliverer", "wrestler", "painter", "musician", "actor",			// 2 tier
	"administrator", "touristtsf", "touristussp", "cliningmanajer", "apprentice", "guard", "migrant", "uncertain",	// 3 tier
	"adjutant", "butler", "maid", "representativetsf", "representativeussp", "dealer", // 4 tier
	"vipcorporateguest", "banker", "securityclown",	// 5 tier
))

/obj/item/card/id/syndicate/Initialize()
	. = ..()
	appearances |= GLOB.card_skins_ss220 + GLOB.card_skins_donor_ss220

/obj/item/card/id/medical/intern
	name = "Intern ID"
	registered_name = "Intern"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "intern"
	rank = "Medical Intern"

/obj/item/card/id/research/student
	name = "Student ID"
	registered_name = "Student"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "student"

/obj/item/card/id/engineering/trainee
	name = "Trainee ID"
	registered_name = "Trainee"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "trainee"

/obj/item/card/id/security/cadet
	name = "Cadet ID"
	registered_name = "Cadet"
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "cadet"

/obj/item/card/id/barber
	name = "Barber ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "barber"

/obj/item/card/id/bath
	name = "Bath ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "bath"

/obj/item/card/id/casino
	name = "Casino ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_HYDROPONICS, ACCESS_BAR)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "casino"

/obj/item/card/id/waiter
	name = "Waiter ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "waiter"

/obj/item/card/id/acolyte
	name = "Acolyte ID"
	access = list(ACCESS_CHAPEL_OFFICE, ACCESS_MAINT_TUNNELS)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "acolyte"

/obj/item/card/id/courier
	name = "Deliverer ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_MINT, ACCESS_MINERAL_STOREROOM)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "deliverer"

/obj/item/card/id/wrestler
	name = "Wrestler ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_RC_ANNOUNCE)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "wrestler"

/obj/item/card/id/painter
	name = "Painter ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "painter"

/obj/item/card/id/musican
	name = "Musician ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "musician"

/obj/item/card/id/actor
	name = "Actor ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "actor"

/obj/item/card/id/administrator
	name = "Administrator ID"
	access = list(ACCESS_THEATRE, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_MINERAL_STOREROOM, ACCESS_JANITOR)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "administrator"

/obj/item/card/id/tourist_tsf
	name = "Tourist TSF ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "touristtsf"

/obj/item/card/id/tourist_ussp
	name = "Tourist USSP ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "touristussp"

/obj/item/card/id/cleaning_manager
	name = "Clining Manager ID"
	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MEDICAL)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "cleaningmanager"

/obj/item/card/id/apprentice
	name = "Apprentice ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "apprentice"

/obj/item/card/id/guard
	name = "Guard ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_LIBRARY)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "guard"

/obj/item/card/id/migrant
	name = "Migrant ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "migrant"

/obj/item/card/id/uncertain
	name = "Uncertain ID"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "uncertain"

/obj/item/card/id/adjutant
	name = "Adjutant ID"
	access = list(ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_EVA, ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "adjutant"
	item_state = "silver-id"

/obj/item/card/id/butler
	name = "Butler ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_EVA, ACCESS_LAWYER)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "butler"

/obj/item/card/id/maid
	name = "Maid ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_EVA, ACCESS_LAWYER)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "maid"

/obj/item/card/id/representative_tsf
	name = "Representative TSF ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_EVA)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "representativetsf"
	item_state = "silver-id"

/obj/item/card/id/representative_ussp
	name = "Representative USSP ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_EVA)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "representativeussp"
	item_state = "silver-id"

/obj/item/card/id/dealer
	name = "Dealer ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_RC_ANNOUNCE, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_MINT, ACCESS_MINERAL_STOREROOM, ACCESS_CONSTRUCTION)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "dealer"

/obj/item/card/id/vip_guest
	name = "VIP Guest ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_EVA)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "vipcorporateguest"
	item_state = "gold-id"

/obj/item/card/id/banker
	name = "Banker ID"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_LIBRARY, ACCESS_EVA)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "banker"
	item_state = "gold-id"

/obj/item/card/id/seclown
	name = "Security Clown ID"
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT)
	icon = 'modular_ss220/aesthetics/better_ids/icons/better_ids.dmi'
	icon_state = "securityclown"
