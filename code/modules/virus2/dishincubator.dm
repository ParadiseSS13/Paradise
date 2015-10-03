/obj/machinery/disease2/incubator/
	name = "Pathogenic incubator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/radiation = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxins = 0

/obj/machinery/disease2/incubator/attackby(var/obj/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/syringe))

		if(beaker)
			user << "<span class='warning'>\The [src] is already loaded.</span>"
			return

		if(!user.drop_item())
			user << "<span class='warning'>\The [O] is stuck to you!</span>"
			return

		beaker = O
		O.forceMove(src)

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		nanomanager.update_uis(src)

		src.attack_hand(user)
		return

	if(istype(O, /obj/item/weapon/virusdish))

		if(dish)
			user << "The dish tray is aleady full!"
			return

		if(!user.drop_item())
			user << "<span class='warning'>\The [O] is stuck to you!</span>"
			return
		dish = O
		O.forceMove(src)

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		nanomanager.update_uis(src)

		src.attack_hand(user)

/obj/machinery/disease2/incubator/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN)) return
	ui_interact(user)

/obj/machinery/disease2/incubator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["chemicals_inserted"] = !!beaker
	data["dish_inserted"] = !!dish
	data["food_supply"] = foodsupply
	data["radiation"] = radiation
	data["toxins"] = min(toxins, 100)
	data["on"] = on
	data["system_in_use"] = foodsupply > 0 || radiation > 0 || toxins > 0
	data["chemical_volume"] = beaker ? beaker.reagents.total_volume : 0
	data["max_chemical_volume"] = beaker ? beaker.volume : 1
	data["virus"] = dish ? dish.virus2 : null
	data["growth"] = dish ? min(dish.growth, 100) : 0
	data["infection_rate"] = dish && dish.virus2 ? dish.virus2.infectionchance * 10 : 0
	data["analysed"] = dish && dish.analysed ? 1 : 0
	data["can_breed_virus"] = null
	data["blood_already_infected"] = null

	if (beaker)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
		data["can_breed_virus"] = dish && dish.virus2 && B

		if (B)
			if (!B.data["virus2"])
				B.data["virus2"] = list()

			var/list/virus = B.data["virus2"]
			for (var/ID in virus)
				data["blood_already_infected"] = virus[ID]

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "dish_incubator.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/disease2/incubator/process()
	if(dish && on && dish.virus2)
		use_power(50,EQUIP)
		if(!powered(EQUIP))
			on = 0
			icon_state = "incubator"

		if(foodsupply)
			if(dish.growth + 3 >= 100 && dish.growth < 100)
				ping("\The [src] pings, \"Sufficient viral growth density achieved.\"")

			foodsupply -= 1
			dish.growth += 3
			nanomanager.update_uis(src)

		if(radiation)
			if(radiation > 50 & prob(5))
				dish.virus2.majormutate()
				if(dish.info)
					dish.info = "OUTDATED : [dish.info]"
					dish.analysed = 0
				ping("\The [src] pings, \"Mutant viral strain detected.\"")
			else if(prob(5))
				dish.virus2.minormutate()
			radiation -= 1
			nanomanager.update_uis(src)
		if(toxins && prob(5))
			dish.virus2.infectionchance -= 1
			nanomanager.update_uis(src)
		if(toxins > 50)
			dish.growth = 0
			dish.virus2 = null
			nanomanager.update_uis(src)
	else if(!dish)
		on = 0
		icon_state = "incubator"
		nanomanager.update_uis(src)

	if(beaker)
		if(!beaker.reagents.remove_reagent("virusfood",5))
			foodsupply += 10
			nanomanager.update_uis(src)

		if (locate(/datum/reagent/toxin) in beaker.reagents.reagent_list)
			for(var/datum/reagent/toxin/T in beaker.reagents.reagent_list)
				//toxins += max(T.toxpwr,1)
				beaker.reagents.remove_reagent(T.id,1)
			nanomanager.update_uis(src)

/obj/machinery/disease2/incubator/Topic(href, href_list)
	if (..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	src.add_fingerprint(user)

	if (href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if (href_list["ejectchem"])
		if(beaker)
			beaker.forceMove(src.loc)
			beaker = null
		return 1

	if (href_list["power"])
		if (dish)
			on = !on
			icon_state = on ? "incubator_on" : "incubator"
		return 1

	if (href_list["ejectdish"])
		if(dish)
			dish.forceMove(src.loc)
			dish = null
		return 1

	if (href_list["rad"])
		radiation += 10
		return 1

	if (href_list["flush"])
		radiation = 0
		toxins = 0
		foodsupply = 0
		return 1

	if(href_list["virus"])
		if (!dish)
			return 1

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
		if (!B)
			return 1

		if (!B.data["virus2"])
			B.data["virus2"] = list()

		var/list/virus = list("[dish.virus2.uniqueID]" = dish.virus2.getcopy())
		B.data["virus2"] += virus

		var/list/virus_effects
		for(var/datum/disease2/effectholder/symptom in dish.virus2.effects)
			virus_effects += "\[" + symptom.effect.name + "\]"
		use_log += text("\[[time_stamp()]\] <font color='red'>[user.name] ([user.ckey]) has transferred a virus containing [virus_effects] to a blood sample.</font>")

		ping("\The [src] pings, \"Injection complete.\"")
		return 1

	return 0