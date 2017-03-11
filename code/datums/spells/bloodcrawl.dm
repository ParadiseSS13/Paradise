/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	charge_max = 0
	clothes_req = 0
	selection_type = "range"
	range = 1
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	panel = "Demon"
	var/phased = 0

/obj/effect/proc_holder/spell/bloodcrawl/choose_targets(mob/user = usr)
	for(var/obj/effect/decal/cleanable/target in range(range, get_turf(user)))
		if(target.can_bloodcrawl_in())
			perform(target, user = user)
			return
	revert_cast()
	to_chat(user, "<span class='warning'>There must be a nearby source of blood!</span>")

/obj/effect/proc_holder/spell/bloodcrawl/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(phased)
			if(user.phasein(target))
				phased = 0
		else
			if(user.phaseout(target))
				phased = 1
		start_recharge()
		return
	revert_cast()
	to_chat(user, "<span class='warning'>You are unable to blood crawl!</span>")


//Travel through pools of blood. Slaughter Demon powers for everyone!
#define BLOODCRAWL     1
#define BLOODCRAWL_EAT 2

/mob/living/proc/phaseout(var/obj/effect/decal/cleanable/B)

	var/mob/living/carbon/C = src
	var/clown = 0
	if (istype(C.l_hand,/obj/item/weapon/twohanded/chainsaw/honkmother) || istype(C.r_hand,/obj/item/weapon/twohanded/chainsaw/honkmother))
		clown = 1

	if(iscarbon(src) && clown == 0)
		if(C.l_hand || C.r_hand)
			to_chat(C, "<span class='warning'>You may not hold items while blood crawling!</span>")
			return 0
		var/obj/item/weapon/bloodcrawl/B1 = new(C)
		var/obj/item/weapon/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()

	if(clown == 1)
		if(!do_after(src, 20, target = B))
			return

	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(loc)
	notransform = TRUE
	spawn(0)
		visible_message("<span class='danger'>[src] sinks into [B].</span>")
		playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
		var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(mobloc)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(mobloc)
		if(clown == 1)
			animation.name = "odd blood"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "melt"
			animation.layer = 5
			animation.master = holder
			animation.dir = dir
		else
			animation.name = "odd blood"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "jaunt"
			animation.layer = 5
			animation.master = holder
			animation.dir = dir

		ExtinguishMob()
		if(buckled)
			buckled.unbuckle_mob()
		if(pulling && bloodcrawl == BLOODCRAWL_EAT)
			if(istype(pulling, /mob/living/))
				var/mob/living/victim = pulling
				if(victim.stat == CONSCIOUS)
					visible_message("<span class='warning'>[victim] kicks free of [B] just before entering it!</span>")
					stop_pulling()
				else
					victim.forceMove(holder)//holder
					victim.emote("scream")
					visible_message("<span class='warning'><b>[src] drags [victim] into [B]!</b></span>")
					kidnapped = victim
					stop_pulling()

		loc = holder
		holder = holder

		if(kidnapped)
			to_chat(src, "<B>You begin to feast on [kidnapped]. You can not move while you are doing this.</B>")
			visible_message("<span class='warning'><B>Loud eating sounds come from the blood...</B></span>")
			sleep(6)
			if(animation)
				qdel(animation)
			var/sound
			if(istype(src, /mob/living/simple_animal/slaughter))
				var/mob/living/simple_animal/slaughter/SD = src
				sound = SD.feast_sound
			else
				sound = 'sound/misc/Demon_consume.ogg'

			for(var/i in 1 to 3)
				playsound(get_turf(src), sound, 100, 1)
				sleep(30)
			if(kidnapped)
				to_chat(src, "<B>You devour [kidnapped]. Your health is fully restored.</B>")
				adjustBruteLoss(-1000)
				adjustFireLoss(-1000)
				adjustOxyLoss(-1000)
				adjustToxLoss(-1000)

				if(istype(src, /mob/living/simple_animal/slaughter)) //rason, do not want humans to get this

					var/mob/living/simple_animal/slaughter/demon = src
					demon.devoured++
					to_chat(kidnapped, "<span class='userdanger'>You feel teeth sink into your flesh, and the--</span>")
					kidnapped.adjustBruteLoss(1000)
					kidnapped.forceMove(src)
					demon.consumed_mobs.Add(kidnapped)
				else
					kidnapped.ghostize()
					qdel(kidnapped)
			else
				to_chat(src, "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>")
		else
			sleep(6)
			if(animation)
				qdel(animation)
		notransform = 0
	return 1

/obj/item/weapon/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	flags = NODROP|ABSTRACT

/mob/living/proc/phasein(var/obj/effect/decal/cleanable/B)

	var/mob/living/carbon/C = src
	var/clown = 0
	if (istype(C.l_hand,/obj/item/weapon/twohanded/chainsaw/honkmother) || istype(C.r_hand,/obj/item/weapon/twohanded/chainsaw/honkmother))
		clown = 1

	if(notransform)
		to_chat(src, "<span class='warning'>Finish eating first!</span>")
		return 0
	B.visible_message("<span class='warning'>[B] starts to bubble...</span>")
	if(!do_after(src, 20, target = B))
		return
	if(!B)
		return
	client.eye = src

	var/atom/movable/overlay/animation = new /atom/movable/overlay( B.loc )
	if(clown == 1)
		animation.name = "odd blood"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "meltup" //Paradise Port:I reversed the jaunt animation so it looks like its rising up
		animation.layer = 5
		animation.master = B.loc
		animation.dir = dir
		sleep(12)
	else
		animation.name = "odd blood"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "jauntup" //Paradise Port:I reversed the jaunt animation so it looks like its rising up
		animation.layer = 5
		animation.master = B.loc
		animation.dir = dir
		sleep(6)

	forceMove(B.loc)

	if(prob(25) && istype(src, /mob/living/simple_animal/slaughter))
		var/list/voice = list('sound/hallucinations/behind_you1.ogg','sound/hallucinations/im_here1.ogg','sound/hallucinations/turn_around1.ogg','sound/hallucinations/i_see_you1.ogg')
		playsound(get_turf(src), pick(voice),50, 1, -1)
	visible_message("<span class='warning'><B>\The [src] rises out of \the [B]!</B>")
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)

	qdel(holder)
	holder = null

	if(iscarbon(src))
		for(var/obj/item/weapon/bloodcrawl/BC in C)
			C.flags = null
			C.unEquip(BC)
			qdel(BC)

	var/oldcolor = color
	color = B.color
	sleep(6)//wait for animation to finish
	if(animation)
		qdel(animation)
	spawn(30)
		color = oldcolor
	return 1

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1
	invisibility = 60
	burn_state = LAVA_PROOF

/obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	forceMove(get_step(src,direction))

/obj/effect/dummy/slaughter/ex_act()
	return

/obj/effect/dummy/slaughter/bullet_act()
	return

/obj/effect/dummy/slaughter/singularity_act()
	return
