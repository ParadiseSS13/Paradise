/obj/item/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	var/base_icon = "stunbaton"
	item_state = "baton"
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	var/stunforce = 7
	var/status = 0
	var/obj/item/stock_parts/cell/high/cell = null
	var/hitcost = 1000
	var/throw_hit_chance = 35

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return FIRELOSS

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/New()
	..()
	update_icon()
	return

/obj/item/melee/baton/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/melee/baton/throw_impact(atom/hit_atom)
	..()
	if(status && prob(throw_hit_chance))
		baton_stun(hit_atom)

/obj/item/melee/baton/loaded/New() //this one starts with a cell pre-installed.
	..()
	cell = new(src)
	update_icon()
	return

/obj/item/melee/baton/proc/deductcharge(var/chrgdeductamt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R.cell && R.cell.charge < (hitcost+chrgdeductamt))
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)
		if(R.cell.use(chrgdeductamt))
			return 1
		else
			return 0
	if(cell)
		if(cell.charge < (hitcost+chrgdeductamt)) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)
		if(cell.use(chrgdeductamt))
			return 1
		else
			return 0

/obj/item/melee/baton/update_icon()
	if(status)
		icon_state = "[base_icon]_active"
	else if(!cell)
		icon_state = "[base_icon]_nocell"
	else
		icon_state = "[base_icon]"

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(isrobot(loc))
		. += "<span class='notice'>This baton is drawing power directly from your own internal charge.</span>"
	if(cell)
		. += "<span class='notice'>The baton is [round(cell.percent())]% charged.</span>"
	if(!cell)
		. += "<span class='warning'>The baton does not have a power source installed.</span>"

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < hitcost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.unEquip(W))
				return
			W.loc = src
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()

	else if(istype(W, /obj/item/screwdriver))
		if(cell)
			cell.update_icon()
			cell.loc = get_turf(src.loc)
			cell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			status = 0
			update_icon()
			return
		..()
	return

/obj/item/melee/baton/attack_self(mob/user)

	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell &&  R.cell.charge >= (hitcost))
			status = !status
			to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
			playsound(loc, "sparks", 75, 1, -1)
		else
			status = 0
			to_chat(user, "<span class='warning'>You do not have enough reserve power to charge the [src]!</span>")
	else if(cell && cell.charge >= hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/living/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(check_martial_counter(H, user))
			return

	if(!isliving(M))
		return

	var/mob/living/L = M

	if(user.a_intent != INTENT_HARM)
		if(status)
			user.do_attack_animation(L)
			baton_stun(L, user)
		else
			L.visible_message("<span class='warning'>[user] has prodded [L] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
			return
	else
		if(status)
			baton_stun(L, user)
		..()


/obj/item/melee/baton/proc/baton_stun(mob/living/L, mob/user)
	if(!ismob(L)) //because this was being called on turfs for some reason
		return

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, 1)
			return

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.shock_internal_organs(33)

	L.Stun(stunforce)
	L.Weaken(stunforce)
	L.apply_effect(STUTTER, stunforce)

	if(user)
		user.lastattacked = L
		L.lastattacker = user
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		add_attack_logs(user, L, "stunned")
	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	deductcharge(hitcost)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)

/obj/item/melee/baton/emp_act(severity)
	if(cell)
		deductcharge(1000 / severity)
	..()

/obj/item/melee/baton/wash(mob/user, atom/source)
	if(cell)
		if(cell.charge > 0 && status == 1)
			flick("baton_active", source)
			user.Stun(stunforce)
			user.Weaken(stunforce)
			user.stuttering = stunforce
			deductcharge(hitcost)
			user.visible_message("<span class='warning'>[user] shocks [user.p_them()]self while attempting to wash the active [src]!</span>", \
								"<span class='userdanger'>You unwisely attempt to wash [src] while it's still on.</span>")
			playsound(src, "sparks", 50, 1)
			return 1
	..()

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	base_icon = "stunprod"
	item_state = "prod"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throwforce = 5
	stunforce = 5
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = null

/obj/item/melee/baton/cattleprod/New()
	..()
	sparkler = new(src)

/obj/item/melee/baton/cattleprod/Destroy()
	QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/cattleprod/baton_stun()
	if(sparkler.activate())
		..()
