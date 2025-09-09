/*
	MARK: Station Airlocks Regular
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

/obj/machinery/door/airlock/virology
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_viro

//////////////////////////////////
/*
	MARK: Station Airlocks Glass
*/

/obj/machinery/door/airlock/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/command/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/engineering/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/security/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/medical/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/virology/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/research/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mining/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/atmos/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/science/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/maintenance/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/maintenance/external/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 200

//////////////////////////////////
/*
	MARK: Station Airlocks Mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_gold
	paintable = FALSE

/obj/machinery/door/airlock/gold/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_silver
	paintable = FALSE

/obj/machinery/door/airlock/silver/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_diamond
	normal_integrity = 1000
	explosion_block = 2
	paintable = FALSE

/obj/machinery/door/airlock/diamond/glass
	normal_integrity = 950
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_uranium
	paintable = FALSE
	var/last_event = 0

/obj/machinery/door/airlock/uranium/Initialize(mapload)
	. = ..()
	var/datum/component/inherent_radioactivity/radioactivity = AddComponent(/datum/component/inherent_radioactivity, 150, 0, 0, 1.5)
	START_PROCESSING(SSradiation, radioactivity)


/obj/machinery/door/airlock/uranium/attack_hand(mob/user)
	. = ..()

/obj/machinery/door/airlock/uranium/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_plasma
	paintable = FALSE

/obj/machinery/door/airlock/plasma/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 500)
	var/obj/structure/door_assembly/DA
	DA = new /obj/structure/door_assembly(loc)
	if(glass)
		DA.glass = TRUE
	DA.update_appearance(UPDATE_NAME|UPDATE_ICON)
	qdel(src)

/obj/machinery/door/airlock/plasma/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(used.get_heat() > 300)
		message_admins("Plasma airlock ignited by [key_name_admin(user)] in ([x],[y],[z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		log_game("Plasma airlock ignited by [key_name(user)] in ([x],[y],[z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]",INVESTIGATE_ATMOS)
		ignite(used.get_heat())
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/door/airlock/plasma/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/bananium
	name = "bananium airlock"
	desc = "Honkhonkhonk!"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_bananium
	doorOpen = 'sound/items/bikehorn.ogg'
	doorClose = 'sound/items/bikehorn.ogg'
	paintable = FALSE

/obj/machinery/door/airlock/bananium/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/tranquillite
	name = "tranquillite airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_tranquillite
	doorOpen = null // it's silent!
	doorClose = null
	doorDeni = null
	boltUp = null
	boltDown = null
	paintable = FALSE

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sandstone
	paintable = FALSE

/obj/machinery/door/airlock/sandstone/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/wood
	name = "wooden airlock"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_wood
	paintable = FALSE

/obj/machinery/door/airlock/wood/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/titanium
	name = "shuttle airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_titanium
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	normal_integrity = 400
	paintable = FALSE

/obj/machinery/door/airlock/titanium/glass
	normal_integrity = 350
	opacity = FALSE
	glass = TRUE

//////////////////////////////////
/*
	MARK: Station2 Airlocks
*/

/obj/machinery/door/airlock/public
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_public

/obj/machinery/door/airlock/public/glass
	opacity = FALSE
	glass = TRUE

//////////////////////////////////
/*
	MARK: External Airlocks
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
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/external_no_weld
	name = "external airlock"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext
	doorOpen = 'sound/machines/airlock_ext_open.ogg'
	doorClose = 'sound/machines/airlock_ext_close.ogg'

/obj/machinery/door/airlock/external_no_weld/welder_act(mob/user, obj/item/I)
	return

//////////////////////////////////
/*
	MARK: CentCom Airlocks
*/

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	explosion_block = 2
	assemblytype = /obj/structure/door_assembly/door_assembly_centcom
	normal_integrity = 1000
	security_level = 6

/obj/machinery/door/airlock/centcom/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/centcom/glass/Initialize(mapload)
	. = ..()
	update_icon()

//////////////////////////////////
/*
	MARK: Vault Airlocks
*/

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2
	normal_integrity = 400 // reverse engieneerd: 400 * 1.5 (sec lvl 6) = 600 = original
	security_level = 6
	paintable = FALSE

//////////////////////////////////
/*
	MARK: Hatch Airlocks
*/

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_hatch
	paintable = FALSE

