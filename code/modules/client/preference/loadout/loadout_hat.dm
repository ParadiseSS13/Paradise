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


/datum/gear/hat
	main_typepath = /datum/gear/hat
	slot = SLOT_HUD_HEAD
	sort_category = "Headwear"

/datum/gear/hat/hhat_yellow
	display_name = "Hardhat, yellow"
	path = /obj/item/clothing/head/hardhat
	allowed_roles = list("Chief Engineer", "Station Engineer", "Life Support Specialist")

/datum/gear/hat/hhat_orange
	display_name = "Hardhat, orange"
	path = /obj/item/clothing/head/hardhat/orange
	allowed_roles = list("Chief Engineer", "Station Engineer", "Life Support Specialist")

/datum/gear/hat/hhat_blue
	display_name = "Hardhat, blue"
	path = /obj/item/clothing/head/hardhat/dblue
	allowed_roles = list("Chief Engineer", "Station Engineer", "Life Support Specialist")

/datum/gear/hat/that
	display_name = "Top hat"
	path = /obj/item/clothing/head/that

/datum/gear/hat/flatcap
	display_name = "Flat cap"
	path = /obj/item/clothing/head/flatcap

/datum/gear/hat/witch
	display_name = "Witch hat"
	path = /obj/item/clothing/head/wizard/marisa/fake

/datum/gear/hat/piratecaphat
	display_name = "Pirate captian hat"
	path = /obj/item/clothing/head/pirate

/datum/gear/hat/fez
	display_name = "Fez"
	path = /obj/item/clothing/head/fez

/datum/gear/hat/rasta
	display_name = "Rasta hat"
	path = /obj/item/clothing/head/beanie/rasta

/datum/gear/hat/bfedora
	display_name = "Fedora, black"
	path = /obj/item/clothing/head/fedora

/datum/gear/hat/wfedora
	display_name = "Fedora, white"
	path = /obj/item/clothing/head/fedora/whitefedora

/datum/gear/hat/brfedora
	display_name = "Fedora, brown"
	path = /obj/item/clothing/head/fedora/brownfedora

/datum/gear/hat/capcsec
	display_name = "Security cap, corporate"
	path = /obj/item/clothing/head/soft/sec/corp
	allowed_roles = list("Head of Security", "Warden", "Security Officer")

/datum/gear/hat/capsec
	display_name = "Security cap"
	path = /obj/item/clothing/head/soft/sec
	allowed_roles = list("Head of Security", "Warden", "Security Officer")

/datum/gear/hat/deliverysoft
	display_name = "Cap, delivery boy"
	path = /obj/item/clothing/head/soft/deliverysoft
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/hat/capred
	display_name = "Cap, red"
	path = /obj/item/clothing/head/soft/red

/datum/gear/hat/capblue
	display_name = "Cap, blue"
	path = /obj/item/clothing/head/soft/blue

/datum/gear/hat/capgreen
	display_name = "Cap, green"
	path = /obj/item/clothing/head/soft/green

/datum/gear/hat/capblack
	display_name = "Cap, black"
	path = /obj/item/clothing/head/soft/black

/datum/gear/hat/cappurple
	display_name = "Cap, purple"
	path = /obj/item/clothing/head/soft/purple

/datum/gear/hat/capwhite
	display_name = "Cap, white"
	path = /obj/item/clothing/head/soft/mime

/datum/gear/hat/caporange
	display_name = "Cap, orange"
	path = /obj/item/clothing/head/soft/orange

/datum/gear/hat/capgrey
	display_name = "Cap, grey"
	path = /obj/item/clothing/head/soft/grey

/datum/gear/hat/capyellow
	display_name = "Cap, yellow"
	path = /obj/item/clothing/head/soft/yellow

/datum/gear/hat/cowboyhat
	display_name = "Cowboy hat, brown"
	path = /obj/item/clothing/head/cowboyhat

