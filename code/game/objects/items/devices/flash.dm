/obj/item/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	materials = list(MAT_METAL = 300, MAT_GLASS = 300)
	origin_tech = "magnets=2;combat=1"

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/battery_panel = 0 //whether the flash can be modified with a cell or not
	var/overcharged = 0   //if overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/can_overcharge = TRUE //set this to FALSE if you don't want your flash to be overcharge capable
	var/use_sound = 'sound/weapons/flash.ogg'

/obj/item/flash/proc/clown_check(mob/user)
	if(user && (CLUMSY in user.mutations) && prob(50))
		flash_carbon(user, user, 15, 0)
		return 0
	return 1

/obj/item/flash/attackby(obj/item/W, mob/user, params)
	if(can_overcharge)
		if(istype(W, /obj/item/screwdriver))
			if(battery_panel)
				to_chat(user, "<span class='notice'>You close the battery compartment on the [src].</span>")
				battery_panel = 0
			else
				to_chat(user, "<span class='notice'>You open the battery compartment on the [src].</span>")
				battery_panel = 1
		if(battery_panel && !overcharged)
			if(istype(W, /obj/item/stock_parts/cell))
				to_chat(user, "<span class='notice'>You jam the cell into battery compartment on the [src].</span>")
				qdel(W)
				overcharged = 1
				overlays += "overcharge"

/obj/item/flash/random/New()
	..()
	if(prob(25))
		broken = 1
		icon_state = "[initial(icon_state)]burnt"

/obj/item/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = 1
	icon_state = "[initial(icon_state)]burnt"
	visible_message("<span class='notice'>The [src.name] burns out!</span>")


