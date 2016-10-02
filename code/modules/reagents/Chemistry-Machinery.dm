#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = 0
	idle_power_usage = 40
	var/ui_title = "Chem Dispenser 5000"
	var/energy = 100
	var/max_energy = 100
	var/amount = 30
	var/obj/item/weapon/reagent_containers/beaker = null
	var/recharged = 0
	var/hackedcheck = 0
	var/list/dispensable_reagents = list("hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
	"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
	"copper", "mercury", "plasma", "radium", "water", "ethanol", "sugar", "iodine", "bromine", "silver")
	var/list/hacked_reagents = list("toxin")
	var/hack_message = "You disable the safety safeguards, enabling the \"Mad Scientist\" mode."
	var/unhack_message = "You re-enable the safety safeguards, enabling the \"NT Standard\" mode."
	var/list/broken_requirements = list()
	var/broken_on_spawn = 0
	var/recharge_delay = 5
	var/image/icon_beaker = null //cached overlay


/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/addenergy = 1
	var/oldenergy = energy
	energy = min(energy + addenergy, max_energy)
	if(energy != oldenergy)
		use_power(1500) // This thing uses up alot of power (this is still low as shit for creating reagents from thin air)
		nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/process()

	if(recharged < 0)
		recharge()
		recharged = recharge_delay
	else
		recharged -= 1

/obj/machinery/chem_dispenser/New()
	..()
	recharge()
	dispensable_reagents = sortList(dispensable_reagents)

	if(broken_on_spawn)
		overlays.Cut()
		var/amount = pick(3,3,4)
		var/list/options = list()
		options[/obj/item/weapon/stock_parts/capacitor/adv] = "Add an advanced capacitor to fix it."
		options[/obj/item/weapon/stock_parts/console_screen] = "Replace the console screen to fix it."
		options[/obj/item/weapon/stock_parts/manipulator/pico] = "Upgrade to a pico manipulator to fix it."
		options[/obj/item/weapon/stock_parts/matter_bin/super] = "Give it a super matter bin to fix it."
		options[/obj/item/weapon/stock_parts/cell/super] = "Replace the reagent synthesizer with a super capacity cell to fix it."
		options[/obj/item/device/mass_spectrometer/adv] = "Replace the reagent scanner with an advanced mass spectrometer to fix it"
		options[/obj/item/weapon/stock_parts/micro_laser/high] = "Repair the reagent synthesizer with an high-power micro-laser to fix it"
		options[/obj/item/device/reagent_scanner/adv] = "Replace the reagent scanner with an advanced reagent scanner to fix it"
		options[/obj/item/stack/nanopaste] = "Apply some nanopaste to the broken nozzles to fix it."
		options[/obj/item/stack/sheet/plasteel] = "Surround the outside with a plasteel cover to fix it."
		options[/obj/item/stack/sheet/rglass] = "Insert a pane of reinforced glass to fix it."

		while(amount > 0)
			amount -= 1

			var/index = pick(options)
			broken_requirements[index] = options[index]
			options -= index


/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return

/obj/machinery/chem_dispenser/blob_act()
	if(prob(50))
		qdel(src)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */

