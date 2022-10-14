/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure1"
	density = 1
	opened = 0
	locked = 1
	broken = 0
	can_be_emaged = TRUE
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	damage_deflection = 20
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

/obj/structure/closet/secure_closet/proc/togglelock(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
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

/obj/structure/closet/secure_closet/closed_item_click(mob/user)
	togglelock(user)

/obj/structure/closet/secure_closet/AltClick(mob/user)
	if(Adjacent(user))
		togglelock(user)

/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(!broken)
		add_attack_logs(user, src, "emagged")
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

/obj/structure/closet/secure_closet/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 0 && user.a_intent != INTENT_HARM) // Stage one
		to_chat(user, "<span class='notice'>Вы начинаете откручивать панель замка [src]...</span>")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(95)) // EZ
				to_chat(user, "<span class='notice'>Вы успешно открутили и сняли панель с замка [src]!</span>")
				desc += " Панель управления снята."
				broken = 3
				icon_state = icon_off
			else // Bad day)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] сорвалась и повредила [affecting.name]!</span>")
		return TRUE

/obj/structure/closet/secure_closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 3 && user.a_intent != INTENT_HARM) // Stage two
		to_chat(user, "<span class='notice'>Вы начинаете подготавливать провода панели [src]...</span>")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				to_chat(user, "<span class='notice'>Вы успешно подготовили провода панели замка [src]!</span>")
				desc += " Провода отключены и торчат наружу."
				broken = 2
			else // woopsy
				to_chat(user, "<span class='warning'>Черт! Не тот провод!</span>")
				do_sparks(5, 1, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/secure_closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && broken == 2 && user.a_intent != INTENT_HARM) // Stage three
		to_chat(user, "<span class='notice'>Вы начинаете подключать провода панели замка [src] к [I]...</span>")
		if(I.use_tool(src, user, 160, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				desc += " Замок отключен."
				broken = 0 // Can be emagged
				emag_act(user)
			else // woopsy
				to_chat(user, "<span class='warning'>Черт! Не тот провод!</span>")
				do_sparks(5, 1, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE
