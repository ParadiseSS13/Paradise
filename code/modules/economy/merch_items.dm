/*
  * # datum/merch_item
  *
  * Stores information about items sold in the merchandise computer
*/

/datum/merch_item
	var/name
	var/desc
	var/typepath
	var/cost
	var/category

/datum/merch_item/snap_pops
	name = "Snap-Pops"
	desc = "Ten-thousand-year-old chinese fireworks: IN SPACE!"
	typepath = /obj/item/storage/box/snappops
	cost = 100
	category = MERCH_CAT_TOY


/datum/merch_item/dnd
	name = "Dungeons & Dragons Set"
	desc = "A box containing minifigures suitable for a good game of D&D."
	typepath = /obj/item/storage/box/characters
	cost = 100
	category = MERCH_CAT_TOY

/datum/merch_item/dice
	name = "Dice Set"
	desc = "A box containing multiple different types of die."
	typepath = /obj/item/storage/box/dice
	cost = 100
	category = MERCH_CAT_TOY

/datum/merch_item/candle
	name = "Candles"
	desc = "A box of candles. Use them to fool others into thinking you're out for a romantic dinner...or something."
	typepath = /obj/item/storage/fancy/candle_box/full
	cost = 100
	category = MERCH_CAT_TOY

/datum/merch_item/scratch_card
	name = "Scratch Cards Box"
	desc = "Contains 5 scratch cards. Become rich today!"
	typepath = /obj/item/storage/box/scratch_cards
	cost = 100
	category = MERCH_CAT_TOY

/datum/merch_item/crayons
	name = "Crayons"
	desc = "Let security know how they're doing by scrawling love notes all over their hallways."
	typepath = /obj/item/storage/fancy/crayons
	cost = 175
	category = MERCH_CAT_TOY

/datum/merch_item/pipe
	name = "Smoking Pipe"
	desc = "A pipe, for smoking. Probably made of meerschaum or something."
	typepath = /obj/item/clothing/mask/cigarette/pipe
	cost = 175
	category = MERCH_CAT_TOY

/datum/merch_item/minigibber
	name = "Miniature Gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	typepath = /obj/item/toy/minigibber
	cost = 200
	category = MERCH_CAT_TOY

/datum/merch_item/unum
	name = "UNUM!"
	desc = "Everyone's favorite card game!"
	typepath = /obj/item/deck/unum
	cost = 200
	category = MERCH_CAT_TOY

/datum/merch_item/katana
	name = "Replica Katana"
	desc = "Woefully underpowered in D20."
	typepath = /obj/item/toy/katana
	cost = 250
	category = MERCH_CAT_TOY

/datum/merch_item/violin
	name = "Space Violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	typepath = /obj/item/instrument/violin
	cost = 250
	category = MERCH_CAT_TOY

/datum/merch_item/guitar
	name = "Guitar"
	desc = "It's made of wood and has bronze strings."
	typepath = /obj/item/instrument/guitar
	cost = 250
	category = MERCH_CAT_TOY

/datum/merch_item/eguitar
	name = "Electric Guitar"
	desc = "Makes all your shredding needs possible."
	typepath = /obj/item/instrument/eguitar
	cost = 250
	category = MERCH_CAT_TOY

/datum/merch_item/banjo
	name = "Banjo"
	desc = "It's pretty much just a drum with a neck and strings."
	typepath = /obj/item/instrument/banjo
	cost = 250
	category = MERCH_CAT_TOY

/datum/merch_item/piano_synth
	name = "Piano Synthesizer"
	desc = "An advanced electronic synthesizer that can emulate various instruments."
	typepath = /obj/item/instrument/piano_synth
	cost = 500
	category = MERCH_CAT_TOY

/datum/merch_item/skateboard
	name = "Skateboard"
	desc = "A skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	typepath = /obj/item/melee/skateboard
	cost = 250
	category = MERCH_CAT_TOY

/datum/merch_item/pro_skateboard
	name = "Pro Skateboard"
	desc = "An EightO brand professional skateboard. It looks sturdy and well made."
	typepath = /obj/item/melee/skateboard/pro
	cost = 600 //Quite fast, though I expect people to fall flat on their face with this a lot.
	category = MERCH_CAT_TOY

/datum/merch_item/flag_slime
	name = "Slime People Flag"
	desc = "A flag proudly proclaiming the superior heritage of Slime People."
	typepath = /obj/item/flag/species/slime
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_skrell
	name = "Skrell Flag"
	desc = "A flag proudly proclaiming the superior heritage of Skrell."
	typepath = /obj/item/flag/species/skrell
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_vox
	name = "Vox Flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	typepath = /obj/item/flag/species/vox
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_machine
	name = "Synthetics Flag"
	desc = "A flag proudly proclaiming the superior heritage of Synthetics."
	typepath = /obj/item/flag/species/machine
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_diona
	name = "Diona Flag"
	desc = "A flag proudly proclaiming the superior heritage of Dionae."
	typepath = /obj/item/flag/species/diona
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_human
	name = "Human Flag"
	desc = "A flag proudly proclaiming the superior heritage of Humans."
	typepath = /obj/item/flag/species/human
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_greys
	name = "Greys Flag"
	desc = "A flag proudly proclaiming the superior heritage of Greys."
	typepath = /obj/item/flag/species/greys
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_kidan
	name = "Kidan Flag"
	desc = "A flag proudly proclaiming the superior heritage of Kidan."
	typepath = /obj/item/flag/species/kidan
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_taj
	name = "Tajaran Flag"
	desc = "A flag proudly proclaiming the superior heritage of Tajara."
	typepath = /obj/item/flag/species/taj
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_unathi
	name = "Unathi Flag"
	desc = "A flag proudly proclaiming the superior heritage of Unathi."
	typepath = /obj/item/flag/species/unathi
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_vulp
	name = "Vulpkanin Flag"
	desc = "A flag proudly proclaiming the superior heritage of Vulpkanin."
	typepath = /obj/item/flag/species/vulp
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_drask
	name = "Drask Flag"
	desc = "A flag proudly proclaiming the superior heritage of Drask."
	typepath = /obj/item/flag/species/drask
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_plasma
	name = "Plasmaman Flag"
	desc = "A flag proudly proclaiming the superior heritage of Plasmamen."
	typepath = /obj/item/flag/species/plasma
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_nian
	name = "Nian Flag"
	desc = "A well-crafted Nianen flag. Approved by the CDM and the Crafting Guild."
	typepath = /obj/item/flag/species/nian
	cost = 500
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_ian
	name = "Ian Flag"
	desc = "The banner of Ian, because SQUEEEEE."
	typepath = /obj/item/flag/ian
	cost = 750
	category = MERCH_CAT_DECORATION

/datum/merch_item/flag_solgov
	name = "SolGov Flag"
	desc = "The banner of Trans-Solar Federation."
	typepath = /obj/item/flag/solgov
	cost = 750
	category = MERCH_CAT_DECORATION

/datum/merch_item/banhammer
	name = "Banhammer"
	desc = "A Banhammer."
	typepath = /obj/item/banhammer
	cost = 1000
	category = MERCH_CAT_TOY
