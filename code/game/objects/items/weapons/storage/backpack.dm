
/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK	//ERROOOOO
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	storage_slots = 21
	burn_state = FLAMMABLE
	burntime = 20
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/back.dmi'
		)

/obj/item/storage/backpack/attackby(obj/item/W as obj, mob/user as mob, params)
	playsound(src.loc, "rustle", 50, 1, -5)
	return ..()

/obj/item/storage/backpack/examine(mob/user)
	var/space_used = 0
	if(!..(user, 1))
		return
	for(var/obj/item/I in contents)
		space_used += I.w_class
	if(!space_used)
		to_chat(user, "<span class='notice'> [src] is empty.</span>")
	else if(space_used <= max_combined_w_class*0.6)
		to_chat(user, "<span class='notice'> [src] still has plenty of remaining space.</span>")
	else if(space_used <= max_combined_w_class*0.8)
		to_chat(user, "<span class='notice'> [src] is beginning to run out of space.</span>")
	else if(space_used < max_combined_w_class)
		to_chat(user, "<span class='notice'> [src] doesn't have much space left.</span>")
	else
		to_chat(user, "<span class='notice'> [src] is full.</span>")

/*
 * Backpack Types
 */

/obj/item/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	icon_state = "holdingpack"
	max_w_class = WEIGHT_CLASS_HUGE
	max_combined_w_class = 35
	burn_state = FIRE_PROOF
	flags_2 = NO_MAT_REDEMPTION_2
	cant_hold = list(/obj/item/storage/backpack/holding)

/obj/item/storage/backpack/holding/New()
	..()
	return

/obj/item/storage/backpack/holding/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/backpack/holding))
		var/response = alert(user, "This creates a singularity, destroying you and much of the station. Are you SURE?","IMMINENT DEATH!", "No", "Yes")
		if(response == "Yes")
			user.visible_message("<span class='warning'>[user] grins as [user.p_they()] begin[user.p_s()] to put a Bag of Holding into a Bag of Holding!</span>", "<span class='warning'>You begin to put the Bag of Holding into the Bag of Holding!</span>")
			if(do_after(user, 30, target=src))
				investigate_log("has become a singularity. Caused by [user.key]","singulo")
				user.visible_message("<span class='warning'>[user] erupts in evil laughter as [user.p_they()] put[user.p_s()] the Bag of Holding into another Bag of Holding!</span>", "<span class='warning'>You can't help but laugh wildly as you put the Bag of Holding into another Bag of Holding, complete darkness surrounding you.</span>","<span class='warning'> You hear the sound of scientific evil brewing! </span>")
				qdel(W)
				var/obj/singularity/singulo = new /obj/singularity(get_turf(user))
				singulo.energy = 300 //To give it a small boost
				message_admins("[key_name_admin(user)] detonated a bag of holding <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				log_game("[key_name(user)] detonated a bag of holding")
				qdel(src)
			else
				user.visible_message("After careful consideration, [user] has decided that putting a Bag of Holding inside another Bag of Holding would not yield the ideal outcome.","You come to the realization that this might not be the greatest idea.")
	else
		. = ..()

/obj/item/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))
	return

/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space on Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 400 // can store a ton of shit!

/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/storage/backpack/clown/syndie

