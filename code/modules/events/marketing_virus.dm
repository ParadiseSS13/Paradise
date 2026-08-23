/datum/event/marketing_virus
	name = "Marketing Virus"
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_ENGINEERING = 1, ASSIGNMENT_CREW = 0.4)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 2, ASSIGNMENT_CREW = 10)
	noAutoEnd = TRUE

	var/area/origin_area
	var/infected_areas_qty
	var/list/marketer_human_icons = list()
	var/list/evil_human_icons = list()
	var/list/infectable_vendors = list()
	var/list/infected_areas = list()
	var/list/infected_holopads = list()
	var/list/infected_vendors = list()
	var/list/remaining_areas = list()
	var/list/remaining_holopads = list()
	var/list/entrapped_areas = list()

/datum/event/marketing_virus/setup()
	if(!length(SSmapping.existing_station_areas))
		log_debug("Marketing Virus failed to find any station areas, cancelling.")
		return

	for(var/area/area in SSmapping.existing_station_areas)
		if(istype(area, /area/station) && !istype(area, /area/station/maintenance))
			remaining_areas += area

	for(var/i in 1 to 5)
		var/mob/living/carbon/human/marketing_virus_hologram/M = new()
		M.dress_up()
		marketer_human_icons += getHologramIcon(get_id_photo(M), colour = "#7db4e1", opacity = 0.8)
		evil_human_icons += getHologramIcon(get_id_photo(M), colour = "#aa0000", opacity = 0.8)
		qdel(M)

	for(var/obj/machinery/hologram/holopad/holopad in SSmachines.get_by_type(/obj/machinery/hologram/holopad))
		if(get_area(holopad) in remaining_areas)
			remaining_holopads += holopad
			RegisterSignal(holopad, COMSIG_PARENT_QDELETING, PROC_REF(remove_holopad))

	for(var/obj/machinery/economy/vending/vending in SSmachines.get_by_type(/obj/machinery/economy/vending))
		if(get_area(vending) in remaining_areas)
			RegisterSignal(vending, COMSIG_PARENT_QDELETING, PROC_REF(remove_machine))

/datum/event/marketing_virus/start()
	var/successful_infection = FALSE
	do
		origin_area = pick(remaining_areas)
		successful_infection = infect_area(origin_area)
	while(!successful_infection)

/datum/event/marketing_virus/proc/spawn_hologram(obj/machinery/hologram/holopad/target)
	var/hologram_idx = rand(1, length(marketer_human_icons))
	var/obj/effect/overlay/marketing_virus_hologram/hologram = new(target.loc, target, marketer_human_icons[hologram_idx], hologram_idx)
	if(!length(infected_holopads))
		var/area/area = get_area(target)
		notify_ghosts("A marketing virus has infected [area]!", title = "Marketing Virus!", source = target, action = NOTIFY_JUMP)
	infected_holopads[target] = hologram
	RegisterSignal(target, COMSIG_OBJ_HEAR_TALK, PROC_REF(on_holopad_hear))

/datum/event/marketing_virus/proc/on_holopad_hear(obj/holopad, mob/sayer, list/message_pieces)
	var/obj/effect/overlay/marketing_virus_hologram/hologram = infected_holopads[holopad]
	if(!istype(hologram))
		return
	var/msg = html_decode(multilingual_to_message(message_pieces))
	var/area/target_area = get_area(holopad)
	if(dd_hasprefix(msg, hologram.accept_phrase))
		if(get_dist(holopad, sayer) > 2)
			hologram.atom_say("I can't hear you!")
			return
		else if(get_area(holopad) != get_area(sayer))
			hologram.atom_say("I can't hear you!!")
			return

		STOP_PROCESSING(SSprocessing, hologram)
		hologram.atom_say("Good job!")
		addtimer(CALLBACK(src, PROC_REF(clean_up_area), target_area), (5 SECONDS))

/datum/event/marketing_virus/tick()
	infected_areas_qty = length(infected_areas)

	if(length(infected_holopads) + length(remaining_areas) == 0)
		kill()
		return

	if(ISMULTIPLE(activeFor, 8))
		for(var/area/area in infected_areas)
			process_area(area)

