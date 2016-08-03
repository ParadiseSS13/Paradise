
/obj/item/weapon/reagent_containers/borghypo
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
	var/list/reagent_ids = list("salglu_solution", "epinephrine", "spaceacillin", "charcoal")
	//var/list/reagent_ids = list("salbutamol", "silver_sulfadiazine", "styptic_powder", "charcoal", "epinephrine", "spaceacillin")

/obj/item/weapon/reagent_containers/borghypo/surgeon
	reagent_ids = list("styptic_powder", "epinephrine", "salbutamol")

/obj/item/weapon/reagent_containers/borghypo/crisis
	reagent_ids = list("salglu_solution", "epinephrine", "sal_acid")

/obj/item/weapon/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and morphine, for offense."
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2
	reagent_ids = list("syndicate_nanites", "potass_iodide", "ether")
	bypass_protection = 1

/obj/item/weapon/reagent_containers/borghypo/New()
	..()
	for(var/R in reagent_ids)
		add_reagent(R)

	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/borghypo/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0

	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/datum/reagents/RG = reagent_list[mode]
			if(RG.total_volume < RG.maximum_volume) 	//Don't recharge reagents and drain power if the storage is full.
				R.cell.use(charge_cost) 					//Take power from borg...
				RG.add_reagent(reagent_ids[mode], 5)		//And fill hypo with reagent.
	//update_icon()
	return 1

// Use this to add more chemicals for the borghypo to produce.
/obj/item/weapon/reagent_containers/borghypo/proc/add_reagent(reagent)
	reagent_ids |= reagent
	var/datum/reagents/RG = new(30)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 30)

/obj/item/weapon/reagent_containers/borghypo/attack(mob/living/M, mob/user)
	var/datum/reagents/R = reagent_list[mode]
	if(!R.total_volume)
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	if(!istype(M))
		return
	if(R.total_volume && M.can_inject(user, 1, penetrate_thick = bypass_protection))
		to_chat(user, "<span class='notice'>You inject [M] with the injector.</span>")
		to_chat(M, "<span class='notice'>You feel a tiny prick!</span>")

		R.add_reagent(M)
		if(M.reagents)
			var/datum/reagent/injected = chemical_reagents_list[reagent_ids[mode]]
			var/contained = injected.name
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [key_name(user)]. Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [key_name(M)]. Reagents: [contained]</font>")
			if(M.ckey)
				msg_admin_attack("[key_name_admin(user)] injected [key_name_admin(M)] with [name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)])")
			M.LAssailant = user

			var/trans = R.trans_to(M, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>[trans] units injected. [R.total_volume] units remaining.</span>")
	return

/obj/item/weapon/reagent_containers/borghypo/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)		//Change the mode
	mode++
	if(mode > reagent_list.len)
		mode = 1

	charge_tick = 0 //Prevents wasted chems/cell charge if you're cycling through modes.
	var/datum/reagent/R = chemical_reagents_list[reagent_ids[mode]]
	to_chat(user, "<span class='notice'>Synthesizer is now producing '[R.name]'.</span>")
	return

/obj/item/weapon/reagent_containers/borghypo/examine(mob/user)
	if(!..(user, 2))
		return

	var/empty = 1

	for(var/datum/reagents/RS in reagent_list)
		var/datum/reagent/R = locate() in RS.reagent_list
		if(R)
			to_chat(user, "<span class='notice'>It currently has [R.volume] units of [R.name] stored.</span>")
			empty = 0

	if(empty)
		to_chat(user, "<span class='notice'>It is currently empty. Allow some time for the internal syntheszier to produce more.</span>")