/obj/item/flash/proc/flash_recharge(var/mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return 0

	var/deciseconds_passed = world.time - last_used
	for(var/seconds = deciseconds_passed/10, seconds>=10, seconds-=10) //get 1 charge every 10 seconds
		times_used--

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/flash/proc/try_use_flash(var/mob/user = null)
	flash_recharge(user)

	if(broken)
		return 0

	playsound(src.loc, use_sound, 100, 1)
	flick("[initial(icon_state)]2", src)
	times_used++

	if(user && !clown_check(user))
		return 0

	return 1


/obj/item/flash/proc/flash_carbon(var/mob/living/carbon/M, var/mob/user = null, var/power = 5, targeted = 1)
	add_attack_logs(user, M, "Flashed with [src]")
	if(user && targeted)
		if(M.weakeyes)
			M.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
		if(M.flash_eyes(1, 1))
			M.AdjustConfused(power)
			terrible_conversion_proc(M, user)
			M.Stun(1)
			visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")
			to_chat(user, "<span class='danger'>You blind [M] with the flash!</span>")
			to_chat(M, "<span class='userdanger'>[user] blinds you with the flash!</span>")
			if(M.weakeyes)
				M.Stun(2)
				M.visible_message("<span class='disarm'>[M] gasps and shields [M.p_their()] eyes!</span>", "<span class='userdanger'>You gasp and shields your eyes!</span>")
		else
			visible_message("<span class='disarm'>[user] fails to blind [M] with the flash!</span>")
			to_chat(user, "<span class='warning'>You fail to blind [M] with the flash!</span>")
			to_chat(M, "<span class='danger'>[user] fails to blind you with the flash!</span>")
	else
		if(M.flash_eyes())
			M.AdjustConfused(power)

/obj/item/flash/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return 0

	if(iscarbon(M))
		flash_carbon(M, user, 5, 1)
		if(overcharged)
			M.adjust_fire_stacks(6)
			M.IgniteMob()
			burn_out()
		return 1

	else if(issilicon(M))
		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			if(R.module) // Perhaps they didn't choose a module yet
				for(var/obj/item/borg/combat/shield/S in R.module.modules)
					if(R.activated(S))
						add_attack_logs(user, M, "Flashed with [src]")
						user.visible_message("<span class='disarm'>[user] tries to overloads [M]'s sensors with the [src.name], but is blocked by [M]'s shield!</span>", "<span class='danger'>You try to overload [M]'s sensors with the [src.name], but are blocked by [M.p_their()] shield!</span>")
						return 1
		add_attack_logs(user, M, "Flashed with [src]")
		if(M.flash_eyes(affect_silicon = 1))
			M.Weaken(rand(5,10))
			user.visible_message("<span class='disarm'>[user] overloads [M]'s sensors with the [src.name]!</span>", "<span class='danger'>You overload [M]'s sensors with the [src.name]!</span>")
		return 1

	user.visible_message("<span class='disarm'>[user] fails to blind [M] with the [src.name]!</span>", "<span class='warning'>You fail to blind [M] with the [src.name]!</span>")


/obj/item/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!try_use_flash(user))
		return 0
	user.visible_message("<span class='disarm'>[user]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
	for(var/mob/living/carbon/M in oviewers(3, null))
		flash_carbon(M, user, 3, 0)


/obj/item/flash/emp_act(severity)
	if(!try_use_flash())
		return 0
	for(var/mob/living/carbon/M in viewers(3, null))
		flash_carbon(M, null, 10, 0)
	burn_out()
	..()


/obj/item/flash/proc/terrible_conversion_proc(mob/M, mob/user)
	if(ishuman(M) && ishuman(user) && M.stat != DEAD)
		if(user.mind && (user.mind in SSticker.mode.head_revolutionaries))
			if(M.client)
				if(M.stat == CONSCIOUS)
					M.mind_initialize() //give them a mind datum if they don't have one.
					var/resisted
					if(!ismindshielded(M))
						if(user.mind in SSticker.mode.head_revolutionaries)
							if(SSticker.mode.add_revolutionary(M.mind))
								times_used -- //Flashes less likely to burn out for headrevs when used for conversion
							else
								resisted = 1
					else
						resisted = 1

					if(resisted)
						to_chat(user, "<span class='warning'>This mind seems resistant to the [name]!</span>")
				else
					to_chat(user, "<span class='warning'>They must be conscious before you can convert [M.p_them()]!</span>")
			else
				to_chat(user, "<span class='warning'>This mind is so vacant that it is not susceptible to influence!</span>")


/obj/item/flash/cyborg
	origin_tech = null

/obj/item/flash/cyborg/attack(mob/living/M, mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cyborg/attack_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cameraflash
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack" //spelling, a coders worst enemy. This part gave me trouble for a while.
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
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

/obj/item/flash/cameraflash/attack(mob/living/M, mob/user)
    if(flash_cur_charges > 0)
        flash_cur_charges -= 1
        to_chat(user, "[src] now has [flash_cur_charges] charge\s.")
        ..()
    else
        to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
    return

/obj/item/flash/cameraflash/attack_self(mob/living/carbon/user, flag = 0)
    if(flash_cur_charges > 0)
        flash_cur_charges -= 1
        to_chat(user, "[src] now has [flash_cur_charges] charge\s.")
        ..()
    else
        to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
    return

/obj/item/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon_state = "memorizer"
	item_state = "nullrod"

/obj/item/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	var/flashcd = 20
	var/overheat = 0
	var/obj/item/organ/internal/cyberimp/arm/flash/I = null

/obj/item/flash/armimplant/Destroy()
	I = null
	return ..()

/obj/item/flash/armimplant/burn_out()
	if(I && I.owner)
		to_chat(I.owner, "<span class='warning'>Your photon projector implant overheats and deactivates!</span>")
		I.Retract()
	overheat = FALSE
	addtimer(CALLBACK(src, .proc/cooldown), flashcd * 2)

/obj/item/flash/armimplant/try_use_flash(mob/user = null)
	if(overheat)
		if(I && I.owner)
			to_chat(I.owner, "<span class='warning'>Your photon projector is running too hot to be used again so quickly!</span>")
		return FALSE
	overheat = TRUE
	addtimer(CALLBACK(src, .proc/cooldown), flashcd)
	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	update_icon(1)
	return TRUE

/obj/item/flash/armimplant/proc/cooldown()
	overheat = FALSE


/obj/item/flash/synthetic //just a regular flash now
