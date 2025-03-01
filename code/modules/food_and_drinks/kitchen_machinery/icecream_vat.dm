//ICE CREAM MACHINE
//Code made by Sawu at Sawu-Station.

/obj/machinery/icemachine
	name = "\improper Cream-Master Deluxe"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	max_integrity = 300
	idle_power_consumption = 20
	var/obj/item/reagent_containers/glass/beaker = null
	var/useramount = 15	//Last used amount
	/// Reagents that can't be exported from the machine except by making ice cream.
	var/list/static/locked_reagents = list("cola", "kahlua", "dr_gibb", "vodka", "space_up", "rum", "spacemountainwind", "gin", "cream", "vanilla")


/obj/machinery/icemachine/proc/generate_name(reagent_name)
	var/name_prefix = pick("Mr.","Mrs.","Mx.","Dr.","Super","Happy","Whippy", "Sugary", "Sweet", "Lawful", "Chaotic", "Neutral", "Drippy","Sicknasty","Tubular","Radical")
	var/name_suffix = pick(" Whippy "," Slappy "," Creamy "," Dippy "," Swirly "," Swirl ", " Rootin'Tootin "," Frosty ", " Chilly "," Neutral ", " Good ", " Evil ", " Smooth ", " Chunky ", " Flaming ")
	var/cone_name = null	//Heart failure prevention.
	cone_name += name_prefix
	cone_name += name_suffix
	cone_name += "[reagent_name]"
	return cone_name


/obj/machinery/icemachine/Initialize(mapload)
	. = ..()
	create_reagents(500)

/obj/machinery/icemachine/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='notice'>A container is already inside [src].</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [used] is stuck to you!</span>")
			return ITEM_INTERACT_COMPLETE
		beaker = used
		used.forceMove(src)
		to_chat(user, "<span class='notice'>You add [used] to [src].</span>")
		updateUsrDialog()
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/food/frozen/icecream))
		if(!used.reagents.has_reagent("sprinkles"))
			if(used.reagents.total_volume > 29)
				used.reagents.remove_any(1)
			used.reagents.add_reagent("sprinkles", 1)
			used.name += " with sprinkles"
			used.desc += ". This also has sprinkles."
		else
			to_chat(user, "<span class='notice'>This [used] already has sprinkles.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/icemachine/Topic(href, href_list)
	if(..()) return

	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["close"])
		usr << browse(null, "window=cream_master")
		usr.unset_machine()
		return

	if(href_list["add"])
		if(href_list["amount"])
			var/id = href_list["add"]
			var/amount = text2num(href_list["amount"])
			if(amount <= 0)
				return
			var/transferred = beaker.reagents.trans_id_to(src, id, amount)
			if(transferred <= 0)
				return
			to_chat(usr, "<span class='notice'>[src] vibrates for a moment as it transfers the liquid.</span>")
			playsound(loc, 'sound/machines/twobeep.ogg', 10, TRUE)

	else if(href_list["remove"])
		if(href_list["amount"])
			var/id = href_list["remove"]
			var/amount = text2num(href_list["amount"])
			if(amount <= 0)
				return
			if(beaker == null || (id in locked_reagents))
				reagents.remove_reagent(id,amount)
				to_chat(usr, "<span class='notice'>[src] vibrates for a moment as it flushes the liquid.</span>")
				playsound(loc, 'sound/machines/twobeep.ogg', 10, TRUE)
				updateUsrDialog()
				return

			var/transferred = reagents.trans_id_to(beaker, id, amount)
			if(transferred <= 0)
				return
			to_chat(usr, "<span class='notice'>[src] vibrates for a moment as it transfers the liquid.</span>")
			playsound(loc, 'sound/machines/twobeep.ogg', 10, TRUE)

	else if(href_list["main"])
		attack_hand(usr)
		return

	else if(href_list["eject"])
		if(beaker)
			beaker.forceMove(loc)
			beaker = null
			reagents.trans_to(beaker, reagents.total_volume)

	else if(href_list["synthcond"])
		if(href_list["type"])
			var/ID = text2num(href_list["type"])
			// ID 1 was sprinkles, which are now added by using ice cream on the machine.
			if(ID == 2 | ID == 3)
				var/brand = pick(1,2,3,4)
				if(brand == 1)
					if(ID == 2)
						reagents.add_reagent("cola",5)
					else
						reagents.add_reagent("kahlua",5)
				else if(brand == 2)
					if(ID == 2)
						reagents.add_reagent("dr_gibb",5)
					else
						reagents.add_reagent("vodka",5)
				else if(brand == 3)
					if(ID == 2)
						reagents.add_reagent("space_up",5)
					else
						reagents.add_reagent("rum",5)
				else if(brand == 4)
					if(ID == 2)
						reagents.add_reagent("spacemountainwind",5)
					else
						reagents.add_reagent("gin",5)
			else if(ID == 4)
				reagents.add_reagent("cream", 5)
			else if(ID == 5)
				reagents.add_reagent("vanilla", 5)

	else if(href_list["createchoco"])
		var/name = generate_name(reagents.get_master_reagent_name())
		name += " Chocolate Cone"
		var/obj/item/food/frozen/icecream/icecreamcup/C = new(loc)
		C.name = "[name]"
		C.pixel_x = rand(-8, 8)
		C.pixel_y = -16
		reagents.trans_to(C, 50)
		if(reagents)
			reagents.clear_reagents()
		C.update_icon()

	else if(href_list["createcone"])
		var/name = generate_name(reagents.get_master_reagent_name())
		name += " Cone"
		var/obj/item/food/frozen/icecream/icecreamcone/C = new(loc)
		C.name = "[name]"
		C.pixel_x = rand(-8, 8)
		C.pixel_y = -16
		reagents.trans_to(C, 30)
		if(reagents)
			reagents.clear_reagents()
		C.update_icon()

	else if(href_list["createwaffle"])
		var/name = generate_name(reagents.get_master_reagent_name())
		name += " Waffle Cone"
		var/obj/item/food/frozen/icecream/wafflecone/C = new(loc)
		C.name = "[name]"
		C.pixel_x = rand(-8, 8)
		C.pixel_y = -16
		reagents.trans_to(C, 20)
		if(reagents)
			reagents.clear_reagents()
		C.update_icon()
	updateUsrDialog()


