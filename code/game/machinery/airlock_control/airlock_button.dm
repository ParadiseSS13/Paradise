GLOBAL_LIST_EMPTY(all_airlock_access_buttons)

/obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "airlock access button"
	desc = "Controls an airlock controller, requesting the doors open on this side."
	layer = ON_EDGED_TURF_LAYER
	anchored = TRUE
	power_channel = PW_CHANNEL_ENVIRONMENT
	/// Id to be used by the controller to grab us on spawn
	var/autolink_id
	/// UID of the airlock controller that owns us
	var/tmp/controller_uid
	/// Command, whether this button cycles in or out. This is /tmp/ so mappers dont try and define it in a map. Its assigned at runtime.
	var/tmp/assigned_command

/obj/machinery/access_button/Initialize(mapload)
	. = ..()
	GLOB.all_airlock_access_buttons += src
	if(assigned_command)
		stack_trace("A mapper tried to set assigned_command to [assigned_command] on [type] at [x],[y],[z]. This should not be mapped in.")

/obj/machinery/access_button/Destroy()
	GLOB.all_airlock_access_buttons -= src
	return ..()

/obj/machinery/access_button/update_icon_state()
	if(has_power(power_channel))
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"

/obj/machinery/access_button/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	// Swiping ID on the access button
	if(istype(used, /obj/item/card/id) || istype(used, /obj/item/pda))
		attack_hand(user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/access_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/access_button/attack_hand(mob/user)
	add_fingerprint(user)

	var/obj/machinery/airlock_controller/C = locateUID(controller_uid)
	if(!C)
		to_chat(user, "<span class='warning'>Could not communicate with controller.</span>")
		return

	if(!C.has_power(C.power_channel))
		to_chat(user, "<span class='warning'>No response from controller, possibly offline.</span>")
		return

	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	C.handle_button(assigned_command)
	flick("access_button_cycle", src)

/obj/machinery/access_button/proc/setup(obj/machinery/airlock_controller/C, mode)
	controller_uid = C.UID()
	assigned_command = mode

BUTTON_HELPERS(/obj/machinery/access_button, 25, 7)
