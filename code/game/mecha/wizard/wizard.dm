/obj/mecha/wizard/
	desc = "A giant construct clearly built by and for wizards."
	name = "Generic wizard mech"
	icon_state = "wizard"
	initial_icon = "wizard"
	starting_voice = /obj/item/mecha_modkit/voice/silent
	var/check_wizard = TRUE

	var/datum/action/innate/mecha/mech_eject/wizard/wiz_eject_action = new
	var/datum/action/innate/mecha/mech_toggle_internals/wizard/wiz_internals_action = new
	var/datum/action/innate/mecha/mech_toggle_lights/wizard/wiz_lights_action = new
	var/datum/action/innate/mecha/mech_view_stats/wizard/wiz_stats_action = new
	var/datum/action/innate/mecha/mech_toggle_thrusters/wizard/wiz_thrusters_action = new

/datum/action/innate/mecha/mech_eject/wizard
	name = "Eject From Construct"
	button_icon_state = "mech_eject_wizard"

/datum/action/innate/mecha/mech_toggle_internals/wizard
	button_icon_state = "mech_internals_off_wizard"

/datum/action/innate/mecha/mech_toggle_internals/wizard/Activate()
	..()
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]_wizard"
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_lights/wizard
	button_icon_state = "mech_lights_off_wizard"

/datum/action/innate/mecha/mech_toggle_lights/wizard/Activate()
	..()
	button_icon_state = "mech_lights_[chassis.lights ? "on" : "off"]_wizard"
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_thrusters/wizard
	button_icon_state = "mech_thrusters_off_wizard"

/datum/action/innate/mecha/mech_toggle_thrusters/wizard/Activate()
	..()
	button_icon_state = "mech_thrusters_[chassis.thrusters_active ? "on" : "off"]_wizard"
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_view_stats/wizard
	button_icon_state = "mech_view_stats_wizard"

/obj/mecha/wizard/GrantActions(mob/living/user, human_occupant = 0)
	wiz_eject_action.Grant(user, src)
	wiz_internals_action.Grant(user, src)
	wiz_lights_action.Grant(user, src)
	wiz_stats_action.Grant(user, src)
	wiz_thrusters_action.Grant(user, src)

/obj/mecha/wizard/RemoveActions(mob/living/user, human_occupant = 0)
	wiz_eject_action.Remove(user)
	wiz_internals_action.Remove(user)
	wiz_lights_action.Remove(user)
	wiz_stats_action.Remove(user)
	wiz_thrusters_action.Remove(user)

/obj/mecha/wizard/add_cell()
	cell = new /obj/item/stock_parts/cell/infinite/wizard(src)
	cell.charge = 30000
	cell.maxcharge = 30000

/obj/mecha/wizard/emp_act(severity)
	visible_message("<span class='danger'>[src] does not seem damaged by the EMP!</span>") //it's not tech it's magic FOOL

/obj/mecha/wizard/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.mind && !(H.mind in ticker.mode.wizards) && check_wizard)
		to_chat(H, "<span class='warning'>You attempt to enter [src], but you're stopped by a magical barrier!</span>")
		return FALSE
	..()

/obj/mecha/wizard/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mmi) || W.GetID() || istype(W, /obj/item/mecha_parts/mecha_tracking) || istype(W, /obj/item/mecha_modkit))
		return FALSE
	else if(iswelder(W))
		if(user.mind && user.mind in ticker.mode.wizards)
			to_chat(user, "<span class='notice'>This primitive tool isn't powerful enough to repair [src], unfortunately. \
				You don't think you have any way of repairing it right now, best wait until you're done wrecking this station.</span>")
			return FALSE
		else
			return attacked_by(W, user)
	else
		..()
