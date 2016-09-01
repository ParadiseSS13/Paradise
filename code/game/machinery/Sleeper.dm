#define ADDICTION_SPEEDUP_TIME 1500 // 2.5 minutes

/////////////
// SLEEPER //
////////////

/obj/machinery/sleeper
	name = "Sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"
	var/base_icon = "sleeper"
	density = 1
	anchored = 1
	dir = 8
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/possible_chems = list(list("epinephrine", "ether", "salbutamol", "styptic_powder", "silver_sulfadiazine"),
							  list("epinephrine", "ether", "salbutamol", "styptic_powder", "silver_sulfadiazine", "oculine"),
							  list("epinephrine", "ether", "salbutamol", "styptic_powder", "silver_sulfadiazine", "oculine", "charcoal", "mutadone", "mannitol"),
							  list("epinephrine", "ether", "salbutamol", "styptic_powder", "silver_sulfadiazine", "oculine", "charcoal", "mutadone", "mannitol", "pen_acid", "omnizine"))
	var/emergency_chems = list("epinephrine") // Desnowflaking
	var/amounts = list(5, 10)
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/filtering = 0
	var/max_chem
	var/initial_bin_rating = 1
	var/min_health = -25
	var/injection_chems = list()
	var/controls_inside = FALSE
	idle_power_usage = 1250
	active_power_usage = 2500

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/sleeper/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/sleeper/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)

	// Customizable bin rating, used by the labor camp to stop people filling themselves with chemicals and escaping.
	var/obj/item/weapon/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B

	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/sleeper/RefreshParts()
	var/E
	var/I
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		I += M.rating

	injection_chems = possible_chems[I]
	max_chem = E * 20
	min_health = -E * 25

/obj/machinery/sleeper/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/sleeper/process()
	if(filtering > 0)
		if(beaker)
			// To prevent runtimes from drawing blood from runtime, and to prevent getting IPC blood.
			if(!istype(occupant) || !occupant.dna || (occupant.species && occupant.species.flags & NO_BLOOD))
				filtering = 0
				return

			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				src.occupant.vessel.trans_to(beaker, 1)
				for(var/datum/reagent/x in src.occupant.reagents.reagent_list)
					src.occupant.reagents.trans_to(beaker, 3)
					src.occupant.vessel.trans_to(beaker, 1)

	if(occupant)
		for(var/A in occupant.reagents.addiction_list)
			var/datum/reagent/R = A

			var/addiction_removal_chance = 5
			if(world.timeofday > (R.last_addiction_dose + ADDICTION_SPEEDUP_TIME)) // 2.5 minutes
				addiction_removal_chance = 10
			if(prob(addiction_removal_chance))
				to_chat(occupant, "<span class='notice'>You no longer feel reliant on [R.name]!</span>")
				occupant.reagents.addiction_list.Remove(R)

	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(src.loc)

	updateDialog()
	return


/obj/machinery/sleeper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	ui_interact(user)

