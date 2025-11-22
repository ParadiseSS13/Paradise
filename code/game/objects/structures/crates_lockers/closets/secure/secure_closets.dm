/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon_state = "secure"
	locked = TRUE
	secure = TRUE
	can_be_emaged = TRUE
	max_integrity = 250
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, RAD = 0, FIRE = 80, ACID = 80)
	damage_deflection = 20

/obj/structure/closet/secure_closet/can_open()
	if(!..())
		return FALSE
	if(locked)
		return FALSE
	return ..()

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			locked = !locked
			update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/user)
	if(opened)
		to_chat(user, SPAN_NOTICE("Close the locker first."))
		return
	if(broken)
		to_chat(user, SPAN_WARNING("The locker appears to be broken."))
		return
	if(user.loc == src)
		to_chat(user, SPAN_NOTICE("You can't reach the lock from inside."))
		return
	if(allowed(user))
		locked = !locked
		visible_message(SPAN_NOTICE("The locker has been [locked ? null : "un"]locked by [user]."))
		update_icon()
	else
		to_chat(user, SPAN_NOTICE("Access Denied."))

/obj/structure/closet/secure_closet/closed_item_click(mob/user)
	togglelock(user)

/obj/structure/closet/secure_closet/AltClick(mob/user)
	if(opened)
		return ..()
	if(Adjacent(user))
		togglelock(user)

/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		locked = FALSE
		flick_overlay_view(image(icon, src, "sparking"), src, 1 SECONDS)
		to_chat(user, SPAN_NOTICE("You break the lock on [src]."))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 1 SECONDS) // Update the icon so the lock actually appears broken
		return TRUE

/obj/structure/closet/secure_closet/attack_hand(mob/user)
	add_fingerprint(user)
	if(locked)
		togglelock(user)
	else
		toggle(user)

/obj/structure/closet/secure_closet/container_resist(mob/living/L)
	var/breakout_time = 2 MINUTES
	if(opened)
		if(L.loc == src)
			L.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?
	if(!locked && !welded)
		return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'

	//okay, so the closet is either welded or locked... resist!!!
	to_chat(L, SPAN_WARNING("You lean on the back of \the [src] and start pushing the door open. (this will take about [breakout_time / 600] minutes)"))
	for(var/mob/O in viewers(src))
		O.show_message(SPAN_DANGER("[src] begins to shake violently!"), 1)


	spawn(0)
		if(do_after(usr, breakout_time, target = src, allow_moving = TRUE, allow_moving_target = TRUE))
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				return

			//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
			if(!locked && !welded)
				return

			//Well then break it!
			desc = "It appears to be broken."
			broken = TRUE
			locked = FALSE
			welded = FALSE
			update_icon()
			to_chat(usr, SPAN_WARNING("You successfully break out!"))
			for(var/mob/O in viewers(L.loc))
				O.show_message(SPAN_DANGER("\the [usr] successfully broke out of \the [src]!"), 1)
			if(istype(loc, /obj/structure/big_delivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
				var/obj/structure/big_delivery/BD = loc
				BD.attack_hand(usr)
			open()
