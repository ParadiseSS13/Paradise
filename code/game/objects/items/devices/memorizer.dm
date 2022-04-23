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
	if(!can_overcharge)
		return
	if(istype(W, /obj/item/screwdriver))
		battery_panel = !battery_panel
		if(battery_panel)
			to_chat(user, "<span class='notice'>You open the battery compartment on the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You close the battery compartment on the [src].</span>")
	else if(istype(W, /obj/item/stock_parts/cell))
		if(!battery_panel || overcharged)
			return
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
		burn_out()
		return FALSE

	var/deciseconds_passed = world.time - last_used
	times_used -= round(deciseconds_passed / 100)

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


/obj/item/memorizer/proc/memorize_carbon(mob/living/carbon/fucking_target, mob/user = null, power = 5, targeted = TRUE)
	if(user)
		add_attack_logs(user, fucking_target, "memorized with [src]")
		if(targeted)
			if(fucking_target.weakeyes)
				fucking_target.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
			if(fucking_target.flash_eyes(1, 1))
				fucking_target.AdjustConfused(power)
				fucking_target.Stun(1)
				visible_message("<span class='disarm'>[user] erases [fucking_target] memory with the memorizer!</span>")
				to_chat(user, "<span class='danger'>You erased [fucking_target] memory with the memorizer!</span>")
				to_chat(fucking_target, "<span class='danger'><span class='reallybig'>Your memory about last events has been erased!</span>")
				if(fucking_target.weakeyes)
					fucking_target.Stun(2)
					fucking_target.visible_message("<span class='disarm'>[fucking_target] gasps and shields [fucking_target.p_their()] eyes!</span>", "<span class='userdanger'>You gasp and shield your eyes!</span>")
			else
				visible_message("<span class='disarm'>[user] fails to erase [fucking_target] memory with the memorizer!</span>")
				to_chat(user, "<span class='warning'>You fail to erase [fucking_target] memory with the memorizer!</span>")
				to_chat(fucking_target, "<span class='danger'>[user] fails to erase your memory with the memorizer!</span>")
			return

	if(fucking_target.flash_eyes())
		fucking_target.AdjustConfused(power)

/obj/item/memorizer/attack(mob/living/fucking_target, mob/user)
	if(!try_use_flash(user))
		return FALSE
	if(iscarbon(fucking_target))
		memorize_carbon(fucking_target, user, 5, TRUE)
		if(overcharged)
			fucking_target.adjust_fire_stacks(6)
			fucking_target.IgniteMob()
			burn_out()
		return TRUE
	else if(issilicon(fucking_target))
		add_attack_logs(user, fucking_target, "Flashed with [src]")
		if(fucking_target.flash_eyes(affect_silicon = TRUE))
			fucking_target.Weaken(rand(5,10))
			user.visible_message("<span class='disarm'>[user] overloads [fucking_target]'s sensors with the [src.name]!</span>", "<span class='danger'>You overload [fucking_target]'s sensors with the [src.name]!</span>")
		return TRUE
	user.visible_message("<span class='disarm'>[user] fails to blind [fucking_target] with the [src.name]!</span>", "<span class='warning'>You fail to blind [fucking_target] with the [src.name]!</span>")


/obj/item/memorizer/attack_self(mob/living/carbon/user, flag = 0, emp = FALSE)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message("<span class='disarm'>[user]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
	for(var/mob/living/carbon/fucking_target in oviewers(3, null))
		memorize_carbon(fucking_target, user, 3, FALSE)


/obj/item/memorizer/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/fucking_target in viewers(3, null))
		memorize_carbon(fucking_target, null, 10, TRUE)
	burn_out()

/obj/item/memorizer/syndicate
	name = "Нейрализатор"
	desc = "Если перед вами сработает это устройство, скорее всего вы не сможете об этом вспомнить!"
	origin_tech = "abductor=3;syndicate=2"

/obj/item/memorizer/syndicate/memorize_carbon(mob/living/carbon/fucking_target, mob/user = null, power = 5, targeted = TRUE)
	if(user)
		add_attack_logs(user, fucking_target, "[user] стёр память [fucking_target] с помощью [src]а")
		if(targeted)
			if(!fucking_target.mind)
				to_chat(user, "<span class='danger'>[fucking_target] кататоник! Стирание памяти бесполезно против тех, кто не осознаёт ничего вокруг себя!</span>")
				return
			if(fucking_target.weakeyes)
				fucking_target.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
			if(fucking_target.flash_eyes(1, 1))
				fucking_target.AdjustConfused(power)
				fucking_target.Stun(1)
				visible_message("<span class='disarm'>[user] стирает память [fucking_target] с помощью Нейрализатора!</span>")
				to_chat(user, "<span class='danger'>Вы стёрли память [fucking_target] с помощью Нейрализатора!</span>")
				to_chat(fucking_target, "<span class='danger'><span class='reallybig'>Ваша память о последних недавних событиях была стёрта!</span>")
				if(is_taipan(fucking_target.z) && !fucking_target.mind.lost_memory)
					var/objective = "Вы не помните ничего о последних событиях, так как ваша память была стёрта. \
					В частности вы не помните о базе синдиката \"Тайпан\", о том как туда добраться и обо всём так или иначе с ней связанным!"
					var/datum/objective/custom_objective = new(objective)
					custom_objective.owner = fucking_target.mind
					fucking_target.mind.objectives += custom_objective
					fucking_target.mind.lost_memory = TRUE
					fucking_target.mind.announce_objectives()
				last_used = world.time
				if(fucking_target.weakeyes)
					fucking_target.Stun(2)
					fucking_target.visible_message("<span class='disarm'>[fucking_target] моргает, тем самым защищая свои глаза!!</span>", "<span class='userdanger'>Вы моргнули и защитили свои глаза!</span>")
			else
				visible_message("<span class='disarm'>У [user] не получилось стереть память [fucking_target] с помощью \"Нейрализатора\"!</span>")
				to_chat(user, "<span class='warning'>Вы не смогли стереть память [fucking_target] с помощью \"Нейрализатора\"!</span>")
				to_chat(fucking_target, "<span class='danger'>У [user] не получилось стереть вашу память с помощью \"Нейрализатора\"!</span>")
			return

	if(fucking_target.flash_eyes())
		fucking_target.AdjustConfused(power)