/obj/item/storage/backpack/clown/syndie/New()
	..()
	new /obj/item/clothing/under/rank/clown(src)
	new /obj/item/clothing/shoes/magboots/clown(src)
	new /obj/item/clothing/mask/gas/voice/clown(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/pda/clown(src)
	new /obj/item/storage/box/survival(src)
	new /obj/item/reagent_containers/food/snacks/grown/banana(src)
	new /obj/item/stamp/clown(src)
	new /obj/item/toy/crayon/rainbow(src)
	new /obj/item/storage/fancy/crayons(src)
	new /obj/item/reagent_containers/spray/waterflower(src)
	new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(src)
	new /obj/item/instrument/bikehorn(src)
	new /obj/item/bikehorn(src)

/obj/item/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = "A silent backpack made for those silent workers. Silence Co."
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/botany
	name = "botany backpack"
	desc = "It's a backpack made of all-natural fibers."
	icon_state = "botpack"
	item_state = "botpack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "A backpack specially designed to repel stains and hazardous liquids."
	icon_state = "chempack"
	item_state = "chempack"

/obj/item/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A bag designed to be super tough, just in case someone hulks out on you."
	icon_state = "genepack"
	item_state = "genepack"

/obj/item/storage/backpack/science
	name = "science backpack"
	desc = "A specially designed backpack. It's fire resistant and smells vaguely of plasma."
	icon_state = "toxpack"
	item_state = "toxpack"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/virology
	name = "virology backpack"
	desc = "A backpack made of hypo-allergenic fibers. It's designed to help prevent the spread of disease. Smells like monkey."
	icon_state = "viropack"
	item_state = "viropack"

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	burn_state = FIRE_PROOF
	var/strap_side_straight = FALSE

/obj/item/storage/backpack/satchel/verb/switch_strap()
	set name = "Switch Strap Side"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return
	strap_side_straight = !strap_side_straight
	icon_state = strap_side_straight ? "satchel-flipped" : "satchel"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_back()



/obj/item/storage/backpack/satcheldeluxe
	name = "leather satchel"
	desc = "An NT Deluxe satchel, with the finest quality leather and the company logo in a thin gold stitch"
	icon_state = "nt_deluxe"

/obj/item/storage/backpack/satchel/withwallet/New()
	..()
	new /obj/item/storage/wallet/random(src)

/obj/item/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A deluxe NT Satchel, made of the highest quality leather."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/storage/backpack/satchel_chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/storage/backpack/satchel_gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/storage/backpack/satchel_tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/satchel_sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"

/obj/item/storage/backpack/satchel_hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel-hyd"

/obj/item/storage/backpack/satchel_cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/satchel_flat
	name = "smuggler's satchel"
	desc = "A very slim satchel that can easily fit into tight spaces."
	icon_state = "satchel-flat"
	w_class = WEIGHT_CLASS_NORMAL //Can fit in backpacks itself.
	max_combined_w_class = 15
	level = 1
	cant_hold = list(/obj/item/storage/backpack/satchel_flat) //muh recursive backpacks

/obj/item/storage/backpack/satchel_flat/hide(var/intact)
	if(intact)
		invisibility = 101
		anchored = 1 //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
	else
		invisibility = initial(invisibility)
		anchored = 0
		icon_state = initial(icon_state)

/obj/item/storage/backpack/satchel_flat/New()
	..()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/crowbar(src)

/*
 * Duffelbags - My thanks to MrSnapWalk for the original icon and Neinhaus for the job variants - Dave.
 */

/obj/item/storage/backpack/duffel
	name = "duffelbag"
	desc = "A large grey duffelbag designed to hold more items than a regular bag."
	icon_state = "duffel"
	item_state = "duffel"
	max_combined_w_class = 30
	slowdown = 1

/obj/item/storage/backpack/duffel/syndie
	name = "suspicious looking duffelbag"
	desc = "A large duffelbag for holding extra tactical supplies."
	icon_state = "duffel-syndie"
	item_state = "duffel-syndimed"
	origin_tech = "syndicate=1"
	silent = 1
	slowdown = 0

/obj/item/storage/backpack/duffel/syndie/med
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a red and white cross sewn onto it."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/ammo
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a patch depicting shotgun shells sewn onto it."
	icon_state = "duffel-syndiammo"
	item_state = "duffel-syndiammo"

/obj/item/storage/backpack/duffel/syndie/ammo/shotgun
	desc = "A large duffelbag, packed to the brim with Bulldog shotgun ammo."

/obj/item/storage/backpack/duffel/syndie/ammo/shotgun/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/storage/backpack/duffel/syndie/ammo/smg
	desc = "A large duffel bag, packed to the brim with C-20r magazines."

/obj/item/storage/backpack/duffel/syndie/ammo/smg/New()
	..()
	for(var/i in 1 to 10)
		new /obj/item/ammo_box/magazine/smgm45(src)

/obj/item/storage/backpack/duffel/syndie/c20rbundle
	desc = "A large duffel bag containing a C-20r, some magazines, and a cheap looking suppressor."

/obj/item/storage/backpack/duffel/syndie/c20rbundle/New()
	..()
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/gun/projectile/automatic/c20r(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/backpack/duffel/syndie/bulldogbundle
	desc = "A large duffel bag containing a Bulldog, some drums, and a pair of thermal imaging glasses."

/obj/item/storage/backpack/duffel/syndie/bulldogbundle/New()
	..()
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)

/obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	desc = "A large duffel bag containing a tactical medkit, a Donksoft machine gun and a big jumbo box of riot darts."

/obj/item/storage/backpack/duffel/syndie/med/medicalbundle/New()
	..()
	new /obj/item/storage/firstaid/tactical(src)
	new /obj/item/gun/projectile/automatic/l6_saw/toy(src)
	new /obj/item/ammo_box/foambox/riot(src)

/obj/item/storage/backpack/duffel/syndie/c4/New()
	..()
	for(var/i in 1 to 10)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/backpack/duffel/syndie/x4/New()
	..()
	for(var/i in 1 to 3)
		new /obj/item/grenade/plastic/x4(src)

/obj/item/storage/backpack/duffel/syndie/surgery
	name = "surgery duffelbag"
	desc = "A suspicious looking duffelbag for holding surgery tools."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/surgery/New()
	..()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/FixOVein(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)

/obj/item/storage/backpack/duffel/syndie/surgery_fake //for maint spawns
	name = "surgery duffelbag"
	desc = "A suspicious looking duffelbag for holding surgery tools."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/surgery_fake/New()
	..()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/cautery(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/FixOVein(src)
	if(prob(50))
		new /obj/item/circular_saw(src)
		new /obj/item/surgicaldrill(src)

/obj/item/storage/backpack/duffel/captain
	name = "captain's duffelbag"
	desc = "A duffelbag designed to hold large quantities of condoms."
	icon_state = "duffel-captain"
	item_state = "duffel-captain"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/duffel/security
	name = "security duffelbag"
	desc = "A duffelbag built with robust fabric!"
	icon_state = "duffel-security"
	item_state = "duffel-security"

/obj/item/storage/backpack/duffel/virology
	name = "virology duffelbag"
	desc = "A white duffelbag designed to contain biohazards."
	icon_state = "duffel-viro"
	item_state = "duffel-viro"

/obj/item/storage/backpack/duffel/science
	name = "scientist duffelbag"
	desc = "A duffelbag designed to hold the secrets of space."
	icon_state = "duffel-toxins"
	item_state = "duffel-toxins"

/obj/item/storage/backpack/duffel/genetics
	name = "geneticist duffelbag"
	desc = "A duffelbag designed to hold gibbering monkies."
	icon_state = "duffel-gene"
	item_state = "duffel-gene"

/obj/item/storage/backpack/duffel/chemistry
	name = "chemist duffelbag"
	desc = "A duffelbag designed to hold corrosive substances."
	icon_state = "duffel-chemistry"
	item_state = "duffel-chemistry"

/obj/item/storage/backpack/duffel/medical
	name = "medical duffelbag"
	desc = "A duffelbag designed to hold medicine."
	icon_state = "duffel-med"
	item_state = "duffel-med"

/obj/item/storage/backpack/duffel/engineering
	name = "industrial duffelbag"
	desc = "A duffelbag designed to hold tools."
	icon_state = "duffel-eng"
	item_state = "duffel-eng"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/duffel/atmos
	name = "atmospherics duffelbag"
	desc = "A duffelbag designed to hold tools. This one is specially designed for atmospherics."
	icon_state = "duffel-atmos"
	item_state = "duffel-atmos"
	burn_state = FIRE_PROOF

/obj/item/storage/backpack/duffel/hydro
	name = "hydroponics duffelbag"
	desc = "A duffelbag designed to hold seeds and fauna."
	icon_state = "duffel-hydro"
	item_state = "duffel-hydro"

/obj/item/storage/backpack/duffel/clown
	name = "smiles von wiggleton"
	desc = "A duffelbag designed to hold bananas and bike horns."
	icon_state = "duffel-clown"
	item_state = "duffel-clown"

//ERT backpacks.
/obj/item/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Nanotrasen Emergency Response Team."
	icon_state = "ert_commander"
	item_state = "backpack"

//Commander
/obj/item/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Nanotrasen Emergency Response Team."

//Security
/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_medical"

//Janitorial
/obj/item/storage/backpack/ert/janitor
	name = "emergency response team janitor backpack"
	desc = "A spacious backpack with lots of pockets, worn by janitorial members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_janitor"