/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(broken_requirements.len)
		to_chat(user, "<span class='warning'>[src] is broken. [broken_requirements[broken_requirements[1]]]</span>")
		return


	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["energy"] = round(energy)
	data["maxEnergy"] = round(max_energy)
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id"=R.id, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if(beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", ui_title, 390, 655)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["amount"])
		amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		if(amount < 0) // Since the user can actually type the commands himself, some sanity checking
			amount = 0
		if(amount > 100)
			amount = 100

	if(href_list["dispense"])
		if(dispensable_reagents.Find(href_list["dispense"]) && beaker != null)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			var/datum/reagents/R = B.reagents
			var/space = R.maximum_volume - R.total_volume

			R.add_reagent(href_list["dispense"], min(amount, energy * 10, space))
			energy = max(energy - min(amount, energy * 10, space) / 10, 0)
			overlays.Cut()
			icon_beaker = image('icons/obj/chemical.dmi', src, "disp_beaker") //randomize beaker overlay position.
			icon_beaker.pixel_x = rand(-10,5)
			overlays += icon_beaker

	if(href_list["remove"])
		if(beaker)
			if(href_list["removeamount"])
				var/amount = text2num(href_list["removeamount"])
				if(isnum(amount) && (amount > 0))
					var/obj/item/weapon/reagent_containers/glass/B = beaker
					var/datum/reagents/R = B.reagents
					var/id = href_list["remove"]
					R.remove_reagent(id, amount)

	if(href_list["ejectBeaker"])
		if(beaker)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			B.forceMove(loc)
			beaker = null
			overlays.Cut()
	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/attackby(obj/item/weapon/reagent_containers/B, mob/user, params)
	if(isrobot(user))
		return

	if(broken_requirements.len && B.type == broken_requirements[1])
		if(istype(B,/obj/item/stack))
			var/obj/item/stack/S = B
			S.use(1)
		else
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[B] is stuck to you!</span>")
				return
			qdel(B)
		broken_requirements -= broken_requirements[1]
		to_chat(user, "<span class='notice'>You fix [src].</span>")
		return

	if(beaker)
		to_chat(user, "<span class='warning'>Something is already loaded into the machine.</span>")
		return

	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B, /obj/item/weapon/reagent_containers/food/drinks))
		beaker =  B
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[B] is stuck to you!</span>")
			return
		B.forceMove(src)
		to_chat(user, "<span class='notice'>You set [B] on the machine.</span>")
		nanomanager.update_uis(src) // update all UIs attached to src
		if(!icon_beaker)
			icon_beaker = image('icons/obj/chemical.dmi', src, "disp_beaker") //randomize beaker overlay position.
		icon_beaker.pixel_x = rand(-10,5)
		overlays += icon_beaker
		return

/obj/machinery/chem_dispenser/attackby(obj/item/weapon/B, mob/user, params)
	..()
	if(istype(B, /obj/item/device/multitool))
		if(hackedcheck == 0)
			to_chat(user, hack_message)
			dispensable_reagents += hacked_reagents
			hackedcheck = 1
			return

		else
			to_chat(user, unhack_message)
			dispensable_reagents -= hacked_reagents
			hackedcheck = 0
			return

/obj/machinery/chem_dispenser/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_dispenser/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user)
	if(stat & BROKEN)
		return

	ui_interact(user)

/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	ui_title = "Soda Dispens-o-matic"
	energy = 100
	max_energy = 100
	dispensable_reagents = list("water", "ice", "milk", "soymilk", "coffee", "tea", "hot_coco", "cola", "spacemountainwind", "dr_gibb", "space_up",
	"tonic", "sodawater", "lemon_lime", "grapejuice", "sugar", "orangejuice", "lemonjuice", "limejuice", "tomatojuice", "banana",
	"watermelonjuice", "carrotjuice", "potato", "berryjuice")
	hack_message = "You change the mode from 'McNano' to 'Pizza King'."
	unhack_message = "You change the mode from 'Pizza King' to 'McNano'."
	hacked_reagents = list("thirteenloko")

/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	ui_title = "Booze Portal 9001"
	energy = 100
	max_energy = 100
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila", "vermouth", "cognac", "ale", "mead", "synthanol")
	hack_message = "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes."
	unhack_message = "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes."
	hacked_reagents = list("goldschlager", "patron", "absinthe", "ethanol", "nothing")

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_dispenser/constructable
	name = "portable chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "minidispenser"
	energy = 5
	max_energy = 5
	amount = 5
	recharge_delay = 10
	dispensable_reagents = list()
	var/list/special_reagents = list(list("hydrogen", "oxygen", "silicon", "phosphorus", "sulfur", "carbon", "nitrogen", "water"),
						 		list("lithium", "sugar", "copper", "mercury", "sodium","iodine","bromine"),
								list("ethanol", "chlorine", "potassium", "aluminum","plasma", "radium", "fluorine", "iron", "silver"),
								list("oil", "ash", "acetone", "saltpetre", "ammonia", "diethylamine", "fuel"))

