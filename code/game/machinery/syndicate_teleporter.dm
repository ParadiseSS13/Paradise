/obj/machinery/computer/camera_advanced/hit_run_teleporter
	name = "hit and run teleporter console"
	desc = "A syndicate teleporter \"inspired\" by the abductor's teleportation technology."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_syndi"
	icon_screen = "camera_syndi_screen"
	networks = list("SS13")
	circuit = /obj/item/circuitboard/syndi_teleporter
	var/datum/action/innate/teleport_in/syndi/tele_in_action = new
	var/obj/machinery/syndi_telepad/pad

/obj/machinery/computer/camera_advanced/hit_run_teleporter/Initialize(mapload)
	. = ..()
	link_pad()

/obj/machinery/computer/camera_advanced/hit_run_teleporter/CreateEye()
	..()
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/hit_run_teleporter/GrantActions(mob/living/carbon/user)
	..()

	if(tele_in_action)
		if(!pad)
			link_pad()
		tele_in_action.target = pad
		tele_in_action.Grant(user)
		actions += tele_in_action

/obj/machinery/computer/camera_advanced/hit_run_teleporter/proc/link_pad()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		pad = locate(/obj/machinery/syndi_telepad, get_step(src, dir))
		if(pad)
			tele_in_action.target = pad
			return

/obj/item/gps/internal/hit_run_teleporter
	icon_state = null
	gpstag = "Suspicious Bluespace Signal"
	desc = "This signal is snooping in the station's camera network, hide your passwords!"

/datum/action/innate/teleport_in/syndi
	name = "Send To"
	button_icon_state = "beam_down"

/datum/action/innate/teleport_in/syndi/Activate()
	if(!target || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/syndi_telepad/P = target

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		P.Teleport_In(get_turf(remote_eye), owner)

/obj/machinery/syndi_telepad
	name = "hit and run telepad"
	desc = "Used to teleport in and then quickly back out"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "syndi-pad-idle"
	idle_power_consumption = 10
	active_power_consumption = 50000 //If we take into account it teleporting you back too it will drain a regular power cell in like 5-8 uses but if you dont force the power on the apc its gonna last you only like 1-2 uses before the power turns off
	anchored = TRUE
	var/cooldown = 0
	var/cooldown_time = 3 MINUTES
	var/retrieve_timer = 45 SECONDS
	var/obj/item/gps/internal/gps_signal = /obj/item/gps/internal/hit_run_teleporter

/obj/machinery/syndi_telepad/Initialize(mapload)
	. = ..()
	gps_signal = new gps_signal(src)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/syndi_telepad(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 2)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/syndi_telepad/Destroy()
	QDEL_NULL(gps_signal)
	return ..()

/obj/machinery/syndi_telepad/update_icon_state()
	if(panel_open || (stat & NOPOWER))
		icon_state = "syndi-pad-o"
	else
		icon_state = "syndi-pad-idle"

/obj/machinery/syndi_telepad/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/syndi_telepad/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon(UPDATE_ICON_STATE)
		return TRUE

/obj/machinery/syndi_telepad/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(cooldown > world.time)
		to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
		return
	if(default_deconstruction_crowbar(user, I))
		return

/obj/machinery/syndi_telepad/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I))
		return TRUE

/obj/machinery/syndi_telepad/proc/Teleport_Out(mob/living/carbon/target)
	if(stat & (BROKEN|NOPOWER))
		return
	if(target.handcuffed && (target.buckled || target.pulledby))
		return
	flick("syndi-pad", src)
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(target), target.dir)
	do_sparks(10, 0, target.loc)
	target.forceMove(get_turf(src))
	do_sparks(10, 0, target.loc)
	use_power(active_power_consumption)

/obj/machinery/syndi_telepad/proc/Teleport_In(turf/T, mob/living/carbon/user)
	if((stat & (BROKEN|NOPOWER)) || !anchored)
		return
	if(cooldown > world.time)
		var/timeleft = cooldown - world.time
		to_chat(user, "<span class='notice'>The telepad is still charging, wait [round(timeleft/10)] seconds.</span>")
		return
	if(!locate(/mob/living) in src.loc)
		return
	cooldown = world.time + cooldown_time
	new/obj/effect/temp_visual/teleport_abductor/syndi(T)
	sleep(25)
	flick("syndy-pad", src)
	for(var/mob/living/target in src.loc)
		target.forceMove(T)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
		addtimer(CALLBACK(src, PROC_REF(Teleport_Out), target), retrieve_timer)
		use_power(active_power_consumption)

/obj/effect/temp_visual/teleport_abductor/syndi
	duration = 25

/obj/item/storage/box/syndie_kit/hit_run_teleporter
	name = "hit and run teleporter kit"

/obj/item/storage/box/syndie_kit/hit_run_teleporter/populate_contents()
	new /obj/item/beacon/syndicate/bomb/syndi_teleporter(src)
	new /obj/item/beacon/syndicate/bomb/syndi_telepad(src)
	new /obj/item/clothing/gloves/color/yellow(src)
