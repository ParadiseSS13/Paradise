#define BORGHYPO_REFILL_VALUE 5

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)
	var/bypass_protection = 0 //If the hypospray can go through armor or thick material

	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"mannitol" = list('icons/obj/species_organs/grey.dmi', "brain2"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"spaceacillin" = list('icons/effects/effects.dmi', "greenglow"), \
		"charcoal" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"))


/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and hydrocodone, for field surgery and pain relief."
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2
	reagent_ids = list( \
		"syndicate_nanites" = list('icons/mob/swarmer.dmi', "swarmer_ranged"), \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"potass_iodide" = list('icons/obj/decals.dmi', "radiation"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"))
	bypass_protection = 1

/obj/item/reagent_containers/borghypo/upgraded
	name = "upgraded cyborg hypospray"
	desc = "An upgraded advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"mannitol" = list('icons/obj/species_organs/grey.dmi', "brain2"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"spaceacillin" = list('icons/effects/effects.dmi', "greenglow"), \
		"pen_acid" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"), \
		"perfluorodecalin" = list('icons/obj/surgery.dmi', "lungs"), \
		"calomel" = list('icons/obj/items.dmi', "soap"), \
		"oculine" = list('icons/obj/surgery.dmi', "eyes"))


/obj/item/reagent_containers/borghypo/empty()
	set hidden = TRUE

/obj/item/reagent_containers/borghypo/New()
	..()
	for(var/R in reagent_ids)
		add_reagent(R)

	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return FALSE
	charge_tick = 0

	var/target_loc
	if (isrobot(loc))
		target_loc = loc
	else if (isrobot(loc.loc))
		target_loc = loc.loc
	else
		return TRUE

	var/mob/living/silicon/robot/R = target_loc
	if(R && R.cell)
		var/datum/reagents/RG = reagent_list[mode]
		if(!refill_borghypo(RG, reagent_ids[mode], R)) 	//If the storage is not full recharge reagents and drain power.
			for(var/i in 1 to reagent_list.len)     	//if active mode is full loop through the list and fill the first one that is not full
				RG = reagent_list[i]
				if(refill_borghypo(RG, reagent_ids[i], R))
					break
	//update_icon()
	return TRUE

// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/add_reagent(reagent)
	reagent_ids |= reagent
	var/datum/reagents/RG = new(30)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 30)

/obj/item/reagent_containers/borghypo/proc/refill_borghypo(datum/reagents/RG, reagent_id, mob/living/silicon/robot/R)
	if(RG.total_volume < RG.maximum_volume)
		RG.add_reagent(reagent_id, BORGHYPO_REFILL_VALUE)
		R.cell.use(charge_cost)
		return TRUE
	return FALSE

/obj/item/reagent_containers/borghypo/attack(mob/living/carbon/human/M, mob/user)
	var/datum/reagents/R = reagent_list[mode]
	if(!R.total_volume)
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	if(!istype(M))
		return
	if(R.total_volume && M.can_inject(user, TRUE, user.zone_selected, penetrate_thick = bypass_protection))
		to_chat(user, "<span class='notice'>You inject [M] with the injector.</span>")
		to_chat(M, "<span class='notice'>You feel a tiny prick!</span>")

		R.add_reagent(M)
		if(M.reagents)
			var/datum/reagent/injected = GLOB.chemical_reagents_list[reagent_ids[mode]]
			var/contained = injected.name
			var/trans = R.trans_to(M, amount_per_transfer_from_this)
			add_attack_logs(user, M, "Injected with [name] containing [contained], transfered [trans] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
			to_chat(user, "<span class='notice'>[trans] units injected. [R.total_volume] units remaining.</span>")

/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	radial_menu(user)

/obj/item/reagent_containers/borghypo/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/i in 1 to length(reagent_ids))
		choices[GLOB.chemical_reagents_list[reagent_ids[i]]] = image(icon = reagent_ids[reagent_ids[i]][1], icon_state = reagent_ids[reagent_ids[i]][2])
	var/choice = show_radial_menu(user, src, choices)
	if(!choice)
		return 0
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	mode = choices.Find(choice)

	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]
	amount_per_transfer_from_this  = (reagent_ids[mode] == "perfluorodecalin") ? 3 : 5
	to_chat(user, "<span class='notice'>Synthesizer is now producing '[R.name]'.</span>")

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		var/empty = TRUE

		for(var/datum/reagents/RS in reagent_list)
			var/datum/reagent/R = locate() in RS.reagent_list
			if(R)
				. += "<span class='notice'>It currently has [R.volume] units of [R.name] stored.</span>"
				empty = FALSE

		if(empty)
			. += "<span class='notice'>It is currently empty. Allow some time for the internal syntheszier to produce more.</span>"

/obj/item/reagent_containers/borghypo/basic
	name = "Basic Medical Hypospray"
	desc = "A very basic medical hypospray, capable of providing simple medical treatment in emergencies."
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"))

/obj/item/reagent_containers/borghypo/basic/upgraded
	name = "Upgraded Basic Medical Hypospray"
	desc = "Basic medical hypospray, capable of providing standart medical treatment."
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"charcoal" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"sal_acid" = list('icons/mob/actions/actions.dmi', "fleshmend"), \
		"salbutamol" = list('icons/obj/surgery.dmi', "lungs"))

#undef BORGHYPO_REFILL_VALUE
