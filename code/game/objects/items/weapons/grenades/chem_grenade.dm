#define EMPTY 0
#define WIRED 1
#define READY 2

/obj/item/weapon/grenade/chem_grenade
	name = "grenade casing"
	desc = "A do it yourself grenade casing!"
	icon_state = "chemg"
	item_state = "flashbang"
	var/bomb_state = "chembomb"
	var/payload_name = null // used for spawned grenades
	w_class = 2
	force = 2
	var/stage = EMPTY
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/device/assembly_holder/nadeassembly = null
	var/label = null
	var/assemblyattacher

/obj/item/weapon/grenade/chem_grenade/New()
	create_reagents(1000)
	if(payload_name)
		payload_name += " " // formatting, ignore me
	update_icon()


/obj/item/weapon/grenade/chem_grenade/examine(mob/user)
	..(user)
	display_timer = (stage == READY && !nadeassembly)	//show/hide the timer based on assembly state



/obj/item/weapon/grenade/chem_grenade/proc/get_trigger()
	if(!nadeassembly) return null
	for(var/obj/O in list(nadeassembly.a_left, nadeassembly.a_right))
		if(!O || istype(O,/obj/item/device/assembly/igniter)) continue
		return O
	return null


/obj/item/weapon/grenade/chem_grenade/proc/update_overlays()
	underlays = list()
	if(nadeassembly)
		underlays += "[nadeassembly.a_left.icon_state]_left"
		for(var/O in nadeassembly.a_left.attached_overlays)
			underlays += "[O]_l"
		underlays += "[nadeassembly.a_right.icon_state]_right"
		for(var/O in nadeassembly.a_right.attached_overlays)
			underlays += "[O]_r"

/obj/item/weapon/grenade/chem_grenade/update_icon()
	if(nadeassembly)
		icon = 'icons/obj/assemblies/new_assemblies.dmi'
		icon_state = bomb_state
		update_overlays()
		var/obj/item/device/assembly/A = get_trigger()
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


/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user)
	if(stage == READY &&  !active)
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		if(nadeassembly)
			nadeassembly.attack_self(user)
			update_icon()
		else if(clown_check(user))
			// This used to go before the assembly check, but that has absolutely zero to do with priming the damn thing.  You could spam the admins with it.
			message_admins("[key_name_admin(usr)] has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])")
			bombers += "[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z])"
			to_chat(user, "<span class='warning'>You prime the [name]! [det_time / 10] second\s!</span>")
			active = 1
			update_icon()
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()

/obj/item/weapon/grenade/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(damage && attack_type == PROJECTILE_ATTACK && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits [owner]'s [src], setting it off! What a shot!</span>")
		prime()
		return 1 //It hit the grenade, not them

/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/hand_labeler))
		var/obj/item/weapon/hand_labeler/HL = I
		if(length(HL.label))
			label = " ([HL.label])"
			return 0
		else
			if(label)
				label = null
				update_icon()
				to_chat(user, "You remove the label from [src].")
				return 1
	if(istype(I, /obj/item/weapon/screwdriver))
		if(stage == WIRED)
			if(beakers.len)
				to_chat(user, "<span class='notice'>You lock the assembly.</span>")
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)
				stage = READY
				update_icon()
				var/contained = ""
				var/cores = ""
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
				log_game("[key_name(usr)] has completed [name] at [bombturf.x], [bombturf.y], [bombturf.z].")
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

	else if(stage == EMPTY && istype(I, /obj/item/device/assembly_holder))
		var/obj/item/device/assembly_holder/A = I
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

	else if(stage == READY && istype(I, /obj/item/weapon/wirecutters))
		to_chat(user, "<span class='notice'>You unlock the assembly.</span>")
		stage = WIRED
		update_icon()

	else if(stage == WIRED && istype(I, /obj/item/weapon/wrench))
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
/obj/item/weapon/grenade/chem_grenade/receive_signal()
	prime()

/obj/item/weapon/grenade/chem_grenade/HasProximity(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.HasProximity(AM)

/obj/item/weapon/grenade/chem_grenade/Move() // prox sensors and infrared care about this
	..()
	if(nadeassembly)
		nadeassembly.process_movement()

/obj/item/weapon/grenade/chem_grenade/pickup()
	..()
	if(nadeassembly)
		nadeassembly.process_movement()

/obj/item/weapon/grenade/chem_grenade/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/weapon/grenade/chem_grenade/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/weapon/grenade/chem_grenade/hear_talk(mob/living/M, msg)
	if(nadeassembly)
		nadeassembly.hear_talk(M, msg)

/obj/item/weapon/grenade/chem_grenade/hear_message(mob/living/M, msg)
	if(nadeassembly)
		nadeassembly.hear_message(M, msg)

/obj/item/weapon/grenade/chem_grenade/Bump()
	..()
	if(nadeassembly)
		nadeassembly.process_movement()

/obj/item/weapon/grenade/chem_grenade/throw_impact() // called when a throw stops
	..()
	if(nadeassembly)
		nadeassembly.process_movement()


/obj/item/weapon/grenade/chem_grenade/prime()
	if(stage != READY)
		return

	var/has_reagents = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		if(G.reagents.total_volume)
			has_reagents = 1

	if(!has_reagents)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		message_admins("grenade primed by an assembly, attached by [key_name_admin(M)]<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>(?)</A> ([admin_jump_link(M)]) and last touched by [key_name_admin(last)]<A HREF='?_src_=holder;adminmoreinfo=\ref[last]'>(?)</A> ([admin_jump_link(last)]) ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>.")
		log_game("grenade primed by an assembly, attached by [key_name(M)] and last touched by [key_name(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] ([T.x], [T.y], [T.z])")

	playsound(loc, 'sound/effects/bamf.ogg', 50, 1)

	update_mob()

	invisibility = INVISIBILITY_MAXIMUM		//kaboom
	qdel(nadeassembly) // do this now to stop infrared beams
	var/end_temp = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)
		end_temp += G.reagents.chem_temp
	reagents.chem_temp = end_temp
	if(reagents.total_volume)	//The possible reactions didnt use up all reagents.
		var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, loc))
			if(A == src)
				continue
			reagents.reaction(A, 1, 10)


	spawn(15)		   //Making sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.

