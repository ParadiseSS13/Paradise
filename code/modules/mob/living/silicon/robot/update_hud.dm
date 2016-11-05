/mob/living/silicon/robot/update_health_hud()
	if(!client)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			var/healthratio = round(100 * (health/maxHealth))
			switch(healthratio)
				if(100 to INFINITY)
					hud_used.healths.icon_state = "health0"
				if(60 to 100)
					hud_used.healths.icon_state = "health2"
				if(20 to 60)
					hud_used.healths.icon_state = "health3"
				if(-20 to 20)
					hud_used.healths.icon_state = "health4"
				if(-60 to -20)
					hud_used.healths.icon_state = "health5"
				else
					hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/silicon/robot/proc/update_temperature_hud()
	switch(bodytemperature) //310.055 optimal body temp
		if(335 to INFINITY)
			throw_alert("temp", /obj/screen/alert/hot/robot, 2)
		if(320 to 335)
			throw_alert("temp", /obj/screen/alert/hot/robot, 1)
		if(300 to 320)
			clear_alert("temp")
		if(260 to 300)
			throw_alert("temp", /obj/screen/alert/cold/robot, 1)
		else
			throw_alert("temp", /obj/screen/alert/cold/robot, 2)

/mob/living/silicon/robot/proc/update_cell_hud()
	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				clear_alert("charge")
			if(0.5 to 0.75)
				throw_alert("charge", /obj/screen/alert/lowcell, 1)
			if(0.25 to 0.5)
				throw_alert("charge", /obj/screen/alert/lowcell, 2)
			if(0.01 to 0.25)
				throw_alert("charge", /obj/screen/alert/lowcell, 3)
			else
				throw_alert("charge", /obj/screen/alert/emptycell)
	else
		throw_alert("charge", /obj/screen/alert/nocell)

/mob/living/silicon/robot/proc/update_hacked_hud()
	if(emagged)
		throw_alert("hacked", /obj/screen/alert/hacked)
	else
		clear_alert("hacked")
