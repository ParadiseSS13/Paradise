/**********************Lazarus Injector**********************/
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	origin_tech = "biotech=4;magnets=6"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it

/obj/item/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, "<span class='info'>[src] does not work on this sort of creature.</span>")
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive()
				M.can_collar = 1
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = 1
						H.friends += user
						H.attack_same = 1
						log_game("[user] has revived hostile mob [target] with a malfunctioning lazarus injector")
					else
						H.attack_same = 0
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, "<span class='info'>[src] is only effective on the dead.</span>")
				return
		else
			to_chat(user, "<span class='info'>[src] is only effective on lesser beings.</span>")
			return

/obj/item/lazarus_injector/emag_act(mob/user)
	if(!malfunctioning)
		malfunctioning = 1
		to_chat(user, "<span class='notice'>You override [src]'s safety protocols.</span>")

/obj/item/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/lazarus_injector/examine(mob/user)
	..(user)
	if(!loaded)
		to_chat(user, "<span class='info'>[src] is empty.</span>")
	if(malfunctioning)
		to_chat(user, "<span class='info'>The display on [src] seems to be flickering.</span>")

/*********************Mob Capsule*************************/

/obj/item/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 20
	var/mob/living/simple_animal/captured = null
	var/colorindex = 0

/obj/item/mobcapsule/Destroy()
	if(captured)
		captured.ghostize()
		QDEL_NULL(captured)
	return ..()

/obj/item/mobcapsule/attack(var/atom/A, mob/user, prox_flag)
	if(!istype(A, /mob/living/simple_animal) || isbot(A))
		return ..()
	capture(A, user)
	return 1

/obj/item/mobcapsule/proc/capture(var/mob/target, var/mob/U as mob)
	var/mob/living/simple_animal/T = target
	if(captured)
		to_chat(U, "<span class='notice'>Capture failed!</span>: The capsule already has a mob registered to it!")
	else
		if(istype(T) && "neutral" in T.faction)
			T.forceMove(src)
			T.name = "[U.name]'s [initial(T.name)]"
			T.cancel_camera()
			name = "Lazarus Capsule: [initial(T.name)]"
			to_chat(U, "<span class='notice'>You placed a [T.name] inside the Lazarus Capsule!</span>")
			captured = T
		else
			to_chat(U, "You can't capture that mob!")

/obj/item/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(captured)
		dump_contents(user)

/obj/item/mobcapsule/proc/dump_contents(mob/user)
	if(captured)
		captured.forceMove(get_turf(src))
		captured = null

/obj/item/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	icon_state = "mobcap[colorindex]"
	update_icon()