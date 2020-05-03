/obj/item/reagent_containers/applicator
	name = "auto-mender"
	desc = "A small electronic device designed to topically apply healing chemicals."
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "mender"
	item_state = "mender"
	volume = 200
	resistance_flags = ACID_PROOF
	container_type = REFILLABLE | AMOUNT_VISIBLE
	temperature_min = 270
	temperature_max = 350
	var/ignore_flags = FALSE
	var/emagged = FALSE
	var/applied_amount = 8 // How much it applies
	var/applying = FALSE // So it can't be spammed.
	var/measured_health = 0 // Used for measuring health; we don't want this to stop applying once the person's health isn't changing.

/obj/item/reagent_containers/applicator/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		ignore_flags = TRUE
		to_chat(user, "<span class='warning'>You short out the safeties on [src].</span>")

/obj/item/reagent_containers/applicator/on_reagent_change()
	if(!emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!GLOB.safe_chem_applicator_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] identifies and removes a harmful substance.</span>")
			else
				visible_message("<span class='warning'>[src] identifies and removes a harmful substance.</span>")
	update_icon()

/obj/item/reagent_containers/applicator/update_icon()
	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/goonstation/objects/objects.dmi', "mender-fluid")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/applicator/attack(mob/living/M, mob/user)
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
			M.visible_message("[user] begins mending [user.p_them()]self with [src].", "<span class='notice'>You begin mending yourself with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins mending [M] with [src].</span>", "<span class='notice'>You begin mending [M] with [src].</span>")
		if(M.reagents)
			applying = TRUE
			icon_state = "mender-active"
			apply_to(M, user, 0.2) // We apply a very weak application up front, then loop.
			while(do_after(user, 10, target = M))
				measured_health = M.health
				apply_to(M, user, 1, FALSE)
				if((measured_health == M.health) || !reagents.total_volume)
					to_chat(user, "<span class='notice'>[M] is finished healing and [src] powers down automatically.</span>")
					break
		applying = FALSE
		icon_state = "mender"
		user.changeNext_move(CLICK_CD_MELEE)


/obj/item/reagent_containers/applicator/proc/apply_to(mob/living/carbon/M, mob/user, multiplier = 1, show_message = TRUE)
	var/total_applied_amount = applied_amount * multiplier

	if(reagents && reagents.total_volume)
		var/list/injected = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			injected += R.name

		var/contained = english_list(injected)

		add_attack_logs(user, M, "Automends with [src] containing ([contained])", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

		var/fractional_applied_amount = total_applied_amount  / reagents.total_volume

		reagents.reaction(M, REAGENT_TOUCH, fractional_applied_amount, show_message)
		reagents.trans_to(M, total_applied_amount * 0.5)
		reagents.remove_any(total_applied_amount * 0.5)

		playsound(get_turf(src), pick('sound/goonstation/items/mender.ogg', 'sound/goonstation/items/mender2.ogg'), 50, 1)

/obj/item/reagent_containers/applicator/brute
	name = "brute auto-mender"
	list_reagents = list("styptic_powder" = 200)

/obj/item/reagent_containers/applicator/burn
	name = "burn auto-mender"
	list_reagents = list("silver_sulfadiazine" = 200)

/obj/item/reagent_containers/applicator/dual
	name = "dual auto-mender"
	list_reagents = list("synthflesh" = 200)
