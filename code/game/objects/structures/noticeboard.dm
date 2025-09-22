#define MAX_NOTICES 5

/obj/item/mounted/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "noticeboard"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/mounted/noticeboard/do_build(turf/on_wall, mob/user)
	new /obj/structure/noticeboard(get_turf(user), get_dir(on_wall, user), TRUE)
	qdel(src)

/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "noticeboard-5"
	anchored = TRUE
	max_integrity = 150
	var/notices = 0

/obj/structure/noticeboard/Initialize(mapload, direction, building = FALSE)
	. = ..()

	if(building)
		setDir(direction)
		set_pixel_offsets_from_dir(-32, 32, -30, 30)
		update_icon(UPDATE_ICON_STATE)

	for(var/obj/item/paper in loc)
		if(notices >= MAX_NOTICES)
			break
		if(istype(paper, /obj/item/paper))
			paper.loc = src
			notices++

	update_icon(UPDATE_ICON_STATE)

/obj/structure/noticeboard/update_icon_state()
	if(notices)
		icon_state = "noticeboard-[notices]"
		return
	icon_state = "noticeboard"

/obj/structure/noticeboard/attack_hand(mob/user)
	ui_interact(user)

/obj/structure/noticeboard/attack_ghost(mob/user)
	ui_interact(user)

/obj/structure/noticeboard/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/noticeboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Noticeboard", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/noticeboard/ui_data(mob/user)
	var/list/data = list()

	var/list/pinned_papers = list()
	for(var/obj/item/paper/paper in src)
		pinned_papers += list(list(
			"name" = paper.name,
			"contents" = paper.info,
			"ref" = paper.UID(),
		))
	data["papers"] = pinned_papers

	return data

/obj/structure/noticeboard/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE

	add_fingerprint(usr)
	switch(action)
		if("interact")
			if(usr.stat || usr.restrained())
				return
			var/obj/item/paper/paper = locate(params["paper"])
			if(!istype(paper) || paper.loc != src)
				return
			var/obj/item/held_item = usr.get_active_hand()
			if(is_pen(held_item))
				paper.attackby__legacy__attackchain(held_item, usr)
				return
			else
				usr.put_in_hands(paper)
				paper.add_fingerprint(usr)
				notices--
				to_chat(usr, "<span class='notice'>You take a [paper.name] out of [src].</span>")
				update_icon(UPDATE_ICON_STATE)
		if("showFull")
			var/obj/item/paper/paper = locate(params["paper"])
			if(!paper && paper.loc != src)
				return
			paper.show_content(usr)
			return

/obj/structure/noticeboard/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/paper))
		if(notices >= MAX_NOTICES)
			to_chat(user, "<span class='notice'>You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached.</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE
		I.forceMove(src)
		notices++
		to_chat(user, "<span class='notice'>You pin the paper to the noticeboard.</span>")
		update_icon(UPDATE_ICON_STATE)
		add_fingerprint(user)
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/noticeboard/wrench_act(mob/living/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!(flags & NODECONSTRUCT))
		WRENCH_UNANCHOR_WALL_MESSAGE
		I.play_tool_sound(user, I.tool_volume)
		deconstruct(TRUE)

/obj/structure/noticeboard/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return
	if(notices)
		for(var/I in contents)
			var/obj/item/paper/notice = I
			notice.forceMove(loc)
	new /obj/item/mounted/noticeboard(loc)
	qdel(src)

#undef MAX_NOTICES
