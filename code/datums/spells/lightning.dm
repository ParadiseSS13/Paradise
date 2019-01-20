/obj/effect/proc_holder/spell/targeted/lightning
	name = "Lightning Bolt"
	desc = "Throws a lightning bolt at the nearby enemy. Classic."
	charge_type = "recharge"
	charge_max	= 300
	clothes_req = 1
	invocation = "UN'LTD P'WAH!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30
	selection_type = "view"
	random_target = 1
	special_availability_check = 1
	var/start_time = 0
	var/ready = 0
	var/image/halo = null
	action_icon_state = "lightning"
	var/sound/Snd // so far only way i can think of to stop a sound, thank MSO for the idea.
	var/damaging = TRUE

/obj/effect/proc_holder/spell/targeted/lightning/lightnian
	clothes_req = 0
	invocation_type = "none"
	damaging = 0

/obj/effect/proc_holder/spell/targeted/lightning/Click()
	if(!ready && start_time == 0)
		if(cast_check())
			StartChargeup()
	else
		if(ready && cast_check(skipcharge=1))
			choose_targets()
	return 1

/obj/effect/proc_holder/spell/targeted/lightning/proc/StartChargeup(mob/user = usr)
	ready = 1
	to_chat(user, "<span class='notice'>You start gathering the power.</span>")
	Snd = new/sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	halo = image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = EFFECTS_LAYER)
	user.overlays.Add(halo)
	playsound(get_turf(user), Snd, 50, 0)
	start_time = world.time
	if(do_mob(user, user, 100, uninterruptible=1))
		if(ready)
			Discharge()

obj/effect/proc_holder/spell/targeted/lightning/proc/Reset(mob/user = usr)
	ready = 0
	start_time = 0
	if(halo)
		user.overlays.Remove(halo)

/obj/effect/proc_holder/spell/targeted/lightning/revert_cast(mob/user = usr)
	to_chat(user, "<span class='notice'>No target found in range.</span>")
	Reset(user)
	..()

/obj/effect/proc_holder/spell/targeted/lightning/proc/Discharge(mob/user = usr)
	var/mob/living/M = user
	to_chat(M, "<span class='danger'>You lose control over the spell.</span>")
	Reset(user)
	start_recharge()


/obj/effect/proc_holder/spell/targeted/lightning/cast(list/targets, mob/user = usr)
	ready = 0
	var/mob/living/target = targets[1]
	Snd = sound(null, repeat = 0, wait = 1, channel = Snd.channel) //byond, why you suck?
	playsound(get_turf(user), Snd, 50, 0)// Sorry MrPerson, but the other ways just didn't do it the way i needed to work, this is the only way.
	if(get_dist(user,target)>range)
		to_chat(user, "<span class='notice'>They are too far away!</span>")
		Reset(user)
		return

	playsound(get_turf(user), 'sound/magic/lightningbolt.ogg', 50, 1)
	user.Beam(target,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5)

	var/energy = min(world.time - start_time,100)
	if(damaging)
		Bolt(user,target,max(15,energy/2),5,user) //5 bounces for energy/2 burn
	else
		var/bounces = round(energy/20)
		Bolt(user,target,0,bounces,user)
	Reset(user)

/obj/effect/proc_holder/spell/targeted/lightning/proc/Bolt(mob/origin, mob/living/target, bolt_energy, bounces, mob/user = usr)
	origin.Beam(target,icon_state="lightning[rand(1,12)]", icon='icons/effects/effects.dmi', time=5)
	var/mob/living/current = target
	if(bounces < 1)
		if(damaging)
			current.electrocute_act(bolt_energy,"Lightning Bolt",safety=1)
		else
			current.AdjustJitter(1000) //High numbers for violent convulsions
			current.do_jitter_animation(current.jitteriness)
			current.AdjustStuttering(2)
			current.Slowed(3)
			spawn(20)
				current.AdjustJitter(-1000, bound_lower = 10) //Still jittery, but vastly less
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 50, 1, -1)
	else
		if(damaging)
			current.electrocute_act(bolt_energy,"Lightning Bolt",safety=1)
		else
			current.AdjustJitter(1000) //High numbers for violent convulsions
			current.do_jitter_animation(current.jitteriness)
			current.AdjustStuttering(2)
			current.Slowed(3)
			spawn(20)
				current.AdjustJitter(-1000, bound_lower = 10) //Still jittery, but vastly less
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 50, 1, -1)
		var/list/possible_targets = new
		for(var/mob/living/M in view_or_range(range,target,"view"))
			if(user == M || target == M && los_check(current,M)) // || origin == M ? Not sure double shockings is good or not
				continue
			possible_targets += M
		if(!possible_targets.len)
			return
		var/mob/living/next = pick(possible_targets)
		if(next)
			Bolt(current,next,bolt_energy,bounces-1,user) // 5 max bounces