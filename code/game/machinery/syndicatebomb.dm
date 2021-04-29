#define BUTTON_COOLDOWN 60 // cant delay the bomb forever
#define BUTTON_DELAY	50 //five seconds

/obj/machinery/syndicatebomb
	icon = 'icons/obj/assemblies.dmi'
	name = "syndicate bomb"
	icon_state = "syndicate-bomb"
	desc = "A large and menacing device. Can be bolted down with a wrench."

	anchored = 0
	density = 0
	layer = BELOW_MOB_LAYER //so people can't hide it and it's REALLY OBVIOUS
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/datum/wires/syndicatebomb/wires = null
	var/minimum_timer = 90
	var/timer_set = 90
	var/maximum_timer = 60000

	var/can_unanchor = TRUE

	var/open_panel = FALSE 	//are the wires exposed?
	var/active = FALSE		//is the bomb counting down?
	var/defused = FALSE		//is the bomb capable of exploding?
	var/obj/item/bombcore/payload = /obj/item/bombcore
	var/beepsound = 'sound/items/timer.ogg'
	var/delayedbig = FALSE	//delay wire pulsed?
	var/delayedlittle  = FALSE	//activation wire pulsed?
	var/obj/effect/countdown/syndicatebomb/countdown

	var/next_beep
	var/detonation_timer
	var/explode_now = FALSE

/obj/machinery/syndicatebomb/proc/try_detonate(ignore_active = FALSE)
	. = (payload in src) && (active || ignore_active) && !defused
	if(.)
		payload.detonate()

/obj/machinery/syndicatebomb/obj_break()
	if(!try_detonate())
		..()

/obj/machinery/syndicatebomb/obj_destruction()
	if(!try_detonate())
		..()

/obj/machinery/syndicatebomb/process()
	if(!active)
		STOP_PROCESSING(SSfastprocess, src)
		detonation_timer = null
		next_beep = null
		countdown.stop()
		return

	if(!isnull(next_beep) && (next_beep <= world.time))
		var/volume
		switch(seconds_remaining())
			if(0 to 5)
				volume = 50
			if(5 to 10)
				volume = 40
			if(10 to 15)
				volume = 30
			if(15 to 20)
				volume = 20
			if(20 to 25)
				volume = 10
			else
				volume = 5
		playsound(loc, beepsound, volume, 0)
		next_beep = world.time + 10

	if(active && !defused && ((detonation_timer <= world.time) || explode_now))
		active = FALSE
		timer_set = initial(timer_set)
		update_icon()
		try_detonate(TRUE)
	//Counter terrorists win
	else if(defused)
		active = FALSE
		if(payload in src)
			payload.defuse()

/obj/machinery/syndicatebomb/New()
	wires 	= new(src)
	if(payload)
		payload = new payload(src)
	update_icon()
	countdown = new(src)
	..()

/obj/machinery/syndicatebomb/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	QDEL_NULL(countdown)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/machinery/syndicatebomb/examine(mob/user)
	. = ..()
	. += "A digital display on it reads \"[seconds_remaining()]\"."

/obj/machinery/syndicatebomb/update_icon()
	icon_state = "[initial(icon_state)][active ? "-active" : "-inactive"][open_panel ? "-wires" : ""]"

/obj/machinery/syndicatebomb/proc/seconds_remaining()
	if(active)
		. = max(0, round((detonation_timer - world.time) / 10))
	else
		. = timer_set

/obj/machinery/syndicatebomb/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly/signaler))
		if(open_panel)
			wires.Interact(user)
	else if(istype(I, /obj/item/bombcore))
		if(!payload)
			if(!user.drop_item())
				return
			payload = I
			to_chat(user, "<span class='notice'>You place [payload] into [src].</span>")
			payload.forceMove(src)
		else
			to_chat(user, "<span class='notice'>[payload] is already loaded into [src], you'll have to remove it first.</span>")
	else
		return ..()

/obj/machinery/syndicatebomb/wrench_act(mob/user, obj/item/I)
	if(!can_unanchor)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!anchored)
		if(!isturf(loc) || isspaceturf(loc))
			to_chat(user, "<span class='notice'>The bomb must be placed on solid ground to attach it.</span>")
		else
			WRENCH_ANCHOR_MESSAGE
			anchored = TRUE
			if(active)
				to_chat(user, "<span class='notice'>The bolts lock in place.</span>")
	else
		if(!active)
			WRENCH_UNANCHOR_MESSAGE
			anchored = FALSE
		else
			to_chat(user, "<span class='warning'>The bolts are locked down!</span>")

