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


/datum/gear/dice
	display_name = "D20"
	path = /obj/item/dice/d20

/datum/gear/uplift
	display_name = "Pack of Uplifts"
	path = /obj/item/storage/fancy/cigarettes/cigpack_uplift

/datum/gear/robust
	display_name = "Pack of Robusts"
	path = /obj/item/storage/fancy/cigarettes/cigpack_robust

/datum/gear/carp
	display_name = "Pack of Carps"
	path = /obj/item/storage/fancy/cigarettes/cigpack_carp

/datum/gear/midori
	display_name = "Pack of Midoris"
	path = /obj/item/storage/fancy/cigarettes/cigpack_midori

/datum/gear/smokingpipe
	display_name = "Smoking pipe"
	path = /obj/item/clothing/mask/cigarette/pipe
	cost = 2

/datum/gear/lighter
	display_name = "Cheap lighter"
	path = /obj/item/lighter

/datum/gear/matches
	display_name = "Box of matches"
	path = /obj/item/storage/fancy/matches

/datum/gear/candlebox
	display_name = "Box of candles"
	description = "For setting the mood or for occult rituals."
	path = /obj/item/storage/fancy/candle_box/full

/datum/gear/rock
	display_name = "Pet rock"
	path = /obj/item/toy/pet_rock

/datum/gear/camera
	display_name = "Camera"
	path = /obj/item/camera

/datum/gear/redfoxplushie
	display_name = "Red fox plushie"
	path = /obj/item/toy/plushie/red_fox

/datum/gear/blackcatplushie
	display_name = "Black cat plushie"
	path = /obj/item/toy/plushie/black_cat

/datum/gear/voxplushie
	display_name = "Vox plushie"
	path = /obj/item/toy/plushie/voxplushie

/datum/gear/lizardplushie
	display_name = "Lizard plushie"
	path = /obj/item/toy/plushie/lizardplushie

/datum/gear/deerplushie
	display_name = "Deer plushie"
	path = /obj/item/toy/plushie/deer

/datum/gear/carpplushie
	display_name = "Carp plushie"
	path = /obj/item/toy/plushie/carpplushie

/datum/gear/greyplushie
	display_name = "Grey Plushie"
	path = /obj/item/toy/plushie/greyplushie

/datum/gear/nianplushie
	display_name = "Nian plushie"
	path = /obj/item/toy/plushie/nianplushie

/datum/gear/ipcplushie
	display_name = "IPC plushie"
	path = /obj/item/toy/plushie/ipcplushie

/datum/gear/kidanplushie
	display_name = "Kidan plushie"
	path = /obj/item/toy/plushie/kidanplushie

/datum/gear/plasmaplushie
	display_name = "Plasmaman plushie"
	path = /obj/item/toy/plushie/plasmamanplushie

/datum/gear/skrellplushie
	display_name = "Skrell plushie"
	path = /obj/item/toy/plushie/skrellplushie

/datum/gear/draskplushie
	display_name = "Drask plushie"
	path = /obj/item/toy/plushie/draskplushie

/datum/gear/borgplushie
	display_name = "Borg plushie"
	path = /obj/item/toy/plushie/borgplushie

/datum/gear/nymphplushie
	display_name = "Diona nymph plushie"
	path = /obj/item/toy/plushie/nymphplushie

/datum/gear/sharkplushie
	display_name = "Shark plushie"
	path = /obj/item/toy/plushie/shark

/datum/gear/cryaonbox
	display_name = "Box of crayons"
	path = /obj/item/storage/fancy/crayons

/datum/gear/cane
	display_name = "Walking cane"
	path = /obj/item/cane

/datum/gear/cards
	display_name = "Deck of standard cards"
	path = /obj/item/deck/cards

/datum/gear/doublecards
	display_name = "Double deck of standard cards"
	path = /obj/item/deck/cards/doublecards

/datum/gear/tarot
	display_name = "Deck of tarot cards"
	path = /obj/item/deck/tarot

/datum/gear/unum
	display_name = "Deck of UNUM! cards"
	path = /obj/item/deck/unum

/datum/gear/headphones
	display_name = "Headphones"
	path = /obj/item/clothing/ears/headphones

/datum/gear/fannypack
	display_name = "Fannypack"
	path = /obj/item/storage/belt/fannypack

/datum/gear/blackbandana
	display_name = "Bandana, black"
	path = /obj/item/clothing/mask/bandana/black

/datum/gear/purplebandana
	display_name = "Bandana, purple"
	path = /obj/item/clothing/mask/bandana/purple

