
//The advanced pea-green monochrome lcd of tomorrow.
// EDIT 2020-09-21: We have had NanoUI PDAs for years, and I am now finally TGUI-ing them
// They arent pea green trash. I DEFY YOU COMMENTS!!! -aa

/// Global list of all PDAs in the world
GLOBAL_LIST_EMPTY(PDAs)

/obj/item/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT | ITEM_SLOT_PDA
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	origin_tech = "programming=2"
	/// Is this a silicon's internal PDA?
	var/silicon_pda = FALSE
	/// Name on the registered owner's ID card.
	var/owner = null
	/// Typepath of the ROM cartridge that spawns with this PDA, if any. Gives extra functionality to the PDA.
	var/default_cartridge = 0
	/// The ROM cartridge currently inside this PDA.
	var/obj/item/cartridge/cartridge = null
	/// The program currently loaded in the PDA (e.g. crew manifest, messanger, main menu).
	var/datum/data/pda/app/current_app = null
	/// Stated by some programs, not visible on examination.
	var/model_name = "Thinktronic 5230 Personal Data Assistant"
	/// Some PDA programs turn the PDA into scanning tool (e.g. gas scaner, medical analyzer).
	var/datum/data/pda/utility/scanmode/scanmode = null
	/// Code to unlock the Syndicate uplink.
	var/lock_code = ""
	/// Is the PDA muted?
	var/silent = FALSE
	/// How many sounds will be replaced with HONKs (when infected with honk.exe)?
	var/honkamt = 0
	/// How many sounds will be muted (when infected with mime.exe)?
	var/mimeamt = 0
	/// Can this PDA be blown up?
	var/detonate = TRUE
	/// This PDA's ringtone.
	var/ttone = "beep"
	/// Core programs that come with this PDA.
	var/list/programs = list(
		new/datum/data/pda/app/main_menu,
		new/datum/data/pda/app/notekeeper,
		new/datum/data/pda/app/messenger,
		new/datum/data/pda/app/manifest,
		new/datum/data/pda/app/nanobank,
		new/datum/data/pda/app/atmos_scanner,
		new/datum/data/pda/utility/flashlight,
		new/datum/data/pda/app/games,
		// Here our games go
		new/datum/data/pda/app/game/minesweeper)
	var/list/shortcut_cache = list()
	var/list/shortcut_cat_order = list()
	var/list/notifying_programs = list()

	/// ID card currently slotted into the PDA.
	var/obj/item/card/id/id = null
	/// Job on the current ID card.
	var/ownjob = null //related to above
	/// Rank of the current ID card.
	var/ownrank = null // this one is rank, never alt title
	/// PDA slot for a pAI.
	var/obj/item/paicard/pai = null
	/// PDA slot for a pen.
	var/obj/item/held_pen
	/// Type of pen this PDA spawns with.
	var/obj/item/pen/default_pen = /obj/item/pen
	var/retro_mode = 0

/*
 *	The Actual PDA
 */
/obj/item/pda/Initialize(mapload)
	. = ..()
	silent = TRUE // We don't want to hear the first program start up
	GLOB.PDAs += src
	GLOB.PDAs = sortAtom(GLOB.PDAs)
	update_programs()
	if(default_cartridge)
		cartridge = new default_cartridge(src)
		cartridge.update_programs(src)
	add_pen(new default_pen(src))
	update_icon(UPDATE_OVERLAYS)
	start_program(find_program(/datum/data/pda/app/main_menu))
	silent = initial(silent)

/obj/item/pda/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt-Click</b> [src] to remove its ID card.</span>"
	. += "<span class='notice'><b>Ctrl-Click</b> [src] to remove its pen.</span>"
	. += "<span class='notice'>Use a screwdriver on [src] to reset it.</span>"

/obj/item/pda/proc/can_use()
	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(M.incapacitated())
		return 0
	if((src in M.contents) || (isturf(loc) && in_range(src, M)))
		return 1
	else
		return 0

/obj/item/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/pda/GetID()
	return id

/obj/item/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!is_screen_atom(over_object)) && can_use())
		return attack_self__legacy__attackchain(M)

/obj/item/pda/attack_self__legacy__attackchain(mob/user as mob)
	if(active_uplink_check(user))
		return
	ui_interact(user)

/obj/item/pda/proc/start_program(datum/data/pda/P)
	if(P && ((P in programs) || (cartridge && (P in cartridge.programs))))
		return P.start()
	return 0

