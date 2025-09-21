/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Matchbox
 *		Cigarette Box
 *		Cigar Box
 *		Vial Box
 *		Aquatic Starter Kit
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	resistance_flags = FLAMMABLE
	var/icon_type

/obj/item/storage/fancy/update_icon_state()
	icon_state = "[icon_type]box[length(contents)]"

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	. += fancy_storage_examine(user)

/obj/item/storage/fancy/proc/fancy_storage_examine(mob/user)
	. = list()
	if(in_range(user, src))
		var/len = LAZYLEN(contents)
		if(len <= 0)
			. += "There are no [icon_type]s left in the box."
		else if(len == 1)
			. += "There is one [icon_type] left in the box."
		else
			. += "There are [length(contents)] [icon_type]s in the box."

/obj/item/storage/fancy/remove_from_storage(obj/item/I, atom/new_location)
	if(!istype(I))
		return FALSE

	update_icon()
	return ..()

// MARK: Donut Box
/obj/item/storage/fancy/donut_box
	name = "donut box"
	desc = "\"To do, or do nut, the choice is obvious.\""
	icon_type = "donut"
	icon_state = "donutbox"
	storage_slots = 6
	can_hold = list(/obj/item/food/donut)
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1

/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/food/donut/donut = contents[I]
		var/icon/new_donut_icon = icon('icons/obj/food/containers.dmi', "[(I - 1)]donut[donut.donut_sprite_type]")
		. += new_donut_icon

/obj/item/storage/fancy/donut_box/update_icon_state()
	return

/obj/item/storage/fancy/donut_box/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/food/donut(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/fancy/donut_box/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
	return

/obj/item/storage/fancy/donut_box/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user) && !length(contents))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

// MARK: Egg Box


/obj/item/storage/fancy/egg_box
	name = "egg box"
	icon_state = "eggbox"
	icon_type = "egg"
	inhand_icon_state = "eggbox"
	storage_slots = 12
	can_hold = list(/obj/item/food/egg)

/obj/item/storage/fancy/egg_box/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/food/egg(src)

// MARK: Candle Box
/obj/item/storage/fancy/candle_box
	name = "Candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox0"
	icon_type = "candle"
	inhand_icon_state = "syringe_kit"
	storage_slots = 5
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/fancy/candle_box/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/storage/fancy/candle_box/full/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/candle(src)

/obj/item/storage/fancy/candle_box/eternal
	name = "Eternal Candle pack"
	desc = "A pack of red candles made with a special wax."

/obj/item/storage/fancy/candle_box/eternal/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/candle/eternal(src)


// MARK: Crayon Box
/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL
	storage_slots = 8
	icon_type = "crayon"
	can_hold = list(
		/obj/item/toy/crayon
	)

/obj/item/storage/fancy/crayons/populate_contents()
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_icon()

/obj/item/storage/fancy/crayons/update_overlays()
	. = ..()
	. += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		. += image('icons/obj/crayons.dmi', crayon.dye_color)

/obj/item/storage/fancy/crayons/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		switch(C.dye_color)
			if("mime")
				to_chat(usr, "This crayon is too sad to be contained in this box.")
				return
			if("rainbow")
				to_chat(usr, "This crayon is too powerful to be contained in this box.")
				return
	..()

// MARK: MatchBox
/obj/item/storage/fancy/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	inhand_icon_state = "matchbox"
	base_icon_state = "matchbox"
	storage_slots = 10
	w_class = WEIGHT_CLASS_TINY
	max_w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound =  'sound/items/handling/matchbox_pickup.ogg'
	can_hold = list(/obj/item/match)

/obj/item/storage/fancy/matches/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/match(src)

/obj/item/storage/fancy/matches/attackby__legacy__attackchain(obj/item/match/W, mob/user, params)
	if(istype(W, /obj/item/match) && (!W.lit && !W.burnt))
		W.matchignite()
		playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, TRUE)
	return

/obj/item/storage/fancy/matches/update_icon_state()
	. = ..()
	switch(length(contents))
		if(10)
			icon_state = base_icon_state
		if(5 to 9)
			icon_state = "[base_icon_state]_almostfull"
		if(1 to 4)
			icon_state = "[base_icon_state]_almostempty"
		if(0)
			icon_state = "[base_icon_state]_e"

