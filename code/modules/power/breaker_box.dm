#define MASTER_BREAKER_

#define BREAKER_DELAY (1 SECONDS)

/obj/machinery/power/breaker_box
	name = "breaker box"
	desc = "a wall box panel which contains many small switch and one large switch which turn APCs on and off on the local network"
	icon = 'icons/obj/power.dmi'
	icon_state = "breakerbox"
	anchored = TRUE
	power_voltage_type = null // breaker box's don't connect to powernets so they don't have a voltage type, but their terminals do!
	req_one_access = list(ACCESS_ENGINE)
	interact_offline = TRUE
	/// The power terminal connected to this breakerbox
	var/obj/machinery/power/terminal/terminal = null
	/// Is the cover locked on this breaker box?
	var/cover_locked = FALSE
	/// Is the cover on this breaker box open?
	var/cover_open = FALSE
	/// Is the master breaker currently locked in its current position? (if TRUE, there is a lock on the breaker)
	var/master_breaker_locked = FALSE // masterbreaker :kapap:
	/// if TRUE, the master breaker is on
	var/master_breaker_toggled = TRUE

	var/list/breakers = list()

/obj/machinery/power/breaker_box/Initialize(mapload)
	. = ..()
	setDir(NORTH) // This is only used for pixel offsets, and later terminal placement. APC dir doesn't affect its sprite since it only has one orientation.
	set_pixel_offsets_from_dir(24, -24, 24, -24)
	update_icon()
	make_terminal()

/obj/machinery/power/breaker_box/proc/remake_breaker_list()
	breakers = list()
	for(var/obj/machinery/power/terminal/apc_terminal in terminal.powernet.nodes)
		var/obj/machinery/power/apc/apc = apc_terminal.master
		if(!istype(apc))
			return // git out of here!
		breakers[apc.UID()] = apc.operating

/obj/machinery/power/breaker_box/proc/make_terminal()
	terminal = new/obj/machinery/power/terminal(get_turf(src))
	terminal.setDir(dir)
	terminal.master = src
	terminal.connect_to_network()

/obj/machinery/power/breaker_box/terminal_update()
	remake_breaker_list()

/obj/machinery/power/breaker_box/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!cover_open)
		attempt_open(user)
		return
	ui_interact(user)

/obj/machinery/power/breaker_box/AltClick(mob/user)
	if(cover_open)
		attempt_close(user)
		return
	attempt_open(user)

/obj/machinery/power/breaker_box/proc/scan_id(obj/item/card/id/id_card, mob/living/user)
	if(check_access(id_card))
		var/message_to_send = cover_locked ? "span class='notice'>[user] swipes their ID on [src] and unlocks its cover.</span>" : "span class='notice'>[user] swipes their ID on [src] and locks its cover.</span>"
		visible_message(message_to_send, "You hear a faint beep followed by the sound of a latch sliding into place")
		toggle_lock()
	else
		visible_message("span class='notice'>[user] swipes their ID on [src] but nothing happens!</span>", "You hear the sound of plastic slap against a metallic panel.")
		to_chat(user, "Insufficient Access")

/obj/machinery/power/breaker_box/attacked_by(obj/item/I, mob/living/user)
	if(user.incapacitated())
		return
	add_fingerprint(user)
	if(istype(I, /obj/item/card/id))
		scan_id(I, user)
		return
	#warn implement attack mechanics here
	#warn implement tool interactions here / deconstruction

	return ..()

/obj/machinery/power/breaker_box/proc/toggle_lock(mob/user, list/access)
	cover_locked = !cover_locked

