#define ADDICTION_SPEEDUP_TIME 1500 // 2.5 minutes

/////////////
// SLEEPER //
////////////

/obj/machinery/sleeper
	name = "sleeper"
	desc = "Injects chemicals into the bloodstream of the occupant, can remove chemicals from the bloodstream of the occupant through dialysis."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper-open"
	var/base_icon = "sleeper"
	density = TRUE
	anchored = TRUE
	dir = WEST
	var/mob/living/carbon/human/occupant = null
	var/possible_chems = list("ephedrine", "salglu_solution", "salbutamol", "charcoal")
	var/emergency_chems = list("ephedrine") // Desnowflaking
	var/amounts = list(5, 10)
	/// Beaker loaded into the sleeper. Used for dialysis.
	var/obj/item/reagent_containers/glass/beaker = null
	/// Whether the machine is currently performing dialysis.
	var/filtering = FALSE
	var/max_chem
	var/initial_bin_rating = 1
	var/min_health = -25
	var/controls_inside = FALSE
	var/auto_eject_dead = FALSE
	idle_power_consumption = 1250
	active_power_consumption = 2500

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/sleeper/examine(mob/user)
	. = ..()
	if(occupant)
		if(occupant.is_dead())
			. += "<span class='warning'>You see [occupant.name] inside. [occupant.p_they(TRUE)] [occupant.p_are()] dead!</span>"
		else
			. += "<span class='notice'>You see [occupant.name] inside.</span>"
	. += "<span class='info'>You can <b>Alt-Click</b> to eject the current occupant. <b>Click-drag</b> someone to the sleeper to place them in it after a short delay.</span>"

/obj/machinery/sleeper/power_change()
	..() //we don't check parent return here because we also care about BROKEN
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/sleeper/update_icon_state()
	if(occupant)
		icon_state = base_icon
	else
		icon_state = "[base_icon]-open"

/obj/machinery/sleeper/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/sleeper(null)

	// Customizable bin rating, used by the labor camp to stop people filling themselves with chemicals and escaping.
	var/obj/item/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B

	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/sleeper(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating

	max_chem = E * 20
	min_health = -E * 25

/obj/machinery/sleeper/Destroy()
	for(var/mob/M in contents)
		M.forceMove(get_turf(src))
	return ..()

/obj/machinery/sleeper/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/sleeper/process()
	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(loc)

	if(occupant)
		if(auto_eject_dead && occupant.stat == DEAD)
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 40)
			go_out()
			return

		if(filtering > 0 && beaker)
			// To prevent runtimes from drawing blood from runtime, and to prevent getting IPC blood.
			if(!istype(occupant) || !occupant.dna || (NO_BLOOD in occupant.dna.species.species_traits))
				filtering = 0
				return

			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				occupant.transfer_blood_to(beaker, 1)
				for(var/datum/reagent/R in occupant.reagents.reagent_list)
					occupant.transfer_blood_to(beaker, 1)
					if(R.id in GLOB.blocked_chems)
						occupant.reagents.remove_reagent(R.id, 3)
						beaker.reagents.add_reagent("saturated_charcoal", 3)
						continue
					occupant.reagents.trans_to(beaker, 3)

		for(var/A in occupant.reagents.addiction_list)
			var/datum/reagent/R = A

			var/addiction_removal_chance = 5
			if(world.timeofday > (R.last_addiction_dose + ADDICTION_SPEEDUP_TIME)) // 2.5 minutes
				addiction_removal_chance = 10
			if(prob(addiction_removal_chance))
				atom_say("Patient's addiction was cured.")
				playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 0)
				to_chat(occupant, "<span class='boldnotice'>You no longer feel reliant on [R.name]!</span>")
				occupant.reagents.addiction_list.Remove(R)
				qdel(R)

	updateDialog()
	return


/obj/machinery/sleeper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/sleeper/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	ui_interact(user)

/obj/machinery/sleeper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Sleeper", "Sleeper", 550, 775)
		ui.open()

