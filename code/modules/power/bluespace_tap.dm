

/datum/data/bluespace_tap_product
	var/product_name = "generic"
	var/product_path = null
	var/product_cost = 100	//cost in mining points to generate
	var/amount_bought = 0	//how often it has been bought so far (don't know if I'll even need this later, tbh)
	var/base_cost = 100		//base cost before cost increases


/datum/data/bluespace_tap_product/New(name, path, cost)
	product_name = name
	product_path = path
	product_cost = cost
	base_cost = cost


//WIP machine that serves as a power sink, to make it useful
/obj/machinery/power/bluespace_tap
	name = "Bluespace mining tap"
	icon = 'icons/obj/machines/field_generator.dmi'//TODO
	icon_state = "Field_Gen"	//just picked an existing icon for now, do this later
	use_power = NO_POWER_USE	//don't pull automatic power
	active_power_usage = 500//value that will be multiplied with mining level to generate actual power use
	var/input_level = 0	//the level the machine is set to mine at. 0 means off
	var/points = 0	//mining points
	var/actual_power_usage = 500
	density = 1
	var/component_mult = 1	//for upgraded components
	interact_offline = 1
	var/max_level = 10	//max power input level
	var/static/product_list = list(	//list of items the bluespace tap can produce
	 new /datum/data/bluespace_tap_product("Metal", /obj/item/stack/sheet/metal/fifty, 100),
	 new /datum/data/bluespace_tap_product("Glass", /obj/item/stack/sheet/glass/fifty, 150),
	 new /datum/data/bluespace_tap_product("Diamond", /obj/item/stack/sheet/mineral/diamond/fifty, 500),
	 new /datum/data/bluespace_tap_product("Plasma", /obj/item/stack/sheet/mineral/plasma/fifty, 500),
	 new /datum/data/bluespace_tap_product("Anomaly Core", /obj/item/assembly/signaler/anomaly/random, 5000000)
	)

/obj/machinery/power/bluespace_tap/New()
	..()
	//TODO add component stuff here
	if(!powernet)
		connect_to_network()
	if(isemptylist(product_list))
		setup_product_list()

/obj/machinery/power/bluespace_tap/proc/setup_product_list()
	//TODO set up the list

/obj/machinery/power/bluespace_tap/proc/increase_level()
	if(input_level < max_level)
		input_level++

/obj/machinery/power/bluespace_tap/proc/decrease_level()
	if(input_level > 0)
		input_level--


/obj/machinery/power/bluespace_tap/proc/set_level(desired_level)
	if(desired_level < 0)
		return
	if(desired_level > max_level)
		return

	input_level = desired_level



//stuff that happens regularily, ie power use and point generation
/obj/machinery/power/bluespace_tap/process()
	if(input_level == 0)
		return
	actual_power_usage = (10 ** input_level) * active_power_usage * component_mult	//each level takes one order of magnitude more power than the previous one
	if(avail() < actual_power_usage)
		decrease_level()	//turn down a level when lacking power, don't want to suck the powernet dry
		return
	draw_power(actual_power_usage)
	points += input_level * 10	//point generation


/obj/machinery/power/bluespace_tap/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["level"] = input_level
	data["points"] = points
	if(input_level)
		data["power_use"] = (10 ** input_level) * active_power_usage * component_mult
	else
		data["power_use"] = 0
	data["available_power"] = surplus()
	data["max_level"] = max_level

	var/list/listed_items = list()//a list of lists, each inner list equals a datum
	for(var/key = 1 to length(product_list))
		var/datum/data/bluespace_tap_product/A = product_list[key]
		listed_items.Add(list(list(
				"key" = key,
				"name" = A.product_name,
				"price" = A.product_cost)))


	data["product"] = listed_items
	return data


/obj/machinery/power/bluespace_tap/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)


/obj/machinery/power/bluespace_tap/attack_ai(mob/user)
	ui_interact(user)

//produces and vends the product with the desired key
/obj/machinery/power/bluespace_tap/proc/produce(key)
	var/datum/data/bluespace_tap_product/A = product_list[key]
	if(!A)	//if called with a bogus key or something, just return
		message_admins(key)	//debugging, weeeee
		return
	A.amount_bought++
	points -= A.product_cost
	A.product_cost += (A.base_cost * 0.5)
	new A.product_path(get_turf(src))	//creates product



//UI stuff below


//TODO: Do input/output here
/obj/machinery/power/bluespace_tap/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["decrease"])
		decrease_level()
	else if(href_list["increase"])
		increase_level()
	else if(href_list["set"])
		set_level(input(usr, "Enter new input level (0-[max_level])", "Bluespace Tap Input Control", input_level))
	else if(href_list["vend"])//it's not really vending as producing, but eh
		var/key = text2num(href_list["vend"])
		produce(key)



/obj/machinery/power/bluespace_tap/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	//stolen from SMES code
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "bluespace_tap.tmpi", "Bluespace Tap", 540, 380)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

//emaging allows anyone to use it. Might also add additional options that are unlocked via it.
/obj/machinery/power/bluespace_tap/emag_act(var/mob/living/user as mob)
	if(!emagged)
		emagged = 1
		if(user)
			user.visible_message("[user.name] emags the [src.name].","<span class='warning'>You short out the lock.</span>")
