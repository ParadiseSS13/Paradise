/obj/item/weapon/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	var/stunforce = 10
	var/status = 0
	var/mob/foundmob = "" //Used in throwing proc.
	var/obj/item/weapon/cell/high/bcell = 0
	var/hitcost = 1500

	origin_tech = "combat=2"

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is putting the live [name] in \his mouth! It looks like \he's trying to commit suicide.</span>"
		return (FIRELOSS)

/obj/item/weapon/melee/baton/loaded/New()
	..()
	bcell = new(src)
	update_icon()
	return

/obj/item/weapon/melee/baton/CheckParts()
	bcell = locate(/obj/item/weapon/cell) in contents
	update_icon()

/obj/item/weapon/melee/baton/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.rigged)
			bcell.explode()//exploding baton of justice
			update_icon()
			return
		else
			bcell.charge -= max(chrgdeductamt,0)
			if(bcell.charge < hitcost)
				status = 0
				update_icon()

/obj/item/weapon/melee/baton/examine()
	set src in view(1)
	..()
	if(bcell)
		usr <<"<span class='notice'>The baton is [round(bcell.percent())]% charged.</span>"
	if(!bcell)
		usr <<"<span class='warning'>The baton does not have a power source installed.</span>"

/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!bcell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/weapon/melee/baton/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(!bcell)
			user.drop_item()
			W.loc = src
			bcell = W
			user << "<span class='notice'>You install a cell in [src].</span>"
			update_icon()
		else
			user << "<span class='notice'>[src] already has a cell.</span>"

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			user << "<span class='notice'>You remove the cell from the [src].</span>"
			status = 0
			update_icon()
			return
		..()
	return

/obj/item/weapon/melee/baton/attack_self(mob/user)
	if(status && (M_CLUMSY in user.mutations) && prob(50))
		user << "\red You grab the [src] on the wrong side."
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return
	if(bcell && bcell.charge)
		if(bcell.charge < hitcost)
			status = 0
			user << "<span class='warning'>[src] is out of charge.</span>"
		else
			status = !status
			user << "<span class='notice'>[src] is now [status ? "on" : "off"].</span>"
			playsound(loc, "sparks", 75, 1, -1)
			update_icon()
	else
		status = 0
		if(!bcell)
			user << "<span class='warning'>[src] does not have a power source!</span>"
		else
			user << "<span class='warning'>[src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/M, mob/user)
	if(status && (M_CLUMSY in user.mutations) && prob(50))
		user << "span class='danger'>You accidentally hit yourself with the [src]!</span>"
		user.Weaken(30)
		deductcharge(hitcost)
		return


	if(isrobot(M))
		..()
		return

	var/mob/living/carbon/human/H = M

	if(user.a_intent == "hurt")
		if(!..()) return
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Beat [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Beaten by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[user.name] ([user.ckey]) beat [H.name] ([H.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		playsound(src.loc, "swing_hit", 50, 1, -1)

	else if(!status)
		H.visible_message("<span class='warning'>[H] has been prodded with [src] by [user]. Luckily it was off.</span>")
		return

	var/stunroll = (rand(1,100))

	if(status)
		user.lastattacked = H
		H.lastattacker = user
		if(user == H) // Attacking yourself can't miss
			stunroll = 100
		if(stunroll < 40)
			H.visible_message("\red <B>[user] misses [H] with \the [src]!")
			msg_admin_attack("[key_name(user)] attempted to stun [key_name(H)] with the [src].")
			return
		H.Stun(stunforce)
		H.Weaken(stunforce)
		H.apply_effect(STUTTER, stunforce)

		H.visible_message("<span class='danger'>[H] has been stunned with [src] by [user]!</span>")
		playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

		msg_admin_attack("[key_name(user)] stunned [key_name(H)] with the [src].")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [src.name]</font>"

		if(isrobot(loc))
			var/mob/living/silicon/robot/R = loc
			if(R && R.cell)
				R.cell.use(hitcost)
		else
			deductcharge(hitcost)


		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [L.name] ([L.ckey]) with [name]</font>"
		L.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [name]</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) stunned [L.name] ([L.ckey]) with [name]</font>" )

		if(!iscarbon(user))
			L.LAssailant = null
		else
			L.LAssailant = user

		if(bcell.charge < hitcost)
			status = 0
			update_icon()

	add_fingerprint(user)

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom)
	. = ..()
	if (prob(50))
		if(istype(hit_atom, /mob/living))
			var/mob/living/carbon/human/H = hit_atom
			if(status)
				H.Stun(stunforce)
				H.Weaken(stunforce)
				H.apply_effect(STUTTER, stunforce)

				deductcharge(hitcost)

				if(bcell.charge < hitcost)
					status = 0
					update_icon()


				for(var/mob/M in player_list) if(M.key == src.fingerprintslast)
					foundmob = M
					break

				H.visible_message("<span class='danger'>[src], thrown by [foundmob.name], strikes [H] and stuns them!</span>")

				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
				log_attack("Flying [src.name], last touched by ([src.fingerprintslast]) stunned [H.name] ([H.ckey])" )

				if(!iscarbon(foundmob))
					H.LAssailant = null
				else
					H.LAssailant = foundmob

/obj/item/weapon/melee/baton/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
		if(bcell.reliability != 100 && prob(50/severity))
			bcell.reliability -= 10 / severity
	..()


/obj/item/weapon/melee/baton/loaded/ntcane
	name = "fancy cane"
	desc = "A cane with special engraving on it. It has a strange button on the handle..."
	icon_state = "cane_nt"
	item_state = "cane_nt"

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/weapon/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	item_state = "prod"
	force = 3
	throwforce = 5
	stunforce = 5
	hitcost = 2500
	slot_flags = null

/obj/item/weapon/melee/baton/cattleprod/update_icon()
	if(status)
		icon_state = "stunprod_active"
	else if(!bcell)
		icon_state = "stunprod_nocell"
	else
		icon_state = "stunprod"