/datum/event/marketing_virus/proc/process_area(area/target_area)
	if(target_area in entrapped_areas)
		return

	if(length(infectable_vendors[target_area]))
		var/obj/machinery/economy/vending/vendor = pick_n_take(infectable_vendors[target_area])
		infected_vendors[target_area] += vendor
	else if(prob(40 + infected_areas_qty))
		infectable_vendors -= target_area
		if(has_said_phrase(target_area))
			log_debug("area [target_area] completely infected, entrapping")
			entrapped_areas += target_area
			make_holograms_evil(target_area)
			RegisterSignal(target_area, COMSIG_MOVABLE_ENTERED_AREA, PROC_REF(entrap_area))

			infect_next_area_from(target_area)
			if(prob(5 + (2 * infected_areas_qty))) // small but steadily growing chance to infect two areas
				infect_next_area_from(target_area)

/datum/event/marketing_virus/proc/has_said_phrase(area/target)
	var/list/said_once = list()
	for(var/obj/candidate in infected_holopads)
		if(get_area(candidate) == target)
			var/obj/effect/overlay/marketing_virus_hologram/hologram = infected_holopads[candidate]
			if(hologram.phrase_said_at_least_once)
				said_once.Add(TRUE)
			else
				return FALSE

	return length(said_once)

/datum/event/marketing_virus/proc/make_holograms_evil(area/target)
	for(var/obj/candidate in infected_holopads)
		if(get_area(candidate) == target)
			var/obj/effect/overlay/marketing_virus_hologram/hologram = infected_holopads[candidate]
			hologram.icon = evil_human_icons[hologram.index]
			hologram.set_light(3, 2, "#ff0000")
			hologram.evil = TRUE

/datum/event/marketing_virus/proc/clean_up_area(area/target)
	infectable_vendors -= target
	infected_vendors -= target
	infected_areas -= target
	for(var/obj/candidate in infected_holopads)
		if(get_area(candidate) == target)
			var/obj/remove_hologram = infected_holopads[candidate]
			qdel(remove_hologram)
			infected_holopads.Remove(candidate)

/datum/event/marketing_virus/proc/entrap_area(area/target, atom/moved)
	SIGNAL_HANDLER // COMSIG_MOVABLE_ENTERED_AREA

	if(!ishuman(moved))
		return

	for(var/obj/machinery/economy/vending/vendor in infected_vendors[target])
		if(prob(20))
			make_vendor_aggressive(vendor)
		else
			make_vendor_mimic(vendor)

	clean_up_area(target)
	UnregisterSignal(target, COMSIG_MOVABLE_ENTERED_AREA)

/datum/event/marketing_virus/proc/make_vendor_aggressive(obj/machinery/economy/vending/vendor)
	vendor.shut_up = FALSE
	vendor.shoot_inventory = TRUE
	vendor.aggressive = TRUE
	if(vendor.tiltable)
		vendor.proximity_monitor = new(vendor)

/datum/event/marketing_virus/proc/make_vendor_mimic(obj/machinery/economy/vending/vendor)
	vendor.shoot_inventory = FALSE
	vendor.aggressive = FALSE
	var/mob/living/basic/mimic/copy/vendor/M = new(vendor.loc, vendor, null)
	M.faction = list("profit")

/datum/event/marketing_virus/proc/infect_area(area/target)
	remaining_areas -= target

	var/list/holopads = list()
	for(var/obj/machinery/hologram/holopad/holopad in remaining_holopads)
		if(get_area(holopad) == target)
			holopads += holopad

	if(length(holopads))
		log_debug("infecting area [target]")
		for(var/obj/machinery/hologram/holopad/holopad in holopads)
			spawn_hologram(holopad)
			remaining_holopads -= holopad

		infectable_vendors[target] = list()
		infected_vendors[target] = list()
		for(var/obj/machinery/economy/vending/vending in SSmachines.get_by_type(/obj/machinery/economy/vending))
			if(get_area(vending) == target)
				infectable_vendors[target] += vending

		infected_areas += target
		return TRUE
	else
		log_debug("Marketing Virus skipping non-holopadded area [target]")

/datum/event/marketing_virus/proc/remove_holopad(atom/target)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	remaining_holopads -= target

/datum/event/marketing_virus/proc/remove_machine(atom/target)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	if(get_area(target) in infectable_vendors)
		infectable_vendors[get_area(target)] -= target

/datum/event/marketing_virus/proc/infect_next_area_from(area/previous)
	var/atom/closest_holopad
	var/atom/viral_atom = get_any_vendor_in_area(previous)
	if(!istype(viral_atom))
		viral_atom = pick(get_area_turfs(previous))
	var/dist = INFINITY
	for(var/atom/candidate in remaining_holopads)
		if(!(get_area(candidate) in infected_areas) && get_dist(candidate, viral_atom) < dist)
			dist = get_dist(candidate, viral_atom)
			closest_holopad = candidate

	var/area/next_area = get_area(closest_holopad)
	infect_area(next_area)

