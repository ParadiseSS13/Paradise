//Travel through pools of blood. Slaughter Demon powers for everyone!
#define BLOODCRAWL     1
#define BLOODCRAWL_EAT 2

/mob/living/proc/phaseout(var/obj/effect/decal/cleanable/B)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(C.l_hand || C.r_hand)
			to_chat(C, "<span class='warning'>You may not hold items while blood crawling!</span>")
			return 0
		var/obj/item/bloodcrawl/B1 = new(C)
		var/obj/item/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()

	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(loc)
	notransform = TRUE
	spawn(0)
		visible_message("<span class='danger'>[src] sinks into [B].</span>")
		playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
		var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(mobloc)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(mobloc)
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
		flick("jaunt",animation)
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
				sound = 'sound/misc/demon_consume.ogg'

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

/obj/item/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	flags = NODROP|ABSTRACT

/mob/living/proc/phasein(var/obj/effect/decal/cleanable/B)

	if(notransform)
		to_chat(src, "<span class='warning'>Finish eating first!</span>")
		return 0
	B.visible_message("<span class='warning'>[B] starts to bubble...</span>")
	if(!do_after(src, 20, target = B))
		return
	if(!B)
		return
	forceMove(B.loc)
	client.eye = src

	var/atom/movable/overlay/animation = new /atom/movable/overlay( B.loc )
	animation.name = "odd blood"
	animation.density = 0
	animation.anchored = 1
	animation.icon = 'icons/mob/mob.dmi'
	animation.icon_state = "jauntup" //Paradise Port:I reversed the jaunt animation so it looks like its rising up
	animation.layer = 5
	animation.master = B.loc
	animation.dir = dir

	if(prob(25) && istype(src, /mob/living/simple_animal/slaughter))
		var/list/voice = list('sound/hallucinations/behind_you1.ogg','sound/hallucinations/im_here1.ogg','sound/hallucinations/turn_around1.ogg','sound/hallucinations/i_see_you1.ogg')
		playsound(get_turf(src), pick(voice),50, 1, -1)
	visible_message("<span class='warning'><B>\The [src] rises out of \the [B]!</B>")
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)

	flick("jauntup",animation)
	QDEL_NULL(holder)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/bloodcrawl/BC in C)
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
