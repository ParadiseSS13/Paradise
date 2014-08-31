/obj/machinery/computer/diseasesplicer
	name = "Disease Splicer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "crew"

	var/datum/disease2/effectholder/memorybank = null
	var/list/species_buffer = null
	var/analysed = 0
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0
	var/splicing = 0
	var/scanning = 0

/obj/machinery/computer/diseasesplicer/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		return ..(I,user)

	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if (dish)
			user << "\The [src] is already loaded."
			return

		dish = I
		c.drop_item()
		I.loc = src

	if(istype(I,/obj/item/weapon/diseasedisk))
		user << "You upload the contents of the disk onto the buffer."
		memorybank = I:effect
		species_buffer = I:species
		analysed = I:analysed

	src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_hand(var/mob/user as mob)
	if(..()) return
	ui_interact(user)

/obj/machinery/computer/diseasesplicer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["dish_inserted"] = !!dish
	data["growth"] = 0
	data["affected_species"] = null

	if (memorybank)
		data["buffer"] = list("name" = (analysed ? memorybank.effect.name : "Unknown Symptom"), "stage" = memorybank.stage)
	if (species_buffer)
		data["species_buffer"] = analysed ? list2text(species_buffer, ", ") : "Unknown Species"

	if (splicing)
		data["busy"] = "Splicing..."
	else if (scanning)
		data["busy"] = "Scanning..."
	else if (burning)
		data["busy"] = "Copying data to disk..."
	else if (dish)
		data["growth"] = min(dish.growth, 100)

		if (dish.virus2)
			if (dish.virus2.affected_species)
				data["affected_species"] = dish.analysed ? list2text(dish.virus2.affected_species, ", ") : "Unknown"

			if (dish.growth >= 50)
				var/list/effects[0]
				for (var/datum/disease2/effectholder/e in dish.virus2.effects)
					effects.Add(list(list("name" = (dish.analysed ? e.effect.name : "Unknown"), "stage" = (e.stage), "reference" = "\ref[e]")))
				data["effects"] = effects
			else
				data["info"] = "Insufficient cell growth for gene splicing."
		else
			data["info"] = "No virus detected."
	else
		data["info"] = "No dish loaded."

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "disease_splicer.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/diseasesplicer/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(scanning)
		scanning -= 1
		if(!scanning)
			ping("\The [src] pings, \"Analysis complete.\"")
			nanomanager.update_uis(src)
	if(splicing)
		splicing -= 1
		if(!splicing)
			ping("\The [src] pings, \"Splicing operation complete.\"")
			nanomanager.update_uis(src)
	if(burning)
		burning -= 1
		if(!burning)
			var/obj/item/weapon/diseasedisk/d = new /obj/item/weapon/diseasedisk(src.loc)
			d.analysed = analysed
			if(analysed)
				if (memorybank)
					d.name = "[memorybank.effect.name] GNA disk (Stage: [memorybank.effect.stage])"
					d.effect = memorybank
				else if (species_buffer)
					d.name = "[list2text(species_buffer, ", ")] GNA disk"
					d.species = species_buffer
			else
				if (memorybank)
					d.name = "Unknown GNA disk (Stage: [memorybank.effect.stage])"
					d.effect = memorybank
				else if (species_buffer)
					d.name = "Unknown Species GNA disk"
					d.species = species_buffer

			ping("\The [src] pings, \"Backup disk saved.\"")
			nanomanager.update_uis(src)

/obj/machinery/computer/diseasesplicer/Topic(href, href_list)
	if(..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	src.add_fingerprint(user)

	if (href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if (href_list["grab"])
		if (dish)
			memorybank = locate(href_list["grab"])
			species_buffer = null
			analysed = dish.analysed
			dish = null
			scanning = 10
		return 1

	if (href_list["affected_species"])
		if (dish)
			memorybank = null
			species_buffer = dish.virus2.affected_species
			analysed = dish.analysed
			dish = null
			scanning = 10
		return 1

	if(href_list["eject"])
		if (dish)
			dish.loc = src.loc
			dish = null
		return 1

	if(href_list["splice"])
		if(dish)
			if (memorybank)
				for(var/datum/disease2/effectholder/e in dish.virus2.effects)
					if(e.stage == memorybank.stage)
						e.effect = memorybank.effect

			if (species_buffer)
				dish.virus2.affected_species = species_buffer

			splicing = 10
			dish.virus2.uniqueID = rand(0,10000)
		return 1

	if(href_list["disk"])
		burning = 10
		return 1

	return 0
