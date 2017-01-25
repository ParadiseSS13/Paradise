
/obj/machinery/prize_counter
	name = "Prize Counter"
	desc = "A machine which exchanges tickets for a variety of fabulous prizes!"
	icon = 'icons/obj/arcade.dmi'
	icon_state = "prize_counter-on"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/tickets = 0

/obj/machinery/prize_counter/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/prize_counter(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/prize_counter/update_icon()
	if(stat & BROKEN)
		icon_state = "prize_counter-broken"
	else if(panel_open)
		icon_state = "prize_counter-open"
	else if(stat & NOPOWER)
		icon_state = "prize_counter-off"
	else
		icon_state = "prize_counter-on"
	return

/obj/machinery/prize_counter/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/stack/tickets))
		var/obj/item/stack/tickets/T = O
		if(user.unEquip(T))		//Because if you can't drop it for some reason, you shouldn't be increasing the tickets var
			tickets += T.amount
			qdel(T)
		else
			to_chat(user, "<span class='warning'>\The [T] seems stuck to your hand!</span>")
		return
	if(istype(O, /obj/item/weapon/screwdriver) && anchored)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
		update_icon()
		return
	if(panel_open)
		if(istype(O, /obj/item/weapon/wrench))
			default_unfasten_wrench(user, O)
		if(component_parts && istype(O, /obj/item/weapon/crowbar))
			if(tickets)		//save the tickets!
				print_tickets()
			default_deconstruction_crowbar(O)

/obj/machinery/prize_counter/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)
	interact(user)

/obj/machinery/prize_counter/interact(mob/user as mob)
	user.set_machine(src)

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat = {"
<html>
	<head>
		<title>Arcade Ticket Exchange</title>
		<style type="text/css">
* {
	font-family:sans-serif;
	font-size:x-small;
}
html {
	background:#333;
	color:#999;
}

a {
	color:#cfcfcf;
	text-decoration:none;
	font-weight:bold;
}

a:hover {
	color:#ffffff;
}
tr {
	background:#303030;
	border-radius:6px;
	margin-bottom:0.5em;
	border-bottom:1px solid black;
}
tr:nth-child(even) {
	background:#3f3f3f;
}

td.cost {
	font-size:20pt;
	font-weight:bold;
}

td.cost.affordable {
	background:green;
}

td.cost.toomuch {
	background:maroon;
}


		</style>
	</head>
	<body>
	<p style="float:right"><b>Tickets:</b> [tickets] | <a href='byond://?src=[UID()];eject=1'>Eject Tickets</a></p>
	<h1>Arcade Ticket Exchange</h1>
	<p>
		<b>Exchange that pile of tickets for a pile of cool prizes!</b>
	</p>
	<h2>Available Prizes:</h2>
	<table cellspacing="0" cellpadding="0">
		<thead>
			<th>#</th>
			<th>Name/Description</th>
			<th>Price</th>
		</thead>
		<tbody>
	"}

	for(var/datum/prize_item/item in global_prizes.prizes)
		var/cost_class="affordable"
		if(item.cost>tickets)
			cost_class="toomuch"
		var/itemID = global_prizes.prizes.Find(item)
		dat += {"
			<tr>
				<th>
					[itemID]
				</th>
				<td>
					<p><b>[item.name]</b></p>
					<p>[item.desc]</p>
				</td>
		"}
		dat += {"
			<td class="cost [cost_class]">
				<a href="byond://?src=[UID()];buy=[itemID]">[item.cost] Tickets</a>
			</td>
		</tr>
		"}

	dat += {"
		</tbody>
	</table>
	</body>
</html>"}
	user << browse(dat, "window=prize_counter")
	onclose(user, "prize_counter")
	return

/obj/machinery/prize_counter/Topic(href, href_list)
	if(..())
		return 1

	add_fingerprint(usr)

	if(href_list["eject"])
		print_tickets()

	if(href_list["buy"])
		var/itemID = text2num(href_list["buy"])
		var/datum/prize_item/item = global_prizes.prizes[itemID]
		var/sure = alert(usr,"Are you sure you wish to purchase [item.name] for [item.cost] tickets?","You sure?","Yes","No") in list("Yes","No")
		if(sure=="No")
			updateUsrDialog()
			return
		if(!global_prizes.PlaceOrder(src, itemID))
			to_chat(usr, "<span class='warning'>Unable to complete the exchange.</span>")
		else
			to_chat(usr, "<span class='notice'>You've successfully purchased the item.</span>")

	interact(usr)
	return

/obj/machinery/prize_counter/proc/print_tickets()
	if(!tickets)
		return
	if(tickets >= 9999)
		new /obj/item/stack/tickets(get_turf(src), 9999)	//max stack size
		tickets -= 9999
		print_tickets()
	else
		new /obj/item/stack/tickets(get_turf(src), tickets)
		tickets = 0