//Holds defibs and recharges them from the powernet
//You can activate the mount with an empty hand to grab the paddles
//Not being adjacent will cause the paddles to snap back
/obj/machinery/defibrillator_mount
	name = "defibrillator mount"
	desc = "Holds and recharges defibrillators. You can grab the paddles if one is mounted."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	anchored = TRUE
	idle_power_consumption = 1
	req_one_access = list(ACCESS_MEDICAL, ACCESS_HEADS) //used to control clamps
	var/obj/item/defibrillator/defib //this mount's defibrillator
	var/clamps_locked = FALSE //if true, and a defib is loaded, it can't be removed without unlocking the clamps

/obj/machinery/defibrillator_mount/attack_ai()
	return

/obj/machinery/defibrillator_mount/get_cell()
	if(defib)
		return defib.get_cell()

/obj/machinery/defibrillator_mount/New(location, direction, building = 0)
	..()

	if(location)
		loc = location

	if(direction)
		setDir(direction)

	if(building)
		set_pixel_offsets_from_dir(30, -30, 30, -30)

/obj/machinery/defibrillator_mount/loaded/Initialize(mapload) //loaded subtype for mapping use
	. = ..()
	defib = new/obj/item/defibrillator/loaded(src)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/defibrillator_mount/loaded/locked
	clamps_locked = TRUE

/obj/machinery/defibrillator_mount/Destroy()
	QDEL_NULL(defib)
	return ..()

/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += "<span class='notice'>There is a defib unit hooked up. Alt-click to remove it.<span>"
		if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
			. += SPAN_NOTICE("Due to a security situation, its locking clamps can be toggled by swiping any ID.")
		else
			. += SPAN_NOTICE("Its locking clamps can be [clamps_locked ? "dis" : ""]engaged by swiping an ID with access.")
	else
		. += "<span class='notice'>There are a pair of <b>bolts</b> in the defibrillator unit housing, securing [src] to the wall.<span>"

/obj/machinery/defibrillator_mount/process()
	if(defib && defib.cell && defib.cell.charge < defib.cell.maxcharge && is_operational())
		use_power(200)
		defib.cell.give(180) //90% efficiency, slightly better than the cell charger's 87.5%
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/defibrillator_mount/update_overlays()
	. = ..()
	if(defib)
		. += "defib"
		if(defib.powered)
			. += "[defib.safety ? "online" : "emagged"]"
			var/ratio = defib.cell.charge / defib.cell.maxcharge
			ratio = CEILING(ratio * 4, 1) * 25
			. += "charge[ratio]"
		if(clamps_locked)
			. += "clamps"

//defib interaction
/obj/machinery/defibrillator_mount/attack_hand(mob/living/user)
	if(!defib)
		to_chat(user, SPAN_WARNING("There's no defibrillator unit loaded!"))
		return
	if(defib.paddles.loc != defib)
		to_chat(user, SPAN_WARNING("[defib.paddles.loc == user ? "You are already" : "Someone else is"] holding [defib]'s paddles!"))
		return
	defib.paddles_on_defib = FALSE
	user.put_in_hands(defib.paddles)

/obj/machinery/defibrillator_mount/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/defibrillator))
		if(defib)
			to_chat(user, SPAN_WARNING("There's already a defibrillator in [src]!"))
			return ITEM_INTERACT_COMPLETE
		if(used.flags & NODROP || !user.drop_item() || !used.forceMove(src))
			to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
			return ITEM_INTERACT_COMPLETE
		user.visible_message(SPAN_NOTICE("[user] hooks up [used] to [src]!"), \
		SPAN_NOTICE("You press [used] into the mount, and it clicks into place."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		defib = used
		update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	else if(defib && used == defib.paddles)
		user.drop_item()
		return ITEM_INTERACT_COMPLETE
	var/obj/item/card/id = used.GetID()
	if(id)
		if(check_access(id) || SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
			if(!defib)
				to_chat(user, SPAN_WARNING("You can't engage the clamps on a defibrillator that isn't there."))
				return ITEM_INTERACT_COMPLETE
			clamps_locked = !clamps_locked
			to_chat(user, SPAN_NOTICE("Clamps [clamps_locked ? "" : "dis"]engaged."))
			update_icon(UPDATE_OVERLAYS)
		else
			to_chat(user, SPAN_WARNING("Insufficient access."))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/defibrillator_mount/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(defib)
		to_chat(user, SPAN_WARNING("[defib] is blocking access to the bolts!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/defib_mount(get_turf(user))
	qdel(src)

/obj/machinery/defibrillator_mount/AltClick(mob/living/carbon/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	if(!defib)
		to_chat(user, SPAN_WARNING("It'd be hard to remove a defib unit from a mount that has none."))
		return
	if(clamps_locked)
		to_chat(user, SPAN_WARNING("You try to tug out [defib], but the mount's clamps are locked tight!"))
		return
	user.put_in_hands(defib)
	user.visible_message(SPAN_NOTICE("[user] unhooks [defib] from [src]."), \
	SPAN_NOTICE("You slide out [defib] from [src] and unhook the charging cables."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	defib = null
	update_icon(UPDATE_OVERLAYS)

//wallframe, for attaching the mounts easily
/obj/item/mounted/frame/defib_mount
	name = "unhooked defibrillator mount"
	desc = "A frame for a defibrillator mount."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/mounted/frame/defib_mount/do_build(turf/on_wall, mob/user)
	new /obj/machinery/defibrillator_mount(get_turf(src), get_dir(user, on_wall), 1)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	qdel(src)
