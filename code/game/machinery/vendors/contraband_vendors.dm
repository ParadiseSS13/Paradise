///Syndicate/Contraband Vendors

/obj/machinery/economy/vending/wallmed/syndicate
	name = "\improper SyndiMed Plus"
	desc = "<b>EVIL</b> wall-mounted Medical Equipment dispenser."
	icon_state = "syndimed"
	icon_deny = "syndimed_deny"
	ads_list = list("Go end some lives!", "The best stuff for your ship.", "Only the finest tools.", "Natural chemicals!", "This stuff saves lives.", "Don't you want some?", "Ping!")
	req_access_txt = "150"
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/reagent_containers/hypospray/autoinjector = 4,/obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4,/obj/item/reagent_containers/syringe/antiviral = 4,/obj/item/reagent_containers/food/pill/tox = 1)

/obj/machinery/economy/vending/syndicigs
	name = "\improper Suspicious Cigarette Machine"
	desc = "Smoke 'em if you've got 'em."
	slogan_list = list("Space cigs taste good like a cigarette should.", "I'd rather toolbox than switch.", "Smoke!", "Don't believe the reports - smoke today!")
	ads_list = list("Probably not bad for you!", "Don't believe the scientists!", "It's good for you!", "Don't quit, buy more!", "Smoke!", "Nicotine heaven.", "Best cigarettes since 2150.", "Award-winning cigs.")
	vend_delay = 34
	icon_state = "cigs"
	icon_lightmask = "cigs"
	products = list(/obj/item/storage/fancy/cigarettes/syndicate = 10, /obj/item/lighter/random = 5)

/obj/machinery/economy/vending/syndisnack
	name = "\improper Getmore Chocolate Corp"
	desc = "A modified snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	slogan_list = list("Try our new nougat bar!", "Twice the calories for half the price!")
	ads_list = list("The healthiest!", "Award-winning chocolate bars!", "Mmm! So good!", "Oh my god it's so juicy!", "Have a snack.", "Snacks are good for you!", "Have some more Getmore!", "Best quality snacks straight from mars.", "We love chocolate!", "Try our new jerky!")
	icon_state = "snack"
	icon_lightmask = "nutri"
	icon_off = "nutri"
	icon_panel = "thin_vendor"
	products = list(/obj/item/reagent_containers/food/snacks/chips = 6,/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/syndicake = 6, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 6)

/obj/machinery/economy/vending/hydroseeds/syndicate_druglab
	products = list(/obj/item/seeds/ambrosia/deus = 2,
					/obj/item/seeds/cannabis = 2,
					/obj/item/seeds/coffee = 3,
					/obj/item/seeds/liberty = 2,
					/obj/item/seeds/cannabis/rainbow = 1,
					/obj/item/seeds/reishi = 2,
					/obj/item/seeds/tobacco = 1)
	contraband = list()
	refill_canister = null

/obj/machinery/economy/vending/hydronutrients/syndicate_druglab
	products = list(/obj/item/reagent_containers/glass/bottle/nutrient/ez = 12,
					/obj/item/reagent_containers/glass/bottle/nutrient/l4z = 2,
					/obj/item/reagent_containers/glass/bottle/nutrient/rh = 3,
					/obj/item/reagent_containers/spray/pestspray = 7,
					/obj/item/reagent_containers/syringe = 11,
					/obj/item/storage/bag/plants = 2,
					/obj/item/cultivator = 3,
					/obj/item/shovel/spade = 2,
					/obj/item/plant_analyzer = 2,
					/obj/item/reagent_containers/glass/bottle/ammonia = 6,
					/obj/item/reagent_containers/glass/bottle/diethylamine = 8)
	contraband = list()

/obj/machinery/economy/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."
	icon_state = "liberationstation"
	icon_lightmask = "liberationstation"
	req_access_txt = "1"
	slogan_list = list("Liberation Station: Your one-stop shop for all things second amendment!", "Be a patriot today, pick up a gun!", "Quality weapons for cheap prices!", "Better dead than red!")
	ads_list = list("Float like an astronaut, sting like a bullet!", "Express your second amendment today!", "Guns don't kill people, but you can!", "Who needs responsibilities when you have guns?")
	vend_reply = "Remember the name: Liberation Station!"
	products = list(/obj/item/gun/projectile/automatic/pistol/deagle/gold = 2,
					/obj/item/gun/projectile/automatic/pistol/deagle/camo = 2,
					/obj/item/gun/projectile/automatic/pistol/m1911 = 2,
					/obj/item/gun/projectile/automatic/proto = 2,
					/obj/item/gun/projectile/shotgun/automatic/combat = 2,
					/obj/item/gun/projectile/automatic/gyropistol = 1,
					/obj/item/gun/projectile/shotgun = 2,
					/obj/item/gun/projectile/automatic/ar = 2,
					/obj/item/gun/projectile/automatic/ak814 = 2,
					/obj/item/ammo_box/magazine/smgm9mm = 2,
					/obj/item/ammo_box/magazine/m50 = 4,
					/obj/item/ammo_box/magazine/m45 = 2,
					/obj/item/ammo_box/magazine/m75 = 2,
					/obj/item/ammo_box/magazine/m556/arg = 2,
					/obj/item/ammo_box/magazine/ak814 = 2)
	contraband = list(/obj/item/clothing/under/costume/patriotsuit = 1, /obj/item/bedsheet/patriot = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/economy/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"
	icon_state = "syndi"
	icon_lightmask = "syndi"
	slogan_list = list("Get your cool toys today!", "Trigger a valid hunter today!", "Quality toy weapons for cheap prices!", "Give them to HoPs for all access!", "Give them to HoS to get permabrigged!")
	ads_list = list("Feel robust with your toys!", "Express your inner child today!", "Toy weapons don't kill people, but valid hunters do!", "Who needs responsibilities when you have toy weapons?", "Make your next murder FUN!")
	vend_reply = "Come back for more!"
	products = list(/obj/item/gun/projectile/automatic/toy = 10,
					/obj/item/gun/projectile/automatic/toy/pistol= 10,
					/obj/item/gun/projectile/shotgun/toy = 10,
					/obj/item/toy/sword = 10,
					/obj/item/ammo_box/foambox = 20,
					/obj/item/toy/foamblade = 10,
					/obj/item/toy/syndicateballoon = 10,
					/obj/item/clothing/suit/syndicatefake = 5,
					/obj/item/clothing/head/syndicatefake = 5) //OPS IN DORMS oh wait it's just an assistant
	contraband = list(/obj/item/gun/projectile/shotgun/toy/crossbow = 10,   //Congrats, you unlocked the +18 setting!
					/obj/item/gun/projectile/automatic/c20r/toy/riot = 10,
					/obj/item/gun/projectile/automatic/l6_saw/toy/riot = 10,
					/obj/item/gun/projectile/automatic/sniper_rifle/toy = 10,
					/obj/item/ammo_box/foambox/riot = 20,
					/obj/item/toy/katana = 10,
					/obj/item/dualsaber/toy = 5,
					/obj/item/deck/cards/syndicate = 10) //Gambling and it hurts, making it a +18 item
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
