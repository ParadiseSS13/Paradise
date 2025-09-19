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


/datum/gear/neck
	main_typepath = /datum/gear/neck
	slot = ITEM_SLOT_NECK
	sort_category = "Neck"

/datum/gear/neck/tie
	display_name = "Tie, blue"
	path = /obj/item/clothing/neck/tie/blue

/datum/gear/neck/tie/red
	display_name = "Tie, red"
	path = /obj/item/clothing/neck/tie/red

/datum/gear/neck/tie/black
	display_name = "Tie, black"
	path = /obj/item/clothing/neck/tie/black

/datum/gear/neck/tie/horrible
	display_name = "Tie, vomit green"
	path = /obj/item/clothing/neck/tie/horrible

/datum/gear/neck/scarf
	display_name = "Scarf, red"
	path = /obj/item/clothing/neck/scarf/red

/datum/gear/neck/scarf/green
	display_name = "Scarf, green"
	path = /obj/item/clothing/neck/scarf/green

/datum/gear/neck/scarf/darkblue
	display_name = "Scarf, dark blue"
	path = /obj/item/clothing/neck/scarf/darkblue

/datum/gear/neck/scarf/purple
	display_name = "Scarf, purple"
	path = /obj/item/clothing/neck/scarf/purple

/datum/gear/neck/scarf/yellow
	display_name = "Scarf, yellow"
	path = /obj/item/clothing/neck/scarf/yellow

/datum/gear/neck/scarf/orange
	display_name = "Scarf, orange"
	path = /obj/item/clothing/neck/scarf/orange

/datum/gear/neck/scarf/lightblue
	display_name = "Scarf, light blue"
	path = /obj/item/clothing/neck/scarf/lightblue

/datum/gear/neck/scarf/white
	display_name = "Scarf, white"
	path = /obj/item/clothing/neck/scarf/white

/datum/gear/neck/scarf/black
	display_name = "Scarf, black"
	path = /obj/item/clothing/neck/scarf/black

/datum/gear/neck/scarf/zebra
	display_name = "Scarf, zebra"
	path = /obj/item/clothing/neck/scarf/zebra

/datum/gear/neck/scarf/christmas
	display_name = "Scarf, christmas"
	path = /obj/item/clothing/neck/scarf/christmas

/datum/gear/neck/scarf/stripedred
	display_name = "Scarf, striped red"
	path = /obj/item/clothing/neck/scarf/stripedred

/datum/gear/neck/scarf/stripedgreen
	display_name = "Scarf, striped green"
	path = /obj/item/clothing/neck/scarf/stripedgreen

/datum/gear/neck/scarf/stripedblue
	display_name = "Scarf, striped blue"
	path = /obj/item/clothing/neck/scarf/stripedblue

/datum/gear/neck/stethoscope
	display_name = "Stethoscope"
	path = /obj/item/clothing/neck/stethoscope
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Paramedic")

/datum/gear/neck/locket
	display_name = "Gold locket"
	path = /obj/item/clothing/neck/necklace/locket

/datum/gear/neck/locket/silver
	display_name = "Silver locket"
	path = /obj/item/clothing/neck/necklace/locket/silver

/datum/gear/neck/necklace
	display_name = "Simple necklace"
	path = /obj/item/clothing/neck/necklace

/datum/gear/neck/necklace/long
	display_name = "Large necklace"
	path = /obj/item/clothing/neck/necklace/long

//Cloaks and mantles

/datum/gear/neck/cloak
	display_name = "Cloak"
	path = /obj/item/clothing/neck/cloak

/datum/gear/neck/cloak/job
	main_typepath = /datum/gear/neck/cloak/job
	subtype_selection_cost = FALSE

/datum/gear/neck/cloak/job/captain
	display_name = "Cloak, captain"
	path = /obj/item/clothing/neck/cloak/captain
	allowed_roles = list("Captain")

/datum/gear/neck/cloak/job/hos
	display_name = "Cloak, head of security"
	path = /obj/item/clothing/neck/cloak/head_of_security
	allowed_roles = list("Head of Security")

/datum/gear/neck/cloak/job/hop
	display_name = "Cloak, head of personnel"
	path = /obj/item/clothing/neck/cloak/head_of_personnel
	allowed_roles = list("Head of Personnel")

/datum/gear/neck/cloak/job/rd
	display_name = "Cloak, research director"
	path = /obj/item/clothing/neck/cloak/research_director
	allowed_roles = list("Research Director")

/datum/gear/neck/cloak/job/ce
	display_name = "Cloak, chief engineer"
	path = /obj/item/clothing/neck/cloak/chief_engineer
	allowed_roles = list("Chief Engineer")

/datum/gear/neck/cloak/job/cmo
	display_name = "Cloak, chief medical officer"
	path = /obj/item/clothing/neck/cloak/chief_medical_officer
	allowed_roles = list("Chief Medical Officer")

/datum/gear/neck/cloak/job/qm
	display_name = "Cloak, quartermaster"
	path = /obj/item/clothing/neck/cloak/quartermaster
	allowed_roles = list("Quartermaster")

/datum/gear/neck/old_scarf
	display_name = "Old scarf"
	path = /obj/item/clothing/neck/cloak/old

/datum/gear/neck/regal_shawl
	display_name = "Regal shawl"
	path = /obj/item/clothing/neck/cloak/regal

/datum/gear/neck/mantle
	display_name = "Mantle"
	path = /obj/item/clothing/neck/cloak/mantle

/datum/gear/neck/mantle/job
	main_typepath = /datum/gear/neck/mantle/job
	subtype_selection_cost = FALSE

/datum/gear/neck/mantle/job/captain
	display_name = "Mantle, captain"
	path = /obj/item/clothing/neck/cloak/captain_mantle
	allowed_roles = list("Captain")

/datum/gear/neck/mantle/job/hos
	display_name = "Mantle, head of security"
	path = /obj/item/clothing/neck/cloak/hos_mantle
	allowed_roles = list("Head of Security")

/datum/gear/neck/mantle/job/hop
	display_name = "Mantle, head of personnel"
	path = /obj/item/clothing/neck/cloak/hop_mantle
	allowed_roles = list("Head of Personnel")

/datum/gear/neck/mantle/job/rd
	display_name = "Mantle, research director"
	path = /obj/item/clothing/neck/cloak/rd_mantle
	allowed_roles = list("Research Director")

/datum/gear/neck/mantle/job/ce
	display_name = "Mantle, chief engineer"
	path = /obj/item/clothing/neck/cloak/ce_mantle
	allowed_roles = list("Chief Engineer")

/datum/gear/neck/mantle/job/cmo
	display_name = "Mantle, chief medical officer"
	path = /obj/item/clothing/neck/cloak/cmo_mantle
	allowed_roles = list("Chief Medical Officer")

/datum/gear/neck/mantle/job/qm
	display_name = "Mantle, quartermaster"
	path = /obj/item/clothing/neck/cloak/qm_mantle
	allowed_roles = list("Quartermaster")

/datum/gear/neck/tallit
	display_name = "Chaplain, tallit"
	path = /obj/item/clothing/neck/cloak/tallit
	allowed_roles = list("Chaplain")