/obj/machinery/sleeper/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/data[0]
	data["hasOccupant"] = occupant ? 1 : 0
	var/occupantData[0]
	var/crisis = 0
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["paralysis"] = occupant.paralysis
		occupantData["hasBlood"] = 0
		occupantData["bodyTemperature"] = occupant.bodytemperature
		occupantData["maxTemp"] = 1000 // If you get a burning vox armalis into the sleeper, congratulations
		// Because we can put simple_animals in here, we need to do something tricky to get things working nice
		occupantData["temperatureSuitability"] = 0 // 0 is the baseline
		if(ishuman(occupant) && occupant.species)
			// I wanna do something where the bar gets bluer as the temperature gets lower
			// For now, I'll just use the standard format for the temperature status
			var/datum/species/sp = occupant.species
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
		else if(istype(occupant, /mob/living/simple_animal))
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
		if(ishuman(occupant) && occupant.vessel && !(occupant.species && occupant.species.flags & NO_BLOOD))
			var/blood_type = occupant.get_blood_name()
			occupantData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			occupantData["hasBlood"] = 1
			occupantData["bloodLevel"] = round(occupant.vessel.get_reagent_amount(blood_type))
			occupantData["bloodMax"] = occupant.max_blood
			occupantData["bloodPercent"] = round(100*(occupant.vessel.get_reagent_amount(blood_type)/occupant.max_blood), 0.01)

	data["occupant"] = occupantData
	data["maxchem"] = max_chem
	data["minhealth"] = min_health
	data["dialysis"] = filtering
	if(beaker)
		data["isBeakerLoaded"] = 1
		if(beaker.reagents)
			data["beakerFreeSpace"] = round(beaker.reagents.maximum_volume - beaker.reagents.total_volume)
		else
			data["beakerFreeSpace"] = 0

	var/chemicals[0]
	for(var/re in injection_chems)
		var/datum/reagent/temp = chemical_reagents_list[re]
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

			// Because I don't know how to do this on the nano side
			pretty_amount = round(reagent_amount, 0.05)

			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("chemical" = temp.id), "occ_amount" = reagent_amount, "pretty_amount" = pretty_amount, "injectable" = injectable, "overdosing" = overdosing, "od_warning" = caution)))
	data["chemicals"] = chemicals

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sleeper.tmpl", "Sleeper", 550, 770)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/sleeper/Topic(href, href_list)
	if(!controls_inside && usr == occupant)
		return 0

	if(..())
		return 1

	if(panel_open)
		to_chat(usr, "<span class='notice'>Close the maintenance panel first.</span>")
		return 0

	if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		if(href_list["chemical"])
			if(occupant)
				if(occupant.stat == DEAD)
					to_chat(usr, "<span class='danger'>This person has no life for to preserve anymore. Take them to a department capable of reanimating them.</span>")
				else if(occupant.health > min_health || (href_list["chemical"] in emergency_chems))
					inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
				else
					to_chat(usr, "<span class='danger'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>")
		if(href_list["removebeaker"])
			remove_beaker()
		if(href_list["togglefilter"])
			toggle_filter()
		if(href_list["ejectify"])
			eject()
		src.add_fingerprint(usr)
	return 1

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		var/atom/movable/A = occupant
		go_out()
		A.blob_act()
		qdel(src)
	return


/obj/machinery/sleeper/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob, params)
	if(istype(G, /obj/item/weapon/reagent_containers/glass))
		if(!beaker)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>\The [G] is stuck to you!</span>")
				return

			beaker = G
			G.forceMove(src)
			user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
			return

		else
			to_chat(user, "<span class='warning'>The sleeper has a beaker already.</span>")
			return

	if(istype(G, /obj/item/weapon/screwdriver))
		if(src.occupant)
			to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
			return
		default_deconstruction_screwdriver(user, "[base_icon]-o", "[base_icon]-open", G)
		return

	if(istype(G, /obj/item/weapon/wrench))
		if(src.occupant)
			to_chat(user, "<span class='notice'>The scanner is occupied.</span>")
			return
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(dir == 4)
			orient = "LEFT"
			dir = 8
		else
			orient = "RIGHT"
			dir = 4
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		return

	if(exchange_parts(user, G))
		return

	if(istype(G, /obj/item/weapon/crowbar))
		default_deconstruction_crowbar(G)
		return

	if(istype(G, /obj/item/weapon/grab))
		if(panel_open)
			to_chat(user, "<span class='boldnotice'>Close the maintenance panel first.</span>")
			return
		if(!ismob(G:affecting))
			return
		if(src.occupant)
			to_chat(user, "<span class='boldnotice'>The sleeper is already occupied!</span>")
			return
		for(var/mob/living/carbon/slime/M in range(1,G:affecting))
			if(M.Victim == G:affecting)
				to_chat(usr, "[G:affecting.name] will not fit into the sleeper because they have a slime latched onto their head.")
				return

		visible_message("[user] starts putting [G:affecting:name] into the sleeper.")

		if(do_after(user, 20, target = G:affecting))
			if(src.occupant)
				to_chat(user, "<span class='boldnotice'>The sleeper is already occupied!</span>")
				return
			if(!G || !G:affecting) return
			var/mob/M = G:affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.forceMove(src)
			src.occupant = M
			src.icon_state = "[base_icon]"
			to_chat(M, "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")

			src.add_fingerprint(user)
			qdel(G)
		return
	return


