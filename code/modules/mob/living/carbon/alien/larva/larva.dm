/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	maxHealth = 30
	health = 30
	density = 0

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_language("Xenomorph")
	add_language("Hivemind")
	internal_organs += new /obj/item/organ/internal/xenos/plasmavessel/larva

	..()

//This is fine, works the same as a human
/mob/living/carbon/alien/larva/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(70))
					to_chat(src, "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>")
					now_pushing = 0
					return
				if(!(tmob.status_flags & CANPUSH))
					now_pushing = 0
					return
			tmob.LAssailant = src

		now_pushing = 0
		..()
		if(!( istype(AM, /atom/movable) ))
			return
		if(!( now_pushing ))
			now_pushing = 1
			if(!( AM.anchored ))
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	stat(null, "Progress: [amount_grown]/[max_grown]")


/mob/living/carbon/alien/larva/adjustPlasma(amount)
	if(stat != DEAD && amount > 0)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)


/mob/living/carbon/alien/larva/ex_act(severity)
	..()

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)

			b_loss += 60

			f_loss += 60

			adjustEarDamage(30,120)

		if(3.0)
			b_loss += 30
			if(prob(50))
				Paralyse(1)
			adjustEarDamage(15,60)

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

/mob/living/carbon/alien/larva/attack_animal(mob/living/simple_animal/M as mob)
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
		add_logs(M, src, "attacked", admin=0)
		updatehealth()



/mob/living/carbon/alien/larva/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	if(stat != DEAD)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")
		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(20, 40)
		else
			damage = rand(5, 35)


		adjustBruteLoss(damage)
		updatehealth()

	return

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)

		if(I_GRAB)
			grabbedby(M)

		else
			M.do_attack_animation(src)
			var/damage = rand(1, 9)
			if(prob(90))
				if(HULK in M.mutations)
					damage += 5
					spawn(0)
						Paralyse(1)
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has kicked [src]!</span>", \
						"<span class='userdanger'>[M] has kicked [src]!</span>")
				if((stat != DEAD) && (damage > 4.9))
					Paralyse(rand(5,10))
					visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
							"<span class='userdanger'>[M] has weakened [src]!</span>", \
							"<span class='danger'>You hear someone fall.</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to kick [src]!</span>", \
						"<span class='userdanger'>[M] has attempted to kick [src]!</span>")
	return

/mob/living/carbon/alien/larva/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
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
				var/damage = 1
				visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
						"<span class='userdanger'>[M.name] bites [src]!</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				to_chat(M, "<span class='warning'>[name] is too injured for that.</span>")
	return

/mob/living/carbon/alien/larva/restrained()
	return 0

/mob/living/carbon/alien/larva/var/temperature_resistance = T0C+75

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/show_inv(mob/user as mob)
	return

/* Commented out because it's duplicated in life.dm
/mob/living/carbon/alien/larva/proc/grow() // Larvae can grow into full fledged Xenos if they survive long enough -- TLE
	if(icon_state == "larva_l" && !canmove) // This is a shit death check. It is made of shit and death. Fix later.
		return
	else
		var/mob/living/carbon/alien/humanoid/A = new(loc)
		A.key = key
		qdel(src) */
