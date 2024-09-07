/obj/item/thurible
	desc = "A religious artifact used to burn and spread incense when swung from the attached chain."
	name = "thurible"
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	flags = CONDUCT
	var/corrupted = FALSE // Whether or not the thurible can be loaded with harmful chems
	var/lit = FALSE // Has the thurible been ignited?
	var/static/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone", "salbutamol", "omnizine",
									"weak_omnizine", "godblood", "potass_iodide", "oculine", "mannitol", "spaceacillin", "salglu_solution",
									"sal_acid", "cryoxadone", "sugar", "hydrocodone", "mitocholide", "rezadone", "menthol",
									"mutadone", "sanguine_reagent", "iron", "ephedrine", "heparin", "corazone", "sodiumchloride",
									"lavaland_extract", "synaptizine", "bicaridine", "kelotane", "water", "holywater", "lsd", "thc", "happiness",
									"cbd", "space_drugs", "nicotine") // List of chemicals considered safe for the thurible
	var/swing_reagents_consumed = 2 // 25 Swings until out of reagents

/obj/item/thurible/Initialize(mapload)
	. = ..()
	create_reagents(50)
	container_type = REFILLABLE
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

/obj/item/thurible/attackby(obj/item/fire_source, mob/user, params)
	. = ..()
	if(fire_source.get_heat())
		user.visible_message("<span class='notice'>[user] lights [src] with [fire_source].</span>", "<span class='notice'>You light [src] with [fire_source].</span>", "<span class='warning'>You hear a low whoosh.</span>")
		light()

/obj/item/thurible/attack_self(mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>You extinguish \the [src].</span>")
		put_out()
	return ..()

/obj/item/thurible/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold \the [initial(name)] while it's lit!</span>") // initial(name) so it doesn't say "lit" twice in a row
		return FALSE
	return TRUE

/obj/item/thurible/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	light()

/obj/item/thurible/on_reagent_change()
	. = ..()
	if(!corrupted)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R == "unholywater")
				corrupted = TRUE
				to_chat(loc, "<span class='warning'>[src] is corrupted by an unholy substance!</span>")
				return
			if(!safe_chem_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] banishes an unholy substance!</span>")
			else
				visible_message("<span class='warning'>[src] banishes an unholy substance!</span>")

/obj/item/thurible/proc/light(mob/living/user)
	if(lit)
		to_chat(user, "<span class='warning'>The [src] is already lit!</span>")
		return

	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>The [src] is out of fuel!</span>")
		return

	// Plasma explodes when exposed to fire.
	if(reagents.get_reagent_amount("plasma"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		return

	// Fuel explodes, too, but much less violently.
	if(reagents.get_reagent_amount("fuel"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
		e.start()
		return

	// And black powder... but more violently.
	if(reagents.get_reagent_amount("blackpowder"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("blackpowder") / 2, 1), get_turf(src), 0, 0)
		e.start()
		return

	lit = TRUE
	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	set_light(2, 0.25, "#E38F46")
	START_PROCESSING(SSobj, src)
	update_icon()
	return TRUE

/obj/item/thurible/proc/put_out()
	lit = FALSE
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"
	set_light(0)
	update_icon()
	STOP_PROCESSING(SSobj, src)
	return TRUE

/obj/item/thurible/proc/swing()
	// 3x3 area, centered on the thurible
	var/obj/released_reagents = new
	released_reagents.create_reagents(2)
	reagents.trans_to(released_reagents, swing_reagents_consumed)
	var/list/mobs_to_smoke = list()
	var/list/smoked_atoms = list()
	for(var/atom/A in view(1, get_turf(src.loc)))
		if(A in smoked_atoms)
			continue
		smoked_atoms += A
		released_reagents.reagents.reaction(A)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.can_breathe_gas())
				mobs_to_smoke += C

	var/percentage_to_add = released_reagents.reagents.total_volume / length(mobs_to_smoke) // Divide the amount of reagents spread around by the number of people inhaling it

	for(var/mob/living/carbon/smoker as anything in mobs_to_smoke)
		released_reagents.reagents.copy_to(smoker, percentage_to_add)

	if(!reagents.total_volume)
		put_out()