/obj/machinery/sleeper/ui_data(mob/user)
	var/list/data = list()
	data["amounts"] = amounts
	data["hasOccupant"] = occupant ? 1 : 0
	var/occupantData[0]
	var/crisis = 0
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = HEALTH_THRESHOLD_DEAD
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["paralysis"] = occupant.AmountParalyzed()
		occupantData["hasBlood"] = 0
		occupantData["bodyTemperature"] = occupant.bodytemperature
		occupantData["maxTemp"] = 1000
		// Because we can put simple_animals in here, we need to do something tricky to get things working nice
		occupantData["temperatureSuitability"] = 0 // 0 is the baseline
		if(ishuman(occupant) && occupant.dna.species)
			// I wanna do something where the bar gets bluer as the temperature gets lower
			// For now, I'll just use the standard format for the temperature status
			var/datum/species/sp = occupant.dna.species
			if(occupant.bodytemperature < sp.cold_level_3)
				occupantData["temperatureSuitability"] = -3
			else if(occupant.bodytemperature < sp.cold_level_2)
				occupantData["temperatureSuitability"] = -2
			else if(occupant.bodytemperature < sp.cold_level_1)
				occupantData["temperatureSuitability"] = -1
			else if(occupant.bodytemperature > sp.heat_level_3)
				occupantData["temperatureSuitability"] = 3
			else if(occupant.bodytemperature > sp.heat_level_2)
				occupantData["temperatureSuitability"] = 2
			else if(occupant.bodytemperature > sp.heat_level_1)
				occupantData["temperatureSuitability"] = 1
		else if(isanimal(occupant))
			var/mob/living/simple_animal/silly = occupant
			if(silly.bodytemperature < silly.minbodytemp)
				occupantData["temperatureSuitability"] = -3
			else if(silly.bodytemperature > silly.maxbodytemp)
				occupantData["temperatureSuitability"] = 3
		// Blast you, imperial measurement system
		occupantData["btCelsius"] = occupant.bodytemperature - T0C
		occupantData["btFaren"] = ((occupant.bodytemperature - T0C) * (9.0/5.0))+ 32


		crisis = (occupant.health < min_health)
		// I'm not sure WHY you'd want to put a simple_animal in a sleeper, but precedent is precedent
		// Runtime is aptly named, isn't she?
		if(ishuman(occupant) && !(NO_BLOOD in occupant.dna.species.species_traits))
			occupantData["pulse"] = occupant.get_pulse()
			occupantData["hasBlood"] = 1
			occupantData["bloodLevel"] = round(occupant.blood_volume)
			occupantData["bloodMax"] = occupant.max_blood
			occupantData["bloodPercent"] = round(100*(occupant.blood_volume/occupant.max_blood), 0.01)

	data["occupant"] = occupantData
	data["maxchem"] = max_chem
	data["minhealth"] = min_health
	data["dialysis"] = filtering
	data["auto_eject_dead"] = auto_eject_dead
	if(beaker)
		data["isBeakerLoaded"] = 1
		if(beaker.reagents)
			data["beakerMaxSpace"] = beaker.reagents.maximum_volume
			data["beakerFreeSpace"] = round(beaker.reagents.maximum_volume - beaker.reagents.total_volume)
		else
			data["beakerMaxSpace"] = 0
			data["beakerFreeSpace"] = 0
	else
		data["isBeakerLoaded"] = FALSE

	var/chemicals[0]
	for(var/re in possible_chems)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/reagent_amount = 0
			var/pretty_amount
			var/injectable = occupant ? 1 : 0
			var/overdosing = 0
			var/caution = 0 // To make things clear that you're coming close to an overdose
			if(crisis && !(temp.id in emergency_chems))
				injectable = 0

			if(occupant && occupant.reagents)
				reagent_amount = occupant.reagents.get_reagent_amount(temp.id)
				// If they're mashing the highest concentration, they get one warning
				if(temp.overdose_threshold && reagent_amount + 10 > temp.overdose_threshold)
					caution = 1
				if(temp.id in occupant.reagents.overdose_list())
					overdosing = 1

			pretty_amount = round(reagent_amount, 0.05)

			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("chemical" = temp.id), "occ_amount" = reagent_amount, "pretty_amount" = pretty_amount, "injectable" = injectable, "overdosing" = overdosing, "od_warning" = caution)))
	data["chemicals"] = chemicals
	return data

/obj/machinery/sleeper/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!controls_inside && usr == occupant)
		return
	if(panel_open)
		to_chat(usr, "<span class='notice'>Close the maintenance panel first.</span>")
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("chemical")
			if(!occupant)
				return
			if(occupant.stat == DEAD)
				to_chat(usr, "<span class='danger'>This person has no life to preserve anymore. Take [occupant.p_them()] to a department capable of reanimating them.</span>")
				return
			var/chemical = params["chemid"]
			var/amount = text2num(params["amount"])
			if(!length(chemical) || amount <= 0)
				return
			if(occupant.health > min_health || (chemical in emergency_chems))
				inject_chemical(usr, chemical, amount)
			else
				to_chat(usr, "<span class='danger'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>")
		if("removebeaker")
			remove_beaker(ui.user)
		if("togglefilter")
			toggle_filter()
		if("ejectify")
			eject()
		if("auto_eject_dead_on")
			auto_eject_dead = TRUE
		if("auto_eject_dead_off")
			auto_eject_dead = FALSE
		else
			return FALSE
	add_fingerprint(usr)

