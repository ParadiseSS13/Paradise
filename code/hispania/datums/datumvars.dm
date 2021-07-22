/client/view_var_Topic(href, href_list, hsrc) // Joder como odio este codigo
	. = ..()

	// ViewVariables especial para la HISPANIABOX

	if(href_list["emag"])
		var/obj/machinery/M = locateUID(href_list["emag"])

		if(!istype(M))
			to_chat(usr, "Algo salio mal, ve a llorar al discord")
			return
		M.emag_act()

		message_admins("Admin [key_name_admin(usr)] ha emageado la hispaniabox del tile ([M.x], [M.y], [M.z]).")
		href_list["datumrefresh"] = href_list["emag"]

	else if(href_list["nuevacancion"])
		var/obj/machinery/hispaniabox/H = locate(href_list["nuevacancion"])

		var/confirm = alert("Estas seguro de querer hacer una nueva cancion? (Se recomienda probar antes en una sala de admin)", "Nueva Cancion", "Si", "No")
		if(confirm != "Si") return

		var/confirm2 = alert("Usaras un sonido de tus archivos o del server?", "Nueva Cancion", "Server", "Mis Archivos")
		var/rutacancion
		if(confirm2 == "Server")
			var/list/sounds = file2list("sound/serversound_list.txt")
			sounds += GLOB.sounds_cache

			var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds
			if(!melody)	return
			rutacancion = file(melody)
		else
		//	rutacancion = hispaniabox_cancionglob(S as sound)
			var/melody = input(usr, "Escoje tu archivo de musica para la nueva cancion","Nueva Cancion Hispaniabox") as null|file
			if(!melody) return
			rutacancion = file(melody)

		var/genero = input(usr, "Escribe el genero muscial de la cancion", "Genero Musical") as text|null
		if(!genero) return

		var/nombre = input(usr, "Escribe el nombre de la cancion", "Nombre de la Cancion") as text|null
		if(!nombre) return

		var/tiempo = input(usr, "Lapso de tiempo de la cancion en decisegundos, ejemplo: Cancion de 4:30 minutos pasaria a \"4300\"", "Tiempo de la Cancion") as num|null
		if(!tiempo) return

		var/iconosaelegir = list("hispania","experimental","weird","admin","event","smuggy","trash","face?","game","calm","classical","smuggy","rock","actualrock") // Si quieren mas iconos solo pongan el nombre del icon state aqui
		var/icono = input(usr, "Eligue el icono del vinilo", "Icono de la Cancion") as null|anything in iconosaelegir
		if(!icono) return

		var/cancionreal = genero + " • " + nombre
		if(!GLOB.sounds_cache.Find(rutacancion))
			GLOB.sounds_cache += rutacancion
		H.songs[cancionreal] = new /datum/track(rutacancion, tiempo, 5,	icono, cancionreal) // Aqui ocurre la magia

		message_admins("Admin [key_name_admin(usr)] ha agregado una nueva cancion: \"[nombre]\" a la hispaniabox del tile ([H.x], [H.y], [H.z]).")
		href_list["datumrefresh"] = href_list["nuevacancion"]
	else if(href_list["borrarcancion"])
		var/obj/machinery/hispaniabox/H = locateUID(href_list["borrarcancion"])

		var/melody = input("Eligue la cancion para eliminar", "Borrar Cancion") as null|anything in H.songs
		if(!melody || melody == "Play/Pause") return
		H.songs.Remove(melody)
		message_admins("Admin [key_name_admin(usr)] ha eliminado una cancion: \"[melody]\" de la hispaniabox del tile ([H.x], [H.y], [H.z]).")
		href_list["datumrefresh"] = href_list["borrarcancion"]
	else if(href_list["borrartodascanciones"])
		var/obj/machinery/hispaniabox/H = locateUID(href_list["borrartodascanciones"])

		var/confirm = alert("Estas seguro de querer borrar TODAS las canciones?", "Borrar TODAS Las Canciones", "Si", "No")
		if(confirm != "Si") return

		H.songs.len = 1 // que facil, no? (El unico que quedara en la lista es el boton de pausa/play)

		message_admins("Admin [key_name_admin(usr)] ha eliminado todas las canciones de la hispaniabox del tile ([H.x], [H.y], [H.z]).")
		href_list["datumrefresh"] = href_list["borrartodascanciones"]
