/datum/gear/dice
	display_name = "a d20"
	path = /obj/item/dice/d20

/datum/gear/uplift
	display_name = "a pack of Uplifts"
	path = /obj/item/storage/fancy/cigarettes/cigpack_uplift

/datum/gear/robust
	display_name = "a pack of Robusts"
	path = /obj/item/storage/fancy/cigarettes/cigpack_robust

/datum/gear/carp
	display_name = "a pack of Carps"
	path = /obj/item/storage/fancy/cigarettes/cigpack_carp

/datum/gear/midori
	display_name = "a pack of Midoris"
	path = /obj/item/storage/fancy/cigarettes/cigpack_midori

/datum/gear/smokingpipe
	display_name = "smoking pipe"
	path = /obj/item/clothing/mask/cigarette/pipe
	cost = 2

/datum/gear/lighter
	display_name = "a cheap lighter"
	path = /obj/item/lighter

/datum/gear/matches
	display_name = "a box of matches"
	path = /obj/item/storage/box/matches

/datum/gear/candlebox
	display_name = "a box candles"
	description = "For setting the mood or for occult rituals."
	path = /obj/item/storage/fancy/candle_box/full

/datum/gear/rock
	display_name = "a pet rock"
	path = /obj/item/toy/pet_rock

/datum/gear/camera
	display_name = "a camera"
	path = /obj/item/camera

/datum/gear/redfoxplushie
	display_name = "a red fox plushie"
	path = /obj/item/toy/plushie/red_fox

/datum/gear/blackcatplushie
	display_name = "a black cat plushie"
	path = /obj/item/toy/plushie/black_cat

/datum/gear/voxplushie
	display_name = "a vox plushie"
	path = /obj/item/toy/plushie/voxplushie

/datum/gear/lizardplushie
	display_name = "a lizard plushie"
	path = /obj/item/toy/plushie/lizardplushie

/datum/gear/deerplushie
	display_name = "a deer plushie"
	path = /obj/item/toy/plushie/deer

/datum/gear/carpplushie
	display_name = "a carp plushie"
	path = /obj/item/toy/carpplushie

/datum/gear/sechud
	display_name = "a classic security HUD"
	path = /obj/item/clothing/glasses/hud/security
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot", "Internal Affairs Agent","Magistrate")

/datum/gear/cryaonbox
	display_name = "a box of crayons"
	path = /obj/item/storage/fancy/crayons

/datum/gear/cane
	display_name = "a walking cane"
	path = /obj/item/cane

/datum/gear/cards
	display_name = "a deck of standard cards"
	path = /obj/item/deck/cards

/datum/gear/doublecards
	display_name = "a double deck of standard cards"
	path = /obj/item/deck/doublecards

/datum/gear/tarot
	display_name = "a deck of tarot cards"
	path = /obj/item/deck/tarot

/datum/gear/headphones
	display_name = "a pair of headphones"
	path = /obj/item/clothing/ears/headphones

/datum/gear/fannypack
	display_name = "a fannypack"
	path = /obj/item/storage/belt/fannypack

/datum/gear/blackbandana
	display_name = "bandana, black"
	path = /obj/item/clothing/mask/bandana/black

/datum/gear/purplebandana
	display_name = "bandana, purple"
	path = /obj/item/clothing/mask/bandana/purple

/datum/gear/orangebandana
	display_name = "bandana, orange"
	path = /obj/item/clothing/mask/bandana/orange

/datum/gear/greenbandana
	display_name = "bandana, green"
	path = /obj/item/clothing/mask/bandana/green

/datum/gear/bluebandana
	display_name = "bandana, blue"
	path = /obj/item/clothing/mask/bandana/blue

/datum/gear/redbandana
	display_name = "bandana, red"
	path = /obj/item/clothing/mask/bandana/red

/datum/gear/goldbandana
	display_name = "bandana, gold"
	path = /obj/item/clothing/mask/bandana/gold

/datum/gear/skullbandana
	display_name = "bandana, skull"
	path = /obj/item/clothing/mask/bandana/skull

/datum/gear/mob_hunt_game
	display_name = "Nano-Mob Hunter GO! Cartridge"
	path = /obj/item/cartridge/mob_hunt_game
	cost = 2

/datum/gear/piano_synth
	display_name ="synthesizer"
	path = /obj/item/instrument/piano_synth
	cost = 2
//////////////////////
//		Mugs		//
//////////////////////

/datum/gear/mug
	display_name = "random coffee mug"
	description = "A randomly colored coffee mug. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/food/drinks/mug
	sort_category = "Mugs"

/datum/gear/novelty_mug
	display_name = "novelty coffee mug"
	description = "A random novelty coffee mug. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/food/drinks/mug/novelty
	cost = 2
	sort_category = "Mugs"

/datum/gear/mug/flask
	display_name = "flask"
	description = "A flask for drink transportation. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/food/drinks/flask/barflask

/datum/gear/mug/department
	subtype_path = /datum/gear/mug/department
	sort_category = "Mugs"
	subtype_cost_overlap = FALSE

/datum/gear/mug/department/eng
	display_name = "engineer coffee mug"
	description = "An engineer's coffee mug, emblazoned in the colors of the Engineering department."
	allowed_roles = list("Chief Engineer", "Station Engineer", "Mechanic", "Life Support Specialist")
	path = /obj/item/reagent_containers/food/drinks/mug/eng

/datum/gear/mug/department/med
	display_name = "doctor coffee mug"
	description = "A doctor's coffee mug, emblazoned in the colors of the Medical department."
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")
	path = /obj/item/reagent_containers/food/drinks/mug/med

/datum/gear/mug/department/sci
	display_name = "scientist coffee mug"
	description = "A scientist's coffee mug, emblazoned in the colors of the Science department."
	allowed_roles = list("Research Director", "Scientist", "Roboticist")
	path = /obj/item/reagent_containers/food/drinks/mug/sci

/datum/gear/mug/department/sec
	display_name = "officer coffee mug"
	description = "An officer's coffee mug, emblazoned in the colors of the Security department."
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot", "Brig Physician", "Internal Affairs Agent")
	path = /obj/item/reagent_containers/food/drinks/mug/sec

/datum/gear/mug/department/serv
	display_name = "crewmember coffee mug"
	description = "A crewmember's coffee mug, emblazoned in the colors of the Service department."
	path = /obj/item/reagent_containers/food/drinks/mug/serv
