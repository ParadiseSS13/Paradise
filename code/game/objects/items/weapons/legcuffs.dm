/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	var/breakouttime = 300	//Deciseconds = 30s = 0.5 minute

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
		viewers(user) << "<span class='danger'>[user] is wrapping the [src.name] around \his neck! It looks like \he's trying to commit suicide.</span>"
		return(OXYLOSS)

/obj/item/weapon/legcuffs/bolas/throw_at(var/atom/A, throw_range, throw_speed)
	if(usr && !istype(thrown_from, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas)) //if there is a user, but not a mech
		if(istype(usr, /mob/living/carbon/human)) //if the user is human
			var/mob/living/carbon/human/H = usr
			if((CLUMSY in H.mutations) && prob(50))
				H <<"<span class='warning'>You smack yourself in the face while swinging the [src]!</span>"
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