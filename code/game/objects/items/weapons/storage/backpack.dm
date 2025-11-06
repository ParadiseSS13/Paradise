
/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK	//ERROOOOO
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	storage_slots = 21
	max_integrity = 300
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/back.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/back.dmi'
		)

/obj/item/storage/backpack/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(Adjacent(user))
		playsound(src.loc, "rustle", 50, TRUE, -5)
		return ..()

/obj/item/storage/backpack/examine(mob/user)
	var/space_used = 0
	. = ..()
	if(Adjacent(user))
		for(var/obj/item/I in contents)
			space_used += I.w_class
		if(!space_used)
			. += "<span class='notice'>[src] is empty.</span>"
		else if(space_used <= max_combined_w_class * 0.6)
			. += "<span class='notice'>[src] still has plenty of remaining space.</span>"
		else if(space_used <= max_combined_w_class * 0.8)
			. += "<span class='notice'>[src] is beginning to run out of space.</span>"
		else if(space_used < max_combined_w_class)
			. += "<span class='notice'>[src] doesn't have much space left.</span>"
		else
			. += "<span class='notice'>[src] is full.</span>"

/*
 * Backpack Types
 */

/obj/item/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A bleeding-edge backpack that uses bluespace technology to create a localized dimensional pocket for storage."
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	icon_state = "holdingpack"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 28
	resistance_flags = FIRE_PROOF
	flags_2 = NO_MAT_REDEMPTION_2
	cant_hold = list(/obj/item/storage/backpack, /obj/item/storage/belt/bluespace)
	cant_hold_override = list(/obj/item/storage/backpack/satchel_flat)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 60, ACID = 50)
	allow_same_size = TRUE

/obj/item/storage/backpack/holding/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/backpack/holding))
		var/response = tgui_alert(user, "This creates a singularity, destroying you and much of the station. Are you SURE?", "IMMINENT DEATH!", list("No", "Yes"))
		if(response == "Yes")
			user.visible_message("<span class='warning'>[user] grins as [user.p_they()] begin[user.p_s()] to put a Bag of Holding into a Bag of Holding!</span>", "<span class='warning'>You begin to put the Bag of Holding into the Bag of Holding!</span>")
			if(do_after(user, 30, target=src))
				if(GLOB.disable_explosions)
					if(istype(user))
						to_chat(user, "<span class='userdanger'>You seem to stuff yourself into the quantum hellscape between the two bags. That wasn't wise.</span>")
						user.gib()

					return

				investigate_log("has become a singularity. Caused by [user.key]",INVESTIGATE_SINGULO)
				user.visible_message("<span class='warning'>[user] erupts in evil laughter as [user.p_they()] put[user.p_s()] the Bag of Holding into another Bag of Holding!</span>", "<span class='warning'>You can't help but laugh wildly as you put the Bag of Holding into another Bag of Holding, complete darkness surrounding you.</span>","<span class='danger'> You hear the sound of scientific evil brewing!</span>")
				qdel(W)
				var/obj/singularity/singulo = new /obj/singularity(get_turf(user))
				singulo.energy = 300 //To give it a small boost
				message_admins("[key_name_admin(user)] detonated a bag of holding <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				log_game("[key_name(user)] detonated a bag of holding")
				qdel(src)
			else
				user.visible_message("After careful consideration, [user] has decided that putting a Bag of Holding inside another Bag of Holding would not yield the ideal outcome.","You come to the realization that this might not be the greatest idea.")
	else
		. = ..()

/obj/item/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2), 1)
	explosion(loc, dist, (dist * 2), (dist * 4), cause = "Bag of Holding (singularity_act)")

/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space on Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	max_combined_w_class = 400 // can store a ton of shit!

/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"
	inhand_icon_state = "backpack"

/obj/item/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"

