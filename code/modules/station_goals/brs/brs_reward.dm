/obj/item/paper/researchnotes_brs
	name = "Исследование Блюспейс Разлома"
	info = "<b>Какие-то заметки о блюспейс разломе. Возможно, это продвинет науку далеко вперед. \nК сожалению, вы не можете разобрать ни слова. \nТребуется деструктивный анализ.</b>"
	origin_tech = "bluespace=9;magnets=8"
	icon_state = "docs_part"

/obj/item/paper/researchnotes_brs/update_icon()
	return

/obj/structure/toilet/bluespace
	name = "Блюспейс унитаз"
	desc = "It is high technological utilization system. We don't need 'выгребная яма' anymore, all the stuff goes directly to the black hole."
	icon_state = "bluespace_toilet00"
	var/teleport_sound = 'sound/magic/lightning_chargeup.ogg'

/obj/structure/toilet/bluespace/update_icon()
	. = ..()
	icon_state = "bluespace_toilet[open][cistern]"
	overlays.Cut()
	if(open)
		overlays += image(icon, "bluespace_toilet_singularity")

/obj/structure/toilet/bluespace/attack_hand(mob/living/user)
	. = ..()
	if(open)
		// Teleport user
		to_chat(user, span_warning("Вы чувствуете, что куда-то перемещаетесь..."))
		if(do_after(user, 5 SECONDS, target = src))
			playsound(src, teleport_sound, 100, vary = TRUE)
			do_teleport(user, user, 7)
			investigate_log("teleported [key_name_log(user)] to [COORD(user)]", INVESTIGATE_TELEPORTATION)

/obj/structure/toilet/bluespace/Destroy()

	// Teleport all the mobs that were nearby
	playsound(src, teleport_sound, 100, vary = TRUE)
	for(var/mob/living/mob in range(7, src))
		do_teleport(mob, mob, 7)
		investigate_log("teleported [key_name_log(mob)] to [COORD(mob)]", INVESTIGATE_TELEPORTATION)

	return ..()

/obj/structure/toilet/bluespace/nt
	icon_state = "bluespace_toilet00-NT"

/obj/structure/toilet/bluespace/nt/update_icon()
	. = ..()
	icon_state = "bluespace_toilet[open][cistern]-NT"

