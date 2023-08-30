/obj/item/envelope
	name = "envelope"
	desc = "We just got a letter, we just got a letter, we just got a letter- wonder who its from."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_small"
	item_state = "paper"
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/list/possible_contents = list()

/obj/item/envelope/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking a sharp corner of the envelope. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/-adminhelp.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/envelope/attack_self(mob/user)
	if(do_after(user, 1 SECONDS, target = user) && !QDELETED(src))
		to_chat(user, "<span class='notice'>You begin to open the envelope.</span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
		for(var/obj/item/I in contents)
			user.put_in_hands(I)
		qdel(src)

/obj/item/envelope/Initialize(mapload)
	.=..()
	var/item = pick(possible_contents)
	new item(src)
	new /obj/item/stack/spacecash(src, rand(1, 50) * 5)

/obj/item/envelope/security
	possible_contents = list(/obj/item/reagent_containers/food/snacks/donut/sprinkles,
	/obj/item/megaphone,
	/obj/item/poster/random_official,
	/obj/item/restraints/handcuffs/pinkcuffs,
	/obj/item/restraints/legcuffs/bola/energy,
	/obj/item/reagent_containers/food/drinks/coffee,
	/obj/item/stock_parts/cell/super,
	/obj/item/grenade/barrier/dropwall,
	/obj/item/toy/figure/crew/detective,
	/obj/item/toy/figure/crew/hos,
	/obj/item/toy/figure/crew/secofficer)

/obj/item/envelope/science
	possible_contents = list(/obj/item/analyzer,
	/obj/item/assembly/signaler,
	/obj/item/slime_extract/grey,
	/obj/item/clothing/mask/gas,
	/obj/item/reagent_containers/spray/cleaner,
	/obj/item/clothing/glasses/regular,
	/obj/item/taperecorder,
	/obj/item/paicard,
	/obj/item/toy/figure/crew/borg,
	/obj/item/toy/figure/crew/geneticist,
	/obj/item/toy/figure/crew/rd,
	/obj/item/toy/figure/crew/roboticist,
	/obj/item/toy/figure/crew/scientist)

/obj/item/envelope/supply
	possible_contents = list(/obj/item/reagent_containers/hypospray/autoinjector/survival,
	/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,
	/obj/item/clothing/glasses/meson/gar,
	/obj/item/stack/marker_beacon/ten,
	/obj/item/clothing/mask/facehugger/toy,
	/obj/item/pen/multi/fountain,
	/obj/item/clothing/mask/cigarette/cigar,
	/obj/item/stack/wrapping_paper,
	/obj/item/toy/figure/crew/cargotech,
	/obj/item/toy/figure/crew/qm,
	/obj/item/toy/figure/crew/miner)

/obj/item/envelope/medical
	possible_contents = list(/obj/item/soap,
	/obj/item/reagent_containers/glass/bottle/morphine,
	/obj/item/reagent_containers/hypospray/safety,
	/obj/item/reagent_containers/applicator/brute,
	/obj/item/reagent_containers/applicator/burn,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/reagent_containers/food/snacks/fortunecookie,
	/obj/item/scalpel/laser/laser1,
	/obj/item/toy/figure/crew/cmo,
	/obj/item/toy/figure/crew/chemist,
	/obj/item/toy/figure/crew/geneticist,
	/obj/item/toy/figure/crew/md,
	/obj/item/toy/figure/crew/virologist)

/obj/item/envelope/engineering
	possible_contents = list(/obj/item/airlock_electronics,
	/obj/item/reagent_containers/food/drinks/cans/beer,
	/obj/item/reagent_containers/food/snacks/candy/confectionery/nougat,
	/obj/item/mod/module/tether,
	/obj/item/weldingtool/hugetank,
	/obj/item/geiger_counter,
	/obj/item/rcd_ammo,
	/obj/item/grenade/gas/oxygen,
	/obj/item/toy/figure/crew/atmos,
	/obj/item/toy/figure/crew/ce,
	/obj/item/toy/figure/crew/engineer)

/obj/item/envelope/service
	possible_contents = list(/obj/item/painter,
	/obj/item/twohanded/push_broom,
	/obj/item/gun/energy/floragun,
	/obj/item/reagent_containers/food/drinks/bottle/fernet,
	/obj/item/whetstone,
	/obj/item/reagent_containers/food/drinks/bottle/holywater,
	/obj/item/stack/ore/tranquillite,
	/obj/item/stack/ore/bananium,
	/obj/item/toy/figure/crew/bartender,
	/obj/item/toy/figure/crew/botanist,
	/obj/item/toy/figure/crew/chef,
	/obj/item/toy/figure/crew/clown,
	/obj/item/toy/figure/crew/hop,
	/obj/item/toy/figure/crew/chaplain,
	/obj/item/toy/figure/crew/janitor,
	/obj/item/toy/figure/crew/librarian,
	/obj/item/toy/figure/crew/mime)

/obj/item/envelope/command
	possible_contents = list(/obj/item/flash,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/poster/random_official,
	/obj/item/book/manual/wiki/sop_command,
	/obj/item/reagent_containers/food/pill/patch/synthflesh,
	/obj/item/paper_bin/nanotrasen,
	/obj/item/reagent_containers/food/snacks/spesslaw,
	/obj/item/clothing/head/collectable/petehat,
	/obj/item/toy/figure/crew/captain,
	/obj/item/toy/figure/crew/lawyer,
	/obj/item/toy/figure/crew/dsquad)

/obj/item/envelope/misc
	possible_contents = list(/obj/item/clothing/under/misc/assistantformal,
	/obj/item/clothing/under/syndicate/tacticool,
	/obj/item/clothing/shoes/ducky,
	/obj/item/toy/plushie/orange_fox/grump,
	/obj/item/multitool,
	/obj/item/instrument/piano_synth,
	/obj/item/toy/crayon/spraycan,
	/obj/item/clothing/head/cakehat,
	/obj/item/toy/figure/crew/assistant,
	/obj/item/toy/figure/owl,
	/obj/item/toy/figure/griffin)




// Hi you deleted mail crates by mistake.
