/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/cardboardbox_pickup.ogg'
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1

/obj/item/storage/box/large
	name = "large box"
	desc = "You could build a fort with this."
	icon_state = "large_box"
	w_class = 4 // Big, bulky.
	foldable_amt = 4
	storage_slots = 21
	max_combined_w_class = 42 // 21*2

////////////////////
/* Survival Boxes */
////////////////////
/obj/item/storage/box/survival
	icon_state = "civ_box"

/obj/item/storage/box/survival/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
		new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
		new /obj/item/flashlight/flare(src)
	else
		new /obj/item/tank/internals/emergency_oxygen(src)
		new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
		new /obj/item/flashlight/flare/glowstick/emergency(src)


/obj/item/storage/box/survival_vox
	icon_state = "vox_box"

/obj/item/storage/box/survival_vox/populate_contents()
	new /obj/item/clothing/mask/breath/vox(src)
	new /obj/item/tank/internals/emergency_oxygen/nitrogen(src)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
		new /obj/item/flashlight/flare(src)
	else
		new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
		new /obj/item/flashlight/flare/glowstick/emergency(src)

/obj/item/storage/box/survival_plasmaman
	icon_state = "plasma_box"

/obj/item/storage/box/survival_plasmaman/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/plasma(src)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
		new /obj/item/flashlight/flare(src)
	else
		new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
		new /obj/item/flashlight/flare/glowstick/emergency(src)

/obj/item/storage/box/engineer
	icon_state = "eng_box"

/obj/item/storage/box/engineer/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/tank/internals/emergency_oxygen/double(src)
		new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
		new /obj/item/flashlight/flare(src)
	else
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
		new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
		new /obj/item/flashlight/flare/glowstick/emergency(src)

/obj/item/storage/box/survival_mining
	icon_state = "min_box"

/obj/item/storage/box/survival_mining/populate_contents()
	new /obj/item/clothing/mask/gas/explorer(src)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/tank/internals/emergency_oxygen/double(src)
		new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
		new /obj/item/flashlight/flare(src)
	else
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
		new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
		new /obj/item/flashlight/flare/glowstick/emergency(src)

/obj/item/storage/box/survival_syndie
	icon_state = "syndie_box"
	desc = "A sleek, sturdy box."