/obj/item/weapon/grenade/chem_grenade/proc/CreateDefaultTrigger(var/typekey)
	if(ispath(typekey,/obj/item/device/assembly))
		nadeassembly = new(src)
		nadeassembly.a_left = new /obj/item/device/assembly/igniter(nadeassembly)
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
/obj/item/weapon/grenade/chem_grenade/large
	name = "large grenade casing"
	desc = "For oversized grenades; fits additional contents and affects a greater area."
	icon_state = "large_grenade"
	bomb_state = "largebomb"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass,/obj/item/weapon/reagent_containers/food/condiment,
								/obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = "combat=3;materials=3"
	affected_area = 4


/obj/item/weapon/grenade/chem_grenade/large/prime()
	if(stage != READY)
		return

	var/has_reagents = 0
	var/obj/item/slime_extract/valid_core = null

	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		if(!istype(G)) continue
		if(G.reagents.total_volume) has_reagents = 1
	for(var/obj/item/slime_extract/E in beakers)
		if(!istype(E)) continue
		if(E.Uses) valid_core = E
		if(E.reagents.total_volume) has_reagents = 1

	if(!has_reagents)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	playsound(loc, 'sound/effects/bamf.ogg', 50, 1)

	update_mob()

	if(valid_core)
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(valid_core, G.reagents.total_volume)

		//If there is still a core (sometimes it's used up)
		//and there are reagents left, behave normally

		if(valid_core && valid_core.reagents && valid_core.reagents.total_volume)
			valid_core.reagents.trans_to(src,valid_core.reagents.total_volume)
	else
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

	if(reagents.total_volume)	//The possible reactions didnt use up all reagents.
		var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, loc))
			if( A == src ) continue
			reagents.reaction(A, 1, 10)

	invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.


	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/weapon/grenade/chem_grenade/large/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/slime_extract) && stage == WIRED)
		to_chat(user, "<span class='notice'>You add [I] to the assembly.</span>")
		user.drop_item()
		I.loc = src
		beakers += I
	else
		return ..()


/obj/item/weapon/grenade/chem_grenade/metalfoam
	payload_name = "metal foam"
	desc = "Used for emergency sealing of air breaches."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 30)
		B2.reagents.add_reagent("fluorosurfactant", 10)
		B2.reagents.add_reagent("sacid", 10)

		beakers += B1
		beakers += B2
		update_icon()


/obj/item/weapon/grenade/chem_grenade/incendiary
	payload_name = "incendiary"
	desc = "Used for clearing rooms of living things."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

		B1.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("plasma", 25)
		B2.reagents.add_reagent("sacid", 25)


		beakers += B1
		beakers += B2
		update_icon()


/obj/item/weapon/grenade/chem_grenade/antiweed
	payload_name = "weed killer"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("atrazine", 30)
		B1.reagents.add_reagent("potassium", 20)
		B2.reagents.add_reagent("phosphorus", 20)
		B2.reagents.add_reagent("sugar", 20)
		B2.reagents.add_reagent("atrazine", 10)

		beakers += B1
		beakers += B2
		update_icon()


/obj/item/weapon/grenade/chem_grenade/cleaner
	payload_name = "cleaner"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 40)
		B2.reagents.add_reagent("cleaner", 10)
		B2.reagents.add_reagent("water", 40) //when you make pre-designed foam reactions that carry the reagents, always add water last

		beakers += B1
		beakers += B2
		update_icon()


/obj/item/weapon/grenade/chem_grenade/teargas
	payload_name = "teargas"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("condensedcapsaicin", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2
		update_icon()

/obj/item/weapon/grenade/chem_grenade/facid
	name = "acid grenade"
	desc = "Used for melting armoured opponents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/facid/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("facid", 280)
	B1.reagents.add_reagent("potassium", 20)
	B2.reagents.add_reagent("phosphorus", 20)
	B2.reagents.add_reagent("sugar", 20)
	B2.reagents.add_reagent("facid", 260)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/weapon/grenade/chem_grenade/saringas
	payload_name = "saringas"
	desc = "Contains sarin gas; extremely deadly and fast acting; use with extreme caution."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

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