#define AUTO_EJECT_DEAD		(1<<0)
#define AUTO_EJECT_HEALTHY	(1<<1)

/obj/machinery/atmospherics/unary/cryo_cell
	name = "криокапсула"
	desc = "Понижает температуру тела, позволяя применять определённые лекарства."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "pod0"
	density = 1
	anchored = 1.0
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	interact_offline = 1
	max_integrity = 350
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 30, "acid" = 30)
	var/on = FALSE
	var/temperature_archived
	var/mob/living/carbon/occupant = null
	var/obj/item/reagent_containers/glass/beaker = null
	//if you don't want to dupe reagents
	var/list/reagents_blacklist = list(
		"stimulants"
	)
	/// Holds two bitflags, AUTO_EJECT_DEAD and AUTO_EJECT_HEALTHY. Used to determine if the cryo cell will auto-eject dead and/or completely health patients.
	var/auto_eject_prefs = NONE

	var/next_trans = 0
	var/current_heat_capacity = 50
	var/efficiency
	var/conduction_coefficient = 1

	var/running_bob_animation = 0 // This is used to prevent threads from building up if update_icons is called multiple times

	light_color = LIGHT_COLOR_WHITE

/obj/machinery/atmospherics/unary/cryo_cell/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cryo_cell/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cryo_cell/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		C += M.rating
	current_heat_capacity = 50 * C
	efficiency = C

/obj/machinery/atmospherics/unary/cryo_cell/atmos_init()
	..()
	if(node) return
	for(var/cdir in GLOB.cardinal)
		node = findConnecting(cdir)
		if(node)
			break

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/atmospherics/unary/cryo_cell/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	if(beaker)
		beaker.ex_act(severity)
	..()

/obj/machinery/atmospherics/unary/cryo_cell/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		updateUsrDialog()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon()

/obj/machinery/atmospherics/unary/cryo_cell/on_deconstruction()
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(atom/movable/O, mob/living/user)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		to_chat(user, "<span class='boldnotice'>Криокапсула уже занята!</span>")
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		to_chat(user, "<span class='danger'>Субъект не должен держать в руках абиотические предметы.</span>")
		return
	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[L] нельзя поместить в [src], поскольку к [genderize_ru(L.gender,"его","её","его","их")] голове прилеплен слайм.</span>")
		return
	if(put_mob(L))
		if(L == user)
			visible_message("[user] залеза[pluralize_ru(user.gender,"ет","ют")] в криокапсулу.")
		else
			visible_message("[user] помеща[pluralize_ru(user.gender,"ет","ют")] [L.name] в криокапсулу.")
			add_attack_logs(user, L, "put into a cryo cell at [COORD(src)].", ATKLOG_ALL)
			if(user.pulling == L)
				user.stop_pulling()
		SStgui.update_uis(src)

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(!occupant)
		return

	if((auto_eject_prefs & AUTO_EJECT_DEAD) && occupant.stat == DEAD)
		auto_eject(AUTO_EJECT_DEAD)
		return
	if((auto_eject_prefs & AUTO_EJECT_HEALTHY) && !occupant.has_organic_damage() && !occupant.has_mutated_organs())
		auto_eject(AUTO_EJECT_HEALTHY)
		return

	if(air_contents)
		process_occupant()

	return TRUE

/obj/machinery/atmospherics/unary/cryo_cell/process_atmos()
	..()
	if(!node)
		return
	if(!on)
		return

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		parent.update = 1


/obj/machinery/atmospherics/unary/cryo_cell/AllowDrop()
	return FALSE


/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/atmospherics/unary/cryo_cell/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	if(user == occupant)
		return

	if(panel_open)
		to_chat(usr, "<span class='boldnotice'>Сначала закройте панель техобслуживания.</span>")
		return

	ui_interact(user)

/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Cryo", "Криокапсула", 520, 490)
		ui.open()

/obj/machinery/atmospherics/unary/cryo_cell/ui_data(mob/user)
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE

	var/occupantData[0]
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
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData

	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > TCRYO)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	data["auto_eject_healthy"] = (auto_eject_prefs & AUTO_EJECT_HEALTHY) ? TRUE : FALSE
	data["auto_eject_dead"] = (auto_eject_prefs & AUTO_EJECT_DEAD) ? TRUE : FALSE
	return data

/obj/machinery/atmospherics/unary/cryo_cell/ui_act(action, params)
	if(..() || usr == occupant)
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("switchOn")
			on = TRUE
			update_icon()
		if("switchOff")
			on = FALSE
			update_icon()
		if("auto_eject_healthy_on")
			auto_eject_prefs |= AUTO_EJECT_HEALTHY
		if("auto_eject_healthy_off")
			auto_eject_prefs &= ~AUTO_EJECT_HEALTHY
		if("auto_eject_dead_on")
			auto_eject_prefs |= AUTO_EJECT_DEAD
		if("auto_eject_dead_off")
			auto_eject_prefs &= ~AUTO_EJECT_DEAD
		if("ejectBeaker")
			if(!beaker)
				return
			beaker.forceMove(get_step(loc, SOUTH))
			beaker = null
		if("ejectOccupant")
			if(!occupant || isslime(usr) || ispAI(usr))
				return
			add_attack_logs(usr, occupant, "ejected from cryo cell at [COORD(src)]", ATKLOG_ALL)
			go_out()
		else
			return FALSE

	add_fingerprint(usr)

