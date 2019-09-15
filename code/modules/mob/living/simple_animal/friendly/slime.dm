/mob/living/simple_animal/slime
	name = "pet slime"
	desc = "A lovable, domesticated slime."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	speak_emote = list("chirps")
	health = 100
	maxHealth = 100
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	pass_flags = PASSTABLE
	var/colour = "grey"

/mob/living/simple_animal/slime/adult
	health = 200
	maxHealth = 200
	icon_state = "grey adult slime"
	icon_living = "grey adult slime"

/mob/living/simple_animal/slime/New()
	..()
	overlays += "aslime-:33"

/mob/living/simple_animal/slime/updatehealth(reason)
	. = ..()
	update_health_hud()

/mob/living/simple_animal/slime/proc/update_health_hud()
	if(hud_used)
		var/severity = 0
		var/healthpercent = (health/maxHealth) * 100
		switch(healthpercent)
			if(100 to INFINITY)
				healths.icon_state = "slime_health0"
			if(80 to 100)
				healths.icon_state = "slime_health1"
				severity = 1
			if(60 to 80)
				healths.icon_state = "slime_health2"
				severity = 2
			if(40 to 60)
				healths.icon_state = "slime_health3"
				severity = 3
			if(20 to 40)
				healths.icon_state = "slime_health4"
				severity = 4
			if(1 to 20)
				healths.icon_state = "slime_health5"
				severity = 5
			else
				healths.icon_state = "slime_health7"
				severity = 6
		if(severity > 0)
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")
