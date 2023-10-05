/obj/item/reagent_containers/food/snacks/rawcutlet/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/cutlet, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_patty/make_grillable()
	AddComponent(/datum/component/grillable, patty_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/rawcutlet/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/cutlet, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_bacon/make_grillable()
		AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/bacon, rand(25 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/make_grillable() //Add more steaks from different sources? Xeno, bear etc
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meatsteak, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/boiledspiderleg, rand(50 SECONDS, 60 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/monstermeat/goliath/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/goliath_steak, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/salmonmeat/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/salmonsteak, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/cookiedough/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/pancake, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_shrimp_skewer/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/shrimp_skewer, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_monkeykabob/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/monkeykabob, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_tofukabob/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/tofukabob, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_fish_skewer/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/fish_skewer, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_egg/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/friedegg, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_rofflewaffles/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/rofflewaffles, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/raw_waffles/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/waffles, rand(30 SECONDS, 50 SECONDS), TRUE, TRUE)
