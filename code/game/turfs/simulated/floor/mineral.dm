/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 */

/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons = list()

/turf/simulated/floor/mineral/New()
	..()
	broken_states = list("[initial(icon_state)]_dam")

/turf/simulated/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if(!(icon_state in icons))
			icon_state = initial(icon_state)

//PLASMA
/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")

/turf/simulated/floor/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn()

/turf/simulated/floor/mineral/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma flooring was ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma flooring was ignited by [key_name(user)] in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/turf/simulated/floor/mineral/plasma/proc/PlasmaBurn()
	make_plating()
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 20)

/turf/simulated/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()

//GOLD
/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")

/turf/simulated/floor/mineral/gold/fancy
	icon_state = "goldfancy"
	floor_tile = /obj/item/stack/tile/mineral/gold/fancy
	icons = list("goldfancy","goldfancy_dam")

//SILVER
/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")

/turf/simulated/floor/mineral/silver/fancy
	icon_state = "silverfancy"
	floor_tile = /obj/item/stack/tile/mineral/silver/fancy
	icons = list("silverfancy","silverfancy_dam")

//BANANIUM
/turf/simulated/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")
	var/spam_flag = 0

/turf/simulated/floor/mineral/bananium/Entered(mob/living/M)
	.=..()
	if(!.)
		if(istype(M))
			squeek()

/turf/simulated/floor/mineral/bananium/attackby(obj/item/weapon/W, mob/user, params)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/attack_hand(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/turf/simulated/floor/mineral/bananium/proc/squeek()
	if(!spam_flag)
		spam_flag = 1
		playsound(src, "clownstep", 50, 1)
		spawn(10)
			spam_flag = 0

/turf/simulated/floor/mineral/bananium/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

//TRANQUILLITE
/turf/simulated/floor/mineral/tranquillite
	name = "silent floor"
	icon_state = "tranquillite"
	floor_tile = /obj/item/stack/tile/mineral/tranquillite
	shoe_running_volume = 0
	shoe_walking_volume = 0

//DIAMOND
/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")

//URANIUM
/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")
	var/last_event = 0
	var/active = null

/turf/simulated/floor/mineral/uranium/Entered(mob/AM)
	.=..()
	if(!.)
		if(istype(AM))
			radiate()

/turf/simulated/floor/mineral/uranium/attackby(obj/item/weapon/W, mob/user, params)
	.=..()
	if(!.)
		radiate()

/turf/simulated/floor/mineral/uranium/attack_hand(mob/user)
	.=..()
	if(!.)
		radiate()

/turf/simulated/floor/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(1,IRRADIATE,0)
			for(var/turf/simulated/floor/mineral/uranium/T in orange(1,src))
				T.radiate()
			last_event = world.time
			active = 0
			return

// ALIEN ALLOY
/turf/simulated/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")

/turf/simulated/floor/mineral/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/simulated/floor/mineral/break_tile()
	return //unbreakable

/turf/simulated/floor/mineral/abductor/burn_tile()
	return //unburnable

/turf/simulated/floor/mineral/abductor/make_plating()
	return ChangeTurf(/turf/simulated/floor/plating/abductor2)

/turf/simulated/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"

/turf/simulated/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/simulated/floor/plating/abductor2/burn_tile()
	return //unburnable