/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.loc)
				A.ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity)
				qdel(src)
				return

/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

// ???
// This looks cool, although mildly broken, should it be included again?
/obj/machinery/sleeper/alter_health(mob/living/M as mob)
	if(M.health > 0)
		if(M.getOxyLoss() >= 10)
			var/amount = max(0.15, 1)
			M.adjustOxyLoss(-amount)
		else
			M.adjustOxyLoss(-12)
		M.updatehealth()
	M.AdjustParalysis(-4)
	M.AdjustWeakened(-4)
	M.AdjustStunned(-4)
	if(M:reagents.get_reagent_amount("salglu_solution") < 5)
		M:reagents.add_reagent("salglu_solution", 5)
	return

/obj/machinery/sleeper/proc/toggle_filter()
	if(filtering)
		filtering = 0
	else
		filtering = 1

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.forceMove(loc)
	occupant = null
	icon_state = "[base_icon]-open"
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts - list(beaker))
		A.forceMove(loc)

/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(!(chemical in injection_chems))
		to_chat(user, "<span class='notice'>The sleeper does not offer that chemical!</notice>")
		return

	if(src.occupant)
		if(src.occupant.reagents)
			if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= max_chem)
				src.occupant.reagents.add_reagent(chemical, amount)
				return
			else
				to_chat(user, "You can not inject any more of this chemical.")
				return
		else
			to_chat(user, "The patient rejects the chemicals!")
			return
	else
		to_chat(user, "There's no occupant in the sleeper!")
		return

/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	src.icon_state = "[base_icon]-open"
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(beaker)
		filtering = 0
		beaker.forceMove(usr.loc)
		beaker = null
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robots dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
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
		to_chat(user, "<span class='boldnotice'>Subject cannot have abiotic items on.</span>")
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the sleeper because they have a slime latched onto their head.")
			return
	if(L == user)
		visible_message("[user] starts climbing into the sleeper.")
	else
		visible_message("[user] starts putting [L.name] into the sleeper.")

	if(do_after(user, 20, target = L))
		if(src.occupant)
			to_chat(user, "<span class='boldnotice'>>The sleeper is already occupied!</span>")
			return
		if(!L) return

		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.forceMove(src)
		src.occupant = L
		src.icon_state = "[base_icon]"
		to_chat(L, "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
		src.add_fingerprint(user)
		if(user.pulling == L)
			user.stop_pulling()
		return
	return

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr)))
		return
	if(src.occupant)
		to_chat(usr, "<span class='boldnotice'>The sleeper is already occupied!</span>")
		return
	if(panel_open)
		to_chat(usr, "<span class='boldnotice'>Close the maintenance panel first.</span>")
		return
	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return
	visible_message("[usr] starts climbing into the sleeper.")
	if(do_after(usr, 20, target = usr))
		if(src.occupant)
			to_chat(usr, "<span class='boldnotice'>The sleeper is already occupied!</span>")
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.forceMove(src)
		src.occupant = usr
		src.icon_state = "[base_icon]"

		for(var/obj/O in src)
			qdel(O)
		src.add_fingerprint(usr)
		return
	return

/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s-open"
	base_icon = "sleeper_s"
	controls_inside = TRUE

	light_color = LIGHT_COLOR_DARKRED

/obj/machinery/sleeper/syndie/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper/syndicate(null)
	var/obj/item/weapon/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

#undef ADDICTION_SPEEDUP_TIME