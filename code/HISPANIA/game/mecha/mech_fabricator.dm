/obj/machinery/mecha_part_fabricator
	var/secureprotocols = TRUE	//para que los diseños bloqueados salgan bloqueados

/obj/machinery/mecha_part_fabricator/emag_act(mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		req_access = list()
		emagged = TRUE
		secureprotocols = FALSE
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")
		..()
