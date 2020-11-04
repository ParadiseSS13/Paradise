/////////////////////////////
// Store Item
/////////////////////////////
/datum/storeitem
	var/name="Thing"
	var/desc="It's a thing."
	var/typepath=/obj/item/storage/box
	var/cost=0

/datum/storeitem/proc/deliver(var/mob/usr)
	if(!istype(typepath,/obj/item/storage))
		var/obj/item/storage/box/box=new(usr.loc)
		new typepath(box)
		box.name="[name] package"
		box.desc="A special gift for doing your job."
		usr.put_in_hands(box)
	else
		var/thing = new typepath(usr.loc)
		usr.put_in_hands(thing)


/////////////////////////////
// Shit for robotics/science
/////////////////////////////
/*
/datum/storeitem/robotnik_labcoat
	name = "Robotnik's Research Labcoat"
	desc = "Join the empire and display your hatred for woodland animals."
	typepath = /obj/item/clothing/suit/storage/labcoat/custom/N3X15/robotics
	cost = 350

/datum/storeitem/robotnik_jumpsuit
	name = "Robotics Interface Suit"
	desc = "A modern black and red design with reinforced seams and brass neural interface fittings."
	typepath = /obj/item/clothing/under/custom/N3X15/robotics
	cost = 500
*/

/////////////////////////////
// General
/////////////////////////////
/datum/storeitem/snap_pops
	name = "Snap-Pops"
	desc = "Ten-thousand-year-old chinese fireworks: IN SPACE"
	typepath = /obj/item/storage/box/snappops
	cost = 200

/datum/storeitem/dnd
	name = "Dungeons & Dragons Set"
	desc = "A box containing minifigures suitable for a good game of D&D."
	typepath = /obj/item/storage/box/characters
	cost = 200

/datum/storeitem/dice
	name = "Dice Set"
	desc = "A box containing multiple different types of die."
	typepath = /obj/item/storage/box/dice
	cost = 200

/datum/storeitem/candle
	name = "Candles"
	desc = "A box of candles. Use them to fool others into thinking you're out for a romantic dinner...or something."
	typepath = /obj/item/storage/fancy/candle_box/full
	cost = 200

/datum/storeitem/nanomob_booster
	name = "Nano-Mob Hunter Trading Card Booster Pack"
	desc = "Contains 6 random Nano-Mob Hunter Trading Cards. May contain a holographic card!"
	typepath = /obj/item/storage/box/nanomob_booster_pack
	cost = 250

/datum/storeitem/crayons
	name = "Crayons"
	desc = "Let security know how they're doing by scrawling love notes all over their hallways."
	typepath = /obj/item/storage/fancy/crayons
	cost = 350

/datum/storeitem/pipe
	name = "Smoking Pipe"
	desc = "A pipe, for smoking. Probably made of meerschaum or something."
	typepath = /obj/item/clothing/mask/cigarette/pipe
	cost = 350

/datum/storeitem/minigibber
	name = "Miniature Gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	typepath = /obj/item/toy/minigibber
	cost = 400

/datum/storeitem/katana
	name = "Replica Katana"
	desc = "Woefully underpowered in D20."
	typepath = /obj/item/toy/katana
	cost = 500

/datum/storeitem/violin
	name = "Space Violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	typepath = /obj/item/instrument/violin
	cost = 500

/datum/storeitem/guitar
	name = "Guitar"
	desc = "It's made of wood and has bronze strings."
	typepath = /obj/item/instrument/guitar
	cost = 500

/datum/storeitem/eguitar
	name = "Electric Guitar"
	desc = "Makes all your shredding needs possible."
	typepath = /obj/item/instrument/eguitar
	cost = 500

/datum/storeitem/piano_synth
	name = "Piano Synthesizer"
	desc = "An advanced electronic synthesizer that can emulate various instruments."
	typepath = /obj/item/instrument/piano_synth
	cost = 1000

/datum/storeitem/baby
	name = "Toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	typepath = /obj/item/toddler
	cost = 1000

/datum/storeitem/flag_slime
	name = "Slime People Flag"
	desc = "A flag proudly proclaiming the superior heritage of Slime People."
	typepath = /obj/item/flag/species/slime
	cost = 1000

/datum/storeitem/flag_skrell
	name = "Skrell Flag"
	desc = "A flag proudly proclaiming the superior heritage of Skrell."
	typepath = /obj/item/flag/species/skrell
	cost = 1000

/datum/storeitem/flag_vox
	name = "Vox Flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	typepath = /obj/item/flag/species/vox
	cost = 1000

/datum/storeitem/flag_machine
	name = "Synthetics Flag"
	desc = "A flag proudly proclaiming the superior heritage of Synthetics."
	typepath = /obj/item/flag/species/machine
	cost = 1000

/datum/storeitem/flag_diona
	name = "Diona Flag"
	desc = "A flag proudly proclaiming the superior heritage of Dionae."
	typepath = /obj/item/flag/species/diona
	cost = 1000

/datum/storeitem/flag_human
	name = "Human Flag"
	desc = "A flag proudly proclaiming the superior heritage of Humans."
	typepath = /obj/item/flag/species/human
	cost = 1000

/datum/storeitem/flag_greys
	name = "Greys Flag"
	desc = "A flag proudly proclaiming the superior heritage of Greys."
	typepath = /obj/item/flag/species/greys
	cost = 1000

/datum/storeitem/flag_kidan
	name = "Kidan Flag"
	desc = "A flag proudly proclaiming the superior heritage of Kidan."
	typepath = /obj/item/flag/species/kidan
	cost = 1000

/datum/storeitem/flag_taj
	name = "Tajaran Flag"
	desc = "A flag proudly proclaiming the superior heritage of Tajara."
	typepath = /obj/item/flag/species/taj
	cost = 1000

/datum/storeitem/flag_unathi
	name = "Unathi Flag"
	desc = "A flag proudly proclaiming the superior heritage of Unathi."
	typepath = /obj/item/flag/species/unathi
	cost = 1000

/datum/storeitem/flag_vulp
	name = "Vulpkanin Flag"
	desc = "A flag proudly proclaiming the superior heritage of Vulpkanin."
	typepath = /obj/item/flag/species/vulp
	cost = 1000

/datum/storeitem/flag_drask
	name = "Drask Flag"
	desc = "A flag proudly proclaiming the superior heritage of Drask."
	typepath = /obj/item/flag/species/drask
	cost = 1000

/datum/storeitem/flag_plasma
	name = "Plasmaman Flag"
	desc = "A flag proudly proclaiming the superior heritage of Plasmamen."
	typepath = /obj/item/flag/species/plasma
	cost = 1000

/datum/storeitem/flag_ian
	name = "Ian Flag"
	desc = "The banner of Ian, because SQUEEEEE."
	typepath = /obj/item/flag/ian
	cost = 1500

/datum/storeitem/banhammer
	name = "Banhammer"
	desc = "A Banhammer."
	typepath = /obj/item/banhammer
	cost = 2000
