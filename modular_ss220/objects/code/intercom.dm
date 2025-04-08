/obj/item/radio/intercom
	icon = 'modular_ss220/objects/icons/intercom.dmi'

	max_hear_range = 5
	has_fixed_hear_range = FALSE

	overlay_speaker_idle = "intercom_s"
	overlay_speaker_active = "intercom_receive"

	overlay_mic_idle = "intercom_m"
	overlay_mic_active = null

	/// The icon of intercom while it's not assembled
	var/icon_frame = "intercom-frame"
	/// The state of icon of intercom while it's unscrewed
	var/icon_postfix_open = "-open"
	/// The icon postfix of intercom while it's turned off
	var/icon_postfix_off = "-p"

	/// Used to disable mic if not used
	var/mic_timeout = 20 SECONDS

/obj/item/radio/intercom/ToggleBroadcast(mob/user = usr)
	. = ..()
	if(broadcasting && !issilicon(user))
		start_mic_timer()

/obj/item/radio/intercom/proc/start_mic_timer()
	addtimer(CALLBACK(src, PROC_REF(disable_mic)), mic_timeout, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

/obj/item/radio/intercom/proc/disable_mic()
	broadcasting = FALSE
	update_icon()

/obj/item/radio/intercom/talk_into(mob/living/M, list/message_pieces, channel, verbage)
	. = ..()
	if(broadcasting)
		start_mic_timer()

/obj/item/mounted/frame/intercom
	icon = 'modular_ss220/objects/icons/intercom.dmi'
	icon_state = "intercom-frame"

/obj/item/mounted/frame/intercom/do_build(turf/on_wall, mob/user)
	var/obj/item/radio/intercom/new_intercom = new(get_turf(src), get_dir(user, on_wall), 0)
	new_intercom.dir = REVERSE_DIR(new_intercom.dir)
	new_intercom.circuitry_installed = FALSE
	new_intercom.update_icon()
	qdel(src)

/obj/item/radio/intercom/attackby__legacy__attackchain(obj/item/W, mob/user)
	. = ..()
	if(. && istype(W, /obj/item/intercom_electronics))
		circuitry_installed = TRUE
		update_icon(UPDATE_ICON)

/obj/item/radio/intercom/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		update_icon(UPDATE_ICON)

/obj/item/radio/intercom/crowbar_act(mob/user, obj/item/I)
	. = ..()
	if(.)
		circuitry_installed = FALSE

/obj/item/radio/intercom/update_icon_state()
	if(!circuitry_installed)
		icon_state = icon_frame
	else
		icon_state = "[initial(icon_state)][!on ? icon_postfix_off : ""][b_stat ? icon_postfix_open : ""]"

/obj/item/radio/intercom/locked/prison
	name = "prison intercom"
	desc = /obj/item/radio/intercom::desc

/obj/item/radio/intercom/locked/prison/New()
	..()
	wires.cut(WIRE_RADIO_TRANSMIT) // this mends the wire actually
	disable_mic()
