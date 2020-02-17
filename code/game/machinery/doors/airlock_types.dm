/*
	Station Airlocks Regular
*/

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_com
	normal_integrity = 450

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sec
	normal_integrity = 450

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mai
	normal_integrity = 250

/obj/machinery/door/airlock/maintenance/external
	name = "external airlock access"
	icon = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_extmai

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_science

//////////////////////////////////
/*
	Station Airlocks Glass
*/

/obj/machinery/door/airlock/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/command/glass
	opacity = 0
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/engineering/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/security/glass
	opacity = 0
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/medical/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/research/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/mining/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/atmos/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/science/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/maintenance/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/maintenance/external/glass
	opacity = 0
	glass = TRUE
	normal_integrity = 200

//////////////////////////////////
/*
	Station Airlocks Mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_gold

/obj/machinery/door/airlock/gold/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_silver

/obj/machinery/door/airlock/silver/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_diamond
	normal_integrity = 1000
	explosion_block = 2

/obj/machinery/door/airlock/diamond/glass
	normal_integrity = 950
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_uranium
	var/event_step = 20

/obj/machinery/door/airlock/uranium/New()
	..()
	addtimer(CALLBACK(src, .proc/radiate), event_step)


/obj/machinery/door/airlock/uranium/proc/radiate()
	if(prob(50))
		for(var/mob/living/L in range (3,src))
			L.apply_effect(15,IRRADIATE,0)
	addtimer(CALLBACK(src, .proc/radiate), event_step)


/obj/machinery/door/airlock/uranium/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_plasma

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 500)
	var/obj/structure/door_assembly/DA
	DA = new /obj/structure/door_assembly(loc)
	if(glass)
		DA.glass = TRUE
	if(heat_proof)
		DA.heat_proof_finished = TRUE
	DA.update_icon()
	DA.update_name()
	qdel(src)

/obj/machinery/door/airlock/plasma/attackby(obj/C, mob/user, params)
	if(is_hot(C) > 300)
		message_admins("Plasma airlock ignited by [key_name_admin(user)] in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		log_game("Plasma airlock ignited by [key_name(user)] in ([x],[y],[z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]","atmos")
		ignite(is_hot(C))
	else
		return ..()

/obj/machinery/door/airlock/plasma/BlockSuperconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/plasma/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/bananium
	name = "bananium airlock"
	desc = "Honkhonkhonk"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_bananium
	doorOpen = 'sound/items/bikehorn.ogg'
	doorClose = 'sound/items/bikehorn.ogg'

/obj/machinery/door/airlock/bananium/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/tranquillite
	name = "tranquillite airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	doorOpen = null // it's silent!
	doorClose = null
	doorDeni = null
	boltUp = null
	boltDown = null

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sandstone

/obj/machinery/door/airlock/sandstone/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/wood
	name = "wooden airlock"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_wood

/obj/machinery/door/airlock/wood/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/titanium
	name = "shuttle airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_titanium
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	normal_integrity = 400

/obj/machinery/door/airlock/titanium/glass
	normal_integrity = 350
	opacity = 0
	glass = TRUE

//////////////////////////////////
/*
	Station2 Airlocks
*/

/obj/machinery/door/airlock/public
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_public

/obj/machinery/door/airlock/public/glass
	opacity = 0
	glass = TRUE

//////////////////////////////////
/*
	External Airlocks
*/

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext
	doorOpen = 'sound/machines/airlock_ext_open.ogg'
	doorClose = 'sound/machines/airlock_ext_close.ogg'

/obj/machinery/door/airlock/external/glass
	opacity = 0
	glass = TRUE

//////////////////////////////////
/*
	CentCom Airlocks
*/

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	opacity = 0
	explosion_block = 2
	assemblytype = /obj/structure/door_assembly/door_assembly_centcom
	normal_integrity = 1000
	security_level = 6

//////////////////////////////////
/*
	Vault Airlocks
*/

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2
	normal_integrity = 400 // reverse engieneerd: 400 * 1.5 (sec lvl 6) = 600 = original
	security_level = 6

//////////////////////////////////
/*
	Hatch Airlocks
*/

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/hatch/syndicate
	name = "syndicate hatch"
	req_access_txt = "150"

/obj/machinery/door/airlock/hatch/syndicate/command
	name = "Command Center"
	req_access_txt = "153"
	explosion_block = 2
	normal_integrity = 1000
	security_level = 6

