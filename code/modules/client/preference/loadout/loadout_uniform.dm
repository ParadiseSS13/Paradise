// Uniform slot
/datum/gear/uniform
	subtype_path = /datum/gear/uniform
	slot = slot_w_uniform
	cost = 2
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
	allowed_roles = list("Chief Medical Officer","Medical Doctor","Chemist","Psychiatrist","Paramedic","Brig Physician")

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

/datum/gear/uniform/sec
	subtype_path = /datum/gear/uniform/sec

/datum/gear/uniform/sec/formal
	display_name = "security uniform, formal"
	path = /obj/item/clothing/under/rank/security/formal
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/sec/secorporate
	display_name = "security uniform, corporate"
	path = /obj/item/clothing/under/rank/security/corp
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/sec/dispatch
	display_name = "security uniform, dispatch"
	path = /obj/item/clothing/under/rank/dispatch
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/sec/casual
	display_name = "security uniform, casual"
	path = /obj/item/clothing/under/rank/security2
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective", "Security Pod Pilot")

/datum/gear/uniform/shorts
	subtype_path = /datum/gear/uniform/shorts

/datum/gear/uniform/shorts/red
	display_name = "shorts, red"
	path = /obj/item/clothing/under/shorts/red

/datum/gear/uniform/shorts/green
	display_name = "shorts, green"
	path = /obj/item/clothing/under/shorts/green

/datum/gear/uniform/shorts/blue
	display_name = "shorts, blue"
	path = /obj/item/clothing/under/shorts/blue

/datum/gear/uniform/shorts/black
	display_name = "shorts, black"
	path = /obj/item/clothing/under/shorts/black

/datum/gear/uniform/shorts/grey
	display_name = "shorts, grey"
	path = /obj/item/clothing/under/shorts/grey

/datum/gear/uniform/pants
	subtype_path = /datum/gear/uniform/pants

/datum/gear/uniform/pants/jeans
	display_name = "jeans, classic"
	path = /obj/item/clothing/under/pants/classicjeans

/datum/gear/uniform/pants/mjeans
	display_name = "jeans, mustang"
	path = /obj/item/clothing/under/pants/mustangjeans

/datum/gear/uniform/pants/bljeans
	display_name = "jeans, black"
	path = /obj/item/clothing/under/pants/blackjeans

/datum/gear/uniform/pants/yfjeans
	display_name = "jeans, Young Folks"
	path = /obj/item/clothing/under/pants/youngfolksjeans

/datum/gear/uniform/pants/whitepants
	display_name = "pants, white"
	path = /obj/item/clothing/under/pants/white

/datum/gear/uniform/pants/redpants
	display_name = "pants, red"
	path = /obj/item/clothing/under/pants/red

/datum/gear/uniform/pants/blackpants
	display_name = "pants, black"
	path = /obj/item/clothing/under/pants/black

/datum/gear/uniform/pants/tanpants
	display_name = "pants, tan"
	path = /obj/item/clothing/under/pants/tan

/datum/gear/uniform/pants/bluepants
	display_name = "pants, blue"
	path = /obj/item/clothing/under/pants/blue

/datum/gear/uniform/pants/trackpants
	display_name = "trackpants"
	path = /obj/item/clothing/under/pants/track

/datum/gear/uniform/pants/khakipants
	display_name = "pants, khaki"
	path = /obj/item/clothing/under/pants/khaki

/datum/gear/uniform/pants/caopants
	display_name = "pants, camo"
	path = /obj/item/clothing/under/pants/camo