/obj/machinery/atmospherics/unary/cryo_cell/attackby(var/obj/item/G, var/mob/user, params)
	if(istype(G, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/B = G
		if(beaker)
			to_chat(user, "<span class='warning'>В криокапсулу уже загружена другая ёмкость.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "Вы не можете бросить [B]!")
			return
		B.forceMove(src)
		beaker =  B
		add_attack_logs(user, null, "Added [B] containing [B.reagents.log_list()] to a cryo cell at [COORD(src)]")
		user.visible_message("[user] загружа[pluralize_ru(user.gender,"ет","ют")] [B] в криокапсулу!", "Вы загружаете [B] в криокапсулу!")
		SStgui.update_uis(src)
		return

	if(exchange_parts(user, G))
		return

	if(istype(G, /obj/item/grab))
		var/obj/item/grab/GG = G
		if(panel_open)
			to_chat(user, "<span class='boldnotice'>Сначала закройте панель техобслуживания.</span>")
			return
		if(!ismob(GG.affecting))
			return
		if(GG.affecting.has_buckled_mobs()) //mob attached to us
			to_chat(user, "<span class='warning'>[GG.affecting] не влеза[pluralize_ru(GG.affecting.gender,"ет","ют")] в [src] потому что к [genderize_ru(GG.affecting.gender,"его","её","его","их")] голове прилеплен слайм.</span>")
			return
		var/mob/M = GG.affecting
		if(put_mob(M))
			qdel(GG)
		return
	return ..()

/obj/machinery/atmospherics/unary/cryo_cell/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return

/obj/machinery/atmospherics/unary/cryo_cell/screwdriver_act(mob/user, obj/item/I)
	if(occupant || on)
		to_chat(user, "<span class='notice'>Панель техобслуживания закрыта.</span>")
		return TRUE
	if(default_deconstruction_screwdriver(user, "pod0-o", "pod0", I))
		return TRUE

/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	handle_update_icon()

/obj/machinery/atmospherics/unary/cryo_cell/proc/handle_update_icon() //making another proc to avoid spam in update_icon
	overlays.Cut() //empty the overlay proc, just in case
	icon_state = "pod[on]" //set the icon properly every time

	if(!src.occupant)
		overlays += "lid[on]" //if no occupant, just put the lid overlay on, and ignore the rest
		return

	if(occupant)
		var/mutable_appearance/pickle = mutable_appearance(occupant.icon, occupant.icon_state)
		pickle.overlays = occupant.overlays
		pickle.pixel_y = 22

		overlays += pickle
		overlays += "lid[on]"
		if(src.on && !running_bob_animation) //no bobbing if off
			var/up = 0 //used to see if we are going up or down, 1 is down, 2 is up
			spawn(0) // Without this, the icon update will block. The new thread will die once the occupant leaves.
				running_bob_animation = 1
				while(occupant)
					overlays -= "lid[on]" //have to remove the overlays first, to force an update- remove cloning pod overlay
					overlays -= pickle //remove mob overlay

					switch(pickle.pixel_y) //this looks messy as fuck but it works, switch won't call itself twice

						if(23) //inbetween state, for smoothness
							switch(up) //this is set later in the switch, to keep track of where the mob is supposed to go
								if(2) //2 is up
									pickle.pixel_y = 24 //set to highest

								if(1) //1 is down
									pickle.pixel_y = 22 //set to lowest

						if(22) //mob is at it's lowest
							pickle.pixel_y = 23 //set to inbetween
							up = 2 //have to go up

						if(24) //mob is at it's highest
							pickle.pixel_y = 23 //set to inbetween
							up = 1 //have to go down

					overlays += pickle //re-add the mob to the icon
					overlays += "lid[on]" //re-add the overlay of the pod, they are inside it, not floating

					sleep(7) //don't want to jiggle violently, just slowly bob
				running_bob_animation = 0

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles() < 10)
		return
	if(occupant)
		if(occupant.bodytemperature < T0C)
			occupant.Sleeping(max(5/efficiency, (1/occupant.bodytemperature)*2000/efficiency))
			occupant.Paralyse(max(5/efficiency, (1/occupant.bodytemperature)*3000/efficiency))
			if(air_contents.oxygen > 2)
				if(occupant.getOxyLoss())
					occupant.adjustOxyLoss(-6)
			else
				occupant.adjustOxyLoss(-1.2)
		if(beaker && next_trans == 0)
			var/proportion = 10 * min(1/beaker.volume, 1)
			var/volume = 10
			// Yes, this means you can get more bang for your buck with a beaker of SF vs a patch
			// But it also means a giant beaker of SF won't heal people ridiculously fast 4 cheap
			for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
				if(reagent.id in reagents_blacklist)
					proportion = min(proportion, 1)
					volume = 1
			beaker.reagents.reaction(occupant, REAGENT_TOUCH, proportion)
			beaker.reagents.trans_to(occupant, 1, volume)
	next_trans++
	if(next_trans == 17)
		next_trans = 0

/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(!occupant)
		return
	var/cold_protection = 0
	var/temperature_delta = air_contents.temperature - occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.

	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		cold_protection = H.get_cold_protection(air_contents.temperature)

	if(abs(temperature_delta) > 1)
		var/air_heat_capacity = air_contents.heat_capacity()

		var/heat = (1 - cold_protection) * conduction_coefficient * temperature_delta * \
			(air_heat_capacity * current_heat_capacity / (air_heat_capacity + current_heat_capacity))

		air_contents.temperature = clamp(air_contents.temperature - heat / air_heat_capacity, TCMB, INFINITY)
		occupant.adjust_bodytemperature(heat / current_heat_capacity, TCMB)

/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(get_step(loc, SOUTH))	//this doesn't account for walls or anything, but i don't forsee that being a problem.
	if(occupant.bodytemperature < 261 && occupant.bodytemperature >= 70) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261
	occupant = null
	update_icon()
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts - list(beaker))
		A.forceMove(get_step(loc, SOUTH))

/obj/machinery/atmospherics/unary/cryo_cell/force_eject_occupant(mob/target)
	go_out()

/// Called when either the occupant is dead and the AUTO_EJECT_DEAD flag is present, OR the occupant is alive, has no external damage, and the AUTO_EJECT_HEALTHY flag is present.
/obj/machinery/atmospherics/unary/cryo_cell/proc/auto_eject(eject_flag)
	on = FALSE
	go_out()
	switch(eject_flag)
		if(AUTO_EJECT_HEALTHY)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
		if(AUTO_EJECT_DEAD)
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 40)
	SStgui.update_uis(src)

