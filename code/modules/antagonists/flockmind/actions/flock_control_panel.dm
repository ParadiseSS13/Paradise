/datum/action/cooldown/flock/control_panel
	name = "Flock Control Panel"
	desc = "Open the Flock control panel."
	button_icon_state = "radio_stun"

/datum/action/cooldown/flock/control_panel/Activate(atom/target)
	. = ..()
	var/mob/camera/flock/ghost_bird = owner
	ghost_bird.flock.ui_interact(ghost_bird)