/obj/effect/spawner/lootdrop/bluespace_rift
	name = "brs loot"
	lootcount = 1
	loot = list(
		//Item type, weight
		/obj/item/stack/ore/bluespace_crystal = 100,
		/obj/item/stack/sheet/mineral/bananium/fifty = 60,
		/obj/item/stack/sheet/mineral/tranquillite/fifty = 60,
		/obj/item/stack/sheet/mineral/abductor/fifty = 30,
		/obj/item/clothing/under/psyjump = 10,
		/obj/item/storage/box/beakers/bluespace = 10,
		/obj/item/grown/bananapeel/bluespace = 10,
		/obj/item/seeds/random/labelled = 10,
		/obj/item/clothing/mask/cigarette/random = 5,
		/obj/item/soap/syndie = 20,
		/obj/item/toy/syndicateballoon = 5,
		/obj/item/stack/telecrystal = 1,

		//Toys
		/obj/item/gun/projectile/automatic/c20r/toy = 5,
		/obj/item/gun/projectile/automatic/l6_saw/toy = 5,
		/obj/item/gun/projectile/automatic/toy/pistol = 10,
		/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 5,
		/obj/item/gun/projectile/shotgun/toy = 5,
		/obj/item/gun/projectile/shotgun/toy/crossbow = 5,
		/obj/item/gun/projectile/shotgun/toy/tommygun = 5,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy = 5,
		/obj/item/twohanded/dualsaber/toy = 5,
		/obj/item/toy/katana = 5,
		/obj/item/fluff/rapid_wheelchair_kit = 50,
		/obj/vehicle/secway = 60,
		/obj/vehicle/atv = 30,
		/obj/vehicle/motorcycle = 20,
		/obj/vehicle/janicart = 15,
		/obj/vehicle/ambulance = 15,
		/obj/vehicle/snowmobile = 15,
		/obj/vehicle/space/speedbike/red = 10,
		/obj/vehicle/space/speedbike = 10,
		/obj/vehicle/car,
		/obj/random/figure = 30,
		/obj/random/mech = 25,
		/obj/random/plushie = 30,
		/obj/random/therapy = 25,
		/obj/random/carp_plushie = 25,

		//Toys that you most likely will never get and unnecessary small things
		/obj/item/toy/prizeball/mech,
		/obj/item/toy/prizeball/carp_plushie,
		/obj/item/toy/prizeball/plushie,
		/obj/item/toy/prizeball/figure,
		/obj/item/toy/prizeball/therapy,
		/obj/item/toy/balloon,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/blink,
		/obj/item/storage/box/dice,
		/obj/item/storage/box/snappops,
		/obj/item/deck/cards,
		/obj/item/storage/fancy/crayons,
		/obj/item/toy/eight_ball,
		/obj/item/storage/wallet/color,
		/obj/item/id_decal/prisoner,
		/obj/item/id_decal/silver,
		/obj/item/id_decal/gold,
		/obj/item/id_decal/centcom,
		/obj/item/id_decal/emag,
		/obj/item/toy/flash,
		/obj/item/toy/minimeteor,
		/obj/item/toy/minigibber,
		/obj/item/grenade/confetti,
		/obj/item/toy/AI,
		/obj/item/gun/projectile/revolver/capgun,
		/obj/item/toy/pet_rock,
		/obj/item/bikehorn/rubberducky,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/spellbook/oneuse/mime/fingergun/fake,
		/obj/item/grenade/clusterbuster/eng_tools,
		/obj/item/grenade/clusterbuster/tools,
		/obj/item/toy/eight_ball/conch,
		/obj/item/toy/foamblade,
		/obj/item/toy/redbutton,
		/obj/item/toy/nuke,
		/obj/item/clothing/head/blob,
		/obj/item/toy/codex_gigas,
		/obj/item/toy/sword,
		/obj/item/stack/tile/fakespace/loaded,
		/obj/item/stack/tile/arcade_carpet/loaded,
		/obj/item/twohanded/toy/chainsaw,
		/obj/item/toy/crayon/random,
		/obj/structure/toilet = 10,
		/obj/structure/toilet/secret = 5,
		/obj/structure/toilet/golden_toilet,
		/obj/structure/toilet/bluespace,


		//Not the most valuable items can still drop, albeit with a small chance of the sum of them all:
		/obj/item/reagent_containers/food/snacks/wingfangchu,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/sliceable/turkey,
		/obj/item/reagent_containers/food/snacks/appletart,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesecake,
		/obj/item/reagent_containers/food/snacks/sliceable/bananacake,
		/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake,
		/obj/item/reagent_containers/food/snacks/soup/meatballsoup,
		/obj/item/reagent_containers/food/snacks/soup/stew,
		/obj/item/reagent_containers/food/snacks/soup/hotchili,
		/obj/item/reagent_containers/food/snacks/burrito,
		/obj/item/reagent_containers/food/snacks/fishburger,
		/obj/item/reagent_containers/food/snacks/cubancarp,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/meatpie,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,
		/obj/item/reagent_containers/food/snacks/soup/mysterysoup,
		/obj/item/reagent_containers/food/snacks/sliceable/bread/xeno,
		/obj/item/clothing/head/collectable/chef,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/captain,
		/obj/item/clothing/head/collectable/beret,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/collectable/flatcap,
		/obj/item/clothing/head/collectable/pirate,
		/obj/item/clothing/head/collectable/kitty,
		/obj/item/clothing/head/crown/fancy,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/HoS,
		/obj/item/clothing/head/collectable/thunderdome,
		/obj/item/clothing/head/collectable/swat,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/police,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/xenom,
		/obj/item/clothing/head/collectable/petehat,

		//Bluespace magic items with the lowest chance to spawn
		/obj/item/spellbook/oneuse/fireball,
		/obj/item/spellbook/oneuse/smoke,
		/obj/item/spellbook/oneuse/blind,
		/obj/item/spellbook/oneuse/forcewall,
		/obj/item/spellbook/oneuse/knock,
		/obj/item/spellbook/oneuse/charge,
		/obj/item/spellbook/oneuse/summonitem,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/spellbook/oneuse/sacredflame,
		/obj/item/spellbook/oneuse/mime,
		/obj/item/spellbook/oneuse/mime/fingergun,
		/obj/item/spellbook/oneuse/mime/greaterwall,
		/obj/item/spellbook/oneuse/mime/fingergun/fake,
		/obj/structure/closet/crate/necropolis/tendril,

		//Babki, babki, suka, babki!
		/obj/item/stack/spacecash/c1000000 = 1,
		/obj/item/stack/spacecash/c1000 = 5,
		/obj/item/stack/spacecash/c500 = 10,
		/obj/item/stack/spacecash/c200 = 15,
		/obj/item/stack/spacecash/c100 = 20,
		/obj/item/stack/spacecash/c50 = 20,
		/obj/item/stack/spacecash/c20 = 20,
		/obj/item/stack/spacecash/c10 = 20,
		/obj/item/storage/bag/cash = 10,
		/obj/item/storage/secure/briefcase/syndie = 30,
	)

/obj/effect/spawner/lootdrop/bluespace_rift/New()
	playsound(loc, 'sound/magic/blink.ogg', 50)
	do_sparks(2, FALSE, loc)
	if(!locate(/obj/effect/portal) in get_turf(loc))
		new /obj/effect/portal(loc, null, null, 4 SECONDS)
	return ..()

/obj/effect/spawner/lootdrop/bluespace_rift/goal_complete
	lootcount = 2
	lootdoubles = FALSE
	loot = list(
		/obj/structure/toilet/bluespace/nt,
		/obj/item/paper/researchnotes_brs,
	)
