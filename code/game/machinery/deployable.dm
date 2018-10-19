/*
CONTAINS:

Deployable items
Barricades

for reference:

	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_genetics = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	access_court = 42
	access_clown = 43
	access_mime = 44

*/


//Barricades, maybe there will be a metal one later...
/obj/structure/barricade
	anchored = 1.0
	density = 1.0
	var/health = 100.0
	var/maxhealth = 100.0
	var/stacktype = /obj/item/stack/sheet/metal

/obj/structure/barricade/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, stacktype))
		if(src.health < src.maxhealth)
			visible_message("<span class='warning'>[user] begins to repair the [src]!</span>")
			if(do_after(user, 20 * W.toolspeed, target = src))
				src.health = src.maxhealth
				W:use(1)
				visible_message("<span class='warning'>[user] repairs the [src]!</span>")
				return
		else
			return
		return
	else if(istype(W, /obj/item/crowbar))
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='notice'>[user] is prying apart \the [src].</span>", "<span class='notice'>You begin to pry apart \the [src].</span>")
		playsound(src, W.usesound, 200, 1)

		if(do_after(user, 300 * W.toolspeed, target = src) && !QDELETED(src))
			user.visible_message("<span class='notice'>[user] pries apart \the [src].</span>", "<span class='notice'>You pry apart \the [src].</span>")
			dismantle()
		return
	else
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 1
			if("brute")
				src.health -= W.force * 0.75
			else
		if(src.health <= 0)
			visible_message("<span class='danger'>\The [src] is smashed apart!</span>")
			dismantle()
		..()

/obj/structure/barricade/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>\The [src] is blown apart!</span>")
			qdel(src)
			return
		if(2.0)
			src.health -= 25
			if(src.health <= 0)
				visible_message("<span class='danger'>\The [src] is blown apart!</span>")
				dismantle()
			return

/obj/structure/barricade/blob_act()
	src.health -= 25
	if(src.health <= 0)
		visible_message("<span class='danger'>The blob eats through \the [src]!</span>")
		qdel(src)
	return

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/barricade/proc/dismantle()
	if(stacktype)
		new stacktype(get_turf(src))
		new stacktype(get_turf(src))
		new stacktype(get_turf(src))
	qdel(src)

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	stacktype = /obj/item/stack/sheet/wood
	burn_state = FLAMMABLE
	burntime = 25

/obj/structure/barricade/mime
	name = "floor"
	desc = "Is... this a floor?"
	icon = 'icons/effects/water.dmi'
	icon_state = "wet_floor_static"
	stacktype = /obj/item/stack/sheet/mineral/tranquillite

/obj/structure/barricade/mime/mrcd
	stacktype = null

//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 100.0
	var/maxhealth = 100.0
	var/locked = 0.0
//	req_access = list(access_maint_tunnels)

/obj/machinery/deployable/barrier/New()
	..()

	src.icon_state = "barrier[src.locked]"

/obj/machinery/deployable/barrier/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/card/id))
		if(src.allowed(user))
			if(src.emagged < 2.0)
				src.locked = !src.locked
				src.anchored = !src.anchored
				src.icon_state = "barrier[src.locked]"
				if((src.locked == 1.0) && (src.emagged < 2.0))
					to_chat(user, "Barrier lock toggled on.")
					return
				else if((src.locked == 0.0) && (src.emagged < 2.0))
					to_chat(user, "Barrier lock toggled off.")
					return
			else
				do_sparks(2, 1, src)
				visible_message("<span class='warning'>BZZzZZzZZzZT</span>")
				return
		return
	else if(istype(W, /obj/item/wrench))
		if(src.health < src.maxhealth)
			src.health = src.maxhealth
			src.emagged = 0
			src.req_access = list(access_security)
			visible_message("<span class='warning'>[user] repairs the [src]!</span>")
			return
		else if(src.emagged > 0)
			src.emagged = 0
			src.req_access = list(access_security)
			visible_message("<span class='warning'>[user] repairs the [src]!</span>")
			return
		return
	else
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 0.75
			if("brute")
				src.health -= W.force * 0.5
			else
		if(src.health <= 0)
			src.explode()
		..()

/obj/machinery/deployable/barrier/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		req_access = null
		to_chat(user, "You break the ID authentication lock on the [src].")
		do_sparks(2, 1, src)
		visible_message("<span class='warning'>BZZzZZzZZzZT</span>")
	else if(src.emagged == 1)
		src.emagged = 2
		to_chat(user, "You short out the anchoring mechanism on the [src].")
		do_sparks(2, 1, src)
		visible_message("<span class='warning'>BZZzZZzZZzZT</span>")

/obj/machinery/deployable/barrier/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= 25
			if(src.health <= 0)
				src.explode()
			return

/obj/machinery/deployable/barrier/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(prob(50/severity))
		locked = !locked
		anchored = !anchored
		icon_state = "barrier[src.locked]"

/obj/machinery/deployable/barrier/blob_act()
	src.health -= 25
	if(src.health <= 0)
		src.explode()
	return

/obj/machinery/deployable/barrier/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/deployable/barrier/proc/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

/*	var/obj/item/stack/rods/ =*/
	new /obj/item/stack/rods(Tsec)

	do_sparks(3, 1, src)

	explosion(src.loc,-1,-1,0)
	if(src)
		qdel(src)
