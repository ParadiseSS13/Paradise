/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	desc = "Lowers the body temperature so certain medications may take effect."
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod0"
	density = 1
	anchored = 1.0
	layer = 2.8
	interact_offline = 1
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100)
	var/on = 0
	var/temperature_archived
	var/mob/living/carbon/occupant = null
	var/obj/item/reagent_containers/glass/beaker = null
	var/autoeject = 0

	var/next_trans = 0
	var/current_heat_capacity = 50
	var/efficiency

	var/running_bob_animation = 0 // This is used to prevent threads from building up if update_icons is called multiple times

	light_color = LIGHT_COLOR_WHITE
	power_change()
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
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cryo_cell/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
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
	for(var/cdir in cardinal)
		node = findConnecting(cdir)
		if(node)
			break

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	var/turf/T = get_turf(src)
	if(istype(T))
		T.contents += contents
		var/obj/item/reagent_containers/glass/B = beaker
		if(beaker)
			B.forceMove(get_step(T, SOUTH)) //Beaker is carefully ejected from the wreckage of the cryotube
			beaker = null
	return ..()

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(atom/movable/O as mob|obj, mob/living/user as mob)
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
		to_chat(user, "<span class='boldnotice'>The cryo cell is already occupied!</span>")
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		to_chat(user, "<span class='danger'>Subject cannot have abiotic items on.</span>")
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the cryo cell because [L.p_they()] [L.p_have()] a slime latched onto [L.p_their()] head.")
			return
	if(put_mob(L))
		if(L == user)
			visible_message("[user] climbs into the cryo cell.")
		else
			visible_message("[user] puts [L.name] into the cryo cell.")
			add_attack_logs(user, L, "put into a cryo cell at [COORD(src)].", ATKLOG_ALL)
			if(user.pulling == L)
				user.stop_pulling()

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(autoeject)
		if(occupant)
			if(!occupant.has_organic_damage() && !occupant.has_mutated_organs())
				on = 0
				go_out()
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)

	if(air_contents)
		if(occupant)
			process_occupant()

	return 1

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


/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/atmospherics/unary/cryo_cell/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	if(user == occupant)
		return

	if(panel_open)
		to_chat(usr, "<span class='boldnotice'>Close the maintenance panel first.</span>")
		return

	ui_interact(user)


 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable (which is inherited by /obj and /mob)
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 420)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/cryo_cell/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0

	var/occupantData[0]
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
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData;

	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > 225)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	data["autoeject"] = autoeject
	return data

