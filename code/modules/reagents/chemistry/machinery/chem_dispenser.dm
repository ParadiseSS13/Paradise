/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = NO_POWER_USE
	idle_power_usage = 40
	var/ui_title = "Chem Dispenser 5000"
	var/energy = 100
	var/max_energy = 100
	var/amount = 30
	var/obj/item/reagent_containers/beaker = null
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
		SSnanoui.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	SSnanoui.update_uis(src) // update all UIs attached to src

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
		options[/obj/item/stock_parts/capacitor/adv] = "Add an advanced capacitor to fix it."
		options[/obj/item/stock_parts/console_screen] = "Replace the console screen to fix it."
		options[/obj/item/stock_parts/manipulator/pico] = "Upgrade to a pico manipulator to fix it."
		options[/obj/item/stock_parts/matter_bin/super] = "Give it a super matter bin to fix it."
		options[/obj/item/stock_parts/cell/super] = "Replace the reagent synthesizer with a super capacity cell to fix it."
		options[/obj/item/reagent_scanner/adv] = "Replace the reagent scanner with an advanced reagent scanner to fix it"
		options[/obj/item/stock_parts/micro_laser/high] = "Repair the reagent synthesizer with an high-power micro-laser to fix it"
		options[/obj/item/reagent_scanner/adv] = "Replace the reagent scanner with an advanced reagent scanner to fix it"
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

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", ui_title, 390, 655)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["amount"] = amount
	data["energy"] = round(energy)
	data["maxEnergy"] = round(max_energy)
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var/beakerContents[0]
	var/beakerCurrentVolume = 0
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

	var/chemicals[0]
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	return data

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
			var/obj/item/reagent_containers/glass/B = beaker
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
					var/obj/item/reagent_containers/glass/B = beaker
					var/datum/reagents/R = B.reagents
					var/id = href_list["remove"]
					R.remove_reagent(id, amount)

	if(href_list["ejectBeaker"])
		if(beaker)
			var/obj/item/reagent_containers/glass/B = beaker
			B.forceMove(loc)
			beaker = null
			overlays.Cut()
	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/attackby(obj/item/reagent_containers/B, mob/user, params)
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

	if(istype(B, /obj/item/reagent_containers/glass) || istype(B, /obj/item/reagent_containers/food/drinks))
		beaker =  B
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[B] is stuck to you!</span>")
			return
		B.forceMove(src)
		to_chat(user, "<span class='notice'>You set [B] on the machine.</span>")
		SSnanoui.update_uis(src) // update all UIs attached to src
		if(!icon_beaker)
			icon_beaker = image('icons/obj/chemical.dmi', src, "disp_beaker") //randomize beaker overlay position.
		icon_beaker.pixel_x = rand(-10,5)
		overlays += icon_beaker
		return

/obj/machinery/chem_dispenser/attackby(obj/item/B, mob/user, params)
	..()
	if(istype(B, /obj/item/multitool))
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
	var/list/special_reagents2 = list(list(""),
							list("bananahonk", "milkshake", "cafe_latte", "cafe_mocha"),
							list("triple_citrus", "icecoffe","icetea"))
	hack_message = "You change the mode from 'McNano' to 'Pizza King'."
	unhack_message = "You change the mode from 'Pizza King' to 'McNano'."
	hacked_reagents = list("thirteenloko")

/obj/machinery/chem_dispenser/soda/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/soda(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/cell/super(null)
	RefreshParts()

/obj/machinery/chem_dispenser/soda/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/soda(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/chem_dispenser/soda/RefreshParts()
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		for(var/i in 1 to M.rating)
			dispensable_reagents = sortList(dispensable_reagents | special_reagents2[i])

/obj/machinery/chem_dispenser/soda/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		return ..()
	else
		..()

	if(default_deconstruction_screwdriver(user, "minidispenser-o", "minidispenser", I))
		return

	if(exchange_parts(user, I))
		return

	if(iswrench(I))
		playsound(src, I.usesound, 50, 1)
		if(anchored)
			anchored = FALSE
			to_chat(user, "<span class='caution'>[src] can now be moved.</span>")
		else if(!anchored)
			anchored = TRUE
			to_chat(user, "<span class='caution'>[src] is now secured.</span>")

	if(panel_open)
		if(iscrowbar(I))
			if(beaker)
				var/obj/item/reagent_containers/glass/B = beaker
				B.forceMove(loc)
				beaker = null
			default_deconstruction_crowbar(I)
			return TRUE


/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	ui_title = "Booze Portal 9001"
	energy = 100
	max_energy = 100
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila", "vermouth", "cognac", "ale", "mead", "synthanol")
	var/list/special_reagents3 = list(list("iced_beer"),
								list("irishcream", "manhattan",),
								list("antihol", "synthignon", "bravebull"))
	hack_message = "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes."
	unhack_message = "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes."
	hacked_reagents = list("goldschlager", "patron", "absinthe", "ethanol", "nothing", "sake")

/obj/machinery/chem_dispenser/beer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/cell/super(null)
	RefreshParts()

/obj/machinery/chem_dispenser/beer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/chem_dispenser/beer/RefreshParts()
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		for(var/i in 1 to M.rating)
			dispensable_reagents = sortList(dispensable_reagents | special_reagents3[i])

/obj/machinery/chem_dispenser/beer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		return ..()
	else
		..()

	if(default_deconstruction_screwdriver(user, "minidispenser-o", "minidispenser", I))
		return

	if(exchange_parts(user, I))
		return

	if(iswrench(I))
		playsound(src, I.usesound, 50, 1)
		if(anchored)
			anchored = FALSE
			to_chat(user, "<span class='caution'>[src] can now be moved.</span>")
		else if(!anchored)
			anchored = TRUE
			to_chat(user, "<span class='caution'>[src] is now secured.</span>")

	if(panel_open)
		if(iscrowbar(I))
			if(beaker)
				var/obj/item/reagent_containers/glass/B = beaker
				B.forceMove(loc)
				beaker = null
			default_deconstruction_crowbar(I)
			return TRUE

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
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/cell/super(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/RefreshParts()
	var/time = 0
	var/temp_energy = 0
	var/i
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		temp_energy += M.rating
	temp_energy--
	max_energy = temp_energy * 5  //max energy = (bin1.rating + bin2.rating - 1) * 5, 5 on lowest 25 on highest
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		time += C.rating
	for(var/obj/item/stock_parts/cell/P in component_parts)
		time += round(P.maxcharge, 10000) / 10000
	recharge_delay = 10 / (time/2)         //delay between recharges, double the usual time on lowest 33% less than usual on highest
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		for(i=1, i<=M.rating, i++)
			dispensable_reagents = sortList(dispensable_reagents | special_reagents[i])

/obj/machinery/chem_dispenser/constructable/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
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

	if(istype(I, /obj/item/wrench))
		playsound(src, I.usesound, 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class='caution'>[src] can now be moved.</span>")
		else if(!anchored)
			anchored = 1
			to_chat(user, "<span class='caution'>[src] is now secured.</span>")

	if(panel_open)
		if(istype(I, /obj/item/crowbar))
			if(beaker)
				var/obj/item/reagent_containers/glass/B = beaker
				B.forceMove(loc)
				beaker = null
			default_deconstruction_crowbar(I)
			return 1
