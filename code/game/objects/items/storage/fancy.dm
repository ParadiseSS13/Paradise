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
 *		Juice Box Box
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

/obj/item/storage/fancy/crayons/marine
	name = "box of TSF Standard Issue crayons"
	desc = "A box of a SolGov Marine's favorite mid-operational snack."

/obj/item/storage/fancy/crayons/marine/populate_contents()
	new /obj/item/toy/crayon/white/marine(src)
	new /obj/item/toy/crayon/red/marine(src)
	new /obj/item/toy/crayon/orange/marine(src)
	new /obj/item/toy/crayon/yellow/marine(src)
	new /obj/item/toy/crayon/green/marine(src)
	new /obj/item/toy/crayon/blue/marine(src)
	new /obj/item/toy/crayon/purple/marine(src)
	new /obj/item/toy/crayon/black/marine(src)
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
	desc = ABSTRACT_TYPE_DESC
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
		. += SPAN_NOTICE("\"[cigarette_slogan]\"")

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
						SPAN_NOTICE("[user] takes \a [C.name] out of [src] and gives it to [M]."),
						SPAN_NOTICE("You take \a [C.name] out of [src] and give it to [M].")
					)
				else
					to_chat(user, SPAN_NOTICE("You take \a [C.name] out of the pack."))
				update_icon()
				got_cig = TRUE
				break
		if(!got_cig)
			to_chat(user, SPAN_WARNING("There are no smokables in the pack!"))
	else
		..()

/obj/item/storage/fancy/cigarettes/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(istype(W, /obj/item/match))
		var/obj/item/match/M = W
		if(M.lit)
			if(!stop_messages)
				to_chat(usr, SPAN_NOTICE("Putting a lit [W] in [src] probably isn't a good idea."))
			return FALSE
	if(istype(W, /obj/item/lighter))
		var/obj/item/lighter/L = W
		if(L.lit)
			if(!stop_messages)
				to_chat(usr, SPAN_NOTICE("Putting [W] in [src] while lit probably isn't a good idea."))
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

/obj/item/storage/fancy/juice_boxes
	name = "Stationside Juice Box Variety Pack"
	desc = "Every flavor of juice boxes, right at your fingertips."
	storage_slots = 12
	// Fancier storage slots for that haphazardly-picked-over look
	var/list/storage_slot_list[12]
	icon = 'icons/obj/juice_box.dmi'
	icon_state = "juice_box_box"
	icon_type = "juice carton"
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	can_hold = list(/obj/item/reagent_containers/drinks/carton)

/obj/item/storage/fancy/juice_boxes/update_icon_state()
	return

/obj/item/storage/fancy/juice_boxes/update_overlays()
	. = ..()
	. += image('icons/obj/juice_box.dmi', "juice_box_box")
	for(var/index in 1 to length(storage_slot_list))
		var/obj/item/reagent_containers/drinks/carton/juice_type = storage_slot_list[index]
		if(!istype(juice_type))
			continue
		if(!(juice_type.icon_state))
			continue
		var/image/box_icon = image(icon, src, "[copytext(juice_type.icon_state, 1, -3)]slot")
		box_icon.pixel_x = 3 * ((index - 1) % 6)
		box_icon.pixel_y = -4 * (index > 6)
		. += box_icon
	. += image(icon, src, "juice_box_box_front")

/obj/item/storage/fancy/juice_boxes/remove_from_storage(obj/item/I, atom/new_location)
	. = ..()
	if(. && storage_slot_list.Find(I))
		storage_slot_list[storage_slot_list.Find(I)] = null
		update_icon()

/obj/item/storage/fancy/juice_boxes/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(length(can_hold))
		if(!is_type_in_typecache(I, can_hold))
			return ..()
	if(isrobot(user))
		return // Robots can't interact with storage items.

	handle_item_insertion(I, user, params)
	return TRUE

/obj/item/storage/fancy/juice_boxes/handle_item_insertion(obj/item/juice_box, mob/user, params, prevent_warning = FALSE)
	. = ..()
	if(!.)
		return
	if(!(juice_box in contents))
		return

	var/list/paramlist = params2list(params)
	// If we don't have info about where the user clicked, put the item at the end of the list.
	if(!paramlist.Find("icon-x") || !paramlist.Find("icon-y") || !paramlist.Find("screen-loc"))
		insert_into_end(juice_box)
		return

	var/src_screenxy = get_obj_screen_xy(src, user.client)
	var/clicked_screenxy = splittext(paramlist["screen-loc"], ",")
	// If the user clicked inside the boxes interface instead of on the icon, put the item at the end of the list.
	if(src_screenxy["x"] != text2num(splittext(clicked_screenxy[1], ":")[1]) || \
		src_screenxy["y"] != text2num(splittext(clicked_screenxy[2], ":")[1]))
		insert_into_end(juice_box)
		return

	// The user clicked our very fancy icon, so figure out where the nearest slot is and put the juice box there.
	var/storage_slot = ceil(clamp(1, (text2num(paramlist["icon-x"]) - 7), 15) / 3)
	storage_slot += 6 * (text2num(paramlist["icon-y"]) < 20)
	insert_into_nearest(juice_box, user, storage_slot)

