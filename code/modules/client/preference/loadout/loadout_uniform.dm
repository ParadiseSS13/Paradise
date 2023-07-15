/*
######################################################################################
##																					##
##								IMPORTANT README									##
##																					##
##	  Changing any /datum/gear typepaths --WILL-- break people's loadouts.			##
##	The typepaths are stored directly in the `characters.gear` column of the DB.	##
##		Please inform the server host if you wish to modify any of these.			##
##																					##
######################################################################################
*/


// Uniform slot
/datum/gear/uniform
	main_typepath = /datum/gear/uniform
	slot = slot_w_uniform
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/suit
	main_typepath = /datum/gear/uniform/suit

//there's a lot more colors than I thought there were @_@

/datum/gear/uniform/suit/jumpsuitblack
	display_name = "Jumpsuit, black"
	path = /obj/item/clothing/under/color/black

/datum/gear/uniform/suit/jumpsuitblue
	display_name = "Jumpsuit, blue"
	path = /obj/item/clothing/under/color/blue

/datum/gear/uniform/suit/jumpsuitgreen
	display_name = "Jumpsuit, green"
	path = /obj/item/clothing/under/color/green

/datum/gear/uniform/suit/jumpsuitgrey
	display_name = "Jumpsuit, grey"
	path = /obj/item/clothing/under/color/grey

/datum/gear/uniform/suit/jumpsuitorange
	display_name = "Jumpsuit, orange"
	path = /obj/item/clothing/under/color/orange

/datum/gear/uniform/suit/jumpsuitpink
	display_name = "Jumpsuit, pink"
	path = /obj/item/clothing/under/color/pink

/datum/gear/uniform/suit/jumpsuitred
	display_name = "Jumpsuit, red"
	path = /obj/item/clothing/under/color/red

/datum/gear/uniform/suit/jumpsuitwhite
	display_name = "Jumpsuit, white"
	path = /obj/item/clothing/under/color/white

/datum/gear/uniform/suit/jumpsuityellow
	display_name = "Jumpsuit, yellow"
	path = /obj/item/clothing/under/color/yellow

/datum/gear/uniform/suit/jumpsuitlightblue
	display_name = "Jumpsuit, lightblue"
	path = /obj/item/clothing/under/color/lightblue

/datum/gear/uniform/suit/jumpsuitaqua
	display_name = "Jumpsuit, aqua"
	path = /obj/item/clothing/under/color/aqua

/datum/gear/uniform/suit/jumpsuitpurple
	display_name = "Jumpsuit, purple"
	path = /obj/item/clothing/under/color/purple

/datum/gear/uniform/suit/jumpsuitlightpurple
	display_name = "Jumpsuit, lightpurple"
	path = /obj/item/clothing/under/color/lightpurple

/datum/gear/uniform/suit/jumpsuitlightgreen
	display_name = "Jumpsuit, lightgreen"
	path = /obj/item/clothing/under/color/lightgreen

/datum/gear/uniform/suit/jumpsuitlightbrown
	display_name = "Jumpsuit, lightbrown"
	path = /obj/item/clothing/under/color/lightbrown

/datum/gear/uniform/suit/jumpsuitbrown
	display_name = "Jumpsuit, brown"
	path = /obj/item/clothing/under/color/brown

/datum/gear/uniform/suit/jumpsuityellowgreen
	display_name = "Jumpsuit, yellowgreen"
	path = /obj/item/clothing/under/color/yellowgreen

/datum/gear/uniform/suit/jumpsuitdarkblue
	display_name = "Jumpsuit, darkblue"
	path = /obj/item/clothing/under/color/darkblue

/datum/gear/uniform/suit/jumpsuitlightred
	display_name = "Jumpsuit, lightred"
	path = /obj/item/clothing/under/color/lightred

/datum/gear/uniform/suit/jumpsuitdarkred
	display_name = "Jumpsuit, darkred"
	path = /obj/item/clothing/under/color/darkred

/datum/gear/uniform/suit/soviet
	display_name = "Old USSP uniform"
	path = /obj/item/clothing/under/costume/soviet

/datum/gear/uniform/suit/kilt
	display_name = "Kilt"
	path = /obj/item/clothing/under/costume/kilt

/datum/gear/uniform/skirt
	main_typepath = /datum/gear/uniform/skirt

/datum/gear/uniform/skirt/blue
	display_name = "Plaid skirt, blue"
	path = /obj/item/clothing/under/dress/plaid_blue

/datum/gear/uniform/skirt/purple
	display_name = "Plaid skirt, purple"
	path = /obj/item/clothing/under/dress/plaid_purple

