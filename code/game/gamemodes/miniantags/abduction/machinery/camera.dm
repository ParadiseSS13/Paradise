/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	var/team = 0
	networks = list("SS13","Abductor")
	off_action = new /datum/action/innate/camera_off/abductor //specific datum
	var/datum/action/innate/teleport_in/tele_in_action = new
	var/datum/action/innate/teleport_out/tele_out_action = new
	var/datum/action/innate/teleport_self/tele_self_action = new
	var/datum/action/innate/vest_mode_swap/vest_mode_action = new
	var/datum/action/innate/vest_disguise_swap/vest_disguise_action = new
	var/datum/action/innate/set_droppoint/set_droppoint_action = new
	var/obj/machinery/abductor/console/console

	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"

/obj/machinery/computer/camera_advanced/abductor/New()
	abductor_equipment.Add(src)
	..()

/obj/machinery/computer/camera_advanced/abductor/CreateEye()
	..()
	eyeobj.visible_icon = 1
	eyeobj.icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/abductor/GrantActions(mob/living/carbon/user)
	off_action.target = user
	off_action.Grant(user)

	jump_action.target = user
	jump_action.Grant(user)
	//TODO : add null checks
	tele_in_action.target = console.pad
	tele_in_action.Grant(user)

	tele_out_action.target = console
	tele_out_action.Grant(user)

	tele_self_action.target = console.pad
	tele_self_action.Grant(user)

	vest_mode_action.target = console
	vest_mode_action.Grant(user)

	vest_disguise_action.target = console
	vest_disguise_action.Grant(user)

	set_droppoint_action.target = console
	set_droppoint_action.Grant(user)

/obj/machinery/computer/camera_advanced/abductor/proc/IsAbductor(mob/living/carbon/human/H)
	return H.get_species() == "Abductor"

/obj/machinery/computer/camera_advanced/abductor/proc/IsScientist(mob/living/carbon/human/H)
	if(H.mind && H.mind.abductor)
		return H.mind.abductor.scientist

/obj/machinery/computer/camera_advanced/abductor/attack_hand(mob/user)
	if(!iscarbon(user) || !IsAbductor(user))
		return
	return ..()

/datum/action/innate/camera_off/abductor/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/abductor/origin = remote_eye.origin
	C.remote_view = 0
	origin.current_user = null
	origin.jump_action.Remove(C)
	origin.tele_in_action.Remove(C)
	origin.tele_out_action.Remove(C)
	origin.tele_self_action.Remove(C)
	origin.vest_mode_action.Remove(C)
	origin.vest_disguise_action.Remove(C)
	origin.set_droppoint_action.Remove(C)
	remote_eye.user = null
	if(C.client)
		C.client.perspective = MOB_PERSPECTIVE
		C.client.eye = src
		C.client.images -= remote_eye.user_image
		for(var/datum/camerachunk/chunk in remote_eye.visibleCameraChunks)
			C.client.images -= chunk.obscured
	C.remote_control = null
	C.unset_machine()
	src.Remove(C)


/datum/action/innate/teleport_in
	name = "Send To"
	button_icon_state = "beam_down"

/datum/action/innate/teleport_in/Activate()
	if(!target || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		P.PadToLoc(remote_eye.loc)

/datum/action/innate/teleport_out
	name = "Retrieve"
	button_icon_state = "beam_up"

/datum/action/innate/teleport_out/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target

	console.TeleporterRetrieve()

/datum/action/innate/teleport_self
	name = "Send Self"
	button_icon_state = "beam_down"

/datum/action/innate/teleport_self/Activate()
	if(!target || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		P.MobToLoc(remote_eye.loc,C)

/datum/action/innate/vest_mode_swap
	name = "Switch Vest Mode"
	button_icon_state = "vest_mode"

/datum/action/innate/vest_mode_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.FlipVest()


/datum/action/innate/vest_disguise_swap
	name = "Switch Vest Disguise"
	button_icon_state = "vest_disguise"

/datum/action/innate/vest_disguise_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.SelectDisguise(remote=1)

/datum/action/innate/set_droppoint
	name = "Set Experiment Release Point"
	button_icon_state = "set_drop"

/datum/action/innate/set_droppoint/Activate()
	if(!target || !iscarbon(owner))
		return

	var/mob/living/carbon/human/C = owner
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control

	var/obj/machinery/abductor/console/console = target
	console.SetDroppoint(remote_eye.loc,owner)
