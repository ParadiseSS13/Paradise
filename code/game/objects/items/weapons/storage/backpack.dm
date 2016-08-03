
/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = 4
	slot_flags = SLOT_BACK	//ERROOOOO
	max_w_class = 3
	max_combined_w_class = 21
	storage_slots = 21
	burn_state = FLAMMABLE
	burntime = 20
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/back.dmi'
		)

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	playsound(src.loc, "rustle", 50, 1, -5)
	return ..()

/*
 * Backpack Types
 */

/obj/item/weapon/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	icon_state = "holdingpack"
	max_w_class = 5
	max_combined_w_class = 35
	burn_state = FIRE_PROOF

	New()
		..()
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		if(crit_fail)
			to_chat(user, "\red The Bluespace generator isn't working.")
			return
		else if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
			var/response = alert(user, "Are you sure you want to put the bag of holding inside another bag of holding?","Are you sure you want to die?","Yes","No")
			if(response == "Yes")
				user.visible_message("<span class='warning'>[user] grins as \he begins to put a Bag of Holding into a Bag of Holding!</span>", "<span class='warning'>You begin to put the Bag of Holding into the Bag of Holding!</span>")
				if(do_after(user,30,target=src))
					investigate_log("has become a singularity. Caused by [user.key]","singulo")
					user.visible_message("<span class='warning'>[user] erupts in evil laughter as \he puts the Bag of Holding into another Bag of Holding!</span>", "<span class='warning'>You can't help but laugh wildly as you put the Bag of Holding into another Bag of Holding, complete darkness surrounding you.</span>","<span class='warning'> You hear the sound of scientific evil brewing! </span>")
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

	proc/failcheck(mob/user as mob)
		if(prob(src.reliability)) return 1 //No failure
		if(prob(src.reliability))
			to_chat(user, "\red The Bluespace portal resists your attempt to add another item.")//light failure

		else
			to_chat(user, "\red The Bluespace generator malfunctions!")
			for(var/obj/O in src.contents) //it broke, delete what was in it
				qdel(O)
			crit_fail = 1
			icon_state = "brokenpack"

	singularity_act(current_size)
		var/dist = max((current_size - 2),1)
		explosion(src.loc,(dist),(dist*2),(dist*4))
		return


/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space on Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 400 // can store a ton of shit!

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/weapon/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/weapon/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = "A silent backpack made for those silent workers. Silence Co."
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/botany
	name = "botany backpack"
	desc = "It's a backpack made of all-natural fibers."
	icon_state = "botpack"
	item_state = "botpack"

/obj/item/weapon/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "A backpack specially designed to repel stains and hazardous liquids."
	icon_state = "chempack"
	item_state = "chempack"

/obj/item/weapon/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A bag designed to be super tough, just in case someone hulks out on you."
	icon_state = "genepack"
	item_state = "genepack"

/obj/item/weapon/storage/backpack/science
	name = "science backpack"
	desc = "A specially designed backpack. It's fire resistant and smells vaguely of plasma."
	icon_state = "toxpack"
	item_state = "toxpack"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/virology
	name = "virology backpack"
	desc = "A backpack made of hypo-allergenic fibers. It's designed to help prevent the spread of disease. Smells like monkey."
	icon_state = "viropack"
	item_state = "viropack"

/*
 * Satchel Types
 */

/obj/item/weapon/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/satcheldeluxe
	name = "leather satchel"
	desc = "An NT Deluxe satchel, with the finest quality leather and the company logo in a thin gold stitch"
	icon_state = "nt_deluxe"

/obj/item/weapon/storage/backpack/satchel/withwallet
	New()
		..()
		new /obj/item/weapon/storage/wallet/random( src )

/obj/item/weapon/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A deluxe NT Satchel, made of the highest quality leather."
	icon_state = "satchel"

/obj/item/weapon/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/weapon/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/weapon/storage/backpack/satchel_chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/weapon/storage/backpack/satchel_gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/weapon/storage/backpack/satchel_tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/satchel_sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"

/obj/item/weapon/storage/backpack/satchel_hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel-hyd"

/obj/item/weapon/storage/backpack/satchel_cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/satchel_flat
	name = "smuggler's satchel"
	desc = "A very slim satchel that can easily fit into tight spaces."
	icon_state = "satchel-flat"
	w_class = 3 //Can fit in backpacks itself.
	max_combined_w_class = 15
	level = 1
	cant_hold = list(/obj/item/weapon/storage/backpack/satchel_flat) //muh recursive backpacks

/obj/item/weapon/storage/backpack/satchel_flat/hide(var/intact)
	if(intact)
		invisibility = 101
		anchored = 1 //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
	else
		invisibility = initial(invisibility)
		anchored = 0
		icon_state = initial(icon_state)

/obj/item/weapon/storage/backpack/satchel_flat/New()
	..()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/weapon/crowbar(src)

/*
 * Duffelbags - My thanks to MrSnapWalk for the original icon and Neinhaus for the job variants - Dave.
 */