/datum/gear/orangebandana
	display_name = "Bandana, orange"
	path = /obj/item/clothing/mask/bandana/orange

/datum/gear/greenbandana
	display_name = "Bandana, green"
	path = /obj/item/clothing/mask/bandana/green

/datum/gear/bluebandana
	display_name = "Bandana, blue"
	path = /obj/item/clothing/mask/bandana/blue

/datum/gear/redbandana
	display_name = "Bandana, red"
	path = /obj/item/clothing/mask/bandana/red

/datum/gear/goldbandana
	display_name = "Bandana, gold"
	path = /obj/item/clothing/mask/bandana/gold

/datum/gear/skullbandana
	display_name = "Bandana, skull"
	path = /obj/item/clothing/mask/bandana/skull

/datum/gear/pai
	display_name = "Personal Artificial Intelligence"
	path = /obj/item/paicard
	cost = 2

/datum/gear/wizard_staff
	display_name = "Wizard's staff"
	path = /obj/item/staff

//////////////////////
//		Mugs		//
//////////////////////

/datum/gear/mug
	display_name = "Coffee mug, random"
	description = "A randomly colored coffee mug. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/drinks/mug
	sort_category = "Mugs"

/datum/gear/novelty_mug
	display_name = "Coffee mug, novelty"
	description = "A random novelty coffee mug. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/drinks/mug/novelty
	cost = 2
	sort_category = "Mugs"

/datum/gear/mug/flask
	display_name = "Flask"
	description = "A flask for drink transportation. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/drinks/flask/barflask

/datum/gear/mug/department
	main_typepath = /datum/gear/mug/department
	subtype_selection_cost = FALSE

/datum/gear/mug/department/eng
	display_name = "Coffee mug, engineering"
	description = "An engineer's coffee mug, emblazoned in the colors of the Engineering department."
	allowed_roles = list("Chief Engineer", "Station Engineer", "Life Support Specialist")
	path = /obj/item/reagent_containers/drinks/mug/eng

/datum/gear/mug/department/med
	display_name = "Coffee mug, medical"
	description = "A doctor's coffee mug, emblazoned in the colors of the Medical department."
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")
	path = /obj/item/reagent_containers/drinks/mug/med

/datum/gear/mug/department/sci
	display_name = "Coffee mug, science"
	description = "A scientist's coffee mug, emblazoned in the colors of the Science department."
	allowed_roles = list("Research Director", "Scientist", "Roboticist")
	path = /obj/item/reagent_containers/drinks/mug/sci

/datum/gear/mug/department/sec
	display_name = "Coffee mug, security"
	description = "An officer's coffee mug, emblazoned in the colors of the Security department."
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Internal Affairs Agent")
	path = /obj/item/reagent_containers/drinks/mug/sec

/datum/gear/mug/department/serv
	display_name = "Coffee mug, service"
	description = "A crewmember's coffee mug, emblazoned in the colors of the Service department."
	path = /obj/item/reagent_containers/drinks/mug/serv


//////////////////////
//	  Instruments	//
//////////////////////

/datum/gear/instrument
	display_name = "Synthesizer"
	path = /obj/item/instrument/piano_synth
	sort_category = "Instruments"
	cost = 2

/datum/gear/instrument/accordion
	display_name = "Accordion"
	path = /obj/item/instrument/accordion

/datum/gear/instrument/banjo
	display_name = "Banjo"
	path = /obj/item/instrument/banjo

/datum/gear/instrument/eguitar
	display_name = "Electric guitar"
	path = /obj/item/instrument/eguitar

/datum/gear/instrument/glock
	display_name = "Glockenspiel"
	path = /obj/item/instrument/glockenspiel

/datum/gear/instrument/guitar
	display_name = "Guitar"
	path = /obj/item/instrument/guitar

/datum/gear/instrument/harmonica
	display_name = "Harmonica"
	path = /obj/item/instrument/harmonica

/datum/gear/instrument/recorder
	display_name = "Recorder"
	path = /obj/item/instrument/recorder

/datum/gear/instrument/sax
	display_name = "Saxophone"
	path = /obj/item/instrument/saxophone

/datum/gear/instrument/trumpet
	display_name = "Trumpet"
	path = /obj/item/instrument/trumpet

/datum/gear/instrument/trombone
	display_name = "Trombone"
	path = /obj/item/instrument/trombone

/datum/gear/instrument/violin
	display_name = "Violin"
	path = /obj/item/instrument/violin

/datum/gear/instrument/xylo
	display_name = "Xylophone"
	path = /obj/item/instrument/xylophone
