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
	var/beaker = null
	var/recharged = 0
	var/hackedcheck = 0
	var/list/dispensable_reagents = list("hydrogen","lithium","carbon","nitrogen","oxygen","fluorine",
	"sodium","aluminum","silicon","phosphorus","sulfur","chlorine","potassium","iron",
	"copper","mercury","plasma","radium","water","ethanol","sugar","tungsten","iodine","bromine","silver")
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
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_dispenser/blob_act()
	if (prob(50))
		del(src)

/obj/machinery/chem_dispenser/meteorhit()
	del(src)
	return

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

/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main",var/datum/nanoui/ui = null, var/force_open = 1)
	if(broken_requirements.len)
		user << "<span class='warning'>[src] is broken. [broken_requirements[broken_requirements[1]]]</span>"
		return


	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["energy"] = round(energy)
	data["maxEnergy"] = round(max_energy)
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker:reagents && beaker:reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker:reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id"=R.id, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker:volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", ui_title, 390, 655)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["amount"])
		amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		if (amount < 0) // Since the user can actually type the commands himself, some sanity checking
			amount = 0
		if (amount > 100)
			amount = 100

	if(href_list["dispense"])
		if (dispensable_reagents.Find(href_list["dispense"]) && beaker != null)
			var/obj/item/weapon/reagent_containers/glass/B = src.beaker
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
			B.loc = loc
			beaker = null
			overlays.Cut()
	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/reagent_containers/B as obj, var/mob/user as mob, params)
	if(isrobot(user))
		return

	if(broken_requirements.len && B.type == broken_requirements[1])
		broken_requirements -= broken_requirements[1]
		user << "<span class='notice'>You fix [src].</span>"
		if(istype(B,/obj/item/stack))
			var/obj/item/stack/S = B
			S.use(1)
		else
			user.drop_item()
			del(B)
		return

	if(src.beaker)
		user << "Something is already loaded into the machine."
		return

	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B,/obj/item/weapon/reagent_containers/food))
		src.beaker =  B
		user.drop_item()
		B.loc = src
		user << "You set [B] on the machine."
		nanomanager.update_uis(src) // update all UIs attached to src
		if(!icon_beaker)
			icon_beaker = image('icons/obj/chemical.dmi', src, "disp_beaker") //randomize beaker overlay position.
		icon_beaker.pixel_x = rand(-10,5)
		overlays += icon_beaker
		return

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob, params)
	..()
	if(istype(B, /obj/item/device/multitool))
		if(hackedcheck == 0)
			user << hack_message
			dispensable_reagents += hacked_reagents
			hackedcheck = 1
			return

		else
			user << unhack_message
			dispensable_reagents -= hacked_reagents
			hackedcheck = 0
			return

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
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
	dispensable_reagents = list("water","ice", "milk", "soymilk", "coffee","tea","hot_coco", "cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime", "grapejuice","sugar","orangejuice", "lemonjuice", "limejuice","tomatojuice", "banana", "watermelonjuice", "carrotjuice", "potato", "berryjuice")
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
	dispensable_reagents = list("ice","cream", "cider", "beer","kahlua","whiskey","wine","vodka","gin","rum","tequilla","vermouth","cognac","ale","mead")
	hack_message = "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes."
	unhack_message = "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes."
	hacked_reagents = list("goldschlager","patron", "absinthe", "ethanol", "nothing")

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
	var/list/special_reagents = list(list("hydrogen", "oxygen", "silicon", "phosphorus", "sulfur", "carbon", "nitrogen", "tungsten", "water"),
						 		list("lithium", "sugar", "copper", "mercury", "sodium","iodine","bromine"),
								list("ethanol", "chlorine", "potassium", "aluminum","plasma", "radium", "fluorine", "iron", "silver"))

/obj/machinery/chem_dispenser/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/weapon/stock_parts/cell/super(src)
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

/obj/machinery/chem_dispenser/constructable/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(panel_open)
			user << "<span class='notice'>Close the maintenance panel first.</span>"
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
			user << "<span class='caution'>The [src] can now be moved.</span>"
		else if(!anchored)
			anchored = 1
			user << "<span class='caution'>The [src] is now secured.</span>"

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.loc = loc
				beaker = null
			default_deconstruction_crowbar(I)
			return 1

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/patchamount = 10
	var/bottlesprite = "1" //yes, strings
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
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/blob_act()
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/meteorhit()
	qdel(src)
	return

