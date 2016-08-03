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

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	burn_state = FLAMMABLE
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/box/large
	name = "large box"
	desc = "You could build a fort with this."
	icon_state = "largebox"
	w_class = 42 // Big, bulky.
	foldable = /obj/item/stack/sheet/cardboard  //BubbleWrap
	storage_slots = 21
	max_combined_w_class = 42 // 21*2

/obj/item/weapon/storage/box/survival
	New()
		..()
		contents = list()
		new /obj/item/clothing/mask/breath( src )
		new /obj/item/weapon/tank/emergency_oxygen( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		return

/obj/item/weapon/storage/box/engineer
	New()
		..()
		contents = list()
		new /obj/item/clothing/mask/breath( src )
		new /obj/item/weapon/tank/emergency_oxygen/engi( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		return

/obj/item/weapon/storage/box/survival_mining
	New()
		..()
		contents = list()
		new /obj/item/clothing/mask/breath(src)
		new /obj/item/weapon/tank/emergency_oxygen/engi(src)
		new /obj/item/weapon/crowbar/red(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)

/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"

	New()
		..()
		new /obj/item/clothing/gloves/color/latex(src)
		new /obj/item/clothing/gloves/color/latex(src)
		new /obj/item/clothing/gloves/color/latex(src)
		new /obj/item/clothing/gloves/color/latex(src)
		new /obj/item/clothing/gloves/color/latex(src)
		new /obj/item/clothing/gloves/color/latex(src)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/weapon/storage/box/masks
	name = "sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"

	New()
		..()
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)


/obj/item/weapon/storage/box/syringes
	name = "syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

	New()
		..()
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )
		new /obj/item/weapon/reagent_containers/syringe( src )

/obj/item/weapon/storage/box/beakers
	name = "beaker box"
	icon_state = "beaker"

	New()
		..()
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )
		new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/storage/box/injectors
	name = "\improper DNA injectors"
	desc = "This box contains injectors it seems."

	New()
		..()
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/h2m(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		new /obj/item/weapon/dnainjector/m2h(src)
		new /obj/item/weapon/dnainjector/m2h(src)

/obj/item/weapon/storage/box/gauge
	name = "box of 12 gauge slugs"
	desc = "It has a picture of a gun and several warning symbols on the front."
	materials = list(MAT_METAL=28000)

	New()
		..()
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)

/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"

	New()
		..()
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/grenade/flashbang(src)

/obj/item/weapon/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "flashbang"

	New()
		..()
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/flash(src)

/obj/item/weapon/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/teargas/New()
	..()
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)
	new /obj/item/weapon/grenade/chem_grenade/teargas(src)

/obj/item/weapon/storage/box/emps
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

	New()
		..()
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)
		new /obj/item/weapon/grenade/empgrenade(src)


/obj/item/weapon/storage/box/trackimp
	name = "tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)
		new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/chemimp
	name = "chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantpad(src)

/obj/item/weapon/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/box/deathimp
	name = "death alarm implant kit"
	desc = "Box of life sign monitoring implants."
	icon_state = "implant"

	New()
		..()
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/box/tapes
	name = "Tape Box"
	desc = "A box of spare recording tapes"
	icon_state = "box"

	New()
		..()
		new /obj/item/device/tape(src)
		new /obj/item/device/tape(src)
		new /obj/item/device/tape(src)
		new /obj/item/device/tape(src)
		new /obj/item/device/tape(src)
		new /obj/item/device/tape(src)

/obj/item/weapon/storage/box/rxglasses
	name = "prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"

	New()
		..()
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

	New()
		..()
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/weapon/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

	New()
		..()
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)

/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

	New()
		..()
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)
		new /obj/item/weapon/reagent_containers/food/condiment(src)



/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )


/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"

	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

/obj/item/weapon/storage/box/syndidonkpockets
	name = "box of donk-pockets"
	desc = "This box feels slightly warm"
	icon_state = "donk_kit"

	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket(src)

/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube")
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)
/obj/item/weapon/storage/box/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube")
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube(src)

/obj/item/weapon/storage/box/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube")
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube(src)

/obj/item/weapon/storage/box/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube")
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube(src)


/obj/item/weapon/storage/box/wolpincubes
	name = "wolpin cube box"
	desc = "Drymate brand wolpin cubes. Just add water!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/wolpincube")
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/wolpincube(src)


/obj/item/weapon/storage/box/permits
	name = "box of construction permits"
	desc = "A box for containing construction permits, used to officially declare built rooms as additions to the station."
	icon_state = "id"

/obj/item/weapon/storage/box/permits/New() //There's only a few, so blueprints are still useful beyond setting every room's name to PRIMARY FART STORAGE
	..()
	new /obj/item/areaeditor/permit(src)
	new /obj/item/areaeditor/permit(src)
	new /obj/item/areaeditor/permit(src)


/obj/item/weapon/storage/box/ids
	name = "spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

	New()
		..()
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)
		new /obj/item/weapon/card/id(src)

/obj/item/weapon/storage/box/prisoner
	name = "prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "id"

	New()
		..()
		new /obj/item/weapon/card/id/prisoner/one(src)
		new /obj/item/weapon/card/id/prisoner/two(src)
		new /obj/item/weapon/card/id/prisoner/three(src)
		new /obj/item/weapon/card/id/prisoner/four(src)
		new /obj/item/weapon/card/id/prisoner/five(src)
		new /obj/item/weapon/card/id/prisoner/six(src)
		new /obj/item/weapon/card/id/prisoner/seven(src)

