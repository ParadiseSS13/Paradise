/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 5, /obj/item/stack/sheet/animalhide/xeno = 1)
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/next_attack = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	var/leap_on_click = 0
	var/custom_pixel_x_offset = 0 //for admin fuckery.
	var/custom_pixel_y_offset = 0

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	add_language("Xenomorph")
	add_language("Hivemind")
	..()

//This is fine, works the same as a human
/mob/living/carbon/alien/humanoid/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if((!( yes ) || now_pushing))
			return
		now_pushing = 0
		..()
		if(!istype(AM, /atom/movable))
			return

		if(ismob(AM))
			var/mob/tmob = AM
			tmob.LAssailant = src

		if(!now_pushing)
			now_pushing = 1
			if(!AM.anchored)
				var/t = get_dir(src, AM)
				if(istype(AM, /obj/structure/window/full))
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/alien/humanoid/movement_delay()
	var/tally = 0
	if(istype(src, /mob/living/carbon/alien/humanoid/queen))
		tally += 4
	if(istype(src, /mob/living/carbon/alien/humanoid/drone))
		tally += 0
	if(istype(src, /mob/living/carbon/alien/humanoid/sentinel))
		tally += 0
	if(istype(src, /mob/living/carbon/alien/humanoid/hunter))
		tally = -2 // hunters go supersuperfast
	return (tally + move_delay_add + config.alien_delay)

/mob/living/carbon/alien/humanoid/Process_Spacemove(var/check_drift = 0)
	if(..())
		return 1

	return 0

///mob/living/carbon/alien/humanoid/bullet_act(var/obj/item/projectile/Proj) taken care of in living

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	..()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)
			if(!shielded)
				b_loss += 60

			f_loss += 60

			adjustEarDamage(30, 120)

		if(3.0)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(1)
			adjustEarDamage(15,60)

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/alien/humanoid/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim) return // can't attack while eating!

	if(stat > -100)

		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")
		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(10, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)

		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", \
				"<span class='userdanger'>The [M.name] has shocked [src]!</span>")

				Weaken(power)
				if(stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if(prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return

/mob/living/carbon/alien/humanoid/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>", \
				"<span class='userdanger'>[M] [M.attacktext] [src]!</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	if(..())	//to allow surgery to return properly.
		return

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)

		if(I_GRAB)
			grabbedby(M)

		if(I_HARM)
			M.do_attack_animation(src)
			var/damage = rand(1, 9)
			if(prob(90))
				if(HULK in M.mutations)//HULK SMASH
					damage = 15
					spawn(0)
						Paralyse(1)
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched [src]!</span>", \
						"<span class='userdanger'>[M] has punched [src]!</span>")
				if((stat != DEAD) && (damage > 9||prob(5)))//Regular humans have a very small chance of weakening an alien.
					Paralyse(2)
					visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
							"<span class='userdanger'>[M] has weakened [src]!</span>", \
							"<span class='danger'>You hear someone fall.</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")

		if(I_DISARM)
			if(!lying)
				if(prob(5))//Very small chance to push an alien down.
					Paralyse(2)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
							"<span class='userdanger'>[M] has pushed down [src]!</span>")
				else
					if(prob(50))
						drop_item()
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
							"<span class='userdanger'>[M] has disarmed [src]!</span>")
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						visible_message("<span class='danger'>[M] has attempted to disarm [src]!</span>")
	return

/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/

/mob/living/carbon/alien/humanoid/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	..()

	switch(M.a_intent)

		if(I_HELP)
			sleeping = max(0,sleeping-5)
			resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake it up!</span>")

		else
			if(health > 0)
				M.do_attack_animation(src)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = rand(1, 3)
				visible_message("<span class='danger'>[M.name] bites [src]!!</span>", \
						"<span class='userdanger'>[M.name] bites [src]!!</span>")

				adjustBruteLoss(damage)
				updatehealth()
			else
				to_chat(M, "<span class='warning'>[name] is too injured for that.</span>")
	return


/mob/living/carbon/alien/humanoid/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[L] rubs its head against [src].</span>")


		else
			if(health > 0)
				L.do_attack_animation(src)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = rand(1, 3)
				visible_message("<span class='danger'>[L.name] bites [src]!!</span>", \
						"<span class='userdanger'>[L.name] bites [src]!!</span>")

				adjustBruteLoss(damage)
				updatehealth()
			else
				to_chat(L, "<span class='warning'>[name] is too injured for that.</span>")
	return



/mob/living/carbon/alien/humanoid/restrained()
	if(handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)
	user.set_machine(src)

	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[UID()];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Pouches:</B></td><td><A href='?src=[UID()];item=pockets'>[((l_store && !(l_store.flags&ABSTRACT)) || (r_store && !(r_store.flags&ABSTRACT))) ? "Full" : "<font color=grey>Empty</font>"]</A>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/alien/humanoid/canBeHandcuffed()
	return 1

/mob/living/carbon/alien/humanoid/cuff_resist(obj/item/I)
	playsound(src, 'sound/voice/hiss5.ogg', 40, 1, 1)  //Alien roars when starting to break free
	..(I, cuff_break = 1)

/mob/living/carbon/alien/humanoid/get_standard_pixel_y_offset(lying = 0)
	if(leaping)
		return -32
	else if(custom_pixel_y_offset)
		return custom_pixel_y_offset
	else
		return initial(pixel_y)

/mob/living/carbon/alien/humanoid/get_standard_pixel_x_offset(lying = 0)
	if(leaping)
		return -32
	else if(custom_pixel_x_offset)
		return custom_pixel_x_offset
	else
		return initial(pixel_x)

/mob/living/carbon/alien/humanoid/get_permeability_protection()
	return 0.8