/obj/item/pda/proc/find_program(type)
	var/datum/data/pda/A = locate(type) in programs
	if(A)
		return A
	if(cartridge)
		A = locate(type) in cartridge.programs
		if(A)
			return A
	return null

// force the cache to rebuild on update_ui
/obj/item/pda/proc/update_shortcuts()
	shortcut_cache.Cut()

/obj/item/pda/proc/update_programs()
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = src

/obj/item/pda/update_overlays()
	. = ..()
	var/datum/data/pda/utility/flashlight/flash = find_program(/datum/data/pda/utility/flashlight)
	if(flash?.fon)
		switch(icon_state)
			if("pda-library")
				. += image('icons/obj/pda.dmi', "pda-light-library")
			if("pda-syndi")
				. += image('icons/obj/pda.dmi', "pda-light-syndi")
			else
				. += image('icons/obj/pda.dmi', "pda-light")

	if(id)
		switch(icon_state)
			if("pda-library")
				. += image('icons/obj/pda.dmi', "pda-id-library")
			if("pda-syndi")
				. += image('icons/obj/pda.dmi', "pda-id-syndi")
			else
				. += image('icons/obj/pda.dmi', "pda-id")

	if(held_pen)
		if(icon_state != "pda-syndi")
			if(icon_state == "pda-library")
				. += image('icons/obj/pda.dmi', "pda-pen-library")
			else
				. += image('icons/obj/pda.dmi', "pda-pen")

	if(length(notifying_programs))
		switch(icon_state)
			if("pda-library")
				. += image('icons/obj/pda.dmi', "pda-dm-library")
			if("pda-syndi")
				. += image('icons/obj/pda.dmi', "pda-dm-syndi")
			else
				. += image('icons/obj/pda.dmi', "pda-dm")

/obj/item/pda/proc/close(mob/user)
	SStgui.close_uis(src)

/obj/item/pda/screwdriver_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	start_program(find_program(/datum/data/pda/app/main_menu))
	notifying_programs.Cut()
	update_icon(UPDATE_OVERLAYS)
	to_chat(user, "<span class='notice'>You press the reset button on \the [src].</span>")
	SStgui.update_uis(src)

/obj/item/pda/AltClick(mob/user)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(!Adjacent(user) && !(loc == user))
		return

	if(issilicon(user))
		return

	if(id)
		remove_id(user)
	else
		to_chat(user, "<span class='warning'>This PDA does not have an ID in it!</span>")

/obj/item/pda/CtrlClick(mob/user)
	..()
	if(issilicon(user))
		return

	if(can_use(user))
		remove_pen(user)

/obj/item/pda/proc/remove_id(mob/user)
	if(id)
		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			to_chat(user, "<span class='notice'>You remove the ID from [src].</span>")
			SStgui.update_uis(src)
		else
			id.forceMove(get_turf(src))
		id = null
		update_icon(UPDATE_OVERLAYS)
		playsound(src, 'sound/machines/terminal_eject.ogg', 50, TRUE)

	if(ishuman(loc))
		var/mob/living/carbon/human/wearing_human = loc
		if(wearing_human.wear_id == src)
			wearing_human.sec_hud_set_ID()

