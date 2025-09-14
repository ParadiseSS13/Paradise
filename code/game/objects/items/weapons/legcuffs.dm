/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon_state = "handcuff"
	cuffed_state = "legcuff"
	flags = CONDUCT
	origin_tech = "engineering=3;combat=3"
	slowdown = 7
	breakouttime = 30 SECONDS

/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	origin_tech = "engineering=4"
	breakouttime = 20 SECONDS
	var/armed = FALSE
	var/trap_damage = 20
	///Do we want the beartrap not to make a visable message on arm? Use when a beartrap is applied by something else.
	var/silent_arming = FALSE
	var/obj/item/grenade/iedcasing/IED = null
	var/obj/item/assembly/signaler/sig = null

/obj/item/restraints/legcuffs/beartrap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/restraints/legcuffs/beartrap/update_icon_state()
	icon_state = "beartrap[armed]"

/obj/item/restraints/legcuffs/beartrap/Destroy()
	QDEL_NULL(IED)
	QDEL_NULL(sig)
	return ..()

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sticking [user.p_their()] head in [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/restraints/legcuffs/beartrap/attack_self__legacy__attackchain(mob/user)
	..()

	if(!ishuman(user) || user.restrained())
		return

	if(do_after(user, 2 SECONDS, target = user))
		armed = !armed
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>")

/obj/item/restraints/legcuffs/beartrap/attackby__legacy__attackchain(obj/item/I, mob/user) //Let's get explosive.
	if(istype(I, /obj/item/grenade/iedcasing))
		if(IED)
			to_chat(user, "<span class='warning'>This beartrap already has an IED hooked up to it!</span>")
			return
		if(sig)
			to_chat(user, "<span class='warning'>This beartrap already has a signaler hooked up to it!</span>")
			return
		user.drop_item()
		I.forceMove(src)
		IED = I
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
			to_chat(user, "<span class='warning'>The signaler is secured.</span>")
			sig = null
			return
		user.drop_item()
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You sneak [sig] underneath the pressure plate and connect the trigger wire.</span>")
		desc = "A trap used to catch bears and other legged creatures. <span class='warning'>There is a remote signaler hooked up to it.</span>"
	..()

/obj/item/restraints/legcuffs/beartrap/screwdriver_act(mob/living/user, obj/item/I)
	if(!IED && !sig)
		return

	if(IED)
		IED.forceMove(get_turf(src))
		IED = null
		to_chat(user, "<span class='notice'>You remove the IED from [src].</span>")
	if(sig)
		sig.forceMove(get_turf(src))
		sig = null
		to_chat(user, "<span class='notice'>You remove the signaler from [src].</span>")
	return TRUE

/obj/item/restraints/legcuffs/beartrap/proc/on_atom_entered(datum/source, mob/living/entered)
	if(!armed || !isturf(loc) || !istype(entered))
		return

	if((iscarbon(entered) || isanimal_or_basicmob(entered)) && !HAS_TRAIT(entered, TRAIT_FLYING))
		spring_trap(entered)

		if(ishuman(entered))
			var/mob/living/carbon/H = entered
			if(IS_HORIZONTAL(H))
				H.apply_damage(trap_damage, BRUTE, "chest")
			else
				H.apply_damage(trap_damage, BRUTE, pick("l_leg", "r_leg"))
			if(!H.legcuffed && H.get_num_legs() >= 2) //beartrap can't cuff you leg if there's already a beartrap or legcuffs.
				H.legcuffed = src
				forceMove(H)
				H.update_inv_legcuffed()
				SSblackbox.record_feedback("tally", "handcuffs", 1, type)
		else
			if(istype(entered, /mob/living/basic/bear))
				entered.apply_damage(trap_damage * 2.5, BRUTE)
			else
				entered.apply_damage(trap_damage * 1.75, BRUTE)

/obj/item/restraints/legcuffs/beartrap/on_found(mob/finder)
	if(!armed)
		return FALSE
	spring_trap(finder)

	if(ishuman(finder))
		var/mob/living/carbon/H = finder
		H.apply_damage(trap_damage, BRUTE, pick("l_hand", "r_hand"))
	return TRUE

/obj/item/restraints/legcuffs/beartrap/proc/spring_trap(mob/user)
	armed = FALSE
	update_icon()
	playsound(loc, 'sound/effects/snap.ogg', 50, TRUE)
	if(!silent_arming)
		user.visible_message("<span class='danger'>[user] triggers [src].</span>", "<span class='userdanger'>You trigger [src].</span>")

	if(sig)
		sig.signal()

	if(IED)
		IED.active = TRUE
		message_admins("[key_name_admin(usr)] has triggered an IED-rigged [name].")
		log_game("[key_name(usr)] has triggered an IED-rigged [name].")
		spawn(IED.det_time)
			IED.prime()

/obj/item/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = TRUE
	icon_state = "e_snare1"
	trap_damage = 0
	flags = DROPDEL
	breakouttime = 6 SECONDS

/obj/item/restraints/legcuffs/beartrap/energy/New()
	..()
	addtimer(CALLBACK(src, PROC_REF(dissipate)), 100)

/obj/item/restraints/legcuffs/beartrap/energy/proc/dissipate()
	if(!ismob(loc))
		do_sparks(1, 1, src)
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk

/obj/item/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 20 // Cyborgs shouldn't have a strong restraint

/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon_state = "bola"
	breakouttime = 3.5 SECONDS
	gender = NEUTER
	origin_tech = "engineering=3;combat=1"
	hitsound = 'sound/effects/snap.ogg'
	throw_range = 0 // increased when throw mode is enabled
	/// is the bola reuseable?
	var/reuseable = TRUE
	///the duration of the knockdown in seconds
	var/knockdown_duration = 0
	/// the number of spins till the bola gets the maximum throw distance. each spin takes 1 second
	var/max_spins = 3
	/// the max range after the bola fully spins up. if your value for this isn't divisable by the value of `max_spins` it will be lower than the max
	var/max_range = 7
	/// the max speed after the bola fully spins up. if your value for this isn't divisable by the value of `max_spins` it will be lower than the max
	var/max_speed = 2
	/// are we currently spinning the bola
	var/spinning = FALSE

/obj/item/restraints/legcuffs/bola/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CARBON_TOGGLE_THROW, PROC_REF(spin_up_wrapper))