/obj/machinery/atmospherics/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant)
		return 0 // don't update UIs attached to this object

	if(..())
		return 0 // don't update UIs attached to this object

	if(href_list["switchOn"])
		on = 1
		update_icon()

	if(href_list["switchOff"])
		on = 0
		update_icon()

	if(href_list["autoejectOn"])
		autoeject = 1

	if(href_list["autoejectOff"])
		autoeject = 0

	if(href_list["ejectBeaker"])
		if(beaker)
			beaker.forceMove(get_step(loc, SOUTH))
			beaker = null

	if(href_list["ejectOccupant"])
		if(!occupant || isslime(usr) || ispAI(usr))
			return 0 // don't update UIs attached to this object
		add_attack_logs(usr, occupant, "ejected from cryo cell at [COORD(src)]", ATKLOG_ALL)
		go_out()

	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/atmospherics/unary/cryo_cell/attackby(var/obj/item/G as obj, var/mob/user as mob, params)
	if(istype(G, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/B = G
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "[B] is stuck to you!")
			return
		B.forceMove(src)
		beaker =  B
		add_attack_logs(user, null, "Added [B] containing [B.reagents.log_list()] to a cryo cell at [COORD(src)]")
		user.visible_message("[user] adds \a [B] to [src]!", "You add \a [B] to [src]!")


	if(istype(G, /obj/item/screwdriver))
		if(occupant || on)
			to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
			return
		default_deconstruction_screwdriver(user, "pod0-o", "pod0", G)
		return

	if(exchange_parts(user, G))
		return

	default_deconstruction_crowbar(G)

	if(istype(G, /obj/item/grab))
		var/obj/item/grab/GG = G
		if(panel_open)
			to_chat(user, "<span class='boldnotice'>Close the maintenance panel first.</span>")
			return
		if(!ismob(GG.affecting))
			return
		for(var/mob/living/carbon/slime/M in range(1,GG.affecting))
			if(M.Victim == GG.affecting)
				to_chat(usr, "[GG.affecting.name] will not fit into the cryo because [GG.affecting.p_they()] [GG.affecting.p_have()] a slime latched onto [GG.affecting.p_their()] head.")
				return
		var/mob/M = GG.affecting
		if(put_mob(M))
			qdel(GG)
	return

/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	handle_update_icon()

/obj/machinery/atmospherics/unary/cryo_cell/proc/handle_update_icon() //making another proc to avoid spam in update_icon
	overlays.Cut() //empty the overlay proc, just in case
	icon_state = "pod[on]" //set the icon properly every time

	if(!src.occupant)
		overlays += "lid[on]" //if no occupant, just put the lid overlay on, and ignore the rest
		return


	if(occupant)
		var/image/pickle = image(occupant.icon, occupant.icon_state)
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
		if(occupant.stat == 2 || (occupant.health >= 100 && !occupant.has_mutated_organs()))  //Why waste energy on dead or healthy people
			occupant.bodytemperature = T0C
			return
		occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + air_contents.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
		if(occupant.bodytemperature < T0C)
			occupant.Sleeping(max(5/efficiency, (1/occupant.bodytemperature)*2000/efficiency))
			occupant.Paralyse(max(5/efficiency, (1/occupant.bodytemperature)*3000/efficiency))
			if(air_contents.oxygen > 2)
				if(occupant.getOxyLoss())
					occupant.adjustOxyLoss(-10)
			else
				occupant.adjustOxyLoss(-2)
		if(beaker && next_trans == 0)
			var/proportion = 10 * min(1/beaker.volume, 1)
			// Yes, this means you can get more bang for your buck with a beaker of SF vs a patch
			// But it also means a giant beaker of SF won't heal people ridiculously fast 4 cheap
			beaker.reagents.reaction(occupant, TOUCH, proportion)
			beaker.reagents.trans_to(occupant, 1, 10)
	next_trans++
	if(next_trans == 10)
		next_trans = 0

/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles() < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

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

/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob)
	if(!istype(M))
		to_chat(usr, "<span class='danger'>The cryo cell cannot handle such a lifeform!</span>")
		return
	if(occupant)
		to_chat(usr, "<span class='danger'>The cryo cell is already occupied!</span>")
		return
	if(M.abiotic())
		to_chat(usr, "<span class='warning'>Subject may not have abiotic items on.</span>")
		return
	if(!node)
		to_chat(usr, "<span class='warning'>The cell is not correctly connected to its pipe network!</span>")
		return
	M.stop_pulling()
	M.forceMove(src)
	if(M.health > -100 && (M.health < 0 || M.sleeping))
		to_chat(M, "<span class='boldnotice'>You feel a cold liquid surround you. Your skin starts to freeze up.</span>")
	occupant = M
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	M.ExtinguishMob()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)

	if(usr == occupant)//If the user is inside the tube...
		if(usr.stat == DEAD)
			return
		to_chat(usr, "<span class='notice'>Release sequence activated. This will take two minutes.</span>")
		sleep(600)
		if(!src || !usr || !occupant || (occupant != usr)) //Check if someone's released/replaced/bombed him already
			return
		go_out()//and release him from the eternal prison.
	else
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

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return

	if(stat & (NOPOWER|BROKEN))
		return

	if(usr.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return

	put_mob(usr)
	return



/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
	return //we don't see the pipe network while inside cryo.
