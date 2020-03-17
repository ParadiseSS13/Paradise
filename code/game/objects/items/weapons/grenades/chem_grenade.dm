#define EMPTY 0
#define WIRED 1
#define READY 2

/obj/item/grenade/chem_grenade
	name = "grenade casing"
	desc = "A do it yourself grenade casing!"
	icon_state = "chemg"
	item_state = "flashbang"
	var/bomb_state = "chembomb"
	var/payload_name = null // used for spawned grenades
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	var/prime_sound = 'sound/items/screwdriver2.ogg'
	var/stage = EMPTY
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/assembly_holder/nadeassembly = null
	var/label = null
	var/assemblyattacher
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.
	var/no_splash = FALSE //If the grenade deletes even if it has no reagents to splash with. Used for slime core reactions.
	var/contained = "" // For logging
	var/cores = "" // Also for logging

/obj/item/grenade/chem_grenade/New()
	..()
	create_reagents(1000)
	if(payload_name)
		payload_name += " " // formatting, ignore me
	update_icon()

/obj/item/grenade/chem_grenade/Destroy()
	QDEL_NULL(nadeassembly)
	QDEL_LIST(beakers)
	return ..()

/obj/item/grenade/chem_grenade/examine(mob/user)
	. = ..()
	display_timer = (stage == READY && !nadeassembly)	//show/hide the timer based on assembly state



/obj/item/grenade/chem_grenade/proc/get_trigger()
	if(!nadeassembly) return null
	for(var/obj/O in list(nadeassembly.a_left, nadeassembly.a_right))
		if(!O || istype(O,/obj/item/assembly/igniter)) continue
		return O
	return null


/obj/item/grenade/chem_grenade/proc/update_overlays()
	underlays = list()
	if(nadeassembly)
		underlays += "[nadeassembly.a_left.icon_state]_left"
		for(var/O in nadeassembly.a_left.attached_overlays)
			underlays += "[O]_l"
		underlays += "[nadeassembly.a_right.icon_state]_right"
		for(var/O in nadeassembly.a_right.attached_overlays)
			underlays += "[O]_r"

/obj/item/grenade/chem_grenade/update_icon()
	if(nadeassembly)
		icon = 'icons/obj/assemblies/new_assemblies.dmi'
		icon_state = bomb_state
		update_overlays()
		var/obj/item/assembly/A = get_trigger()
		if(stage != READY)
			name = "bomb casing[label]"
		else
			if(!A)
				name = "[payload_name]de-fused bomb[label]" // this should not actually happen
			else
				name = payload_name + A.bomb_name + label // time bombs, remote mines, etc
	else
		icon = 'icons/obj/grenade.dmi'
		icon_state = initial(icon_state)
		overlays = list()
		switch(stage)
			if(EMPTY)
				name = "grenade casing[label]"
			if(WIRED)
				icon_state += "_ass"
				name = "grenade casing[label]"
			if(READY)
				if(active)
					icon_state += "_active"
				else
					icon_state += "_locked"
				name = payload_name + "grenade" + label


/obj/item/grenade/chem_grenade/attack_self(mob/user)
	if(stage == READY &&  !active)
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		if(nadeassembly)
			nadeassembly.attack_self(user)
			update_icon()
		else if(clown_check(user))
			// This used to go before the assembly check, but that has absolutely zero to do with priming the damn thing.  You could spam the admins with it.
			message_admins("[key_name_admin(usr)] has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> [contained].")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) [contained].")
			investigate_log("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])[contained].", INVESTIGATE_BOMB)
			to_chat(user, "<span class='warning'>You prime the [name]! [det_time / 10] second\s!</span>")
			playsound(user.loc, 'sound/weapons/armbomb.ogg', 60, 1)
			active = 1
			update_icon()
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits [owner]'s [src], setting it off! What a shot!</span>")
		var/turf/T = get_turf(src)
		log_game("A projectile ([hitby]) detonated a grenade held by [key_name(owner)] at [COORD(T)]")
		message_admins("A projectile ([hitby]) detonated a grenade held by [key_name_admin(owner)] at [ADMIN_COORDJMP(T)]")
		prime()
		return 1 //It hit the grenade, not them