/datum/gear/uniform/skirt/red
	display_name = "Plaid skirt, red"
	path = /obj/item/clothing/under/dress/plaid_red

/datum/gear/uniform/skirt/black
	display_name = "Skirt, black"
	path = /obj/item/clothing/under/dress/blackskirt

/datum/gear/uniform/skirt/job
	main_typepath = /datum/gear/uniform/skirt/job
	subtype_selection_cost = FALSE

/datum/gear/uniform/skirt/job/ce
	display_name = "Skirt, ce"
	path = /obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	allowed_roles = list("Chief Engineer")

/datum/gear/uniform/skirt/job/atmos
	display_name = "Skirt, atmos"
	path = /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	allowed_roles = list("Chief Engineer","Life Support Specialist")

/datum/gear/uniform/skirt/job/eng
	display_name = "Skirt, engineer"
	path = /obj/item/clothing/under/rank/engineering/engineer/skirt
	allowed_roles = list("Chief Engineer","Station Engineer")

/datum/gear/uniform/skirt/job/roboticist
	display_name = "Skirt, roboticist"
	path = /obj/item/clothing/under/rank/rnd/roboticist/skirt
	allowed_roles = list("Research Director","Roboticist")

/datum/gear/uniform/skirt/job/cmo
	display_name = "Skirt, cmo"
	path = /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	allowed_roles = list("Chief Medical Officer")

/datum/gear/uniform/skirt/job/chem
	display_name = "Skirt, chemist"
	path = /obj/item/clothing/under/rank/medical/chemist/skirt
	allowed_roles = list("Chief Medical Officer","Chemist")

/datum/gear/uniform/skirt/job/viro
	display_name = "Skirt, virologist"
	path = /obj/item/clothing/under/rank/medical/virologist/skirt
	allowed_roles = list("Virologist")

/datum/gear/uniform/skirt/job/med
	display_name = "Skirt, medical"
	path = /obj/item/clothing/under/rank/medical/doctor/skirt
	allowed_roles = list("Chief Medical Officer","Medical Doctor","Psychiatrist","Paramedic","Coroner")

/datum/gear/uniform/skirt/job/sci
	display_name = "Skirt, scientist"
	path = /obj/item/clothing/under/rank/rnd/scientist/skirt
	allowed_roles = list("Research Director","Scientist")

/datum/gear/uniform/skirt/job/cargo
	display_name = "Skirt, cargo"
	path = /obj/item/clothing/under/rank/cargo/tech/skirt
	allowed_roles = list("Quartermaster","Cargo Technician")

/datum/gear/uniform/skirt/job/qm
	display_name = "Skirt, QM"
	path = /obj/item/clothing/under/rank/cargo/quartermaster/skirt
	allowed_roles = list("Quartermaster")

/datum/gear/uniform/skirt/job/warden
	display_name = "Skirt, warden"
	path = /obj/item/clothing/under/rank/security/warden/skirt
	allowed_roles = list("Head of Security", "Warden")

/datum/gear/uniform/skirt/job/security
	display_name = "Skirt, security"
	path = /obj/item/clothing/under/rank/security/officer/skirt
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/skirt/job/head_of_security
	display_name = "Skirt, hos"
	path = /obj/item/clothing/under/rank/security/head_of_security/skirt
	allowed_roles = list("Head of Security")

/datum/gear/uniform/skirt/job/magistrate
	display_name = "Skirt, magistrate"
	path = /obj/item/clothing/under/rank/centcom/magistrate/skirt
	allowed_roles = list("Magistrate")

/datum/gear/uniform/skirt/job/ntrep
	display_name = "Skirt, nt rep"
	path = /obj/item/clothing/under/rank/centcom/representative/skirt
	allowed_roles = list("Nanotrasen Representative")

/datum/gear/uniform/skirt/job/blueshield
	display_name = "Skirt, blueshield"
	path = /obj/item/clothing/under/rank/centcom/blueshield/skirt
	allowed_roles = list("Blueshield")


/datum/gear/uniform/medical
	main_typepath = /datum/gear/uniform/medical

/datum/gear/uniform/medical/pscrubs
	display_name = "Medical scrubs, purple"
	path = /obj/item/clothing/under/rank/medical/scrubs/purple
	allowed_roles = list("Chief Medical Officer", "Medical Doctor")

/datum/gear/uniform/medical/gscrubs
	display_name = "Medical scrubs, green"
	path = /obj/item/clothing/under/rank/medical/scrubs/green
	allowed_roles = list("Chief Medical Officer", "Medical Doctor")

