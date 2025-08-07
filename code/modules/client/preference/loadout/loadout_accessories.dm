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


/datum/gear/accessory
	main_typepath = /datum/gear/accessory
	slot = ITEM_SLOT_ACCESSORY
	sort_category = "Accessories"

/datum/gear/accessory/holobadge
	display_name = "Holobadge, pin"
	path = /obj/item/clothing/accessory/holobadge
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/accessory/holobadge_n
	display_name = "Holobadge, cord"
	path = /obj/item/clothing/accessory/holobadge/cord
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/accessory/cowboyshirt
	display_name = "Cowboy shirt, black"
	path = /obj/item/clothing/accessory/cowboyshirt

/datum/gear/accessory/cowboyshirt/short_sleeved
	display_name = "Cowboy shirt, short sleeved black"
	path = /obj/item/clothing/accessory/cowboyshirt/short_sleeved

/datum/gear/accessory/cowboyshirt/white
	display_name = "Cowboy shirt, white"
	path = /obj/item/clothing/accessory/cowboyshirt/white

/datum/gear/accessory/cowboyshirt/white/short_sleeved
	display_name = "Cowboy shirt, short sleeved white"
	path = /obj/item/clothing/accessory/cowboyshirt/white/short_sleeved

/datum/gear/accessory/cowboyshirt/pink
	display_name = "Cowboy shirt, pink"
	path = /obj/item/clothing/accessory/cowboyshirt/pink

/datum/gear/accessory/cowboyshirt/pink/short_sleeved
	display_name = "Cowboy shirt, short sleeved pink"
	path = /obj/item/clothing/accessory/cowboyshirt/pink/short_sleeved

/datum/gear/accessory/cowboyshirt/red
	display_name = "Cowboy shirt, red"
	path = /obj/item/clothing/accessory/cowboyshirt/red

/datum/gear/accessory/cowboyshirt/red/short_sleeved
	display_name = "Cowboy shirt, short sleeved red"
	path = /obj/item/clothing/accessory/cowboyshirt/red/short_sleeved

/datum/gear/accessory/cowboyshirt/navy
	display_name = "Cowboy shirt, navy"
	path = /obj/item/clothing/accessory/cowboyshirt/navy

/datum/gear/accessory/cowboyshirt/navy/short_sleeved
	display_name = "Cowboy shirt, short sleeved navy"
	path = /obj/item/clothing/accessory/cowboyshirt/navy/short_sleeved

/datum/gear/accessory/corset
	display_name = "Corset, black"
	path = /obj/item/clothing/accessory/corset

/datum/gear/accessory/corsetred
	display_name = "Corset, red"
	path = /obj/item/clothing/accessory/corset/red

/datum/gear/accessory/corsetblue
	display_name = "Corset, blue"
	path = /obj/item/clothing/accessory/corset/blue

/datum/gear/accessory/nt_pin
	display_name = "Nanotrasen pin"
	path = /obj/item/clothing/accessory/pin

/datum/gear/accessory/pride_pin
	display_name = "Pride pin"
	path = /obj/item/clothing/accessory/pin/pride

/datum/gear/accessory/armband_red
	display_name = "Armband"
	path = /obj/item/clothing/accessory/armband

/datum/gear/accessory/armband_civ
	display_name = "Armband, blue-yellow"
	path = /obj/item/clothing/accessory/armband/yb

/datum/gear/accessory/armband_job
	main_typepath = /datum/gear/accessory/armband_job
	subtype_selection_cost = FALSE

/datum/gear/accessory/armband_job/sec
	display_name = "Armband, security"
	path = /obj/item/clothing/accessory/armband/sec
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/accessory/armband_job/cargo
	display_name = "Armband, cargo"
	path = /obj/item/clothing/accessory/armband/cargo
	allowed_roles = list("Quartermaster","Cargo Technician", "Shaft Miner", "Explorer")

/datum/gear/accessory/armband_job/medical
	display_name = "Armband, medical"
	path = /obj/item/clothing/accessory/armband/med
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Coroner", "Virologist", "Paramedic")

/datum/gear/accessory/armband_job/emt
	display_name = "Armband, EMT"
	path = /obj/item/clothing/accessory/armband/medgreen
	allowed_roles = list("Chief Medical Officer", "Paramedic")

/datum/gear/accessory/armband_job/engineering
	display_name = "Armband, engineering"
	path = /obj/item/clothing/accessory/armband/engine
	allowed_roles = list("Chief Engineer","Station Engineer", "Life Support Specialist")

/datum/gear/accessory/armband_job/hydro
	display_name = "Armband, hydroponics"
	path = /obj/item/clothing/accessory/armband/hydro
	allowed_roles = list("Botanist")

/datum/gear/accessory/armband_job/sci
	display_name = "Armband, science"
	path = /obj/item/clothing/accessory/armband/science
	allowed_roles = list("Research Director","Scientist", "Roboticist", "Geneticist")

/datum/gear/accessory/armband_job/procedure
	display_name = "Armband, procedure"
	path = /obj/item/clothing/accessory/armband/procedure
	allowed_roles = list("Captain", "Nanotrasen Representative", "Magistrate", "Internal Affairs Agent", "Nanotrasen Career Trainer")

/datum/gear/accessory/armband_job/service
	display_name = "Armband, service"
	path = /obj/item/clothing/accessory/armband/service
	allowed_roles = list("Head of Personnel", "Chaplain", "Janitor", "Botanist", "Chef", "Bartender", "Clown", "Mime", "Librarian")
