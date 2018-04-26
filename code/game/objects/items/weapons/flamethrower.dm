/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=500)
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	var/status = 0
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/plasma/ptank = null


/obj/item/flamethrower/Destroy()
	QDEL_NULL(weldtool)
	QDEL_NULL(igniter)
	QDEL_NULL(ptank)
	previousturf = null
	return ..()


/obj/item/flamethrower/process()
	if(!lit)
		processing_objects.Remove(src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	return


/obj/item/flamethrower/update_icon()
	overlays.Cut()
	if(igniter)
		overlays += "+igniter[status]"
	if(ptank)
		overlays += "+ptank"
	if(lit)
		overlays += "+lit"
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/flamethrower/afterattack(atom/target, mob/user, flag)
	if(flag) return // too close
	// Make sure our user is still holding us
	if(user && user.is_in_active_hand(src))
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			add_attack_logs(user, target, "Flamethrowered at [target.x],[target.y],[target.z]")
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/W as obj, mob/user as mob, params)
	if(user.stat || user.restrained() || user.lying)	return
	if(iswrench(W) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.loc = T
			weldtool = null
		if(igniter)
			igniter.loc = T
			igniter = null
		if(ptank)
			ptank.loc = T
			ptank = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	if(isscrewdriver(W) && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	if(isigniter(W))
		var/obj/item/assembly/igniter/I = W
		if(I.secured)	return
		if(igniter)		return
		user.drop_item()
		I.loc = src
		igniter = I
		update_icon()
		return

	if(istype(W,/obj/item/tank/plasma))
		if(ptank)
			to_chat(user, "<span class='notice'>There appears to already be a plasma tank loaded in [src]!</span>")
			return
		user.drop_item()
		ptank = W
		W.loc = src
		update_icon()
		return

	if(istype(W, /obj/item/analyzer) && ptank)
		atmosanalyzer_scan(ptank.air_contents, user)
	..()
	return


/obj/item/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=[UID()];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\n<A HREF='?src=[UID()];remove=1'>Remove plasmatank</A> - <A HREF='?src=[UID()];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return


/obj/item/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(!status)	return
		lit = !lit
		if(lit)
			processing_objects.Add(src)
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	return

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	weldtool.status = 0
	igniter.secured = 0
	status = 1
	update_icon()

//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)	return
	operating = 1
	var/turf/previousturf = get_turf(src)
	for(var/turf/simulated/T in turflist)
		if(!T.air)
			break
		if(T == previousturf)
			continue	//so we don't burn the tile we be standin on
		if(!T.CanAtmosPass(previousturf))
			break
		ignite_turf(T)
		sleep(1)
		previousturf = T
	operating = 0
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/flamethrower/proc/ignite_turf(turf/target, release_amount = 0.05)
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(release_amount)
	air_transfer.toxins = air_transfer.toxins // This is me not comprehending the air system. I realize this is retarded and I could probably make it work without fucking it up like this, but there you have it. -- TLE
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	//location.hotspot_expose(1000,500,1)
	SSair.add_to_active(target, 0)
	return


/obj/item/flamethrower/full/New(var/loc)
	..()
	if(!weldtool)
		weldtool = new /obj/item/weldingtool(src)
	weldtool.status = 0
	if(!igniter)
		igniter = new /obj/item/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()

/obj/item/flamethrower/full/tank/New(var/loc)
	..()
	ptank = new /obj/item/tank/plasma/full(src)
	update_icon()

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(ptank && damage && attack_type == PROJECTILE_ATTACK && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
		var/target_turf = get_turf(owner)
		ignite_turf(target_turf, 100)
		qdel(ptank)
		return 1 //It hit the flamethrower, not them
