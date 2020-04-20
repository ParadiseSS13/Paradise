/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 125
	health = 125
	icon_state = "alienh_s"

/mob/living/carbon/alien/humanoid/hunter/New()
	create_reagents(100)
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/hunter
	..()

/mob/living/carbon/alien/humanoid/hunter/movement_delay()
	. = -1		//hunters are sanic
	. += ..()	//but they still need to slow down on stun

/mob/living/carbon/alien/humanoid/hunter/handle_hud_icons_health()
	..() //-Yvarov

	if(healths)
		if(stat != 2)
			switch(health)
				if(125 to INFINITY)
					healths.icon_state = "health0"
				if(100 to 125)
					healths.icon_state = "health1"
				if(50 to 100)
					healths.icon_state = "health2"
				if(25 to 50)
					healths.icon_state = "health3"
				if(0 to 25)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"


/mob/living/carbon/alien/humanoid/hunter/handle_environment()
	if(m_intent == MOVE_INTENT_RUN || resting)
		..()
	else
		adjustPlasma(-heal_rate)


//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(var/message = 1)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	if(message)
		to_chat(src, "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>")
	else
		return

/mob/living/carbon/alien/humanoid/hunter/ClickOn(var/atom/A, var/params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()

#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(var/atom/A)
	if(pounce_cooldown > world.time)
		to_chat(src, "<span class='alertalien'>You are too fatigued to pounce right now!</span>")
		return

	if(leaping) //Leap while you leap, so you can leap while you leap
		return

	if(!has_gravity(src) || !has_gravity(A))
		to_chat(src, "<span class='alertalien'>It is unsafe to leap without gravity!</span>")
		//It's also extremely buggy visually, so it's balance+bugfix
		return
	if(lying)
		return

	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		leaping = 1
		update_icons()
		throw_at(A, MAX_ALIEN_LEAP_DIST, 1, spin = 0, diagonals_first = 1, callback = CALLBACK(src, .leap_end))

/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = 0
	update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/A)
	if(!leaping)
		return ..()

	if(A)
		if(isliving(A))
			var/mob/living/L = A
			var/blocked = 0
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(src, 0, "the [name]", attack_type = LEAP_ATTACK))
					blocked = 1
			if(!blocked)
				L.visible_message("<span class ='danger'>[src] pounces on [L]!</span>", "<span class ='userdanger'>[src] pounces on you!</span>")
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					H.apply_effect(5, WEAKEN, H.run_armor_check(null, "melee"))
				else
					L.Weaken(5)
				sleep(2)//Runtime prevention (infinite bump() calls on hulks)
				step_towards(src,L)
			else
				Weaken(2, 1, 1)

			toggle_leap(0)
			pounce_cooldown = world.time + pounce_cooldown_time
		else if(A.density && !A.CanPass(src))
			visible_message("<span class ='danger'>[src] smashes into [A]!</span>", "<span class ='alertalien'>[src] smashes into [A]!</span>")
			Weaken(2, 1, 1)

		if(leaping)
			leaping = 0
			update_icons()
			update_canmove()


/mob/living/carbon/alien/humanoid/float(on)
	if(leaping)
		return
	..()