/datum/gear/uniform/sec
	main_typepath = /datum/gear/uniform/sec

/datum/gear/uniform/sec/formal
	display_name = "Security uniform, formal"
	path = /obj/item/clothing/under/rank/security/formal
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/sec/secorporate
	display_name = "Security uniform, corporate"
	path = /obj/item/clothing/under/rank/security/officer/corporate
	allowed_roles = list("Head of Security", "Warden", "Security Officer")

/datum/gear/uniform/sec/dispatch
	display_name = "Security uniform, dispatch"
	path = /obj/item/clothing/under/rank/security/officer/dispatch
	allowed_roles = list("Head of Security", "Warden", "Security Officer")

/datum/gear/uniform/sec/casual
	display_name = "Security uniform, casual"
	path = /obj/item/clothing/under/rank/security/officer/uniform
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective")

/datum/gear/uniform/shorts
	main_typepath = /datum/gear/uniform/shorts

/datum/gear/uniform/shorts/red
	display_name = "Shorts, red"
	path = /obj/item/clothing/under/pants/shorts/red

/datum/gear/uniform/shorts/green
	display_name = "Shorts, green"
	path = /obj/item/clothing/under/pants/shorts/green

/datum/gear/uniform/shorts/blue
	display_name = "Shorts, blue"
	path = /obj/item/clothing/under/pants/shorts/blue

/datum/gear/uniform/shorts/black
	display_name = "Shorts, black"
	path = /obj/item/clothing/under/pants/shorts/black

/datum/gear/uniform/shorts/grey
	display_name = "Shorts, grey"
	path = /obj/item/clothing/under/pants/shorts/grey

/datum/gear/uniform/pants
	main_typepath = /datum/gear/uniform/pants

/datum/gear/uniform/pants/jeans
	display_name = "Jeans, classic"
	path = /obj/item/clothing/under/pants/classicjeans

/datum/gear/uniform/pants/mjeans
	display_name = "Jeans, mustang"
	path = /obj/item/clothing/under/pants/mustangjeans

/datum/gear/uniform/pants/bljeans
	display_name = "Jeans, black"
	path = /obj/item/clothing/under/pants/blackjeans

/datum/gear/uniform/pants/yfjeans
	display_name = "Jeans, Young Folks"
	path = /obj/item/clothing/under/pants/youngfolksjeans

/datum/gear/uniform/pants/whitepants
	display_name = "Pants, white"
	path = /obj/item/clothing/under/pants/white

/datum/gear/uniform/pants/redpants
	display_name = "Pants, red"
	path = /obj/item/clothing/under/pants/red

/datum/gear/uniform/pants/blackpants
	display_name = "Pants, black"
	path = /obj/item/clothing/under/pants/black

/datum/gear/uniform/pants/tanpants
	display_name = "Pants, tan"
	path = /obj/item/clothing/under/pants/tan

/datum/gear/uniform/pants/bluepants
	display_name = "Pants, blue"
	path = /obj/item/clothing/under/pants/blue

/datum/gear/uniform/pants/trackpants
	display_name = "Trackpants"
	path = /obj/item/clothing/under/pants/track

/datum/gear/uniform/pants/khakipants
	display_name = "Pants, khaki"
	path = /obj/item/clothing/under/pants/khaki

/datum/gear/uniform/pants/caopants
	display_name = "Pants, camo"
	path = /obj/item/clothing/under/pants/camo

/datum/gear/uniform/suit/tacticool
	display_name = "Tacticool turtleneck"
	description = "A sleek black turtleneck paired with some khakis (WARNING DOES NOT HAVE SUIT SENSORS)"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/suit/assistantformal
	display_name = "Assistant's Formal Uniform"
	description = "Formal attire fit for an Assistant."
	path = /obj/item/clothing/under/misc/assistantformal

/datum/gear/uniform/suit/redhawaiianshirt
	display_name = "Red Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is red."
	path = /obj/item/clothing/under/misc/redhawaiianshirt

/datum/gear/uniform/suit/bluehawaiianshirt
	display_name = "Blue Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is blue."
	path = /obj/item/clothing/under/misc/bluehawaiianshirt

/datum/gear/uniform/suit/pinkhawaiianshirt
	display_name = "Pink Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is pink."
	path = /obj/item/clothing/under/misc/pinkhawaiianshirt

/datum/gear/uniform/suit/orangehawaiianshirt
	display_name = "Orange Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is orange."
	path = /obj/item/clothing/under/misc/orangehawaiianshirt