/obj/machinery/door/airlock/hatch/syndicate
	name = "syndicate hatch"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/door/airlock/hatch/syndicate/command
	name = "Command Center"
	req_access = list(ACCESS_SYNDICATE_COMMAND)
	explosion_block = 2
	normal_integrity = 1000
	security_level = 6

/obj/machinery/door/airlock/hatch/syndicate/command/emag_act(mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this door are far too advanced for your primitive hacking peripherals.</span>")
	return

/// This door is used in the malf AI telecomms ruin. This door starts early access, and will try to crush someone to death who enters it's turf like how an AI door crushes.
/obj/machinery/door/airlock/hatch/syndicate/command/trapped
	emergency = TRUE
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON
	safe = FALSE
	normal_integrity = 100 // going to get boosted by security level anyway

/obj/machinery/door/airlock/hatch/syndicate/command/trapped/process()
	if(locate(/mob/living) in get_turf(src))
		unlock(TRUE)
		if(density)
			open()
		else
			close()

/obj/machinery/door/airlock/hatch/syndicate/vault
	name = "syndicate vault hatch"
	req_access = list(ACCESS_SYNDICATE)
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	security_level = 6
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON

/obj/machinery/door/airlock/maintenance_hatch
	name = "maintenance hatch"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mhatch
	paintable = FALSE

//////////////////////////////////
/*
	MARK: High Security Airlocks
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
	paintable = FALSE

/obj/machinery/door/airlock/highsecurity/red
	name = "secure armory airlock"
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON

/obj/machinery/door/airlock/highsecurity/red/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_update))

/obj/machinery/door/airlock/highsecurity/red/proc/on_security_level_update(datum/source, previous_level_number, new_level_number)
	SIGNAL_HANDLER

	if(new_level_number >= SEC_LEVEL_RED)
		unlock(TRUE)
	else
		lock(TRUE)

/obj/machinery/door/airlock/highsecurity/red/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!issilicon(user))
		if(isElectrified())
			if(shock(user, 75))
				return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/detective_scanner))
		return ITEM_INTERACT_COMPLETE

	add_fingerprint(user)

	return ..()

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
	aiControlDisabled = AICONTROLDISABLED_ON
	normal_integrity = 700
	security_level = 1
	paintable = FALSE

// MARK: Clockwork Airlocks

/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass."
	icon = 'icons/obj/doors/airlocks/clockwork/clockwork.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/clockwork-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_clockwork
	paintable = FALSE

/obj/machinery/door/airlock/clockwork/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/ratvar/door(loc)

/obj/machinery/door/airlock/clockwork/allowed(mob/living/L)
	if(..())
		new /obj/effect/temp_visual/ratvar/door(loc)
		return TRUE

/obj/machinery/door/airlock/clockwork/glass
	glass = TRUE
	opacity = FALSE

//////////////////////////////////
/*
	MARK: Cult Airlocks
*/

/obj/machinery/door/airlock/cult
	name = "cult airlock"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult
	damage_deflection = 20
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON
	paintable = FALSE
	/// Spawns an effect when opening
	var/openingoverlaytype = /obj/effect/temp_visual/cult/door
	/// Will the door let anyone through
	var/friendly = FALSE
	/// Is this door currently concealed
	var/stealthy = FALSE
	/// Door sprite when concealed
	var/stealth_icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	/// Door overlays when concealed (Bolt lights, maintenance panel, etc.)
	var/stealth_overlays = 'icons/obj/doors/airlocks/station/overlays.dmi'
	/// Is the concealed airlock glass
	var/stealth_glass = FALSE
	/// Opacity when concealed (For glass doors)
	var/stealth_opacity = TRUE
	/// Inner airlock material (Glass, plasteel)
	var/stealth_airlock_material = null

/obj/machinery/door/airlock/cult/Initialize(mapload)
	. = ..()
	icon = GET_CULT_DATA(airlock_runed_icon_file, initial(icon))
	overlays_file = GET_CULT_DATA(airlock_runed_overlays_file, initial(overlays_file))
	update_icon()
	new openingoverlaytype(loc)

/obj/machinery/door/airlock/cult/canAIControl(mob/user)
	return (IS_CULTIST(user) && !isAllPowerLoss())

/obj/machinery/door/airlock/cult/allowed(mob/living/L)
	if(!density)
		return TRUE
	if(friendly || IS_CULTIST(L) || isshade(L) || isconstruct(L))
		if(!stealthy)
			new openingoverlaytype(loc)
		return TRUE
	else
		if(!stealthy)
			new /obj/effect/temp_visual/cult/sac(loc)
			var/atom/throwtarget
			throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
			SEND_SOUND(L, pick(sound('sound/hallucinations/turn_around1.ogg', 0, 1, 50), sound('sound/hallucinations/turn_around2.ogg', 0, 1, 50)))
			L.KnockDown(4 SECONDS)
			L.throw_at(throwtarget, 5, 1)
		return FALSE

/obj/machinery/door/airlock/cult/screwdriver_act(mob/user, obj/item/I)
	return

/obj/machinery/door/airlock/cult/cult_conceal()
	icon = stealth_icon
	overlays_file = stealth_overlays
	set_opacity(stealth_opacity)
	glass = stealth_glass
	airlock_material = stealth_airlock_material
	name = "airlock"
	desc = "An airlock door keeping you safe from the vacuum of space. Only works if closed."
	stealthy = TRUE
	update_icon()

/obj/machinery/door/airlock/cult/cult_reveal()
	icon = GET_CULT_DATA(airlock_runed_icon_file, initial(icon))
	overlays_file = GET_CULT_DATA(airlock_runed_overlays_file, initial(overlays_file))
	set_opacity(initial(opacity))
	glass = initial(glass)
	airlock_material = initial(airlock_material)
	name = initial(name)
	desc = initial(desc)
	stealthy = initial(stealthy)
	update_icon()

/obj/machinery/door/airlock/cult/arePowerSystemsOn()
	return !(stat & BROKEN)

/obj/machinery/door/airlock/cult/narsie_act()
	return

/obj/machinery/door/airlock/cult/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult/glass/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/door/airlock/cult/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned
	openingoverlaytype = /obj/effect/temp_visual/cult/door/unruned

/obj/machinery/door/airlock/cult/unruned/Initialize(mapload)
	. = ..()
	icon = GET_CULT_DATA(airlock_unruned_icon_file, initial(icon))
	overlays_file = GET_CULT_DATA(airlock_unruned_overlays_file, initial(overlays_file))
	update_icon()

/obj/machinery/door/airlock/cult/unruned/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult/unruned/glass/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/door/airlock/cult/unruned/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/weak
	name = "brittle cult airlock"
	desc = "An airlock hastily corrupted by blood magic, it is unusually brittle in this state."
	normal_integrity = 150
	damage_deflection = 5
	armor = null

//////////////////////////////////
/*
	MARK: Misc Airlocks
*/

//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	name = "large airlock"
	width = 2
	icon = 'icons/obj/doors/airlocks/glass_large/glass_large.dmi'
	overlays_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/multi_tile
	paintable = FALSE

/obj/machinery/door/airlock/multi_tile/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	update_bounds()

/obj/machinery/door/airlock/multi_tile/narsie_act()
	return

/obj/machinery/door/airlock/multi_tile/glass
	opacity = FALSE
	glass = TRUE

/// Player view blocking fillers for multi-tile doors
/obj/airlock_filler_object
	name = "airlock fluff"
	desc = "You shouldn't be able to see this fluff!"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The door/airlock this fluff panel is attached to
	var/obj/machinery/door/filled_airlock

/obj/airlock_filler_object/Destroy()
	filled_airlock = null
	return ..()

/// Multi-tile airlocks pair with a filler panel, if one goes so does the other.
/obj/airlock_filler_object/proc/pair_airlock(obj/machinery/door/parent_airlock)
	if(isnull(parent_airlock))
		stack_trace("Attempted to pair an airlock filler with no parent airlock specified!")

	filled_airlock = parent_airlock
	RegisterSignal(filled_airlock, COMSIG_PARENT_QDELETING, PROC_REF(no_airlock))

/obj/airlock_filler_object/proc/no_airlock()
	UnregisterSignal(filled_airlock)
	qdel(src)

/// They only block our visuals, not movement
/obj/airlock_filler_object/CanPass(atom/movable/mover, border_dir)
	return TRUE

/obj/airlock_filler_object/singularity_act()
	return

/obj/airlock_filler_object/singularity_pull(S, current_size)
	return
