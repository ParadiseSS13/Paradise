/datum/gear/neck
	subtype_path = /datum/gear/neck
	slot = slot_neck
	sort_category = "Neck"

//Mantles
/datum/gear/neck/mantle
	display_name = "mantle"
	path = /obj/item/clothing/neck/mantle

/datum/gear/neck/old_scarf
	display_name = "old scarf"
	path = /obj/item/clothing/neck/mantle/old

/datum/gear/neck/regal_shawl
	display_name = "regal shawl"
	path = /obj/item/clothing/neck/mantle/regal

/datum/gear/neck/mantle/job
	subtype_path = /datum/gear/neck/mantle/job
	subtype_cost_overlap = FALSE

/datum/gear/neck/mantle/job/captain
	display_name = "mantle, captain"
	path = /obj/item/clothing/neck/mantle/captain
	allowed_roles = list("Captain")

/datum/gear/neck/mantle/job/chief_engineer
	display_name = "mantle, chief engineer"
	path = /obj/item/clothing/neck/mantle/chief_engineer
	allowed_roles = list("Chief Engineer")

/datum/gear/neck/mantle/job/chief_medical_officer
	display_name = "mantle, chief medical officer"
	path = /obj/item/clothing/neck/mantle/chief_medical_officer
	allowed_roles = list("Chief Medical Officer")

/datum/gear/neck/mantle/job/head_of_security
	display_name = "mantle, head of security"
	path = /obj/item/clothing/neck/mantle/head_of_security
	allowed_roles = list("Head of Security")

/datum/gear/neck/mantle/job/head_of_personnel
	display_name = "mantle, head of personnel"
	path = /obj/item/clothing/neck/mantle/head_of_personnel
	allowed_roles = list("Head of Personnel")

/datum/gear/neck/mantle/job/research_director
	display_name = "mantle, research director"
	path = /obj/item/clothing/neck/mantle/research_director
	allowed_roles = list("Research Director")

//Cloaks
/datum/gear/neck/cloak
	display_name = "cloak, grey"
	path = /obj/item/clothing/neck/cloak

/datum/gear/neck/cloak/job
	subtype_path = /datum/gear/neck/cloak/job
	subtype_cost_overlap = FALSE

/datum/gear/neck/cloak/job/healer
	display_name = "cloak, healer"
	path = /obj/item/clothing/neck/cloak/healer
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Intern", "Paramedic", "Brig Physician")

/datum/gear/neck/cloak/job/captain
	display_name = "cloak, captain"
	path = /obj/item/clothing/neck/cloak/captain
	allowed_roles = list("Captain")

/datum/gear/neck/cloak/job/nanotrasen_representative
	display_name = "cloak, nanotrasen representative"
	path = /obj/item/clothing/neck/cloak/nanotrasen_representative
	allowed_roles = list("Nanotrasen Representative")

/datum/gear/neck/cloak/job/blueshield
	display_name = "cloak, blueshield"
	path = /obj/item/clothing/neck/cloak/blueshield
	allowed_roles = list("Blueshield")

/datum/gear/neck/cloak/job/chief_engineer
	display_name = "cloak, chief engineer"
	path = /obj/item/clothing/neck/cloak/chief_engineer
	allowed_roles = list("Chief Engineer")

/datum/gear/neck/cloak/job/chief_engineer/white
	display_name = "cloak, chief engineer, white"
	path = /obj/item/clothing/neck/cloak/chief_engineer/white
	allowed_roles = list("Chief Engineer")

/datum/gear/neck/cloak/job/chief_medical_officer
	display_name = "cloak, chief medical officer"
	path = /obj/item/clothing/neck/cloak/chief_medical_officer
	allowed_roles = list("Chief Medical Officer")

/datum/gear/neck/cloak/job/head_of_security
	display_name = "cloak, head of security"
	path = /obj/item/clothing/neck/cloak/head_of_security
	allowed_roles = list("Head of Security")

/datum/gear/neck/cloak/security
	display_name = "cloak, security officer"
	path = /obj/item/clothing/neck/cloak/security
	allowed_roles = list("Head of Security", "Security Officer", "Warden", "Security Cadet", "Security Pod Pilot")

/datum/gear/neck/cloak/job/head_of_personnel
	display_name = "cloak, head of personnel"
	path = /obj/item/clothing/neck/cloak/head_of_personnel
	allowed_roles = list("Head of Personnel")

/datum/gear/neck/cloak/job/research_director
	display_name = "cloak, research director"
	path = /obj/item/clothing/neck/cloak/research_director
	allowed_roles = list("Research Director")

/datum/gear/neck/cloak/job/quartermaster
	display_name = "cloak, quartermaster"
	path = /obj/item/clothing/neck/cloak/quartermaster
	allowed_roles = list("Quartermaster")

//Ponchos
/datum/gear/neck/poncho
	display_name = "poncho, classic"
	path = /obj/item/clothing/neck/poncho

/datum/gear/neck/poncho/green
	display_name = "poncho, green"
	path = /obj/item/clothing/neck/poncho/green

/datum/gear/neck/poncho/red
	display_name = "poncho, red"
	path = /obj/item/clothing/neck/poncho/red

/datum/gear/neck/poncho/security
	display_name = "poncho, corporate"
	path = /obj/item/clothing/neck/poncho/security
	allowed_roles = list("Head of Security", "Security Officer", "Warden", "Security Cadet", "Security Pod Pilot")

