/****************Mining Charges****************/
/obj/item/grenade/plastic/miningcharge
	name = "industrial mining charge"
	desc = "Used to make big holes in rocks. Only works on rocks!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining-charge-2"
	det_time = 5
	var/smoke_amount = 3
	var/boom_sizes = list(1,3,5)

/obj/item/grenade/plastic/miningcharge/Initialize()
	. = ..()
	image_overlay = mutable_appearance(icon, "[icon_state]_active", ON_EDGED_TURF_LAYER)

/obj/item/grenade/plastic/miningcharge/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)

/obj/item/grenade/plastic/miningcharge/afterattack(atom/movable/AM, mob/user, flag)
	if(ismineralturf(AM))
		if(isancientturf(AM))
			visible_message("<span class='notice'>This rock appears to be resistant to all mining tools except pickaxes!</span>")
			return
		..()
	else
		to_chat(user,span_warning("The charge only works on rocks!"))

/obj/item/grenade/plastic/miningcharge/prime()
	var/turf/simulated/mineral/location = get_turf(target)
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(smoke_amount,0,location,null)
	S.start()
	//location.attempt_drill(null,TRUE,3) //orange says it doesnt include the actual middle
	for(var/turf/simulated/mineral/rock in circlerangeturfs(location, boom_sizes[3]))
		var/distance = get_dist_euclidian(location,rock)
		if(distance <= boom_sizes[1])
			rock.attempt_drill(null,TRUE,3)
		else if (distance <= boom_sizes[2])
			rock.attempt_drill(null,TRUE,2)
		else if (distance <= boom_sizes[3])
			rock.attempt_drill(null,TRUE,1)

	for(var/mob/living/carbon/C in circlerange(location,boom_sizes[3]))
		if(ishuman(C)) //working on everyone
			var/distance = get_dist_euclidian(location,C)
			C.flash_eyes()
			C.Weaken((boom_sizes[2] - distance) * 1 SECONDS) //1 second for how close you are to center if you're in range
			C.AdjustDeaf(0, (boom_sizes[3] - distance) * 10 SECONDS) // i dont know what am i doing
			to_chat(C, span_warning("<font size='2'><b>You are knocked down by the power of the mining charge!</font></b>"))
	qdel(src)

/obj/item/grenade/plastic/miningcharge/deconstruct(disassembled = TRUE) //no gibbing a miner with pda bombs
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/plastic/miningcharge/lesser
	name = "mining charge"
	desc = "A mining charge. This one seems less powerful than industrial. Only works on rocks!"
	icon_state = "mining-charge-1"
	smoke_amount = 1
	boom_sizes = list(1,2,3)

/obj/item/grenade/plastic/miningcharge/mega
	name = "experimental mining charge"
	desc = "A mining charge. This one seems much more powerful than normal!"
	icon_state = "mining-charge-3"
	smoke_amount = 5
	boom_sizes = list(2,5,7) //5 ticks of stun, if in center

/obj/item/storage/backpack/duffel/miningcharges/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/plastic/miningcharge/lesser(src)
	for(var/i in 1 to 2)
		new /obj/item/grenade/plastic/miningcharge(src)



