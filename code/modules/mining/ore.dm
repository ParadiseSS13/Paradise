/obj/item/weapon/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into
	var/datum/geosample/geologic_data

/obj/item/weapon/ore/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(15) && refined_type)
			new refined_type(get_turf(src.loc))
			qdel(src)
		else if(W.isOn())
			to_chat(user, "<span class='info'>Not enough fuel to smelt [src].</span>")
	..()

/obj/item/weapon/ore/Crossed(AM as mob|obj)
	var/obj/item/weapon/storage/bag/ore/OB
	var/turf/simulated/floor/F = get_turf(src)
	if(loc != F)
		return ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		for(var/thing in H.get_body_slots())
			if(istype(thing, /obj/item/weapon/storage/bag/ore))
				OB = thing
				break
	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		for(var/thing in R.get_all_slots())
			if(istype(thing, /obj/item/weapon/storage/bag/ore))
				OB = thing
				break
	if(OB && istype(F, /turf/simulated/floor/plating/airless/asteroid))
		F.attackby(OB, AM)
	return ..()



/obj/item/weapon/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	points = 30
	refined_type = /obj/item/stack/sheet/mineral/uranium
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	points = 1
	refined_type = /obj/item/stack/sheet/metal
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	points = 1
	refined_type = /obj/item/stack/sheet/glass
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/glass/attack_self(mob/living/user as mob)
	to_chat(user, "<span class='notice'>You use the sand to make sandstone.</span>")
	var/sandAmt = 1
	for(var/obj/item/weapon/ore/glass/G in user.loc) // The sand on the floor
		sandAmt += 1
		qdel(G)
	while(sandAmt > 0)
		var/obj/item/stack/sheet/mineral/sandstone/SS = new /obj/item/stack/sheet/mineral/sandstone(user.loc)
		if(sandAmt >= SS.max_amount)
			SS.amount = SS.max_amount
		else
			SS.amount = sandAmt
			for(var/obj/item/stack/sheet/mineral/sandstone/SA in user.loc)
				if(SA != SS && SA.amount < SA.max_amount)
					SA.attackby(SS, user) //we try to transfer all old unfinished stacks to the new stack we created.
		sandAmt -= SS.max_amount
	qdel(src)
	return

/obj/item/weapon/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "plasmatech=2;materials=2"
	points = 15
	refined_type = /obj/item/stack/sheet/mineral/plasma
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/plasma/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding)
			to_chat(user, "<span class='warning'>You can't hit a high enough temperature to smelt [src] properly!</span>")
	else
		..()

/obj/item/weapon/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	points = 16
	refined_type = /obj/item/stack/sheet/mineral/silver
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	points = 18
	refined_type = /obj/item/stack/sheet/mineral/gold
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	points = 50
	refined_type = /obj/item/stack/sheet/mineral/diamond
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/bananium
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	points = 60
	refined_type = /obj/item/stack/sheet/mineral/bananium
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/tranquillite
	name = "tranquillite ore"
	icon_state = "Mime ore"
	origin_tech = "materials=4"
	points = 60
	refined_type = /obj/item/stack/sheet/mineral/tranquillite
	materials = list(MAT_TRANQUILLITE=MINERAL_MATERIAL_AMOUNT)

/obj/item/weapon/ore/slag
	name = "slag"
	desc = "Completely useless"
	icon_state = "slag"

/obj/item/weapon/twohanded/required/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = 4
	throw_range = 0
	anchored = 1 //Forces people to carry it by hand, no pulling!
	var/primed = 0
	var/det_time = 100
	var/quality = 1 //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"
	var/datum/wires/explosive/gibtonite/wires

/obj/item/weapon/twohanded/required/gibtonite/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/item/weapon/twohanded/required/gibtonite/attackby(obj/item/I, mob/user, params)
	if(!wires && istype(I, /obj/item/device/assembly/igniter))
		user.visible_message("[user] attaches [I] to [src].", "<span class='notice'>You attach [I] to [src].</span>")
		wires = new(src)
		attacher = key_name(user)
		qdel(I)
		overlays += "Gibtonite_igniter"
		return

	if(wires && !primed)
		if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler))
			wires.Interact(user)
			return

	if(istype(I, /obj/item/weapon/pickaxe) || istype(I, /obj/item/weapon/resonator) || I.force >= 10)
		GibtoniteReaction(user)
		return
	if(primed)
		if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner) || istype(I, /obj/item/device/multitool))
			primed = 0
			user.visible_message("The chain reaction was stopped! ...The ore's quality looks diminished.", "<span class='notice'>You stopped the chain reaction. ...The ore's quality looks diminished.</span>")
			icon_state = "Gibtonite ore"
			quality = 1
			return
	..()

/obj/item/weapon/twohanded/required/gibtonite/attack_self(user)
	if(wires)
		wires.Interact(user)
	else
		..()

/obj/item/weapon/twohanded/required/gibtonite/bullet_act(var/obj/item/projectile/P)
	GibtoniteReaction(P.firer)
	..()

/obj/item/weapon/twohanded/required/gibtonite/ex_act()
	GibtoniteReaction(null, 1)

/obj/item/weapon/twohanded/required/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/notify_admins = 0
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1

		if(notify_admins)
			if(triggered_by == 1)
				message_admins("An explosion has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else if(triggered_by == 2)
				message_admins("A signal has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>. Igniter attacher: [key_name_admin(attacher)]")
			else
				message_admins("[key_name_admin(user)] has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
		if(triggered_by == 1)
			log_game("An explosion has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		else if(triggered_by == 2)
			log_game("A signal has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z]). Igniter attacher: [key_name(attacher)].")
		else
			user.visible_message("<span class='warning'>[user] strikes \the [src], causing a chain reaction!</span>", "<span class='danger'>You strike \the [src], causing a chain reaction.</span>")
			log_game("[key_name(user)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		spawn(det_time)
		if(primed)
			if(quality == 3)
				explosion(src.loc,2,4,9,adminlog = notify_admins)
			if(quality == 2)
				explosion(src.loc,1,2,5,adminlog = notify_admins)
			if(quality == 1)
				explosion(src.loc,-1,1,3,adminlog = notify_admins)
			qdel(src)

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
	if(is_mining_level(src.z))
		score_oremined++ //When ore spawns, increment score.  Only include ore spawned on mining asteroid (No Clown Planet)

/obj/item/weapon/ore/ex_act()
	return

/obj/item/weapon/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()