/obj/machinery/chem_master/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_master/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob, params)

	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))

		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return
		src.beaker = B
		user.drop_item()
		B.loc = src
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(istype(B, /obj/item/weapon/storage/pill_bottle))

		if(src.loaded_pill_bottle)
			user << "A pill bottle is already loaded into the machine."
			return

		src.loaded_pill_bottle = B
		user.drop_item()
		B.loc = src
		user << "You add the pill bottle into the dispenser slot!"
		src.updateUsrDialog()
	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER)) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	src.add_fingerprint(usr)
	usr.set_machine(src)


	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null
	else if(href_list["close"])
		usr << browse(null, "window=chemmaster")
		usr.unset_machine()
		return

	if (href_list["print_p"])
		if (!(src.printing))
			src.printing = 1
			for(var/mob/O in viewers(usr))
				O.show_message("\blue \the [src] rattles and prints out a sheet of paper.", 1)
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
			P.info = "<CENTER><B>Chemical Analysis</B></CENTER><BR>"
			P.info += "<b>Time of analysis:</b> [worldtime2text(world.time)]<br><br>"
			P.info += "<b>Chemical name:</b> [href_list["name"]]<br>"
			if(href_list["name"] == "Blood")
				var/datum/reagents/R = beaker:reagents
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
			src.printing = null

	if(beaker)
		var/datum/reagents/R = beaker:reagents
		if (href_list["analyze"])
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
				dat += "<BR><BR><A href='?src=\ref[src];print_p=1;desc=[href_list["desc"]];name=[href_list["name"]]'>(Print Analysis)</A><BR>"
				dat += "<A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
			return

		else if (href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				R.trans_id_to(src, id, amount)

		else if (href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if (href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)


		else if (href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))

		else if (href_list["toggle"])
			mode = !mode

		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			if(beaker)
				beaker:loc = src.loc
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"
		else if (href_list["createpill"] || href_list["createpill_multiple"])
			if(!condi)
				var/count = 1
				if (href_list["createpill_multiple"]) count = isgoodnumber(input("Select the number of pills to make.", 10, pillamount) as num)
				if (count > 20) count = 20	//Pevent people from creating huge stacks of pills easily. Maybe move the number to defines?
				var/amount_per_pill = reagents.total_volume/count
				if (amount_per_pill > 50) amount_per_pill = 50
				var/name = reject_bad_text(input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)"))
				while (count--)
					var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
					if(!name) name = reagents.get_master_reagent_name()
					P.name = "[name] pill"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					P.icon_state = "pill"+pillsprite
					reagents.trans_to(P,amount_per_pill)
					if(src.loaded_pill_bottle)
						if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
							P.loc = loaded_pill_bottle
							src.updateUsrDialog()
			else
				var/name = reject_bad_text(input(usr,"Name:","Name your bag!",reagents.get_master_reagent_name()))
				var/obj/item/weapon/reagent_containers/food/condiment/pack/P = new/obj/item/weapon/reagent_containers/food/condiment/pack(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.originalname = name
				P.name = "[name] pack"
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P,10)
		else if (href_list["createpatch"] || href_list["createpatch_multiple"])
			if(!condi)
				var/count = 1
				if (href_list["createpatch_multiple"]) count = isgoodnumber(input("Select the number of patches to make.", 10, patchamount) as num)
				if (count > 20) count = 20	//Pevent people from creating huge stacks of patches easily. Maybe move the number to defines?
				var/amount_per_patch = reagents.total_volume/count
				if (amount_per_patch > 50) amount_per_patch = 50
				var/name = reject_bad_text(input(usr,"Name:","Name your patch!","[reagents.get_master_reagent_name()] ([amount_per_patch] units)"))
				while (count--)
					var/obj/item/weapon/reagent_containers/pill/patch/P = new/obj/item/weapon/reagent_containers/pill/patch(src.loc)
					if(!name) name = reagents.get_master_reagent_name()
					P.name = "[name] patch"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					reagents.trans_to(P,amount_per_patch)
		else if (href_list["createbottle"])
			if(!condi)
				var/name = reject_bad_text(input(usr,"Name:","Name your bottle!",reagents.get_master_reagent_name()))
				var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "bottle"+bottlesprite
				reagents.trans_to(P,30)
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
				reagents.trans_to(P,50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 20 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[i]\"><img src=\"bottle[i].png\" /></a></td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]

	src.updateUsrDialog()
	return

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.set_machine(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "bottle" + num2text(i)), "bottle[i].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker:reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "[G.name] , [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (50 units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
			dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
			dat += "<HR><BR><A href='?src=\ref[src];createpatch=1'>Create patch (50 units max)</A><BR>"
			dat += "<A href='?src=\ref[src];createpatch_multiple=1'>Create multiple patches</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (30 units max)</A>"
		else
			dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pack (10 units max)</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
	if(!condi)
		user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	else
		user << browse("<TITLE>Condimaster 3000</TITLE>Condimaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	onclose(user, "chem_master")
	return

/obj/machinery/chem_master/proc/isgoodnumber(var/num)
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



/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/*

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/weapon/circuitboard/pandemic
	//use_power = 1
	//idle_power_usage = 20		//defaults make more sense.
	var/temphtml = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null


/obj/machinery/computer/pandemic/set_broken()
	icon_state = (src.beaker?"mixer1_b":"mixer0_b")
	stat |= BROKEN


/obj/machinery/computer/pandemic/power_change()

	if(stat & BROKEN)
		icon_state = (src.beaker?"mixer1_b":"mixer0_b")

	else if(powered())
		icon_state = (src.beaker?"mixer1":"mixer0")
		stat &= ~NOPOWER

	else
		spawn(rand(0, 15))
			src.icon_state = (src.beaker?"mixer1_nopower":"mixer0_nopower")
			stat |= NOPOWER


/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN)) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	usr.set_machine(src)
	if(!beaker) return

	if (href_list["create_vaccine"])
		if(!src.wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			if(B)
				var/path = href_list["create_vaccine"]
				var/vaccine_type = text2path(path)
				var/datum/disease/D = null

				if(!vaccine_type)
					D = archive_diseases[path]
					vaccine_type = path
				else
					if(vaccine_type in diseases)
						D = new vaccine_type(0, null)

				if(D)
					B.name = "[D.name] vaccine bottle"
					B.reagents.add_reagent("vaccine",15,vaccine_type)
					wait = 1
					var/datum/reagents/R = beaker.reagents
					var/datum/reagent/blood/Blood = null
					for(var/datum/reagent/blood/L in R.reagent_list)
						if(L)
							Blood = L
							break
					var/list/res = Blood.data["resistances"]
					spawn(res.len*200)
						src.wait = null
		else
			src.temphtml = "The replicator is not ready yet."
		src.updateUsrDialog()
		return
	else if (href_list["create_virus_culture"])
		if(!wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			B.icon_state = "bottle3"
			var/type = text2path(href_list["create_virus_culture"])//the path is received as string - converting
			var/datum/disease/D = null
			if(!type)
				var/datum/disease/advance/A = archive_diseases[href_list["create_virus_culture"]]
				if(A)
					D = new A.type(0, A)
			else
				if(type in diseases) // Make sure this is a disease
					D = new type(0, null)
			var/list/data = list("viruses"=list(D))
			var/name = sanitize(input(usr,"Name:","Name the culture",D.name))
			if(!name || name == " ") name = D.name
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			src.updateUsrDialog()
			wait = 1
			spawn(1000)
				src.wait = null
		else
			src.temphtml = "The replicator is not ready yet."
		src.updateUsrDialog()
		return
	else if (href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		src.updateUsrDialog()
		return
	else if (href_list["eject"])
		beaker:loc = src.loc
		beaker = null
		icon_state = "mixer0"
		src.updateUsrDialog()
		return
	else if(href_list["clear"])
		src.temphtml = ""
		src.updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = stripped_input(usr, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(stat & (NOPOWER|BROKEN)) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return
		var/id = href_list["name_disease"]
		if(archive_diseases[id])
			var/datum/disease/advance/A = archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in active_diseases)
				AD.Refresh()
		src.updateUsrDialog()


	else
		usr << browse(null, "window=pandemic")
		src.updateUsrDialog()
		return

	src.add_fingerprint(usr)
	return

/obj/machinery/computer/pandemic/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pandemic/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pandemic/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	var/dat = ""
	if(src.temphtml)
		dat = "[src.temphtml]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
	else if(!beaker)
		dat += "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		var/datum/reagent/blood/Blood = null
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break
		if(!R.total_volume||!R.reagent_list.len)
			dat += "The beaker is empty<BR>"
		else if(!Blood)
			dat += "No blood sample found in beaker"
		else if(!Blood.data)
			dat += "No blood data found in beaker."
		else
			dat += "<h3>Blood sample data:</h3>"
			dat += "<b>Blood DNA:</b> [(Blood.data["blood_DNA"]||"none")]<BR>"
			dat += "<b>Blood Type:</b> [(Blood.data["blood_type"]||"none")]<BR>"


			if(Blood.data["viruses"])
				var/list/vir = Blood.data["viruses"]
				if(vir.len)
					for(var/datum/disease/D in Blood.data["viruses"])
						if(!D.hidden[PANDEMIC])


							var/disease_creation = D.type
							if(istype(D, /datum/disease/advance))

								var/datum/disease/advance/A = D
								D = archive_diseases[A.GetDiseaseID()]
								disease_creation = A.GetDiseaseID()
								if(D.name == "Unknown")
									dat += "<b><a href='?src=\ref[src];name_disease=[A.GetDiseaseID()]'>Name Disease</a></b><BR>"

							if(!D)
								CRASH("We weren't able to get the advance disease from the archive.")

							dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[disease_creation]'>Create virus culture bottle</A>":"none"]<BR>"
							dat += "<b>Common name:</b> [(D.name||"none")]<BR>"
							dat += "<b>Description: </b> [(D.desc||"none")]<BR>"
							dat += "<b>Spread:</b> [(D.spread||"none")]<BR>"
							dat += "<b>Possible cure:</b> [(D.cure||"none")]<BR><BR>"

							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/A = D
								dat += "<b>Symptoms:</b> "
								var/english_symptoms = list()
								for(var/datum/symptom/S in A.symptoms)
									english_symptoms += S.name
								dat += english_list(english_symptoms)


			dat += "<BR><b>Contains antibodies to:</b> "
			if(Blood.data["resistances"])
				var/list/res = Blood.data["resistances"]
				if(res.len)
					dat += "<ul>"
					for(var/type in Blood.data["resistances"])
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/advance/A = archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type(0, null)
							disease_name = D.name

						dat += "<li>[disease_name] - <A href='?src=\ref[src];create_vaccine=[type]'>Create vaccine bottle</A></li>"
					dat += "</ul><BR>"
				else
					dat += "nothing<BR>"
			else
				dat += "nothing<BR>"
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"

	user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
	onclose(user, "pandemic")
	return


/obj/machinery/computer/pandemic/attackby(var/obj/I as obj, var/mob/user as mob, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(stat & (NOPOWER|BROKEN)) return
		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return

		src.beaker =  I
		user.drop_item()
		I.loc = src
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else
		..()
	return

*/
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
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
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/mineral/plasma = list("plasma" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/clown = list("banana" = 20),
		/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
		/obj/item/weapon/grown/nettle = list("sacid" = 0),
		/obj/item/weapon/grown/deathnettle = list("facid" = 0),
		/obj/item/weapon/grown/novaflower = list("capsaicin" = 0),

		//Blender Stuff
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
		///obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk = list("rice" = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium = list("plasticide" = 5),


		//archaeology!
		/obj/item/weapon/rocksliver = list("ground_rock" = 50),



		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/weapon/reagent_containers/pill = list(),
		/obj/item/weapon/reagent_containers/food = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon = list("lemonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = list("orangejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime = list("limejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries = list("poisonberryjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = list("grapejuice" = 0),
	)




	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/New()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	return

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob, params)


	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 1
		else
			src.beaker =  O
			user.drop_item()
			O.loc = src
			update_icon()
			src.updateUsrDialog()
			return 0

	if(holdingitems && holdingitems.len >= limit)
		usr << "The machine cannot hold anymore items."
		return 1

	//Fill machine with the plantbag!
	if(istype(O, /obj/item/weapon/storage/bag/plants))

		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			O.contents -= G
			G.loc = src
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				user << "You fill the All-In-One grinder to the brim."
				break

		if(!O.contents.len)
			user << "You empty the plant bag into the All-In-One grinder."

		src.updateUsrDialog()
		return 0


	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		user << "Cannot refine into a reagent."
		return 1

	user.unEquip(O)
	O.loc = src
	holdingitems += O
	src.updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!inuse)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if (!beaker)
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
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
			dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += "<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
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
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/reagentgrinder/proc/detach()

	if (usr.stat != 0)
		return
	if (!beaker)
		return
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()

	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems = list()

/obj/machinery/reagentgrinder/proc/is_allowed(var/obj/item/weapon/reagent_containers/O)
	for (var/i in blend_items)
		if(istype(O, i))
			return 1
	return 0

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(var/obj/item/weapon/grown/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(var/obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(var/obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(var/obj/item/weapon/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(var/obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(var/obj/item/O)
	holdingitems -= O
	del(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
	inuse = 1
	spawn(50)
		inuse = 0
		interact(usr)
	//Snacks
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	inuse = 1
	spawn(60)
		inuse = 0
		interact(usr)
	//Snacks and Plants
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for (var/obj/item/stack/sheet/O in holdingitems)
		var/allowed = get_allowed_by_id(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.amount, 1); i++)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if (space < amount)
					break
			if (i == round(O.amount, 1))
				remove_object(O)
				break
	//Plants
	for (var/obj/item/weapon/grown/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//xenoarch
	for(var/obj/item/weapon/rocksliver/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space), O.geological_data)

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//Everything else - Transfers reagents from it into beaker
	for (var/obj/item/weapon/reagent_containers/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)