/obj/machinery/syndicatebomb/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	open_panel = !open_panel
	update_icon()
	to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")

/obj/machinery/syndicatebomb/wirecutter_act(mob/user, obj/item/I)
	if(!open_panel)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wires.Interact(user)

/obj/machinery/syndicatebomb/multitool_act(mob/user, obj/item/I)
	if(!open_panel)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wires.Interact(user)

/obj/machinery/syndicatebomb/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(open_panel && wires.is_all_cut())
		if(payload)
			to_chat(user, "<span class='notice'>You carefully pry out [payload].</span>")
			payload.loc = user.loc
			payload = null
		else
			to_chat(user, "<span class='warning'>There isn't anything in here to remove!</span>")
	else if(open_panel)
		to_chat(user, "<span class='warning'>The wires connecting the shell to the explosives are holding it down!</span>")
	else
		to_chat(user, "<span class='warning'>The cover is screwed on, it won't pry off!</span>")

/obj/machinery/syndicatebomb/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(payload || !wires.is_all_cut() || !open_panel)
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		new /obj/item/stack/sheet/plasteel(drop_location(), 3)
		qdel(src)

/obj/machinery/syndicatebomb/attack_ghost(mob/user)
	interact(user)

/obj/machinery/syndicatebomb/attack_hand(mob/user)
	interact(user)

/obj/machinery/syndicatebomb/attack_ai()
	return

/obj/machinery/syndicatebomb/interact(mob/user)
	if(wires && open_panel)
		wires.Interact(user)
	if(!open_panel && can_interact(user))
		if(!active)
			spawn()
				settings(user)
				return
		else if(anchored)
			to_chat(user, "<span class='notice'>The bomb is bolted to the floor!</span>")