/obj/item/storage/box/survival_syndie/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/reagent_containers/pill/initropidril(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival_syndie/traitor/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/survival_syndie/traitor/loot/populate_contents()
	new /obj/item/crowbar/small(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/flashlight/flare/glowstick/red(src)

/obj/item/storage/box/syndie_kit/loot/populate_contents()
	new /obj/effect/spawner/random/syndie_mob_loot(src)

/obj/item/storage/box/syndie_kit/loot/elite/populate_contents()
	new /obj/effect/spawner/random/pool/spaceloot/syndicate/armory/elite(src)

//////////////////
/* Common Boxes */
//////////////////

/obj/item/storage/box/tapes
	name = "Tape Box"
	desc = "A box of spare recording tapes."
	icon_state = "tape_box"

/obj/item/storage/box/tapes/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/tape/random(src)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	icon_state = "cup_box"

/obj/item/storage/box/cups/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/drinks/sillycup(src)

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/storage/box/drinkingglasses/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/drinks/drinkingglass(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/storage/box/condimentbottles/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/reagent_containers/condiment(src)

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<b><font color='red'>WARNING:</font></b> <i>Keep out of reach of children</i>."
	icon_state = "mousetraps_box"

/obj/item/storage/box/mousetraps/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/assembly/mousetrap(src)

/obj/item/storage/box/ids
	name = "spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id_box"

/obj/item/storage/box/ids/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/card/id(src)

/obj/item/storage/box/lights
	name = "replacement bulbs"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	icon_state = "light_box"
	storage_slots = 21
	can_hold = list(/obj/item/light/tube, /obj/item/light/bulb)
	max_combined_w_class = 21
	use_to_pickup = TRUE // for picking up broken bulbs, not that most people will try

/obj/item/storage/box/lights/bulbs/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/lights/tubes
	name = "replacement tubes"
	icon_state = "light_tube_box"

/obj/item/storage/box/lights/tubes/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/light/tube(src)

/obj/item/storage/box/lights/mixed
	name = "replacement lights"
	icon_state = "light_mixed_box"

/obj/item/storage/box/lights/mixed/populate_contents()
	for(var/I in 1 to 14)
		new /obj/item/light/tube(src)
	for(var/I in 1 to 7)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/disks_plantgene
	name = "plant data disks box"
	icon_state = "disk_box"

/obj/item/storage/box/disks_plantgene/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/disk/plantgene(src)

/obj/item/storage/box/pdas
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon_state = "pda_box"

/obj/item/storage/box/pdas/populate_contents()
	var/newcart = pick(
		/obj/item/cartridge/engineering,
		/obj/item/cartridge/security,
		/obj/item/cartridge/medical,
		/obj/item/cartridge/signal/toxins,
		/obj/item/cartridge/cargo)

	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/cartridge/head(src)
	new newcart(src)

///////////////////
/* Special Boxes */
///////////////////
/obj/item/storage/box/bartender_rare_ingredients_kit
	name = "bartender rare reagents kit"
	desc = "A box intended for experienced bartenders."

/obj/item/storage/box/bartender_rare_ingredients_kit/populate_contents()
	var/list/reagent_list = list("sacid", "radium", "ether", "methamphetamine", "plasma", "gold", "silver", "capsaicin", "psilocybin")
	for(var/reag in reagent_list)
		var/obj/item/reagent_containers/glass/bottle/B = new(src)
		B.reagents.add_reagent(reag, 30)
		B.name = "[reag] bottle"

/obj/item/storage/box/chef_rare_ingredients_kit
	name = "chef rare reagents kit"
	desc = "A box intended for experienced chefs."

/obj/item/storage/box/chef_rare_ingredients_kit/populate_contents()
	new /obj/item/reagent_containers/condiment/soysauce(src)
	new /obj/item/reagent_containers/condiment/enzyme(src)
	new /obj/item/reagent_containers/condiment/pack/hotsauce(src)
	new /obj/item/kitchen/knife/butcher(src)
	var/list/reagent_list = list("msg", "triple_citrus", "salglu_solution", "nutriment", "gravy", "honey", "vitfro")
	for(var/reag in reagent_list)
		var/obj/item/reagent_containers/glass/bottle/B = new(src)
		B.reagents.add_reagent(reag, 30)
		B.name = "[reag] bottle"

/obj/item/storage/box/botany_labelled_seeds
	name = "botanist labelled random seeds kit"
	desc = "A box intended for experienced botanists."

/obj/item/storage/box/botany_labelled_seeds/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/seeds/random/labelled(src)

/obj/item/storage/box/barber
	name = "barber starter kit"
	desc = "For all hairstyling needs."

/obj/item/storage/box/barber/populate_contents()
	new /obj/item/scissors/barber(src)
	new /obj/item/hair_dye_bottle(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/hairgrownium(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/hair_dye(src)
	new /obj/item/reagent_containers/glass/bottle/reagent(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/clothing/mask/fakemoustache(src) //totally necessary for successful barbering -Fox

/obj/item/storage/box/lip_stick
	name = "lipstick kit"
	desc = "For all your lip coloring needs."

/obj/item/storage/box/lip_stick/populate_contents()
	new /obj/item/lipstick(src)
	new /obj/item/lipstick/purple(src)
	new /obj/item/lipstick/jade(src)
	new /obj/item/lipstick/black(src)
	new /obj/item/lipstick/green(src)
	new /obj/item/lipstick/blue(src)
	new /obj/item/lipstick/white(src)

/obj/item/storage/box/characters
	name = "box of miniatures"
	desc = "The nerd's best friends."
	icon_state = "toy_box"

/obj/item/storage/box/characters/populate_contents()
	new /obj/item/toy/character/alien(src)
	new /obj/item/toy/character/cleric(src)
	new /obj/item/toy/character/warrior(src)
	new /obj/item/toy/character/thief(src)
	new /obj/item/toy/character/wizard(src)
	new /obj/item/toy/character/cthulhu(src)
	new /obj/item/toy/character/lich(src)

/obj/item/storage/box/large/rnd_parts
	name = "\improper R&D components box"
	desc = "A full set of labelled components for assembling an R&D setup with. There are wordless picrographs of how to assemble everything on the back."

/obj/item/storage/box/large/rnd_parts/populate_contents()
	new /obj/item/circuitboard/rnd_network_controller(src)
	new /obj/item/circuitboard/rdserver(src)
	new /obj/item/circuitboard/rdconsole(src)
	new /obj/item/circuitboard/protolathe(src)
	new /obj/item/circuitboard/scientific_analyzer(src)
	new /obj/item/circuitboard/circuit_imprinter(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/scanning_module(src)
	new /obj/item/stock_parts/scanning_module(src)
	new /obj/item/stock_parts/micro_laser(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)

/obj/item/storage/box/large/glowstick/emergency
	name = "emergency glowstick box"
	desc = "A large box filled to the brim with cheap emergency glowsticks."

/obj/item/storage/box/large/glowstick/emergency/populate_contents()
	for(var/i in 1 to 15)
		new /obj/item/flashlight/flare/glowstick/emergency(src)

/obj/item/storage/box/glowstick/premium
	name = "premium glowstick box"
	desc = "A box filled with high-quality military surplus glowsticks."

/obj/item/storage/box/glowstick/premium/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/flashlight/flare/glowstick(src)

/obj/item/storage/box/flares
	name = "emergency flare box"
	desc = "A box full of magnesium signal flares."

/obj/item/storage/box/flares/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/flashlight/flare(src)


//////////////////
/* Monkey Boxes */
//////////////////
/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon_state = "monkey_box"
	can_hold = list(/obj/item/food/monkeycube)
	var/monkey_cube_type = /obj/item/food/monkeycube

/obj/item/storage/box/monkeycubes/populate_contents()
	for(var/I in 1 to 5)
		new monkey_cube_type(src)

/obj/item/storage/box/monkeycubes/obj_destruction(damage_flag)
	if(damage_flag == ACID || damage_flag == FIRE)
		for(var/obj/item/food/monkeycube/mkc in contents)
			mkc.obj_destruction(damage_flag)
	. = ..()

/obj/item/storage/box/monkeycubes/syndicate
	desc = "Waffle Co. brand monkey cubes. Just add water and a dash of subterfuge!"
	monkey_cube_type = /obj/item/food/monkeycube/syndicate

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes. Just add water!"
	icon_state = "farwa_box"
	monkey_cube_type = /obj/item/food/monkeycube/farwacube

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes. Just add water!"
	icon_state = "stok_box"
	monkey_cube_type = /obj/item/food/monkeycube/stokcube

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes. Just add water!"
	icon_state = "neaera_box"
	monkey_cube_type = /obj/item/food/monkeycube/neaeracube

/obj/item/storage/box/monkeycubes/wolpincubes
	name = "wolpin cube box"
	desc = "Drymate brand wolpin cubes. Just add water!"
	icon_state = "wolpin_box"
	monkey_cube_type = /obj/item/food/monkeycube/wolpincube

/obj/item/storage/box/monkeycubes/nian_worme_cubes
	name = "nian worme cube box"
	desc = "Nian Trade Guild brand worme cubes. Just add water!"
	icon_state = "nian_worme_box"
	monkey_cube_type = /obj/item/food/monkeycube/nian_wormecube

///////////////////
/* Medical Boxes */
///////////////////
/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex_box"

/obj/item/storage/box/gloves/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/storage/box/masks
	name = "sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "mask_box"

/obj/item/storage/box/masks/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/box/syringes
	name = "syringes"
	desc = "A box full of syringes."
	icon_state = "syringe_box"

/obj/item/storage/box/syringes/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/beakers
	name = "beaker box"
	icon_state = "beaker_box"

/obj/item/storage/box/beakers/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker(src)

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	icon_state = "beaker_bs_box"

/obj/item/storage/box/beakers/bluespace/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/box/iv_bags
	name = "IV Bags"
	desc = "A box full of empty IV bags."
	icon_state = "iv_box"

/obj/item/storage/box/iv_bags/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/iv_bag(src)

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "injector_box"

/obj/item/storage/box/autoinjectors/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)

/obj/item/storage/box/autoinjectors/utility
	name = "autoinjector kit"
	desc = "A box with several utility autoinjectors for the economical miner."

/obj/item/storage/box/autoinjectors/utility/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/teporone(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/teporone(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/stimpack(src)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	icon_state = "pillbox_box"

/obj/item/storage/box/pillbottles/populate_contents()
	for(var/I in 1 to 7)
		var/obj/item/storage/pill_bottle/P = new /obj/item/storage/pill_bottle(src)
		P.apply_wrapper_color(I)

/obj/item/storage/box/patch_packs
	name = "box of patch packs"
	desc = "It has pictures of patch packs on its front."
	icon_state = "patch_box"

/obj/item/storage/box/patch_packs/populate_contents()
	for(var/I in 1 to 7)
		var/obj/item/storage/pill_bottle/P = new /obj/item/storage/pill_bottle/patch_pack(src)
		P.apply_wrapper_color(I)

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags_box"

/obj/item/storage/box/bodybags/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/rxglasses
	name = "prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses_box"

/obj/item/storage/box/rxglasses/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

////////////////////
/* Security Boxes */
////////////////////
/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang_box"

/obj/item/storage/box/flashbangs/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/flashbang(src)

/obj/item/storage/box/stingers
	name = "box of stinger grenades (WARNING)"
	desc = "<b>WARNING: These devices are dangerous and can cause significant physical harm with repeated use.</b>"
	icon_state = "flashbang_box"

/obj/item/storage/box/stingers/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/frag/stinger(src)

/obj/item/storage/box/smoke_grenades
	name = "smoke grenades"
	desc = "A box with 7 smoke grenades."
	icon_state = "teargas_box"

/obj/item/storage/box/smoke_grenades/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/smokebomb(src)

/obj/item/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "flash_box"

/obj/item/storage/box/flashes/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/flash(src)

/obj/item/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "teargas_box"

/obj/item/storage/box/teargas/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/chem_grenade/teargas(src)

/obj/item/storage/box/emps
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "emp_box"

/obj/item/storage/box/emps/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/empgrenade(src)

/obj/item/storage/box/prisoner
	name = "prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "id_prisoner_box"

/obj/item/storage/box/prisoner/populate_contents()
	new /obj/item/card/id/prisoner/one(src)
	new /obj/item/card/id/prisoner/two(src)
	new /obj/item/card/id/prisoner/three(src)
	new /obj/item/card/id/prisoner/four(src)
	new /obj/item/card/id/prisoner/five(src)
	new /obj/item/card/id/prisoner/six(src)
	new /obj/item/card/id/prisoner/seven(src)

/obj/item/storage/box/seccarts
	name = "spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda_box"

/obj/item/storage/box/seccarts/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/cartridge/security(src)

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."
	icon_state = "badge_box"

/obj/item/storage/box/holobadge/populate_contents()
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)
	new /obj/item/clothing/accessory/holobadge/cord(src)

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	icon_state = "evidence_box"

/obj/item/storage/box/evidence/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/evidencebag(src)

/obj/item/storage/box/handcuffs
	name = "spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff_box"

/obj/item/storage/box/handcuffs/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/restraints/handcuffs(src)

/obj/item/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "zipties_box"

/obj/item/storage/box/zipties/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/restraints/handcuffs/cable/zipties(src)

////////////////////
/* Implants Boxes */
////////////////////
/obj/item/storage/box/trackimp
	name = "tracking bio-chip kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant_box"

/obj/item/storage/box/trackimp/populate_contents()
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_implanter(src)
	new /obj/item/bio_chip_pad(src)
	new /obj/item/gps/security(src)

/obj/item/storage/box/minertracker
	name = "boxed tracking bio-chip kit"
	desc = "For finding those who have died on the accursed lavaworld."
	icon_state = "implant_box"

/obj/item/storage/box/minertracker/populate_contents()
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_case/tracking(src)
	new /obj/item/bio_chip_implanter(src)
	new /obj/item/bio_chip_pad(src)
	new /obj/item/gps/mining(src)

/obj/item/storage/box/chemimp
	name = "chemical bio-chip kit"
	desc = "Box of stuff used to bio-chip chemicals."
	icon_state = "implant_box"

/obj/item/storage/box/chemimp/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/bio_chip_case/chem(src)
	new /obj/item/bio_chip_implanter(src)
	new /obj/item/bio_chip_pad(src)

/obj/item/storage/box/deathimp
	name = "death alarm bio-chip kit"
	desc = "Box of life sign monitoring bio-chips."
	icon_state = "implant_box"

/obj/item/storage/box/deathimp/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/bio_chip_case/death_alarm(src)
	new /obj/item/bio_chip_implanter/death_alarm (src)

////////////////
/* Ammo Boxes */
////////////////

/obj/item/storage/fancy/shell
	icon = 'icons/obj/shell_boxes.dmi'
	storage_slots = 8
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	can_hold = list(/obj/item/ammo_casing/shotgun)
	/// What shell do we fill the box with
	var/shell_type

/obj/item/storage/fancy/shell/fancy_storage_examine(mob/user)
	. = list()
	if(!length(contents))
		. += "There are no shells in the box."
		return

	var/list/shell_list = list() // Associated list of all shells in the box
	for(var/obj/item/ammo_casing/shotgun/shell as anything in contents)
		shell_list[shell.name] += 1

	for(var/thing as anything in shell_list)
		if(shell_list[thing] == 1)
			. += "There is one [thing] in the box."
		else
			. += "There are [shell_list[thing]] [thing]s in the box."

/obj/item/storage/fancy/shell/update_icon_state()
	icon_state = "open"

/obj/item/storage/fancy/shell/populate_contents()
	if(!shell_type)
		return
	for(var/i in 1 to storage_slots)
		new shell_type(src)

/obj/item/storage/fancy/shell/update_overlays()
	. = ..()
	var/list/cached_contents = contents
	for(var/index in 1 to length(cached_contents))
		var/obj/shell = cached_contents[index]
		var/image/I = image(icon, src, initial(shell.icon_state))
		I.pixel_x = 3 * (round((index - 1) / 2))
		I.pixel_y = -4 * ((index + 1) % 2)
		. += I

	. += "shell_box_front" // need to add another overlay to prevent from other overlays from showing on top

/obj/item/storage/fancy/shell/tranquilizer
	name = "ammunition box (Tranquilizer darts)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "tranqbox"
	shell_type = /obj/item/ammo_casing/shotgun/tranquilizer

/obj/item/storage/fancy/shell/slug
	name = "ammunition box (Slug)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "slugbox"
	shell_type = /obj/item/ammo_casing/shotgun

/obj/item/storage/fancy/shell/buck
	name = "ammunition box (Buckshot)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "buckbox"
	shell_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/storage/fancy/shell/dragonsbreath
	name = "ammunition box (Dragonsbreath)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "dragonsbox"
	shell_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/storage/fancy/shell/stun
	name = "ammunition box (Stun shells)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "stunbox"
	shell_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/storage/fancy/shell/beanbag
	name = "ammunition box (Beanbag shells)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "beanbox"
	shell_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/storage/fancy/shell/rubbershot
	name = "ammunition box (Rubbershot shells)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "rubberbox"
	shell_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/storage/fancy/shell/holy
	name = "ammunition box (Holy Water darts)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "holybox"
	shell_type = /obj/item/ammo_casing/shotgun/holy

/obj/item/storage/fancy/shell/confetti
	name = "ammunition box (Confettishot)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "partybox"
	shell_type = /obj/item/ammo_casing/shotgun/confetti

/obj/item/storage/fancy/shell/meteor
	name = "ammunition box (Meteorslug)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "meteorbox"
	shell_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/storage/fancy/shell/ion
	name = "ammunition box (Ionshot)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "ionbox"
	shell_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/storage/fancy/shell/pulse
	name = "ammunition box (Proto Pulse Slug)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "pulsebox"
	shell_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/storage/fancy/shell/incindiary
	name = "ammunition box (Incendiary slug)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "incendiarybox"
	shell_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/storage/fancy/shell/lasershot
	name = "ammunition box (Lasershot)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "lasershotbox"
	shell_type = /obj/item/ammo_casing/shotgun/lasershot

/obj/item/storage/fancy/shell/frag12
	name = "ammunition box (FRAG-12 slug)"
	desc = "A small box capable of holding eight shotgun shells."
	icon_state = "frag12box"
	shell_type = /obj/item/ammo_casing/shotgun/frag12

////////////////
/* Donk Boxes */
////////////////
/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "A heavy, insulated box that reads, <b>Instructions:</b> <i>Heat in microwave. Product will cool if not eaten within seven minutes. Store product in box to keep warm.</i>"
	icon_state = "donk_box"
	storage_slots = 6
	can_hold = list(
		/obj/item/food/donkpocket,
		/obj/item/food/warmdonkpocket,
		/obj/item/food/warmdonkpocket_weak,
		/obj/item/food/syndidonkpocket)

/obj/item/storage/box/donkpockets/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/food/donkpocket(src)

/obj/item/storage/box/donkpockets/empty/populate_contents()
	return

/obj/item/storage/box/syndidonkpockets
	name = "box of donk-pockets"
	desc = "This box feels slightly warm."
	icon_state = "donk_box"

/obj/item/storage/box/syndidonkpockets/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/food/syndidonkpocket(src)

////////////////
/* Misc Boxes */
////////////////
/obj/item/storage/box/permits
	name = "box of construction permits"
	desc = "A box for containing construction permits, used to officially declare built rooms as additions to the station."
	icon_state = "id_box"

/obj/item/storage/box/permits/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/areaeditor/permit(src)

/obj/item/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alien_handcuff_box"

/obj/item/storage/box/alienhandcuffs/populate_contents()
	for(var/I in 1 to 7)
		new	/obj/item/restraints/handcuffs/alien(src)

/obj/item/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "doom_box"

/obj/item/storage/box/fakesyndiesuit/populate_contents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/storage/box/enforcer_rubber
	name = "\improper Enforcer pistol kit (rubber)"
	desc = "A box marked with pictures of an Enforcer pistol, two ammo clips, and the word 'NON-LETHAL'."
	icon_state = "ert_box"

/obj/item/storage/box/enforcer_rubber/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/enforcer(src) // loaded with rubber by default
	new /obj/item/ammo_box/magazine/enforcer(src)
	new /obj/item/ammo_box/magazine/enforcer(src)

/obj/item/storage/box/enforcer_lethal
	name = "\improper Enforcer pistol kit (lethal)"
	desc = "A box marked with pictures of an Enforcer pistol, two ammo clips, and the word 'LETHAL'."
	icon_state = "ert_box"

/obj/item/storage/box/enforcer_lethal/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/enforcer/lethal(src)
	new /obj/item/ammo_box/magazine/enforcer/lethal(src)
	new /obj/item/ammo_box/magazine/enforcer/lethal(src)

/obj/item/storage/box/hydroponics_starter
	name = "hydroponics starter kit"
	desc = "Everything you need to start your own botany lab."

/obj/item/storage/box/hydroponics_starter/populate_contents()
	for(var/I in 1 to 2)
		new /obj/item/circuitboard/hydroponics(src)
		new /obj/item/stock_parts/matter_bin(src)
		new /obj/item/stock_parts/matter_bin(src)
		new /obj/item/stock_parts/manipulator(src)
	new /obj/item/reagent_containers/glass/bucket(src)

/obj/item/storage/box/turbine_kit
	name = "turbine kit"
	desc = "Somehow, they managed to fit almost an entire turbine assembly into this box."

/obj/item/storage/box/turbine_kit/populate_contents()
	new /obj/item/circuitboard/turbine_computer(src)
	new /obj/item/circuitboard/power_compressor(src)
	new /obj/item/circuitboard/power_turbine(src)
	for(var/I in 1 to 6)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/manipulator(src)

/obj/item/storage/box/deagle
	name = "desert eagle handcannon kit"
	desc = "A box marked with pictures of the iconic Desert Eagle pistol, one ammo clip, and the word 'LETHAL'."
	icon_state = "doom_box"

/obj/item/storage/box/deagle/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol/deagle(src)
	new /obj/item/ammo_box/magazine/m50(src)

/obj/item/storage/box/marine_armor_export
	name = "\improper Federation marine armor box"
	desc = "A box containing a factory-fresh suit of export-grade Trans-Solar Marine Corps combat armor."

/obj/item/storage/box/marine_armor_export/populate_contents()
	new /obj/item/clothing/suit/armor/federation/marine/export(src)
	new /obj/item/clothing/head/helmet/federation/marine/export(src)

/obj/item/storage/box/skrell_suit
	name = "skrellian suit box"
	desc = "A box containing a skrell-designed medical spacesuit."
	icon_state = "doom_box"

/obj/item/storage/box/skrell_suit/white
	name = "white skrellian suit box"
	desc = "A box containing a skrell-designed medical spacesuit. This one is white."

/obj/item/storage/box/skrell_suit/white/populate_contents()
	new /obj/item/clothing/head/helmet/space/skrell/white(src)
	new /obj/item/clothing/suit/space/skrell/white(src)

/obj/item/storage/box/skrell_suit/black
	name = "black skrellian suit box"
	desc = "A box containing a skrell-designed medical spacesuit. This one is black."

/obj/item/storage/box/skrell_suit/black/populate_contents()
	new /obj/item/clothing/head/helmet/space/skrell/black(src)
	new /obj/item/clothing/suit/space/skrell/black(src)

/obj/item/storage/box/breacher
	name = "unathi breacher suit box"
	desc = "A box containing a bulky unathi battlesuit."
	icon_state = "doom_box"

/obj/item/storage/box/breacher/populate_contents()
	new /obj/item/clothing/suit/space/unathi/breacher(src)
	new /obj/item/clothing/head/helmet/space/unathi/breacher(src)

/obj/item/storage/box/vox_spacesuit
	name = "vox voidsuit box"
	desc = "A box containing an old, dusty voidsuit fit for vox."
	icon_state = "doom_box"

/obj/item/storage/box/vox_spacesuit/populate_contents()
	new /obj/item/clothing/head/helmet/space/vox/pressure(src)
	new /obj/item/clothing/suit/space/vox/pressure(src)

/obj/item/storage/box/telescience
	name = "babies first telescience kit"
	desc = "A now restricted kit for those who want to learn about telescience!"
	icon_state = "circuit_box"

/obj/item/storage/box/telescience/populate_contents()
	new /obj/item/circuitboard/telesci_pad(src)
	new /obj/item/circuitboard/telesci_console(src)

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon_state = "toy_box"
	storage_slots = 8
	can_hold = list(/obj/item/toy/snappop)

/obj/item/storage/box/snappops/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/toy/snappop(src)

/obj/item/storage/box/injectors
	name = "\improper DNA injectors"
	desc = "This box contains injectors it seems."
	icon_state = "injector_box"

/obj/item/storage/box/injectors/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/dnainjector/h2m(src)


#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILE "SmileyFace"

/obj/item/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon = 'icons/obj/storage.dmi'
	icon_state = "paperbag_None"
	foldable = null
	var/design = NODESIGN

/obj/item/storage/box/papersack/update_desc()
	. = ..()
	switch(design)
		if(NODESIGN)
			desc = "A sack neatly crafted out of paper."
		if(NANOTRASEN)
			desc = "A standard Nanotrasen paper lunch sack for loyal employees on the go."
		if(SYNDI)
			desc = "The design on this paper sack is a remnant of the notorious 'SyndieSnacks' program."
		if(HEART)
			desc = "A paper sack with a heart etched onto the side."
		if(SMILE)
			desc = "A paper sack with a crude smile etched onto the side."

/obj/item/storage/box/papersack/update_icon_state()
	icon_state = "paperbag_[design][length(contents) ? "_closed" : ""]"

/obj/item/storage/box/papersack/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(is_pen(W))
		//if a pen is used on the sack, dialogue to change its design appears
		if(length(contents))
			to_chat(user, "<span class='warning'>You can't modify [src] with items still inside!</span>")
			return
		var/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILE)
		var/switchDesign = tgui_input_list(user, "Select a Design", "Paper Sack Design", designs)
		if(!switchDesign)
			return
		if(get_dist(usr, src) > 1 && !usr.incapacitated())
			to_chat(usr, "<span class='warning'>You have moved too far away!</span>")
			return
		if(design == switchDesign)
			return
		to_chat(usr, "<span class='notice'>You make some modifications to [src] using your pen.</span>")
		design = switchDesign
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		return
	else if(W.sharp)
		if(!length(contents))
			if(icon_state == "paperbag_None")
				to_chat(user, "<span class='notice'>You cut eyeholes into [src].</span>")
				new /obj/item/clothing/head/papersack(user.loc)
				qdel(src)
				return
			else if(icon_state == "paperbag_SmileyFace")
				to_chat(user, "<span class='notice'>You cut eyeholes into [src] and modify the design.</span>")
				new /obj/item/clothing/head/papersack/smiley(user.loc)
				qdel(src)
				return
	return ..()

/obj/item/storage/box/papersack/pbj_lunch
	name = "peanut butter and jelly lunch"
	desc = "A paper sack filled with enough sandwiches to feed a department."

/obj/item/storage/box/papersack/pbj_lunch/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/food/peanut_butter_jelly(src)

/obj/item/storage/box/relay_kit
	name = "telecommunications relay kit"
	desc = "Contains everything you need to set up your own telecommunications array!"

/obj/item/storage/box/relay_kit/populate_contents()
	new /obj/item/paper/tcommskey(src)
	new /obj/item/stack/sheet/metal/(src, 5)
	new /obj/item/circuitboard/tcomms/relay(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stack/cable_coil(src, 7)

/obj/item/storage/box/centcomofficer
	name = "officer kit"
	icon_state = "ert_box"
	storage_slots = 14
	max_combined_w_class = 20

/obj/item/storage/box/centcomofficer/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/kitchen/knife/combat(src)

	new /obj/item/radio/centcom(src)
	new /obj/item/door_remote/omni(src)
	new /obj/item/bio_chip_implanter/death_alarm(src)

	new /obj/item/reagent_containers/hypospray/combat/nanites(src)
	new /obj/item/pinpointer(src)
	new /obj/item/pinpointer/crew/centcom(src)

/obj/item/storage/box/responseteam
	name = "boxed survival kit"
	icon_state = "ert_box"

/obj/item/storage/box/responseteam/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/radio/centcom(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)

/obj/item/storage/box/deathsquad
	name = "boxed death kit"
	icon_state = "doom_box"

/obj/item/storage/box/deathsquad/populate_contents()
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/grenade/plastic/c4/x4(src)
	new /obj/item/reagent_containers/patch/synthflesh(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/survival(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)

/obj/item/storage/box/soviet
	name = "boxed survival kit"
	desc = "A standard issue Soviet military survival kit."
	icon_state = "soviet_box"

/obj/item/storage/box/soviet/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine
	new /obj/item/flashlight/flare(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/reagent_containers/patch/synthflesh(src)
	new /obj/item/reagent_containers/patch/synthflesh(src)

/obj/item/storage/box/clown
	name = "clown box"
	desc = "A colorful cardboard box for the clown."
	icon_state = "clown_box"
	var/robot_arm // This exists for bot construction

/obj/item/storage/box/emptysandbags
	name = "box of empty sandbags"

/obj/item/storage/box/emptysandbags/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/emptysandbag(src)

/obj/item/storage/box/rndboards
	name = "the Liberator's legacy"
	desc = "A box containing a gift for worthy golems."
	icon_state = "circuit_box"

/obj/item/storage/box/rndboards/populate_contents()
	new /obj/item/circuitboard/protolathe(src)
	new /obj/item/circuitboard/scientific_analyzer(src)
	new /obj/item/circuitboard/circuit_imprinter(src)
	new /obj/item/circuitboard/rdconsole/public(src)
	new /obj/item/circuitboard/rnd_network_controller(src)

/obj/item/storage/box/stockparts
	display_contents_with_number = TRUE

/obj/item/storage/box/smithboards
	name = "the Liberator's fabricator"
	desc = "A box containing a gift for golems with the will to create."
	icon_state = "circuit_box"

/obj/item/storage/box/smithboards/populate_contents()
	new /obj/item/circuitboard/magma_crucible(src)
	new /obj/item/circuitboard/casting_basin(src)
	new /obj/item/circuitboard/casting_basin(src)
	new /obj/item/circuitboard/power_hammer(src)
	new /obj/item/circuitboard/lava_furnace(src)
	new /obj/item/circuitboard/kinetic_assembler(src)
	new /obj/item/vending_refill/smith(src)
	new /obj/item/circuitboard/vendor(src)

/// for ruins where it's a bad idea to give access to an autolathe/protolathe, but still want to make stock parts accessible
/obj/item/storage/box/stockparts/basic
	name = "box of stock parts"
	desc = "Contains a variety of basic stock parts."

/obj/item/storage/box/stockparts/basic/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

/obj/item/storage/box/stockparts/deluxe
	name = "box of deluxe stock parts"
	desc = "Contains a variety of deluxe stock parts."

/obj/item/storage/box/stockparts/deluxe/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)

/obj/item/storage/box/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hug_box"
	foldable = null

/obj/item/storage/box/hug/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all..</span>")
	return (BRUTELOSS)

/obj/item/storage/box/hug/attack_self__legacy__attackchain(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, TRUE, -5)
	user.visible_message("<span class='notice'>[user] hugs \the [src].</span>","<span class='notice'>You hug \the [src].</span>")

/obj/item/storage/box/wizard
	name = "magical box"
	desc = "It's just an ordinary magical box."
	icon_state = "wizard_box"
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/storage/box/wizard/hardsuit
	name = "battlemage armour bundle"
	desc = "This box contains a bundle of Battlemage Armour."

/obj/item/storage/box/wizard/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/wizard(src)
	new /obj/item/clothing/shoes/magboots/wizard(src)

/obj/item/storage/box/breaching
	name = "breaching charges"
	desc = "Contains three T4 thermal breaching charges."
	icon_state = "grenade_box"

/obj/item/storage/box/breaching/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/c4/thermite(src)

/obj/item/storage/box/mindshield
	name = "boxed mindshield kit"
	desc = "Contains everything needed to secure the minds of those around you."
	icon_state = "implant_box"

/obj/item/storage/box/mindshield/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/bio_chip_case/mindshield(src)
	new /obj/item/bio_chip_implanter/mindshield(src)

/obj/item/storage/box/dish_drive
	name = "DIY Dish Drive Kit"
	desc = "Contains everything you need to build your own Dish Drive!"

/obj/item/storage/box/dish_drive/populate_contents()
	new /obj/item/stack/sheet/metal/(src, 5)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/circuitboard/dish_drive(src)
	new /obj/item/stack/sheet/glass(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/screwdriver(src)

/obj/item/storage/box/crewvend
	name = "CrewVend 3000 Kit"
	desc = "Contains everything you need to build your own vending machine!"

/obj/item/storage/box/crewvend/populate_contents()
	new /obj/item/stack/sheet/metal/(src, 5)
	new /obj/item/stack/cable_coil/five(src)
	var/obj/item/circuitboard/vendor/board = new /obj/item/circuitboard/vendor(src)
	board.set_type("CrewVend 3000")
	new /obj/item/screwdriver(src)

/obj/item/storage/box/hardmode_box
	name = "box of HRD-MDE project box"
	desc = "Contains everything needed to get yourself killed for a medal."

/obj/item/storage/box/hardmode_box/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/megafauna_hardmode(src)
	new /obj/item/storage/lockbox/medal/hardmode_box(src)
	new /obj/item/paper/hardmode(src)

/obj/item/storage/box/oxygen_grenades
	name = "oxygen grenades box"
	desc = "A box full of oxygen grenades."
	icon_state = "flashbang_box"

/obj/item/storage/box/oxygen_grenades/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/gas/oxygen(src)

/obj/item/storage/box/foam_grenades
	name = "foam grenades box"
	desc = "A box full of foam grenades."
	icon_state = "flashbang_box"

/obj/item/storage/box/foam_grenades/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/grenade/chem_grenade/metalfoam(src)

/obj/item/storage/box/coke_envirosuit
	name = "coke suit box"
	desc = "A box with a special envirosuit brought to you by Space Cola Co."
	icon_state = "plasma_box"

/obj/item/storage/box/coke_envirosuit/populate_contents()
	new /obj/item/clothing/under/plasmaman/coke(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/coke(src)

/obj/item/storage/box/tacticool_envirosuit
	name = "tactical suit box"
	desc = "A box with a special envirosuit usually supplied by black markets."
	icon_state = "plasma_box"

/obj/item/storage/box/tacticool_envirosuit/populate_contents()
	new /obj/item/clothing/under/plasmaman/tacticool(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/tacticool(src)

/obj/item/storage/box/chapbw_envirosuit
	name = "chaplain suit box, black and white"
	desc = "A box with a special envirosuit for pious plasmamen."
	icon_state = "plasma_box"

/obj/item/storage/box/chapbw_envirosuit/populate_contents()
	new /obj/item/clothing/under/plasmaman/chaplain(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chaplain(src)

/obj/item/storage/box/chapwg_envirosuit
	name = "chaplain suit box, white and green"
	desc = "A box with a special envirosuit for pious plasmamen."
	icon_state = "plasma_box"

/obj/item/storage/box/chapwg_envirosuit/populate_contents()
	new /obj/item/clothing/under/plasmaman/chaplain/green(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chaplain/green(src)

/obj/item/storage/box/chapco_envirosuit
	name = "chaplain suit box, blue and orange"
	desc = "A box with a special envirosuit for pious plasmamen."
	icon_state = "plasma_box"

/obj/item/storage/box/chapco_envirosuit/populate_contents()
	new /obj/item/clothing/under/plasmaman/chaplain/blue(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chaplain/orange(src)

/obj/item/storage/box/autochef
	name = "autochef starter kit"
	desc = "Contains everything you need to build and use an autochef."

/obj/item/storage/box/autochef/populate_contents()
	new /obj/item/circuitboard/autochef(src)
	new /obj/item/stack/sheet/metal(src, 5)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/matter_bin(src)
	new /obj/item/stock_parts/micro_laser(src)
	new /obj/item/stock_parts/manipulator(src)
	new /obj/item/autochef_remote(src)
	new /obj/item/screwdriver(src)
	new /obj/item/paper/autochef_quickstart(src)

/obj/item/storage/box/kitchen_utensils/populate_contents()
	new /obj/item/kitchen/utensil/fork(src)
	new /obj/item/kitchen/utensil/fork(src)
	new /obj/item/kitchen/utensil/spoon(src)
	new /obj/item/kitchen/utensil/spoon(src)
	new /obj/item/kitchen/knife(src)
	new /obj/item/kitchen/knife/cheese(src)
	new /obj/item/kitchen/knife/pizza_cutter(src)

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILE
