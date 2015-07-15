// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "It monitors power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	use_power = 2
	idle_power_usage = 20
	active_power_usage = 80
	light_color = LIGHT_COLOR_ORANGE
	circuit = /obj/item/weapon/circuitboard/powermonitor
	var/datum/powernet/powernet = null

//fix for issue 521, by QualityVan.
//someone should really look into why circuits have a powernet var, it's several kinds of retarded.
/obj/machinery/computer/monitor/New()
	..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()

/obj/machinery/computer/monitor/process() //oh shit, somehow we didnt end up with a powernet... lets look for one.
	if(!powernet)
		var/obj/structure/cable/attached = null
		var/turf/T = loc
		if(isturf(T))
			attached = locate() in T
		if(attached)
			powernet = attached.get_powernet()
	return

/obj/machinery/computer/monitor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/monitor/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=powcomp")
			return


	user.set_machine(src)
	var/t = "<TT><B>Power Monitoring</B><HR>"

	t += "<BR><HR><A href='?src=\ref[src];update=1'>Refresh</A>"
	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	if(!powernet)
		t += "\red No connection"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\power.dm:97: t += "<PRE>Total power: [powernet.avail] W<BR>Total load:	[num2text(powernet.viewload,10)] W<BR>"
		t += {"<PRE>Total power: [powernet.avail] W<BR>Total load:	[num2text(powernet.viewload,10)] W<BR>
			<FONT SIZE=-1>"}
		// END AUTOFIX

		var/list/State = list("<font color=red> Off</font>",
								"<font color=red>AOff</font>",
								"<font color=green>  On</font>",
								"<font color=green> AOn</font>")
		var/list/chg   = list("Not charging",
								"Charging",
								"Fully charged")
		// Start of power report table
		// Table header
		t += {"<TABLE>
		       <TH><TR><B><TD>Area</TD><TD>Eqp.</TD><TD>Lgt.</TD><TD>Env.</TD><TD>Load</TD><TD>Cell</TD></B></TR></TH>"}
		if(L.len > 0)
			// Each entry
			for(var/obj/machinery/power/apc/A in L)
				t += {"<TR>
				<TD> [get_area_master(A)   ]</TD>
				<TD> [State[A.equipment+1]]</TD>
				<TD> [State[A.lighting+1 ]]</TD>
				<TD> [State[A.environ+1  ]]</TD>
				<TD> [A.lastused_total    ]</TD>
				<TD>[A.cell ? "[round(A.cell.percent())]% [chg[A.charging+1]]" : "  N/C"] </TD>
				</TR>"}

		t += "</TABLE></FONT></PRE></TT>"
		// End of powa report

	user << browse(t, "window=powcomp;size=640x800")
	onclose(user, "powcomp")

/obj/machinery/computer/monitor/Topic(href, href_list)
	if(..())
		return
	if( href_list["close"] )
		usr << browse(null, "window=powcomp")
		usr.unset_machine()
		return
	if( href_list["update"] )
		src.updateDialog()
		return