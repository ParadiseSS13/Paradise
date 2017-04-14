/obj/item/weapon/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = 3
	origin_tech = "materials=1"
	slowdown = 7
	breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0
	var/trap_damage = 20
	var/obj/item/weapon/grenade/iedcasing/IED = null
	var/obj/item/device/assembly/signaler/sig = null

/obj/item/weapon/restraints/legcuffs/beartrap/New()
	..()
	icon_state = "[initial(icon_state)][armed]"

/obj/item/weapon/restraints/legcuffs/beartrap/Destroy()
	QDEL_NULL(IED)
	QDEL_NULL(sig)
	return ..()

/obj/item/weapon/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking \his head in the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "[initial(icon_state)][armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")

/obj/item/weapon/restraints/legcuffs/beartrap/attackby(obj/item/I, mob/user) //Let's get explosive.
	if(istype(I, /obj/item/weapon/grenade/iedcasing))
		if(IED)
			to_chat(user, "<span class='warning'>This beartrap already has an IED hooked up to it!</span>")
			return
		if(sig)
			to_chat(user, "<span class='warning'>This beartrap already has a signaler hooked up to it!</span>")
			return
		IED = I
		switch(IED.assembled)
			if(0,1) //if it's not fueled/hooked up
				to_chat(user, "<span class='warning'>You haven't prepared this IED yet!</span>")
				IED = null
				return
			if(2,3)
				user.drop_item()
				I.forceMove(src)
				message_admins("[key_name_admin(user)] has rigged a beartrap with an IED.")
				log_game("[key_name(user)] has rigged a beartrap with an IED.")
				to_chat(user, "<span class='notice'>You sneak the [IED] underneath the pressure plate and connect the trigger wire.</span>")
				desc = "A trap used to catch bears and other legged creatures. <span class='warning'>There is an IED hooked up to it.</span>"
			else
				to_chat(user, "<span class='danger'>You shouldn't be reading this message! Contact a coder or someone, something broke!</span>")
				IED = null
				return
	if(istype(I, /obj/item/device/assembly/signaler))
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
	if(istype(I, /obj/item/weapon/screwdriver))
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

/obj/item/weapon/restraints/legcuffs/beartrap/Crossed(AM as mob|obj)
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
				IED.overlays -= image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
				IED.icon_state = initial(icon_state) + "_active"
				IED.assembled = 3
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
				if(!H.legcuffed) //beartrap can't cuff you leg if there's already a beartrap or legcuffs.
					H.legcuffed = src
					forceMove(H)
					H.update_inv_legcuffed()
					feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.

			else
				L.apply_damage(trap_damage, BRUTE)
	..()

/obj/item/weapon/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0

/obj/item/weapon/restraints/legcuffs/beartrap/energy/New()
	..()
	spawn(100)
		if(!istype(loc, /mob))
			var/datum/effect/system/spark_spread/sparks = new /datum/effect/system/spark_spread
			sparks.set_up(1, 1, src)
			sparks.start()
			qdel(src)

/obj/item/weapon/restraints/legcuffs/beartrap/energy/dropped()
	..()
	qdel(src)

/obj/item/weapon/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk

/obj/item/weapon/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 20 // Cyborgs shouldn't have a strong restraint

/obj/item/weapon/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	breakouttime = 35//easy to apply, easy to break out of
	gender = NEUTER
	origin_tech = "engineering=3;combat=1"
	var/weaken = 0

/obj/item/weapon/restraints/legcuffs/bola/throw_impact(atom/hit_atom)
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort
	var/mob/living/carbon/C = hit_atom
	if(!C.legcuffed)
		visible_message("<span class='danger'>[src] ensnares [C]!</span>")
		C.legcuffed = src
		forceMove(C)
		C.update_inv_legcuffed()
		feedback_add_details("handcuffs","B")
		to_chat(C, "<span class='userdanger'>[src] ensnares you!</span>")
		C.Weaken(weaken)

/obj/item/weapon/restraints/legcuffs/bola/tactical //traitor variant
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = 70
	origin_tech = "engineering=4;combat=3"
	weaken = 1

/obj/item/weapon/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	hitsound = 'sound/weapons/tase.ogg'
	w_class = 2
	breakouttime = 60

/obj/item/weapon/restraints/legcuffs/bola/energy/throw_impact(atom/hit_atom)
	if(iscarbon(hit_atom))
		var/obj/item/weapon/restraints/legcuffs/beartrap/B = new /obj/item/weapon/restraints/legcuffs/beartrap/energy/cyborg(get_turf(hit_atom))
		B.Crossed(hit_atom)
		qdel(src)
	..()