/obj/machinery/chem_dispenser/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/super(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/RefreshParts()
	var/time = 0
	var/temp_energy = 0
	var/i
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		temp_energy += M.rating
	temp_energy--
	max_energy = temp_energy * 5  //max energy = (bin1.rating + bin2.rating - 1) * 5, 5 on lowest 25 on highest
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		time += C.rating
	for(var/obj/item/weapon/stock_parts/cell/P in component_parts)
		time += round(P.maxcharge, 10000) / 10000
	recharge_delay = 10 / (time/2)         //delay between recharges, double the usual time on lowest 33% less than usual on highest
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		for(i=1, i<=M.rating, i++)
			dispensable_reagents = sortList(dispensable_reagents | special_reagents[i])

/obj/machinery/chem_dispenser/constructable/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		..()
	else
		..()

	if(default_deconstruction_screwdriver(user, "minidispenser-o", "minidispenser", I))
		return

	if(exchange_parts(user, I))
		return

	if(istype(I, /obj/item/weapon/wrench))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class='caution'>[src] can now be moved.</span>")
		else if(!anchored)
			anchored = 1
			to_chat(user, "<span class='caution'>[src] is now secured.</span>")

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.forceMove(loc)
				beaker = null
			default_deconstruction_crowbar(I)
			return 1

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/patchamount = 10
	var/bottlesprite = "bottle"
	var/pillsprite = "1"
	var/client/has_sprites = list()
	var/printing = null

/obj/machinery/chem_master/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	overlays += "waitlight"

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_master/attackby(obj/item/weapon/B, mob/user, params)

	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))

		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[B] is stuck to you!</span>")
			return
		beaker = B
		B.forceMove(src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
		nanomanager.update_uis(src)
		icon_state = "mixer1"

	else if(istype(B, /obj/item/weapon/storage/pill_bottle))

		if(loaded_pill_bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into the machine.</span>")
			return

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[B] is stuck to you!</span>")
			return
		loaded_pill_bottle = B
		B.forceMove(src)
		to_chat(user, "<span class='notice'>You add the pill bottle into the dispenser slot!</span>")
		nanomanager.update_uis(src)
	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(..())
		return 1

	add_fingerprint(usr)
	usr.set_machine(src)


	if(href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(loc)
			loaded_pill_bottle = null
	else if(href_list["close"])
		usr << browse(null, "window=chem_master")
		onclose(usr, "chem_master")
		usr.unset_machine()
		return

	if(href_list["print_p"])
		if(!(printing))
			printing = 1
			visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
			playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
			P.info = "<CENTER><B>Chemical Analysis</B></CENTER><BR>"
			P.info += "<b>Time of analysis:</b> [worldtime2text(world.time)]<br><br>"
			P.info += "<b>Chemical name:</b> [href_list["name"]]<br>"
			if(href_list["name"] == "Blood")
				var/datum/reagents/R = beaker.reagents
				var/datum/reagent/blood/G
				for(var/datum/reagent/F in R.reagent_list)
					if(F.name == href_list["name"])
						G = F
						break
				var/B = G.data["blood_type"]
				var/C = G.data["blood_DNA"]
				P.info += "<b>Description:</b><br>Blood Type: [B]<br>DNA: [C]"
			else
				P.info += "<b>Description:</b> [href_list["desc"]]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Chemical Analysis - [href_list["name"]]"
			printing = null

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if(href_list["analyze"])
			var/dat = ""
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]"
				dat += "<BR><BR><A href='?src=[UID()];print_p=1;desc=[href_list["desc"]];name=[href_list["name"]]'>(Print Analysis)</A><BR>"
				dat += "<A href='?src=[UID()];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=[UID()];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
			return

		else if(href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				R.trans_id_to(src, id, amount)

		else if(href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if(href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)


		else if(href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))

		else if(href_list["toggle"])
			mode = !mode

		else if(href_list["main"])
			attack_hand(usr)
			return
		else if(href_list["eject"])
			if(beaker)
				beaker.forceMove(get_turf(src))
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"
		else if(href_list["createpill"] || href_list["createpill_multiple"])
			if(!condi)
				var/count = 1
				if(href_list["createpill_multiple"])
					count = input("Select the number of pills to make.", 10, pillamount) as num|null
					if(count == null)
						return
					count = isgoodnumber(count)
				if(count > 20) count = 20	//Pevent people from creating huge stacks of pills easily. Maybe move the number to defines?
				if(count <= 0) return
				var/amount_per_pill = reagents.total_volume/count
				if(amount_per_pill > 50) amount_per_pill = 50
				var/name = input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill]u)") as text|null
				if(!name)
					return
				name = reject_bad_text(name)
				while(count--)
					var/obj/item/weapon/reagent_containers/food/pill/P = new/obj/item/weapon/reagent_containers/food/pill(loc)
					if(!name) name = reagents.get_master_reagent_name()
					P.name = "[name] pill"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					P.icon_state = "pill"+pillsprite
					reagents.trans_to(P,amount_per_pill)
					if(loaded_pill_bottle)
						if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
							P.forceMove(loaded_pill_bottle)
							updateUsrDialog()
			else
				var/name = input(usr,"Name:","Name your bag!",reagents.get_master_reagent_name()) as text|null
				if(!name)
					return
				name = reject_bad_text(name)
				var/obj/item/weapon/reagent_containers/food/condiment/pack/P = new/obj/item/weapon/reagent_containers/food/condiment/pack(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.originalname = name
				P.name = "[name] pack"
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P,10)
		else if(href_list["createpatch"] || href_list["createpatch_multiple"])
			if(!condi)
				var/count = 1
				if(href_list["createpatch_multiple"])
					count = input("Select the number of patches to make.", 10, patchamount) as num|null
					if(count == null)
						return
					count = isgoodnumber(count)
				if(!count || count <= 0)
					return
				if(count > 20) count = 20	//Pevent people from creating huge stacks of patches easily. Maybe move the number to defines?
				var/amount_per_patch = reagents.total_volume/count
				if(amount_per_patch > 40) amount_per_patch = 40
				var/name = input(usr,"Name:","Name your patch!","[reagents.get_master_reagent_name()] ([amount_per_patch]u)") as text|null
				if(!name)
					return
				name = reject_bad_text(name)
				var/is_medical_patch = chemical_safety_check(reagents)
				while(count--)
					var/obj/item/weapon/reagent_containers/food/pill/patch/P = new/obj/item/weapon/reagent_containers/food/pill/patch(loc)
					if(!name) name = reagents.get_master_reagent_name()
					P.name = "[name] patch"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					reagents.trans_to(P,amount_per_patch)
					if(is_medical_patch)
						P.instant_application = 1
						P.icon_state = "bandaid_med"
		else if(href_list["createbottle"])
			if(!condi)
				var/name = input(usr,"Name:","Name your bottle!",reagents.get_master_reagent_name()) as text|null
				if(!name)
					return
				name = reject_bad_text(name)
				var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = bottlesprite
				reagents.trans_to(P,30)
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(loc)
				reagents.trans_to(P,50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			var/j = 0
			for(var/i = 1 to MAX_PILL_SPRITE)
				j++
				if(j == 1)
					dat += "<tr>"
				dat += "<td><a href=\"?src=[UID()]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td>"
				if(j == 5)
					dat += "</tr>"
					j = 0
			dat += "</table>"
			usr << browse(dat, "window=chem_master_iconsel;size=225x193")
			return
		else if(href_list["change_bottle"])
			var/dat = "<table>"
			var/j = 0
			for(var/i in list("bottle", "small_bottle", "wide_bottle", "round_bottle"))
				j++
				if(j == 1)
					dat += "<tr>"
				dat += "<td><a href=\"?src=[UID()]&bottle_sprite=[i]\"><img src=\"[i].png\" /></a></td>"
				if(j == 5)
					dat += "</tr>"
					j = 0
			dat += "</table>"
			usr << browse(dat, "window=chem_master_iconsel;size=225x193")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
			usr << browse(null, "window=chem_master_iconsel")
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
			usr << browse(null, "window=chem_master_iconsel")

	nanomanager.update_uis(src)
	return

/obj/machinery/chem_master/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_master/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)
	return

/obj/machinery/chem_master/ui_interact(mob/user, ui_key="main", datum/nanoui/ui = null, force_open = 1)

	var/datum/asset/chem_master/assets = get_asset_datum(/datum/asset/chem_master)
	assets.send(user)

	var/data = list()

	data["condi"] = condi
	data["loaded_pill_bottle"] = (loaded_pill_bottle ? 1 : 0)
	if(loaded_pill_bottle)
		data["loaded_pill_bottle_contents_len"] = loaded_pill_bottle.contents.len
		data["loaded_pill_bottle_storage_slots"] = loaded_pill_bottle.storage_slots

	data["beaker"] = (beaker ? 1 : 0)
	if(beaker)
		var/list/beaker_reagents_list = list()
		data["beaker_reagents"] = beaker_reagents_list
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_reagents_list[++beaker_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)
		var/list/buffer_reagents_list = list()
		data["buffer_reagents"] = buffer_reagents_list
		for(var/datum/reagent/R in reagents.reagent_list)
			buffer_reagents_list[++buffer_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)

	data["pillsprite"] = pillsprite
	data["bottlesprite"] = bottlesprite
	data["mode"] = mode

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_master.tmpl", name, 575, 400)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 1
		else
			num = round(num)
		return num
	else
		return 0

/obj/machinery/chem_master/proc/chemical_safety_check(datum/reagents/R)
	var/all_safe = 1
	for(var/datum/reagent/A in R.reagent_list)
		if(!safe_chem_list.Find(A.id))
			all_safe = 0
	return all_safe

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	condi = 1

/obj/machinery/chem_master/constructable
	name = "ChemMaster 2999"
	desc = "Used to seperate chemicals and distribute them in a variety of forms."

/obj/machinery/chem_master/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_master(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)

/obj/machinery/chem_master/constructable/attackby(obj/item/B, mob/user, params)

	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", B))
		if(beaker)
			beaker.forceMove(get_turf(src))
			beaker = null
			reagents.clear_reagents()
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(get_turf(src))
			loaded_pill_bottle = null
		return

	if(exchange_parts(user, B))
		return

	if(panel_open)
		if(istype(B, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(B)
			return 1
		else
			to_chat(user, "<span class='warning'>You can't use the [name] while it's panel is opened!</span>")
			return 1
	else
		..()

/obj/machinery/reagentgrinder

	name = "\improper All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/inuse = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10

	//IMPORTANT NOTE! A negative number is a multiplier, a positive number is a flat amount to add. 0 means equal to the amount of the original reagent
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/mineral/plasma = list("plasma_dust" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
		/obj/item/stack/sheet/mineral/tranquillite = list("nothing" = 20),
		/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
		/obj/item/weapon/grown/novaflower = list("capsaicin" = 0),

		//archaeology!
		///obj/item/weapon/rocksliver = list("ground_rock" = 50),


		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/weapon/reagent_containers/food/pill = list(),
		/obj/item/weapon/reagent_containers/food = list(),
		/obj/item/weapon/reagent_containers/honeycomb = list()
	)

	var/list/blend_tags = list (
		"nettle" = list("sacid" = 0),
		"deathnettle" = list("facid" = 0),
		"soybeans" = list("soymilk" = 0),
		"tomato" = list("ketchup" = 0),
		"wheat" = list("flour" = -5),
		"rice" = list("rice" = -5),
		"cherries" = list("cherryjelly" = 0),
	)

	var/list/juice_items = list (
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
	)

	var/list/juice_tags = list (
		"tomato" = list("tomatojuice" = 0),
		"carrot" = list("carrotjuice" = 0),
		"berries" = list("berryjuice" = 0),
		"banana" = list("banana" = 0),
		"potato" = list("potato" = 0),
		"lemon" = list("lemonjuice" = 0),
		"orange" = list("orangejuice" = 0),
		"lime" = list("limejuice" = 0),
		"poisonberries" = list("poisonberryjuice" = 0),
		"grapes" = list("grapejuice" = 0),
		"corn" = list("cornoil" = 0),
	)

	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/New()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	return

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return

/obj/machinery/reagentgrinder/attackby(obj/item/O, mob/user, params)

	if(istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if(beaker)
			return 1
		else
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[O] is stuck to you!</span>")
				return
			beaker =  O
			O.forceMove(src)
			update_icon()
			updateUsrDialog()
			return 0

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "<span class='warning'>The machine cannot hold anymore items.</span>")
		return 1

	//Fill machine with the plantbag!
	if(istype(O, /obj/item/weapon/storage/bag/plants))

		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			O.contents -= G
			G.forceMove(src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "<span class='notice>You fill the All-In-One grinder to the brim.</span>")
				break

		if(!O.contents.len)
			to_chat(user, "<span class='notice'>You empty the plant bag into the All-In-One grinder.</span>")

		updateUsrDialog()
		return 0


	if(!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "<span class='warning'>Cannot refine into a reagent.</span>")
		return 1

	user.unEquip(O)
	O.forceMove(src)
	holdingitems += O
	updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/attack_ai(mob/user)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!inuse)
		for(var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if(!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if(!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = 1
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = 0
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = 1
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"


		dat = {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if(is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
			dat += "<A href='?src=[UID()];action=grind'>Grind the reagents</a><BR>"
			dat += "<A href='?src=[UID()];action=juice'>Juice the reagents</a><BR><BR>"
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=[UID()];action=eject'>Eject the reagents</a><BR>"
		if(beaker)
			dat += "<A href='?src=[UID()];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."
	user << browse("<HEAD><TITLE>All-In-One Grinder</TITLE></HEAD><TT>[dat]</TT>", "window=reagentgrinder")
	onclose(user, "reagentgrinder")
	return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	switch(href_list["action"])
		if("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if("detach")
			detach()
	updateUsrDialog()
	return

/obj/machinery/reagentgrinder/proc/detach()

	if(usr.stat != 0)
		return
	if(!beaker)
		return
	beaker.forceMove(loc)
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()

	if(usr.stat != 0)
		return
	if(holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.forceMove(loc)
		holdingitems -= O
	holdingitems = list()

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/weapon/reagent_containers/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return 1
	return 0

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/weapon/grown/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_tag(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	for(var/i in blend_tags)
		if(O.seed.kitchen_tag == i)
			return blend_tags[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_tag(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	for(var/i in juice_tags)
		if(O.seed.kitchen_tag == i)
			return juice_tags[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/weapon/grown/O)
	if(!istype(O))
		return 5
	else if(O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if(!istype(O))
		return 5
	else if(O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(loc, 'sound/machines/juicer.ogg', 20, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	inuse = 1
	spawn(50)
		pixel_x = initial(pixel_x) //return to its spot after shaking
		inuse = 0
		interact(usr)
	//Snacks
	for(var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = null
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
			allowed = get_allowed_juice_by_tag(O)
		else
			allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for(var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	inuse = 1
	spawn(60)
		pixel_x = initial(pixel_x) //return to its spot after shaking
		inuse = 0
		interact(usr)
	//Snacks and Plants
	for(var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = null
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
			allowed = get_allowed_snack_by_tag(O)
		else
			allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for(var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)				//Negative amounts are multipliers for the reagent amount (Example: "amount = -5" means "reagent_amount * 5")
				if(amount == 0)
					if(O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					if(O.reagents != null && O.reagents.has_reagent("plantmatter"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("plantmatter"), space))
						O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
				else
					if(O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					if(O.reagents != null && O.reagents.has_reagent("plantmatter"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("plantmatter")*abs(amount)), space))
						O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for(var/obj/item/stack/sheet/O in holdingitems)
		var/allowed = get_allowed_by_id(O)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.amount, 1); i++)
			for(var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if(space < amount)
					break
			if(i == round(O.amount, 1))
				remove_object(O)
				break
	//Plants
	for(var/obj/item/weapon/grown/O in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for(var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount == 0)
				if(O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//xenoarch
	/*for(var/obj/item/weapon/rocksliver/O in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for(var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space), O.geological_data)

			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)*/

	//Everything else - Transfers reagents from it into beaker
	for(var/obj/item/weapon/reagent_containers/O in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)