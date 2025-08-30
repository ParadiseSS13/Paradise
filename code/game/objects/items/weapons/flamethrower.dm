/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	inhand_icon_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	materials = list(MAT_METAL = 5000)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	var/status = FALSE
	var/lit = FALSE	//on or off
	var/operating = FALSE//cooldown
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/internals/plasma/ptank = null
	var/warned_admins = FALSE //for the message_admins() when lit
	//variables for prebuilt flamethrowers
	var/create_full = FALSE
	var/create_with_tank = FALSE
	var/igniter_type = /obj/item/assembly/igniter

/obj/item/flamethrower/Destroy()
	QDEL_NULL(weldtool)
	QDEL_NULL(igniter)
	QDEL_NULL(ptank)
	return ..()

/obj/item/flamethrower/process()
	if(!lit || !igniter)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		if(M.is_holding(src))
			location = M.loc
	if(isturf(location)) //start a fire if possible
		igniter.flamethrower_process(location)

/obj/item/flamethrower/update_icon_state()
	inhand_icon_state = "flamethrower_[lit]"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/flamethrower/update_overlays()
	. = ..()
	if(igniter)
		. += "+igniter[status]"
	if(ptank)
		. += "+ptank"
	if(lit)
		. += "+lit"

/obj/item/flamethrower/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	else
		return TRUE

/obj/item/flamethrower/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(!cigarette_lighter_act(user, target))
		return ..()

/obj/item/flamethrower/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!lit)
		to_chat(user, "<span class='warning'>You need to ignite [src] before you can use it as a lighter!</span>")
		return TRUE

	// Pulling this off 'safely' requires years of experience, a true badass, or blind luck!
	if(HAS_TRAIT(user, TRAIT_BADASS) || (user.mind.assigned_role in list("Station Engineer", "Chief Engineer", "Life Support Specialist")) || prob(50))
		if(user == target)
			user.visible_message(
				"<span class='warning'>[user] confidently lifts up [src] and releases a big puff of flame at [user.p_their()] [cig] to light it, like some kind of psychopath!</span>",
				"<span class='notice'>You lift up [src] and lightly pull the trigger, lighting [cig].</span>",
				"<span class='warning'>You hear a brief burst of flame!</span>"
			)
		else
			user.visible_message(
				"<span class='warning'>[user] confidently lifts up [src] and releases a big puff of flame at [target], lighting [target.p_their()] [cig.name], like some kind of psychopath!</span>",
				"<span class='notice'>You lift up [src] and point it at [target], lightly pullling the trigger to light [target.p_their()] [cig.name] with a big puff of flame.</span>",
				"<span class='warning'>You hear a brief burst of flame!</span>"
		)
	else
		// You set them on fire, but at least the cigarette got lit...
		if(target == user)
			user.visible_message(
				"<span class='danger'>[user] carelessly lifts up [src] and releases a large burst of flame at [user.p_their()] [cig] to light it, accidentally setting [user.p_themselves()] ablaze in the process!</span>",
				"<span class='userdanger'>You lift up [src] and squeeze the trigger to light [cig]. Unfortunately, you squeeze a little too hard and release a large burst of flame that sets you ablaze!</span>",
				"<span class='danger'>You hear a plume of fire and something igniting!</span>"
			)
		else
			user.visible_message(
				"<span class='danger'>[user] carelessly lifts up [src] and releases a large burst of flame at [target] to light [target.p_their()] [cig.name], accidentally setting [target.p_them()] ablaze!</span>",
				"<span class='danger'>You lift up [src] up and point it at [target], squeezing the trigger to light [target.p_their()] [cig.name]. \
				Unfortunately, your squeeze a little too hard and release large burst of flame that sets [target.p_them()] ablaze!</span>",
				"<span class='danger'>You hear a plume of fire and something igniting!</span>"
			)
		target.adjust_fire_stacks(2)
		target.IgniteMob()
	cig.light(user, target)
	return TRUE

