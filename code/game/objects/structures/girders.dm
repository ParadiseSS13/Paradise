/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = TURF_LAYER + 0.9
	var/state = 0
	var/health = 200
	var/metalUsed = 2 //used to determine amount returned in deconstruction

/obj/structure/girder/proc/refundMetal(metalAmount) //refunds metal used in construction when deconstructed
	for(var/i=0;i < metalAmount;i++)
		new /obj/item/stack/sheet/metal(get_turf(src))

/obj/structure/girder/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.environment_smash >= 1)
		if(M.environment_smash == 3)
			ex_act(2)
			M.visible_message("<span class='warning'>[M] smashes through \the [src].</span>", "<span class='warning'>You smash through \the [src].</span>")
		else
			M.visible_message("<span class='warning'>[M] smashes against \the [src].</span>", "<span class='warning'>You smash against \the [src].</span>")
			take_damage(rand(25, 75))
			return

/obj/structure/girder/proc/take_damage(var/amount)
	health -= amount
	if(health <= 0)
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench) && state == 0)
		if(anchored && !istype(src,/obj/structure/girder/displaced))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			to_chat(user, "\blue Now disassembling the girder")
			if(do_after(user,40, target = src))
				if(!src) return
				to_chat(user, "\blue You dissasembled the girder!")
				refundMetal(metalUsed)
				qdel(src)
		else if(!anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			to_chat(user, "\blue Now securing the girder")
			if(do_after(user, 40, target = src))
				to_chat(user, "\blue You secured the girder!")
				new/obj/structure/girder( src.loc )
				qdel(src)

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		to_chat(user, "\blue Now slicing apart the girder")
		if(do_after(user,30, target = src))
			if(!src) return
			to_chat(user, "\blue You slice apart the girder!")
			refundMetal(metalUsed)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamonddrill))
		to_chat(user, "\blue You drill through the girder!")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		playsound(src.loc, 'sound/weapons/sonic_jackhammer.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You Disintegrate the girder!</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		to_chat(user, "\blue Now unsecuring support struts")
		if(do_after(user,40, target = src))
			if(!src) return
			to_chat(user, "\blue You unsecured the support struts!")
			state = 1

	else if(istype(W, /obj/item/weapon/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		to_chat(user, "\blue Now removing support struts")
		if(do_after(user,40, target = src))
			if(!src) return
			to_chat(user, "\blue You removed the support struts!")
			new/obj/structure/girder( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		to_chat(user, "\blue Now dislodging the girder")
		if(do_after(user, 40, target = src))
			if(!src) return
			to_chat(user, "\blue You dislodged the girder!")
			new/obj/structure/girder/displaced( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet))

		var/obj/item/stack/sheet/S = W
		switch(S.type)

			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(!anchored)
					if(S.amount < 2) return
					S.use(2)
					to_chat(user, "\blue You create a false wall! Push on it to open or close the passage.")
					new /obj/structure/falsewall (src.loc)
					qdel(src)
				else
					if(S.amount < 2) return ..()
					to_chat(user, "\blue Now adding plating...")
					if(do_after(user,40, target = src))
						if(!src || !S || S.amount < 2) return
						S.use(2)
						to_chat(user, "\blue You added the plating!")
						var/turf/Tsrc = get_turf(src)
						Tsrc.ChangeTurf(/turf/simulated/wall)
						for(var/turf/simulated/wall/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						qdel(src)
					return

			if(/obj/item/stack/sheet/plasteel)
				if(!anchored)
					if(S.amount < 2) return
					S.use(2)
					to_chat(user, "\blue You create a false wall! Push on it to open or close the passage.")
					new /obj/structure/falsewall/reinforced (src.loc)
					qdel(src)
				else
					if(src.icon_state == "reinforced") //I cant believe someone would actually write this line of code...
						if(S.amount < 1) return ..()
						to_chat(user, "\blue Now finalising reinforced wall.")
						if(do_after(user, 50, target = src))
							if(!src || !S || S.amount < 1) return
							S.use(1)
							to_chat(user, "\blue Wall fully reinforced!")
							var/turf/Tsrc = get_turf(src)
							Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
							for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							qdel(src)
						return
					else
						if(S.amount < 1) return ..()
						to_chat(user, "\blue Now reinforcing girders")
						if(do_after(user,60, target = src))
							if(!src || !S || S.amount < 1) return
							S.use(1)
							to_chat(user, "\blue Girders reinforced!")
							new/obj/structure/girder/reinforced( src.loc )
							qdel(src)
						return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				if(S.amount < 2) return
				S.use(2)
				to_chat(user, "\blue You create a false wall! Push on it to open or close the passage.")
				var/F = text2path("/obj/structure/falsewall/[M]")
				new F (src.loc)
				qdel(src)
			else
				if(S.amount < 2) return ..()
				to_chat(user, "\blue Now adding plating...")
				if(do_after(user,40, target = src))
					if(!src || !S || S.amount < 2) return
					S.use(2)
					to_chat(user, "\blue You added the plating!")
					var/turf/Tsrc = get_turf(src)
					Tsrc.ChangeTurf(text2path("/turf/simulated/wall/mineral/[M]"))
					for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
						if(X)	X.add_hiddenprint(usr)
					qdel(src)
				return

		add_hiddenprint(usr)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			user.drop_item()
			P.loc = src.loc
			to_chat(user, "\blue You fit the pipe into the [src]!")
	else
		..()

/obj/structure/girder/blob_act()
	if(prob(40))
		qdel(src)

/obj/structure/girder/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/pulse))
		src.ex_act(2)
	else
		take_damage(Proj.damage)
	..()
	return 0

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(75))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)
			return
		if(3.0)
			if(prob(40))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)
			return
		else
	return

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0
	health = 50

/obj/structure/girder/reinforced
	icon_state = "reinforced"
	state = 2
	health = 500

/obj/structure/cultgirder
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	layer = 2
	var/health = 250

/obj/structure/cultgirder/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		to_chat(user, "\blue Now disassembling the girder")
		if(do_after(user,40, target = src))
			to_chat(user, "\blue You dissasembled the girder!")
			dismantle()

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		to_chat(user, "\blue Now slicing apart the girder")
		if(do_after(user,30, target = src))
			to_chat(user, "\blue You slice apart the girder!")
			dismantle()

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamonddrill))
		to_chat(user, "\blue You drill through the girder!")
		dismantle()

/obj/structure/cultgirder/proc/dismantle()
	new /obj/effect/decal/remains/human(get_turf(src))
	qdel(src)

/obj/structure/cultgirder/blob_act()
	if(prob(40))
		dismantle()

/obj/structure/cultgirder/bullet_act(var/obj/item/projectile/Proj) //No beam check- How else will you destroy the cult girder with silver bullets?????
	health -= Proj.damage
	..()
	if(health <= 0)
		dismantle()
	return

/obj/structure/cultgirder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(30))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
		if(3.0)
			if(prob(5))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
		else
	return