/obj/machinery/syndicatebomb/proc/can_interact(mob/user)
	if(user.can_advanced_admin_interact())
		return TRUE
	if(!isliving(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied!</span>")
		return FALSE
	return TRUE

/obj/machinery/syndicatebomb/proc/activate()
	active = TRUE
	START_PROCESSING(SSfastprocess, src)
	countdown.start()
	next_beep = world.time + 10
	detonation_timer = world.time + (timer_set * 10)
	playsound(loc, 'sound/machines/click.ogg', 30, 1)

/obj/machinery/syndicatebomb/proc/settings(mob/user)
	var/new_timer = input(user, "Please set the timer.", "Timer", "[timer_set]") as num
	if(can_interact(user)) //No running off and setting bombs from across the station
		timer_set = clamp(new_timer, minimum_timer, maximum_timer)
		loc.visible_message("<span class='notice'>[bicon(src)] timer set for [timer_set] seconds.</span>")
	if(alert(user,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && can_interact(user))
		if(defused || active)
			if(defused)
				loc.visible_message("<span class='notice'>[bicon(src)] Device error: User intervention required.</span>")
			return
		else
			loc.visible_message("<span class='danger'>[bicon(src)] [timer_set] seconds until detonation, please clear the area.</span>")
			activate()
			update_icon()
			add_fingerprint(user)

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			if(payload && !istype(payload, /obj/item/bombcore/training))
				log_game("[key_name(user)] has primed a [name] ([payload]) for detonation at [A.name] [COORD(bombturf)]")
				investigate_log("[key_name(user)] has has primed a [name] ([payload]) for detonation at [A.name] [COORD(bombturf)]", INVESTIGATE_BOMB)
				add_attack_logs(user, src, "has primed a [name] ([payload]) for detonation", ATKLOG_FEW)
				payload.adminlog = "\The [src] that [key_name(user)] had primed detonated!"

///Bomb Subtypes///

/obj/machinery/syndicatebomb/training
	name = "training bomb"
	icon_state = "training-bomb"
	desc = "A salvaged syndicate device gutted of its explosives to be used as a training aid for aspiring bomb defusers."
	payload = /obj/item/bombcore/training

/obj/machinery/syndicatebomb/emp
	name = "emp bomb"
	icon_state = "emp-bomb"
	desc = "A large bomb, seemingly made to make a large electromagnetic pulse."
	payload = /obj/item/bombcore/emp

/obj/machinery/syndicatebomb/badmin
	name = "generic summoning badmin bomb"
	desc = "Oh god what is in this thing?"
	payload = /obj/item/bombcore/badmin/summon

/obj/machinery/syndicatebomb/badmin/clown
	name = "clown bomb"
	icon_state = "clown-bomb"
	desc = "HONK."
	payload = /obj/item/bombcore/badmin/summon/clown
	beepsound = 'sound/items/bikehorn.ogg'

/obj/machinery/syndicatebomb/empty
	name = "bomb"
	icon_state = "base-bomb"
	desc = "An ominous looking device designed to detonate an explosive payload. Can be bolted down using a wrench."
	payload = null
	open_panel = TRUE
	timer_set = 120

/obj/machinery/syndicatebomb/empty/New()
	..()
	wires.cut_all()


///Bomb Cores///

/obj/item/bombcore
	name = "bomb payload"
	desc = "A powerful secondary explosive of syndicate design and unknown composition, it should be stable under normal conditions..."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bombcore"
	item_state = "eshield0"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "syndicate=5;combat=6"
	resistance_flags = FLAMMABLE //Burnable (but the casing isn't)
	var/adminlog = null
	var/range_heavy = 3
	var/range_medium = 9
	var/range_light = 17
	var/range_flame = 17
	var/admin_log = TRUE

/obj/item/bombcore/ex_act(severity) //Little boom can chain a big boom
	detonate()


/obj/item/bombcore/burn()
	detonate()
	..()

/obj/item/bombcore/proc/detonate()
	if(adminlog)
		message_admins(adminlog)
		log_game(adminlog)
	explosion(get_turf(src), range_heavy, range_medium, range_light, flame_range = range_flame, adminlog = admin_log)
	if(loc && istype(loc, /obj/machinery/syndicatebomb))
		qdel(loc)
	qdel(src)

/obj/item/bombcore/proc/defuse()
//Note: 	Because of how var/defused is used you shouldn't override this UNLESS you intend to set the var to 0 or
//			otherwise remove the core/reset the wires before the end of defuse(). It will repeatedly be called otherwise.

///Bomb Core Subtypes///

/obj/item/bombcore/training
	name = "dummy payload"
	desc = "A nanotrasen replica of a syndicate payload. Its not intended to explode but to announce that it WOULD have exploded, then rewire itself to allow for more training."
	origin_tech = null
	var/defusals = 0
	var/attempts = 0

/obj/item/bombcore/training/proc/reset()
	var/obj/machinery/syndicatebomb/holder = loc
	if(istype(holder))
		if(holder.wires)
			holder.wires.shuffle_wires()
		holder.defused = 0
		holder.open_panel = 0
		holder.delayedbig = FALSE
		holder.delayedlittle = FALSE
		holder.explode_now = FALSE
		holder.update_icon()
		holder.updateDialog()

/obj/item/bombcore/training/detonate()
	var/obj/machinery/syndicatebomb/holder = loc
	if(istype(holder))
		attempts++
		holder.loc.visible_message("<span class='danger'>[bicon(holder)] Alert: Bomb has detonated. Your score is now [defusals] for [attempts]. Resetting wires...</span>")
		reset()
	else
		qdel(src)

/obj/item/bombcore/training/defuse()
	var/obj/machinery/syndicatebomb/holder = loc
	if(istype(holder))
		attempts++
		defusals++
		holder.loc.visible_message("<span class='notice'>[bicon(holder)] Alert: Bomb has been defused. Your score is now [defusals] for [attempts]! Resetting wires in 5 seconds...</span>")
		sleep(50)	//Just in case someone is trying to remove the bomb core this gives them a little window to crowbar it out
		if(istype(holder))
			reset()

/obj/item/bombcore/badmin
	name = "badmin payload"
	desc = "If you're seeing this someone has either made a mistake or gotten dangerously savvy with var editing!"
	origin_tech = null

/obj/item/bombcore/badmin/defuse() //because we wouldn't want them being harvested by players
	var/obj/machinery/syndicatebomb/B = loc
	qdel(B)
	qdel(src)

/obj/item/bombcore/badmin/summon
	var/summon_path = /obj/item/reagent_containers/food/snacks/cookie
	var/amt_summon = 1

/obj/item/bombcore/badmin/summon/detonate()
	var/obj/machinery/syndicatebomb/B = src.loc
	for(var/i = 0; i < amt_summon; i++)
		var/atom/movable/X = new summon_path
		X.admin_spawned = TRUE
		X.loc = get_turf(src)
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(X, pick(NORTH,SOUTH,EAST,WEST))
	qdel(B)
	qdel(src)

/obj/item/bombcore/badmin/summon/clown
	summon_path = /mob/living/simple_animal/hostile/retaliate/clown
	amt_summon 	= 100

/obj/item/bombcore/badmin/summon/clown/defuse()
	playsound(src.loc, 'sound/misc/sadtrombone.ogg', 50)
	..()

/obj/item/bombcore/large
	name = "large bomb payload"
	range_heavy = 5
	range_medium = 10
	range_light = 20
	range_flame = 20

/obj/item/bombcore/large/explosive_wall
	admin_log = FALSE

/obj/item/bombcore/large/underwall
	layer = ABOVE_OPEN_TURF_LAYER

/obj/item/bombcore/miniature
	name = "small bomb core"
	w_class = WEIGHT_CLASS_SMALL
	range_heavy = 1
	range_medium = 2
	range_light = 4
	range_flame = 2

/obj/item/bombcore/emp
	name = "EMP bomb core"
	var/light_emp = 36
	var/heavy_emp = 18
	var/pulse_number = 1 //Since one EMP wont destroy anything other then consoles and IPCS, here is an option to have multiple pulses when dentonating. DO NOT USE THIS WITH REALLY LARGE AREAS
	var/adminlogged = FALSE //If it exploded once, don't do it again.

/obj/item/bombcore/emp/ex_act(severity) //It's an EMP bomb, not a chemical explosive
	return

/obj/item/bombcore/emp/burn()
	return

/obj/item/bombcore/emp/detonate()
	if(adminlog && !adminlogged)
		message_admins(adminlog)
		log_game(adminlog)
		adminlogged = TRUE
	empulse(src, heavy_emp, light_emp, 1)
	if(pulse_number <= 1)
		src.visible_message("<span class='warning'>The bomb's core burns out, and the bomb disintegrates into ash.</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		if(loc && istype(loc, /obj/machinery/syndicatebomb))
			qdel(loc)
		qdel(src)
	else
		pulse_number -= 1
		addtimer(CALLBACK(src, .proc/detonate), 20) // every 2 seconds go off again till pulses run out

/obj/item/bombcore/chemical
	name = "chemical payload"
	desc = "An explosive payload designed to spread chemicals, dangerous or otherwise, across a large area. It is able to hold up to four chemical containers, and must be loaded before use."
	origin_tech = "combat=4;materials=3"
	icon_state = "chemcore"
	var/list/beakers = list()
	var/max_beakers = 1
	var/spread_range = 5
	var/temp_boost = 50
	var/time_release = 0

/obj/item/bombcore/chemical/detonate()

	if(time_release > 0)
		var/total_volume = 0
		for(var/obj/item/reagent_containers/RC in beakers)
			total_volume += RC.reagents.total_volume

		if(total_volume < time_release) // If it's empty, the detonation is complete.
			if(loc && istype(loc, /obj/machinery/syndicatebomb))
				qdel(loc)
			qdel(src)
			return

		var/fraction = time_release/total_volume
		var/datum/reagents/reactants = new(time_release)
		reactants.my_atom = src
		for(var/obj/item/reagent_containers/RC in beakers)
			RC.reagents.trans_to(reactants, RC.reagents.total_volume*fraction, 1, 1, 1)
		chem_splash(get_turf(src), spread_range, list(reactants), temp_boost)

		// Detonate it again in one second, until it's out of juice.
		addtimer(CALLBACK(src, .proc/detonate), 10)

	// If it's not a time release bomb, do normal explosion

	var/list/reactants = list()

	for(var/obj/item/reagent_containers/glass/G in beakers)
		reactants += G.reagents

	for(var/obj/item/slime_extract/S in beakers)
		if(S.Uses)
			for(var/obj/item/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(S, G.reagents.total_volume)

			if(S && S.reagents && S.reagents.total_volume)
				reactants += S.reagents

	if(!chem_splash(get_turf(src), spread_range, reactants, temp_boost))
		playsound(loc, 'sound/items/screwdriver2.ogg', 50, 1)
		return // The Explosion didn't do anything. No need to log, or disappear.

	if(adminlog)
		message_admins(adminlog)
		log_game(adminlog)

	playsound(loc, 'sound/effects/bamf.ogg', 75, 1, 5)

	if(loc && istype(loc, /obj/machinery/syndicatebomb))
		qdel(loc)
	qdel(src)

/obj/item/bombcore/chemical/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass/beaker) || istype(I, /obj/item/reagent_containers/glass/bottle))
		if(beakers.len < max_beakers)
			if(!user.drop_item())
				return
			beakers += I
			to_chat(user, "<span class='notice'>You load [src] with [I].</span>")
			I.loc = src
		else
			to_chat(user, "<span class='warning'>The [I] wont fit! The [src] can only hold up to [max_beakers] containers.</span>")
			return
	else
		return ..()

/obj/item/bombcore/chemical/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(beakers.len == 0)
		return
	for(var/obj/item/B in beakers)
		B.loc = get_turf(src)
		beakers -= B

/obj/item/bombcore/chemical/CheckParts(list/parts_list)
	..()
	// Using different grenade casings, causes the payload to have different properties.
	var/obj/item/stock_parts/matter_bin/MB = locate(/obj/item/stock_parts/matter_bin) in src
	if(MB)
		max_beakers += MB.rating	// max beakers = 2-5.
		qdel(MB)
	for(var/obj/item/grenade/chem_grenade/G in src)

		if(istype(G, /obj/item/grenade/chem_grenade/large))
			var/obj/item/grenade/chem_grenade/large/LG = G
			max_beakers += 1 // Adding two large grenades only allows for a maximum of 7 beakers.
			spread_range += 2 // Extra range, reduced density.
			temp_boost += 50 // maximum of +150K blast using only large beakers. Not enough to self ignite.
			for(var/obj/item/slime_extract/S in LG.beakers) // And slime cores.
				if(beakers.len < max_beakers)
					beakers += S
					S.loc = src
				else
					S.loc = get_turf(src)

		if(istype(G, /obj/item/grenade/chem_grenade/cryo))
			spread_range -= 1 // Reduced range, but increased density.
			temp_boost -= 100 // minimum of -150K blast.

		if(istype(G, /obj/item/grenade/chem_grenade/pyro))
			temp_boost += 150 // maximum of +350K blast, which is enough to self ignite. Which means a self igniting bomb can't take advantage of other grenade casing properties. Sorry?

		if(istype(G, /obj/item/grenade/chem_grenade/adv_release))
			time_release += 50 // A typical bomb, using basic beakers, will explode over 2-4 seconds. Using two will make the reaction last for less time, but it will be more dangerous overall.

		for(var/obj/item/reagent_containers/glass/B in G)
			if(beakers.len < max_beakers)
				beakers += B
				B.loc = src
			else
				B.loc = get_turf(src)

		qdel(G)

/obj/item/bombcore/toxins
	name = "toxins payload"
	desc = "A payload casing designed to secure a gas based bomb. Must be loaded with a tank transfer valve and installed into a plasteel bomb frame in order to be detonated."
	origin_tech = "materials=1;engineering=1"
	icon_state = "chemcore"
	var/obj/item/transfer_valve/ttv = null

/obj/item/bombcore/toxins/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/transfer_valve))
		if(!ttv && !check_attached(I))
			if(!user.drop_item())
				return
			to_chat(user, "<span class='notice'>You load [src] with [I].</span>")
			ttv = I
			I.forceMove(src)
		else if (ttv)
			to_chat(user, "<span class='warning'>Another tank transfer valve is already loaded.</span>")
		else
			to_chat(user, "<span class='warning'>Remove the attached assembly component first.</span>")
	else
		return ..()

/obj/item/bombcore/toxins/crowbar_act(mob/user, obj/item/I)
	if(!ttv)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	ttv.forceMove(get_turf(src))
	ttv = null



/obj/item/bombcore/toxins/proc/check_attached(obj/item/transfer_valve/ttv)
	if (ttv.attached_device)
		return TRUE
	else
		return FALSE

/obj/item/bombcore/toxins/ex_act(severity) //No chain reactions, the explosion only occurs when gas mixes
	return

/obj/item/bombcore/toxins/burn()
	return

/obj/item/bombcore/toxins/detonate()
	if(ttv)
		ttv.toggle_valve()

///Syndicate Detonator (aka the big red button)///

/obj/item/syndicatedetonator
	name = "big red button"
	desc = "Your standard issue bomb synchronizing button. Five second safety delay to prevent 'accidents'."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "syndicate=3"
	var/timer = 0
	var/detonated =	0
	var/existant =	0

/obj/item/syndicatedetonator/attack_self(mob/user)
	if(timer < world.time)
		for(var/obj/machinery/syndicatebomb/B in GLOB.machines)
			if(B.active)
				B.detonation_timer = world.time + BUTTON_DELAY
				detonated++
			existant++
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[existant] found, [detonated] triggered.</span>")
		if(detonated)
			var/turf/T = get_turf(src)
			var/area/A = get_area(T)
			detonated--
			investigate_log("[key_name(user)] has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at [A.name] ([T.x],[T.y],[T.z])", INVESTIGATE_BOMB)
			add_attack_logs(user, src, "has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using", ATKLOG_FEW)
			log_game("[key_name(user)] has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at [A.name] ([T.x],[T.y],[T.z])")
		detonated =	0
		existant =	0
		timer = world.time + BUTTON_COOLDOWN

#undef BUTTON_COOLDOWN
#undef BUTTON_DELAY
