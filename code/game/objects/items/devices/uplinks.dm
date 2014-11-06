//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

var/list/world_uplinks = list()

/obj/item/device/uplink
	var/welcome 					// Welcoming menu message
	var/uses 						// Numbers of crystals
	// List of items not to shove in their hands.
	var/purchase_log = ""
	var/show_description = null
	var/active = 0
	var/job = null

	var/uplink_owner = null//text-only
	var/used_TC = 0

/obj/item/device/uplink/New()
	..()
	world_uplinks+=src
	welcome = ticker.mode.uplink_welcome
	uses = ticker.mode.uplink_uses

/obj/item/device/uplink/Del()
	world_uplinks-=src
	..()

//Let's build a menu!
/obj/item/device/uplink/proc/generate_menu(mob/user as mob)
	if(!job)
		job = user.mind.assigned_role
	var/dat = "<B>[src.welcome]</B><BR>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\uplinks.dm:26: dat += "Tele-Crystals left: [src.uses]<BR>"
	dat += {"Tele-Crystals left: [src.uses]<BR>
		<HR>
		<B>Request item:</B><BR>
		<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"}
	// END AUTOFIX
	var/list/buyable_items = get_uplink_items()

	// Loop through categories
	var/index = 0
	for(var/category in buyable_items)

		index++
		dat += "<b>[category]</b><br>"

		var/i = 0

		// Loop through items in category
		for(var/datum/uplink_item/item in buyable_items[category])
			i++

			var/cost_text = ""
			var/desc = "[item.desc]"
			if(item.job && item.job.len)
				if(!(item.job.Find(job)))
					//world.log << "Skipping job item that doesn't match"
					continue
				else
					//world.log << "Found matching job item"
			if(item.cost > 0)
				cost_text = "([item.cost])"
			if(item.cost <= uses)
				dat += "<A href='byond://?src=\ref[src];buy_item=[category]:[i];'>[item.name]</A> [cost_text] "
			else
				dat += "<font color='grey'><i>[item.name] [cost_text] </i></font>"
			if(item.desc)
				if(show_description == 2)
					dat += "<A href='byond://?src=\ref[src];show_desc=1'><font size=2>\[-\]</font></A><BR><font size=2>[desc]</font>"
				else
					dat += "<A href='byond://?src=\ref[src];show_desc=2'><font size=2>\[?\]</font></A>"
			dat += "<BR>"

		// Break up the categories, if it isn't the last.
		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR>"
	return dat

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/interact(mob/user as mob)

	var/dat = "<body link='yellow' alink='white' bgcolor='#601414'><font color='white'>"
	dat += src.generate_menu(user)

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\uplinks.dm:72: dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</a>"
	dat += {"<A href='byond://?src=\ref[src];lock=1'>Lock</a>
		</font></body>"}
	// END AUTOFIX
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return


/obj/item/device/uplink/Topic(href, href_list)
	..()
	if(!active)
		return

	if (href_list["buy_item"])

		var/item = href_list["buy_item"]
		var/list/split = text2list(item, ":") // throw away variable

		if(split.len == 2)
			// Collect category and number
			var/category = split[1]
			var/number = text2num(split[2])

			var/list/buyable_items = get_uplink_items()

			var/list/uplink = buyable_items[category]
			if(uplink && uplink.len >= number)
				var/datum/uplink_item/I = uplink[number]
				if(I)
					I.buy(src, usr)
			else
				var/text = "[key_name(usr)] tried to purchase an uplink item that doesn't exist"
				var/textalt = "[key_name(usr)] tried to purchase an uplink item that doesn't exist [item]"
				message_admins(text)
				log_game(textalt)
				admin_log.Add(textalt)

	else if(href_list["show_desc"])
		show_description = text2num(href_list["show_desc"])
		interact(usr)

// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "Hidden Uplink."
	desc = "There is something wrong if you're examining this."

/obj/item/device/uplink/hidden/Topic(href, href_list)
	..()
	if(href_list["lock"])
		toggle()
		usr << browse(null, "window=hidden")
		return 1

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user as mob)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user as mob, var/value, var/target)
	if(value == target)
		trigger(user)
		return 1
	return 0

/*
/*
	NANO UI FOR UPLINK WOOP WOOP
*/
/obj/item/device/uplink/hidden/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/title = "Syndicate Uplink"
	var/data[0]

	data["crystals"] = uses
	data["nano_items"] = nanoui_items
	data["welcome"] = welcome

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "uplink.tmpl", title, 450, 600)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/hidden/interact(mob/user)

	ui_interact(user)

// The purchasing code.
/obj/item/device/uplink/hidden/Topic(href, href_list)
	if (usr.stat || usr.restrained())
		return

	if (!( istype(usr, /mob/living/carbon/human)))
		return 0
	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
	if ((usr.contents.Find(src.loc) || (in_range(src.loc, usr) && istype(src.loc.loc, /turf))))
		usr.set_machine(src)
		if(href_list["lock"])
			toggle()
			ui.close()
			return 1

		if(..(href, href_list) == 1)

			if(!(href_list["buy_item"] in valid_items))
				return

			var/path_obj = text2path(href_list["buy_item"])

			var/obj/I = new path_obj(get_turf(usr))
			if(ishuman(usr))
				var/mob/living/carbon/human/A = usr
				A.put_in_any_hand_if_possible(I)
			purchase_log += "[usr] ([usr.ckey]) bought [I]."
	interact(usr)
	return 1

*/

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	hidden_uplink = new(src)
	icon_state = "radio"

/obj/item/device/radio/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/multitool/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 20
