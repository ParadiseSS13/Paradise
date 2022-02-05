/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "engineering=3;combat=3"
	slowdown = 7
	breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	origin_tech = "engineering=4"
	var/armed = 0
	var/trap_damage = 20
	var/obj/item/grenade/iedcasing/IED = null
	var/obj/item/assembly/signaler/sig = null

/obj/item/restraints/legcuffs/beartrap/New()
	..()
	icon_state = "[initial(icon_state)][armed]"

/obj/item/restraints/legcuffs/beartrap/Destroy()
	QDEL_NULL(IED)
	QDEL_NULL(sig)
	return ..()

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking [user.p_their()] head in the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "[initial(icon_state)][armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")

/obj/item/restraints/legcuffs/beartrap/attackby(obj/item/I, mob/user) //Let's get explosive.
	if(istype(I, /obj/item/grenade/iedcasing))
		if(IED)
			to_chat(user, "<span class='warning'>This beartrap already has an IED hooked up to it!</span>")
			return
		if(sig)
			to_chat(user, "<span class='warning'>This beartrap already has a signaler hooked up to it!</span>")
			return
		user.drop_item()
		I.forceMove(src)
		message_admins("[key_name_admin(user)] has rigged a beartrap with an IED.")
		log_game("[key_name(user)] has rigged a beartrap with an IED.")
		to_chat(user, "<span class='notice'>You sneak [IED] underneath the pressure plate and connect the trigger wire.</span>")
		desc = "A trap used to catch bears and other legged creatures. <span class='warning'>There is an IED hooked up to it.</span>"
	if(istype(I, /obj/item/assembly/signaler))
		if(IED)
			to_chat(user, "<span class='warning'>This beartrap already has an IED hooked up to it!</span>")
			return
		if(sig)
			to_chat(user, "<span class='warning'>This beartrap already has a signaler hooked up to it!</span>")
			return
		sig = I
		if(sig.secured)
			to_chat(user, "<span class='notice'>The signaler is secured.</span>")
			sig = null
			return
		user.drop_item()
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You sneak the [sig] underneath the pressure plate and connect the trigger wire.</span>")
		desc = "A trap used to catch bears and other legged creatures. <span class='warning'>There is a remote signaler hooked up to it.</span>"
	if(istype(I, /obj/item/screwdriver))
		if(IED)
			IED.forceMove(get_turf(src))
			IED = null
			to_chat(user, "<span class='notice'>You remove the IED from the [src].</span>")
			return
		if(sig)
			sig.forceMove(get_turf(src))
			sig = null
			to_chat(user, "<span class='notice'>You remove the signaler from the [src].</span>")
			return
	..()

/obj/item/restraints/legcuffs/beartrap/Crossed(AM as mob|obj, oldloc)
	if(armed && isturf(src.loc))
		if( (iscarbon(AM) || isanimal(AM)) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/hostile/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			var/mob/living/L = AM
			armed = 0
			icon_state = "[initial(icon_state)][armed]"
			playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
			L.visible_message("<span class='danger'>[L] triggers \the [src].</span>", \
					"<span class='userdanger'>You trigger \the [src]!</span>")

			if(IED && isturf(src.loc))
				IED.active = 1
				message_admins("[key_name_admin(usr)] has triggered an IED-rigged [name].")
				log_game("[key_name(usr)] has triggered an IED-rigged [name].")
				spawn(IED.det_time)
					IED.prime()

			if(sig && isturf(src.loc))
				sig.signal()

			if(ishuman(AM))
				var/mob/living/carbon/H = AM
				if(H.lying)
					H.apply_damage(trap_damage, BRUTE,"chest")
				else
					H.apply_damage(trap_damage, BRUTE,(pick("l_leg", "r_leg")))
				if(!H.legcuffed && H.get_num_legs() >= 2) //beartrap can't cuff you leg if there's already a beartrap or legcuffs.
					H.legcuffed = src
					forceMove(H)
					H.update_inv_legcuffed()
					SSblackbox.record_feedback("tally", "handcuffs", 1, type)

			else
				L.apply_damage(trap_damage, BRUTE)
	..()

/obj/item/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0
	flags = DROPDEL

/obj/item/restraints/legcuffs/beartrap/energy/New()
	..()
	addtimer(CALLBACK(src, .proc/dissipate), 100)

/obj/item/restraints/legcuffs/beartrap/energy/proc/dissipate()
	if(!ismob(loc))
		do_sparks(1, 1, src)
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk

/obj/item/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 40 // Cyborgs shouldn't have a strong restraint

/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	breakouttime = 60//easy to apply, easy to break out of
	gender = NEUTER
	origin_tech = "engineering=3;combat=1"
	hitsound = 'sound/effects/snap.ogg'
	var/weaken = 0
	throw_speed = 4

/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	playsound(loc,'sound/weapons/bolathrow.ogg', 50, TRUE)
	if(!..())
		return

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom)
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort
	var/mob/living/carbon/C = hit_atom
	if(!C.legcuffed && C.get_num_legs() >= 2)
		visible_message("<span class='danger'>[src] ensnares [C]!</span>")
		C.legcuffed = src
		forceMove(C)
		C.update_inv_legcuffed()
		SSblackbox.record_feedback("tally", "handcuffs", 1, type)
		to_chat(C, "<span class='userdanger'>[src] ensnares you!</span>")
		C.Weaken(weaken)
		playsound(loc, hitsound, 50, TRUE)

/obj/item/restraints/legcuffs/bola/tactical //traitor variant
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = 100
	origin_tech = "engineering=4;combat=3"
	weaken = 1

/obj/item/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	hitsound = 'sound/weapons/tase.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 40

/obj/item/restraints/legcuffs/bola/energy/throw_impact(atom/hit_atom)
	if(iscarbon(hit_atom))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy/cyborg(get_turf(hit_atom))
		B.Crossed(hit_atom, null)
		qdel(src)
	..()
