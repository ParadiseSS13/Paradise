/*
	Station Airlocks Regular
*/

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/Doorcom.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/Doorsec.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sec

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/Dooreng.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/Doormed.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/Doormaint.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/Doorresearch.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/Doorsci.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_science

//////////////////////////////////
/*
	Station Airlocks Glass
*/

/obj/machinery/door/airlock/glass_command
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_com
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	icon = 'icons/obj/doors/Doorengglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_eng
	glass = 1

/obj/machinery/door/airlock/glass_security
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_sec
	glass = 1

/obj/machinery/door/airlock/glass_medical
	icon = 'icons/obj/doors/Doormedglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_med
	glass = 1

/obj/machinery/door/airlock/glass_research
	icon = 'icons/obj/doors/Doorresearchglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_research
	glass = 1

/obj/machinery/door/airlock/glass_mining
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_min
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1

/obj/machinery/door/airlock/glass_science
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_science
	glass = 1

//////////////////////////////////
/*
	Station Airlocks Mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = "gold"

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = "silver"

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = "diamond"

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = "uranium"
	var/event_step = 20

/obj/machinery/door/airlock/uranium/New()
	..()
	addtimer(src, "radiate", event_step)

/obj/machinery/door/airlock/uranium/proc/radiate()
	if(prob(50))
		for(var/mob/living/L in range (3,src))
			L.apply_effect(15,IRRADIATE,0)
	addtimer(src, "radiate", event_step)

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	mineral = "plasma"

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 500)
	new/obj/structure/door_assembly(loc)
	qdel(src)

/obj/machinery/door/airlock/plasma/BlockSuperconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/bananium
	name = "bananium airlock"
	icon = 'icons/obj/doors/Doorbananium.dmi'
	mineral = "bananium"
	doorOpen = 'sound/items/bikehorn.ogg'
	doorClose = 'sound/items/bikehorn.ogg'

/obj/machinery/door/airlock/tranquillite
	name = "tranquillite airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	mineral = "tranquillite"
	doorOpen = null // it's silent!
	doorClose = null
	doorDeni = null
	boltUp = null
	boltDown = null

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = "sandstone"

//////////////////////////////////
/*
	Station2 Airlocks
*/

/obj/machinery/door/airlock/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	glass = 1
	doorOpen = 'sound/machines/windowdoor.ogg'
	doorClose = 'sound/machines/windowdoor.ogg'

//////////////////////////////////
/*
	External Airlocks
*/

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext
	doorOpen = 'sound/machines/airlock_ext_open.ogg'
	doorClose = 'sound/machines/airlock_ext_close.ogg'

//////////////////////////////////
/*
	CentCom Airlocks
*/

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_centcom

//////////////////////////////////
/*
	Vault Airlocks
*/

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/vault.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2

//////////////////////////////////
/*
	Hatch Airlocks
*/

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/hatch/gamma
	name = "gamma level hatch"
	hackProof = 1
	aiControlDisabled = 1
	unacidable = 1
	is_special = 1

/obj/machinery/door/airlock/maintenance_hatch
	name = "maintenance hatch"
	icon = 'icons/obj/doors/Doorhatchmaint2.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mhatch

//////////////////////////////////
/*
	High Security Airlocks
*/

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	explosion_block = 2

/obj/machinery/door/airlock/highsecurity/red
	name = "secure armory airlock"
	hackProof = 1
	aiControlDisabled = 1

//////////////////////////////////
/*
	Shuttle Airlocks
*/

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/doorshuttle.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_shuttle

//////////////////////////////////
/*
	Cult Airlocks
*/

/obj/machinery/door/airlock/cult
	name = "cult airlock"
	icon = 'icons/obj/doors/doorcult.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult
	hackProof = 1
	aiControlDisabled = 1
	var/friendly = FALSE

/obj/machinery/door/airlock/cult/New()
	..()

/obj/machinery/door/airlock/cult/canAIControl(mob/user)
	return (iscultist(user))

/obj/machinery/door/airlock/cult/allowed(mob/M)
	if(!density)
		return 1
	if(friendly || \
			iscultist(M) || \
			istype(M, /mob/living/simple_animal/shade) || \
			istype(M, /mob/living/simple_animal/construct))
		return 1
	else
		var/atom/throwtarget
		throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(M, src)))
		M << pick(sound('sound/hallucinations/turn_around1.ogg',0,1,50), sound('sound/hallucinations/turn_around2.ogg',0,1,50))
		M.Weaken(2)
		spawn(0)
			M.throw_at(throwtarget, 5, 1,src)
		return 0

/obj/machinery/door/airlock/cult/narsie_act()
	return

/obj/machinery/door/airlock/cult/friendly
	friendly = TRUE

//////////////////////////////////
/*
	Misc Airlocks
*/

//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	width = 2

/obj/machinery/door/airlock/multi_tile/glass
	name = "large glass airlock"
	icon = 'icons/obj/doors/Door2x1glass.dmi'
	opacity = 0
	glass = 1
	assemblytype = "obj/structure/door_assembly/multi_tile"
