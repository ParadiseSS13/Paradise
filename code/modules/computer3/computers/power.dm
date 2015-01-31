/obj/machinery/computer3/powermonitor
	default_prog = /datum/file/program/powermon
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/cable)
	icon_state = "frame-eng"

/datum/file/program/powermon
	name = "power monitoring console"
	desc = "It monitors APC status."
	active_state = "power"

	proc/format(var/obj/machinery/power/apc/A)
		var/static/list/S = list(" Off","AOff","  On", " AOn")
		var/static/list/chg = list("N","C","F")
		return "[copytext(add_tspace("\The [A.area]", 30), 1, 30)] [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] \
		[add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

	interact()
		if(!interactable())
			return
		if(!computer.net)
			computer.Crash(MISSING_PERIPHERAL)
			return
		var/list/L = computer.net.get_machines(/obj/machinery/power/apc)
		var/t = ""
		t += "<A href='?src=\ref[src]'>Refresh</A><br /><br />"
		if(!L || !L.len)
			t += "No connection"
		else
			var/datum/powernet/powernet = computer.net.connect_to(/datum/powernet,null)
			if(powernet)
				t += "<PRE>Total power: [powernet.avail] W<BR>Total load:  [num2text(powernet.viewload,10)] W<BR>"
			else
				t += "<PRE><i>Power statistics unavailable</i><BR>"
			t += "<FONT SIZE=-1>"

			if(L.len > 0)
				t += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"
				for(var/obj/machinery/power/apc/A in L)
					t += src.format(A)
			t += "</FONT></PRE>"

		popup.set_content(t)
		popup.open()

	Topic(var/href, var/list/href_list)
		if(!interactable() || ..(href,href_list))
			return
		interact()