/obj/item/storage/backpack/clown/syndie/populate_contents()
	new /obj/item/clothing/under/rank/civilian/clown(src)
	new /obj/item/clothing/shoes/magboots/clown(src)
	new /obj/item/clothing/mask/chameleon/voice_change(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/pda/clown(src)
	new /obj/item/storage/box/survival(src)
	new /obj/item/food/grown/banana(src)
	new /obj/item/stamp/clown(src)
	new /obj/item/toy/crayon/rainbow(src)
	new /obj/item/storage/fancy/crayons(src)
	new /obj/item/reagent_containers/spray/waterflower(src)
	new /obj/item/reagent_containers/drinks/bottle/bottleofbanana(src)
	new /obj/item/instrument/bikehorn(src)
	new /obj/item/bikehorn(src)
	new /obj/item/dnainjector/comic(src)
	for(var/i in 1 to 10)
		new /obj/item/ammo_box/magazine/m12g/confetti(src)
	for(var/i in 1 to 5)
		new /obj/item/grenade/confetti(src)
	new /obj/item/gun/projectile/revolver/capgun(src)

/obj/item/storage/backpack/mime
	name = "Pierre the Panda"
	desc = "A backpack modelled after Pierre the Panda - the official mascot for the Université du Mime."
	icon_state = "mimepack"

/obj/item/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	inhand_icon_state = "backpack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/industrial/atmos
	name = "atmospherics backpack"
	desc = "It's a fireproof backpack for Atmospherics Staff."
	icon_state = "atmospack"

/obj/item/storage/backpack/explorer
	name = "explorer bag"
	desc = "A robust backpack for stashing your loot."
	icon_state = "explorerpack"

/obj/item/storage/backpack/botany
	name = "botany backpack"
	desc = "It's a backpack made of all-natural fibers."
	icon_state = "botpack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "A backpack specially designed to repel stains and hazardous liquids."
	icon_state = "chempack"

/obj/item/storage/backpack/genetics
	name = "genetics backpack"
	desc = "A bag designed to be super tough, just in case someone hulks out on you."
	icon_state = "genepack"

/obj/item/storage/backpack/science
	name = "science backpack"
	desc = "A specially designed backpack. It's fire resistant and smells vaguely of plasma."
	icon_state = "toxpack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/virology
	name = "virology backpack"
	desc = "A backpack made of hypo-allergenic fibers. It's designed to help prevent the spread of disease. Smells like monkey."
	icon_state = "viropack"

/obj/item/storage/backpack/blueshield
	name = "blueshield backpack"
	desc = "A robust backpack issued to Nanotrasen's finest."
	icon_state = "blueshieldpack"

/obj/item/storage/backpack/robotics
	name = "robotics backpack"
	desc = "A specially designed backpack. It's fire resistant and smells vaguely of welding fuel."
	icon_state = "robopack"
	inhand_icon_state = "backpack"
	resistance_flags = FIRE_PROOF

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	inhand_icon_state = "satchel"
	resistance_flags = FIRE_PROOF
	var/strap_side_straight = FALSE

/obj/item/storage/backpack/satchel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Shift-Click</b> [src] to flip its strap side.</span>"

/obj/item/storage/backpack/satchel/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	strap_side_straight = !strap_side_straight
	worn_icon_state = "satchel[strap_side_straight ? "-flipped" : ""]"
	if(user.back == src)
		user.update_inv_back()

/obj/item/storage/backpack/satchel/withwallet/populate_contents()
	new /obj/item/storage/wallet/random(src)

/obj/item/storage/backpack/satcheldeluxe
	name = "leather satchel"
	desc = "An NT Deluxe satchel, with the finest quality leather and the company logo in a thin gold stitch."
	icon_state = "nt_deluxe"
	worn_icon_state = "satchel"
	inhand_icon_state = "satchel"

/obj/item/storage/backpack/satchel_lizard
	name = "lizard skin handbag"
	desc = "A handbag made out of what appears to be supple green Unathi skin. A face can be vaguely seen on the front."
	icon_state = "satchel-lizard"

/obj/item/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A deluxe NT Satchel, made of the highest quality leather."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satchel_clown
	name = "Tickles Von Squeakerton"
	desc = "A satchel with extra pockets for all your banana storing needs!"
	icon_state = "satchel-clown"

/obj/item/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_atmos
	name = "atmospherics satchel"
	desc = "A fireproof satchel for keeping gear safe."
	icon_state = "satchel-atmos"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_explorer
	name = "explorer satchel"
	desc = "A robust satchel for stashing your loot."
	icon_state = "satchel-explorer"

/obj/item/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"
	worn_icon_state = null
	inhand_icon_state = null

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
	resistance_flags = FIRE_PROOF

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
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_blueshield
	name = "blueshield satchel"
	desc = "A robust satchel issued to Nanotrasen's finest."
	icon_state = "satchel-blueshield"

/obj/item/storage/backpack/satchel_robo
	name = "bioengineer satchel"
	desc = "A black satchel designed for holding repair equipment."
	icon_state = "satchel-robo"
	inhand_icon_state = "satchel-norm"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel_flat
	name = "smuggler's satchel"
	desc = "A very slim satchel that can easily fit into tight spaces."
	icon_state = "satchel-flat"
	w_class = WEIGHT_CLASS_NORMAL //Can fit in backpacks itself.
	max_combined_w_class = 15
	level = 1
	cant_hold = list(/obj/item/storage/backpack/satchel_flat) //muh recursive backpacks

/obj/item/storage/backpack/satchel_flat/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_MAXIMUM
		anchored = TRUE //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
	else
		invisibility = initial(invisibility)
		anchored = FALSE
		icon_state = initial(icon_state)

/obj/item/storage/backpack/satchel_flat/populate_contents()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/crowbar(src)

/*
 * Duffelbags
 */

/obj/item/storage/backpack/duffel
	name = "duffelbag"
	desc = "A large grey duffelbag designed to hold more items than a regular bag. It slows you down when unzipped."
	icon_state = "duffel"
	max_combined_w_class = 30
	/// Is the bag zipped up?
	var/zipped = TRUE
	/// How long it takes to toggle the zip state of this bag
	var/zip_time = 0.7 SECONDS
	/// This variable is used to change the icon state to the variable when opened
	var/open_icon_sprite
	/// Do we want the bag to be antidropped when zipped up?
	var/antidrop_on_zip = FALSE

/obj/item/storage/backpack/duffel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is currently [zipped ? "zipped" : "unzipped"]. Alt+Shift+Click to [zipped ? "un-" : ""]zip it!</span>"

/obj/item/storage/backpack/duffel/AltShiftClick(mob/user)
	. = ..()
	handle_zipping(user)

/obj/item/storage/backpack/duffel/proc/handle_zipping(mob/user)
	if(!Adjacent(user))
		return

	if(!zip_time || do_after(user, zip_time, target = src))
		playsound(src, 'sound/items/zip.ogg', 75, TRUE)
		zipped = !zipped

		if(!zipped) // Handle slowdown and stuff now that we just zipped it
			show_to(user)

			if(zip_time)
				slowdown = 1
			if(antidrop_on_zip)
				set_nodrop(NODROP_TOGGLE, user)
			update_icon(UPDATE_ICON_STATE)
			return

		slowdown = 0
		hide_from_all()
		for(var/obj/item/storage/container in src)
			container.hide_from_all() // Hide everything inside the bag too
		if(antidrop_on_zip)
			set_nodrop(TRUE, user)
		update_icon(UPDATE_ICON_STATE)

/obj/item/storage/backpack/duffel/update_icon_state()
	. = ..()
	if(!zipped)
		if(open_icon_sprite)
			icon_state = open_icon_sprite
	else
		if(open_icon_sprite)
			icon_state = initial(icon_state)

// The following three procs handle refusing access to contents if the duffel is zipped

/obj/item/storage/backpack/duffel/handle_item_insertion(obj/item/I, mob/user, prevent_warning, bypass_zip = FALSE)
	if(bypass_zip)
		return ..()

	if(zipped)
		to_chat(usr, "<span class='notice'>[src] is zipped shut!</span>")
		return FALSE

	return ..()

/obj/item/storage/backpack/duffel/removal_allowed_check(mob/user)
	if(zipped)
		to_chat(user, "<span class='notice'>[src] is zipped shut!</span>")
		return FALSE

	return TRUE

/obj/item/storage/backpack/duffel/drop_inventory(user)
	if(zipped)
		to_chat(usr, "<span class='notice'>[src] is zipped shut!</span>")
		return FALSE

	return ..()

/obj/item/storage/backpack/duffel/show_to(mob/user)
	if(isobserver(user))
		return ..()

	if(zipped)
		to_chat(usr, "<span class='notice'>[src] is zipped shut!</span>")
		return FALSE

	return ..()

/obj/item/storage/backpack/duffel/syndie
	name = "suspicious looking duffelbag"
	desc = "A large duffelbag for holding extra tactical supplies."
	icon_state = "duffel-syndiammo"
	origin_tech = "syndicate=1"
	silent = TRUE
	zip_time = 0
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/syndie/med
	name = "suspicious duffelbag"
	desc = "A black and red duffelbag with a red and white cross sewn onto it."
	icon_state = "duffel-syndimed"

/obj/item/storage/backpack/duffel/syndie/shotgun
	desc = "A large duffelbag, packed to the brim with Bulldog shotgun ammo."

/obj/item/storage/backpack/duffel/syndie/shotgun/populate_contents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/storage/backpack/duffel/syndie/shotgun_xl_mags
	desc = "A large duffelbag, containing three types of extended drum magazines."

/obj/item/storage/backpack/duffel/syndie/shotgun_xl_mags/populate_contents()
	new /obj/item/ammo_box/magazine/m12g/xtr_lrg(src)
	new /obj/item/ammo_box/magazine/m12g/xtr_lrg(src)
	new /obj/item/ammo_box/magazine/m12g/xtr_lrg(src)
	new /obj/item/ammo_box/magazine/m12g/xtr_lrg/buckshot(src)
	new /obj/item/ammo_box/magazine/m12g/xtr_lrg/dragon(src)

/obj/item/storage/backpack/duffel/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."

/obj/item/storage/backpack/duffel/mining_conscript/populate_contents()
	new /obj/item/pickaxe(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/encryptionkey/headset_cargo(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/kitchen/knife/combat/survival(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/suit/hooded/explorer(src)

/obj/item/storage/backpack/duffel/syndie/smg
	desc = "A large duffel bag, packed to the brim with C-20r magazines."

/obj/item/storage/backpack/duffel/syndie/smg/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_box/magazine/smgm45(src)

/obj/item/storage/backpack/duffel/syndie/c20rbundle
	desc = "A large duffel bag containing a C-20r, some magazines, and a cheap looking suppressor."

/obj/item/storage/backpack/duffel/syndie/c20rbundle/populate_contents()
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/gun/projectile/automatic/c20r(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	desc = "A large duffel bag containing a tactical medkit, a medical beam gun and a pair of syndicate magboots."

/obj/item/storage/backpack/duffel/syndie/med/medicalbundle/populate_contents()
	new /obj/item/storage/firstaid/tactical(src)
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/gun/medbeam(src)

/obj/item/storage/backpack/duffel/syndie/c4/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/backpack/duffel/syndie/x4/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/plastic/c4/x4(src)

/obj/item/storage/backpack/duffel/syndie/med/surgery
	name = "surgery duffelbag"
	desc = "A suspicious looking duffelbag for holding surgery tools."

/obj/item/storage/backpack/duffel/syndie/med/surgery/populate_contents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/fix_o_vein(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/hydrocodone(src)

/// for maint spawns
/obj/item/storage/backpack/duffel/syndie/med/surgery_fake
	name = "surgery duffelbag"
	desc = "A suspicious looking duffelbag for holding surgery tools."

/obj/item/storage/backpack/duffel/syndie/med/surgery_fake/populate_contents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/cautery(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/fix_o_vein(src)
	if(prob(50))
		new /obj/item/circular_saw(src)
		new /obj/item/surgicaldrill(src)

/obj/item/storage/backpack/duffel/syndie/party
	desc = "A large duffel bag, packed to the brim with hilarious equipment."

/obj/item/storage/backpack/duffel/syndie/party/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_box/magazine/m12g/confetti(src)
	for(var/i in 1 to 5)
		new /obj/item/grenade/confetti(src)
	new /obj/item/gun/projectile/revolver/capgun(src)

#define NANNY_MAX_VALUE 7
#define NANNY_MIN_VALUE 6

/obj/item/storage/backpack/duffel/magic_nanny_bag
	name = "magic nanny bag"
	desc = "Not to be confused with a magic granny bag. Zip it up to make it unable to be dropped while closed."
	icon_state = "magic_nanny_bag"
	worn_icon_state = "magic_nanny_bag"
	inhand_icon_state = "magic_nanny_bag"
	max_w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	storage_slots = 98 //Most that fits on your screen. Good luck getting that much in there.
	max_combined_w_class = 256 //get your 8 bit magic bags here. Also it's wizard, at some point this many items will just make it crowded.
	silent = TRUE
	zip_time = 0
	resistance_flags = FIRE_PROOF
	open_icon_sprite = "magic_nanny_bag_open"
	antidrop_on_zip = TRUE

/obj/item/storage/backpack/duffel/magic_nanny_bag/populate_contents(attempts = 0)
	var/value = 0
	//Melee Weapon
	switch(rand(1, 8))
		if(1)
			new /obj/item/melee/spellblade(src)
			value += 2
		if(2)
			new /obj/item/organ/internal/cyberimp/arm/katana(src)
			value += 1
		if(3)
			new /obj/item/mjollnir(src)
			value += 2
		if(4)
			new /obj/item/singularityhammer(src)
			value += 2
		if(5)
			new /obj/item/katana(src)
			value += 2 //force 40 this is value 2
		if(6)
			new /obj/item/claymore(src)
			value += 2 //force 40 this is value 2
		if(7)
			new /obj/item/spear/grey_tide(src)
			value += 2 //Value 2, clones are strong
		if(8)
			if(prob(50))
				new /obj/item/sord(src)
				value -= 1 //Useless joke, might as well give them a value point back.
			else
				new /obj/item/bostaff(src) //Funky item, not really worth a point, but good to balance sord's free point out
	//Wands
	var/wands = 0
	while(wands < 2)
		var/obj/item/pickedw = pick(
			/obj/item/gun/magic/wand/death,
			/obj/item/gun/magic/wand/resurrection,
			/obj/item/gun/magic/wand/polymorph,
			/obj/item/gun/magic/wand/teleport,
			/obj/item/gun/magic/wand/door,
			/obj/item/gun/magic/wand/fireball,
			/obj/item/gun/magic/wand/slipping)
		new pickedw(src)
		wands++

	for(var/obj/item/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

	//Staff
	var/list/list_s = list(
		/obj/item/gun/magic/staff/change = 2,
		/obj/item/gun/magic/staff/slipping = 1,
		/obj/item/gun/magic/staff/door = 1,
		/obj/item/gun/magic/staff/healing = 1,
		/obj/item/gun/magic/staff/chaos = 2,
		/obj/item/gun/magic/staff/animate = 2,
		/obj/item/gun/magic/staff/focus = 2,
		/obj/item/gun/magic/hook = 1,
		/obj/item/hierophant_club = 3, //Strong so super costly
		/obj/item/lava_staff = 2 ) //Hot seller so 2
	var/obj/item/pickeds = pick(list_s)
	value += list_s[pickeds]
	new pickeds(src)

	//Random magical artifact.
	var/list/list_a = list(
		/obj/item/necromantic_stone = 2,
		/obj/item/scrying = 1, //thematic discount
		/obj/item/organ/internal/heart/cursed/wizard = 1,
		/obj/item/organ/internal/vocal_cords/colossus/wizard = 2,
		/obj/item/warp_cube/red = 1,
		/obj/item/reagent_containers/drinks/everfull = 2,
		/obj/item/clothing/suit/space/hardsuit/wizard = 2,
		/obj/item/immortality_talisman = 1, //spells recharge when invincible
		/obj/item/tarot_generator/wizard = 2)
	var/obj/item/pickeda = pick(list_a)
	value += list_a[pickeda]
	new pickeda(src)

	//Summon
	switch(rand(1, 8))
		if(1)
			new /obj/item/antag_spawner/slaughter_demon(src)
			value += 2
		if(2)
			new /obj/item/antag_spawner/morph(src)
			value += 1
		if(3)
			new /obj/item/antag_spawner/slaughter_demon/laughter(src)
			value += 1
		if(4)
			new /obj/item/antag_spawner/slaughter_demon/shadow(src)
			value += 1
		if(5)
			new /obj/item/antag_spawner/revenant(src)
			value += 1
		if(6)
			new /obj/item/contract(src)
			value += 2
		if(7)
			new /obj/item/guardiancreator(src)
			value += 1
		if(8)
			if(prob(25))
				new /obj/item/food/grown/nymph_pod(src)
				new /obj/item/slimepotion/sentience(src)
			else
				new /obj/item/paicard(src) //Still useful, not a point useful.

	//Treat / potion. Free.
	var/obj/item/pickedt = pick(
			/obj/item/storage/box/syndidonkpockets, // Healing + speed
			/obj/item/reagent_containers/drinks/bottle/dragonsbreath, // Killing
			/obj/item/reagent_containers/drinks/bottle/immortality, // Super healing for 20 seconds
			/obj/item/food/meatsteak/stimulating, //Healing + stun immunity
			/obj/item/food/plum_pie ) // Great healing over long period of time
	new pickedt(src)


	if(value > NANNY_MAX_VALUE || value < NANNY_MIN_VALUE)
		if(attempts >= 5)
			message_admins("Failed to generate the wizard a properly priced magic nanny bag!")
		else
			new /obj/item/storage/backpack/duffel/magic_nanny_bag(get_turf(loc), attempts + 1)
		qdel(src)

#undef NANNY_MAX_VALUE
#undef NANNY_MIN_VALUE

/obj/item/reagent_containers/drinks/bottle/dragonsbreath
	name = "flask of dragons breath"
	desc = "Not recommended for wizardly consumption. Recommended for mundane consumption!"
	icon_state = "holyflask"
	color = "#DC0000"
	list_reagents = list("dragonsbreath" = 80, "hell_water" = 20)

/obj/item/reagent_containers/drinks/bottle/immortality
	name = "drop of immortality"
	desc = "Drinking this will make you immortal. For a moment or two, at least."
	icon_state = "holyflask"
	color = "#437fb8"
	volume = 5
	list_reagents = list("adminordrazine" = 5)

/obj/item/food/meatsteak/stimulating
	name = "stimulating steak"
	desc = "Stimulate your senses."
	list_reagents = list("nutriment" = 5, "stimulants" = 25)
	bitesize = 100
	goal_difficulty = FOOD_GOAL_SKIP

/obj/item/food/plum_pie
	name = "perfect plum pie"
	desc = "The Jack Horner brand of pie. 2 big thumbs up."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	bitesize = 10
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "syndicate_nanites" = 45)
	tastes = list("pie" = 1, "plum" = 1)

/obj/item/storage/backpack/duffel/captain
	name = "captain's duffelbag"
	desc = "A duffelbag designed to hold large quantities of condoms."
	icon_state = "duffel-captain"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/security
	name = "security duffelbag"
	desc = "A duffelbag built with robust fabric!"
	icon_state = "duffel-security"

/obj/item/storage/backpack/duffel/virology
	name = "virology duffelbag"
	desc = "A white duffelbag designed to contain biohazards."
	icon_state = "duffel-viro"

/obj/item/storage/backpack/duffel/science
	name = "scientist duffelbag"
	desc = "A duffelbag designed to hold the secrets of space."
	icon_state = "duffel-toxins"

/obj/item/storage/backpack/duffel/genetics
	name = "geneticist duffelbag"
	desc = "A duffelbag designed to hold gibbering monkies."
	icon_state = "duffel-gene"

/obj/item/storage/backpack/duffel/chemistry
	name = "chemist duffelbag"
	desc = "A duffelbag designed to hold corrosive substances."
	icon_state = "duffel-chemistry"

/obj/item/storage/backpack/duffel/medical
	name = "medical duffelbag"
	desc = "A duffelbag designed to hold medicine."
	icon_state = "duffel-med"

/obj/item/storage/backpack/duffel/engineering
	name = "industrial duffelbag"
	desc = "A duffelbag designed to hold tools."
	icon_state = "duffel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/atmos
	name = "atmospherics duffelbag"
	desc = "A duffelbag designed to hold tools. This one is specially designed for atmospherics."
	icon_state = "duffel-atmos"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffel/hydro
	name = "hydroponics duffelbag"
	desc = "A duffelbag designed to hold seeds and fauna."
	icon_state = "duffel-hydro"

/obj/item/storage/backpack/duffel/clown
	name = "smiles von wiggleton"
	desc = "A duffelbag designed to hold bananas and bike horns."
	icon_state = "duffel-clown"

/obj/item/storage/backpack/duffel/blueshield
	name = "blueshield duffelbag"
	desc = "A robust duffelbag issued to Nanotrasen's finest."
	icon_state = "duffel-blueshield"

/obj/item/storage/backpack/duffel/robotics
	name = "roboticist duffelbag"
	desc = "A duffelbag designed to hold tools."
	icon_state = "duffel-robo"
	inhand_icon_state = "duffel"

//ERT backpacks.
/obj/item/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Nanotrasen Emergency Response Team."
	icon_state = "ert_commander"
	inhand_icon_state = "backpack"
	max_combined_w_class = 30
	resistance_flags = FIRE_PROOF

//Commander
/obj/item/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious blue-striped combat backpack with plenty of easily-accessible pockets."

//Security
/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious red-striped combat backpack with plenty of easily-accessible pockets."
	icon_state = "ert_security"

//Engineering
/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious orange-striped combat backpack with plenty of easily-accessible pockets."
	icon_state = "ert_engineering"

//Medical
/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious white-striped combat backpack with plenty of easily-accessible pockets."
	icon_state = "ert_medical"

//Janitorial
/obj/item/storage/backpack/ert/janitor
	name = "emergency response team janitor backpack"
	desc = "A spacious purple-striped combat backpack with plenty of easily-accessible pockets."
	icon_state = "ert_janitor"

//Solgov
/obj/item/storage/backpack/ert/solgov
	name = "\improper TSF marine rucksack"
	desc = "A spacious rucksack covered in pouches and pockets, worn by marines of the Trans-Solar Federation."
	icon_state = "ert_solgov"

/obj/item/storage/backpack/ert/deathsquad
	name = "Deathsquad backpack"
	desc = "A spacious red & black combat rucksack made of lightweight nanomesh. Likely the most intimidating backpack one will ever see."
	icon_state = "ert_security"
	inhand_icon_state = null
