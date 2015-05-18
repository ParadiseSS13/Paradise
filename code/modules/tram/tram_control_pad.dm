/obj/tram/controlpad
	name = "tram controller interface"
	desc = "Controls the tram."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	var/obj/tram/tram_controller/tram_linked

/obj/tram/controlpad/attack_hand(var/mob/user)
	if(!tram_linked)	return
	var/dat = "Tram Controller"
	for(var/cdir in cardinal)
		dat += "<br>Move to: <a href=?src=\ref[src];movedir=[cdir]>[cdir]</a>"
	user << browse(dat, "window=trampad")
	onclose(user,"trampad")

/obj/tram/controlpad/Topic(href, href_list)
	if(href_list["movedir"])
		var/dir = text2num(href_list["movedir"])
		tram_linked.handle_move(dir)