/obj/machinery/icemachine/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/icemachine/proc/show_toppings()
	var/dat = ""
	if(reagents.total_volume <= 500)
		dat += "<HR>"
		dat += "<strong>Add fillings:</strong><BR>"
		dat += "<A href='byond://?src=[UID()];synthcond=1;type=2'>Soda</A><BR>"
		dat += "<A href='byond://?src=[UID()];synthcond=1;type=3'>Alcohol</A><BR>"
		dat += "<strong>Finish With:</strong><BR>"
		dat += "<A href='byond://?src=[UID()];synthcond=1;type=4'>Cream</A><BR>"
		dat += "<A href='byond://?src=[UID()];synthcond=1;type=5'>Vanilla</A><BR>"
		dat += "<strong>Dispense in:</strong><BR>"
		dat += "<A href='byond://?src=[UID()];createchoco=1'>Chocolate Cone</A><BR>"
		dat += "<A href='byond://?src=[UID()];createcone=1'>Cone</A><BR>"
		dat += "<A href='byond://?src=[UID()];createwaffle=1'>Waffle Cone</A><BR>"
	dat += "</center>"
	return dat


/obj/machinery/icemachine/proc/show_reagents(container)
	//1 = beaker / 2 = internal
	var/dat = ""
	if(container == 1)
		var/obj/item/reagent_containers/glass/A = beaker
		var/datum/reagents/R = A.reagents
		dat += "The container has:<BR>"
		for(var/datum/reagent/G in R.reagent_list)
			dat += "[G.volume] unit(s) of [G.name] | "
			dat += "<A href='byond://?src=[UID()];add=[G.id];amount=5'>(5)</A> "
			dat += "<A href='byond://?src=[UID()];add=[G.id];amount=10'>(10)</A> "
			dat += "<A href='byond://?src=[UID()];add=[G.id];amount=15'>(15)</A> "
			dat += "<A href='byond://?src=[UID()];add=[G.id];amount=[G.volume]'>(All)</A>"
			dat += "<BR>"
	else if(container == 2)
		dat += "<BR>The Cream-Master has:<BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.volume] unit(s) of [N.name] | "
				dat += "<A href='byond://?src=[UID()];remove=[N.id];amount=5'>(5)</A> "
				dat += "<A href='byond://?src=[UID()];remove=[N.id];amount=10'>(10)</A> "
				dat += "<A href='byond://?src=[UID()];remove=[N.id];amount=15'>(15)</A> "
				dat += "<A href='byond://?src=[UID()];remove=[N.id];amount=[N.volume]'>(All)</A>"
				dat += "<BR>"
	else
		dat += "<BR>SOMEONE ENTERED AN INVALID REAGENT CONTAINER; QUICK, BUG REPORT!<BR>"
	return dat


/obj/machinery/icemachine/attack_hand(mob/user)
	if(..()) return
	user.set_machine(src)
	var/dat = ""
	if(!beaker)
		dat += "No container is loaded into the machine, external transfer offline.<BR>"
		dat += show_reagents(2)
		dat += show_toppings()
		dat += "<A href='byond://?src=[UID()];close=1'>Close</A>"
	else
		var/obj/item/reagent_containers/glass/A = beaker
		var/datum/reagents/R = A.reagents
		dat += "<A href='byond://?src=[UID()];eject=1'>Eject container and end transfer.</A><BR>"
		if(!R.total_volume)
			dat += "Container is empty.<BR><HR>"
		else
			dat += show_reagents(1)
		dat += show_reagents(2)
		dat += show_toppings()
	var/datum/browser/popup = new(user, "cream_master","Cream-Master Deluxe", 700, 400, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/icemachine/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 4)
	qdel(src)

/obj/machinery/icemachine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 30)