/obj/machinery/door/airlock/hatch/syndicate/command/emag_act(mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this door are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/door/airlock/hatch/syndicate/vault
	name = "syndicate vault hatch"
	req_access_txt = "151"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	security_level = 6
	hackProof = TRUE
	aiControlDisabled = TRUE

/obj/machinery/door/airlock/hatch/gamma
	name = "gamma level hatch"
	hackProof = 1
	aiControlDisabled = 1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	is_special = 1

/obj/machinery/door/airlock/hatch/gamma/attackby(obj/C, mob/user, params)
	if(!issilicon(user))
		if(isElectrified())
			if(shock(user, 75))
				return
	if(istype(C, /obj/item/detective_scanner))
		return

	if(istype(C, /obj/item/grenade/plastic/c4))
		to_chat(user, "The hatch is coated with a product that prevents the shaped charge from sticking!")
		return

	if(istype(C, /obj/item/mecha_parts/mecha_equipment/rcd) || istype(C, /obj/item/rcd))
		to_chat(user, "The hatch is made of an advanced compound that cannot be deconstructed using an RCD.")
		return

	add_fingerprint(user)

/obj/machinery/door/airlock/hatch/gamma/welder_act(mob/user, obj/item/I)
	if(shock_user(user, 75))
		return
	if(operating || !density)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, amount = 0, volume = I.tool_volume))
		return
	welded = !welded
	visible_message("<span class='notice'>[user] [welded ? null : "un"]welds [src]!</span>",\
					"<span class='notice'>You [welded ? null : "un"]weld [src]!</span>",\
					"<span class='warning'>You hear welding.</span>")
	update_icon()

/obj/machinery/door/airlock/maintenance_hatch
	name = "maintenance hatch"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mhatch

//////////////////////////////////
/*
	High Security Airlocks
*/

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	explosion_block = 2
	normal_integrity = 500
	security_level = 1
	damage_deflection = 30

/obj/machinery/door/airlock/highsecurity/red
	name = "secure armory airlock"
	hackProof = 1
	aiControlDisabled = 1

/obj/machinery/door/airlock/highsecurity/red/attackby(obj/C, mob/user, params)
	if(!issilicon(user))
		if(isElectrified())
			if(shock(user, 75))
				return
	if(istype(C, /obj/item/detective_scanner))
		return

	add_fingerprint(user)


/obj/machinery/door/airlock/highsecurity/red/welder_act(mob/user, obj/item/I)
	if(shock_user(user, 75))
		return
	if(operating || !density)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	welded = !welded
	visible_message("<span class='notice'>[user] [welded ? null : "un"]welds [src]!</span>",\
					"<span class='notice'>You [welded ? null : "un"]weld [src]!</span>",\
					"<span class='warning'>You hear welding.</span>")
	update_icon()


//////////////////////////////////
/*
	Shuttle Airlocks
*/

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_shuttle

/obj/machinery/door/airlock/shuttle/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/abductor
	name = "alien airlock"
	desc = "With humanity's current technological level, it could take years to hack this advanced airlock... or maybe we should give a screwdriver a try?"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_abductor
	damage_deflection = 30
	explosion_block = 3
	hackProof = TRUE
	aiControlDisabled = 1
	normal_integrity = 700
	security_level = 1

//////////////////////////////////
/*
	Cult Airlocks
*/

/obj/machinery/door/airlock/cult
	name = "cult airlock"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult
	damage_deflection = 10
	hackProof = TRUE
	aiControlDisabled = TRUE
	var/openingoverlaytype = /obj/effect/temp_visual/cult/door
	var/friendly = FALSE

/obj/machinery/door/airlock/cult/Initialize()
	. = ..()
	icon = SSticker.cultdat?.airlock_runed_icon_file
	overlays_file = SSticker.cultdat?.airlock_runed_overlays_file
	update_icon()
	new openingoverlaytype(loc)

/obj/machinery/door/airlock/cult/canAIControl(mob/user)
	return (iscultist(user) && !isAllPowerLoss())

/obj/machinery/door/airlock/cult/allowed(mob/living/L)
	if(!density)
		return 1
	if(friendly || iscultist(L) || isshade(L)|| isconstruct(L))
		new openingoverlaytype(loc)
		return 1
	else
		new /obj/effect/temp_visual/cult/sac(loc)
		var/atom/throwtarget
		throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		L << pick(sound('sound/hallucinations/turn_around1.ogg',0,1,50), sound('sound/hallucinations/turn_around2.ogg',0,1,50))
		L.Weaken(2)
		spawn(0)
			L.throw_at(throwtarget, 5, 1,src)
		return 0

/obj/machinery/door/airlock/cult/narsie_act()
	return

/obj/machinery/door/airlock/cult/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/glass
	glass = TRUE
	opacity = 0

/obj/machinery/door/airlock/cult/glass/Initialize()
	. = ..()
	update_icon()

/obj/machinery/door/airlock/cult/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned
	openingoverlaytype = /obj/effect/temp_visual/cult/door/unruned

/obj/machinery/door/airlock/cult/unruned/Initialize()
	. = ..()
	icon = SSticker.cultdat?.airlock_unruned_icon_file
	overlays_file = SSticker.cultdat?.airlock_unruned_overlays_file
	update_icon()

/obj/machinery/door/airlock/cult/unruned/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned/glass
	glass = TRUE
	opacity = 0

/obj/machinery/door/airlock/cult/unruned/glass/Initialize()
	. = ..()
	update_icon()

/obj/machinery/door/airlock/cult/unruned/glass/friendly
	friendly = TRUE

//////////////////////////////////
/*
	Misc Airlocks
*/

//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	name = "large airlock"
	dir = EAST
	width = 2
	icon = 'icons/obj/doors/airlocks/glass_large/glass_large.dmi'
	overlays_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/multi_tile

/obj/machinery/door/airlock/multi_tile/narsie_act()
	return

/obj/machinery/door/airlock/multi_tile/glass
	opacity = 0
	glass = TRUE
