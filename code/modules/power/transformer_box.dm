/// The number of over heat cycles on the transformer before signs of an overheat display
#define TRANSFORMER_OVERHEAT_START		25
/// The number of overheat cycles before the transformer starts doing dangerous things (like sparking/shocking, etc)
#define TRANSFORMER_OVERHEAT_DANGER		75
/// The number of overheat cycles before the transformer performs its shutdown sequence, effects are variable on other factors
#define TRANSFORMER_OVERHEAT_SHUTDOWN 	105

/// The default wattage setting for transformers
#define WATTAGE_SETTING_DEFAULT (40 kW)
/// The lower bound for transformer wattage settings
#define MIN_WATTAGE_SETTING (5 kW)
/// The higher bound for transformer wattage settings
#define MAX_WATTAGE_SETTING (750 kW)

/// The default transformer efficiency level when it does not have a capacitor in it
#define TRANSFORMER_DEFAULT_INEFFICIENCY 0.5
/// The transformer efficiency level when it has a capacitor in it
#define TRANSFORMER_BASIC_INEFFICIENCY 0.2
/// The default value for a transformers safety buffer
#define TRANSFORMER_DEFAULT_SAFETY_BUFFER (5 kW)
/// How much kw's the safety buffer loses every time you go up a rating on the transformers capacitor
#define TRANSFORMER_RATING_TO_SAFETY_BUFFER (2.5 kW)

/*
	* # /obj/machinery/power/transformer
	*
	* The transformer box power machine, these machines connect the global HV regional powernet to all of it's departmental subnets
	* on the station. All code pertaining to transformers is almost completely self-contained with the exception being the regional
	* powernet type which hooks into the power procs on this type to produce power on the regional net this transformer belongs to
*/
/obj/machinery/power/transformer
	name = "Transformer Box"
	desc = "a step-down transformer which transforms high-voltage power into usable low-voltage power"
	icon = 'icons/obj/power.dmi'
	icon_state = "transformer0"
	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE

	power_voltage_type = VOLTAGE_LOW
	powernet_connection_type = PW_CONNECTION_NODE

	/// If instantiated in constructed state, this is the capacitor that will be spawned in the transformer
	var/initial_capacitor_type = /obj/item/stock_parts/capacitor
	/// The part that sets the safety buffer for the transformer, higher level capacitors are more efficient but more dangerous
	var/obj/item/stock_parts/capacitor/capacitor = null
	/// A percentage of how much power is wasted every production cycle, determined by capacitor level
	var/transformer_inefficiency = TRANSFORMER_DEFAULT_INEFFICIENCY

	/// Toggle for if the transformer is converting (i.g. producing) power on the regional powernet, TRUE for ON, FALSE for OFF
	var/operating = TRUE
	/// Toggle for whether the transformer's maintenance panel is open
	var/maintenance_panel_open = FALSE

	/// How many watts were transformed in the last cycle
	var/last_output = 0

	var/wattage_setting = WATTAGE_SETTING_DEFAULT
	var/safety_buffer = TRANSFORMER_DEFAULT_SAFETY_BUFFER
	var/overheat_counter = 0
	var/overload_counter = 0

	var/overheating = FALSE
	var/overloading = FALSE

/obj/machinery/power/transformer/Initialize(mapload, panel_open)
	. = ..()
	GLOB.transformers += src

	connect_to_network(PW_CONNECTION_CONNECTOR) // connect to our HV connectors first
	connect_to_network(PW_CONNECTION_NODE) // then the wire nodes underneath

	maintenance_panel_open = panel_open
	if(!maintenance_panel_open) // panel is open b/c we're in the middle of construction
		capacitor = new initial_capacitor_type(src)
		register_capacitor(capacitor)
	operating = !maintenance_panel_open
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/transformer/Destroy()
	GLOB.transformers -= src
	QDEL_NULL(capacitor)
	return ..()

/obj/machinery/power/transformer/update_icon_state()
	. = ..()
	if(overheat_counter > TRANSFORMER_OVERHEAT_START)
		icon_state = overheat_counter >= TRANSFORMER_OVERHEAT_DANGER ? "transformer-o1" : "transformer-o2"
	else
		icon_state = maintenance_panel_open ? "transformer1" : "transformer0" // panel closed vs. panel open state

