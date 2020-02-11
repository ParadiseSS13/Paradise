/var/security_level = 0
//0 = code green
//1 = code blue
//2 = code red
//3 = gamma
//4 = epsilon
//5 = code delta

//config.alert_desc_blue_downto
/var/datum/announcement/priority/security/security_announcement_up = new(do_log = 0, do_newscast = 0, new_sound = sound('sound/misc/notice1.ogg'))
/var/datum/announcement/priority/security/security_announcement_down = new(do_log = 0, do_newscast = 0)

/proc/set_security_level(var/level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("gamma")
			level = SEC_LEVEL_GAMMA
		if("epsilon")
			level = SEC_LEVEL_EPSILON
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		if(level >= SEC_LEVEL_RED && security_level < SEC_LEVEL_RED)
			// Mark down this time to prevent shuttle cheese
			SSshuttle.emergency_sec_level_time = world.time

		// Reset gamma borgs if the new security level is lower than Gamma.
		if(level < SEC_LEVEL_GAMMA)
			for(var/M in GLOB.silicon_mob_list)
				if(isrobot(M))
					var/mob/living/silicon/robot/R = M
					if(istype(R.module, /obj/item/robot_module/combat) && !R.crisis)
						R.reset_module()
						to_chat(R, "<span class='warning'>Crisis mode deactivated. The combat module is no longer available and your module has been reset.</span>")

		switch(level)
			if(SEC_LEVEL_GREEN)
				security_announcement_down.Announce("Todas las amenazas a la estación han cesado. Todas las armas deben estar enfundadas y las leyes de privacidad se vuelven a aplicar por completo.","¡Atención! Nivel de seguridad bajado a Verde.")
				security_level = SEC_LEVEL_GREEN

				post_status("alert", "outline")

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_contact(FA.z))
						FA.overlays.Cut()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")

			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					security_announcement_up.Announce("La estación ha recibido información confiable sobre una posible actividad hostil en la estación. El personal de seguridad puede tener armas visibles y se permiten revisiones aleatorias.","¡Atención! Nivel de seguridad elevado a Azul.")
				else
					security_announcement_down.Announce("La amenaza inmediata ha pasado. Seguridad ya no necesita tener armas desenfundadas en todo momento, pero puede seguir haciéndolas visibles. Las revisiones aleatorias aún están permitidas.","¡Atención! Nivel de seguridad bajado a Azul.")
				security_level = SEC_LEVEL_BLUE

				post_status("alert", "outline")

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_contact(FA.z))
						FA.overlays.Cut()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")

			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					security_announcement_up.Announce("Existe una amenaza inmediata y grave para la estación. Seguridad puede tener armas sin funda en todo momento. Se permiten y aconsejan revisiones aleatorias.Todo el personal debe mantenerse dentro de su departamento respectivo. Civiles reunirse en bar.","¡Atención! ¡Código Rojo!")
				else
					security_announcement_down.Announce("El mecanismo de autodestrucción de la estación se ha desactivado, pero aún existe una amenaza inmediata y grave para la estación. Seguridad puede tener armas sin funda en todo momento. Se permiten y aconsejan revisiones aleatorias.","¡Atención! ¡Código Rojo!")
				security_level = SEC_LEVEL_RED

				var/obj/machinery/door/airlock/highsecurity/red/R = locate(/obj/machinery/door/airlock/highsecurity/red) in GLOB.airlocks
				if(R && is_station_level(R.z))
					R.locked = 0
					R.update_icon()

				post_status("alert", "redalert")

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_contact(FA.z))
						FA.overlays.Cut()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")

			if(SEC_LEVEL_GAMMA)
				security_announcement_up.Announce("El Comando Central ha ordenado el nivel de seguridad Gamma en la estación. Seguridad debe tener armas equipadas en todo momento, y toda la tripulacion debe buscar a los jefes de departamento para el transporte a un lugar seguro. El arsenal Gamma de la estación se ha desbloqueado y está listo para usar.","¡Atención! ¡Nivel de seguridad Gamma activado!", new_sound = sound('sound/effects/new_siren.ogg'))
				security_level = SEC_LEVEL_GAMMA

				move_gamma_ship()

				if(security_level < SEC_LEVEL_RED)
					for(var/obj/machinery/door/airlock/highsecurity/red/R in GLOB.airlocks)
						if(is_station_level(R.z))
							R.locked = 0
							R.update_icon()

				for(var/obj/machinery/door/airlock/hatch/gamma/H in GLOB.airlocks)
					if(is_station_level(H.z))
						H.locked = 0
						H.update_icon()

				post_status("alert", "gammaalert")

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_contact(FA.z))
						FA.overlays.Cut()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_gamma")
						FA.update_icon()

			if(SEC_LEVEL_EPSILON)
				security_announcement_up.Announce("El Comando Central ha ordenado el nivel de seguridad de Epsilon en la estación. Contratos laborales rescindidos.","¡Atención! ¡Nivel de seguridad de Epsilon activado!", new_sound = sound('sound/effects/purge_siren.ogg'))
				security_level = SEC_LEVEL_EPSILON

				post_status("alert", "epsilonalert")

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_contact(FA.z))
						FA.overlays.Cut()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_epsilon")

			if(SEC_LEVEL_DELTA)
				security_announcement_up.Announce("El mecanismo de autodestrucción de la estación ha sido activado. Toda la tripulación tiene instrucciones de localizar inmediatamente y obedecer las ordenes dadas por los jefes departamentales. Cualquier violación de estas órdenes puede ser castigada con la muerte. Esto no es un simulacro.","¡Atención! ¡Nivel de seguridad Delta activado!", new_sound = sound('sound/effects/deltaalarm.ogg'))
				security_level = SEC_LEVEL_DELTA

				post_status("alert", "deltaalert")

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_contact(FA.z))
						FA.overlays.Cut()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")

		if(level >= SEC_LEVEL_RED)
			atc.reroute_traffic(yes = TRUE) // Tell them fuck off we're busy.
		else
			atc.reroute_traffic(yes = FALSE)
		SSnightshift.check_nightshift(TRUE)

	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(var/num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(var/seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("gamma")
			return SEC_LEVEL_GAMMA
		if("epsilon")
			return SEC_LEVEL_EPSILON
		if("delta")
			return SEC_LEVEL_DELTA
