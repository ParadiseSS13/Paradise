/mob/living/simple_animal/update_health_hud()
	if(!client)
		return
	if(hud_used.healths && maxHealth > 0)
		switch((health / maxHealth) * 30)
			if(30 to INFINITY)		hud_used.healths.icon_state = "health0"
			if(26 to 29)			hud_used.healths.icon_state = "health1"
			if(21 to 25)			hud_used.healths.icon_state = "health2"
			if(16 to 20)			hud_used.healths.icon_state = "health3"
			if(11 to 15)			hud_used.healths.icon_state = "health4"
			if(6 to 10)				hud_used.healths.icon_state = "health5"
			if(1 to 5)				hud_used.healths.icon_state = "health6"
			if(0)					hud_used.healths.icon_state = "health7"