/// Pick the nearest empty slot in this juice box box to slot the juice box into.
/obj/item/storage/fancy/juice_boxes/proc/insert_into_nearest(obj/item/juice_box, mob/user, storage_slot)
	var/distance = 0
	var/second_row_slot = storage_slot > 6 ? storage_slot - 6 : storage_slot + 6
	while(distance < storage_slots / 2)
		if(storage_slot - distance > 0 && !storage_slot_list[storage_slot - distance])
			storage_slot_list[storage_slot - distance] = juice_box
			break
		if(storage_slot + distance <= storage_slots && !storage_slot_list[storage_slot + distance])
			storage_slot_list[storage_slot + distance] = juice_box
			break
		if(second_row_slot - distance > 0 && !storage_slot_list[second_row_slot - distance])
			storage_slot_list[second_row_slot - distance] = juice_box
			break
		if(second_row_slot + distance <= storage_slots && !storage_slot_list[second_row_slot + distance])
			storage_slot_list[second_row_slot + distance] = juice_box
			break
		distance++

	// If it somehow doesn't fit in a storage slot, it shouldn't be in the contents either.
	if(!(juice_box in storage_slot_list))
		to_chat(user, SPAN_WARNING("Somehow, [juice_box] doesn't seem to fit."))
		remove_from_storage(juice_box, get_turf(src))

	// Nudge the standard contents around so they're in the right order.
	var/contents_copy = contents.Copy()
	for(var/index = 1 to storage_slots)
		if(!storage_slot_list[index])
			continue
		contents_copy -= storage_slot_list[index]
		contents_copy += storage_slot_list[index]
	contents = contents_copy

	// Re-show any mobs viewing the contents the juice boxes in the proper order.
	for(var/each_mob in mobs_viewing)
		show_to(each_mob)

	update_icon()

/// Put the juice box into the last slot on the list, and nudge other juice boxes out of the way if necessary.
/obj/item/storage/fancy/juice_boxes/proc/insert_into_end(obj/item/juice_box)
	var/list/items_to_nudge = list()
	// Find an empty slot
	for(var/storage_slot = storage_slots; storage_slot > 0; storage_slot--)
		if(!storage_slot_list[storage_slot])
			break
		items_to_nudge.Add(storage_slot_list[storage_slot])

	// If the empty slot was not at the end, move each juice box found back one slot until the last slot is empty
	while(length(items_to_nudge))
		storage_slot_list[storage_slots - length(items_to_nudge)] = items_to_nudge[length(items_to_nudge)]
		items_to_nudge.Remove(items_to_nudge[length(items_to_nudge)])

	storage_slot_list[storage_slots] = juice_box
	update_icon()

/obj/item/storage/fancy/juice_boxes/random

/obj/item/storage/fancy/juice_boxes/random/populate_contents()
	var/index = 1
	for(var/juice_type in typesof(/obj/item/reagent_containers/drinks/carton) - /obj/item/reagent_containers/drinks/carton)
		if(prob(35))
			storage_slot_list[index] = new juice_type(src)
		index++
	update_icon()

/obj/item/storage/fancy/juice_boxes/full

/obj/item/storage/fancy/juice_boxes/full/populate_contents()
	new /obj/item/reagent_containers/drinks/carton/apple(src)
	new /obj/item/reagent_containers/drinks/carton/banana(src)
	new /obj/item/reagent_containers/drinks/carton/berry(src)
	new /obj/item/reagent_containers/drinks/carton/carrot(src)
	new /obj/item/reagent_containers/drinks/carton/grape(src)
	new /obj/item/reagent_containers/drinks/carton/lemonade(src)
	new /obj/item/reagent_containers/drinks/carton/orange(src)
	new /obj/item/reagent_containers/drinks/carton/pineapple(src)
	new /obj/item/reagent_containers/drinks/carton/plum(src)
	new /obj/item/reagent_containers/drinks/carton/tomato(src)
	new /obj/item/reagent_containers/drinks/carton/vegetable(src)
	new /obj/item/reagent_containers/drinks/carton/watermelon(src)
	storage_slot_list = contents.Copy()
	update_icon()
