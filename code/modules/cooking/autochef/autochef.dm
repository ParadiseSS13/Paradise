RESTRICT_TYPE(/obj/machinery/autochef)

/obj/machinery/autochef
	name = "autochef"
	desc = "An automated cooking machine."
	icon = 'icons/obj/cooking/autochef.dmi'
	icon_state = "autochef_base"
	anchored = TRUE
	pass_flags = PASSTABLE
	density = TRUE

	var/list/linked_cooking_containers = list()
	var/list/linked_machines = list()
	var/list/linked_storages = list()
	var/list/task_queue = list()

	var/screen_icon_state
	var/current_state = AUTOCHEF_TASK_QUEUE_IDLE
	var/next_step_cooldown_delay = 1 SECONDS
	var/upgrade_level = 0

	COOLDOWN_DECLARE(ingredient_search_giveup_cd)
	COOLDOWN_DECLARE(next_step_cd)

/obj/machinery/autochef/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Specify the desired output by using a food item on [src].</span>"
	. += "<span class='notice'>Start, pause, or restart [src] by clicking on it.</span>"
	. += "<span class='notice'><b>Alt-Click</b> to reset and clear all pending recipes.</span>"

/obj/machinery/autochef/Initialize(mapload)
	. = ..()

	makeSpeedProcess()

	component_parts = list()
	component_parts += new /obj/item/circuitboard/autochef(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)

	RefreshParts()

/obj/machinery/autochef/RefreshParts()
	. = ..()
	var/new_level = 0
	for(var/obj/item/stock_parts/part in component_parts)
		new_level += part.rating
	upgrade_level = floor(new_level / 4)

/obj/machinery/autochef/Destroy()
	QDEL_LIST_CONTENTS(task_queue)
	. = ..()

/obj/machinery/autochef/attack_hand(mob/user)
	if(..())
		return

	switch(current_state)
		if(AUTOCHEF_TASK_QUEUE_IDLE, AUTOCHEF_TASK_QUEUE_INTERRUPTED)
			if(length(task_queue))
				current_state = AUTOCHEF_TASK_QUEUE_RUNNING
				set_display("screen-gear")
			else
				atom_say("Please provide a food item to create.")
		if(AUTOCHEF_TASK_QUEUE_RUNNING)
			set_display(null)
			current_state = AUTOCHEF_TASK_QUEUE_IDLE

/obj/machinery/autochef/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	var/obj/item/autochef_remote/remote = used
	if(istype(remote))
		for(var/uid in remote.linkable_machine_uids)
			var/obj = locateUID(uid)
			var/success = FALSE
			if(obj)
				if(istype(obj, /obj/item/reagent_containers/cooking))
					linked_cooking_containers |= obj
					success = TRUE
				else if(istype(obj, /obj/machinery/cooking))
					linked_machines |= obj
					success = TRUE
				else if(istype(obj, /obj/machinery/smartfridge))
					linked_storages |= obj
					success = TRUE

			if(success)
				RegisterSignal(obj, COMSIG_PARENT_QDELETING, PROC_REF(unlink), override = TRUE)
				to_chat(user, "<span class='notice'>[obj] is registered to [src].</span>")
			else
				to_chat(user, "<span class='notice'>[obj] failed to register to [src].</span>")

		return ITEM_INTERACT_COMPLETE

	var/obj/item/food/food_item = used
	if(istype(food_item))
		if(current_state == AUTOCHEF_TASK_QUEUE_RUNNING)
			atom_say("Autochef running. Please wait.")
			return ITEM_INTERACT_COMPLETE

		if(length(task_queue))
			task_queue.Cut()

		var/datum/autochef_task/make_item/task = new(src, food_item.type)
		task.repeating = TRUE
		task_queue.Add(task)
		set_display(null)
		atom_say("Recipe selected: [initial(food_item.name)].")
	else
		atom_say("Cannot make [initial(food_item.name)].")

	return ITEM_INTERACT_COMPLETE

