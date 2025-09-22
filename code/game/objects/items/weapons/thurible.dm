/obj/item/thurible
	name = "thurible"
	desc = "A religious artifact used to burn and spread incense when swung from the attached chain."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "thurible"
	lefthand_file = 'icons/mob/inhands/religion_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/religion_righthand.dmi'
	force = 10
	throwforce = 7
	flags = CONDUCT
	container_type = REFILLABLE
	/// Whether or not the thurible can be loaded with harmful chems
	var/corrupted = FALSE
	/// Has the thurible been ignited?
	var/lit = FALSE
	/// List of chemicals considered safe for the thurible
	var/static/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone", "salbutamol", "omnizine",
									"weak_omnizine", "godblood", "potass_iodide", "oculine", "mannitol", "spaceacillin", "salglu_solution",
									"sal_acid", "cryoxadone", "sugar", "hydrocodone", "mitocholide", "rezadone", "menthol",
									"mutadone", "sanguine_reagent", "iron", "ephedrine", "heparin", "corazone", "sodiumchloride",
									"lavaland_extract", "synaptizine", "bicaridine", "kelotane", "water", "holywater", "lsd", "thc", "happiness",
									"cbd", "space_drugs", "nicotine", "jestosterone", "nothing")
	/// How many reagents are consumed with each swing?
	var/swing_reagents_consumed = 2

/obj/item/thurible/Initialize(mapload)
	. = ..()
	create_reagents(50)
	reagents.set_reacting(FALSE)

/obj/item/thurible/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(reagents)
	return ..()

/obj/item/thurible/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can hold up to [reagents.maximum_volume] units.</span>"
	. += "<span class='notice'>Contains [reagents.total_volume] units of various reagents.</span>"

/obj/item/thurible/process()
	swing()

/obj/item/thurible/update_appearance()
	if(lit)
		icon_state = "thurible-lit"
	else
		icon_state = "thurible"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.r_hand == src || H.l_hand == src)
			H.update_inv_l_hand()
			H.update_inv_r_hand()
	return ..()

/obj/item/thurible/attackby__legacy__attackchain(obj/item/fire_source, mob/user, params)
	. = ..()
	if(fire_source.get_heat())
		user.visible_message(
			"<span class='notice'>[user] lights [src] with [fire_source].</span>",
			"<span class='notice'>You light [src] with [fire_source].</span>",
			"<span class='warning'>You hear a low whoosh.</span>"
		)
		light(user)

/obj/item/thurible/attack_self__legacy__attackchain(mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>You extinguish [src].</span>")
		put_out(user)
	return ..()

/obj/item/thurible/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold \the [initial(name)] while it's lit!</span>") // initial(name) so it doesn't say "lit" twice in a row
		return FALSE
	return TRUE

/obj/item/thurible/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	. = ..()
	light()

/obj/item/thurible/on_reagent_change()
	. = ..()
	if(corrupted)
		return
	var/found_forbidden_reagent = FALSE
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(R.id == "unholywater")
			corrupted = TRUE
			visible_message(
				"<span class='notice'>You corrupt [src] with unholy water!</span>",
				"<span class='warning'>You hear a strange gurgling.</span>"
			)
			return
		if(!safe_chem_list.Find(R.id))
			reagents.del_reagent(R.id)
			found_forbidden_reagent = TRUE
	if(found_forbidden_reagent)
		visible_message(
			"<span class='notice'>[src] banishes an unholy substance!</span>",
			"<span class='warning'>You hear a strange fizzing.</span>"
		)

/// Lights the thurible and starts processing reagents
/obj/item/thurible/proc/light(mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[src] is already lit!</span>")
		return

	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return

	// Plasma explodes when exposed to fire.
	if(reagents.get_reagent_amount("plasma"))
		var/datum/effect_system/reagents_explosion/E = new()
		E.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
		E.start()
		return

	// Fuel explodes, too, but much less violently.
	if(reagents.get_reagent_amount("fuel"))
		var/datum/effect_system/reagents_explosion/E = new()
		E.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
		E.start()
		return

	// And black powder... but more violently.
	if(reagents.get_reagent_amount("blackpowder"))
		var/datum/effect_system/reagents_explosion/E = new()
		E.set_up(round(reagents.get_reagent_amount("blackpowder") / 2, 1), get_turf(src), 0, 0)
		E.start()
		return

	lit = TRUE
	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	START_PROCESSING(SSobj, src)
	set_light(2, 0.3, "#E38F46")
	update_appearance()
	return TRUE

/// Extinguishes the thurible and stops processing
/obj/item/thurible/proc/put_out(mob/user)
	lit = FALSE
	STOP_PROCESSING(SSobj, src)
	set_light(0)
	update_appearance()
	return TRUE

/// Spreads reagents in a 3x3 area centered on the thurible
/obj/item/thurible/proc/swing()
	var/obj/released_reagents = new
	released_reagents.create_reagents(2)
	reagents.trans_to(released_reagents, swing_reagents_consumed)
	var/list/mobs_to_smoke = list()
	for(var/atom/A in view(1, get_turf(src)))
		released_reagents.reagents.reaction(A)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.can_breathe_gas())
				mobs_to_smoke += C
	if(length(mobs_to_smoke))
		var/percentage_to_add = released_reagents.reagents.total_volume / length(mobs_to_smoke) // Divide the amount of reagents spread around by the number of people inhaling it

		for(var/mob/living/carbon/smoker as anything in mobs_to_smoke)
			released_reagents.reagents.copy_to(smoker, percentage_to_add)

	if(reagents.total_volume <= 0)
		put_out()
