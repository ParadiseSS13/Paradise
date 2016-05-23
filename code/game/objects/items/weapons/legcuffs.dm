/obj/item/weapon/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	slowdown = 7
	breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0
	var/obj/item/weapon/grenade/iedcasing/IED = null
	var/obj/item/device/assembly/signaler/sig = null

/obj/item/weapon/restraints/legcuffs/beartrap/Destroy()
	if(IED)
		qdel(IED)
		IED = null
	if(sig)
		qdel(sig)
		sig = null
	return ..()

/obj/item/weapon/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking \his head in the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/restraints/legcuffs/beartrap/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")

/obj/item/weapon/restraints/legcuffs/beartrap/attackby(var/obj/item/I, mob/user as mob) //Let's get explosive.
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
		if( (iscarbon(AM) || isanimal(AM)) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			var/mob/living/L = AM
			armed = 0
			icon_state = "beartrap0"
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
					H.apply_damage(20,BRUTE,"chest")
				else
					H.apply_damage(20,BRUTE,(pick("l_leg", "r_leg")))
				if(!H.legcuffed) //beartrap can't cuff you leg if there's already a beartrap or legcuffs.
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed(0)
					feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.

			else
				L.apply_damage(20,BRUTE)
	..()


/obj/item/weapon/legcuffs/bolas
	name = "bolas"
	desc = "An entangling bolas. Throw at your foes to trip them and prevent them from running."
	gender = NEUTER
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolas"
	slot_flags = SLOT_BELT
	throwforce = 2
	w_class = 2
	origin_tech = "materials=1"
	attack_verb = list("lashed", "bludgeoned", "whipped")
	force = 4
	breakouttime = 50 //10 seconds
	throw_speed = 1
	throw_range = 10
	var/dispenser = 0
	var/throw_sound = 'sound/weapons/whip.ogg'
	var/trip_prob = 60
	var/thrown_from

/obj/item/weapon/legcuffs/bolas/suicide_act(mob/living/user)
		to_chat(viewers(user), "<span class='danger'>[user] is wrapping the [src.name] around \his neck! It looks like \he's trying to commit suicide.</span>")
		return(OXYLOSS)

/obj/item/weapon/legcuffs/bolas/throw_at(var/atom/A, throw_range, throw_speed)
	if(usr && !istype(thrown_from, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas)) //if there is a user, but not a mech
		if(istype(usr, /mob/living/carbon/human)) //if the user is human
			var/mob/living/carbon/human/H = usr
			if((CLUMSY in H.mutations) && prob(50))
				to_chat(H, "<span class='warning'>You smack yourself in the face while swinging the [src]!</span>")
				H.Stun(2)
				H.drop_item(src)
				return
	if (!thrown_from && usr) //if something hasn't set it already (like a mech does when it launches)
		thrown_from = usr //then the user must have thrown it
	if (!istype(thrown_from, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas))
		playsound(src, throw_sound, 20, 1) //because mechs play the sound anyways
	var/turf/target = get_turf(A)
	var/atom/movable/adjtarget = new /atom/movable
	var/xadjust = 0
	var/yadjust = 0
	var/scaler = 0 //used to changed the normalised vector to the proper size
	scaler = throw_range / max(abs(target.x - src.x), abs(target.y - src.y)) //whichever is larger magnitude is what we normalise to
	if (target.x - src.x != 0) //just to avoid fucking with math for no reason
		xadjust = round((target.x - src.x) * scaler) //normalised vector is now scaled up to throw_range
		adjtarget.x = src.x + xadjust //the new target at max range
	else
		adjtarget.x = src.x
	if (target.y - src.y != 0)
		yadjust = round((target.y - src.y) * scaler)
		adjtarget.y = src.y + yadjust
	else
		adjtarget.y = src.y
	// log_admin("Adjusted target of [adjtarget.x] and [adjtarget.y], adjusted with [xadjust] and [yadjust] from [scaler]")
	..(get_turf(adjtarget), throw_range, throw_speed)
	thrown_from = null

/obj/item/weapon/legcuffs/bolas/throw_impact(atom/hit_atom) //Pomf was right, I was wrong - Comic
	if(isliving(hit_atom) && hit_atom != usr) //if the target is a live creature other than the thrower
		var/mob/living/M = hit_atom
		if(ishuman(M)) //if they're a human species
			var/mob/living/carbon/human/H = M
			if(H.legcuffed) //if the target is already legcuffed (has to be walking)
				throw_failed()
				return
			if(prob(trip_prob)) //this probability is up for change and mostly a placeholder - Comic
				step(H, H.dir)
				H.visible_message("<span class='warning'>[H] was tripped by the bolas!</span>","<span class='warning'>Your legs have been tangled!</span>");
				H.Stun(2) //used instead of setting damage in vars to avoid non-human targets being affected
				H.Weaken(4)
				H.legcuffed = src //applies legcuff properties inherited through legcuffs
				src.loc = H
				H.update_inv_legcuffed()
				if(!H.legcuffed) //in case it didn't happen, we need a safety net
					throw_failed()
		else
			M.Stun(2) //minor stun damage to anything not human
			throw_failed()
			return

/obj/item/weapon/legcuffs/bolas/proc/throw_failed() //called when the throw doesn't entangle
	//log_admin("Logged as [thrown_from]")
	if(!thrown_from || !istype(thrown_from, /mob/living)) //in essence, if we don't know whether a person threw it
		qdel(src) //destroy it, to stop infinite bolases

/obj/item/weapon/legcuffs/bolas/Bump()
	..()
	throw_failed() //allows a mech bolas to be destroyed