/obj/item/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/hand_labeler))
		var/obj/item/hand_labeler/HL = I
		if(length(HL.label))
			label = " ([HL.label])"
			return 0
		else
			if(label)
				label = null
				update_icon()
				to_chat(user, "You remove the label from [src].")
				return 1
	if(istype(I, /obj/item/screwdriver))
		if(stage == WIRED)
			if(beakers.len)
				to_chat(user, "<span class='notice'>You lock the assembly.</span>")
				playsound(loc, prime_sound, 25, -3)
				stage = READY
				update_icon()
				contained = ""
				cores = "" // clear them out so no recursive logging by accidentally
				for(var/obj/O in beakers)
					if(!O.reagents) continue
					if(istype(O,/obj/item/slime_extract))
						cores += " [O]"
					for(var/reagent in O.reagents.reagent_list)
						contained += " [reagent] "
				if(contained)
					if(cores)
						contained = "\[[cores];[contained]\]"
					else
						contained = "\[[contained]\]"
				var/turf/bombturf = get_turf(loc)
				var/area/A = bombturf.loc
				message_admins("[key_name_admin(usr)] has completed [name] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> [contained].")
				log_game("[key_name(usr)] has completed [name] at [bombturf.x], [bombturf.y], [bombturf.z]. [contained]")
			else
				to_chat(user, "<span class='notice'>You need to add at least one beaker before locking the assembly.</span>")
		else if(stage == READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			to_chat(user, "<span class='notice'>You modify the time delay. It's set for [det_time / 10] second\s.</span>")
		else if(stage == EMPTY)
			to_chat(user, "<span class='notice'>You need to add an activation mechanism.</span>")

	else if(stage == WIRED && is_type_in_list(I, allowed_containers))
		if(beakers.len == 2)
			to_chat(user, "<span class='notice'>[src] can not hold more containers.</span>")
			return
		else
			if(I.reagents.total_volume)
				to_chat(user, "<span class='notice'>You add [I] to the assembly.</span>")
				user.drop_item()
				I.loc = src
				beakers += I
			else
				to_chat(user, "<span class='notice'>[I] is empty.</span>")

	else if(stage == EMPTY && istype(I, /obj/item/assembly_holder))
		var/obj/item/assembly_holder/A = I
		if(!A.secured)
			return
		if(isigniter(A.a_left) == isigniter(A.a_right))	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
			return

		user.drop_item()
		nadeassembly = A
		A.master = src
		A.loc = src
		assemblyattacher = user.ckey
		stage = WIRED
		to_chat(user, "<span class='notice'>You add [A] to [src]!</span>")
		update_icon()

	else if(stage == EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		C.use(1)

		stage = WIRED
		to_chat(user, "<span class='notice'>You rig [src].</span>")
		update_icon()

	else if(stage == READY && istype(I, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>You unlock the assembly.</span>")
		stage = WIRED
		update_icon()

	else if(stage == WIRED && istype(I, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You open the grenade and remove the contents.</span>")
		stage = EMPTY
		payload_name = null
		label = null
		if(nadeassembly)
			nadeassembly.loc = get_turf(src)
			nadeassembly.master = null
			nadeassembly = null
		if(beakers.len)
			for(var/obj/O in beakers)
				O.loc = get_turf(src)
			beakers = list()
		update_icon()


//assembly stuff
/obj/item/grenade/chem_grenade/receive_signal()
	prime()

/obj/item/grenade/chem_grenade/HasProximity(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.HasProximity(AM)

/obj/item/grenade/chem_grenade/Move() // prox sensors and infrared care about this
	..()
	if(nadeassembly)
		nadeassembly.process_movement()

/obj/item/grenade/chem_grenade/pickup()
	. = ..()
	if(nadeassembly)
		nadeassembly.process_movement()

/obj/item/grenade/chem_grenade/Crossed(atom/movable/AM, oldloc)
	if(nadeassembly)
		nadeassembly.Crossed(AM, oldloc)

/obj/item/grenade/chem_grenade/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/grenade/chem_grenade/hear_talk(mob/living/M, list/message_pieces)
	if(nadeassembly)
		nadeassembly.hear_talk(M, message_pieces)

/obj/item/grenade/chem_grenade/hear_message(mob/living/M, msg)
	if(nadeassembly)
		nadeassembly.hear_message(M, msg)

/obj/item/grenade/chem_grenade/Bump()
	..()
	if(nadeassembly)
		nadeassembly.process_movement()

/obj/item/grenade/chem_grenade/throw_impact() // called when a throw stops
	..()
	if(nadeassembly)
		nadeassembly.process_movement()


/obj/item/grenade/chem_grenade/prime()
	if(stage != READY)
		return

	var/list/datum/reagents/reactants = list()
	for(var/obj/item/reagent_containers/glass/G in beakers)
		reactants += G.reagents

	if(!chem_splash(get_turf(src), affected_area, reactants, ignition_temp, threatscale) && !no_splash)
		playsound(loc, 'sound/items/screwdriver2.ogg', 50, 1)
		if(beakers.len)
			for(var/obj/O in beakers)
				O.forceMove(get_turf(src))
			beakers = list()
		stage = EMPTY
		update_icon()
		return

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		message_admins("grenade primed by an assembly, attached by [key_name_admin(M)] and last touched by [key_name_admin(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>. [contained]")
		log_game("grenade primed by an assembly, attached by [key_name(M)] and last touched by [key_name(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] ([T.x], [T.y], [T.z]) [contained]")

	update_mob()

	qdel(src)

/obj/item/grenade/chem_grenade/proc/CreateDefaultTrigger(var/typekey)
	if(ispath(typekey,/obj/item/assembly))
		nadeassembly = new(src)
		nadeassembly.a_left = new /obj/item/assembly/igniter(nadeassembly)
		nadeassembly.a_left.holder = nadeassembly
		nadeassembly.a_left.secured = 1
		nadeassembly.a_right = new typekey(nadeassembly)
		if(!nadeassembly.a_right.secured)
			nadeassembly.a_right.toggle_secure() // necessary because fuxing prock_sensors
		nadeassembly.a_right.holder = nadeassembly
		nadeassembly.secured = 1
		nadeassembly.master = src
		nadeassembly.update_icon()
		stage = READY
		update_icon()


//Large chem grenades accept slime cores and use the appropriately.
/obj/item/grenade/chem_grenade/large
	name = "large grenade casing"
	desc = "A custom made large grenade. It affects a larger area."
	icon_state = "large_grenade"
	bomb_state = "largebomb"
	allowed_containers = list(/obj/item/reagent_containers/glass,/obj/item/reagent_containers/food/condiment,
								/obj/item/reagent_containers/food/drinks)
	origin_tech = "combat=3;engineering=3"
	affected_area = 5
	ignition_temp = 25 // Large grenades are slightly more effective at setting off heat-sensitive mixtures than smaller grenades.
	threatscale = 1.1	// 10% more effective.

/obj/item/grenade/chem_grenade/large/prime()
	if(stage != READY)
		return

	for(var/obj/item/slime_extract/S in beakers)
		if(S.Uses)
			for(var/obj/item/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(S, G.reagents.total_volume)

			//If there is still a core (sometimes it's used up)
			//and there are reagents left, behave normally,
			//otherwise drop it on the ground for timed reactions like gold.

			if(S)
				if(S.reagents && S.reagents.total_volume)
					for(var/obj/item/reagent_containers/glass/G in beakers)
						S.reagents.trans_to(G, S.reagents.total_volume)
				else
					S.forceMove(get_turf(src))
					no_splash = TRUE
	..()


	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/grenade/chem_grenade/large/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/slime_extract) && stage == WIRED)
		to_chat(user, "<span class='notice'>You add [I] to the assembly.</span>")
		user.drop_item()
		I.loc = src
		beakers += I
	else
		return ..()

/obj/item/grenade/chem_grenade/cryo // Intended for rare cryogenic mixes. Cools the area moderately upon detonation.
	name = "cryo grenade"
	desc = "A custom made cryogenic grenade. It rapidly cools its contents upon detonation."
	icon_state = "cryog"
	affected_area = 2
	ignition_temp = -100

/obj/item/grenade/chem_grenade/pyro // Intended for pyrotechnical mixes. Produces a small fire upon detonation, igniting potentially flammable mixtures.
	name = "pyro grenade"
	desc = "A custom made pyrotechnical grenade. It heats up and ignites its contents upon detonation."
	icon_state = "pyrog"
	origin_tech = "combat=4;engineering=4"
	affected_area = 3
	ignition_temp = 500 // This is enough to expose a hotspot.

/obj/item/grenade/chem_grenade/adv_release // Intended for weaker, but longer lasting effects. Could have some interesting uses.
	name = "advanced release grenade"
	desc = "A custom made advanced release grenade. It is able to be detonated more than once. Can be configured using a multitool."
	icon_state = "timeg"
	origin_tech = "combat=3;engineering=4"
	var/unit_spread = 10 // Amount of units per repeat. Can be altered with a multitool.

/obj/item/grenade/chem_grenade/adv_release/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(unit_spread)
		if(0 to 24)
			unit_spread += 5
		if(25 to 99)
			unit_spread += 25
		else
			unit_spread = 5
	to_chat(user, "<span class='notice'> You set the time release to [unit_spread] units per detonation.</span>")

/obj/item/grenade/chem_grenade/adv_release/prime()
	if(stage != READY)
		return

	var/total_volume = 0
	for(var/obj/item/reagent_containers/RC in beakers)
		total_volume += RC.reagents.total_volume
	if(!total_volume)
		qdel(src)
		qdel(nadeassembly)
		return
	var/fraction = unit_spread/total_volume
	var/datum/reagents/reactants = new(unit_spread)
	reactants.my_atom = src
	for(var/obj/item/reagent_containers/RC in beakers)
		RC.reagents.trans_to(reactants, RC.reagents.total_volume*fraction, threatscale, 1, 1)
	chem_splash(get_turf(src), affected_area, list(reactants), ignition_temp, threatscale)

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		message_admins("grenade primed by an assembly, attached by [key_name_admin(M)] and last touched by [key_name_admin(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>.")
		log_game("grenade primed by an assembly, attached by [key_name(M)] and last touched by [key_name(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] ([T.x], [T.y], [T.z])")
	else
		addtimer(CALLBACK(src, .proc/prime), det_time)
	var/turf/DT = get_turf(src)
	var/area/DA = get_area(DT)
	log_game("A grenade detonated at [DA.name] ([DT.x], [DT.y], [DT.z])")

/obj/item/grenade/chem_grenade/metalfoam
	payload_name = "metal foam"
	desc = "Used for emergency sealing of air breaches."
	stage = READY

/obj/item/grenade/chem_grenade/metalfoam/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminum", 30)
	B2.reagents.add_reagent("fluorosurfactant", 10)
	B2.reagents.add_reagent("sacid", 10)

	beakers += B1
	beakers += B2
	update_icon()


/obj/item/grenade/chem_grenade/firefighting
	payload_name = "fire fighting grenade"
	desc = "Can help to put out dangerous fires from a distance."
	stage = READY

/obj/item/grenade/chem_grenade/firefighting/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("firefighting_foam", 30)
	B2.reagents.add_reagent("firefighting_foam", 30)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/incendiary
	payload_name = "incendiary"
	desc = "Used for clearing rooms of living things."
	stage = READY

/obj/item/grenade/chem_grenade/incendiary/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("plasma", 25)
	B2.reagents.add_reagent("sacid", 25)


	beakers += B1
	beakers += B2
	update_icon()


/obj/item/grenade/chem_grenade/antiweed
	payload_name = "weed killer"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/grenade/chem_grenade/antiweed/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("atrazine", 30)
	B1.reagents.add_reagent("potassium", 20)
	B2.reagents.add_reagent("phosphorus", 20)
	B2.reagents.add_reagent("sugar", 20)
	B2.reagents.add_reagent("atrazine", 10)

	beakers += B1
	beakers += B2
	update_icon()


/obj/item/grenade/chem_grenade/cleaner
	payload_name = "cleaner"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

/obj/item/grenade/chem_grenade/cleaner/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("cleaner", 10)
	B2.reagents.add_reagent("water", 40) //when you make pre-designed foam reactions that carry the reagents, always add water last

	beakers += B1
	beakers += B2
	update_icon()


/obj/item/grenade/chem_grenade/teargas
	payload_name = "teargas"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/grenade/chem_grenade/teargas/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/facid
	payload_name = "acid smoke"
	desc = "Use to chew up opponents from the inside out."
	stage = READY

/obj/item/grenade/chem_grenade/facid/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("facid", 80)
	B1.reagents.add_reagent("potassium", 20)
	B2.reagents.add_reagent("phosphorus", 20)
	B2.reagents.add_reagent("sugar", 20)
	B2.reagents.add_reagent("facid", 60)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/saringas
	payload_name = "sarin gas"
	desc = "Contains sarin gas; extremely deadly and fast acting; use with extreme caution."
	stage = READY

/obj/item/grenade/chem_grenade/saringas/New()
	..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("sarin", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	update_icon()

#undef EMPTY
#undef WIRED
#undef READY
