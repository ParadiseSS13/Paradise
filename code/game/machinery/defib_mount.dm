//Holds defibs and recharges them from the powernet
//You can activate the mount with an empty hand to grab the paddles
//Not being adjacent will cause the paddles to snap back
/obj/machinery/defibrillator_mount
	name = "defibrillator mount"
	desc = "Holds and recharges defibrillators. You can grab the paddles if one is mounted."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	density = FALSE
	use_power = IDLE_POWER_USE
	anchored = TRUE
	idle_power_usage = 1
	power_channel = EQUIP
	req_access = list(ACCESS_MEDICAL, ACCESS_HEADS) //used to control clamps
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

/obj/machinery/defibrillator_mount/loaded/New() //loaded subtype for mapping use
	..()
	defib = new/obj/item/defibrillator/loaded(src)
	update_icon()

/obj/machinery/defibrillator_mount/Destroy()
	QDEL_NULL(defib)
	return ..()

/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += span_notice("There is a defib unit hooked up. Alt-click to remove it.")
		if(GLOB.security_level >= SEC_LEVEL_RED)
			. += span_notice("Due to a security situation, its locking clamps can be toggled by swiping any ID.")
		else
			. += span_notice("Its locking clamps can be [clamps_locked ? "dis" : ""]engaged by swiping an ID with access.")
	else
		. += span_notice("There are a pair of <b>bolts</b> in the defib unit housing securing the [src] to the wall.")

/obj/machinery/defibrillator_mount/process()
	if(defib && defib.cell && defib.cell.charge < defib.cell.maxcharge && is_operational())
		use_power(200)
		defib.cell.give(180) //90% efficiency, slightly better than the cell charger's 87.5%
		update_icon()

/obj/machinery/defibrillator_mount/update_icon()
	cut_overlays()
	if(defib)
		add_overlay("defib")
		if(defib.powered)
			add_overlay(defib.safety ? "online" : "emagged")
			var/ratio = defib.cell.charge / defib.cell.maxcharge
			ratio = CEILING(ratio * 4, 1) * 25
			add_overlay("charge[ratio]")
		if(clamps_locked)
			add_overlay("clamps")

//defib interaction
/obj/machinery/defibrillator_mount/attack_hand(mob/living/carbon/)
	var/mob/living/carbon/human/user = usr

	if(!defib)
		to_chat(user, span_warning("There's no defibrillator unit loaded!"))
		return

	var/obj/item/organ/external/temp2 = user.bodyparts_by_name["r_hand"]
	var/obj/item/organ/external/temp = user.bodyparts_by_name["l_hand"]

	if(!temp || !temp.is_usable() && !temp2 || !temp2.is_usable())
		to_chat(user, span_warning("You can't use your hand to take out the paddles!"))
		return

	if(defib.paddles.loc != defib)
		to_chat(user, span_warning("[defib.paddles.loc == user ? "You are already" : "Someone else is"] holding [defib]'s paddles!"))
		return

	defib.paddles.forceMove_turf()
	if(!user.put_in_hands(defib.paddles, ignore_anim = FALSE))
		defib.paddles.forceMove(defib)
		to_chat(user, SPAN_WARNING("You need a free hand to hold the paddles!"))
		return

	add_fingerprint(user)
	defib.paddles_on_defib = FALSE

/obj/machinery/defibrillator_mount/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/defibrillator))
		if(defib)
			to_chat(user, span_warning("There's already a defibrillator in [src]!"))
			return
		if(!user.drop_transfer_item_to_loc(I, src))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		add_fingerprint(user)
		user.visible_message(span_notice("[user] hooks up [I] to [src]!"), \
		span_notice("You press [I] into the mount, and it clicks into place."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		defib = I
		update_icon()
		return
	else if(defib && I == defib.paddles)
		add_fingerprint(user)
		user.drop_from_active_hand()
		return
	var/obj/item/card/id = I.GetID()
	if(id)
		if(check_access(id) || GLOB.security_level >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
			if(!defib)
				to_chat(user, span_warning("You can't engage the clamps on a defibrillator that isn't there."))
				return
			add_fingerprint(user)
			clamps_locked = !clamps_locked
			to_chat(user, span_notice("Clamps [clamps_locked ? "" : "dis"]engaged."))
			update_icon()
		else
			to_chat(user, span_warning("Insufficient access."))
		return
	return ..()

/obj/machinery/defibrillator_mount/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(defib)
		to_chat(user, span_warning("The [defib] is blocking access to the bolts!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/defib_mount(get_turf(user))
	qdel(src)

/obj/machinery/defibrillator_mount/AltClick(mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	var/obj/item/organ/external/temp2 = user.bodyparts_by_name["r_hand"]
	var/obj/item/organ/external/temp = user.bodyparts_by_name["l_hand"]
	if(!Adjacent(user))
		return
	if(!defib)
		to_chat(user, span_warning("It'd be hard to remove a defib unit from a mount that has none."))
		return
	if(!temp || !temp.is_usable() && !temp2 || !temp2.is_usable())
		to_chat(user, span_warning("You can't use your hand to take out the defibrillator!"))
		return
	if(clamps_locked)
		to_chat(user, span_warning("You try to tug out [defib], but the mount's clamps are locked tight!"))
		return
	defib.forceMove_turf()
	user.put_in_hands(defib, ignore_anim = FALSE)
	user.visible_message(span_notice("[user] unhooks [defib] from [src]."), \
	span_notice("You slide out [defib] from [src] and unhook the charging cables."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	defib = null
	update_icon()

//wallframe, for attaching the mounts easily
/obj/item/mounted/frame/defib_mount
	name = "unhooked defibrillator mount"
	desc = "A frame for a defibrillator mount."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	sheets_refunded = 0
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	w_class = WEIGHT_CLASS_BULKY

/obj/item/mounted/frame/defib_mount/do_build(turf/on_wall, mob/user)
	new /obj/machinery/defibrillator_mount(get_turf(src), get_dir(user, on_wall), 1)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	qdel(src)