/obj/item/flamethrower/afterattack__legacy__attackchain(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	if(!user)
		return
	if(user.mind?.martial_art?.no_guns)
		to_chat(user, "<span class='warning'>[user.mind.martial_art.no_guns_message]</span>")
		return
	if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS))
		to_chat(user, "<span class='warning'>Your meaty finger is far too large for the trigger guard!</span>")
		return
	if(user.get_active_hand() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = get_line(user, target_turf)
			add_attack_logs(user, target, "Flamethrowered at [target.x],[target.y],[target.z]")
			flame_turf(turflist)

/obj/item/flamethrower/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(isigniter(I))
		var/obj/item/assembly/igniter/IG = I
		if(IG.secured)
			return
		if(igniter)
			return
		if(!user.drop_item())
			return
		IG.forceMove(src)
		igniter = IG
		update_icon()
		return

	else if(istype(I, /obj/item/tank/internals/plasma))
		if(ptank)
			if(user.drop_item())
				I.forceMove(src)
				ptank.forceMove(get_turf(src))
				ptank = I
				to_chat(user, "<span class='notice'>You swap the plasma tank in [src]!</span>")
			return
		if(!user.drop_item())
			return
		I.forceMove(src)
		ptank = I
		update_icon()
		return

	else
		return ..()

/obj/item/flamethrower/wrench_act(mob/user, obj/item/I)
	if(status)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/turf/T = get_turf(src)
	if(weldtool)
		weldtool.forceMove(T)
		weldtool = null
	if(igniter)
		igniter.forceMove(T)
		igniter = null
	if(ptank)
		ptank.forceMove(T)
		ptank = null
	new /obj/item/stack/rods(T)
	qdel(src)

/obj/item/flamethrower/screwdriver_act(mob/user, obj/item/I)
	if(!igniter || lit)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	status = !status
	to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
	update_icon()

/obj/item/flamethrower/return_analyzable_air()
	if(ptank)
		return ptank.return_analyzable_air()
	return null

/obj/item/flamethrower/attack_self__legacy__attackchain(mob/user)
	toggle_igniter(user)

/obj/item/flamethrower/AltClick(mob/user)
	if(ptank && isliving(user) && user.Adjacent(src))
		user.put_in_hands(ptank)
		ptank = null
		to_chat(user, "<span class='notice'>You remove the plasma tank from [src]!</span>")
		update_icon()

/obj/item/flamethrower/examine(mob/user)
	. = ..()
	if(ptank)
		. += "<span class='notice'>[src] has \a [ptank] attached. Alt-click to remove it.</span>"

/obj/item/flamethrower/proc/toggle_igniter(mob/user)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	if(!status)
		to_chat(user, "<span class='notice'>Secure the igniter first!</span>")
		return
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	lit = !lit
	if(lit)
		damtype = BURN
		START_PROCESSING(SSobj, src)
		if(!warned_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] has lit a flamethrower.")
			warned_admins = TRUE
	else
		damtype = initial(damtype)
		STOP_PROCESSING(SSobj,src)
	update_icon()

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	igniter.secured = FALSE
	status = TRUE
	update_icon()

//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return
	operating = TRUE
	var/turf/previousturf = get_turf(src)
	for(var/turf/simulated/T in turflist)
		if(T.blocks_air)
			break
		if(T == previousturf)
			continue	//so we don't burn the tile we be standin on
		if(!T.CanAtmosPass(get_dir(T, previousturf)) || !previousturf.CanAtmosPass(get_dir(previousturf, T)))
			break
		if(igniter)
			igniter.ignite_turf(src, T)
		else
			default_ignite(T)
		sleep(1)
		previousturf = T
	operating = FALSE
	for(var/mob/M in viewers(1, loc))
		if(M.client && M.machine == src)
			attack_self__legacy__attackchain(M)

/obj/item/flamethrower/proc/default_ignite(turf/target, release_amount = 0.05)
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(release_amount)
	target.blind_release_air(air_transfer)
	target.hotspot_expose(PLASMA_UPPER_TEMPERATURE, min(CELL_VOLUME, CELL_VOLUME * air_transfer.total_moles()))

/obj/item/flamethrower/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		if(!igniter)
			igniter = new igniter_type(src)
		igniter.secured = FALSE
		status = TRUE
		if(create_with_tank)
			ptank = new /obj/item/tank/internals/plasma/full(src)
		update_icon()

/obj/item/flamethrower/full
	create_full = TRUE

/obj/item/flamethrower/full/tank
	create_with_tank = TRUE

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
		var/turf/target_turf = get_turf(owner)
		log_game("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]")
		igniter.ignite_turf(src,target_turf, release_amount = 100)
		QDEL_NULL(ptank)
		return 1 //It hit the flamethrower, not them

/obj/item/assembly/igniter/proc/flamethrower_process(turf/simulated/location)
	location.hotspot_expose(700, 2)

/obj/item/assembly/igniter/proc/ignite_turf(obj/item/flamethrower/F, turf/simulated/location, release_amount = 0.05)
	F.default_ignite(location, release_amount)
