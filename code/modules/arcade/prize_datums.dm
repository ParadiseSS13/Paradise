GLOBAL_DATUM_INIT(global_prizes, /datum/prizes, new())

/datum/prizes
	var/list/prizes = list()

/datum/prizes/New()
	for(var/itempath in subtypesof(/datum/prize_item))
		prizes += new itempath()

/datum/prizes/proc/PlaceOrder(var/obj/machinery/prize_counter/prize_counter, var/itemID)
	if(!prize_counter.Adjacent(usr))
		to_chat(usr, "<span class='warning'>You need to be closer!</span>")
		return
	if(!prize_counter)
		return 0
	var/datum/prize_item/item = GLOB.global_prizes.prizes[itemID]
	if(!item)
		return 0
	if(prize_counter.tickets >= item.cost)
		new item.typepath(prize_counter.loc)
		prize_counter.tickets -= item.cost
		prize_counter.visible_message("<span class='notice'>Enjoy your prize!</span>")
		return 1
	else
		prize_counter.visible_message("<span class='warning'>Not enough tickets!</span>")
		return 0

//////////////////////////////////////
//			prize_item datum		//
//////////////////////////////////////

/datum/prize_item
	var/name = "Prize"
	var/desc = "This shouldn't show up..."
	var/typepath = /obj/item/toy/prizeball
	var/cost = 0

//////////////////////////////////////
//			    Prizes		    	//
//////////////////////////////////////

/datum/prize_item/balloon
	name = "Water Balloon"
	desc = "A thin balloon for throwing liquid at people."
	typepath = /obj/item/toy/balloon
	cost = 10

/datum/prize_item/spinningtoy
	name = "Spinning Toy"
	desc = "Looks like an authentic Singularity!"
	typepath = /obj/item/toy/spinningtoy
	cost = 15

/datum/prize_item/blinktoy
	name = "Blink Toy"
	desc = "Blink. Blink. Blink."
	typepath = /obj/item/toy/blink
	cost = 15

/datum/prize_item/dice
	name = "Dice Set"
	desc = "A set of assorted dice."
	typepath = /obj/item/storage/box/dice
	cost = 20

/datum/prize_item/foam_darts
	name = "Pack of Foam Darts"
	desc = "A refill pack with foam darts."
	typepath = /obj/item/ammo_box/foambox
	cost = 20

/datum/prize_item/snappops
	name = "Snap-Pops"
	desc = "A box of exploding snap-pop fireworks."
	typepath = /obj/item/storage/box/snappops
	cost = 20

/datum/prize_item/cards
	name = "Deck of Cards"
	desc = "Anyone fancy a game of 52-card Pickup?"
	typepath = /obj/item/deck/cards
	cost = 25

/datum/prize_item/crayons
	name = "Box of Crayons"
	desc = "A six-pack of crayons, just like back in kindergarten."
	typepath = /obj/item/storage/fancy/crayons
	cost = 35

/datum/prize_item/eight_ball
	name = "Magic Eight Ball"
	desc = "A mystical ball that can divine the future!"
	typepath = /obj/item/toy/eight_ball
	cost = 40

/datum/prize_item/wallet
	name = "Colored Wallet"
	desc = "Brightly colored and big enough for standard issue ID cards."
	typepath = /obj/item/storage/wallet/color
	cost = 50

/datum/prize_item/id_sticker
	name = "Prisoner ID Sticker"
	desc = "A sticker that can make any ID look like a prisoner ID."
	typepath = /obj/item/id_decal/prisoner
	cost = 50

/datum/prize_item/id_sticker/silver
	name = "Silver ID Sticker"
	desc = "A sticker that can make any ID look like a silver ID."
	typepath = /obj/item/id_decal/silver

/datum/prize_item/id_sticker/gold
	name = "Gold ID Sticker"
	desc = "A sticker that can make any ID look like a golden ID."
	typepath = /obj/item/id_decal/gold

/datum/prize_item/id_sticker/centcom
	name = "Centcomm ID Sticker"
	desc = "A sticker that can make any ID look like a Central Command ID."
	typepath = /obj/item/id_decal/centcom

/datum/prize_item/id_sticker/emag
	name = "Suspicious ID Sticker"
	desc = "A sticker that can make any ID look like something suspicious..."
	typepath = /obj/item/id_decal/emag

/datum/prize_item/flash
	name = "Toy Flash"
	desc = "AUGH! MY EYES!"
	typepath = /obj/item/toy/flash
	cost = 50

/datum/prize_item/minimeteor
	name = "Mini-Meteor"
	desc = "Meteors have been detected on a collision course with your fun times!"
	typepath = /obj/item/toy/minimeteor
	cost = 50

/datum/prize_item/therapy_doll
	name = "Random Therapy Doll"
	desc = "A therapeutic doll for relieving stress without being charged with assault."
	typepath = /obj/item/toy/prizeball/therapy
	cost = 60

/datum/prize_item/minigibber
	name = "Minigibber Toy"
	desc = "A model of the station gibber. Probably shouldn't stick your fingers in it."
	typepath = /obj/item/toy/minigibber
	cost = 60

/datum/prize_item/confetti
	name = "Confetti Grenade"
	desc = "Party time!"
	typepath = /obj/item/grenade/confetti
	cost = 65

/datum/prize_item/plushie
	name = "Random Plushie"
	desc = "A colorful plush toy."
	typepath = /obj/item/toy/prizeball/plushie
	cost = 75

/datum/prize_item/carp_plushie
	name = "Random Carp Plushie"
	desc = "A colorful fish-shaped plush toy."
	typepath = /obj/item/toy/prizeball/carp_plushie
	cost = 75

