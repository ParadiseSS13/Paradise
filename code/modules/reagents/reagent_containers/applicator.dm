/obj/item/reagent_containers/applicator
	name = "auto-mender"
	desc = "A small electronic device designed to topically apply healing chemicals."
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "mender"
	item_state = "mender"
	volume = 200
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	resistance_flags = ACID_PROOF
	container_type = REFILLABLE | AMOUNT_VISIBLE
	temperature_min = 270
	temperature_max = 350
	var/ignore_flags = FALSE
	var/applied_amount = 8 // How much it applies
	var/applying = FALSE // So it can't be spammed.
	var/measured_health = 0 // Used for measuring health; we don't want this to stop applying once the person's health isn't changing.
	var/static/list/safe_chem_applicator_list = list("silver_sulfadiazine", "styptic_powder", "synthflesh")

/obj/item/reagent_containers/applicator/examine(mob/user)
	. = ..()
	. += "<span class='info'><b>Alt-Click</b> to empty it.</span>"

/obj/item/reagent_containers/applicator/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		ignore_flags = TRUE
		to_chat(user, "<span class='warning'>You short out the safeties on [src].</span>")

/obj/item/reagent_containers/applicator/on_reagent_change()
	if(!emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!safe_chem_applicator_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] identifies and removes a harmful substance.</span>")
			else
				visible_message("<span class='warning'>[src] identifies and removes a harmful substance.</span>")
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/applicator/update_icon_state()
	if(applying)
		icon_state = "mender-active"
	else
		icon_state = "mender"

/obj/item/reagent_containers/applicator/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/goonstation/objects/objects.dmi', "mender-fluid")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling
	var/reag_pct = round((reagents.total_volume / volume) * 100)
	var/mutable_appearance/applicator_bar = mutable_appearance('icons/goonstation/objects/objects.dmi', "app_e")
	switch(reag_pct)
		if(51 to 100)
			applicator_bar.icon_state = "app_hf"
		if(1 to 50)
			applicator_bar.icon_state = "app_he"
		if(0)
			applicator_bar.icon_state = "app_e"
	. += applicator_bar

/obj/item/reagent_containers/applicator/proc/apply(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(applying)
		to_chat(user, "<span class='warning'>You're already applying [src].</span>")
		return
	if(!iscarbon(M))
		return

	if(ignore_flags || M.can_inject(user, TRUE))
		if(M == user)
			M.visible_message("[user] begins mending [user.p_themselves()] with [src].", "<span class='notice'>You begin mending yourself with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins mending [M] with [src].</span>", "<span class='notice'>You begin mending [M] with [src].</span>")
		if(M.reagents)
			applying = TRUE
			update_icon(UPDATE_ICON_STATE)
			while(do_after(user, 10, target = M))
				measured_health = M.health
				apply_to(M, user, 1, FALSE)
				if(measured_health == M.health)
					to_chat(user, "<span class='notice'>[M] is finished healing and [src] powers down automatically.</span>")
					break
				if(!reagents.total_volume)
					to_chat(user, "<span class='notice'>[src] is out of reagents and powers down automatically.</span>")
					break
		applying = FALSE
		update_icon()
		user.changeNext_move(CLICK_CD_MELEE)

/obj/item/reagent_containers/applicator/attack(mob/living/M, mob/user)
	return apply(M, user)

/obj/item/reagent_containers/applicator/attack_self(mob/user)
	return apply(user, user)

/obj/item/reagent_containers/applicator/proc/apply_to(mob/living/carbon/M, mob/user, multiplier = 1, show_message = TRUE)
	var/total_applied_amount = applied_amount * multiplier

	if(reagents && reagents.total_volume)
		var/list/injected = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			injected += R.name

		var/contained = english_list(injected)
		// allow normal logging only if reagents are not harmless and automender is emagged
		add_attack_logs(user, M, "Automends with [src] containing ([contained])", (emagged && !(reagents.harmless_helper())) ? null : ATKLOG_ALMOSTALL)

		var/fractional_applied_amount = total_applied_amount  / reagents.total_volume

		reagents.reaction(M, REAGENT_TOUCH, fractional_applied_amount, show_message)
		reagents.trans_to(M, total_applied_amount * 0.5)
		reagents.remove_any(total_applied_amount * 0.5)

		playsound(get_turf(src), pick('sound/goonstation/items/mender.ogg', 'sound/goonstation/items/mender2.ogg'), 50, 1)

/obj/item/reagent_containers/applicator/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(alert(user, "Are you sure you want to empty [src]?", "Empty Applicator:", "Yes", "No") != "Yes")
		return
	if(!user.incapacitated() && isturf(user.loc) && loc == user)
		to_chat(user, "<span class='notice'>You empty [src] onto the floor.</span>")
		reagents.reaction(user.loc)
		reagents.clear_reagents()

/obj/item/reagent_containers/applicator/brute
	name = "brute auto-mender"
	list_reagents = list("styptic_powder" = 200)

/obj/item/reagent_containers/applicator/burn
	name = "burn auto-mender"
	list_reagents = list("silver_sulfadiazine" = 200)

/obj/item/reagent_containers/applicator/dual
	name = "dual auto-mender"
	list_reagents = list("synthflesh" = 200)

/obj/item/reagent_containers/applicator/dual/syndi // It magically goes through hardsuits. Don't ask how.
	ignore_flags = TRUE
