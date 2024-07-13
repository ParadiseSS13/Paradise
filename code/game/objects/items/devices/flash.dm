/obj/item/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)
	belt_icon = "flash"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	materials = list(MAT_METAL = 300, MAT_GLASS = 300)
	origin_tech = "magnets=2;combat=1"

	var/times_used = 0 //Number of times it's been used.
	var/broken = FALSE     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/battery_panel = FALSE //whether the flash can be modified with a cell or not
	var/overcharged = FALSE   //if overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/can_overcharge = TRUE //set this to FALSE if you don't want your flash to be overcharge capable
	///This tracks the world.time until the flash can be used again
	var/cooldown
	///This is the duration of the cooldown
	var/cooldown_duration = 5 SECONDS
	var/use_sound = 'sound/weapons/flash.ogg'

/obj/item/flash/proc/clown_check(mob/user)
	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, 30 SECONDS, 0)
		return FALSE
	return TRUE

/obj/item/flash/attackby(obj/item/I, mob/user, params)
	if(can_overcharge)
		if(battery_panel && !overcharged)
			if(istype(I, /obj/item/stock_parts/cell))
				to_chat(user, "<span class='notice'>You jam [I] into the battery compartment on [src].</span>")
				qdel(I)
				overcharged = TRUE
				add_overlay("overcharge")

/obj/item/flash/screwdriver_act(mob/living/user, obj/item/I)
	if(!can_overcharge)
		return

	if(battery_panel)
		to_chat(user, "<span class='notice'>You close the battery compartment on [src].</span>")
	else
		to_chat(user, "<span class='notice'>You open the battery compartment on [src].</span>")
	battery_panel = !battery_panel
	return TRUE

/obj/item/flash/random/New()
	..()
	if(prob(25))
		broken = TRUE
		icon_state = "[initial(icon_state)]burnt"

/obj/item/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = TRUE
	icon_state = "[initial(icon_state)]burnt"
	visible_message("<span class='notice'>[src] burns out!</span>")


/obj/item/flash/proc/flash_recharge(mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return FALSE

	var/deciseconds_passed = world.time - last_used
	for(var/seconds = deciseconds_passed/10, seconds>=10, seconds-=10) //get 1 charge every 10 seconds
		times_used--

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/flash/proc/try_use_flash(mob/user)
	if(broken)
		return FALSE

	if(cooldown >= world.time && user)
		to_chat(user, "<span class='warning'>Your [name] is still too hot to use again!</span>")
		return FALSE
	cooldown = world.time + cooldown_duration
	flash_recharge(user)

	playsound(loc, use_sound, 100, 1)
	flick("[initial(icon_state)]2", src)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 2)
	times_used++

	if(user && !clown_check(user))
		return FALSE

	return TRUE


/obj/item/flash/proc/flash_carbon(mob/living/carbon/M, mob/user = null, power = 10 SECONDS, targeted = 1)
	if(user)
		add_attack_logs(user, M, "Flashed with [src]")
		if(targeted)
			if(M.flash_eyes(1, 1))
				M.AdjustConfused(power)
				revolution_conversion(M, user)
				if(!M.absorb_stun(0))
					M.drop_l_hand()
					M.drop_r_hand()
				visible_message("<span class='disarm'>[user] blinds [M] with [src]!</span>")
				to_chat(user, "<span class='danger'>You blind [M] with [src]!</span>")
				to_chat(M, "<span class='userdanger'>[user] blinds you with [src]!</span>")
			else
				visible_message("<span class='disarm'>[user] fails to blind [M] with [src]!</span>")
				to_chat(user, "<span class='warning'>You fail to blind [M] with [src]!</span>")
				to_chat(M, "<span class='danger'>[user] fails to blind you with [src]!</span>")
			return

	if(M.flash_eyes())
		M.AdjustConfused(power)