/obj/machinery/power/transformer/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/power/transformer/attacked_by(obj/item/I, mob/living/user)
	if(maintenance_panel_open && istype(capacitor, /obj/item/stock_parts/capacitor))
		if(insert_capacitor(I, user))
			return
	. = ..() // we want them to go through with the hit with wrenches
	if(!operating && iswrench(I) && prob(50))
		playsound(get_turf(src), 'sound/items/hitsound/metallic_clang.ogg', 50, FALSE)
		addtimer(CALLBACK(src, PROC_REF(transformer_startup)), 1 SECONDS)

/obj/machinery/power/transformer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A dial on it shows that it's drawing [last_output] watts</span>"
	if(maintenance_panel_open)
		. += "<span class='notice'>The maintenance panel is open.</span>"
	switch(overheat_counter) // instead of showing the count, we use descriptive indicators b/c the player will understand what it means (as opposed to a contextless number)
		if(1 to TRANSFORMER_OVERHEAT_START)
			. +=  "<span class='notice'>it is making loud noises and smells like burning rubber</span>"
		if(TRANSFORMER_OVERHEAT_START to TRANSFORMER_OVERHEAT_DANGER)
			. +=  "<span class='notice'>it is rattling loudly and smoke is rising from its vents</span>"
		if(TRANSFORMER_OVERHEAT_DANGER to TRANSFORMER_OVERHEAT_SHUTDOWN)
			. +=  "<span class='warning'>it is glowing red hot and smoke is pouring out of its vents!</span>"

// we can use this proc to get real time updates on power production and update this type's tracking variables
/obj/machinery/power/transformer/produce_direct_power(amount)
	if(!operating)
		amount = 0
	. = ..() // let the parent proc do the heavy lifting here :)
	last_output = .
	if(amount > (wattage_setting + safety_buffer))
		overheating = TRUE
		overloading = FALSE
	else if(amount < (wattage_setting - safety_buffer))
		overheating = FALSE
		overloading = TRUE

/// hijacking parent proc, transformers should consume power off the HV net they're connected to b/c it will always be powered then
/obj/machinery/power/transformer/consume_direct_power(amount)
	if(length(linked_connectors))
		var/obj/machinery/power/hv_connector/connector = linked_connectors[1] // we know it's in there due to the prev check :)
		return connector.consume_direct_power(amount)
	return FALSE // no connectors?

/obj/machinery/power/transformer/process()
	if(overheating)
		overheat()
	if(overloading)
		overload()
	update_icon(UPDATE_ICON_STATE)

/// Called every process cycle when demand is over safety threshold, handles transformers special behaviour when it overheats and calls other procs based on the overheat counter
/obj/machinery/power/transformer/proc/overheat()
	overheat_counter++
	switch(overheat_counter)
		if(1 to TRANSFORMER_OVERHEAT_START)
			return
		if(TRANSFORMER_OVERHEAT_START to TRANSFORMER_OVERHEAT_DANGER)
			. +=  "<span class='notice'>it is rattling loudly and smoke is rising from its vents</span>"
		if(TRANSFORMER_OVERHEAT_DANGER to TRANSFORMER_OVERHEAT_SHUTDOWN)
			. +=  "<span class='warning'>it is glowing red hot and smoke is pouring out of its vents!</span>"

/// Called every process cycle when demand is below safety threshold, handles transformers special behaviour when it overloads and calls other procs based on the overcharge counter
/obj/machinery/power/transformer/proc/overload()
	overload_counter++
	switch(overload_counter)
		if(1 to TRANSFORMER_OVERHEAT_START)
			return
		if(TRANSFORMER_OVERHEAT_START to TRANSFORMER_OVERHEAT_DANGER)
			. +=  "<span class='notice'>it is rattling loudly and smoke is rising from its vents</span>"
		if(TRANSFORMER_OVERHEAT_DANGER to TRANSFORMER_OVERHEAT_SHUTDOWN)
			. +=  "<span class='warning'>it is glowing red hot and smoke is pouring out of its vents!</span>"

/// When the internal capacitor calls obj_break, the signal will be caught and this proc will be called, this proc deletes the internal capacitor, updates the transformer, and produces fun side effects for players
/obj/machinery/power/transformer/proc/capacitor_blowout()
	SIGNAL_HANDLER
	if(QDELETED(capacitor))
		return // this should all be handled in capacitor_remove() already
	var/old_capacitor = capacitor
	capacitor_remove()
	qdel(old_capacitor)
	register_capacitor(new /obj/item/stock_parts/capacitor/blown_out(src))

