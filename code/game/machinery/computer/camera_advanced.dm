/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	var/mob/camera/eye/abductor/eyeobj
	var/mob/living/carbon/human/current_user = null
	var/list/networks = list("SS13")
	var/datum/action/innate/camera_off/off_action = new
	var/datum/action/innate/camera_jump/jump_action = new
	var/list/actions = list()

/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new /mob/camera/eye/abductor(loc, name, src, current_user)
	give_eye_control(current_user)

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	if(jump_action)
		jump_action.target = user
		jump_action.Grant(user)
		actions += jump_action

/obj/machinery/computer/camera_advanced/proc/RemoveActions()
	if(!istype(current_user))
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(current_user)
	actions.Cut()

/obj/machinery/computer/camera_advanced/proc/remove_eye_control(mob/living/user)
	RemoveActions()
	eyeobj.release_control()
	current_user = null
	user.unset_machine()
	playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)

/obj/machinery/computer/camera_advanced/check_eye(mob/user)
	if((stat & (NOPOWER|BROKEN)) || (!Adjacent(user) && !user.has_unlimited_silicon_privilege) || !user.has_vision() || user.incapacitated())
		user.unset_machine()

/obj/machinery/computer/camera_advanced/Destroy()
	if(current_user)
		current_user.unset_machine()
	QDEL_NULL(eyeobj)
	QDEL_LIST_CONTENTS(actions)
	return ..()

/obj/machinery/computer/camera_advanced/on_unset_machine(mob/M)
	if(istype(M) && M == current_user)
		remove_eye_control(M)

/obj/machinery/computer/camera_advanced/attack_hand(mob/user)
	if(current_user)
		to_chat(user, "The console is already in use!")
		return
	if(!iscarbon(user))
		return
	if(..())
		return
	user.set_machine(src)
	current_user = user

	if(!eyeobj)
		CreateEye()
	else
		give_eye_control(user)
		eyeobj.setLoc(eyeobj.loc)

/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	eyeobj.give_control(user)
	GrantActions(user)

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/eye/abductor/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(target)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/eye/abductor/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for(var/obj/machinery/camera/cam in GLOB.cameranet.cameras)
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for(var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network&origin.networks
		if(tempnetwork.len)
			T[text("[][]", netcam.c_tag, (netcam.can_use() ? null : " (Deactivated)"))] = netcam


	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/camera = tgui_input_list(target, "Choose which camera you want to view", "Cameras", T)
	var/obj/machinery/camera/final = T[camera]
	playsound(origin, "terminal_type", 25, 0)
	if(final)
		playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
		remote_eye.setLoc(get_turf(final))
		C.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/noise)
		C.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!
	else
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)
