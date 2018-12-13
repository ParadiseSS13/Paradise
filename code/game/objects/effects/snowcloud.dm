/obj/effect/snowcloud
	name = "snow cloud"
	desc = "Let it snow, let it snow, let it snow!"
	icon_state = "snowcloud"
	layer = FLY_LAYER
	anchored = TRUE
	var/obj/machinery/snow_machine/parent_machine

/obj/effect/snowcloud/New(turf, obj/machinery/snow_machine/SM)
	..()
	processing_objects.Add(src)
	if(SM && istype(SM))
		parent_machine = SM

/obj/effect/snowcloud/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/effect/snowcloud/process()
	if(QDELETED(parent_machine))
		parent_machine = null
	var/turf/T = get_turf(src)
	if(!issimulatedturf(T) || T.density)
		qdel(src)
		return
	var/turf/simulated/S = T
	var/turf_hotness = S.air.temperature
	if(turf_hotness > T0C && prob(10 * (turf_hotness - T0C))) //Cloud disappears if it's too warm
		qdel(src)
		return
	if(!parent_machine || !parent_machine.active || parent_machine.stat & NOPOWER) //All reasons a cloud could dissipate
		to_chat(world, "cloud not powered")
		if(prob(10))
			qdel(src)
		return
	try_to_snow()
	try_to_spread_cloud()
	parent_machine.affect_turf_temperature(S, 0.25 * parent_machine.cooling_speed)

/obj/effect/snowcloud/proc/try_to_snow()
	var/turf/T = get_turf(src)
	if(!issimulatedturf(T))
		return
	var/turf/simulated/S = T
	if(locate(/obj/effect/snow, S))
		return
	if(prob(25 + T0C - S.air.temperature)) //Colder turf = more chance of snow
		new /obj/effect/snow(T)

/obj/effect/snowcloud/proc/try_to_spread_cloud()
	if(prob(90))
		return
	var/list/random_dirs = shuffle(cardinal)
	for(var/potential in random_dirs)
		var/turf/T = get_turf(get_step(src, potential))
		if(!issimulatedturf(T) || T.density)
			continue
		if(parent_machine.make_snowcloud(T))
			return


//Snow stuff below

/obj/effect/snow
	desc = "Perfect for making snow angels, or throwing at other people!"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	layer = ABOVE_ICYOVERLAY_LAYER
	anchored = TRUE

/obj/effect/snow/New()
	processing_objects.Add(src)
	var/image/north_border = new('icons/turf/snow.dmi', null, "snow_corner", layer, NORTH)
	var/image/east_border = new('icons/turf/snow.dmi', null, "snow_corner", layer, EAST)
	var/image/south_border = new('icons/turf/snow.dmi', null, "snow_corner", layer, SOUTH)
	var/image/west_border = new('icons/turf/snow.dmi', null, "snow_corner", layer, WEST)
	north_border.pixel_y -= 32
	east_border.pixel_x -= 32
	south_border.pixel_y += 32
	west_border.pixel_x += 32
	add_overlay(north_border)
	add_overlay(east_border)
	add_overlay(south_border)
	add_overlay(west_border)
	..()

/obj/effect/snow/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/effect/snow/proc/melt()
	var/turf/simulated/T = get_turf(src)
	T.MakeSlippery() //Yes it'll runtime if it spawns on an unsimulated turf. But that shouldn't happen as the only way to spawn this is to have a snowcloud, and that can only spawn on simulated turfs
	qdel(src)


/obj/effect/snow/process()
	var/turf/T = get_turf(src)
	if(!issimulatedturf(T) || T.density)
		qdel(src)
		return
	var/turf/simulated/S = T
	if(S.air.temperature > T0C)
		if(prob(10 + S.air.temperature - T0C))
			melt()

/obj/effect/snow/attack_hand(mob/living/carbon/human/user)
	if(!istype(user)) //Nonhumans don't have the balls to fight in the snow
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/snowball/SB = new(get_turf(user))
	user.put_in_hands(SB)
	to_chat(user, "<span class='notice'>You scoop up some snow and make \a [SB]!</span>")

/obj/effect/snow/fire_act()
	melt()

/obj/effect/snow/ex_act(severity)
	if(severity == 3 && prob(50))
		return
	melt()

/obj/item/snowball
	name = "snowball"
	desc = "Get ready for a snowball fight!"
	force = 0
	throwforce = 2
	icon_state = "snowball"

/obj/item/snowball/throw_impact(atom/target)
	..()
	qdel(src)

/obj/item/snowball/fire_act()
	qdel(src)

/obj/item/snowball/ex_act(severity)
	qdel(src)
