/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"

	secured = 0

	bomb_name = "time bomb"

	var/timing = 0
	var/time = 10
	var/repeat = 0
	var/set_time = 10

	proc
		timer_end()

	describe()
		if(timing)
			return "The timer is counting down from [time]!"
		return "The timer is set for [time] seconds."

	activate()
		if(!..())	return 0//Cooldown check
		timing = !timing
		update_icon()
		return 0


	toggle_secure()
		secured = !secured
		if(secured)
			processing_objects.Add(src)
		else
			timing = 0
			processing_objects.Remove(src)
		update_icon()
		return secured


	timer_end()
		if((!secured)||(cooldown > 0))	return 0
		pulse(0)
		if(loc)
			loc.visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	process()
		if(timing && (time > 0))
			time -= 2 // 2 seconds per process()
		if(timing && time <= 0)
			timing = repeat
			timer_end()
			time = set_time
		return


	update_icon()
		overlays.Cut()
		attached_overlays = list()
		if(timing)
			overlays += "timer_timing"
			attached_overlays += "timer_timing"
		if(holder)
			holder.update_icon()
		return


	interact(mob/user as mob)//TODO: Have this use the wires
		if(!secured)
			user.show_message("\red The [name] is unsecured!")
			return 0
		var/second = time % 60
		var/minute = (time - second) / 60
		var/set_second = set_time % 60
		var/set_minute = (set_time - set_second) / 60
		if(second < 10) second = "0[second]"
		if(set_second < 10) set_second = "0[set_second]"

		var/dat = {"
		<TT>
			<center><h2>Timing Unit</h2>
			[minute]:[second] <a href='?src=[UID()];time=1'>[timing?"Stop":"Start"]</a> <a href='?src=[UID()];reset=1'>Reset</a><br>
			Repeat: <a href='?src=[UID()];repeat=1'>[repeat?"On":"Off"]</a><br>
			Timer set for
			<A href='?src=[UID()];tp=-30'>-</A> <A href='?src=[UID()];tp=-1'>-</A> [set_minute]:[set_second] <A href='?src=[UID()];tp=1'>+</A> <A href='?src=[UID()];tp=30'>+</A>
			</center>
		</TT>
		<BR><BR>
		<A href='?src=[UID()];refresh=1'>Refresh</A>
		<BR><BR>
		<A href='?src=[UID()];close=1'>Close</A>"}
		var/datum/browser/popup = new(user, "timer", name, 400, 400)
		popup.set_content(dat)
		popup.open(0)
		onclose(user, "timer")
		return


	Topic(href, href_list)
		..()
		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=timer")
			onclose(usr, "timer")
			return

		if(href_list["time"])
			timing = !timing
			if(timing && istype(holder, /obj/item/device/transfer_valve))
				message_admins("[key_name_admin(usr)] activated [src] attachment on [holder].")
				bombers += "[key_name(usr)] activated [src] attachment for [loc]"
				log_game("[key_name(usr)] activated [src] attachment for [loc]")
			update_icon()
		if(href_list["reset"])
			time = set_time

		if(href_list["repeat"])
			repeat = !repeat

		if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			set_time += tp
			set_time = min(max(round(set_time), 6), 600)
			if(!timing)
				time = set_time

		if(href_list["close"])
			usr << browse(null, "window=timer")
			return

		if(usr)
			attack_self(usr)

		return
