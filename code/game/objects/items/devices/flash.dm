/obj/item/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	inhand_icon_state = "flashtool"	// Looks exactly like a flash (and nothing like a flashbang).
	belt_icon = "flash"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	flags = CONDUCT
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	origin_tech = "magnets=2;combat=1"

	/// Is the flash burnt out?
	var/broken = FALSE
	/// Whether the flash can be modified with a cell or not
	var/battery_panel = FALSE
	/// If overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/overcharged = FALSE
	/// Set this to FALSE if you don't want your flash to be overcharge capable
	var/can_overcharge = TRUE
	/// How many times have we used the flash recently
	var/times_used = 0
	/// What is the max amount we can use this flash before it burns out
	var/max_uses = 5
	/// A reference to the timer used to recharge. If we use it while it's on cooldown, we reset the cooling
	var/flash_timer
	/// How long do we have between flashes
	var/time_between_flashes = 5 SECONDS
	new_attack_chain = TRUE

	var/use_sound = 'sound/weapons/flash.ogg'
	COOLDOWN_DECLARE(flash_cooldown)

/obj/item/flash/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!can_overcharge || !istype(used, /obj/item/stock_parts/cell))
		return ..()

	if(!battery_panel)
		to_chat(user, SPAN_WARNING("You need to unscrew the battery panel before inserting [used]!"))
		return ITEM_INTERACT_COMPLETE

	if(overcharged)
		to_chat(user, SPAN_WARNING("There's already a power cell attached to [src]!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You jam [used] into the battery compartment on [src]."))
	qdel(used)
	overcharged = TRUE
	update_icon(UPDATE_OVERLAYS)
	return ITEM_INTERACT_COMPLETE

/obj/item/flash/update_overlays()
	. = ..()
	if(overcharged)
		add_overlay("overcharge")

/obj/item/flash/screwdriver_act(mob/living/user, obj/item/I)
	if(!can_overcharge)
		return

	if(battery_panel)
		to_chat(user, SPAN_NOTICE("You close the battery compartment on [src]."))
	else
		to_chat(user, SPAN_NOTICE("You open the battery compartment on [src]."))
	battery_panel = !battery_panel
	return TRUE

/obj/item/flash/proc/burn_out() // Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = TRUE
	icon_state = "[initial(icon_state)]burnt"
	visible_message(SPAN_NOTICE("[src] burns out!"))

/obj/item/flash/proc/try_use_flash(mob/user)
	if(broken)
		return FALSE

	if(!COOLDOWN_FINISHED(src, flash_cooldown) && user)
		to_chat(user, SPAN_WARNING("Your [name] is still too hot to use again!"))
		return FALSE

	. = TRUE
	COOLDOWN_START(src, flash_cooldown, time_between_flashes)
	if(!flash_timer)
		flash_timer = addtimer(CALLBACK(src, PROC_REF(flash_recharge)), 10 SECONDS, TIMER_STOPPABLE)
	else
		// The flash can't cool down if you overheat it again!
		deltimer(flash_timer)
		flash_timer = addtimer(CALLBACK(src, PROC_REF(flash_recharge)), 10 SECONDS, TIMER_STOPPABLE)

	playsound(loc, use_sound, 100, TRUE)

	flick("[initial(icon_state)]2", src)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 2 DECISECONDS)

	times_used++
	if(times_used == (max_uses - 1))
		to_chat(user, SPAN_WARNING("[src] is getting dangerously hot! Don't use it for a few seconds or it will burn out!"))
	else if(times_used == max_uses)
		burn_out()

	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, 30 SECONDS, 0)
		return FALSE

/obj/item/flash/proc/flash_recharge(mob/user)
	times_used = max(0, times_used - 1)
	if(times_used)
		flash_timer = addtimer(CALLBACK(src, PROC_REF(flash_recharge)), 10 SECONDS, TIMER_STOPPABLE)
	else
		flash_timer = null

/obj/item/flash/proc/flash_carbon(mob/living/carbon/target, mob/user, power = 10 SECONDS, targeted = TRUE)
	if(user)
		add_attack_logs(user, target, "Flashed with [src]")
		if(targeted)
			if(target.flash_eyes(1, 1))
				target.AdjustConfused(power)
				revolution_conversion(target, user)
				if(!target.absorb_stun(0))
					target.drop_l_hand()
					target.drop_r_hand()
				target.visible_message(
					SPAN_DANGER("[user] blinds [target] with [src]!"),
					SPAN_USERDANGER("[user] blinds you with [src]!"),
					SPAN_HEAR("A click and a rising high pitched tone fills the air!")
				)
			else
				target.visible_message(
					SPAN_DISARM("[user] fails to blind [target] with [src]!"),
					SPAN_USERDANGER("[user] fails to blind you with [src]!"),
					SPAN_HEAR("A click and a rising high pitched tone fills the air!")
				)
			return

	if(target.flash_eyes())
		target.AdjustConfused(power)

