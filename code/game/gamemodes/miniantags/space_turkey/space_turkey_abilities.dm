#define MAX_TURKEY_TACKLE_DIST 6

/obj/effect/proc_holder/spell/targeted/turkey_tackle

	name = "Flying Tackle"
	desc = "Fly through the air, tackling anyone in your way to the ground."
	panel = "Turkey"

	charge_max = 100
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "genetic_jump"

/obj/effect/proc_holder/spell/targeted/turkey_tackle/cast(list/targets, mob/user = usr)
	if(is_ventcrawling(user))
		to_chat(user, "<span class='warning'>You can't fly while you're in a pipe!</span>")
		charge_counter = charge_max
		return FALSE

	if(istype(user.loc, /obj/machinery/disposal) || istype(user.loc, /obj/structure/disposalholder))
		to_chat(user, "<span class='warning'>You can't fly while you're in Disposals!</span>")
		charge_counter = charge_max
		return FALSE

	user.notransform = 1
	var/prevLayer = user.layer
	var/prevFlying = user.flying
	user.layer = 9

	user.flying = TRUE
	user.pass_flags |= PASSMOB


	var/collided = FALSE
	var/pixel_elevation = 0
	user.visible_message("<span class ='warning'>[user] takes a flying leap!</span>", "<span class='warning'>You take a flying leap!</span>")
	playsound(user.loc, 'sound/creatures/turkey_gobble.ogg',50,1,-1)
	for(var/i=0, i<MAX_TURKEY_TACKLE_DIST, i++)
		step(user, user.dir)
		if(i*2 < MAX_TURKEY_TACKLE_DIST)
			user.pixel_y += 8
			pixel_elevation += 8
		else
			user.pixel_y -= 8
			pixel_elevation -= 8
		for(var/mob/living/carbon/human/H in view(0,user))
			if(!H.lying && !(H.restrained() && H.buckled))
				if(H.buckled)
					H.buckled.unbuckle_mob(H, TRUE)
				H.Weaken(3)
				H.visible_message("<span class ='danger'>[user] flies into [H]!</span>", "<span class ='userdanger'>[user] flies into you!</span>")
				collided = TRUE
		if(collided)
			playsound(user.loc, 'sound/weapons/genhit1.ogg',50,1,-1)
			user.pixel_y -= pixel_elevation
			break
		sleep(1)

	user.pass_flags &= ~PASSMOB
	user.flying = prevFlying
	user.layer = prevLayer
	user.notransform = 0

/obj/effect/proc_holder/spell/targeted/lay_turkey_egg

	name = "Lay Egg"
	desc = "Lay an egg that should eventually hatch into another space turkey."
	panel = "Turkey"

	charge_max = 600*5
	starts_charged = FALSE
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "hatch"
	var/egg_type = /obj/item/reagent_containers/food/snacks/egg/turkey

/obj/effect/proc_holder/spell/targeted/lay_turkey_egg/cast(list/targets, mob/user = usr)
	if(istype(user.loc, /obj))
		to_chat(user, "<span class='warning'>You need to lay eggs on open turf!</span>")
		charge_counter = charge_max
		return FALSE

	playsound(user.loc, 'sound/creatures/turkey_gobble.ogg',50,1,-1)
	var/obj/item/E = new egg_type(get_turf(user))
	E.pixel_x = rand(-6,6)
	E.pixel_y = rand(-6,6)
	user.visible_message("<span class ='warning'>[user] lays an egg.</span>", "<span class='warning'>You lay a turkey egg.</span>")

/obj/effect/proc_holder/spell/targeted/gobble
	name = "Gobble"
	desc = "Let the crew know their day is about to get worse."
	panel = "Turkey"

	charge_max = 30
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "dissonant_shriek"

/obj/effect/proc_holder/spell/targeted/gobble/perform(list/targets, recharge = 1, mob/user = usr, make_attack_logs = FALSE)
	return ..()

/obj/effect/proc_holder/spell/targeted/gobble/cast(list/targets, mob/user = usr)
	playsound(user.loc, 'sound/creatures/turkey_gobble.ogg',50,1,-1)
