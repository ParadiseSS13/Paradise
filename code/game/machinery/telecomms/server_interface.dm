/obj/machinery/computer/telecomms/server_interface
	name = "telecommunications server interface"
	icon_screen = "server_interface"
	icon_keyboard = "teleport_key"
	tcomms_linkable = 1 // That's the whole point of this.
	light_color = LIGHT_COLOR_LIGHTBLUE
	circuit = /obj/item/weapon/circuitboard/server_interface

	var/list/ui_elements = list("text~Welcome. The telecomms server has not been configured to display a UI on this server interface. Press init to send \"init\" signal to server.","button~Init~init")

/obj/machinery/computer/telecomms/server_interface/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/telecomms/server_interface/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/weapon/pen))
		to_chat(user, "<span class='notice'>You insert \the [W]'s tip into \the [src]'s reset hole.</span>")
		if(do_after(user, 50, target=src))
			to_chat(user, "<span class='notice'>You reset \the [src].</span>")
			ui_elements = list("text~Welcome. The telecomms server has not been configured to display a UI on this server interface. Press init to send \"init\" signal to server.","button~Init~init")
		else
			to_chat(user, "<span class='warning'>You pull \the [W] out too early, and fail to reset it</span>")
	else
		..()

/obj/machinery/computer/telecomms/server_interface/interact(mob/user)
	user.set_machine(src)
	var/dat
	var/window_width = 500
	var/window_height = 400
	for(var/element_text in ui_elements)
		if(!istext(element_text))
			return
		var/list/element = splittext(element_text,"~")
		if(element.len < 1)
			continue
		switch(element[1])
			if("text") // Text. Format: "text~Some Message"
				if(element.len < 2)
					continue
				dat += element[2]
			if("button") // Just a button. Format: "button~Label~id"
				if(element.len < 3)
					continue
				dat += "<a href='?src=\ref[src];button=[element[3]]'>[element[2]]</a>"
			if("input") // A button that asks for an input from user. Format: "input~Label~id~title~query~default" Last 3 are optional
				if(element.len < 3)
					continue
				var/input_title = "telecommunications server interface"
				var/input_query = "Please enter text"
				var/input_default = ""
				if(element.len >= 4)
					input_query = element[4]
				if(element.len >= 5)
					input_default = element[5]
				if(element.len >= 6)
					input_title = element[6]
				dat += "<a href='?src=\ref[src];input=[element[3]];inputQuery=[input_query];inputDefault=[input_default];inputTitle = [input_title]'>[element[2]]</a>"
			if("winsize") // Change window's size. Format: "winsize~h or w~value"
				if(element.len < 3)
					continue
				var/num = text2num(element[3])
				if(element[2] == "w" && num < 900 && num > 100)
					window_width = num
				if(element[2] == "h" && num < 900 && num > 100)
					window_height = num

	var/datum/browser/popup = new(user, "server_interface", name, window_width, window_height)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/telecomms/server_interface/Topic(href, href_list)
	if(..())
		return

	if(href_list["button"])
		notify_subscribers(href_list["button"])
	if(href_list["input"])
		var/val = input(href_list["inputQuery"],href_list["inputTitle"],href_list["inputDefault"]) as text
		if(val)
			notify_subscribers("[href_list["input"]]:[val]")

/obj/machinery/computer/telecomms/server_interface/server_interface(var/list/argslist)
	ui_elements = argslist
	updateUsrDialog()