/obj/item/flash/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!try_use_flash(user))
		return NONE

	if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/camera = target
		camera.emp_act(EMP_HEAVY)
		user.visible_message(
			SPAN_WARNING("[user] flashes [camera] with [src], temporarily overloading its sensors!"),
			SPAN_DISARM("You flash the lens of [camera] with [src], temporarily overloading its sensors!"),
			SPAN_HEAR("A click and a rising high pitched tone fills the air!")
		)
		log_admin("[key_name(user)] EMPd a camera with a flash")
		user.create_attack_log("[key_name(user)] EMPd a camera with a flash")
		add_attack_logs(user, camera, "EMPd with [src]", ATKLOG_ALL)
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		flash_carbon(target, user, 10 SECONDS, 1)
		if(overcharged)
			carbon_target.adjust_fire_stacks(6)
			carbon_target.IgniteMob()
			carbon_target.visible_message(
				SPAN_DANGER("[carbon_target] suddenly bursts into flames!"),
				SPAN_USERDANGER("You suddenly burst into flames!"),
				SPAN_DANGER("You hear a flame erupting!")
			)
			burn_out()
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	if(issilicon(target))
		var/mob/living/silicon/silicon_target = target
		add_attack_logs(user, target, "Flashed with [src]")
		if(silicon_target.flash_eyes(intensity = 1.25, affect_silicon = TRUE)) // 40 * 1.25 = 50 stamina damage
			user.visible_message(
				SPAN_DISARM("[user] overloads [target]'s sensors with [src]!"),
				SPAN_DANGER("You overload [target]'s sensors with [src]!"),
				SPAN_HEAR("A click and a rising high pitched tone fills the air!")
			)
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_DISARM("[user] fails to blind [target] with [src]!"),
		SPAN_WARNING("You fail to blind [target] with [src]!"),
		SPAN_HEAR("A click and a rising high pitched tone fills the air!")
	)

/obj/item/flash/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(!try_use_flash(user))
		return NONE

	add_fingerprint(user)
	user.visible_message(
		SPAN_DISARM("[user]'s [name] emits a blinding light!"),
		SPAN_DANGER("Your [name] emits a blinding light!"),
		SPAN_HEAR("A click and a rising high pitched tone fills the air!")
	)
	for(var/mob/living/carbon/mob_target in oviewers(3, null))
		flash_carbon(mob_target, user, 6 SECONDS, 0)

	for(var/obj/machinery/camera/camera_target in view(3, user))
		camera_target.emp_act(EMP_LIGHT)
		log_admin("[key_name(user)] EMPd a camera with a flash")
		user.create_attack_log("[key_name(user)] EMPd a camera with a flash")
		add_attack_logs(user, camera_target, "EMPd with [src]", ATKLOG_ALL)
	return ITEM_INTERACT_COMPLETE

/obj/item/flash/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/M in viewers(3, null))
		flash_carbon(M, null, 20 SECONDS, 0)
	burn_out()
	return ..()

/obj/item/flash/proc/revolution_conversion(mob/M, mob/user)
	if(!ishuman(M) || !user.mind?.has_antag_datum(/datum/antagonist/rev/head))
		return
	if(M.stat != CONSCIOUS)
		to_chat(user, SPAN_WARNING("They must be conscious before you can convert [M.p_them()]!"))
	else if(add_revolutionary(M.mind))
		times_used-- //Flashes less likely to burn out for headrevs when used for conversion
	else
		to_chat(user, SPAN_WARNING("This mind seems resistant to [src]!"))

/obj/item/flash/proc/add_revolutionary(datum/mind/converting_mind)
	var/mob/living/carbon/human/conversion_target = converting_mind.current
	if(converting_mind.assigned_role in GLOB.command_positions)
		return FALSE
	if(!istype(conversion_target))
		return FALSE
	if(ismindshielded(conversion_target))
		return FALSE
	if(converting_mind.has_antag_datum(/datum/antagonist/rev))
		return FALSE
	converting_mind.add_antag_datum(/datum/antagonist/rev)

	conversion_target.Silence(10 SECONDS)
	conversion_target.Stun(10 SECONDS)
	return TRUE

/obj/item/flash/cyborg
	origin_tech = null
	can_overcharge = FALSE

/obj/item/flash/cyborg/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cyborg/activate_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cyborg/cyborg_recharge(coeff, emagged)
	if(broken)
		broken = FALSE
		times_used = 0
		icon_state = "flash"

/obj/item/flash/cameraflash
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	worn_icon_state = "camera"
	inhand_icon_state = "camera"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_NECK
	can_overcharge = FALSE
	var/flash_max_charges = 5
	var/flash_cur_charges = 5
	var/charge_tick = 0
	use_sound = 'sound/items/polaroid1.ogg'

/obj/item/flash/cameraflash/burn_out() //stops from burning out
	return

/obj/item/flash/cameraflash/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/flash/cameraflash/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flash/cameraflash/process() //this and the two parts above are part of the charge system.
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	flash_cur_charges = min(flash_cur_charges + 1, flash_max_charges)
	return TRUE

/obj/item/flash/cameraflash/try_use_flash(mob/user = null)
	if(!flash_cur_charges)
		to_chat(user, SPAN_WARNING("[src] needs time to recharge!"))
		return FALSE
	. = ..()
	if(.)
		flash_cur_charges--
		to_chat(user, "[src] now has [flash_cur_charges] charge\s.")

/obj/item/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon." // Why doesn't this at least delete your notes smh.
	icon_state = "memorizer"
	inhand_icon_state = "tele_baton"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'

/obj/item/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	time_between_flashes = 2 SECONDS
	var/obj/item/organ/internal/cyberimp/arm/implant

/obj/item/flash/armimplant/burn_out()
	if(implant?.owner)
		to_chat(implant.owner, SPAN_WARNING("Your [name] implant overheats and deactivates!"))
		implant.Retract()

/obj/item/flash/armimplant/Destroy()
	implant = null
	return ..()

/obj/item/flash/random/Initialize(mapload)
	. = ..()
	if(prob(25))
		broken = TRUE
		icon_state = "[initial(icon_state)]burnt"