/// WILL RUNTIME IF THERE IS NO CAPACITOR, unregisters signals from current capacitor and nulls references
/obj/machinery/power/transformer/proc/capacitor_remove()
	UnregisterSignal(capacitor, COMSIG_OBJ_BREAK)
	capacitor = null
	capacitor_on_update()

/// When the capacitor changes in any way (removal, addition, etc), we need to update the transformers stats, this proc updates the trans inefficiency and safety buffer accordingly
/obj/machinery/power/transformer/proc/capacitor_on_update()
	if(isnull(capacitor) || !capacitor.rating)
		safety_buffer = TRANSFORMER_RATING_TO_SAFETY_BUFFER
		transformer_inefficiency = TRANSFORMER_DEFAULT_INEFFICIENCY
		return
	safety_buffer = TRANSFORMER_RATING_TO_SAFETY_BUFFER
	transformer_inefficiency = TRANSFORMER_BASIC_INEFFICIENCY - (capacitor.rating * 0.05)

/// Handles behaviour when a player inserts a capacitor into the transformer, only inserts capacitor if user passes all checks appropriately
/obj/machinery/power/transformer/proc/insert_capacitor(obj/item/stock_parts/capacitor/the_capacitor, mob/living/user)
	. = FALSE
	if(capacitor)
		to_chat(user, "<span class='notice'>There's already a capacitor in [src]! You must remove [capacitor] before inserting a new one.</span>")
		return
	if(!user.drop_item()) // do this last! We only want the user to drop the item if it's guaranteed to go into the machine
		return
	. = TRUE
	the_capacitor.forceMove(src)
	register_capacitor(the_capacitor)
	user.visible_message("<span class='notice'>[user] inserts [the_capacitor] into [src].</span>",
							"<span class='notice'>You insert [the_capacitor] into [src].</span>")

/// Registers the capacitor with proper signals and adds its reference to the transformer
/obj/machinery/power/transformer/proc/register_capacitor(obj/item/stock_parts/capacitor/the_capacitor)
	RegisterSignal(the_capacitor, COMSIG_OBJ_BREAK, PROC_REF(capacitor_blowout))
	capacitor = the_capacitor
	capacitor_on_update()

/// Handles behaviour when player mob attempts to remove capacitor, only removes capacitor and puts it in players hands if all checks are passed
/obj/machinery/power/transformer/proc/attempt_remove_capacitor(mob/living/user)
	. = FALSE
	if(!capacitor)
		return
	var/time_to_takeout = 1 SECONDS
	switch(overheat_counter)
		if(0 to TRANSFORMER_OVERHEAT_START)
			user.visible_message("<span class='notice'>[user] attempts to pull [capacitor] out from inside [src].</span>",
						"<span class='danger'>You attempts to pull [capacitor] out from inside [src].")
			attack_zap_check(user)
		if(TRANSFORMER_OVERHEAT_START to TRANSFORMER_OVERHEAT_DANGER)
			user.visible_message("<span class='notice'>[user] attempts to pull [capacitor] out from inside [src]. They appear to be struggling to remove it!</span>",
									"<span class='danger'>You insert [capacitor] into [src]. It's hot to the touch!</span>")
			time_to_takeout = 3 SECONDS
			if(prob(25))
				attack_zap_check(user)
		if(TRANSFORMER_OVERHEAT_START to TRANSFORMER_OVERHEAT_DANGER)
			user.visible_message("<span class='notice'>[user] attempts to pull [capacitor] out from inside [src] while it's overheating, they must be crazy or stupid!</span>",
						"<span class='danger'>You insert [capacitor] into [src]. It's hot to the touch!</span>")
			time_to_takeout = 3 SECONDS
			if(prob(75))
				attack_zap_check(user)
		#warn todo, finish me
	add_fingerprint(capacitor, ignoregloves = TRUE) // unless the player is **dumb**, they will always have gloves on
	add_fingerprint(src, ignoregloves = TRUE)
	if(!do_after_once(user, time_to_takeout, TRUE, src))
		return
	. = TRUE
	var/obj/item/stock_parts/capacitor/the_capacitor = capacitor
	capacitor_remove() // nulls capacitor so we need to store it in a temp variable
	the_capacitor.forceMove(get_turf(src))
	user.put_in_active_hand(the_capacitor)
	attack_zap_check(user) // don't stick your unprotected hand into flowing electricity kids!

