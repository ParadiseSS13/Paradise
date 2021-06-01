/obj/item/reagent_containers/moa
	name = "M.O.A"
	desc = "(Medbay Oxygen Asissistant) A oxigen assistant that will be sending oxygen to the pacient over a period of time. Also has properties that make sick patients have less difficulties."
	icon = 'icons/hispania/obj/moa.dmi'
	icon_state = "moa_shutdown"
	item_state = "moa"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	list_reagents = list("moa_complement" = 10000)
	origin_tech = "materials=4;biotech=3;engineering=3"
	volume = 10000
	has_lid = TRUE
	w_class = WEIGHT_CLASS_HUGE
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = 1
	var/status = 3
	var/hitcost = 40
	var/obj/item/stock_parts/cell/cell = null
	var/mob/living/carbon/human/injection_target
	var/soundcycle = 0
	var/icon/mask = icon('icons/hispania/obj/moa.dmi',"needle")

/obj/item/reagent_containers/moa/attack_self(mob/user)
	return

/obj/item/reagent_containers/moa/process(mob/user)
	if(!injection_target || injection_target.wear_mask || status == 4)
		injection_target.overlays -= mask
		injection_target.status_flags &= ~MOAED
		end_processing()
		return
	if(get_dist(get_turf(src), get_turf(injection_target)) > 1)
		to_chat(injection_target, "<span class='userdanger'>The [src] needle mask is ripped out of you!</span>")
		injection_target.apply_damage(12, BRUTE, pick("head"))
		injection_target.overlays -= mask
		injection_target.status_flags &= ~MOAED
		end_processing()
		return
	if(status >= 2)
		playsound(loc, "sound/machines/buzz-sigh.ogg", 75, 1, 2)
		update_icon()
		return
	else
		if(reagents.total_volume && status == 1) // Injecting
			soundcycle++
			if(soundcycle == 4)
				playsound(loc, "sound/hispania/machines/moa.ogg", 75, 1, 1)
				soundcycle = 0
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1) 	//The amount of reagents we'll transfer to the person
			reagents.reaction(injection_target, REAGENT_INGEST, fraction) 	//React the amount we're transfering.
			reagents.trans_to(injection_target, amount_per_transfer_from_this)
			deductcharge(hitcost)
			cell.use(hitcost)
			update_icon()

/obj/item/reagent_containers/moa/attackby(obj/item/W, mob/user, params)
	if(status == 4)
		return
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < hitcost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.unEquip(W))
				return
			W.loc = src
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			status = 1
			update_icon()
		..()
	return

/obj/item/reagent_containers/moa/screwdriver_act(mob/user, obj/item/I)
	if(cell)
		cell.loc = get_turf(src.loc)
		cell = null
		to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
		status = 2
		update_icon()
		return

/obj/item/reagent_containers/moa/loaded/New() //this one starts with a cell pre-installed.
	..()
	status = 1
	cell = new/obj/item/stock_parts/cell/high(src)
	update_icon()
	return

/obj/item/reagent_containers/moa/get_cell()
	return cell

/obj/item/reagent_containers/moa/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>The M.O.A is [round(cell.percent())]% charged.</span>"
	if(!cell)
		. += "<span class='warning'>The M.O.A does not have a power source installed.</span>"

/obj/item/reagent_containers/moa/update_icon()
	if(status == 1)
		icon = 'icons/hispania/obj/moa.dmi'
		icon_state = "moa_active"
	if(status == 2)
		icon = 'icons/hispania/obj/moa.dmi'
		icon_state = "moa_nocell"
	if(status == 3)
		icon = 'icons/hispania/obj/moa.dmi'
		icon_state = "moa_shutdown"
	if(status == 4)
		icon = 'icons/hispania/obj/moa.dmi'
		icon_state = "moa_broken"

/obj/item/reagent_containers/moa/proc/deductcharge(chrgdeductamt, mob/user)
	if(cell)
		if(cell.charge < (hitcost+chrgdeductamt))
			status = 3
			playsound(loc, "sound/effects/sparks2.ogg", 75, 1, -1)
			to_chat(viewers(user), "<span class='warning'>The [src] has discharged!.</span>")
			update_icon()

/obj/item/reagent_containers/moa/emp_act(severity)
	if(cell)
		cell = null
		playsound(loc, "sound/effects/bang.ogg", 100, 1, -1)
		status = 4
		desc = "(Medbay Oxygen Asissistant) Looks like the cell just exploded from inside."
		update_icon()
	..()

/obj/item/reagent_containers/moa/Destroy()
	end_processing()
	return ..()

/obj/item/reagent_containers/moa/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/moa/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/moa/proc/end_processing()
	injection_target = null
	STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/moa/proc/begin_processing(mob/target)
	injection_target = target
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/moa/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/moa/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/reagent_containers/moa/afterattack(atom/target, mob/user, proximity)
	if(status == 4)
		return
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(isliving(target))
		var/mob/living/carbon/L = target
		if(injection_target) // Removing the needle
			if(L != injection_target)
				to_chat(user, "<span class='notice'>[src] is already inserted into [injection_target]'s neck!")
				return
			if(L != user)
				L.visible_message("<span class='danger'>[user] is trying to remove [src]'s needle from [L]'s neck!</span>", \
								"<span class='userdanger'>[user] is trying to remove [src]'s needle from [L]'s neck!</span>")
				if(!do_mob(user, L))
					return
			L.visible_message("<span class='danger'>[user] removes [src]'s needle from [L]'s neck!</span>", \
								"<span class='userdanger'>[user] removes [src]'s needle from [L]'s neck!</span>")
			L.status_flags &= ~MOAED // Sin condicional para evitar exploits
			L.overlays -= mask
			end_processing()
		else // Inserting the needle
			if(L.wear_mask)
				to_chat(user, "<span class='userdanger'>There's a mask obstrouing the way of the M.O.A!</span!</span>")
				return
			if(!L.can_inject(user, 1))
				return
			if(L != user)
				L.visible_message("<span class='danger'>[user] is trying to insert [src]'s needle mask into [L]'s neck!</span>", \
									"<span class='userdanger'>[user] is trying to insert [src]'s needle mask into [L]'s neck!</span>")
				if(!do_mob(user, L))
					return
			L.visible_message("<span class='danger'>[user] inserts [src]'s needle mask into [L]'s neck!</span>", \
									"<span class='userdanger'>[user] inserts [src]'s needle mask into [L]'s neck!</span>")
			if(L.dna.species.breathid == "o2")
				L.status_flags |= MOAED
			L.overlays += mask
			begin_processing(L)
