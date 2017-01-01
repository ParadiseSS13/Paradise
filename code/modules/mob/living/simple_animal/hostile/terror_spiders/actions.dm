

/datum/action/innate/terrorspider/web
	name = "Web"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "stickyweb1"

/datum/action/innate/terrorspider/web/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.Web()

/datum/action/innate/terrorspider/wrap
	name = "Wrap"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon_large1"

/datum/action/innate/terrorspider/wrap/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.FindWrapTarget()
	user.DoWrap()


// ---------- WEB

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Web()
	visible_message("<span class='notice'>[src] begins to secrete a sticky substance.</span>")
	if(do_after(src, 40, target = loc))
		var/obj/effect/spider/terrorweb/T = locate() in get_turf(src)
		if(T)
			to_chat(src, "<span class='danger'>There is already a web here.</span>")
		else
			new /obj/effect/spider/terrorweb(loc)

/obj/effect/spider/terrorweb
	name = "terror web"
	desc = "it's stringy and sticky"
	icon = 'icons/effects/effects.dmi'
	anchored = 1 // prevents people dragging it
	density = 0 // prevents it blocking all movement
	health = 20 // two welders, or one laser shot (15 for the normal spider webs)
	icon_state = "stickyweb1"


/obj/effect/spider/terrorweb/New()
	..()
	if(prob(50))
		icon_state = "stickyweb2"


/obj/effect/spider/terrorweb/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/poison/terror_spider))
		return 1
	if(isliving(mover))
		if(prob(80))
			to_chat(mover, "<span class='danger'>You get stuck in [src] for a moment.</span>")
			var/mob/living/M = mover
			M.Stun(4) // 8 seconds.
			M.Weaken(4) // 8 seconds.
			return 1
		else
			return 0
	if(istype(mover, /obj/item/projectile))
		return prob(20)
	return ..()




// ---------- WRAP


/mob/living/simple_animal/hostile/poison/terror_spider/proc/FindWrapTarget()
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in oview(1,src))
			if(Adjacent(L))
				if(L.stat == DEAD)
					choices += L
		for(var/obj/O in oview(1,src))
			if(Adjacent(O) && !O.anchored)
				if(!istype(O, /obj/effect/spider/terrorweb) && !istype(O, /obj/effect/spider/cocoon))
					choices += O
		if(choices.len)
			cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
		else
			to_chat(src, "<span class='danger'>There is nothing nearby you can wrap.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoWrap()
	if(cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		if(do_after(src, 40, target = cocoon_target.loc))
			if(busy == SPINNING_COCOON)
				if(cocoon_target && isturf(cocoon_target.loc) && get_dist(src,cocoon_target) <= 1)
					var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/O in C.loc)
						if(istype(O, /obj/item))
							O.loc = C
						else if(istype(O, /obj/machinery) || istype(O, /obj/structure))
							O.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/terror_spider))
							continue
						if(L.stat != DEAD)
							continue
						if(iscarbon(L))
							regen_points += regen_points_per_kill
							fed++
						large_cocoon = 1
						last_cocoon_object = 0
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						visible_message("<span class='danger'>[src] sticks a proboscis into [L] and sucks a viscous substance out.</span>")
						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		cocoon_target = null
		busy = 0
		stop_automated_movement = 0