/obj/machinery/sleeper/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass) && user.a_intent != INTENT_HARM)
		if(!beaker)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
				return

			beaker = I
			I.forceMove(src)
			user.visible_message("[user] adds \a [I] to [src]!", "You add \a [I] to [src]!")
			SStgui.update_uis(src)
			return

		else
			to_chat(user, "<span class='warning'>The sleeper has a beaker already.</span>")
			return

	if(exchange_parts(user, I))
		return

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(panel_open)
			to_chat(user, "<span class='boldnotice'>Close the maintenance panel first.</span>")
			return
		if(!ismob(G.affecting))
			return
		if(occupant)
			to_chat(user, "<span class='boldnotice'>The sleeper is already occupied!</span>")
			return
		if(G.affecting.has_buckled_mobs()) //mob attached to us
			to_chat(user, "<span class='warning'>[G.affecting] will not fit into [src] because [G.affecting.p_they()] [G.affecting.p_have()] a slime latched onto [G.affecting.p_their()] head.</span>")
			return

		visible_message("[user] starts putting [G.affecting.name] into the sleeper.")

		if(do_after(user, 20, target = G.affecting))
			if(occupant)
				to_chat(user, "<span class='boldnotice'>The sleeper is already occupied!</span>")
				return
			if(!G || !G.affecting)
				return
			var/mob/M = G.affecting
			M.forceMove(src)
			occupant = M
			update_icon(UPDATE_ICON_STATE)
			to_chat(M, "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
			add_fingerprint(user)
			qdel(G)
			SStgui.update_uis(src)
			return

	return ..()


/obj/machinery/sleeper/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/sleeper/screwdriver_act(mob/user, obj/item/I)
	if(occupant)
		to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[base_icon]-o", "[base_icon]-open", I))
		return TRUE

/obj/machinery/sleeper/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(occupant)
		to_chat(user, "<span class='notice'>The scanner is occupied.</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	setDir(turn(dir, -90))

/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/sleeper/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)
		SStgui.update_uis(src)
	if(A == beaker)
		beaker = null
		updateUsrDialog()
		SStgui.update_uis(src)

/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/sleeper/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/sleeper/proc/toggle_filter()
	if(filtering || !beaker)
		filtering = FALSE
	else
		filtering = TRUE

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	playsound(src, 'sound/machines/podopen.ogg', 5)
	update_icon(UPDATE_ICON_STATE)
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts - list(beaker))
		A.forceMove(loc)
	SStgui.update_uis(src)

/obj/machinery/sleeper/force_eject_occupant(mob/target)
	go_out()

/obj/machinery/sleeper/proc/inject_chemical(mob/living/user, chemical, amount)
	if(!(chemical in possible_chems))
		to_chat(user, "<span class='notice'>The sleeper does not offer that chemical!</span>")
		return
	if(!(amount in amounts))
		return

	if(occupant)
		if(occupant.reagents)
			if(occupant.reagents.get_reagent_amount(chemical) + amount <= max_chem)
				occupant.reagents.add_reagent(chemical, amount)
			else
				to_chat(user, "You can not inject any more of this chemical.")
		else
			to_chat(user, "The patient rejects the chemicals!")
	else
		to_chat(user, "There's no occupant in the sleeper!")

/obj/machinery/sleeper/AltClick(mob/user)
	if(issilicon(user))
		eject()
		return
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	eject()

/obj/machinery/sleeper/proc/eject(mob/user)
	go_out()
	add_fingerprint(usr)

/obj/machinery/sleeper/proc/remove_beaker(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(beaker)
		filtering = FALSE
		user.put_in_hands(beaker)
		beaker = null
		SStgui.update_uis(src)
	add_fingerprint(user)

/obj/machinery/sleeper/MouseDrop_T(atom/movable/O, mob/user)
	if(!permitted_check(O, user))
		return
	var/mob/living/L = O
	if(L == user)
		visible_message("[user] starts climbing into the sleeper.")
	else
		visible_message("[user] starts putting [L.name] into the sleeper.")
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/sleeper, put_in), O, user, L)
	return TRUE

/obj/machinery/sleeper/proc/put_in(atom/movable/O, mob/user, mob/living/L) // need this proc to use INVOKE_ASYNC in other proc. You're not recommended to use that one
	if(do_after(user, 20, target = L))
		if(!permitted_check(O, user))
			return
		if(!L)
			return
		L.forceMove(src)
		occupant = L
		playsound(src, 'sound/machines/podclose.ogg', 5)
		update_icon(UPDATE_ICON_STATE)
		to_chat(L, "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
		add_fingerprint(user)
		if(user.pulling == L)
			user.stop_pulling()
		SStgui.update_uis(src)

/obj/machinery/sleeper/proc/permitted_check(atom/movable/O, mob/user)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(isanimal(O) || issilicon(O)) //animals and robots dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(!user.loc) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!isturf(user.loc) || !isturf(O.loc)) // are you in a container/closet/pod/etc?
		return
	if(panel_open)
		to_chat(user, "<span class='boldnotice'>Close the maintenance panel first.</span>")
		return
	if(occupant)
		to_chat(user, "<span class='boldnotice'>The sleeper is already occupied!</span>")
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		to_chat(user, "<span class='boldnotice'>Subject may not hold anything in their hands.</span>")
		return
	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[L] will not fit into [src] because [L.p_they()] [L.p_have()] a slime latched onto [L.p_their()] head.</span>")
		return
	return TRUE

/obj/machinery/sleeper/AllowDrop()
	return FALSE

/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s-open"
	base_icon = "sleeper_s"
	possible_chems = list("epinephrine", "ether", "salbutamol", "styptic_powder", "silver_sulfadiazine")
	emergency_chems = list("epinephrine")
	controls_inside = TRUE

	light_color = LIGHT_COLOR_DARKRED

/obj/machinery/sleeper/syndie/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/sleeper/syndicate(null)
	var/obj/item/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

#undef ADDICTION_SPEEDUP_TIME
