/datum/ui_module/crimes_menu
	var/mob/owner
	var/obj/machinery/door_timer/cell
	var/list/menores = list("Vandalismo","Robo Menor","Allanamiento Menor","Brecha y Entrada","Posesión de Contrabando y Armas Improvisadas","Posesión o Tráfico de Drogas","Conducta Inapropiada","Exposicion Indecente","Uso Inadecuado de la Radio","Asalto Menor","Abuso del Equipo","Abuso de Equipo Confiscado","Uso no autorizado de Equipo","Asociacion Ilicita","Maltrato Animal","Comportamiento Amenazante","Resistirse a un Arresto")
	var/list/moderados = list("Insubordinacion","Negligencia","Impersonar","Inculpar","Interferir en un Arresto","Provocar una Persecucion","Asalto","Robo","Despojo de la Propiedad Personal","Traspaso","Sabotaje","Posesion de Explosivos","Posesion de Armas","Homicidio Involuntario","Construir Equipamiento de Combate no Autorizado","Brecha y Entrada en Areas Restringidas","Secuestrar a un Oficial","Incitar a un Motin","Intentar Escapar de Brig")
	var/list/mayores = list("Acto de lesa humanidad","Liberar Prisioneros de Brig","Modificadores Illegales de las leyes de un Sintetico","Secuestro","Allanamiento Mayor","Gran Sabotaje","Gran Robo","Brecha y Entrada Mayor","Asalto a un Oficial","Abuso de Poder","Remocion de Implante a si Mismo","Escape de Sentencia Permanente","Amotinamiento","Enemigo de la Corporacion","Asesinato")


/datum/ui_module/crimes_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Crimes", "Crimes", 375, 500, master_ui, state)
		ui.open()

/datum/ui_module/crimes_menu/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("menor")
			var/ref = params["ref"]
			cell.prisoner_charge += "/ " + ref + " "
			cell.prisoner_charge_minor += "/ " +ref + " "
		if("menor_detalles")
			cell.prisoner_minor_details = input("Detalles:", "Detalles de Crimenes Menores", cell.prisoner_minor_details) as text|null
		if("moderado")
			var/ref = params["ref"]
			cell.prisoner_charge += "/ " + ref + " "
			cell.prisoner_charge_moderate += "/ " +ref + " "
		if("moder_detalles")
			cell.prisoner_moderate_details = input("Detalles:", "Detalles de Crimenes Moderados", cell.prisoner_moderate_details) as text|null
		if("mayor")
			var/ref = params["ref"]
			cell.prisoner_charge += "/ " +ref + " "
			cell.prisoner_charge_major += "/ " +ref + " "
		if("mayor_detalles")
			cell.prisoner_major_details = input("Detalles:", "Detalles de Crimenes Mayores", cell.prisoner_major_details) as text|null

/datum/ui_module/crimes_menu/ui_data(mob/user)
	var/list/data = list()
	data["menores"] = menores
	data["moderados"] = moderados
	data["mayores"] = mayores
	data["prisoner_minor_details"] = cell.prisoner_minor_details
	data["prisoner_moderate_details"] = cell.prisoner_moderate_details
	data["prisoner_major_details"] = cell.prisoner_major_details
	return data
