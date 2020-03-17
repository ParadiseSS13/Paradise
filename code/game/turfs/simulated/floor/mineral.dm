/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 * Shuttle floor (Titanium)
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
	..()
	if(exposed_temperature > 300)
		PlasmaBurn()

/turf/simulated/floor/mineral/plasma/attackby(obj/item/W, mob/user, params)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma flooring was ignited by [key_name_admin(user)]([ADMIN_QUE(user,"?")]) ([ADMIN_FLW(user,"FLW")]) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma flooring was <b>ignited by [key_name(user)] in ([x],[y],[z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]","atmos")
		ignite(is_hot(W))
		return
	..()

/turf/simulated/floor/mineral/plasma/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		user.visible_message("<span class='danger'>[user] sets [src] on fire!</span>",\
						"<span class='danger'>[src] disintegrates into a cloud of plasma!</span>",\
						"<span class='warning'>You hear a 'whoompf' and a roar.</span>")
		ignite(2500) //Big enough to ignite
		message_admins("Plasma wall ignited by [key_name_admin(user)] in ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma wall ignited by [key_name(user)] in ([x], [y], [z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]","atmos")

/turf/simulated/floor/mineral/plasma/proc/PlasmaBurn()
	make_plating()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 20)

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

//TITANIUM (shuttle)

/turf/simulated/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium
	broken_states = list("titanium_dam1","titanium_dam2","titanium_dam3","titanium_dam4","titanium_dam5")

/turf/simulated/floor/mineral/titanium/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/mineral/titanium/blue
	icon_state = "titanium_blue"

/turf/simulated/floor/mineral/titanium/blue/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/mineral/titanium/yellow
	icon_state = "titanium_yellow"

/turf/simulated/floor/mineral/titanium/yellow/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/mineral/titanium/purple
	icon_state = "titanium_purple"
	floor_tile = /obj/item/stack/tile/mineral/titanium/purple

/turf/simulated/floor/mineral/titanium/purple/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

//PLASTITANIUM (syndieshuttle)
/turf/simulated/floor/mineral/plastitanium
	name = "shuttle floor"
	icon_state = "plastitanium"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium
	broken_states = list("plastitanium_dam1","plastitanium_dam2","plastitanium_dam3","plastitanium_dam4","plastitanium_dam5")

/turf/simulated/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"

/turf/simulated/floor/mineral/plastitanium/red/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/mineral/plastitanium/red/brig
	name = "brig floor"

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

/turf/simulated/floor/mineral/bananium/attackby(obj/item/W, mob/user, params)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/attack_hand(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/proc/honk()
	if(spam_flag < world.time)
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spam_flag = world.time + 20

/turf/simulated/floor/mineral/bananium/proc/squeek()
	if(spam_flag < world.time)
		playsound(src, "clownstep", 50, 1)
		spam_flag = world.time + 10

/turf/simulated/floor/mineral/bananium/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB


/turf/simulated/floor/mineral/bananium/lubed/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_LUBE, TRUE)

/turf/simulated/floor/mineral/bananium/lubed/pry_tile(obj/item/C, mob/user, silent = FALSE) //I want to get off Mr Honk's Wild Ride
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, "<span class='warning'>You lose your footing trying to pry off the tile!</span>")
		H.slip("the floor", 0, 5, tilesSlipped = 4, walkSafely = 0, slipAny = 1)
	return

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

/turf/simulated/floor/mineral/uranium/attackby(obj/item/W, mob/user, params)
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

/turf/simulated/floor/mineral/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/simulated/floor/mineral/abductor/break_tile()
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
