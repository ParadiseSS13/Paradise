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


/datum/gear/racial
	sort_category = "Racial"
	main_typepath = /datum/gear/racial

/datum/gear/racial/taj
	display_name = "Tajaran veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran. It is rare and offensive to see it on other races. Can be combined with various other eyewear."
	path = /obj/item/clothing/glasses/hud/tajblind
	slot = ITEM_SLOT_EYES

/datum/gear/racial/taj/medical
	display_name = "Tajaran Medical Veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran. It is rare and offensive to see it on other races. Comes equipped with a medical HUD."
	path = /obj/item/clothing/glasses/hud/tajblind/med
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Coroner", "Chemist", "Virologist", "Psychiatrist", "Paramedic")

/datum/gear/racial/taj/sec
	display_name = "Tajaran Security Veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran. It is rare and offensive to see it on other races. Comes equipped with a security HUD."
	path = /obj/item/clothing/glasses/hud/tajblind/sec
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective", "Internal Affairs Agent", "Magistrate")

/datum/gear/racial/taj/miner
	display_name = "Tajaran Mining Meson Veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran. It is rare and offensive to see it on other races. Comes equipped with a meson HUD."
	path = /obj/item/clothing/glasses/hud/tajblind/meson/cargo
	allowed_roles = list("Shaft Miner", "Explorer", "Quartermaster")

/datum/gear/racial/taj/engineering
	display_name = "Tajaran Engineering Meson Veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran. It is rare and offensive to see it on other races. Comes equipped with a meson HUD."
	path = /obj/item/clothing/glasses/hud/tajblind/meson
	allowed_roles = list("Chief Engineer", "Life Support Specialist", "Station Engineer")

/datum/gear/racial/taj/science
	display_name = "Tajaran Science Veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran. It is rare and offensive to see it on other races. Comes equipped with a science HUD."
	path = /obj/item/clothing/glasses/hud/tajblind/sci
	allowed_roles = list("Scientist", "Research Director", "Bartender")

/datum/gear/racial/footwraps
	display_name = "Cloth footwraps"
	path = /obj/item/clothing/shoes/footwraps
	slot = ITEM_SLOT_SHOES

/datum/gear/racial/handwraps
	display_name = "Cloth handwraps"
	path = /obj/item/clothing/gloves/handwraps
	slot = ITEM_SLOT_GLOVES

/datum/gear/racial/vox_casual
	display_name = "Vox jumpsuit"
	description = "These loose clothes are optimized for the labors of the lower castes onboard the arkships. Large openings in the top allow for breathability while the pants are durable yet flexible enough to not restrict movement."
	path = /obj/item/clothing/under/vox/vox_casual
	slot = ITEM_SLOT_JUMPSUIT

/datum/gear/racial/vox_robes
	display_name = "Vox robes"
	description = "Large, comfortable robes worn by those who need a bit more covering. The thick fabric contains a pocket suitable for those that need their hands free during their work, while the cloth serves to cover scars or other injuries to the wearer's body."
	path = /obj/item/clothing/suit/hooded/vox_robes
	slot = ITEM_SLOT_OUTER_SUIT

/datum/gear/racial/plasmamansuit_coke
	display_name = "Coke Suit"
	description = "Plasmaman envirosuit designed by Space Cola Co and gifted to the people of Boron as part of an elaborate advertisement campaign."
	path = /obj/item/storage/box/coke_envirosuit

/datum/gear/racial/plasmamansuit_tacticool
	display_name = "Tactical Suit"
	description = "Plasmaman envirosuit supplied by black markets. Forged on Boron. Does not have suit sensors."
	path = /obj/item/storage/box/tacticool_envirosuit

/datum/gear/racial/plasmamansuit_chapbw
	display_name = "Chaplain suit, black and white"
	description = "Envirosuit for pious plasmamen in black and white."
	path =/obj/item/storage/box/chapbw_envirosuit
	allowed_roles = list("Chaplain")

/datum/gear/racial/plasmamansuit_chapwg
	display_name = "Chaplain suit, white and green"
	description = "Envirosuit for pious plasmamen in white and green."
	path = /obj/item/storage/box/chapwg_envirosuit
	allowed_roles = list("Chaplain")

/datum/gear/racial/plasmamansuit_chapco
	display_name = "Chaplain suit, blue and orange"
	description = "Envirosuit for pious plasmamen in blue and orange."
	path = /obj/item/storage/box/chapco_envirosuit
	allowed_roles = list("Chaplain")
