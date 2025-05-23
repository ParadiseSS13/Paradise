/obj/item/circuitboard/organ_analyzer
	board_name = "Organ Analyzer"
	icon_state = "science"
	build_path = /obj/machinery/organ_analyzer
	board_type = "machine"
	origin_tech = "biotech=2"

	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/machinery/organ_analyzer
	name = "Organ Analysis Chamber"
	desc = "A sophisticated machine made to break down and study samples of alien organs. Only revitalized organs are valid for analysis."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ_analyzer0"
	idle_power_consumption = 40
	layer = ABOVE_OBJ_LAYER
	resistance_flags = FIRE_PROOF|ACID_PROOF
	// what organ are we currently holding?
	var/obj/item/organ/internal/contains_organ
	// Are we actively taking apart an organ?
	var/processing_organ = FALSE
	// How long until the machine finishes?
	var/time_to_complete = 15 SECONDS
	// How good is the machine at giving credits for our work?
	var/reward_coeff

	COOLDOWN_DECLARE(process_organ)

/obj/machinery/organ_analyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/organ_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	update_appearance(UPDATE_OVERLAYS)


/obj/machinery/organ_analyzer/update_overlays()
	underlays = null
	if(contains_organ)
		var/mutable_appearance/underlay_organ = mutable_appearance(layer = OBJ_LAYER, plane = GAME_PLANE)
		underlay_organ.icon = icon = 'icons/obj/xeno_organs.dmi'
		underlay_organ.icon_state = contains_organ.icon_state
		underlay_organ.pixel_y = -3
		underlays += underlay_organ
	var/mutable_appearance/underlay_base = mutable_appearance(layer = BELOW_OBJ_LAYER, plane = GAME_PLANE)
	underlay_base.icon = 'icons/obj/xeno_organs.dmi'
	if(processing_organ)
		underlay_base.icon_state += "organ_analyzer_on"
	else
		underlay_base.icon_state += "organ_analyzer_off"
	underlays += underlay_base

/obj/machinery/organ_analyzer/RefreshParts()
	reward_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		reward_coeff += S.rating
	reward_coeff = reward_coeff / 2 // average the parts

/obj/machinery/organ_analyzer/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(processing_organ || contains_organ)
		to_chat(user, "<span class='warning'>The machine cannot be opened while holding an organ! Remove it first.</span>")
		return TRUE
	default_deconstruction_screwdriver(user, "organ_analyzer1", "organ_analyzer0", I)

/obj/machinery/organ_analyzer/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/organ_analyzer/attack_hand(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't interact with the machine while the panel is open!</span>")
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(contains_organ)
		if(processing_organ)
			to_chat(user, "<span class='warning'>The machine is already analyzing the organ!</span>")
			return
		else
			COOLDOWN_START(src, process_organ, time_to_complete)
			processing_organ = TRUE
			playsound(src, 'sound/machines/organ_analyzer.ogg', 60, FALSE)
			update_appearance(UPDATE_OVERLAYS)

/obj/machinery/organ_analyzer/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/organ/internal))
		to_chat(user, "<span class='warning'>The machines rejects [used]; it finds no possible potential in it.</span>")
		return ITEM_INTERACT_COMPLETE
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't interact with the machine while the panel is open!</span>")
		return ITEM_INTERACT_COMPLETE
	var/obj/item/organ/internal/organ = used
	if(organ.is_xeno_organ)
		if(organ.type in GLOB.scanned_organs)
			if(GLOB.scanned_organs[organ.type] >= 3) // No more than
				to_chat(user, "<span class='warning'>The analyzer rejects the organ. It's gotten as much data as it can from this type of organ.</span>")
				return ITEM_INTERACT_COMPLETE
			else
				GLOB.scanned_organs[organ.type]++
		else
			GLOB.scanned_organs += list(organ.type = 1)
		contains_organ = organ
		user.transfer_item_to(organ, src)
		src.visible_message("[user] inserts [organ] into the recepticle.")
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/organ_analyzer/AltClick(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't interact with the machine while the panel is open!</span>")
		return
	if(processing_organ)
		to_chat(user, "<span class='warning'>You cannot remove an organ currently being processed!</span>")
		return
	if(contains_organ)
		user.put_in_hands(contains_organ)
		contains_organ = null
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/organ_analyzer/process()
	..()
	if(stat & (NOPOWER|BROKEN))
		processing_organ = FALSE
		update_appearance(UPDATE_OVERLAYS)
		return
	if(processing_organ && COOLDOWN_FINISHED(src, process_organ))
		complete_analysis()

/obj/machinery/organ_analyzer/proc/complete_analysis()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	processing_organ = FALSE

	if(contains_organ.hidden_origin_tech)
		handle_disk()

	var/account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
	var/quality_modifier = 1
	if(contains_organ.organ_quality == ORGAN_PRISTINE)
		quality_modifier = 2
	if(contains_organ.organ_quality == ORGAN_DAMAGED)
		quality_modifier = 0.5
	var/final_value = round((contains_organ.analyzer_price * reward_coeff) * quality_modifier)
	station_db.credit_account(account, final_value, "Organ Analyzation Subsidy", "Xenobiology Organ Analyzer", FALSE)
	SSblackbox.record_feedback("amount", "Organ_Analyzer_Revenue", final_value)
	atom_say("Analysis complete. Depositing [final_value] credits into the science account.")
	qdel(contains_organ)
	contains_organ = null
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/organ_analyzer/proc/handle_disk()
	var/obj/item/disk/tech_disk/disk = new /obj/item/disk/tech_disk(src.loc)
	var/datum/tech/tech

	switch(contains_organ.hidden_origin_tech)
		if(TECH_MATERIAL)
			tech = new /datum/tech/materials
		if(TECH_ENGINEERING)
			tech = new /datum/tech/engineering
		if(TECH_PLASMA)
			tech = new /datum/tech/plasmatech
		if(TECH_POWER)
			tech = new /datum/tech/powerstorage
		if(TECH_BLUESPACE)
			tech = new /datum/tech/bluespace
		if(TECH_BIO)
			tech = new /datum/tech/biotech
		if(TECH_COMBAT)
			tech = new /datum/tech/combat
		if(TECH_MAGNETS)
			tech = new /datum/tech/magnets
		if(TECH_PROGRAM)
			tech = new /datum/tech/programming
		if(TECH_TOXINS)
			tech = new /datum/tech/toxins
		if(TECH_SYNDICATE)
			tech = new /datum/tech/syndicate
		if(TECH_ABDUCTOR)
			tech = new /datum/tech/abductor

	tech.level = contains_organ.hidden_tech_level
	disk.load_tech(tech)
