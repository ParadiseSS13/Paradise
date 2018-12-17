//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/twohanded/fireaxe/fireaxe = new/obj/item/twohanded/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = 1
	density = 0
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 100, bomb = 10, bio = 100, rad = 100)
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	locked = 1
	var/smashed = 0

	attackby(var/obj/item/O as obj, var/mob/living/user as mob)  //Marker -Agouri
		//..() //That's very useful, Erro

		var/hasaxe = 0       //gonna come in handy later~
		if(fireaxe)
			hasaxe = 1

		if(isrobot(user) || src.locked)
			if(istype(O, /obj/item/multitool))
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
				if(do_after(user, 20 * O.toolspeed, target = src))
					src.locked = 0
					to_chat(user, "<span class = 'caution'> You disable the locking modules.</span>")
					update_icon()
				return
			else if(istype(O, /obj/item))
				user.changeNext_move(CLICK_CD_MELEE)
				var/obj/item/W = O
				if(src.smashed || src.localopened)
					if(localopened)
						localopened = 0
						icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					return
				else
					user.do_attack_animation(src)
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1) //We don't want this playing every time
				if(W.force < 15)
					to_chat(user, "<span class='notice'>The cabinet's protective glass glances off the hit.</span>")
				else
					src.hitstaken++
					if(src.hitstaken == 4)
						playsound(user, 'sound/effects/glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
						src.smashed = 1
						src.locked = 0
						src.localopened = 1
				update_icon()
			return
		if(istype(O, /obj/item/twohanded/fireaxe) && src.localopened)
			if(!fireaxe)
				if(O:wielded)
					to_chat(user, "<span class='warning'>Unwield the axe first.</span>")
					return
				fireaxe = O
				user.drop_item(O)
				src.contents += O
				to_chat(user, "<span class='notice'>You place the fire axe back in the [src.name].</span>")
				update_icon()
			else
				if(src.smashed)
					return
				else
					localopened = !localopened
					if(localopened)
						icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					else
						icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
		else
			if(src.smashed)
				return
			if(istype(O, /obj/item/multitool))
				if(localopened)
					localopened = 0
					icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
					return
				else
					to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
					sleep(50)
					src.locked = 1
					to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
					playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
					if(do_after(user, 20 * O.toolspeed, target = src))
						src.locked = 1
						to_chat(user, "<span class = 'caution'> You re-enable the locking modules.</span>")
					return
			else
				localopened = !localopened
				if(localopened)
					icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
				else
					icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()




	attack_hand(mob/user as mob)

		var/hasaxe = 0
		if(fireaxe)
			hasaxe = 1

		if(src.locked)
			to_chat(user, "<span class='warning'>The cabinet won't budge!</span>")
			return
		if(localopened)
			if(fireaxe)
				user.put_in_hands(fireaxe)
				fireaxe = null
				to_chat(user, "<span class='notice'>You take the fire axe from the [name].</span>")
				src.add_fingerprint(user)
				update_icon()
			else
				if(src.smashed)
					return
				else
					localopened = !localopened
					if(localopened)
						src.icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					else
						src.icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()

		else
			localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
			if(localopened)
				src.icon_state = text("fireaxe[][][][]opening",hasaxe,src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()
			else
				src.icon_state = text("fireaxe[][][][]closing",hasaxe,src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()

	attack_tk(mob/user as mob)
		if(localopened && fireaxe)
			fireaxe.forceMove(loc)
			to_chat(user, "<span class='notice'>You telekinetically remove the fire axe.</span>")
			fireaxe = null
			update_icon()
			return
		attack_hand(user)

	verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
		set name = "Open/Close"
		set category = "Object"

		if(isrobot(usr) || src.locked || src.smashed)
			if(src.locked)
				to_chat(usr, "<span class='warning'>The cabinet won't budge!</span>")
			else if(src.smashed)
				to_chat(usr, "<span class='notice'>The protective glass is broken!</span>")
			return

		localopened = !localopened
		update_icon()

	verb/remove_fire_axe()
		set name = "Remove Fire Axe"
		set category = "Object"

		if(isrobot(usr))
			return

		if(localopened)
			if(fireaxe)
				usr.put_in_hands(fireaxe)
				fireaxe = null
				to_chat(usr, "<span class='notice'>You take the Fire axe from the [name].</span>")
			else
				to_chat(usr, "<span class='notice'>The [src.name] is empty.</span>")
		else
			to_chat(usr, "<span class='notice'>The [src.name] is closed.</span>")
		update_icon()

	attack_ai(mob/user as mob)
		if(src.smashed)
			to_chat(user, "<span class='warning'>The security of the cabinet is compromised.</span>")
			return
		else
			locked = !locked
			if(locked)
				to_chat(user, "<span class='warning'>Cabinet locked.</span>")
			else
				to_chat(user, "<span class='notice'>Cabinet unlocked.</span>")

	update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
		var/hasaxe = 0
		if(fireaxe)
			hasaxe = 1
		icon_state = text("fireaxe[][][][]",hasaxe,src.localopened,src.hitstaken,src.smashed)

	open()
		return

	close()
		return