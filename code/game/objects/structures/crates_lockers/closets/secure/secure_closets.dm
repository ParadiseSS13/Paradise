/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure1"
	density = 1
	opened = 0
	locked = 1
	broken = 0
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	damage_deflection = 20
	var/large = 1
	icon_closed = "secure"
	var/icon_locked = "secure1"
	icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"
	wall_mounted = 0 //never solid (You can always pass over it)

/obj/structure/closet/secure_closet/can_open()
	if(!..())
		return 0
	if(locked)
		return 0
	return ..()

/obj/structure/closet/secure_closet/close()
	if(..())
		if(broken)
			icon_state = icon_off
		return 1
	else
		return 0

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
		to_chat(user, "<span class='notice'>Close the locker first.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The locker appears to be broken.</span>")
		return
	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return
	if(allowed(user))
		locked = !locked
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		visible_message("<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/secure_closet/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcs))
		return ..()

	if(opened)
		if(istype(W, /obj/item/grab))
			if(large)
				MouseDrop_T(W:affecting, user)	//act like they were dragged onto the closet
			else
				to_chat(user, "<span class='notice'>The locker is too small to stuff [W:affecting] into!</span>")
		if(isrobot(user))
			return
		if(!user.drop_item()) //couldn't drop the item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return
		if(W)
			W.forceMove(loc)
	else if((istype(W, /obj/item/card/emag)||istype(W, /obj/item/melee/energy/blade)) && !broken)
		emag_act(user)
	else if(istype(W,/obj/item/stack/packageWrap) || istype(W,/obj/item/weldingtool))
		return ..(W, user)
	else if(user.a_intent != INTENT_HARM)
		togglelock(user)
	else
		return ..()

/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		locked = FALSE
		icon_state = icon_off
		flick(icon_broken, src)
		to_chat(user, "<span class='notice'>You break the lock on \the [src].</span>")

/obj/structure/closet/secure_closet/attack_hand(mob/user)
	add_fingerprint(user)
	if(locked)
		togglelock(user)
	else
		toggle(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		add_fingerprint(usr)
		togglelock(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/secure_closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		if(locked)
			icon_state = icon_locked
		else
			icon_state = icon_closed
		if(welded)
			overlays += "welded"
	else
		icon_state = icon_opened

/obj/structure/closet/secure_closet/container_resist(var/mob/living/L)
	var/breakout_time = 2 //2 minutes by default
	if(opened)
		if(L.loc == src)
			L.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?
	if(!locked && !welded)
		return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'

	//okay, so the closet is either welded or locked... resist!!!
	L.changeNext_move(CLICK_CD_BREAKOUT)
	L.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(L, "<span class='warning'>You lean on the back of \the [src] and start pushing the door open. (this will take about [breakout_time] minutes)</span>")
	for(var/mob/O in viewers(src))
		O.show_message("<span class='danger'>The [src] begins to shake violently!</span>", 1)


	spawn(0)
		if(do_after(usr,(breakout_time*60*10), target = src)) //minutes * 60seconds * 10deciseconds
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				return

			//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
			if(!locked && !welded)
				return

			//Well then break it!
			desc = "It appears to be broken."
			icon_state = icon_off
			flick(icon_broken, src)
			sleep(10)
			flick(icon_broken, src)
			sleep(10)
			broken = 1
			locked = 0
			welded = 0
			update_icon()
			to_chat(usr, "<span class='warning'>You successfully break out!</span>")
			for(var/mob/O in viewers(L.loc))
				O.show_message("<span class='danger'>\the [usr] successfully broke out of \the [src]!</span>", 1)
			if(istype(loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
				var/obj/structure/bigDelivery/BD = loc
				BD.attack_hand(usr)
			open()