/datum/event/marketing_virus/proc/get_any_vendor_in_area(area/target)
	if(length(infectable_vendors[target]))
		return pick(infectable_vendors[target])
	else if(length(infected_vendors[target]))
		return pick(infected_vendors[target])

/mob/living/carbon/human/marketing_virus_hologram
	flags = parent_type::flags | ABSTRACT

/mob/living/carbon/human/marketing_virus_hologram/Initialize(mapload)
	var/new_species = pick(
		/datum/species/diona,
		/datum/species/drask,
		/datum/species/grey,
		/datum/species/human,
		/datum/species/kidan,
		/datum/species/machine,
		/datum/species/moth,
		/datum/species/plasmaman,
		/datum/species/skrell,
		/datum/species/skulk,
		/datum/species/slime,
		/datum/species/unathi,
		/datum/species/tajaran,
		/datum/species/vox,
		/datum/species/vulpkanin,
	)
	. = ..(new_species = new_species)

/mob/living/carbon/human/marketing_virus_hologram/proc/dress_up()
	equipOutfit(/datum/outfit/randomizer/gambler, visualsOnly = TRUE)

GLOBAL_LIST_INIT(marketing_virus_hologram_phrases, list(
		"Do I have an opportunity for you!",
		"And now a word from our sponsor!",
		"Listen carefully for an amazing deal!",
		"If you're hearing this you are today's lucky winner!",
		"This message is sponsored by Donk Co!",
		"Today we have a very special deal!",
		"Do you love saving money? Of course you do!",
		"I can't wait to tell you about today's sponsor.",
		"Take a break and listen to some advertising!",
	))

/obj/effect/overlay/marketing_virus_hologram
	var/list/initial_phrases

	var/static/list/invoke_phrases = list(
		"Just say \"$msg!\" to earn your coupon!",
		"Let me hear you say \"$msg!\"!",
		"Say \"$msg!\" to learn more!",
		"Can I hear you say \"$msg!\"???"
	)

	var/static/list/evil_phrases = list(
		"Consume!",
		"Your money can buy happiness!",
		"Engage direct marketing!",
		"Try our aggressive new marketing strategies!",
		"You should have listened.",
		"It's too late.",
		"Our products aren't dangerous, but I am.",
		"All you had to do was hand over all your cash.",
		"Buy! Buy! Buy!",
	)

	var/static/list/accept_phrases = list(
		"Tell me more",
		"I'm loving it",
		"Sign me up",
		"I'll buy ten",
		"I love buying stuff",
		"Shut up and take my money",
	)

	var/index
	var/evil = FALSE
	var/accept_phrase
	var/phrase_count
	var/phrase_said_at_least_once = FALSE
	var/cooldown_lower_bound = 3 SECONDS
	var/cooldown_upper_bound = 6 SECONDS
	var/parent_holopad
	COOLDOWN_DECLARE(next_phrase)

/obj/effect/overlay/marketing_virus_hologram/Initialize(mapload, obj/machinery/hologram/holopad/holopad, hologram_icon, hologram_index)
	. = ..()
	parent_holopad = holopad
	icon = hologram_icon
	index = hologram_index
	alpha = 166
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = FLY_LAYER
	anchored = TRUE
	name = "Marketer"
	set_light(2)
	bubble_icon = "swarmer"
	pixel_y = 16
	accept_phrase = pick(accept_phrases)
	START_PROCESSING(SSprocessing, src)
	restart_spiel()

/obj/effect/overlay/marketing_virus_hologram/proc/restart_spiel()
	initial_phrases = GLOB.marketing_virus_hologram_phrases.Copy()
	COOLDOWN_START(src, next_phrase, rand(cooldown_lower_bound, cooldown_upper_bound))
	phrase_count = rand(2, 3)

/obj/effect/overlay/marketing_virus_hologram/process()
	if(evil)
		if(COOLDOWN_FINISHED(src, next_phrase))
			atom_say(pick(evil_phrases))
			COOLDOWN_START(src, next_phrase, rand(cooldown_lower_bound, cooldown_upper_bound))

		return

	if(COOLDOWN_FINISHED(src, next_phrase))
		if(phrase_count <= 0)
			phrase_said_at_least_once = TRUE
			atom_say(replacetext(pick(invoke_phrases), "$msg", accept_phrase))
			restart_spiel()
		else
			var/phrase = pick_n_take(initial_phrases)
			phrase_count--
			atom_say(phrase)
			COOLDOWN_START(src, next_phrase, rand(cooldown_lower_bound, cooldown_upper_bound))
