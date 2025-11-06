#define BORGHYPO_REFILL_VALUE 10

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "borghypo"
	possible_transfer_amounts = list(1, 2, 3, 4, 5, 10, 15, 20, 25, 30)
	volume = 50
	/// Cyborg that our module is attached to
	var/mob/living/silicon/robot/cyborg
	/// Amount of charge that we will deduct from cell on each successful `refill_hypo()`
	var/charge_cost = 50
	/// Delay in ticks we apply before refilling our hypo
	var/refill_delay = 2
	/// Tracking for how long we didn't make a refill. Refills on every (charge_tick > refill_delay) tick
	var/charge_tick = 0
	/// Can the autohypo inject through thick materials?
	var/penetrate_thick = FALSE
	/// if true - will play a sound on use
	var/play_sound = TRUE
	/// reagent that we will transfer on hypo use
	var/reagent_selected = "salglu_solution"
	/// reagents that we are able to dispense
	var/list/reagent_ids = list("salglu_solution", "epinephrine", "spaceacillin", "charcoal", "hydrocodone", "mannitol", "salbutamol")
	/// reagents that we will be able to dispense when someone emaggs us
	var/list/reagent_ids_emagged = list("tirizene")
	var/static/list/reagent_icons = list("salglu_solution" = image(icon = 'icons/goonstation/objects/iv.dmi', icon_state = "ivbag"),
							"epinephrine" = image(icon = 'icons/obj/hypo.dmi', icon_state = "autoinjector"),
							"spaceacillin" = image(icon = 'icons/obj/decals.dmi', icon_state = "bio"),
							"charcoal" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill17"),
							"hydrocodone" = image(icon = 'icons/obj/chemical.dmi', icon_state = "bottle19"),
							"styptic_powder" = image(icon = 'icons/obj/chemical.dmi', icon_state = "bandaid2"),
							"salbutamol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill8"),
							"sal_acid" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill4"),
							"syndicate_nanites" = image(icon = 'icons/obj/decals.dmi', icon_state = "greencross"),
							"potass_iodide" = image(icon = 'icons/obj/decals.dmi', icon_state = "radiation"),
							"mannitol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill19"),
							"salbutamol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill8"),
							"corazone" = image(icon = 'icons/obj/abductor.dmi', icon_state = "bed"),
							"tirizene" = image(icon = 'icons/obj/aibots.dmi', icon_state = "pancbot"))

/obj/item/reagent_containers/borghypo/Initialize(mapload)
	. = ..()
	cyborg = loc.loc // yeah..
	refill_hypo(quick = TRUE) // start with a full hypo

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	cyborg = null
	return ..()

/obj/item/reagent_containers/borghypo/process()
	if(!should_refill()) // no need to refill
		STOP_PROCESSING(SSobj, src)
		return
	if(!refill_delay) // no delay, refill it now
		refill_hypo(cyborg)
		return
	if(charge_tick < refill_delay) // not ready to refill
		charge_tick++
	else // ready to refill
		refill_hypo(cyborg)

// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/refill_hypo(mob/living/silicon/robot/user, quick = FALSE)
	if(quick) // gives us a hypo full of reagents no matter what
		for(var/reagent as anything in reagent_ids)
			if(reagent_ids[reagent] < volume)
				reagent_ids[reagent] = volume
		return
	if(istype(user) && user.cell && user.cell.use(charge_cost)) // we are a robot, we have a cell and enough charge? let's refill now
		if(charge_tick)
			charge_tick = 0
		for(var/reagent as anything in reagent_ids)
			if(reagent_ids[reagent] < volume)
				var/reagents_to_add = min(volume - reagent_ids[reagent], BORGHYPO_REFILL_VALUE)
				reagent_ids[reagent] = (reagent_ids[reagent] || 0) + reagents_to_add // in case if it's null somehow, set it to 0

// whether our hypo's reagents are at max volume or not
/obj/item/reagent_containers/borghypo/proc/should_refill()
	for(var/reagent as anything in reagent_ids)
		if(reagent_ids[reagent] < volume)
			return TRUE
	return FALSE

/obj/item/reagent_containers/borghypo/mob_act(mob/target, mob/living/user)
	if(!ishuman(target))
		return
	if(!reagent_ids[reagent_selected])
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	var/mob/living/carbon/human/mob = target
	if(mob.can_inject(user, TRUE, user.zone_selected, penetrate_thick))
		to_chat(user, "<span class='notice'>You inject [mob] with [src].</span>")
		to_chat(mob, "<span class='notice'>You feel a tiny prick!</span>")
		var/reagents_to_transfer = min(amount_per_transfer_from_this, reagent_ids[reagent_selected])
		mob.reagents.add_reagent(reagent_selected, reagents_to_transfer)
		reagent_ids[reagent_selected] -= reagents_to_transfer
		START_PROCESSING(SSobj, src) // start processing so we can refill hypo
		if(play_sound)
			playsound(loc, 'sound/goonstation/items/hypo.ogg', 80, FALSE)
		if(mob.reagents)
			var/datum/reagent/injected = GLOB.chemical_reagents_list[reagent_selected]
			var/contained = injected.name
			add_attack_logs(user, mob, "Injected with [name] containing [contained], transfered [reagents_to_transfer] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
			to_chat(user, "<span class='notice'>[reagents_to_transfer] units injected. [reagent_ids[reagent_selected]] units remaining.</span>")

/obj/item/reagent_containers/borghypo/proc/get_radial_contents()
	return reagent_icons & reagent_ids

/obj/item/reagent_containers/borghypo/activate_self(mob/user)
	if(..())
		return

	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	var/selected_reagent = show_radial_menu(user, src, get_radial_contents(), radius = 48)
	if(!selected_reagent)
		return
	var/datum/reagent/R = GLOB.chemical_reagents_list[selected_reagent]
	to_chat(user, "<span class='notice'>Synthesizer is now dispensing [R.name].</span>")
	reagent_selected = selected_reagent

/// Overriding because this is not really a reagent container
/obj/item/reagent_containers/borghypo/build_reagent_description(mob/user)
	var/datum/reagent/get_reagent_name = GLOB.chemical_reagents_list[reagent_selected]
	return "<span class='notice'>Contains [reagent_ids[reagent_selected]] units of [get_reagent_name.name].</span>"

/obj/item/reagent_containers/borghypo/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		penetrate_thick = TRUE
		play_sound = FALSE
		reagent_ids += reagent_ids_emagged
		refill_hypo(quick = TRUE)
		return
	emagged = FALSE
	penetrate_thick = FALSE
	play_sound = initial(play_sound)
	reagent_ids -= reagent_ids_emagged
	refill_hypo(quick = TRUE)

/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and hydrocodone, for field surgery and pain relief."
	icon_state = "borghypo_s"
	penetrate_thick = TRUE
	refill_delay = FALSE // recharges each tick
	play_sound = FALSE
	volume = 30
	charge_cost = 20
	reagent_ids = list("syndicate_nanites", "potass_iodide", "hydrocodone")
	reagent_selected = "syndicate_nanites"

/obj/item/reagent_containers/borghypo/abductor
	penetrate_thick = TRUE
	charge_cost = 40
	reagent_ids = list("salglu_solution", "epinephrine", "spaceacillin", "charcoal", "hydrocodone", "mannitol", "salbutamol", "corazone")

#undef BORGHYPO_REFILL_VALUE
