/obj/item/circuitboard/organ_analyzer
	board_name = "Organ Analyzer"
	icon_state = "science"
	build_path = /obj/machinery/organ_analyzer
	board_type = "machine"
	origin_tech = "biotech=2"

	var/reward_coeff

	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 1
	)

/obj/machinery/organ_analyzer
	name = "Organ Analysis Chamber"
	desc = "A sophisticated machine made to break down and study samples of alien organs. Only revitalized organs are valid for analysis."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ_analyzer0"
	idle_power_consumption = 40
	resistance_flags = FIRE_PROOF|ACID_PROOF

/obj/machinery/organ_analyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/organ_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/organ_analyzer/RefreshParts()
	reward_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		reward_coeff += S.rating
	reward_coeff = reward_coeff / 2 // average the parts

/obj/machinery/organ_analyzer/power_change()
	if(has_power())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/organ_analyzer/item_interaction(mob/living/user, obj/item/used, list/modifiers)


/obj/machinery/chem_heater/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/chem_heater/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "organ_analyzer1", "organ_analyzer0")

/obj/machinery/chem_heater/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	eject_beaker()
	default_deconstruction_crowbar(user, I)

/obj/machinery/chem_heater/attack_hand(mob/user)
	ui_interact(user)
