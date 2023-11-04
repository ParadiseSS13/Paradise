/obj/item/envelope
	name = "broken letter"
	desc = "We just got a letter, we just got a letter, we just got a letter -- I wonder who it's from?"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_misc"
	item_state = "paper"
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'

	var/list/possible_contents = list()
	/// A list that contains the names of the jobs that can receive this type of letter. Only the base job has to be put in it, alternative titles have the same definition on the mind. Name of the job can be found in `mind.assigned_role`
	var/list/job_list = list()
	/// The real name required to open the letter
	var/recipient
	var/has_been_scanned = FALSE

/obj/item/envelope/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking a sharp corner of the envelope. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/-adminhelp.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/envelope/attack_self(mob/user)
	if(!user?.mind)
		return
	if(user.real_name != recipient)
		to_chat(user, "<span class='warning'>You don't want to open up another person's mail, that's an invasion of their privacy!</span>")
		return
	if(do_after(user, 1 SECONDS, target = user) && !QDELETED(src))
		to_chat(user, "<span class='notice'>You begin to open the envelope.</span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		user.unEquip(src)
		for(var/obj/item/I in contents)
			user.put_in_hands(I)
		qdel(src)

/obj/item/envelope/Initialize(mapload)
	. = ..()
	var/item = pick(possible_contents)
	new item(src)
	new /obj/item/stack/spacecash(src, rand(1, 50) * 5)
	var/list/mind_copy = shuffle(SSticker.minds)
	for(var/datum/mind/mail_attracted_people in mind_copy)
		var/turf/T = get_turf(mail_attracted_people.current)
		if(mail_attracted_people.offstation_role || !ishuman(mail_attracted_people.current) || is_admin_level(T.z))
			continue
		if(mail_attracted_people.assigned_role in job_list)
			recipient = mail_attracted_people.current.real_name
			name = "letter to [recipient]"
			return
	if(!admin_spawned)
		log_debug("Failed to find a new name to assign to [src]!")
		qdel(src)

/obj/item/envelope/security
	icon_state = "mail_sec"
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
							/obj/item/toy/figure/crew/secofficer,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Head of Security", "Security Officer", "Detective", "Warden")

/obj/item/envelope/science
	icon_state = "mail_sci"
	possible_contents = list(/obj/item/analyzer,
							/obj/item/assembly/signaler,
							/obj/item/slime_extract/grey,
							/obj/item/clothing/mask/gas,
							/obj/item/reagent_containers/spray/cleaner,
							/obj/item/clothing/glasses/regular,
							/obj/item/stack/ore/diamond, // Jackpot
							/obj/item/paicard,
							/obj/item/toy/figure/crew/borg,
							/obj/item/toy/figure/crew/geneticist,
							/obj/item/toy/figure/crew/rd,
							/obj/item/toy/figure/crew/roboticist,
							/obj/item/toy/figure/crew/scientist,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Research Director", "Roboticist", "Geneticist", "Scientist")

/obj/item/envelope/supply
	icon_state = "mail_sup"
	possible_contents = list(/obj/item/reagent_containers/hypospray/autoinjector/survival,
							/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,
							/obj/item/clothing/glasses/meson/gar,
							/obj/item/stack/marker_beacon/ten,
							/obj/item/stack/medical/splint,
							/obj/item/pen/multi/fountain,
							/obj/item/clothing/mask/cigarette/cigar,
							/obj/item/stack/wrapping_paper,
							/obj/item/toy/figure/crew/cargotech,
							/obj/item/toy/figure/crew/qm,
							/obj/item/toy/figure/crew/miner,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Quartermaster", "Cargo Technician", "Shaft Miner")

/obj/item/envelope/medical
	icon_state = "mail_med"
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
							/obj/item/toy/figure/crew/virologist,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Chief Medical Officer", "Medical Doctor", "Coroner", "Chemist", "Virologist", "Psychiatrist", "Paramedic")

/obj/item/envelope/engineering
	icon_state = "mail_eng"
	possible_contents = list(/obj/item/airlock_electronics,
							/obj/item/reagent_containers/food/drinks/cans/beer,
							/obj/item/reagent_containers/food/snacks/candy/confectionery/nougat,
							/obj/item/mod/module/storage/large_capacity,
							/obj/item/weldingtool/hugetank,
							/obj/item/geiger_counter,
							/obj/item/rcd_ammo,
							/obj/item/grenade/gas/oxygen,
							/obj/item/toy/figure/crew/atmos,
							/obj/item/toy/figure/crew/ce,
							/obj/item/toy/figure/crew/engineer,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Chief Engineer", "Station Engineer", "Life Support Specialist")

/obj/item/envelope/bread
	icon_state = "mail_serv"
	possible_contents = list(/obj/item/painter,
							/obj/item/gun/energy/floragun,
							/obj/item/reagent_containers/food/drinks/bottle/fernet,
							/obj/item/whetstone,
							/obj/item/soap/deluxe,
							/obj/item/stack/tile/disco_light/thirty,
							/obj/item/paicard,
							/obj/item/gun/projectile/automatic/toy/pistol,
							/obj/item/toy/figure/crew/bartender,
							/obj/item/toy/figure/crew/botanist,
							/obj/item/toy/figure/crew/chef,
							/obj/item/toy/figure/crew/janitor,
							/obj/item/toy/figure/crew/librarian,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Bartender", "Chef", "Botanist", "Janitor", "Barber", "Librarian", "Barber")

/obj/item/envelope/circuses
	icon_state = "mail_serv"
	possible_contents = list(/obj/item/painter,
							/obj/item/stack/sheet/mineral/tranquillite/ten,
							/obj/item/stack/sheet/mineral/bananium/ten,
							/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
							/obj/item/gun/throw/piecannon,
							/obj/item/ammo_box/shotgun/confetti,
							/obj/item/book/manual/wiki/sop_security, // They'll need this.
							/obj/item/soulstone/anybody/purified/chaplain,
							/obj/item/toy/figure/crew/clown,
							/obj/item/toy/figure/crew/hop,
							/obj/item/toy/figure/crew/chaplain,
							/obj/item/toy/figure/crew/mime,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Clown", "Mime", "Head of Personnel", "Chaplain")


/obj/item/envelope/command
	icon_state = "mail_com"
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
							/obj/item/toy/figure/crew/dsquad,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Captain", "Magistrate", "Nanotrasen Representative", "Blueshield", "Internal Affairs Agent")

/obj/item/envelope/misc
	possible_contents = list(/obj/item/clothing/under/misc/assistantformal,
							/obj/item/clothing/under/syndicate/tacticool,
							/obj/item/clothing/shoes/ducky,
							/obj/item/toy/plushie/orange_fox/grump, // A grumpy plushie for a grumpy tider
							/obj/item/multitool,
							/obj/item/instrument/piano_synth,
							/obj/item/toy/crayon/spraycan,
							/obj/item/clothing/head/cakehat,
							/obj/item/toy/figure/crew/assistant,
							/obj/item/toy/figure/owl,
							/obj/item/toy/figure/griffin,
							/obj/item/storage/box/scratch_cards)
	job_list = list("Assistant", "Explorer")


	/*//////////////////////\/
	\/	   \\		 //		\/
	\/	    \\      //		\/
	\/	     \\    //		\/
	\/	      \\  //		\/
	\/	       \\//			\/
	\/						\/
	\/		You've got:		\/
	\/	 	   Mail			\/
	\/						\/
	\/\\\\\\\\\\\\\\\\\\\\\\*/

/obj/item/mail_scanner
	name = "mail scanner"
	desc = "Sponsored by Messaging and Intergalactic Letters, this device allows you to log mail deliveries in exchange for financial compensation."
	force = 0
	throwforce = 0
	icon = 'icons/obj/device.dmi'
	icon_state = "mail_scanner"
	item_state = "mail_scanner"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=1"
	/// The reference to the envelope that is currently stored in the mail scanner. It will be cleared upon confirming a correct delivery
	var/obj/item/envelope/saved

/obj/item/mail_scanner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Scan a letter to log it into the active database, then scan the person you wish to hand the letter to. Correctly scanning the recipient of the letter logged into the active database will add credits to the Supply budget.</span>"

/obj/item/mail_scanner/attack()
	return

/obj/item/mail_scanner/afterattack(atom/A, mob/user)
	if(istype(A, /obj/item/envelope))
		var/obj/item/envelope/envelope = A
		if(envelope.has_been_scanned)
			to_chat(user, "<span class='warning'>This letter has already been logged to the active database!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, TRUE)
			return
		to_chat(user, "<span class='notice'>You add [envelope] to the active database.</span>")
		playsound(loc, 'sound/mail/mailscanned.ogg', 50, TRUE)
		saved = A
		SSblackbox.record_feedback("amount", "successful_mail_scan", 1)
		return
	if(isliving(A))
		var/mob/living/M = A
		if(!saved)
			to_chat(user, "<span class='warning'>Error: You have not logged mail to the mail scanner!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, TRUE)
			return

		if(M.stat == DEAD)
			to_chat(user, "<span class='warning'>Consent Verification failed: You can't deliver mail to a corpse!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, TRUE)
			return

		if(M.real_name != saved.recipient)
			to_chat(user, "<span class='warning'>'Identity Verification failed: Target is not an authorized recipient of this package!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, TRUE)
			return

		if(!M.client)
			to_chat(user, "<span class='warning'>Consent Verification failed: The scanner will not accept confirmation of orders from SSD people!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, TRUE)
			return

		saved.has_been_scanned = TRUE
		saved = null
		to_chat(user, "<span class='notice'>Successful delivery acknowledged! [MAIL_DELIVERY_BONUS] credits added to Supply account!</span>")
		playsound(loc, 'sound/mail/mailapproved.ogg', 50, TRUE)
		GLOB.station_money_database.credit_account(SSeconomy.cargo_account, MAIL_DELIVERY_BONUS, "Mail Delivery Compensation", "Messaging and Intergalactic Letters", supress_log = FALSE)
		SSblackbox.record_feedback("amount", "successful_mail_delivery", 1)