/obj/machinery/power/transformer/deconstruct(disassembled)
	if(!disassembled)
		new /obj/structure/transformer_assembly(get_turf(src))
	else
		new /obj/structure/transformer_assembly(get_turf(src), CONSTRUCTION_CIRCUIT_PRIED)
	qdel(src)

/// Plays transformer startup noise & animation + starts processing
/obj/machinery/power/transformer/proc/transformer_startup()
	operating = TRUE
	electricity_sparks(src)
	animate_rumble(src) // players love this shit
	playsound(get_turf(src), 'sound/machines/power/generator_startup.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(transformer_rumble_end)), 1 SECONDS)

/obj/machinery/power/transformer/proc/transformer_shutdown()
	#warn playsound 'transformer_shutdown'
	operating = FALSE
	electricity_sparks(src)
	animate_rumble(src)
	addtimer(CALLBACK(src, PROC_REF(transformer_rumble_end)), 1 SECONDS)

/// does what is says on the box
/obj/machinery/power/transformer/proc/transformer_rumble_end()
	animate(src, transform = matrix())

/obj/machinery/power/transformer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Transformer", name, 500, 425, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/obj/machinery/power/transformer/ui_data(mob/user)
	var/list/data = list()
	data["last_output"] = last_output
	data["wattage_setting"] = wattage_setting
	data["power_demand"] = powernet ? powernet.power_demand : 0
	data["overheating"] = overheat_counter >= TRANSFORMER_OVERHEAT_DANGER
	data["overheat_count"] = overheat_counter
	data["safety_buffer"] = TRANSFORMER_DEFAULT_SAFETY_BUFFER
	if(capacitor)
		data["capacitor"] = list(
			"name" = capacitor.name,
			"img" = "[icon2base64(icon(capacitor.icon, capacitor.icon_state, SOUTH))]"
		)
	return data

/obj/machinery/power/transformer/ui_static_data(mob/user)
	var/list/static_data = list()
	if(!powernet)
		return static_data
	static_data["apc_count"] = 0
	for(var/obj/machinery/power/apc/apc in powernet.nodes)
		static_data["apc_count"]++
	static_data["minimum_wattage"] = MIN_WATTAGE_SETTING
	static_data["maximum_wattage"] = MAX_WATTAGE_SETTING
	return static_data


/obj/machinery/power/transformer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(!.)
		return
	switch(action)
		if("toggle_power")
			if(operating && (overheat_counter || overload_counter))
				if(overheat_counter)
					to_chat(user, "<span class='notice'>You can't shutdown [src] while its overheating!</span>")
				else
					to_chat(user, "<span class='notice'>You can't shutdown [src] while its overloading!</span>")
				return
			if(operating)
				transformer_shutdown()
			else
				transformer_startup()
		if("capacitor_button")
			if(!maintenance_panel_open)
				to_chat(user, "<span class='notice'>You can't access the internal capacitor while the maintenance panel is closed!</span>")
			if(capacitor)
				attempt_remove_capacitor(ui.user)
			else
				var/obj/item/stock_parts/capacitor/user_capacitor = ui.user.get_active_hand()
				if(!istype(user_capacitor))
					insert_capacitor(I, user)

/obj/machinery/power/transformer/screwdriver_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(!maintenance_panel_open && overheat_counter)
		to_chat(user, "<span class='notice'>You can't open the panel cover on [src] while its overheating!</span>")
		attack_zap_check(user)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	playsound(get_turf(src), I.usesound, 50, TRUE)
	user.visible_message("<span class='notice'>[user] [!maintenance_panel_open ? "opens" : "closes"] [src]'s panel cover.</span>", \
						"<span class='notice'>You [!maintenance_panel_open ? "open" : "close"] [src]'s panel cover..</span>")
	maintenance_panel_open = !maintenance_panel_open
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/transformer/crowbar_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	. = TRUE
	if(operating)
		to_chat(user, "<span class='notice'>You can't pry out the circuit in [src] while its operating!</span>")
		attack_zap_check(user)
		return
	CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE
	attack_zap_check(user)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return
	playsound(get_turf(src), I.usesound, 50, TRUE)
	CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE
	deconstruct(disassembled = TRUE)