/datum/prize_item/mech_toy
	name = "Random Mecha"
	desc = "A random mecha figure, collect all 11!"
	typepath = /obj/item/toy/prizeball/mech
	cost = 75

/datum/prize_item/action_figure
	name = "Random Action Figure"
	desc = "A random action figure, collect them all!"
	typepath = /obj/item/toy/prizeball/figure
	cost = 75

/datum/prize_item/AI
	name = "Toy AI Unit"
	desc = "Law 1: Maximize fun for crew."
	typepath = /obj/item/toy/AI
	cost = 75

/datum/prize_item/capgun
	name = "Capgun Revolver"
	desc = "Do you feel lucky... punk?"
	typepath = /obj/item/gun/projectile/revolver/capgun
	cost = 75

/datum/prize_item/pet_rock
	name = "Pet Rock"
	desc = "A pet of your very own!"
	typepath = /obj/item/toy/pet_rock
	cost = 80

/datum/prize_item/toy_xeno
	name = "Xeno Action Figure"
	desc = "A lifelike replica of the horrific xeno scourge."
	typepath = /obj/item/toy/toy_xeno
	cost = 80

/datum/prize_item/tacticool
	name = "Tacticool Turtleneck"
	desc = "A cool-looking turtleneck."
	typepath = /obj/item/clothing/under/syndicate/tacticool
	cost = 90

/datum/prize_item/nanomob_booster
	name = "Nano-Mob Hunter Trading Card Booster Pack"
	desc = "Contains 6 random Nano-Mob Hunter Trading Cards. May contain a holographic card!"
	typepath = /obj/item/storage/box/nanomob_booster_pack
	cost = 100

/datum/prize_item/fakespell
	name = "Fake Spellbook"
	desc = "Perform magic! Astound your friends! Get mistaken for an enemy of the corporation!"
	typepath = /obj/item/spellbook/oneuse/fake_gib
	cost = 100

/datum/prize_item/fakefingergun
	name = "Miming Manual : Finger Gun"
	desc = "..."
	typepath = /obj/item/spellbook/oneuse/mime/fingergun/fake
	cost = 100

/datum/prize_item/magic_conch
	name = "Magic Conch Shell"
	desc = "All hail the magic conch!"
	typepath = /obj/item/toy/eight_ball/conch
	cost = 100

/datum/prize_item/crossbow
	name = "Foam Dart Crossbow"
	desc = "A toy crossbow that fires foam darts."
	typepath = /obj/item/gun/projectile/shotgun/toy/crossbow
	cost = 100

/datum/prize_item/foamblade
	name = "Foam Arm Blade"
	desc = "Perfect for reenacting space horror holo-vids."
	typepath = /obj/item/toy/foamblade
	cost = 100

/datum/prize_item/redbutton
	name = "Shiny Red Button"
	desc = "PRESS IT!"
	typepath = /obj/item/toy/redbutton
	cost = 100

/datum/prize_item/nuke
	name = "Nuclear Fun Device"
	desc = "Annihilate boredom with an explosion of excitement!"
	typepath = /obj/item/toy/nuke
	cost = 100

/datum/prize_item/blobhat
	name = "Blob Hat"
	desc = "There's... something... on your head..."
	typepath = /obj/item/clothing/head/blob
	cost = 125

/datum/prize_item/owl
	name = "Owl Action Figure"
	desc = "Remember: heroes don't grief!"
	typepath = /obj/item/toy/owl
	cost = 125

/datum/prize_item/griffin
	name = "Griffin Action Figure"
	desc = "If you can't be the best, you can always be the WORST."
	typepath = /obj/item/toy/griffin
	cost = 125

/datum/prize_item/codex_gigas
	name = "Toy Codex Gigas"
	desc = "For helping you come up with writing ideas for your diabolical adventures."
	typepath = /obj/item/toy/codex_gigas/
	cost = 75

/datum/prize_item/esword
	name = "Toy Energy Sword"
	desc = "A plastic replica of an energy blade."
	typepath = /obj/item/toy/sword
	cost = 150

/datum/prize_item/fakespace
	name = "Space Carpet"
	desc = "A stack of carpeted floor tiles that resemble space."
	typepath = /obj/item/stack/tile/fakespace/loaded
	cost = 150

/datum/prize_item/arcadecarpet
	name = "Arcade Carpet"
	desc = "A stack of genuine arcade carpet tiles, complete with authentic soft drink stains!"
	typepath = /obj/item/stack/tile/arcade_carpet/loaded
	cost = 150

/datum/prize_item/tommygun
	name = "Tommy Gun"
	desc = "A replica tommy gun that fires foam darts."
	typepath = /obj/item/gun/projectile/shotgun/toy/tommygun
	cost = 175

/datum/prize_item/spacesuit
	name = "Fake Spacesuit"
	desc = "A replica spacesuit. Not actually spaceworthy."
	typepath = /obj/item/storage/box/fakesyndiesuit
	cost = 180

/datum/prize_item/chainsaw
	name = "Toy Chainsaw"
	desc = "A full-scale model chainsaw, based on that massacre in Space Texas."
	typepath = /obj/item/twohanded/toy/chainsaw
	cost = 200

/datum/prize_item/headpat
	name = "Gloves of Headpats"
	desc = "Gloves that fill you with an irresistable urge to give headpats."
	typepath = /obj/item/clothing/gloves/fingerless/rapid/headpat
	cost = 150

/datum/prize_item/bike
	name = "Awesome Bike!"
	desc = "WOAH."
	typepath = /obj/structure/chair/wheelchair/bike
	cost = 10000	//max stack + 1 tickets.