/obj/machinery/power/breaker_box/proc/open_cover()
	playsound(get_turf(src), 'sound/machines/power/panel_open.ogg', 50, FALSE)
	cover_open = TRUE
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/machinery/power/breaker_box/proc/attempt_open(mob/user)
	if(user.can_advanced_admin_interact())
		// even the blind deserve to notice adminbus
		visible_message("<span class='notice'>The panel of [src] flies open seemingly on its own accord!</span>", "You hear a loud swoosh and the sound of a metal panel slamming!")
		open_cover()
		return
	if(!iscarbon(user))
		return
	if(attack_zap_check(user) >= MACHINE_ELECTRIFIED_SHOCK)
		return
	add_fingerprint(user)
	if(cover_locked)
		playsound(get_turf(src), 'sound/machines/power/panel_locked.ogg', 50, FALSE)
		visible_message("<span class='notice'>[user] pulls at the [src] panel cover handle but it won't budge!</span>", "You hear a loud swoosh and the sound of a metal panel slamming!")
		return
	if(!do_after_once(user, BREAKER_DELAY, TRUE, get_turf(src), attempt_cancel_message = "You stop trying to open the breaker panel."))
		return
	visible_message("<span class='notice'>[user] opens the cover panel on [src]</span>", "You hear a latch being undone followed by a metallic creak.")
	open_cover()

/obj/machinery/power/breaker_box/proc/close_cover()
	playsound(get_turf(src), 'sound/machines/power/panel_close.ogg', 50, 0)
	cover_open = FALSE
	SStgui.close_uis(src) // no more fucking with the breakers for you!
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/machinery/power/breaker_box/proc/attempt_close(mob/user)
	add_fingerprint(user)
	if(!do_after_once(user, BREAKER_DELAY, TRUE, get_turf(src), attempt_cancel_message = "You stop trying to close the breaker panel."))
		return
	if(attack_zap_check(user) >= MACHINE_ELECTRIFIED_THROW)
		return
	close_cover()

/obj/machinery/power/breaker_box/proc/attempt_flip_breaker(mob/user, obj/machinery/power/apc/apc)
	if(!cover_open)
		to_chat(user, "<span class='notice'>You need to open [src]\s cover before doing that!</span>")
	if(user.can_advanced_admin_interact())
		// even the blind deserve to notice adminbus
		visible_message("<span class='notice'>A switch on [src] swings into the [apc.operating ? "off" : "on"] position seemingly on its own accord!</span>",
						"You hear a loud swoosh and the sound of a plastic switch moving into place!")
		flip_breaker(apc)
		return
	if(!ishuman(user))
		return
	add_fingerprint(user)
	if(attack_zap_check(user) >= MACHINE_ELECTRIFIED_SHOCK)
		return // nice try bucko, 3rd degree burns for you
	visible_message("<span class='notice'>[user] flips the [apc] breaker on [src] into the [apc.operating ? "off" : "on"] position.</span>",
						"You hear a metallic flick and a zzzt of electrical activity.")
	flip_breaker(apc)

/obj/machinery/power/breaker_box/proc/flip_breaker(obj/machinery/power/apc/apc)
	apc.operating = !apc.operating
	if(!apc.operating)
		apc.power_shutoff()
	playsound(get_turf(src), 'sound/machines/power/breaker_flip.ogg', 50, 0)


/obj/machinery/power/breaker_box/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	remake_breaker_list()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BreakerBox", name, 500, 750, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/obj/machinery/power/breaker_box/ui_data(mob/user)
	var/list/data = list()
	data["breaker_list"] = list()
	for(var/apc_uid in breakers)
		var/obj/machinery/power/apc/apc = locateUID(apc_uid)
		var/list/apc_data = list(
			"name" = apc.name,
			"toggled" = breakers[apc_uid],
			"apc_uid" = apc_uid,
			"breaker_color" = "yellow"
		)
		data["breaker_list"] += list(apc_data)
	data["has_screwdriver"] = isscrewdriver(user.get_active_hand())
	data["has_boltcutter"] = isboltcutter(user.get_active_hand())
	data["has_wirecutter"] = iswirecutter(user.get_active_hand())
	return data

/obj/machinery/power/breaker_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("flip_breaker")
			message_admins("detected")
			var/obj/machinery/power/apc/apc = locateUID(params["breaker_uid"])
			message_admins(apc.UID())
			message_admins(apc.type)
			message_admins(breakers[params["breaker_uid"]])
			if(!istype(apc) || isnull(breakers[params["breaker_uid"]]))
				return
			attempt_flip_breaker(ui.user, apc)