//	MARK: Cigarette Pack
/obj/item/storage/fancy/cigarettes
	name = "generic cigarette packet"
	desc = "An abstract brand of cigarette that should not exist. Make a GitHub report if you see this."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "robust_packet"
	inhand_icon_state = "robust_packet"
	belt_icon = "patch_pack"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	storage_slots = 6
	max_combined_w_class = 6
	can_hold = list(/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match)
	cant_hold = list(/obj/item/clothing/mask/cigarette/cigar,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/lighter/zippo)
	icon_type = "cigarette"
	var/cigarette_slogan = "The preferred brand of coders and developers."
	var/cigarette_type = /obj/item/clothing/mask/cigarette

/obj/item/storage/fancy/cigarettes/examine(mob/user)
	. = ..()
	if(cigarette_slogan)
		. += "<span class='notice'>\"[cigarette_slogan]\"</span>"

/obj/item/storage/fancy/cigarettes/populate_contents()
	for(var/I in 1 to storage_slots)
		new cigarette_type(src)

/obj/item/storage/fancy/cigarettes/update_icon_state()
	icon_state = "[initial(icon_state)]_[length(contents)]"

/obj/item/storage/fancy/cigarettes/attack__legacy__attackchain(mob/living/carbon/M, mob/living/user)
	if(!ismob(M))
		return

	if(istype(M) && user.zone_selected == "mouth" && length(contents) > 0 && !M.wear_mask)
		var/got_cig = FALSE
		for(var/num in 1 to length(contents))
			var/obj/item/I = contents[num]
			if(istype(I, /obj/item/clothing/mask/cigarette))
				var/obj/item/clothing/mask/cigarette/C = I
				M.equip_to_slot_if_possible(C, ITEM_SLOT_MASK)
				if(M != user)
					user.visible_message(
						"<span class='notice'>[user] takes \a [C.name] out of [src] and gives it to [M].</span>",
						"<span class='notice'>You take \a [C.name] out of [src] and give it to [M].</span>"
					)
				else
					to_chat(user, "<span class='notice'>You take \a [C.name] out of the pack.</span>")
				update_icon()
				got_cig = TRUE
				break
		if(!got_cig)
			to_chat(user, "<span class='warning'>There are no smokables in the pack!</span>")
	else
		..()

/obj/item/storage/fancy/cigarettes/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(istype(W, /obj/item/match))
		var/obj/item/match/M = W
		if(M.lit)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>Putting a lit [W] in [src] probably isn't a good idea.</span>")
			return FALSE
	if(istype(W, /obj/item/lighter))
		var/obj/item/lighter/L = W
		if(L.lit)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>Putting [W] in [src] while lit probably isn't a good idea.</span>")
			return FALSE
	//if we get this far, handle the insertion checks as normal
	. = ..()

/obj/item/storage/fancy/cigarettes/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user) && !length(contents))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Smoked mainly by spacers. The somewhat fishy notes are an acquired taste. \
	Has a light, low-tar smoke specifically designed to reduce stress on scrubber systems."
	icon_state = "carp_packet"
	inhand_icon_state = "carp_packet"
	cigarette_slogan = "Carp smokers would rather bite you than switch, since 2313."

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "An infamous brand, DromedaryCo cigarettes are unfiltered, tarry, and have a very harsh flavour. \
	Not for beginner smokers. Enjoyed mainly by gruff types with equally gruff voices."
	icon_state = "D_packet"
	inhand_icon_state = "D_packet"
	cigarette_slogan = "Wouldn't a slow death make a change?"

/obj/item/storage/fancy/cigarettes/cigpack_random
	name ="\improper Embellished Enigma packet"
	desc = "True to the name, Enigmas are impossible to pin down. \
	No two cigarettes are alike as each one is infused with unique flavours and substances, so every time is just like your first time."
	icon_state = "enigma_packet"
	inhand_icon_state = "enigma_packet"
	cigarette_slogan = "For the true connoisseur of exotic flavors."
	cigarette_type = /obj/item/clothing/mask/cigarette/random

/obj/item/storage/fancy/cigarettes/cigpack_random/examine(mob/user)
	. = ..()
	. += "<span class = 'warning'>Warning: Not all substances used have undergone regulatory testing, smoke at your own risk. \
	The Embellished Enigma Tobacco Company does not accept liability for proper or negligent use of its products. Consult your doctor before use.</span>"

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "Whilst you cannot decipher what the strange runes on the packet say, it bears the unmistakable scent of cannabis."
	icon_state = "midori_packet"
	inhand_icon_state = "midori_packet"
	cigarette_slogan = ""
	cigarette_type = /obj/item/clothing/mask/cigarette/rollie

