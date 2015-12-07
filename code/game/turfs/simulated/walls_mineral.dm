/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null

/turf/simulated/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"
	explosion_block = 0 //gold is a soft metal you dingus.
	//var/electro = 1
	//var/shocked = null

/turf/simulated/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"
	//var/electro = 0.75
	//var/shocked = null

/turf/simulated/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"
	explosion_block = 3

/turf/simulated/wall/mineral/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = "clown0"
	walltype = "clown"
	mineral = "clown"

/turf/simulated/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"
	explosion_block = 0

/turf/simulated/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"

/turf/simulated/wall/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/simulated/wall/mineral/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/Bumped(AM as mob|obj)
	radiate()
	..()

/turf/simulated/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = "plasma0"
	walltype = "plasma"
	mineral = "plasma"
	thermal_conductivity = 0.04

/turf/simulated/wall/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma wall ignited by [key_name_admin(user)] in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma wall ignited by [key_name(user)] in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/turf/simulated/wall/mineral/plasma/proc/PlasmaBurn(temperature)
	spawn(2)
	new /obj/structure/girder(src)
	src.ChangeTurf(/turf/simulated/floor)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)

/turf/simulated/wall/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/*
/turf/simulated/wall/mineral/proc/shock()
	if (electrocute_mob(user, C, src))
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

/turf/simulated/wall/mineral/proc/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if((mineral == "gold") || (mineral == "silver"))
		if(shocked)
			shock()
*/

/turf/simulated/wall/mineral/alien
	name = "alien wall"
	desc = "An strange-looking alien wall."
	icon_state = "plasma0"
	walltype = "plasma"
	mineral = "plasma"
