/obj/structure/girder
	name = "girder"
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = BELOW_OBJ_LAYER
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
			playsound(src.loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>Now disassembling the girder</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!src) return
				to_chat(user, "<span class='notice'>You dissasembled the girder!</span>")
				refundMetal(metalUsed)
				qdel(src)
		else if(!anchored)
			playsound(src.loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>Now securing the girder</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				to_chat(user, "<span class='notice'>You secured the girder!</span>")
				new/obj/structure/girder( src.loc )
				qdel(src)

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>Now slicing apart the girder</span>")
		if(do_after(user, 30 * W.toolspeed, target = src))
			if(!src) return
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You slice apart the girder!</span>")
			refundMetal(metalUsed)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamonddrill))
		to_chat(user, "<span class='notice'>You drill through the girder!</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		playsound(src.loc, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>You Disintegrate the girder!</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		playsound(src.loc, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>Now unsecuring support struts</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src) return
			to_chat(user, "<span class='notice'>You unsecured the support struts!</span>")
			state = 1

	else if(istype(W, /obj/item/weapon/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		playsound(src.loc, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>Now removing support struts</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src) return
			to_chat(user, "<span class='notice'>You removed the support struts!</span>")
			new/obj/structure/girder( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
		playsound(src.loc, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>Now dislodging the girder</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src) return
			to_chat(user, "<span class='notice'>You dislodged the girder!</span>")
			new/obj/structure/girder/displaced( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet))

		var/obj/item/stack/sheet/S = W
		switch(S.type)

			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(!anchored)
					if(S.amount < 2) return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a false wall! Push on it to open or close the passage.</span>")
					new /obj/structure/falsewall (src.loc)
					qdel(src)
				else
					if(S.amount < 2) return ..()
					to_chat(user, "<span class='notice'>Now adding plating...</span>")
					if(do_after(user, 40 * W.toolspeed, target = src))
						if(!src || !S || S.amount < 2) return
						S.use(2)
						to_chat(user, "<span class='notice'>You added the plating!</span>")
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
					to_chat(user, "<span class='notice'>You create a false wall! Push on it to open or close the passage.</span>")
					new /obj/structure/falsewall/reinforced (src.loc)
					qdel(src)
				else
					if(src.icon_state == "reinforced") //I cant believe someone would actually write this line of code...
						if(S.amount < 1) return ..()
						to_chat(user, "<span class='notice'>Now finalising reinforced wall.</span>")
						if(do_after(user, 50, target = src))
							if(!src || !S || S.amount < 1) return
							S.use(1)
							to_chat(user, "<span class='notice'>Wall fully reinforced!</span>")
							var/turf/Tsrc = get_turf(src)
							Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
							for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							qdel(src)
						return
					else
						if(S.amount < 1) return ..()
						to_chat(user, "<span class='notice'>Now reinforcing girders</span>")
						if(do_after(user,60, target = src))
							if(!src || !S || S.amount < 1) return
							S.use(1)
							to_chat(user, "<span class='notice'>Girders reinforced!</span>")
							new/obj/structure/girder/reinforced( src.loc )
							qdel(src)
						return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				if(S.amount < 2) return
				S.use(2)
				to_chat(user, "<span class='notice'>You create a false wall! Push on it to open or close the passage.</span>")
				var/F = text2path("/obj/structure/falsewall/[M]")
				new F (src.loc)
				qdel(src)
			else
				if(S.amount < 2) return ..()
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(do_after(user,40, target = src))
					if(!src || !S || S.amount < 2) return
					S.use(2)
					to_chat(user, "<span class='notice'>You added the plating!</span>")
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
			to_chat(user, "<span class='notice'>You fit the pipe into the [src]!</span>")
	else
		..()

/obj/structure/girder/blob_act()
	if(prob(40))
		qdel(src)

/obj/structure/girder/narsie_act()
	if(prob(25))
		new /obj/structure/girder/cult(loc)
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
	name = "displaced girder"
	icon_state = "displaced"
	anchored = 0
	health = 50

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
	state = 2
	health = 500

/obj/structure/girder/cult
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It doesn't seem to have any bolts."
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	metalUsed = 1
	health = 250

/obj/structure/girder/cult/refundMetal(metalAmount)
	for(var/i=0;i < metalAmount;i++)
		new /obj/item/stack/sheet/runed_metal(get_turf(src))

/obj/structure/girder/cult/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/tome) && iscultist(user)) //Cultists can demolish cult girders instantly with their tomes
		user.visible_message("<span class='warning'>[user] strikes [src] with [W]!</span>", "<span class='notice'>You demolish [src].</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			playsound(loc, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You start slicing apart the girder...</span>")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(!WT.isOn())
					return
				to_chat(user, "<span class='notice'>You slice apart the girder.</span>")
				var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
				R.amount = 1
				transfer_fingerprints_to(R)
				qdel(src)

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You start slicing apart the girder...</span>")
		if(do_after(user, 40* W.toolspeed, target = src))
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You slice apart the girder.</span>")
			var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
			R.amount = 1
			transfer_fingerprints_to(R)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		to_chat(user, "<span class='notice'>Your jackhammer smashes through the girder!</span>")
		var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
		R.amount = 1
		transfer_fingerprints_to(R)
		D.playDigSound()
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/runed_metal))
		var/obj/item/stack/sheet/runed_metal/R = W
		if(R.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need at least one sheet of runed metal to construct a runed wall!</span>")
			return 0
		user.visible_message("<span class='notice'>[user] begins laying runed metal on [src]...</span>", "<span class='notice'>You begin constructing a runed wall...</span>")
		if(do_after(user, 50, target = src))
			if(R.get_amount() < 1 || !R)
				return
			user.visible_message("<span class='notice'>[user] plates [src] with runed metal.</span>", "<span class='notice'>You construct a runed wall.</span>")
			R.use(1)
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/simulated/wall/cult)
			qdel(src)

/obj/structure/girder/cult/take_damage(amount)
	health -= amount
	if(health <= 0)
		new /obj/item/stack/sheet/runed_metal(get_turf(src))
		qdel(src)

/obj/structure/girder/cult/narsie_act()
	return
