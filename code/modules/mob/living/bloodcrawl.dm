//Travel through pools of blood. Slaughter Demon powers for everyone!
#define BLOODCRAWL     1
#define BLOODCRAWL_EAT 2

/mob/living/proc/phaseout(var/obj/effect/decal/cleanable/B)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(C.l_hand || C.r_hand)
			C << "<span class='warning'>You may not hold items while blood crawling!</span>"
			return 0
		var/obj/item/weapon/bloodcrawl/B1 = new(C)
		var/obj/item/weapon/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()

	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(src.loc)
	var/turf/bloodloc = get_turf(B.loc)
	if(Adjacent(bloodloc))
		src.notransform = TRUE
		spawn(0)
			src.visible_message("<span class='danger'>[src] sinks into [B].</span>")
			playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
			var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "odd blood"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "jaunt"
			animation.layer = 5
			animation.master = holder
			animation.dir = src.dir

			src.ExtinguishMob()
			if(src.buckled)
				src.buckled.unbuckle_mob()
			if(src.pulling && src.bloodcrawl == BLOODCRAWL_EAT)
				if(istype(src.pulling, /mob/living/))
					var/mob/living/victim = src.pulling
					if(victim.stat == CONSCIOUS)
						src.visible_message("<span class='warning'>[victim] kicks free of [B] just before entering it!</span>")
					else
						victim.loc = holder///holder
						victim.emote("scream")
						src.visible_message("<span class='warning'><b>[src] drags [victim] into [B]!</b></span>")
						kidnapped = victim
			flick("jaunt",animation)
			src.loc = holder
			src.holder = holder

			if(kidnapped)
				src << "<B>You begin to feast on [kidnapped]. You can not move while you are doing this.</B>"
				src.visible_message("<span class='warning'><B>Loud eating sounds come from the blood...</B></span>")
				sleep(6)
				if (animation)
					qdel(animation)
				for(var/i = 3; i > 0; i--)
					playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
					sleep(30)
				if (kidnapped)
					src << "<B>You devour [kidnapped]. Your health is fully restored.</B>"
					src.adjustBruteLoss(-1000)
					src.adjustFireLoss(-1000)
					src.adjustOxyLoss(-1000)
					src.adjustToxLoss(-1000)

					if (istype(src, /mob/living/simple_animal/slaughter)) //rason, do not want humans to get this

						var/mob/living/simple_animal/slaughter/demon = src
						demon.devoured++
						kidnapped << "<span class='userdanger'>You feel teeth sink into your flesh, and the--</span>"
						kidnapped.adjustBruteLoss(1000)
						kidnapped.forceMove(src)
						demon.consumed_mobs.Add(kidnapped)
					else
						kidnapped.ghostize()
						qdel(kidnapped)
				else
					src << "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>"
			else
				sleep(6)
				if (animation)
					qdel(animation)
			src.notransform = 0

/obj/item/weapon/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	flags = NODROP

/mob/living/proc/phasein(var/obj/effect/decal/cleanable/B)
	if(src.notransform)
		src << "<span class='warning'>Finish eating first!</span>"
	else
		var/atom/movable/overlay/animation = new /atom/movable/overlay( B.loc )
		animation.name = "odd blood"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "jauntup" //Paradise Port:I reversed the jaunt animation so it looks like its rising up
		animation.layer = 5
		animation.master = B.loc
		animation.dir = src.dir
		B.visible_message("<span class='warning'>[B] starts to bubble...</span>")
		if(!do_after(src, 20, target = B))
			return
		if(!B)
			return
		src.forceMove(B)
		src.client.eye = src
		if (prob(25) && istype(src, /mob/living/simple_animal/slaughter))
			var/list/voice = list('sound/hallucinations/behind_you1.ogg','sound/hallucinations/im_here1.ogg','sound/hallucinations/turn_around1.ogg','sound/hallucinations/i_see_you1.ogg')
			playsound(get_turf(src), pick(voice),50, 1, -1)
		src.visible_message("<span class='warning'><B>\The [src] rises out of \the [B]!</B>")
		playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)
		flick("jauntup",animation)
		qdel(src.holder)
		src.holder = null
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			for(var/obj/item/weapon/bloodcrawl/BC in C)
				C.flags = null
				C.unEquip(BC)
				qdel(BC)
		var/oldcolor = src.color
		src.color = B.color
		sleep(6)//wait for animation to finish
		if(animation)
			qdel(animation)
		spawn(30)
			src.color = oldcolor

/obj/effect/decal/cleanable/blood/CtrlClick(mob/living/user)
	..()
	if(user.bloodcrawl)
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)



/obj/effect/decal/cleanable/trail_holder/CtrlClick(mob/living/user)
	..()
	if(user.bloodcrawl)
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)



/turf/CtrlClick(var/mob/living/user)
	..()
	if(user.bloodcrawl)
		for(var/obj/effect/decal/cleanable/B in src.contents)
			if(istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))
				if(user.holder)
					user.phasein(B)
					break
				else
					user.phaseout(B)
					break

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/effect/dummy/slaughter/relaymove(var/mob/user, direction)
	if (!src.canmove || !direction) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	src.canmove = 0
	spawn(1)
		src.canmove = 1

/obj/effect/dummy/slaughter/ex_act(severity)
	return 1

/obj/effect/dummy/slaughter/bullet_act(blah)
	return

/obj/effect/dummy/slaughter/singularity_act(blah)
	return