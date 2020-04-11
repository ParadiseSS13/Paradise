//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	var/code = null
	var/lastattempt = null
	var/attempts = 10
	var/codelen = 4
	integrity_failure = 0 //no breaking open the crate

/obj/structure/closet/crate/secure/loot/New()
	..()
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	code = ""
	for(var/i = 0, i < codelen, i++)
		var/dig = pick(digits)
		code += dig
		digits -= dig  //Player can enter codes with matching digits, but there are never matching digits in the answer

	var/loot = rand(1,100) //100 different crates with varying chances of spawning
	switch(loot)
		if(1 to 5) //5% chance
			new /obj/item/reagent_containers/food/drinks/bottle/rum(src)
			new /obj/item/reagent_containers/food/snacks/grown/ambrosia/deus(src)
			new /obj/item/reagent_containers/food/drinks/bottle/whiskey(src)
			new /obj/item/lighter(src)
		if(6 to 10)
			new /obj/item/bedsheet(src)
			new /obj/item/kitchen/knife(src)
			new /obj/item/wirecutters(src)
			new /obj/item/screwdriver(src)
			new /obj/item/weldingtool(src)
			new /obj/item/hatchet(src)
			new /obj/item/crowbar(src)
		if(11 to 15)
			new /obj/item/reagent_containers/glass/beaker/bluespace(src)
		if(16 to 20)
			new /obj/item/stack/ore/diamond(src, 10)
		if(21 to 25)
			for(var/i in 1 to 5)
				new /obj/item/poster/random_contraband(src)
		if(26 to 30)
			for(var/i in 1 to 3)
				new /obj/item/reagent_containers/glass/beaker/noreact(src)
		if(31 to 35)
			new /obj/item/seeds/firelemon(src)
		if(36 to 40)
			new /obj/item/melee/baton(src)
		if(41 to 45)
			new /obj/item/clothing/under/shorts/red(src)
			new /obj/item/clothing/under/shorts/blue(src)
		if(46 to 50)
			new /obj/item/clothing/under/chameleon(src)
			for(var/i in 1 to 7)
				new /obj/item/clothing/accessory/horrible(src)
		if(51 to 52) // 2% chance
			new /obj/item/melee/classic_baton(src)
		if(53 to 54)
			new /obj/item/toy/balloon(src)
		if(55 to 56)
			var/newitem = pick(subtypesof(/obj/item/toy/prize))
			new newitem(src)
		if(57 to 58)
			new /obj/item/toy/syndicateballoon(src)
		if(59 to 60)
			new /obj/item/borg/upgrade/modkit/aoe/mobs(src)
			new /obj/item/clothing/suit/space(src)
			new /obj/item/clothing/head/helmet/space(src)
		if(61 to 62)
			for(var/i in 1 to 5)
				new /obj/item/clothing/head/kitty(src)
				new /obj/item/clothing/accessory/petcollar(src)
		if(63 to 64)
			for(var/i in 1 to rand(4, 7))
				var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
				new newcoin(src)
		if(65 to 66)
			new /obj/item/clothing/suit/ianshirt(src)
			new /obj/item/clothing/suit/corgisuit(src)
			new /obj/item/clothing/head/corgi(src)
		if(67 to 68)
			for(var/i in 1 to rand(4, 7))
				var /newitem = pick(subtypesof(/obj/item/stock_parts) - /obj/item/stock_parts/subspace)
				new newitem(src)
		if(69 to 70)
			new /obj/item/stack/ore/bluespace_crystal(src, 5)
		if(71 to 72)
			new /obj/item/pickaxe/drill(src)
		if(73 to 74)
			new /obj/item/pickaxe/drill/jackhammer(src)
		if(75 to 76)
			new /obj/item/pickaxe/diamond(src)
		if(77 to 78)
			new /obj/item/pickaxe/drill/diamonddrill(src)
		if(79 to 80)
			new /obj/item/cane(src)
			new /obj/item/clothing/head/collectable/tophat(src)
		if(81 to 82)
			new /obj/item/gun/energy/plasmacutter(src)
		if(83 to 84)
			new /obj/item/toy/katana(src)
		if(85 to 86)
			new /obj/item/defibrillator/compact(src)
		if(87) //1% chance
			new /obj/item/weed_extract(src)
		if(88)
			new /obj/item/organ/internal/brain(src)
		if(89)
			new /obj/item/organ/internal/brain/xeno(src)
		if(90)
			new /obj/item/organ/internal/heart(src)
		if(91)
			new /obj/item/soulstone/anybody(src)
		if(92)
			new /obj/item/katana(src)
		if(93)
			new /obj/item/dnainjector/xraymut(src)
		if(94)
			new /obj/item/storage/backpack/clown(src)
			new /obj/item/clothing/under/rank/clown(src)
			new /obj/item/clothing/shoes/clown_shoes(src)
			new /obj/item/pda/clown(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/bikehorn(src)
			new /obj/item/toy/crayon/rainbow(src)
			new /obj/item/reagent_containers/spray/waterflower(src)
			new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(src)
		if(95)
			new /obj/item/clothing/under/mime(src)
			new /obj/item/clothing/shoes/black(src)
			new /obj/item/pda/mime(src)
			new /obj/item/clothing/gloves/color/white(src)
			new /obj/item/clothing/mask/gas/mime(src)
			new /obj/item/clothing/head/beret(src)
			new /obj/item/clothing/suit/suspenders(src)
			new /obj/item/toy/crayon/mime(src)
			new /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing(src)
		if(96)
			new /obj/item/hand_tele(src)
		if(97)
			new /obj/item/clothing/mask/balaclava
			new /obj/item/gun/projectile/automatic/pistol(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
		if(98)
			new /obj/item/katana/cursed(src)
		if(99)
			new /obj/item/storage/belt/champion(src)
			new /obj/item/clothing/mask/luchador(src)
		if(100)
			new /obj/item/clothing/head/bearpelt(src)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	if(locked)
		to_chat(user, "<span class='notice'>The crate is locked with a Deca-code lock.</span>")
		var/input = clean_input("Enter [codelen] digits.", "Deca-Code Lock", "")
		if(in_range(src, user))
			if(input == code)
				to_chat(user, "<span class='notice'>The crate unlocks!</span>")
				locked = 0
				overlays.Cut()
				overlays += "securecrateg"
			else if(input == null || length(input) != codelen)
				to_chat(user, "<span class='notice'>You leave the crate alone.</span>")
			else
				to_chat(user, "<span class='warning'>A red light flashes.</span>")
				lastattempt = input
				attempts--
				if(attempts == 0)
					boom(user)
	else
		return ..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/card/emag))
			boom(user)
			return 1
		if(istype(W, /obj/item/multitool))
			to_chat(user, "<span class='notice'>DECA-CODE LOCK REPORT:</span>")
			if(attempts == 1)
				to_chat(user, "<span class='warning'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>")
			else
				to_chat(user, "<span class='notice'>* Anti-Tamper Bomb will activate after [attempts] failed access attempts.</span>")
			if(lastattempt != null)
				var/bulls = 0
				var/cows = 0
				var/list/banned = list()
				for(var/i in 1 to codelen)
					var/list/a = copytext(lastattempt, i, i + 1)
					if(a in banned)
						continue
					var/g = findtext(code, a)
					if(g)
						banned += a
						if(g == i)
							++bulls
						else
							++cows

				to_chat(user, "<span class='notice'>Last code attempt had [bulls] correct digits at correct positions and [cows] correct digits at incorrect positions.</span>")
			return 1
	return ..()

/obj/structure/closet/crate/secure/loot/emag_act(mob/user)
	if(locked)
		boom(user)

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	if(locked)
		boom(user)
	else
		..()

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled = TRUE)
	boom()
