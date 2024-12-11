/* Nanotrasen Shuttles */
// This is actually don't work for now and only need for Drop Pod
/obj/machinery/computer/shuttle/nanotrasen
	name = "nanotrasen shuttle terminal"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_CENT_SPECOPS_COMMANDER)
	bubble_icon = "syndibot"
	circuit = /obj/item/circuitboard/shuttle/nanotrasen
	shuttleId = "nanotrasen"
	possible_destinations = "syndicate_away;syndicate_z5;syndicate_z3;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODECONSTRUCT

/obj/machinery/computer/shuttle/nanotrasen/recall
	name = "nanotrasen shuttle recall terminal"
	circuit = /obj/item/circuitboard/shuttle/nanotrasen/recall
	possible_destinations = "syndicate_away"

// Nanotrasen Drop Pod
/obj/machinery/computer/shuttle/nanotrasen/drop_pod
	name = "nanotrasen assault pod control"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "syndie_assault_pod"
	req_access = list(ACCESS_CENT_SPECOPS_COMMANDER)
	circuit = /obj/item/circuitboard/shuttle/nanotrasen/drop_pod
	shuttleId = "nt_drop_pod"
	possible_destinations = null
	/// Is it possible to force sent a drop pod? (for admin shitspawns)
	var/allow_force_sent = FALSE
	/// To prevent spamming
	var/next_request

/obj/machinery/computer/shuttle/nanotrasen/drop_pod/can_call_shuttle(user, action)
	if(action == "move")
		if(world.time < next_request)
			var/wait_time = round((next_request - world.time) / 10, 1)
			to_chat(user, span_warning("Подождите ещё [wait_time] [wait_time == 1 ? "секунду" : "секунд"] перед использованием!"))
			return
		// 20 seconds cooldown before use
		next_request = world.time + 20 SECONDS
		if(z != level_name_to_num(CENTCOMM))
			to_chat(user, span_warning("Дроп Под может лететь только в одну сторону!"))
			return FALSE
		if(!allow_force_sent && SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_EPSILON)
			to_chat(user, span_warning("Дроп Под доступен при коде не ниже «Epsilon»!"))
			return FALSE
	return ..()

/obj/machinery/computer/shuttle/nanotrasen/drop_pod/vv_edit_var(var_name, var_value)
	if(var_name == "allow_force_sent")
		var/confirm = tgui_alert(usr, "Отправка Дроп Пода в последующем будет невозможна, вы уверены?", "Подтверждение", list("Да", "Нет"))
		if(confirm != "Да")
			return FALSE
	return ..()

/* Docking Ports */
/obj/docking_port/mobile/assault_pod/nanotrasen
	id = "nt_drop_pod"

/obj/docking_port/mobile/assault_pod/nanotrasen/request()
	// No launching pods that have already launched
	if(z == initial(src.z))
		return ..()

/* Circuits */
/obj/item/circuitboard/shuttle/nanotrasen/recall
	board_name = "Nanotrasen Shuttle Recall Terminal"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/nanotrasen/recall

/obj/item/circuitboard/shuttle/nanotrasen/drop_pod
	board_name = "Nanotrasen Drop Pod"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/nanotrasen/drop_pod

/* Specific Shuttle Items */
/obj/item/assault_pod/nanotrasen
	shuttle_id = "nt_drop_pod"