/datum/gear/hat/cowboyhat/tan
	display_name = "Cowboy hat, tan"
	path = /obj/item/clothing/head/cowboyhat/tan

/datum/gear/hat/cowboyhat/black
	display_name = "Cowboy hat, black"
	path = /obj/item/clothing/head/cowboyhat/black

/datum/gear/hat/cowboyhat/white
	display_name = "Cowboy hat, white"
	path = /obj/item/clothing/head/cowboyhat/white

/datum/gear/hat/cowboyhat/pink
	display_name = "Cowboy hat, pink"
	path = /obj/item/clothing/head/cowboyhat/pink

/datum/gear/hat/beret_purple
	display_name = "Beret, purple"
	path = /obj/item/clothing/head/beret/purple_normal

/datum/gear/hat/beret_black
	display_name = "Beret, black"
	path = /obj/item/clothing/head/beret/black

/datum/gear/hat/beret_white
	display_name = "Beret, white"
	path = /obj/item/clothing/head/beret/white

/datum/gear/hat/beret_blue
	display_name = "Beret, blue"
	path = /obj/item/clothing/head/beret/blue

/datum/gear/hat/beret_red
	display_name = "Beret, red"
	path = /obj/item/clothing/head/beret

/datum/gear/hat/beret_job
	main_typepath = /datum/gear/hat/beret_job
	subtype_selection_cost = FALSE

/datum/gear/hat/beret_job/captain
	display_name = "Beret, captain's"
	path = /obj/item/clothing/head/caphat/beret
	allowed_roles = list("Captain")

/datum/gear/hat/beret_job/captain_white
	display_name = "Beret, captain's white"
	path = /obj/item/clothing/head/caphat/beret/white
	allowed_roles = list("Captain")

/datum/gear/hat/beret_job/sec
	display_name = "Beret, security"
	path = /obj/item/clothing/head/beret/sec
	allowed_roles = list("Head of Security", "Warden", "Security Officer")

/datum/gear/hat/beret_job/hop
	display_name = "Beret, head of personnel"
	path = /obj/item/clothing/head/hopcap/beret
	allowed_roles = list("Head of Personnel")

/datum/gear/hat/beret_job/sci
	display_name = "Beret, science"
	path = /obj/item/clothing/head/beret/sci
	allowed_roles = list("Research Director", "Scientist")

/datum/gear/hat/beret_job/robowhite
	display_name = "Beret, robotics"
	path = /obj/item/clothing/head/beret/robowhite
	allowed_roles = list("Research Director", "Roboticist")

/datum/gear/hat/beret_job/roboblack
	display_name = "Beret, bioengineer"
	path = /obj/item/clothing/head/beret/roboblack
	allowed_roles = list("Research Director", "Roboticist")

/datum/gear/hat/beret_job/med
	display_name = "Beret, medical"
	path = /obj/item/clothing/head/beret/med
	allowed_roles = list("Chief Medical Officer", "Medical Doctor" , "Virologist", "Coroner")

/datum/gear/hat/beret_job/eng
	display_name = "Beret, engineering"
	path = /obj/item/clothing/head/beret/eng
	allowed_roles = list("Chief Engineer", "Station Engineer")

/datum/gear/hat/beret_job/atmos
	display_name = "Beret, atmospherics"
	path = /obj/item/clothing/head/beret/atmos
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/hat/surgicalcap_purple
	display_name = "Surgical cap, purple"
	path = /obj/item/clothing/head/surgery/purple
	allowed_roles = list("Chief Medical Officer", "Medical Doctor")

/datum/gear/hat/surgicalcap_green
	display_name = "Surgical cap, green"
	path = /obj/item/clothing/head/surgery/green
	allowed_roles = list("Chief Medical Officer", "Medical Doctor")

/datum/gear/hat/flowerpin
	display_name = "Hair flower"
	path = /obj/item/clothing/head/hairflower

/datum/gear/hat/capsolgov
	display_name = "Cap, Sol Gov"
	path = /obj/item/clothing/head/soft/solgov
