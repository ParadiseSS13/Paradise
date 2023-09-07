/obj/item/envelope
	name ="broken letter"
	desc = "We just got a letter, we just got a letter, we just got a letter- wonder who its from."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_misc"
	item_state = "paper"
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/list/possible_contents = list()
	var/list/job_list = list()
	var/mob/living/recipient
	var/has_been_scanned = FALSE

/obj/item/envelope/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking a sharp corner of the envelope. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/-adminhelp.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/envelope/attack_self(mob/user)
	if(user != recipient)
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
	.=..()
	var/item = pick(possible_contents)
	new item(src)
	new /obj/item/stack/spacecash(src, rand(1, 50) * 5)
	var/list/mind_copy = SSticker.minds.Copy()
	shuffle(mind_copy)
	for(var/datum/mind/mail_attracted_people in mind_copy)
		if(mail_attracted_people.offstation_role || mail_attracted_people.assigned_role == ("AI" || "Cyborg"))
			continue
		if(mail_attracted_people.assigned_role in job_list)
			recipient = mail_attracted_people.current
			name = "letter to [recipient]"
			return
	if(!admin_spawned)
		log_debug("Error: failed to find a new name to assign to [src]!")
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
	/obj/item/toy/figure/crew/secofficer)
	job_list = list("Head of Security", "Security Officer", "Detective", "Forensic Technician", "Warden")

/obj/item/envelope/science
	icon_state = "mail_sci"
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
	job_list = list("Research Director", "Roboticist", "Biomechanical Engineer", "Geneticist", "Mechatronic Engineer", "Scientist", "Xenoarcheologist", "Annomalist", "Plasma Researcher", "Xenobiologist", "Chemical Researcher")

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
	/obj/item/toy/figure/crew/miner)
	job_list = list("Quartermaster", "Cargo Technician", "Mail Carrier", "Courier", "Shaft Miner", "Spelunker")

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
	/obj/item/toy/figure/crew/virologist)
	job_list = list("Chief Medical Officer", "Medical Doctor", "Surgeon", "Nurse", "Coroner", "Chemist", "Pharmacist", "Pharmacologist", "Virologist", "Pathologist", "Microbiologist", "Psychiatrist", "Psychologist", "Therapist", "Paramedic")

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
	/obj/item/toy/figure/crew/engineer)
	job_list = list("Chief Engineer", "Station Engineer", "Engine Technician", "Electrician", "Life Support Specialist", "Atmospheric Technician")

/obj/item/envelope/service
	icon_state = "mail_serv"
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
	job_list = list("Head of Personnel", "Bartender", "Chef", "Cook", "Culinary Artist", "Butcher", "Botanist", "Hydroponicist", "Botanical Researcher", "Clown", "Mime", "Janitor", "Custodial Technician", "Librarian", "Journalist", "Barber")

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
	/obj/item/toy/figure/crew/dsquad)
	job_list = list("Captain", "Magistrate", "NanoTrasen Representative", "Blueshield", "Internal Affairs Agent", "Human Resources Agent")

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
	job_list = list("Assistant", "Explorer")

/obj/item/mail_scanner
	name = "mail scanner"
	desc = "Confirms deliveries of mail with clients."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "autopsy_scanner"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=1"
	var/obj/item/envelope/saved


/obj/item/mail_scanner/attack()
	return

/obj/item/mail_scanner/afterattack(atom/A, mob/user)
	if(istype(A, /obj/item/envelope))
		var/obj/item/envelope/O = A
		if(O.has_been_scanned)
			to_chat(user, "<span class='warning'>This letter has already been logged to the active database!</span>")
			playsound(loc, 'sound/machines/deniedbeep.ogg', 50, 1)
			return
		to_chat(user, "<span class='notice'>You add [src] to the active database.</span>")
		playsound(loc, 'sound/mail/mailscanned.ogg', 50, 1)
		saved = A
		return
	if(isliving(A))
		var/mob/living/M = A
		if(!saved)
			to_chat(user, "<span class='warning'>You have not logged mail to the mail scanner!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, 1)
			return
		if(M.stat == DEAD)
			to_chat(user, "<span class='warning'>You can't deliver mail to a corpse!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, 1)
			return

		if(M != saved.recipient)
			to_chat(user, "<span class='warning'>The scanner will not accept confirmation of orders from non clients!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, 1)
			return
		if(!M.client)
			to_chat(user, "<span class='warning'>The scanner will not accept confirmation of orders from SSD people!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 50, 1)
			return
		saved.has_been_scanned = TRUE
		saved = null
		to_chat(user, "<span class='notice'>Succesful delivery acknowledged! 100 credits added to Supply account!</span>")
		playsound(loc, 'sound/mail/mailapproved.ogg', 50, 1)
		GLOB.station_money_database.credit_account(SSeconomy.cargo_account, MAIL_DELIVERY_BONUS, "Mail Delivery Compensation", "Messaging and Intergalactic Letters", supress_log = FALSE)

