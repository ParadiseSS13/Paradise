//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/fireaxe/fireaxe
	icon_state = "fireaxe_full_0hits"
	icon_closed = "fireaxe_full_0hits"
	icon_opened = "fireaxe_full_open"
	anchored = TRUE
	density = FALSE
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 100, BOMB = 10, RAD = 100, FIRE = 90, ACID = 50)
	var/localopened = FALSE //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = TRUE
	var/hitstaken = FALSE
	locked = TRUE
	var/smashed = FALSE
	var/operating = FALSE
	var/has_axe = null // Use a string over a boolean value to make the sprite names more readable

/obj/structure/closet/fireaxecabinet/populate_contents()
	fireaxe = new/obj/item/fireaxe(src)
	has_axe = "full"
	update_icon(UPDATE_ICON_STATE)	// So its initial icon doesn't show it without the fireaxe

/obj/structure/closet/fireaxecabinet/examine(mob/user)
	. = ..()
	if(!smashed)
		. += "<span class='notice'>Use a multitool to lock/unlock it.</span>"
	else
		. += "<span class='notice'>It is damaged beyond repair.</span>"

/obj/structure/closet/fireaxecabinet/attackby(obj/item/O as obj, mob/living/user as mob)  //Marker -Agouri
	if(isrobot(user) || locked)
		if(istype(O, /obj/item/multitool))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
			if(do_after(user, 20 * O.toolspeed, target = src))
				locked = FALSE
				to_chat(user, "<span class = 'caution'> You disable the locking modules.</span>")
				update_icon(UPDATE_ICON_STATE)
			return
		else if(isitem(O))
			user.changeNext_move(CLICK_CD_MELEE)
			var/obj/item/W = O
			if(smashed || localopened)
				if(localopened)
					operate_panel()
				return
			else
				user.do_attack_animation(src)
				playsound(user, 'sound/effects/Glasshit.ogg', 100, 1) //We don't want this playing every time
			if(W.force < 15)
				to_chat(user, "<span class='notice'>The cabinet's protective glass glances off the hit.</span>")
			else
				hitstaken++
				if(hitstaken == 4)
					playsound(user, 'sound/effects/glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
					smashed = TRUE
					locked = FALSE
					localopened = TRUE
			update_icon(UPDATE_ICON_STATE)
		return
	if(istype(O, /obj/item/fireaxe) && localopened)
		if(!fireaxe)
			var/obj/item/fireaxe/F = O
			if(HAS_TRAIT(F, TRAIT_WIELDED))
				to_chat(user, "<span class='warning'>Unwield \the [F] first.</span>")
				return
			if(!user.unEquip(F, FALSE))
				to_chat(user, "<span class='warning'>\The [F] stays stuck to your hands!</span>")
				return
			fireaxe = F
			has_axe = "full"
			contents += F
			to_chat(user, "<span class='notice'>You place \the [F] back in the [name].</span>")
			update_icon(UPDATE_ICON_STATE)
		else
			if(smashed)
				return
			else
				operate_panel()
	else
		if(smashed)
			return
		if(istype(O, /obj/item/multitool))
			if(localopened)
				operate_panel()
				return
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
				if(do_after(user, 20 * O.toolspeed, target = src))
					locked = TRUE
					to_chat(user, "<span class = 'caution'> You re-enable the locking modules.</span>")
				return
		else
			operate_panel()

/obj/structure/closet/fireaxecabinet/attack_hand(mob/user as mob)
	if(locked)
		to_chat(user, "<span class='warning'>The cabinet won't budge!</span>")
		return
	if(localopened && fireaxe)
		user.put_in_hands(fireaxe)
		to_chat(user, "<span class='notice'>You take \the [fireaxe] from [src].</span>")
		has_axe = "empty"
		fireaxe = null

		add_fingerprint(user)
		update_icon(UPDATE_ICON_STATE)
		return
	if(smashed)
		return
	operate_panel()

/obj/structure/closet/fireaxecabinet/attack_tk(mob/user as mob)
	if(localopened && fireaxe)
		fireaxe.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove \the [fireaxe].</span>")
		has_axe = "empty"
		fireaxe = null
		update_icon(UPDATE_ICON_STATE)
		return
	attack_hand(user)

/obj/structure/closet/fireaxecabinet/shove_impact(mob/living/target, mob/living/attacker)
	// no, you can't shove people into a fireaxe cabinet either
	return FALSE

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(smashed)
		to_chat(user, "<span class='warning'>The security of the cabinet is compromised.</span>")
		return
	else
		locked = !locked
		if(locked)
			to_chat(user, "<span class='warning'>Cabinet locked.</span>")
		else
			to_chat(user, "<span class='notice'>Cabinet unlocked.</span>")

/obj/structure/closet/fireaxecabinet/proc/operate_panel()
	if(operating)
		return
	operating = TRUE
	localopened = !localopened
	do_animate()
	operating = FALSE

/obj/structure/closet/fireaxecabinet/proc/do_animate()
	if(!localopened)
		flick("fireaxe_[has_axe]_closing", src)
	else
		flick("fireaxe_[has_axe]_opening", src)
	sleep(10)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/closet/fireaxecabinet/update_icon_state()
	if(localopened && !smashed)
		icon_state = "fireaxe_[has_axe]_open"
	else
		icon_state = "fireaxe_[has_axe]_[hitstaken]hits"

/obj/structure/closet/fireaxecabinet/update_overlays()
	return list()

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return

/obj/structure/closet/fireaxecabinet/welder_act(mob/user, obj/item/I) //A bastion of sanity in a sea of madness
	return