/obj/item/storage/fancy/cigarettes/cigpack_our_brand
	name = "\improper Our Brand packet" // This brand name is an obscure reference to The Master and Margarita by Ivan Bezdomny.
	desc = "The one, official brand of cigarette manufactured by the Vostran Iron Republic - one of the main constitient nations of the USSP. \
	Exported across the known Orion Spur by members of the USSP's trading bloc and vendors affiliated with the Nian Merchant Guild. \
	The flavour is acrid, the smoke is thin and wispy, yet harsh on the throat. The only redeeming features are the high nicotine content and the low price."
	icon_state = "our_brand_packet"
	cigarette_slogan = "Smoke, for the Union!"

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Nanotrasen's in-house brand of cigarettes. Cheap quality, wispy smoke, has a somewhat harsh flavour."
	cigarette_slogan = "Smoked by the robust."

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Nanotrasen's premium cigarette offering. Has a smooth, drawn-out flavour and a dense smoke. Contains real gold."
	icon_state = "robust_g_packet"
	inhand_icon_state = "robust_g_packet"
	cigarette_slogan = "Smoked by the <b>truly</b> robust."
	cigarette_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_candy
	name = "\improper Robust Junior packet"
	desc = "A packet of nicotine-free* candy cigarettes, manufactured by Robust Tobacco."
	cigarette_slogan = "Unsure about smoking? Want to bring your children safely into the family tradition? Look no more with this special packet! Includes 100% nicotine-free* candy cigarettes."
	cigarette_type = /obj/item/clothing/mask/cigarette/candy

/obj/item/storage/fancy/cigarettes/cigpack_candy/examine(mob/user)
	. = ..()
	. += "<span class = 'warning'>*Warning: Do not expose to high temperatures or naked flames, contains additives that will form nicotine at high temperatures.</span>"

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name ="\improper Shady Jim's Super Slims packet"
	desc = "Despite the doubious appearance, these cigarettes do exactly what they say on the box. The smoke tastes like cheap berry juice and battery acid, with a bitter chemical aftertaste."
	icon_state = "shady_jim_packet"
	inhand_icon_state = "shady_jim_packet"
	cigarette_slogan = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? \
	Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	cigarette_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_solar_rays
	name = "\improper Solar Rays packet"
	desc = "A popular brand within the Trans-Solar Federation, they have a smooth, slightly cinnamon flavour. \
	Whilst not actually state-owned, these cigarettes lean heavily into patriotic marketing, and are included in federal ration packs as a morale booster."
	icon_state = "solar_packet"
	cigarette_slogan = "Smoked by true patriots."

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "One of the most popular brands in the Orion Sector, flavoured with menthol to give a smooth cooling sensation with every puff."
	icon_state = "uplift_packet"
	inhand_icon_state = "uplift_packet"
	cigarette_slogan = "Sit back and relax with the soft cooling embrace that only an Uplift can provide."
	cigarette_type = /obj/item/clothing/mask/cigarette/menthol

/obj/item/storage/fancy/cigarettes/cigpack_med
	name = "medical marijuana packet"
	desc = "A prescription packet containing six fully legal medical marijuana cigarettes. \
	Made using a strain of cannabis engineered to maximise CBD content and eliminate THC, much to the chagrin of stoners everywhere."
	icon_state = "med_packet"
	inhand_icon_state = "med_packet"
	cigarette_slogan = "All the medical benefits, with none of the high!"
	cigarette_type = /obj/item/clothing/mask/cigarette/medical_marijuana

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "suspicious cigarette packet"
	desc = "An obscure brand of evil-looking cigarettes. Smells like Donk pockets."
	icon_state = "syndie_packet"
	inhand_icon_state = "syndie_packet"
	cigarette_slogan = "Strong flavour, dense smoke, infused with omnizine."
	cigarette_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_carcinoma
	name = "\improper Carcinoma Angel packet"
	desc = "True to their name, Carcinoma Angels will bring your breathless body to heaven. \
	This is an attempt to create the most cancerous cigarettes in the universe, for specific connoisseurs. \
	These cigarettes have been banned across most of known space due to their reckless marketing strategy and obvious health risks."
	icon_state = "death_packet"
	inhand_icon_state = "enigma_packet"
	cigarette_slogan = "That which does not kill us makes us stronger."
	cigarette_type = /obj/item/clothing/mask/cigarette/carcinoma

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	inhand_icon_state = "cig_paper_pack"
	w_class = WEIGHT_CLASS_TINY
	storage_slots = 10
	icon_type = "rolling paper"
	can_hold = list(/obj/item/rollingpaper)

/obj/item/storage/fancy/rollingpapers/update_icon_state()
	return

/obj/item/storage/fancy/rollingpapers/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/rollingpaper(src)

