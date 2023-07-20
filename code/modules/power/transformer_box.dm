#define TRANSFORMER_WATTAGE_DEFAULT 40000
#define TRANSFORMER_SAFETY_BUFFER 100000

#define CONSTRUCTION_COMPLETE 0 //No construction done - functioning as normal
#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning, can wrench to remove circuit board

/obj/machinery/power/transformer
	name = "Transformer Box"
	desc = "a step-down transformer which transforms high-voltage power into usable low-voltage power"
	icon = 'icons/obj/power.dmi'
	icon_state = "transformer"
	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE

	power_voltage_type = VOLTAGE_LOW
	powernet_connection_type = PW_CONNECTION_NODE

	var/construction_step = CONSTRUCTION_COMPLETE
	var/last_output = 0

	var/wattage_setting = TRANSFORMER_WATTAGE_DEFAULT
	var/safety_buffer = TRANSFORMER_SAFETY_BUFFER
	var/overheat_counter = 0
	var/overload_counter = 0

/obj/machinery/power/transformer/Initialize(mapload, initial_construction_step)
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

	GLOB.transformers += src

	connect_to_network(PW_CONNECTION_CONNECTOR) // connect to our HV connectors first
	connect_to_network(PW_CONNECTION_NODE) // then the wire nodes underneath

	construction_step = initial_construction_step
	update_icon()

/obj/machinery/power/transformer/Destroy()
	GLOB.transformers -= src
	return ..()

/obj/machinery/power/transformer/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/power/transformer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A dial on it shows that it's drawing [last_output] watts</span>"
	. += "<span class='notice'>A dial on it shows that it's overheating at [overheat_counter] counts</span>"

	switch(overheat_counter)
		if(0 to 25)
			. +=  "<span class='notice'>it is making loud noises and smells like burning rubber</span>"
		if(25 to 50)
			. +=  "<span class='notice'>it is rattling loudly and smoke is rising from its vents</span>"
		if(50 to 99)
			. +=  "<span class='warning'>it is glowing red hot and smoke is pouring out of its vents!</span>"


#warn Add Construction Mechanics Here

/obj/machinery/power/transformer/produce_direct_power(amount)
	. = ..()
	last_output = . ? amount : 0
	if(amount > (wattage_setting + safety_buffer))
		overheat_counter++
	else if(amount < (wattage_setting - safety_buffer))
		overload_counter++

/obj/machinery/power/transformer/proc/overheat()

/obj/machinery/power/transformer/proc/overload()

/obj/machinery/power/transformer/proc/update_safety_buffer(amount)
	var/obj/item/stock_parts/capacitor/capacitor = component_parts[1]
	wattage_setting = capacitor.level * 25000 + TRANSFORMER_SAFETY_BUFFER

/obj/machinery/power/transformer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Transformer", name, 500, 500, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/obj/machinery/power/transformer/ui_data(mob/user)
	var/list/data = list()
	data["last_output"] = last_output
	data["wattage_setting"] = wattage_setting
	data["power_demand"] = powernet.power_demand

	return data

/obj/machinery/power/transformer/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["apc_count"] = 0
	for(var/obj/machinery/power/apc/apc in powernet.nodes)
		static_data["apc_count"]++
	return static_data

/obj/machinery/power/transformer/screwdriver_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(construction_step == CONSTRUCTION_COMPLETE && overheat_counter)
		to_chat(user, "<span class='notice'>You can't open the panel cover on [src] while its overheating!</span>")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] [construction_step == CONSTRUCTION_COMPLETE ? "opens" : "closes"] [src]'s panel cover.</span>", \
						"<span class='notice'>You [construction_step == CONSTRUCTION_COMPLETE ? "open" : "close"] [src]'s panel cover..</span>")
	construction_step = (construction_step == CONSTRUCTION_COMPLETE) ? CONSTRUCTION_PANEL_OPEN : CONSTRUCTION_COMPLETE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/power/transformer/crowbar_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return TRUE
	CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE
	deconstruct(disassembled = TRUE)

/obj/machinery/power/transformer/deconstruct(disassembled)
	if(!disassembled)
		new /obj/structure/transformer_assembly()
	else
		new /obj/structure/transformer_assembly(CONSTRUCTION_CIRCUIT_PRIED)
	qdel(src)
