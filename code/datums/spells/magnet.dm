/obj/effect/proc_holder/spell/targeted/magnet
	name = "Magnetic Pull"
	desc = "Pulls metalic objects from enemies hands with the power of MAGNETS."
	charge_type = "recharge"
	charge_max	= 300
	clothes_req = 0
	invocation = "UN'LTD P'WAH!"
	invocation_type = "none"
	range = 7
	cooldown_min = 30
	selection_type = "view"
	random_target = 1
	var/energy = 0
	var/ready = 0
	var/image/halo = null
	action_icon_state = "tech"


/obj/effect/proc_holder/spell/targeted/magnet/Click()
	if(!ready)
		if(cast_check())
			StartChargeup()
	else
		if(cast_check(skipcharge=1))
			choose_targets()
	return 1

/obj/effect/proc_holder/spell/targeted/magnet/proc/StartChargeup(mob/user = usr)
	ready = 1
	user << "<span class='notice'>You start gathering the power.</span>"
	halo = image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = EFFECTS_LAYER)
	user.overlays.Add(halo)
	spawn(0)
		while(ready)
			sleep(1)
			energy++
			if(energy >= 100 && ready)
				Discharge()

obj/effect/proc_holder/spell/targeted/magnet/proc/Reset(mob/user = usr)
	ready = 0
	energy = 0
	if(halo)
		user.overlays.Remove(halo)

/obj/effect/proc_holder/spell/targeted/magnet/revert_cast(mob/user = usr)
	user << "<span class='notice'>No target found in range.</span>"
	Reset(user)
	..()

/obj/effect/proc_holder/spell/targeted/magnet/proc/Discharge(mob/user = usr)
	var/mob/living/M = user
	//M.electrocute_act(25,"magnet Bolt")
	M << "<span class='danger'>You lose control over the power.</span>"
	Reset(user)
	start_recharge()


/obj/effect/proc_holder/spell/targeted/magnet/cast(list/targets, mob/user = usr)

	var/mob/living/carbon/target = targets[1]

	if(get_dist(user,target)>range)
		user << "<span class='notice'>They are too far away!</span>"
		Reset(user)
		return

	user.Beam(target,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)

	switch(energy)
		if(0 to 25)
			if(prob(50))
				for(var/obj/item/I in target.l_hand)
					if(I.flags & CONDUCT)
						I.throw_at(user, I.throw_range, 4, target)
			else
				for(var/obj/item/I in target.r_hand)
					if(I.flags & CONDUCT)
						I.throw_at(user, I.throw_range, 4, target)
			playsound(get_turf(target), 'sound/machines/defib_zap.ogg', 50, 1, -1)
		if(25 to 75)
			for(var/obj/item/I in target.l_hand)
				if(I.flags & CONDUCT)
					I.throw_at(user, I.throw_range, 4, target)
			for(var/obj/item/I in target.r_hand)
				if(I.flags & CONDUCT)
					I.throw_at(user, I.throw_range, 4, target)
			playsound(get_turf(target), 'sound/machines/defib_zap.ogg', 50, 1, -1)
		if(75 to 100)
			//CHAIN magnet
			Bolt(user,target,energy,user)
	Reset(user)

/obj/effect/proc_holder/spell/targeted/magnet/proc/Bolt(mob/origin,mob/target,bolt_energy,mob/user = usr)
	origin.Beam(target,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
	var/mob/living/carbon/current = target
	if(bolt_energy < 75)
		for(var/obj/item/I in target.l_hand)
			if(I.flags & CONDUCT)
				I.throw_at(user, I.throw_range, 4, target)
		for(var/obj/item/I in target.r_hand)
			if(I.flags & CONDUCT)
				I.throw_at(user, I.throw_range, 4, target)
		playsound(get_turf(current), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	else
		for(var/obj/item/I in target.l_hand)
			if(I.flags & CONDUCT)
				I.throw_at(user, I.throw_range, 4, target)
		for(var/obj/item/I in target.r_hand)
			if(I.flags & CONDUCT)
				I.throw_at(user, I.throw_range, 4, target)
		playsound(get_turf(current), 'sound/machines/defib_zap.ogg', 50, 1, -1)
		var/list/possible_targets = new
		for(var/mob/living/M in view_or_range(range,target,"view"))
			if(user == M || target == M && los_check(current,M)) // || origin == M ? Not sure double shockings is good or not
				continue
			possible_targets += M
		if(!possible_targets.len)
			return
		var/mob/living/next = pick(possible_targets)
		if(next)
			Bolt(current,next,bolt_energy-6,user) // 5 max bounces