/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!length(contents))
		. += "[icon_state]_empty"

// MARK: Cigar Box
/obj/item/storage/fancy/cigars
	name = "plastic cigar box"
	desc = "A cheap plastic box for holding cheap cigars. Only Nanotrasen would think something like this is a good idea."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigar_box"
	storage_slots = 6
	max_combined_w_class = 6
	can_hold = list(/obj/item/clothing/mask/cigarette/cigar)
	icon_type = "cigar"
	var/cigar_type = /obj/item/clothing/mask/cigarette/cigar

/obj/item/storage/fancy/cigars/populate_contents()
	for(var/I in 1 to storage_slots)
		new cigar_type(src)

/obj/item/storage/fancy/cigars/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/clothing/mask/cigarette/cigar/cigar = contents[I]
		var/icon/new_cigar_icon = icon('icons/obj/cigarettes.dmi', "[initial(cigar.icon_state)]_[I]")
		. += new_cigar_icon
	
/obj/item/storage/fancy/cigars/update_icon_state()
	icon_state = "[initial(icon_state)]_open"

/obj/item/storage/fancy/cigars/cohiba
	name = "wooden cigar box"
	icon_state = "wood_cigar_box"
	desc = "An ornate wooden box with decorative brass inlays. Perfect for storing a collection of fine cigars."
	cigar_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/storage/fancy/havana_cigar
	name = "\improper Cuban cigar box"
	desc = "A small, ornate wooden box with decorative brass inlays. It has space for a single cigar inside. The bottom portion of the box has a silk-covered for holding the cigar. \
	Underneath the insert is a folded paper with embossed gold lettering explaining the long and illustrious history of Cuban cigars."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cuban_cigar_box"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/clothing/mask/cigarette/cigar/havana) // It's so powerful it refuses anything else.
	icon_type = "cigar"
	storage_slots = 1
	var/cigar_type = /obj/item/clothing/mask/cigarette/cigar/havana

/obj/item/storage/fancy/havana_cigar/update_icon_state()
	icon_state = "[initial(icon_state)]_open"

/obj/item/storage/fancy/havana_cigar/populate_contents()
	new cigar_type(src)

/obj/item/storage/fancy/havana_cigar/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/clothing/mask/cigarette/cigar/cigar = contents[I]
		var/icon/new_cigar_icon = icon('icons/obj/cigarettes.dmi', "h_[initial(cigar.icon_state)]")
		. += new_cigar_icon
	
// MARK: Vial Box
/obj/item/storage/fancy/vials
	name = "vial storage box"
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox6"
	inhand_icon_state = "syringe_kit"
	icon_type = "vial"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)

/obj/item/storage/fancy/vials/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/reagent_containers/glass/beaker/vial(src)
	return

/obj/item/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	can_hold = list(/obj/item/reagent_containers/glass/bottle)
	storage_slots = 6
	req_access = list(ACCESS_VIROLOGY)

/obj/item/storage/lockbox/vials/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/lockbox/vials/update_icon_state()
	icon_state = "vialbox[length(contents)]"
	cut_overlays()

/obj/item/storage/lockbox/vials/update_overlays()
	. = ..()
	if(!broken)
		. += "led[locked]"
		if(locked)
			. += "cover"
	else
		. += "ledb"

/obj/item/storage/lockbox/vials/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	..()
	update_icon()

/obj/item/storage/lockbox/vials/zombie_cure
	name = "secure vial storage box - 'Anti-Plague Sequences'"

/obj/item/storage/lockbox/vials/zombie_cure/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/zombiecure1(src)
	new /obj/item/reagent_containers/glass/bottle/zombiecure2(src)
	new /obj/item/reagent_containers/glass/bottle/zombiecure3(src)
	new /obj/item/reagent_containers/glass/bottle/zombiecure4(src)

// MARK: Aquatic Starter Kit
/obj/item/storage/firstaid/aquatic_kit
	name = "aquatic starter kit"
	desc = "It's a starter kit box for an aquarium."
	icon_state = "AquaticKit"
	med_bot_skin = "fish"

/obj/item/storage/firstaid/aquatic_kit/full
	desc = "It's a starter kit for an aquarium; includes 1 tank brush, 1 egg scoop, 1 fish net, 1 container of fish food and 1 fish bag."

/obj/item/storage/firstaid/aquatic_kit/full/populate_contents()
	new /obj/item/egg_scoop(src)
	new /obj/item/fish_net(src)
	new /obj/item/tank_brush(src)
	new /obj/item/fishfood(src)
	new /obj/item/storage/bag/fish(src)
