#define BORGHYPO_REFILL_VALUE 10

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	item_state = "hypo"
	icon = 'icons/obj/hypo.dmi'
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	/// It doesn't matter what reagent is used in the autohypos, so we don't!
	var/total_reagents = 50
	/// Maximum reagents that the base autohypo can store
	var/maximum_reagents = 50
	var/charge_cost = 50
	/// Used for delay with the recharge time, each charge tick is worth 2 seconds of real time
	var/charge_tick = 0
	/// How many SSobj ticks it takes for the reagents to recharge by 10 units
	var/recharge_time = 3
	/// Can the autohypo inject through thick materials?
	var/bypass_protection = 0
	var/choosen_reagent = "salglu_solution"
	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list("salglu_solution", "epinephrine", "spaceacillin", "charcoal", "hydrocodone", "mannitol", "salbutamol")
	var/list/reagent_ids_emagged = list("tirizene")
	var/static/list/reagent_icons = list("salglu_solution" = image(icon = 'icons/goonstation/objects/iv.dmi', icon_state = "ivbag"),
							"epinephrine" = image(icon = 'icons/obj/hypo.dmi', icon_state = "autoinjector"),
							"spaceacillin" = image(icon = 'icons/obj/decals.dmi', icon_state = "bio"),
							"charcoal" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill17"),
							"hydrocodone" = image(icon = 'icons/obj/chemical.dmi', icon_state = "bottle19"),
							"styptic_powder" = image(icon = 'icons/obj/chemical.dmi', icon_state = "bandaid_brute"),
							"salbutamol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill8"),
							"sal_acid" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill4"),
							"syndicate_nanites" = image(icon = 'icons/obj/decals.dmi', icon_state = "greencross"),
							"potass_iodide" = image(icon = 'icons/obj/decals.dmi', icon_state = "radiation"),
							"mannitol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill19"),
							"salbutamol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill8"),
							"corazone" = image(icon = 'icons/obj/abductor.dmi', icon_state = "bed"),
							"tirizene" = image(icon = 'icons/obj/aibots.dmi', icon_state = "pancbot"))

/obj/item/reagent_containers/borghypo/surgeon
	reagent_ids = list("styptic_powder", "epinephrine", "salbutamol")
	total_reagents = 60
	maximum_reagents = 60

/obj/item/reagent_containers/borghypo/crisis
	reagent_ids = list("salglu_solution", "epinephrine", "sal_acid")
	total_reagents = 60
	maximum_reagents = 60

/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and hydrocodone, for field surgery and pain relief."
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2 // No time to recharge
	reagent_ids = list("syndicate_nanites", "potass_iodide", "hydrocodone")
	total_reagents = 30
	maximum_reagents = 30
	bypass_protection = TRUE
	choosen_reagent = "syndicate_nanites"

/obj/item/reagent_containers/borghypo/abductor
	charge_cost = 40
	recharge_time = 3
	reagent_ids = list("salglu_solution", "epinephrine", "hydrocodone", "spaceacillin", "charcoal", "mannitol", "salbutamol", "corazone")
	bypass_protection = 1

/obj/item/reagent_containers/borghypo/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return FALSE
	charge_tick = 0
	refill_borghypo()
	return TRUE

// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/refill_borghypo(reagent_id, mob/living/silicon/robot/robot)
	if(istype(robot))
		robot.cell.use(charge_cost)
	total_reagents = min((total_reagents + BORGHYPO_REFILL_VALUE), maximum_reagents)

/obj/item/reagent_containers/borghypo/attack(mob/living/carbon/human/M, mob/user)
	if(!total_reagents)
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	if(!istype(M))
		return
	if(total_reagents && M.can_inject(user, TRUE, user.zone_selected, penetrate_thick = bypass_protection))
		to_chat(user, "<span class='notice'>You inject [M] with the injector.</span>")
		to_chat(M, "<span class='notice'>You feel a tiny prick!</span>")

		M.reagents.add_reagent(choosen_reagent, 5)
		total_reagents = (total_reagents - 5)
		if(M.reagents)
			var/datum/reagent/injected = GLOB.chemical_reagents_list[choosen_reagent]
			var/contained = injected.name
			add_attack_logs(user, M, "Injected with [name] containing [contained], transfered [5] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
			to_chat(user, "<span class='notice'>[5] units injected. [total_reagents] units remaining.</span>")

/obj/item/reagent_containers/borghypo/proc/get_radial_contents()
	return reagent_icons & reagent_ids

/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	var/selected_reagent = show_radial_menu(user, src, get_radial_contents(), radius = 48)
	if(!selected_reagent)
		return
	charge_tick = 0 //Prevents wasted chems/cell charge if you're cycling through modes.
	var/datum/reagent/R = GLOB.chemical_reagents_list[selected_reagent]
	to_chat(user, "<span class='notice'>Synthesizer is now producing [R.name].</span>")
	choosen_reagent = selected_reagent

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	var/datum/reagent/get_reagent_name = GLOB.chemical_reagents_list[choosen_reagent]
	. |= "<span class='notice'>It is currently dispensing [get_reagent_name.name]. Contains [total_reagents] units of various reagents.</span>" // We couldn't care less what actual reagent is in the container, just if there IS reagent in it

/obj/item/reagent_containers/borghypo/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		reagent_ids += reagent_ids_emagged
		return
	emagged = FALSE
	reagent_ids -= reagent_ids_emagged

/obj/item/reagent_containers/borghypo/basic
	name = "Basic Medical Hypospray"
	desc = "A very basic medical hypospray, capable of providing simple medical treatment in emergencies."
	reagent_ids = list("salglu_solution", "epinephrine")
	total_reagents = 30
	maximum_reagents = 30

#undef BORGHYPO_REFILL_VALUE
