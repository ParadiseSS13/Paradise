/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 150
	health = 150
	icon_state = "alienh_s"
	alien_movement_delay = -0.5 //hunters are faster than normal xenomorphs, and people
	var/leap_on_click = FALSE
	/// Are we on leap cooldown?
	var/on_leap_cooldown = FALSE
	surgery_container = /datum/xenobiology_surgery_container/alien/hunter

/mob/living/carbon/alien/humanoid/hunter/Initialize(mapload)
	. = ..()
	name = "alien hunter ([rand(1, 1000)])"
	real_name = name

/mob/living/carbon/alien/humanoid/hunter/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/alien/plasmavessel/hunter

/mob/living/carbon/alien/humanoid/hunter/handle_environment()
	if(m_intent == MOVE_INTENT_RUN || IS_HORIZONTAL(src))
		..()
	else
		add_plasma(-heal_rate)

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(message = TRUE)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		to_chat(src, "<span class='noticealien'>You will now [leap_on_click ? "leap at" : "slash at"] enemies!</span>")

/mob/living/carbon/alien/humanoid/hunter/ClickOn(atom/A, params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()

#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(atom/A)
	if(leaping || on_leap_cooldown)
		return

	if(IS_HORIZONTAL(src))
		return

	leaping = TRUE
	on_leap_cooldown = TRUE
	update_icons()
	Immobilize(15 SECONDS, TRUE)
	addtimer(VARSET_CALLBACK(src, on_leap_cooldown, FALSE), 3 SECONDS)
	throw_at(A, MAX_ALIEN_LEAP_DIST, 1.5, spin = 0, diagonals_first = 1, callback = CALLBACK(src, PROC_REF(leap_end)))

/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = FALSE
	SetImmobilized(0, TRUE)
	update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/A)
	if(!leaping)
		return ..()

	if(isliving(A))
		var/mob/living/L = A
		var/blocked = FALSE
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			if(H.check_shields(src, 0, "the [name]", attack_type = LEAP_ATTACK))
				blocked = TRUE
		if(!blocked)
			L.visible_message("<span class ='danger'>[src] pounces on [L]!</span>", "<span class ='userdanger'>[src] pounces on you!</span>")
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				H.apply_effect(10 SECONDS, KNOCKDOWN, H.run_armor_check(armor_type = MELEE))
				H.apply_damage(40, STAMINA)
			else
				L.Weaken(5 SECONDS)
			sleep(2)//Runtime prevention (infinite bump() calls on hulks)
			step_towards(src, L)
		else
			Weaken(2 SECONDS, TRUE)
			..()

		toggle_leap(FALSE)
	else if(A.density && !A.CanPass(src))
		visible_message("<span class ='danger'>[src] smashes into [A]!</span>", "<span class ='alertalien'>[src] smashes into [A]!</span>")
		Weaken(2 SECONDS, TRUE)
		playsound(get_turf(src), 'sound/effects/bang.ogg', 50, FALSE, 0) // owwie
		..()
	if(leaping)
		leaping = FALSE
		update_icons()

/mob/living/carbon/alien/humanoid/hunter/update_icons()
	..()
	if(leap_on_click && !leaping)
		icon_state = "alien[caste]_pounce"
	if(leaping)
		if(alt_icon == initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		icon_state = "alien[caste]_leap"
		pixel_x = -32
		pixel_y = -32

/mob/living/carbon/alien/humanoid/float(on)
	if(leaping)
		return
	..()

#undef MAX_ALIEN_LEAP_DIST