/obj/item/flash/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return FALSE
	if(iscarbon(M))
		flash_carbon(M, user, 10 SECONDS, 1)
		if(overcharged)
			M.adjust_fire_stacks(6)
			M.IgniteMob()
			burn_out()
		return TRUE
	else if(issilicon(M))
		add_attack_logs(user, M, "Flashed with [src]")
		if(M.flash_eyes(intensity = 1.25, affect_silicon = TRUE)) // 40 * 1.25 = 50 stamina damage
			user.visible_message("<span class='disarm'>[user] overloads [M]'s sensors with [src]!</span>", "<span class='danger'>You overload [M]'s sensors with [src]!</span>")
		return TRUE
	user.visible_message("<span class='disarm'>[user] fails to blind [M] with [src]!</span>", "<span class='warning'>You fail to blind [M] with [src]!</span>")

/obj/item/flash/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity)
		return
	if(!istype(target, /obj/machinery/camera))
		return
	if(!try_use_flash(user))
		return
	var/obj/machinery/camera/C = target
	C.emp_act(EMP_HEAVY)
	to_chat(user,"<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>")
	log_admin("[key_name(user)] EMPd a camera with a flash")
	user.create_attack_log("[key_name(user)] EMPd a camera with a flash")
	add_attack_logs(user, C, "EMPd with [src]", ATKLOG_ALL)


/obj/item/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message("<span class='disarm'>[user]'s [name] emits a blinding light!</span>", "<span class='danger'>Your [name] emits a blinding light!</span>")
	for(var/mob/living/carbon/M in oviewers(3, null))
		flash_carbon(M, user, 6 SECONDS, 0)
	for(var/obj/machinery/camera/C in view(3, user))
		C.emp_act(EMP_LIGHT)
		log_admin("[key_name(user)] EMPd a camera with a flash")
		user.create_attack_log("[key_name(user)] EMPd a camera with a flash")
		add_attack_logs(user, C, "EMPd with [src]", ATKLOG_ALL)


/obj/item/flash/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/M in viewers(3, null))
		flash_carbon(M, null, 20 SECONDS, 0)
	burn_out()
	..()


/obj/item/flash/proc/revolution_conversion(mob/M, mob/user)
	if(!ishuman(M) || !user.mind?.has_antag_datum(/datum/antagonist/rev/head))
		return
	if(M.stat != CONSCIOUS)
		to_chat(user, "<span class='warning'>They must be conscious before you can convert [M.p_them()]!</span>")
	else if(add_revolutionary(M.mind))
		times_used-- //Flashes less likely to burn out for headrevs when used for conversion
	else
		to_chat(user, "<span class='warning'>This mind seems resistant to [src]!</span>")

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

/obj/item/flash/cyborg/attack(mob/living/M, mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cyborg/attack_self(mob/user)
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
	item_state = "electropack" //spelling, a coders worst enemy. This part gave me trouble for a while.
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_FLAG_BELT
	can_overcharge = FALSE
	var/flash_max_charges = 5
	var/flash_cur_charges = 5
	var/charge_tick = 0
	use_sound = 'sound/items/polaroid1.ogg'

/obj/item/flash/cameraflash/burn_out() //stops from burning out
	return

/obj/item/flash/cameraflash/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/flash/cameraflash/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flash/cameraflash/process() //this and the two parts above are part of the charge system.
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	flash_cur_charges = min(flash_cur_charges+1, flash_max_charges)
	return TRUE

/obj/item/flash/cameraflash/try_use_flash(mob/user = null)
	if(!flash_cur_charges)
		to_chat(user, "<span class='warning'>[src] needs time to recharge!</span>")
		return FALSE
	. = ..()
	if(.)
		flash_cur_charges--
		to_chat(user, "[src] now has [flash_cur_charges] charge\s.")

/obj/item/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon_state = "memorizer"
	item_state = "nullrod"

/obj/item/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	cooldown_duration = 2 SECONDS
	var/obj/item/organ/internal/cyberimp/arm/implant = null

/obj/item/flash/armimplant/burn_out()
	if(implant?.owner)
		to_chat(implant.owner, "<span class='warning'>Your [name] implant overheats and deactivates!</span>")
		implant.Retract()

/obj/item/flash/armimplant/Destroy()
	implant = null
	return ..()

/// just a regular flash now
/obj/item/flash/synthetic
