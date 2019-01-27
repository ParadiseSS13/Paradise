/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null
	canSmoothWith = null
	smooth = SMOOTH_TRUE

/turf/simulated/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	explosion_block = 0 //gold is a soft metal you dingus.
	canSmoothWith = list(/turf/simulated/wall/mineral/gold, /obj/structure/falsewall/gold)

/turf/simulated/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	canSmoothWith = list(/turf/simulated/wall/mineral/silver, /obj/structure/falsewall/silver)

/turf/simulated/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond"
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	explosion_block = 3
	canSmoothWith = list(/turf/simulated/wall/mineral/diamond, /obj/structure/falsewall/diamond)

/turf/simulated/wall/mineral/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium"
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	canSmoothWith = list(/turf/simulated/wall/mineral/bananium, /obj/structure/falsewall/bananium)

/turf/simulated/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	explosion_block = 0
	canSmoothWith = list(/turf/simulated/wall/mineral/sandstone, /obj/structure/falsewall/sandstone)

/turf/simulated/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	canSmoothWith = list(/turf/simulated/wall/mineral/uranium, /obj/structure/falsewall/uranium)

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

/turf/simulated/wall/mineral/uranium/attackby(obj/item/W as obj, mob/user as mob, params)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/Bumped(AM as mob|obj)
	radiate()
	..()

/turf/simulated/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma"
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	thermal_conductivity = 0.04
	canSmoothWith = list(/turf/simulated/wall/mineral/plasma, /obj/structure/falsewall/plasma)

/turf/simulated/wall/mineral/plasma/attackby(obj/item/W as obj, mob/user as mob)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma wall ignited by [key_name_admin(user)] in ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma wall ignited by [key_name(user)] in ([x], [y], [z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]","atmos")
		ignite(is_hot(W))
		return
	..()

/turf/simulated/wall/mineral/plasma/proc/PlasmaBurn(temperature)
	new girder_type(src)
	ChangeTurf(/turf/simulated/floor)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)

/turf/simulated/wall/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage == 0)//lasertag guns and so on don't set off plasma anymore. can't use nodamage here because lasertag guns actually don't have it.
		return
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/turf/simulated/wall/mineral/alien
	name = "alien wall"
	desc = "A strange-looking alien wall."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma"
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	canSmoothWith = list(/turf/simulated/wall/mineral/alien, /obj/structure/falsewall/alien)

/turf/simulated/wall/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood"
	sheet_type = /obj/item/stack/sheet/wood
	hardness = 70
	explosion_block = 0
	canSmoothWith = list(/turf/simulated/wall/mineral/wood, /obj/structure/falsewall/wood)

/turf/simulated/wall/mineral/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron"
	sheet_type = /obj/item/stack/rods
	sheet_amount = 5
	canSmoothWith = list(/turf/simulated/wall/mineral/iron, /obj/structure/falsewall/iron)

/turf/simulated/wall/mineral/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor"
	smooth = SMOOTH_TRUE|SMOOTH_DIAGONAL
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	explosion_block = 3
	canSmoothWith = list(/turf/simulated/wall/mineral/abductor, /obj/structure/falsewall/abductor)

/////////////////////Titanium walls/////////////////////

/turf/simulated/wall/mineral/titanium //has to use this path due to how building walls works
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "map-shuttle"
	explosion_block = 3
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/simulated/wall/mineral/titanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock, /obj/structure/window/full/shuttle, /obj/structure/shuttle/engine/heater, /obj/structure/falsewall/titanium)

/turf/simulated/wall/mineral/titanium/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "map-shuttle_nd"

/turf/simulated/wall/mineral/titanium/nosmooth
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smooth = SMOOTH_FALSE

/turf/simulated/wall/mineral/titanium/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/simulated/wall/mineral/titanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/simulated/wall/mineral/titanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/turf/simulated/wall/mineral/titanium/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/simulated/wall/mineral/titanium/survival, /obj/machinery/door/airlock, /obj/structure/window/full, /obj/structure/window/full/reinforced, /obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/shuttle, /obj/structure/shuttle/engine)

/turf/simulated/wall/mineral/titanium/survival/nodiagonal
	smooth = SMOOTH_MORE

/turf/simulated/wall/mineral/titanium/survival/pod
	canSmoothWith = list(/turf/simulated/wall/mineral/titanium/survival, /obj/machinery/door/airlock/survival_pod)

//undeconstructable type for derelict
//these walls are undeconstructable/unthermitable
/turf/simulated/wall/mineral/titanium/nodecon
	name = "russian wall"
	desc = "Like regular titanium, but able to deflect capitalist aggressors."

/turf/simulated/wall/mineral/titanium/nodecon/tileblend
	fixed_underlay = list("icon"='icons/turf/floors.dmi', "icon_state"="darkredfull")

/turf/simulated/wall/mineral/titanium/nodecon/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "map-shuttle_nd"

/turf/simulated/wall/mineral/titanium/nodecon/nosmooth
	smooth = SMOOTH_FALSE
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"

//properties for derelict sub-type to prevent said deconstruction/thermiting
/turf/simulated/wall/mineral/titanium/nodecon/try_decon(obj/item/I, mob/user, params)
	return

/turf/simulated/wall/mineral/titanium/nodecon/thermitemelt(mob/user as mob, speed)
	return

/////////////////////Plastitanium walls/////////////////////

/turf/simulated/wall/mineral/plastitanium
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle"
	explosion_block = 4
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/simulated/wall/mineral/plastitanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock, /obj/structure/shuttle/engine, /obj/structure/falsewall/plastitanium)

/turf/simulated/wall/mineral/plastitanium/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "map-shuttle_nd"

/turf/simulated/wall/mineral/plastitanium/nosmooth
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smooth = SMOOTH_FALSE

/turf/simulated/wall/mineral/plastitanium/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)

//have to copypaste this code
/turf/simulated/wall/mineral/plastitanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/simulated/wall/mineral/plastitanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform