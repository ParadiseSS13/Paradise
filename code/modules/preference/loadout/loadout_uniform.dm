// Uniform slot
/datum/gear/uniform
	subtype_path = /datum/gear/uniform
	slot = slot_w_uniform
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/skirt
	subtype_path = /datum/gear/uniform/skirt

/datum/gear/uniform/skirt/blue
	display_name = "plaid skirt, blue"
	path = /obj/item/clothing/under/dress/plaid_blue

/datum/gear/uniform/skirt/purple
	display_name = "plaid skirt, purple"
	path = /obj/item/clothing/under/dress/plaid_purple

/datum/gear/uniform/skirt/red
	display_name = "plaid skirt, red"
	path = /obj/item/clothing/under/dress/plaid_red

/datum/gear/uniform/skirt/black
	display_name = "skirt, black"
	path = /obj/item/clothing/under/blackskirt

/datum/gear/uniform/skirt/job
	cost = 3
	subtype_path = /datum/gear/uniform/skirt/job
	subtype_cost_overlap = FALSE

/datum/gear/uniform/skirt/job/ce
	display_name = "skirt, ce"
	path = /obj/item/clothing/under/rank/chief_engineer/skirt
	allowed_roles = list("Chief Engineer")

/datum/gear/uniform/skirt/job/atmos
	display_name = "skirt, atmos"
	path = /obj/item/clothing/under/rank/atmospheric_technician/skirt
	allowed_roles = list("Chief Engineer","Atmospheric Technician")

/datum/gear/uniform/skirt/job/eng
	display_name = "skirt, engineer"
	path = /obj/item/clothing/under/rank/engineer/skirt
	allowed_roles = list("Chief Engineer","Station Engineer")

/datum/gear/uniform/skirt/job/roboticist
	display_name = "skirt, roboticist"
	path = /obj/item/clothing/under/rank/roboticist/skirt
	allowed_roles = list("Research Director","Roboticist")

/datum/gear/uniform/skirt/job/cmo
	display_name = "skirt, cmo"
	path = /obj/item/clothing/under/rank/chief_medical_officer
	allowed_roles = list("Chief Medical Officer")

/datum/gear/uniform/skirt/job/chem
	display_name = "skirt, chemist"
	path = /obj/item/clothing/under/rank/chemist/skirt
	allowed_roles = list("Chief Medical Officer","Chemist")

/datum/gear/uniform/skirt/job/viro
	display_name = "skirt, virologist"
	path = /obj/item/clothing/under/rank/virologist/skirt
	allowed_roles = list("Chief Medical Officer","Medical Doctor")

/datum/gear/uniform/skirt/job/med
	display_name = "skirt, medical"
	path = /obj/item/clothing/under/rank/medical/skirt
	allowed_roles = list("Chief Medical Officer","Medical Doctor","Chemist","Psychiatrist","Paramedic")

/datum/gear/uniform/skirt/job/sci
	display_name = "skirt, scientist"
	path = /obj/item/clothing/under/rank/scientist/skirt
	allowed_roles = list("Research Director","Scientist")

/datum/gear/uniform/skirt/job/cargo
	display_name = "skirt, cargo"
	path = /obj/item/clothing/under/rank/cargotech/skirt
	allowed_roles = list("Quartermaster","Cargo Technician")

/datum/gear/uniform/skirt/job/qm
	display_name = "skirt, QM"
	path = /obj/item/clothing/under/rank/cargo/skirt
	allowed_roles = list("Quartermaster")

/datum/gear/uniform/skirt/job/warden
	display_name = "skirt, warden"
	path = /obj/item/clothing/under/rank/warden/skirt
	allowed_roles = list("Head of Security", "Warden")

/datum/gear/uniform/skirt/job/security
	display_name = "skirt, security"
	path = /obj/item/clothing/under/rank/security/skirt
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/skirt/job/head_of_security
	display_name = "skirt, hos"
	path = /obj/item/clothing/under/rank/head_of_security/skirt
	allowed_roles = list("Head of Security")