/obj/item/weapon/storage/box/seccarts
	name = "spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"

	New()
		..()
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)
		new /obj/item/weapon/cartridge/security(src)


/obj/item/weapon/storage/box/handcuffs
	name = "spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"

	New()
		..()
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/restraints/handcuffs(src)

/obj/item/weapon/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "handcuff"

	New()
		..()
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
		new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)

/obj/item/weapon/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienboxCuffs"

	New()
		..()
		for(var/i in 1 to 7)
			new	/obj/item/weapon/restraints/handcuffs/alien(src)

/obj/item/weapon/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "box_of_doom"

	New()
		..()
		new /obj/item/clothing/head/syndicatefake(src)
		new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"

	New()
		..()
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )

/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."

	New()
		..()
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )
		new /obj/item/weapon/storage/pill_bottle( src )


/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list("/obj/item/toy/snappop")
	New()
		..()
		for(var/i=1; i <= storage_slots; i++)
			new /obj/item/toy/snappop(src)

/obj/item/weapon/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	storage_slots = 10
	w_class = 1
	slot_flags = SLOT_BELT

	New()
		..()
		for(var/i=1; i <= storage_slots; i++)
			new /obj/item/weapon/match(src)

	attackby(obj/item/weapon/match/W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/match) && W.lit == 0)
			W.lit = 1
			W.icon_state = "match_lit"
			processing_objects.Add(W)
			playsound(user.loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, 1)
		W.update_icon()
		return

/obj/item/weapon/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	New()
		..()
		for(var/i; i < storage_slots; i++)
			new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)

/obj/item/weapon/storage/box/autoinjector/utility
	name = "autoinjector kit"
	desc = "A box with several utility autoinjectors for the economical miner."
	icon_state = "syringe"

	New()
		..()
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/teporone(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/teporone(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack(src)

/obj/item/weapon/storage/box/lights
	name = "replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list("/obj/item/weapon/light/tube", "/obj/item/weapon/light/bulb")
	max_combined_w_class = 21
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/lights/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/light/tube(src)

/obj/item/weapon/storage/box/lights/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/light/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/light/bulb(src)

/obj/item/weapon/storage/box/barber
	name = "Barber Starter Kit"
	desc = "For all hairstyling needs."
	icon_state = "implant"

/obj/item/weapon/storage/box/barber/New()
	..()
	new /obj/item/weapon/scissors/barber(src)
	new /obj/item/hair_dye_bottle(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/reagent/hairgrownium(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/reagent/hair_dye(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/reagent(src)
	new /obj/item/weapon/reagent_containers/dropper(src)
	new /obj/item/clothing/mask/fakemoustache(src) //totally necessary for successful barbering -Fox

/obj/item/weapon/storage/box/lip_stick
	name = "Lipstick Kit"
	desc = "For all your lip coloring needs."
	icon_state = "implant"

/obj/item/weapon/storage/box/lip_stick/New()
	..()
	new /obj/item/weapon/lipstick(src)
	new /obj/item/weapon/lipstick/purple(src)
	new /obj/item/weapon/lipstick/jade(src)
	new /obj/item/weapon/lipstick/black(src)
	new /obj/item/weapon/lipstick/green(src)
	new /obj/item/weapon/lipstick/blue(src)
	new /obj/item/weapon/lipstick/white(src)

#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILE "SmileyFace"

/obj/item/weapon/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon_state = "paperbag_None"
	item_state = "paperbag_None"
	foldable = null
	var/design = NODESIGN

/obj/item/weapon/storage/box/papersack/update_icon()
	if(!contents.len)
		icon_state = "[item_state]"
	else icon_state = "[item_state]_closed"

/obj/item/weapon/storage/box/papersack/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		//if a pen is used on the sack, dialogue to change its design appears
		if(contents.len)
			to_chat(user, "<span class='warning'>You can't modify [src] with items still inside!</span>")
			return
		var/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILE)
		var/switchDesign = input("Select a Design:", "Paper Sack Design", designs[1]) as null|anything in designs
		if(!switchDesign)
			return
		if(get_dist(usr, src) > 1 && !usr.incapacitated())
			to_chat(usr, "<span class='warning'>You have moved too far away!</span>")
			return
		if(design == switchDesign)
			return
		to_chat(usr, "<span class='notice'>You make some modifications to [src] using your pen.</span>")
		design = switchDesign
		icon_state = "paperbag_[design]"
		item_state = "paperbag_[design]"
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
		return
	else if(is_sharp(W))
		if(!contents.len)
			if(item_state == "paperbag_None")
				to_chat(user, "<span class='notice'>You cut eyeholes into [src].</span>")
				new /obj/item/clothing/head/papersack(user.loc)
				qdel(src)
				return
			else if(item_state == "paperbag_SmileyFace")
				to_chat(user, "<span class='notice'>You cut eyeholes into [src] and modify the design.</span>")
				new /obj/item/clothing/head/papersack/smiley(user.loc)
				qdel(src)
				return
	return ..()

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILE