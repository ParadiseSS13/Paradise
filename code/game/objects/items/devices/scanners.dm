/*
CONTAINS:
T-RAY SCANNER
REAGENT SCANNERS
SLIME SCANNER
*/

////////////////////////////////////////
// MARK:	T-ray scanner
////////////////////////////////////////
/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 300)
	origin_tech = "magnets=1;engineering=1"
	var/on = FALSE

/obj/item/t_scanner/Destroy()
	if(on)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self__legacy__attackchain(mob/user)
	toggle_on()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 8, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer))
		if(O.level != 1)
			continue

		if(O.invisibility == INVISIBILITY_MAXIMUM)
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			if(MA.layer < TURF_LAYER)
				MA.layer += TRAY_SCAN_LAYER_OFFSET
			MA.plane = GAME_PLANE
			I.appearance = MA
			t_ray_images += I
	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

////////////////////////////////////////
// MARK:	Reagent scanners
////////////////////////////////////////
/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents and blood types."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = FALSE
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)
	new_attack_chain = TRUE

/obj/item/reagent_scanner/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	do_scan(target, user)

/obj/item/reagent_scanner/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	do_scan(target, user)

/obj/item/reagent_scanner/proc/do_scan(atom/target, mob/living/user)
	if(user.stat != CONSCIOUS)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	if(!target.reagents)
		to_chat(user, SPAN_NOTICE("No significant chemical agents found in [target]."))
		return

	if(!length(target.reagents.reagent_list))
		to_chat(user, SPAN_NOTICE("No active chemical agents found in [target]."))
		return

	var/dat
	var/blood_type = ""

	var/one_percent = target.reagents.total_volume / 100
	for(var/datum/reagent/R in target.reagents.reagent_list)
		if(R.id != "blood")
			dat += "<br>[TAB][SPAN_NOTICE("[R] [details ? ":([R.volume / one_percent]%)" : ""]")]"
		else
			blood_type = R.data["blood_type"]
			dat += "<br>[TAB][SPAN_NOTICE("[blood_type ? "[blood_type]" : ""] [R.data["species"]] [R.name] [details ? ":([R.volume / one_percent]%)" : ""]")]"

	to_chat(user, SPAN_NOTICE("Chemicals found: [dat]"))
	datatoprint = dat
	scanning = FALSE

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/reagent_scanner/proc/print_report(mob/user)
	if(!istype(user))
		return

	if(scanning)
		to_chat(user, SPAN_NOTICE("[src] has no logs or is already in use."))
		return

	user.visible_message(SPAN_WARNING("[src] rattles and prints out a sheet of paper."))
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	sleep(5 SECONDS)

	var/obj/item/paper/P = new(get_turf(src))
	P.name = "Reagent Scanner Report: [station_time_timestamp()]"
	P.info = "<center><b>Reagent Scanner</b></center><br><center>Data Analysis:</center><br><hr><br><b>Chemical agents detected:</b><br> [datatoprint]<br><hr>"

	user.put_in_hands(P)
	to_chat(user, SPAN_NOTICE("Report printed. Log cleared."))
	datatoprint = ""
	scanning = TRUE

/obj/item/reagent_scanner/ui_action_click(mob/owner)
	print_report(owner)

////////////////////////////////////////
// MARK:	Slime scanner
////////////////////////////////////////
/obj/item/slime_scanner
	name = "slime scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer_s"
	inhand_icon_state = "analyzer"
	origin_tech = "biotech=2"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throw_speed = 3
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/slime_scanner/attack__legacy__attackchain(mob/living/M, mob/living/user)
	if(user.incapacitated() || user.AmountBlinded())
		return
	if(!isslime(M))
		to_chat(user, SPAN_WARNING("This device can only scan slimes!"))
		return
	slime_scan(M, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	to_chat(user, "========================")
	to_chat(user, "<b>Slime scan results:</b>")
	to_chat(user, SPAN_NOTICE("[T.colour] [T.is_adult ? "adult" : "baby"] slime"))
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if(T.nutrition < T.get_starve_nutrition())
		to_chat(user, SPAN_WARNING("Warning: slime is starving!"))
	else if(T.nutrition < T.get_hunger_nutrition())
		to_chat(user, SPAN_WARNING("Warning: slime is hungry"))
	to_chat(user, "Electric change strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]%")
	if(T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
	if(T.cores > 1)
		to_chat(user, "Multiple cores detected")
	to_chat(user, "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
	if(T.effectmod)
		to_chat(user, SPAN_NOTICE("Core mutation in progress: [T.effectmod]"))
		to_chat(user, SPAN_NOTICE("Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]"))
	to_chat(user, "========================")
