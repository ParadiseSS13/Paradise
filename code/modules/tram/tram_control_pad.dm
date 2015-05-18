/obj/tram/controlpad
	name = "tram controller interface"
	desc = "Controls the tram."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	var/obj/tram/tram_controller/tram_linked
	var/list/cdir2readable = list("North","South",null,"East",null,null,null,"West")

/obj/tram/controlpad/attack_hand(var/mob/user)
	usr.set_machine(src)
	if(!tram_linked)	return
	var/dat = "Tram Controller"
	dat += "<br>Tram engine: <a href=?src=\ref[src];engine_toggle=1>[tram_linked.automode ? "<font color='green'>On</font>" : "<font color='red'>Off</font>"]</a>"
	dat += "<br><A href='?src=\ref[src];close=1'>Close console</A>"
	user << browse(dat, "window=trampad")
	onclose(user,"trampad")

/obj/tram/controlpad/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["engine_toggle"])
		tram_linked.automode = !tram_linked.automode
	else if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=trampad")

	src.add_fingerprint(usr)
	src.updateUsrDialog()