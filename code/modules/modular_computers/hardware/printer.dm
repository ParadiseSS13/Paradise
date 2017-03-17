/obj/item/weapon/computer_hardware/printer
	name = "printer"
	desc = "Computer-integrated printer with paper recycling module."
	power_usage = 100
	origin_tech = "programming=2;engineering=2"
	icon_state = "printer"
	w_class = WEIGHT_CLASS_NORMAL
	device_type = MC_PRINT
	var/stored_paper = 20
	var/max_paper = 30

/obj/item/weapon/computer_hardware/printer/diagnostics(mob/living/user)
	..()
	to_chat(user, "Paper level: [stored_paper]/[max_paper]")

/obj/item/weapon/computer_hardware/printer/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Paper level: [stored_paper]/[max_paper]</span>")


/obj/item/weapon/computer_hardware/printer/proc/print_text(var/text_to_print, var/paper_title = "")
	if(!stored_paper)
		return FALSE
	if(!check_functionality())
		return FALSE

	var/obj/item/weapon/paper/P = new/obj/item/weapon/paper(get_turf(holder))

	// Damaged printer causes the resulting paper to be somewhat harder to read.
	if(damage > damage_malfunction)
		P.info = stars(text_to_print, 100-malfunction_probability)
	else
		P.info = text_to_print
	if(paper_title)
		P.name = paper_title
	P.update_icon()
	stored_paper--
	P = null
	return TRUE

/obj/item/weapon/computer_hardware/printer/try_insert(obj/item/I, mob/living/user = null)
	if(istype(I, /obj/item/weapon/paper))
		if(stored_paper >= max_paper)
			if(user)
				to_chat(user, "<span class='warning'>You try to add \the [I] into [src], but its paper bin is full!</span>")
			return FALSE

		if(user && !user.unEquip(I))
			return FALSE

		if(user)
			to_chat(user, "<span class='notice'>You insert \the [I] into [src]'s paper recycler.</span>")
		qdel(I)
		stored_paper++
		return TRUE
	return FALSE

/obj/item/weapon/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 50
	icon_state = "printer_mini"
	w_class = WEIGHT_CLASS_TINY
	stored_paper = 5
	max_paper = 15