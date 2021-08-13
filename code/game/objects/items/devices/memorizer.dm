/obj/item/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer"
	item_state = "nullrod"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT

	var/times_used = 0 //Number of times it's been used.
	var/broken = FALSE     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/battery_panel = FALSE //whether the flash can be modified with a cell or not
	var/overcharged = FALSE   //if overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/can_overcharge = FALSE //set this to FALSE if you don't want your flash to be overcharge capable
	var/use_sound = 'sound/weapons/flash.ogg'

/obj/item/memorizer/proc/clown_check(mob/user)
	if(user && (CLUMSY in user.mutations) && prob(50))
		memorize_carbon(user, user, 15, FALSE)
		return FALSE
	return TRUE

/obj/item/memorizer/attackby(obj/item/W, mob/user, params)
	if(can_overcharge)
		if(istype(W, /obj/item/screwdriver))
			if(battery_panel)
				to_chat(user, "<span class='notice'>You close the battery compartment on the [src].</span>")
				battery_panel = FALSE
			else
				to_chat(user, "<span class='notice'>You open the battery compartment on the [src].</span>")
				battery_panel = TRUE
		if(battery_panel && !overcharged)
			if(istype(W, /obj/item/stock_parts/cell))
				to_chat(user, "<span class='notice'>You jam the cell into battery compartment on the [src].</span>")
				qdel(W)
				overcharged = TRUE
				overlays += "overcharge"

/obj/item/memorizer/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = TRUE
	icon_state = "[initial(icon_state)]burnt"
	visible_message("<span class='notice'>The [src.name] burns out!</span>")


/obj/item/memorizer/proc/flash_recharge(var/mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		return FALSE

	var/deciseconds_passed = world.time - last_used
	for(var/seconds = deciseconds_passed/10, seconds>=10, seconds-=10) //get 1 charge every 10 seconds
		times_used--

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/memorizer/proc/try_use_flash(mob/user = null)
	flash_recharge(user)

	if(broken)
		return FALSE

	playsound(loc, use_sound, 100, 1)
	flick("[initial(icon_state)]2", src)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, /atom./proc/set_light, 0), 2)
	times_used++

	if(user && !clown_check(user))
		return FALSE

	return TRUE


/obj/item/memorizer/proc/memorize_carbon(var/mob/living/carbon/M, var/mob/user = null, var/power = 5, targeted = 1)
	if(user)
		add_attack_logs(user, M, "memorized with [src]")
		if(targeted)
			if(M.weakeyes)
				M.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
			if(M.flash_eyes(1, 1))
				M.AdjustConfused(power)
				M.Stun(1)
				visible_message("<span class='disarm'>[user] erases [M] memory with the memorizer!</span>")
				to_chat(user, "<span class='danger'>You erased [M] memory with the memorizer!</span>")
				to_chat(M, "<span class='danger'><span class='reallybig'>Your memory about last events has been erased!</span>")
				if(M.weakeyes)
					M.Stun(2)
					M.visible_message("<span class='disarm'>[M] gasps and shields [M.p_their()] eyes!</span>", "<span class='userdanger'>You gasp and shield your eyes!</span>")
			else
				visible_message("<span class='disarm'>[user] fails to erase [M] memory with the memorizer!</span>")
				to_chat(user, "<span class='warning'>You fail to erase [M] memory with the memorizer!</span>")
				to_chat(M, "<span class='danger'>[user] fails to erase your memory with the memorizer!</span>")
			return

	if(M.flash_eyes())
		M.AdjustConfused(power)

/obj/item/memorizer/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return FALSE
	if(iscarbon(M))
		memorize_carbon(M, user, 5, TRUE)
		if(overcharged)
			M.adjust_fire_stacks(6)
			M.IgniteMob()
			burn_out()
		return TRUE
	else if(issilicon(M))
		add_attack_logs(user, M, "Flashed with [src]")
		if(M.flash_eyes(affect_silicon = TRUE))
			M.Weaken(rand(5,10))
			user.visible_message("<span class='disarm'>[user] overloads [M]'s sensors with the [src.name]!</span>", "<span class='danger'>You overload [M]'s sensors with the [src.name]!</span>")
		return TRUE
	user.visible_message("<span class='disarm'>[user] fails to blind [M] with the [src.name]!</span>", "<span class='warning'>You fail to blind [M] with the [src.name]!</span>")


/obj/item/memorizer/attack_self(mob/living/carbon/user, flag = 0, emp = FALSE)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message("<span class='disarm'>[user]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
	for(var/mob/living/carbon/M in oviewers(3, null))
		memorize_carbon(M, user, 3, FALSE)


/obj/item/memorizer/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/M in viewers(3, null))
		memorize_carbon(M, null, 10, TRUE)
	burn_out()