/obj/item/weapon/storage/backpack/duffel
	name = "duffelbag"
	desc = "A large grey duffelbag designed to hold more items than a regular bag."
	icon_state = "duffel"
	item_state = "duffel"
	max_combined_w_class = 30
	slowdown = 1

/obj/item/weapon/storage/backpack/duffel/syndie
	name = "suspicious looking dufflebag"
	desc = "A large dufflebag for holding extra tactical supplies."
	icon_state = "duffel-syndi"
	item_state = "duffel-syndimed"
	origin_tech = "syndicate=1"
	silent = 1
	slowdown = 0

/obj/item/weapon/storage/backpack/duffel/syndie/med
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a red and white cross sewn onto it."
	icon_state = "duffel-syndimed"
	item_state = "duffel-syndimed"

/obj/item/weapon/storage/backpack/duffel/syndie/ammo
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a patch depicting shotgun shells sewn onto it."
	icon_state = "duffel-syndiammo"
	item_state = "duffel-syndiammo"

/obj/item/weapon/storage/backpack/duffel/syndie/ammo/loaded
	desc = "A large dufflebag, packed to the brim with Bulldog shotgun ammo."

/obj/item/weapon/storage/backpack/duffel/syndie/ammo/loaded/New()
	..()
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/stun(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/weapon/storage/backpack/duffel/syndie/surgery
	name = "surgery dufflebag"
	desc = "A suspicious looking dufflebag for holding surgery tools."
	icon_state = "duffel-syndimed"
	item_state = "duffle-syndimed"

/obj/item/weapon/storage/backpack/duffel/syndie/surgery/New()
	..()
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/bonegel(src)
	new /obj/item/weapon/bonesetter(src)
	new /obj/item/weapon/FixOVein(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/device/mmi/syndie(src)

/obj/item/weapon/storage/backpack/duffel/syndie/surgery_fake //for maint spawns
	name = "surgery dufflebag"
	desc = "A suspicious looking dufflebag for holding surgery tools."
	icon_state = "duffel-syndimed"
	item_state = "duffle-syndimed"

/obj/item/weapon/storage/backpack/duffel/syndie/surgery_fake/New()
	..()
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/bonegel(src)
	new /obj/item/weapon/bonesetter(src)
	new /obj/item/weapon/FixOVein(src)
	if(prob(50))
		new /obj/item/weapon/circular_saw(src)
		new /obj/item/weapon/surgicaldrill(src)

/obj/item/weapon/storage/backpack/duffel/captain
	name = "captain's duffelbag"
	desc = "A duffelbag designed to hold large quantities of condoms."
	icon_state = "duffel-captain"
	item_state = "duffel-captain"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/duffel/security
	name = "security duffelbag"
	desc = "A duffelbag built with robust fabric!"
	icon_state = "duffel-security"
	item_state = "duffel-security"

/obj/item/weapon/storage/backpack/duffel/virology
	name = "virology duffelbag"
	desc = "A white duffelbag designed to contain biohazards."
	icon_state = "duffel-viro"
	item_state = "duffel-viro"

/obj/item/weapon/storage/backpack/duffel/science
	name = "scientist duffelbag"
	desc = "A duffelbag designed to hold the secrets of space."
	icon_state = "duffel-toxins"
	item_state = "duffel-toxins"

/obj/item/weapon/storage/backpack/duffel/genetics
	name = "geneticist duffelbag"
	desc = "A duffelbag designed to hold gibbering monkies."
	icon_state = "duffel-gene"
	item_state = "duffel-gene"

/obj/item/weapon/storage/backpack/duffel/chemistry
	name = "chemist duffelbag"
	desc = "A duffelbag designed to hold corrosive substances."
	icon_state = "duffel-chemistry"
	item_state = "duffel-chemistry"

/obj/item/weapon/storage/backpack/duffel/medical
	name = "medical duffelbag"
	desc = "A duffelbag designed to hold medicine."
	icon_state = "duffel-med"
	item_state = "duffel-med"

/obj/item/weapon/storage/backpack/duffel/engineering
	name = "industrial duffelbag"
	desc = "A duffelbag designed to hold tools."
	icon_state = "duffel-eng"
	item_state = "duffel-eng"
	burn_state = FIRE_PROOF

/obj/item/weapon/storage/backpack/duffel/hydro
	name = "hydroponics duffelbag"
	desc = "A duffelbag designed to hold seeds and fauna."
	icon_state = "duffel-hydro"
	item_state = "duffel-hydro"

/obj/item/weapon/storage/backpack/duffel/clown
	name = "smiles von wiggleton"
	desc = "A duffelbag designed to hold bananas and bike horns."
	icon_state = "duffel-clown"
	item_state = "duffel-clown"

//ERT backpacks.
/obj/item/weapon/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Nanotrasen Emergency Response Team."
	icon_state = "ert_commander"
	item_state = "backpack"

//Commander
/obj/item/weapon/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Nanotrasen Emergency Response Team."

//Security
/obj/item/weapon/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/weapon/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/weapon/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_medical"

//Janitorial
/obj/item/weapon/storage/backpack/ert/janitor
	name = "emergency response team janitor backpack"
	desc = "A spacious backpack with lots of pockets, worn by janitorial members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_janitor"