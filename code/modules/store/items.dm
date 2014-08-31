/////////////////////////////
// Store Item
/////////////////////////////
/datum/storeitem
	var/name="Thing"
	var/desc="It's a thing."
	var/typepath=/obj/item/weapon/storage/box
	var/cost=0

/datum/storeitem/proc/deliver(var/mob/usr)
	if(!istype(typepath,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/box/box=new(usr.loc)
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
	typepath = /obj/item/weapon/storage/box/snappops
	cost = 200

/datum/storeitem/crayons
	name = "Crayons"
	desc = "Let security know how they're doing by scrawling lovenotes all over their hallways."
	typepath = /obj/item/weapon/storage/fancy/crayons
	cost = 350

/datum/storeitem/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	typepath = /obj/item/clothing/mask/cigarette/pipe
	cost = 350

/datum/storeitem/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	typepath = /obj/item/toy/katana
	cost = 500

/datum/storeitem/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	typepath = /obj/item/device/violin
	cost = 500

/datum/storeitem/baby
	name = "Toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	typepath = /obj/item/weapon/toddler
	cost = 1000

/datum/storeitem/laserpointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	typepath = /obj/item/device/laser_pointer
	cost = 1000

/datum/storeitem/flag/slime
	name = "Slime People flag"
	desc = "A flag proudly proclaiming the superior heritage of Slime People."
	typepath = /obj/item/flag/species/slime
	cost = 1000

/datum/storeitem/flag/skrell
	name = "Skrell flag"
	desc = "A flag proudly proclaiming the superior heritage of Skrell."
	typepath = /obj/item/flag/species/skrell
	cost = 1000

/datum/storeitem/flag/vox
	name = "Vox flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	typepath = /obj/item/flag/species/vox
	cost = 1000

/datum/storeitem/flag/machine
	name = "Synthetics flag"
	desc = "A flag proudly proclaiming the superior heritage of Synthetics."
	typepath = /obj/item/flag/species/machine
	cost = 1000

/datum/storeitem/flag/diona
	name = "Diona flag"
	desc = "A flag proudly proclaiming the superior heritage of Diona."
	typepath = /obj/item/flag/species/diona
	cost = 1000

/datum/storeitem/flag/human
	name = "Human flag"
	desc = "A flag proudly proclaiming the superior heritage of Humans."
	typepath = /obj/item/flag/species/human
	cost = 1000

/datum/storeitem/flag/greys
	name = "Greys flag"
	desc = "A flag proudly proclaiming the superior heritage of Greys."
	typepath = /obj/item/flag/species/greys
	cost = 1000

/datum/storeitem/flag/kidan
	name = "Kidan flag"
	desc = "A flag proudly proclaiming the superior heritage of Kidan."
	typepath = /obj/item/flag/species/kidan
	cost = 1000

/datum/storeitem/flag/taj
	name = "Tajaran flag"
	desc = "A flag proudly proclaiming the superior heritage of Tajaran."
	typepath = /obj/item/flag/species/taj
	cost = 1000

/datum/storeitem/flag/unathi
	name = "Unathi flag"
	desc = "A flag proudly proclaiming the superior heritage of Unathi."
	typepath = /obj/item/flag/species/unathi
	cost = 1000

/datum/storeitem/flag/ian
	name = "Ian flag"
	desc = "The banner of Ian, because SQUEEEEE."
	typepath = /obj/item/flag/ian
	cost = 1500

/datum/storeitem/banhammer
	desc = "A banhammer"
	name = "banhammer"
	typepath = /obj/item/weapon/banhammer
	cost = 2000
