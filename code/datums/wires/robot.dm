/datum/wires/robot
	randomize = TRUE
	holder_type = /mob/living/silicon/robot
	wire_count = 5
	window_x = 340
	window_y = 106
	proper_name = "Cyborg"

/datum/wires/robot/New(atom/_holder)
	wires = list(WIRE_AI_CONTROL, WIRE_BORG_CAMERA, WIRE_BORG_LAWCHECK, WIRE_BORG_LOCKED)
	return ..()

/datum/wires/robot/get_status()
	. = ..()
	var/mob/living/silicon/robot/R = holder
	. += "The LawSync light is [R.lawupdate ? "on" : "off"]."
	. += "The AI link light is [R.connected_ai ? "on" : "off"]."
	. += "The Camera light is [(R.camera && R.camera.status == 1) ? "on" : "off"]."
	. += "The lockdown light is [R.lockcharge ? "on" : "off"]."

/datum/wires/robot/on_cut(wire, mend)
	var/mob/living/silicon/robot/R = holder
	switch(wire)
		if(WIRE_BORG_LAWCHECK) //Cut the law wire, and the borg will no longer receive law updates from its AI
			if(!mend)
				if(!R.deployed) //AI shells must always have the same laws as the AI
					R.lawupdate = FALSE

				if(R.lawupdate)
					to_chat(R, "LawSync protocol engaged.")
					R.lawsync()
					R.show_laws()
			else
				if(!R.lawupdate && !R.emagged)
					R.lawupdate = TRUE

		if(WIRE_AI_CONTROL) //Cut the AI wire to reset AI control
			if(!mend)
				if(R.connected_ai)
					R.notify_ai(DISCONNECT)
					if(R.shell)
						R.undeploy() //Forced disconnect of an AI should this body be a shell.
					R.connected_ai = null

		if(WIRE_BORG_CAMERA)
			if(!isnull(R.camera) && !R.scrambledcodes)
				R.camera.status = mend
				R.camera.toggle_cam(usr, 0) // Will kick anyone who is watching the Cyborg's camera.

		if(WIRE_BORG_LOCKED)
			R.SetLockdown(!mend)
	..()


/datum/wires/robot/on_pulse(wire)
	var/mob/living/silicon/robot/R = holder
	switch(wire)
		if(WIRE_AI_CONTROL) //pulse the AI wire to make the borg reselect an AI
			if(!R.emagged)
				var/new_ai
				new_ai = select_active_ai(R)
				R.notify_ai(DISCONNECT)
				if(new_ai && (new_ai != R.connected_ai))
					R.connected_ai = new_ai
					if(R.shell)
						R.undeploy() //If this borg is an AI shell, disconnect the controlling AI and assign ti to a new AI
						R.notify_ai(AI_SHELL)
				else
					R.notify_ai(NEW_BORG)

		if(WIRE_BORG_CAMERA)
			if(!isnull(R.camera) && R.camera.can_use() && !R.scrambledcodes)
				R.camera.toggle_cam(usr, 0) // Kick anyone watching the Cyborg's camera, doesn't display you disconnecting the camera.
				R.visible_message("[R]'s camera lense focuses loudly.")
				to_chat(R, "Your camera lense focuses loudly.")

		if(WIRE_BORG_LOCKED)
			R.SetLockdown(!R.lockcharge) // Toggle
	..()

/datum/wires/robot/interactable(mob/user)
	var/mob/living/silicon/robot/R = holder
	if(R.wiresexposed)
		return TRUE
	return FALSE