/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M)
	if(!istype(M))
		to_chat(usr, "<span class='danger'>Подобную форму жизни не удастся поместить в криокапсулу!</span>")
		return
	if(occupant)
		to_chat(usr, "<span class='danger'>Криокапсула уже занята!</span>")
		return
	if(M.abiotic())
		to_chat(usr, "<span class='warning'>Субъект не должен держать в руках абиотические предметы.</span>")
		return
	if(!node)
		to_chat(usr, "<span class='warning'>Криокапсула не подключена к трубам!</span>")
		return
	M.stop_pulling()
	M.forceMove(src)
	if(M.health > -100 && (M.health < 0 || M.sleeping))
		to_chat(M, "<span class='boldnotice'>Вас окружает холодная жидкость. Кожа начинает замерзать.</span>")
	occupant = M
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	M.ExtinguishMob()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Извлечь пациента"
	set category = "Object"
	set src in oview(1)

	if(usr == occupant)//If the user is inside the tube...
		if(usr.stat == DEAD)
			return
		to_chat(usr, "<span class='notice'>Активирована высвобождающая последовательность. Время ожидания: две минуты.</span>")
		sleep(600)
		if(!src || !usr || !occupant || (occupant != usr)) //Check if someone's released/replaced/bombed him already
			return
		go_out()//and release him from the eternal prison.
	else
		if(usr.default_can_use_topic(src) != STATUS_INTERACTIVE)
			return
		if(usr.incapacitated()) //are you cuffed, dying, lying, stunned or other
			return
		add_attack_logs(usr, occupant, "Ejected from cryo cell at [COORD(src)]")
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/atmospherics/unary/cryo_cell/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	color = "red"//force the icon to red
	light_color = LIGHT_COLOR_RED

/obj/machinery/atmospherics/unary/cryo_cell/ratvar_act()
	go_out()
	new /obj/effect/decal/cleanable/blood/gibs/clock(get_turf(src))
	qdel(src)

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Залезть внутрь"
	set category = "Object"
	set src in oview(1)

	if(usr.has_buckled_mobs()) //mob attached to us
		to_chat(usr, "<span class='warning'>[usr] не влез[pluralize_ru(usr.gender,"ет","ут")] в [src], потому что к [genderize_ru(usr.gender,"его","её","его","их")] голове прилеплен слайм.</span>")
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(usr.incapacitated() || usr.buckled) //are you cuffed, dying, lying, stunned or other
		return

	put_mob(usr)
	return



/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user)
	return

/datum/data/function/proc/display()
	return

/obj/machinery/atmospherics/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/unary/cryo_cell/update_remote_sight(mob/living/user)
	return //we don't see the pipe network while inside cryo.

/obj/machinery/atmospherics/unary/cryo_cell/can_crawl_through()
	return // can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/unary/cryo_cell/can_see_pipes()
	return FALSE // you can't see the pipe network when inside a cryo cell.

#undef AUTO_EJECT_HEALTHY
#undef AUTO_EJECT_DEAD