/obj/item/restraints/legcuffs/bola/proc/spin_up_wrapper(datum/source, throw_mode_state) // so that signal handler works
	SIGNAL_HANDLER
	if(throw_mode_state) // if we actually turned throw mode on
		INVOKE_ASYNC(src, PROC_REF(spin_up))

/obj/item/restraints/legcuffs/bola/proc/spin_up()
	if(spinning)
		return
	var/mob/living/L = loc // can only be called if the mob is holding the bola.
	var/range_increment = round(max_range / max_spins)
	var/speed_increment = round(max_speed / max_spins)
	RegisterSignal(L, COMSIG_CARBON_SWAP_HANDS, PROC_REF(reset_values), override = TRUE)
	inhand_icon_state = "[initial(icon_state)]_spin"
	L.update_inv_r_hand()
	L.update_inv_l_hand()
	spinning = TRUE
	for(var/i in 1 to max_spins)
		if(!do_mob(L, L, 1 SECONDS, only_use_extra_checks = TRUE, extra_checks = list(CALLBACK(src, PROC_REF(can_spin_check), L)), hidden = TRUE))
			reset_values(L)
			break
		throw_range += range_increment
		throw_speed += speed_increment

/obj/item/restraints/legcuffs/bola/end_throw()
	reset_values()

/obj/item/restraints/legcuffs/bola/equipped(mob/user, slot, initial) // switching hands with it or putting it into/out of a bag resets it.
	. = ..()
	reset_values()

/obj/item/restraints/legcuffs/bola/proc/reset_values(mob/living/user)
	throw_range = initial(throw_range)
	throw_speed = initial(throw_speed)
	inhand_icon_state = initial(inhand_icon_state)
	spinning = FALSE
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()

/// if it returns TRUE, it breaks the loop, returning FALSE, continues the loop
/obj/item/restraints/legcuffs/bola/proc/can_spin_check(mob/living/user)
	if(user.get_active_hand() != src)
		return TRUE
	if(!user.in_throw_mode)
		return TRUE
	return FALSE

/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	playsound(loc,'sound/weapons/bolathrow.ogg', 50, TRUE)
	if(!..())
		return

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom)
	reset_values()
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort
	var/mob/living/carbon/C = hit_atom
	if(!C.legcuffed && C.get_num_legs() >= 2 && !IS_HORIZONTAL(C))
		visible_message("<span class='danger'>[src] ensnares [C]!</span>")
		C.legcuffed = src
		forceMove(C)
		C.update_inv_legcuffed()
		SSblackbox.record_feedback("tally", "handcuffs", 1, type)
		to_chat(C, "<span class='userdanger'>[src] ensnares you!</span>")
		C.KnockDown(knockdown_duration)
		playsound(loc, hitsound, 50, TRUE)
		if(!reuseable)
			flags |= DROPDEL

/// traitor variant
/obj/item/restraints/legcuffs/bola/tactical
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = 7 SECONDS
	origin_tech = "engineering=4;combat=3"
	knockdown_duration = 2 SECONDS

/// For Security
/obj/item/restraints/legcuffs/bola/energy
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	hitsound = 'sound/weapons/tase.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 4 SECONDS
	reuseable = FALSE
