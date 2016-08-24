// Updates the health HUD on the side of your screen
/mob/living/carbon/update_health_hud()
	if(!client)
		return
		if(hud_used.healths)
			if(stat != DEAD)
				var/healthpercent = 100 * round(health/maxHealth)
				switch(healthpercent)
					if(100 to INFINITY)
						hud_used.healths.icon_state = "health0"
					if(80 to 100)
						hud_used.healths.icon_state = "health1"
					if(60 to 80)
						hud_used.healths.icon_state = "health2"
					if(40 to 60)
						hud_used.healths.icon_state = "health3"
					if(20 to 40)
						hud_used.healths.icon_state = "health4"
					if(0 to 20)
						hud_used.healths.icon_state = "health5"
					else
						hud_used.healths.icon_state = "health6"
			else
				hud_used.healths.icon_state = "health7"

// Apply the damage vignettes
/mob/living/carbon/update_damage_hud()
	if(!client)
		return 0

	if(stat == UNCONSCIOUS && health <= config.health_threshold_crit)
		var/severity = 0
		switch(health)
			if(-20 to -10) severity = 1
			if(-30 to -20) severity = 2
			if(-40 to -30) severity = 3
			if(-50 to -40) severity = 4
			if(-60 to -50) severity = 5
			if(-70 to -60) severity = 6
			if(-80 to -70) severity = 7
			if(-90 to -80) severity = 8
			if(-95 to -90) severity = 9
			if(-INFINITY to -95) severity = 10
		overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		if(oxyloss)
			var/severity = 0
			switch(oxyloss)
				if(10 to 20) severity = 1
				if(20 to 25) severity = 2
				if(25 to 30) severity = 3
				if(30 to 35) severity = 4
				if(35 to 40) severity = 5
				if(40 to 45) severity = 6
				if(45 to INFINITY) severity = 7
			overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(5 to 15) severity = 1
				if(15 to 30) severity = 2
				if(30 to 45) severity = 3
				if(45 to 70) severity = 4
				if(70 to 85) severity = 5
				if(85 to INFINITY) severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")