/obj/item/pda/proc/remove_pen(mob/user)
	if(issilicon(user))
		return

	if(can_use(user))
		if(held_pen)
			to_chat(user, "<span class='notice'>You remove [held_pen] from [src].</span>")
			playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
			user.put_in_hands(held_pen)
			clear_pen()
			update_icon(UPDATE_OVERLAYS)
		else
			to_chat(user, "<span class='warning'>This PDA does not have a pen in it.</span>")
	else
		to_chat(user, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if(id)
			remove_id(user)
		else
			var/obj/item/I = user.get_active_hand()
			if(istype(I, /obj/item/card/id))
				user.drop_item()
				I.forceMove(src)
				id = I
	else
		var/obj/item/card/I = user.get_active_hand()
		if(istype(I, /obj/item/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.forceMove(src)
			id = I
			user.put_in_hands(old_id)
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)

	if(ishuman(loc))
		var/mob/living/carbon/human/wearing_human = loc
		if(wearing_human.wear_id == src)
			wearing_human.sec_hud_set_ID()

/obj/item/pda/attackby__legacy__attackchain(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/cartridge) && !cartridge)
		cartridge = C
		user.drop_item()
		cartridge.forceMove(src)
		cartridge.update_programs(src)
		update_shortcuts()
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		SStgui.update_uis(src)
		playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)

	else if(istype(C, /obj/item/card/id))
		var/obj/item/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			if(!silent)
				playsound(src, 'sound/machines/terminal_error.ogg', 50, TRUE)
			return
		if(!owner)
			var/datum/data/pda/app/nanobank/nanobank_program = (locate(/datum/data/pda/app/nanobank) in programs)
			if(nanobank_program && idcard.associated_account_number)
				nanobank_program.reconnect_database()
				nanobank_program.user_account = nanobank_program.account_database?.find_user_account(idcard.associated_account_number)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			ownrank = idcard.rank
			name = "PDA-[owner] ([ownjob])"
			to_chat(user, "<span class='notice'>Card scanned.</span>")
			SStgui.update_uis(src)
			if(!silent)
				playsound(src, 'sound/machines/terminal_success.ogg', 50, TRUE)
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(!HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) && ((src in user) || (isturf(loc) && in_range(src, user))))
				id_check(user, 2)
				to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.<br>You can remove it with ALT click.</span>")
				update_icon(UPDATE_OVERLAYS)
				SStgui.update_uis(src)

	else if(istype(C, /obj/item/paicard) && !src.pai)
		user.drop_item()
		C.forceMove(src)
		pai = C
		to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
		SStgui.update_uis(src)
		playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
	else if(is_pen(C))
		if(held_pen)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			user.drop_item()
			add_pen(C)
			to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)

/obj/item/pda/proc/add_pen(obj/item/P)
	P.forceMove(src)
	held_pen = P
	RegisterSignal(held_pen, COMSIG_PARENT_QDELETING, PROC_REF(clear_pen))
	update_icon(UPDATE_OVERLAYS)

/obj/item/pda/proc/clear_pen()
	UnregisterSignal(held_pen, COMSIG_PARENT_QDELETING)
	held_pen = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/pda/attack__legacy__attackchain(mob/living/C as mob, mob/living/user as mob)
	if(iscarbon(C) && scanmode)
		scanmode.scan_mob(C, user)

/obj/item/pda/afterattack__legacy__attackchain(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(proximity && scanmode)
		scanmode.scan_atom(A, user)

/obj/item/pda/proc/explode() //This needs tuning.
	if(!detonate)
		return
	var/turf/T = get_turf(src.loc)

	if(ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='danger'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3, cause = "Exploding PDA")
	qdel(src)
	return

/obj/item/pda/Destroy()
	GLOB.PDAs -= src
	var/T = get_turf(loc)
	if(id)
		id.forceMove(T)
	if(pai)
		pai.forceMove(T)
	current_app = null
	scanmode = null
	QDEL_NULL(held_pen)
	QDEL_LIST_CONTENTS(programs)
	QDEL_NULL(cartridge)
	return ..()

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/obj/item/pda/proc/play_ringtone()
	var/S
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		if(ttone in GLOB.pda_ringtone_choices)
			S = GLOB.pda_ringtone_choices[ttone]
		else
			S = 'sound/machines/twobeep_high.ogg'
		playsound(loc, S, 50, TRUE)
	for(var/mob/O in hearers(3, loc))
		O.show_message(text("[bicon(src)] *[ttone]*"))

/obj/item/pda/proc/set_ringtone(mob/user)
	var/new_tone = tgui_input_text(user, "Please enter new ringtone", name, ttone, max_length = 20, encode = FALSE)
	new_tone = trim(new_tone)

	if(!in_range(src, user) || loc != user)
		close(user)
		return FALSE

	if(!new_tone)
		return FALSE

	if(hidden_uplink && hidden_uplink.check_trigger(user, lowertext(new_tone), lowertext(lock_code)))
		to_chat(user, "The PDA softly beeps.")
		close(user)
		return TRUE
	ttone = new_tone
	return TRUE

/obj/item/pda/process()
	if(current_app)
		current_app.program_process()

/obj/item/pda/extinguish_light(force = FALSE)
	var/datum/data/pda/utility/flashlight/FL = find_program(/datum/data/pda/utility/flashlight)
	if(FL && FL.fon)
		FL.start()

/obj/item/pda/get_ID_assignment(if_no_id = "No id")
	. = ..()
	if(. == if_no_id) // We dont have an ID in us, check our cached job
		return ownjob

/obj/item/pda/get_ID_rank(if_no_id = "No id")
	. = ..()
	if(. == if_no_id) // Ditto but rank
		return ownrank