/obj/machinery/autochef/update_overlays()
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		return

	. += image(icon, icon_state = "light-on")
	if(screen_icon_state)
		. += image(icon, icon_state = screen_icon_state)

/obj/machinery/autochef/AltClick(mob/user, modifiers)
	. = ..()
	if(current_state == AUTOCHEF_TASK_QUEUE_RUNNING)
		current_state = AUTOCHEF_TASK_QUEUE_IDLE

	set_display(null)
	task_queue.Cut()
	atom_say("All recipes and tasks cleared.")

/obj/machinery/autochef/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>You screw [src]'s panel [panel_open ? "open" : "closed"].</span>")
	update_icon()

/obj/machinery/autochef/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/autochef/update_overlays()
	. = ..()
	if(panel_open)
		. += image(icon = icon, icon_state = "panel-open")

/obj/machinery/autochef/proc/set_display(name)
	screen_icon_state = name
	update_appearance()

/obj/machinery/autochef/proc/unlink(datum/source)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	return

/obj/machinery/autochef/proc/find_free_container(container_type)
	for(var/obj/item/reagent_containers/cooking/container in linked_cooking_containers)
		if(!istype(container, container_type))
			continue
		if(container.get_usable_status() != PCWJ_CONTAINER_AVAILABLE)
			continue
		if(!isInSight(src, container))
			continue
		if(container.claimed && container.claimed != src)
			continue

		return container

/obj/machinery/autochef/process()
	if(!..())
		return FALSE

	if(!COOLDOWN_FINISHED(src, next_step_cd))
		return

	COOLDOWN_START(src, next_step_cd, next_step_cooldown_delay)
	update_appearance(UPDATE_OVERLAYS)

	if(!length(task_queue))
		current_state = AUTOCHEF_TASK_QUEUE_IDLE
		return

	if(current_state == AUTOCHEF_TASK_QUEUE_RUNNING)
		var/datum/autochef_task/current_task = task_queue[1]
		current_task.resume()

		switch(current_task.current_state)
			if(AUTOCHEF_TASK_COMPLETE)
				current_task.finalize()
				if(!current_task.repeating)
					task_queue.Remove(current_task)
			if(AUTOCHEF_TASK_INTERRUPTED)
				current_state = AUTOCHEF_TASK_QUEUE_INTERRUPTED
				current_task.reset()
			if(AUTOCHEF_TASK_FAILED)
				current_state = AUTOCHEF_TASK_QUEUE_IDLE
				current_task.reset()
				set_display("screen-error")

/obj/item/paper/autochef_quickstart
	name = "Quickstart Guide: Autochef"
	icon_state = "paper"
	info = {"<b>You and Your Autochef: Quickstart</b><br />
<br />
To use your autochef, it must be linked to all the tools and items you want it to use.
<br />
This includes machines such as grills and ovens, containers such as grill grates and pans, and containers like smartfridges and food-and-drink carts.<br />
<br />
To link items to your autochef, use the autochef remote on them, and then on the autochef.<br />
<br />
To choose a recipe to make, use the food item on the autochef to scan it.<br />
<br />
To start, stop, or pause the autochef, interact with it. It will continue making the selected recipe until it runs out of ingredients or cannot use the tools it needs to make it. Once a recipe is complete, the end result will be stored in any available food-and-drink carts.<br />
<br />
Stock autochefs require all ingredients to be prepared in advance. Once upgraded, the autochef may create items it needs to finish the selected recipe. For example, a stock autochef requires burgers and cooked patties to make burgers. An upgraded autochef can bake dough to make buns, grill patties, and then resume making the burger.<br />
<br />
Autochefs may be tempermental and act in unexpected ways. If it is not working as expected:<br />
<ul>
<li>Ensure that all items it needs are linked.</li>
<li>Ensure that it has all the ingredients it needs.</li>
<li>Ensure that all machines are functional, powered, and, in the case of the grill, have enough charcoal to operate.</li>
</ul>
If all else fails, reset the autochef, scan your food item again, and restart it.
"}
