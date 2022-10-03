////////////////////////////////
//	Multitool menu UI
////////////////////////////////
/datum/multitool_menu_host
	/// The multitool
	var/obj/item/multitool/multitool
	/// multitool_menu of an attached object
	var/datum/multitool_menu/attached_menu

/datum/multitool_menu_host/New(obj/item/multitool/multitool)
	..()
	if(!istype(multitool))
		CRASH("My multitool is null/the wrong type!")
	src.multitool = multitool

/datum/multitool_menu_host/Destroy()
	disconnect()
	multitool = null
	return ..()

/datum/multitool_menu_host/proc/disconnect()
	if(attached_menu)
		attached_menu.multitool = null
	attached_menu = null

/datum/multitool_menu_host/proc/get_menu_id(mob/user)
	/*!
	Which menu should be opened for the currently attached object
	*/
	if(!attached_menu)
		// No thing to configure
		return "default_no_machine"
	if(get_dist(user, attached_menu.holder) > 1)
		// User is too far away from the thing
		disconnect()
		return "default_no_machine"
	if(attached_menu.inoperable())
		disconnect()
		return "default_no_machine"
	if(multitool.allowed(user))
		return attached_menu.menu_id
	else
		return "access_denied"

/datum/multitool_menu_host/proc/interact(mob/user, datum/multitool_menu/attached_menu)
	src.attached_menu = attached_menu
	ui_interact(user)

/datum/multitool_menu_host/proc/notify_if_no_access(mob/user)
	if(!multitool.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE
	return FALSE

/datum/multitool_menu_host/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Multitool", multitool.name, 510, 420, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/multitool_menu_host/ui_act(action, list/params)
	if(..())
		return
	if(notify_if_no_access(usr))
		return
	. = TRUE
	switch(action)
		if("buffer_add")
			if(attached_menu && attached_menu.holder != multitool.buffer)
				multitool.buffer = attached_menu.holder
		if("buffer_flush")
			multitool.buffer = null
		else
			return attached_menu?._ui_act(usr, action, params)

/datum/multitool_menu_host/ui_data(mob/user)
	var/list/data = list()
	// Multitool data
	data["buffer"] = multitool.buffer ? TRUE : FALSE
	data["bufferName"] = multitool.buffer?.name
	data["bufferTag"] = multitool.buffer?.multitool_menu?.get_tag()
	data["canBufferHaveTag"] = istype(multitool.buffer?.multitool_menu, /datum/multitool_menu/idtag)
	// Other object's data
	var/menu_id = get_menu_id(user)
	data["multitoolMenuId"] = menu_id
	data["attachedName"] = attached_menu?.holder.name
	data["isAttachedAlreadyInBuffer"] = attached_menu && attached_menu.holder == multitool.buffer
	if(menu_id == "access_denied" || menu_id == "default_no_machine")
		return data
	var/list/menu_data = attached_menu?._ui_data()
	if(menu_data)
		data.Add(menu_data)
	return data

/datum/multitool_menu_host/ui_close(mob/user)
	disconnect()
	return ..()

/datum/multitool_menu_host/ui_host()
	return multitool

////////////////////////////////
//	Multitool menu
//  ABSTRACT
////////////////////////////////
/datum/multitool_menu
	/// The object the state of which can be changed via the multitool menu.
	var/obj/machinery/holder
	/// The holder type; used to make sure that the holder is the correct type.
	var/holder_type
	/// Which menu should be opened for the holder. For example "default_no_machine".
	var/menu_id
	/// The multitool that is currently attached to the object.
	/// Do not apply any changes while this is null.
	var/obj/item/multitool/multitool

/datum/multitool_menu/New(obj/machinery/holder)
	..()
	if(!istype(holder, holder_type))
		CRASH("My holder is null/the wrong type!")
	src.holder = holder

/datum/multitool_menu/Destroy()
	multitool?.menu.disconnect()
	multitool = null
	holder = null
	return ..()

/datum/multitool_menu/proc/inoperable()
	if(!ismachinery(holder))
		return FALSE
	var/obj/machinery/my_holder = holder
	return my_holder.inoperable()

/datum/multitool_menu/proc/interact(mob/user, obj/item/multitool/multitool)
	if(!menu_id)
		return
	if(!istype(user))
		return
	if(!istype(multitool))
		return
	holder.add_fingerprint(user)
	if(inoperable())
		to_chat(user, "<span class='warning'>You attach [multitool] to [holder], but nothing happens. [holder] seems to be inoperable.</span>")
		return
	src.multitool = multitool
	src.multitool.menu.interact(user, src)

/datum/multitool_menu/proc/_ui_act(mob/user, action, list/params)
	return FALSE

/datum/multitool_menu/proc/_ui_data()
	return

/datum/multitool_menu/proc/get_tag()
	return

/datum/multitool_menu/proc/notify_if_cannot_apply(mob/user)
	/*!
	Used to check if we still need to apply changes (returns true if we don't), e.g. after input() call.
	*/
	if(!multitool)
		to_chat(user, "<span class='warning'>You are unable to reach [holder ? holder : "the thing"].</span>")
		return TRUE
	return FALSE

/datum/multitool_menu/proc/service_message(txt, class="warning")
	multitool?.visible_message("<span class=[class]>[multitool] beeps: [txt]</span>")

////////////////////////////////
//	Multitool menu "tag_only"
//  ABSTRACT
////////////////////////////////
/datum/multitool_menu/idtag
	menu_id = "tag_only"

/datum/multitool_menu/idtag/_ui_data()
	var/list/data = list()
	. = ..()
	if(.)
		data.Add(.)
	data["attachedTag"] = get_tag()
	return data

/datum/multitool_menu/idtag/_ui_act(mob/user, action, list/params)
	. = TRUE
	switch(action)
		if("set_tag")
			var/new_tag = enter_new_tag(user)
			if(!new_tag || notify_if_cannot_apply(user))
				return FALSE
			set_tag(new_tag)
		if("clear_tag")
			set_tag(null)
		else
			return ..()

/datum/multitool_menu/idtag/proc/set_tag(new_tag)
	return

/datum/multitool_menu/idtag/proc/enter_new_tag(mob/user)
	var/title = "ID Tag"
	var/message = "Enter an ID tag"
	var/current_tag = get_tag()
	var/default = current_tag ? current_tag : ""
	return reject_bad_text(stripped_input(user=user, message=message, title=title, default=default))

////////////////////////////////
//	Mass driver
////////////////////////////////
/datum/multitool_menu/idtag/mass_driver
	holder_type = /obj/machinery/mass_driver
	
/datum/multitool_menu/idtag/mass_driver/get_tag()
	var/obj/machinery/mass_driver/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/mass_driver/set_tag(new_tag)
	var/obj/machinery/mass_driver/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	my_holder.id_tag = new_tag

////////////////////////////////
//	Mass driver button
////////////////////////////////
/datum/multitool_menu/idtag/driver_button
	holder_type = /obj/machinery/driver_button

/datum/multitool_menu/idtag/driver_button/get_tag()
	var/obj/machinery/driver_button/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/driver_button/set_tag(new_tag)
	var/obj/machinery/driver_button/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	my_holder.id_tag = new_tag

////////////////////////////////
//	Multitool menu "frequency_and_tag"
//  ABSTRACT
////////////////////////////////
/datum/multitool_menu/idtag/freq
	menu_id = "frequency_and_tag"

/datum/multitool_menu/idtag/freq/_ui_data()
	var/list/data = list()
	. = ..()
	if(.)
		data.Add(.)
	var/my_frequency = get_frequency()
	var/my_default_frequency = get_default_frequency()
	data["frequency"] = my_frequency
	data["minFrequency"] = RADIO_LOW_FREQ
	data["maxFrequency"] = RADIO_HIGH_FREQ
	data["canReset"] = my_frequency == my_default_frequency ? FALSE : TRUE
	return data

/datum/multitool_menu/idtag/freq/_ui_act(mob/user, action, list/params)
	. = TRUE
	switch(action)
		if("set_frequency")
			var/new_frequency = text2num(params["frequency"])
			set_frequency(sanitize_frequency(new_frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ))
		if("reset_frequency")
			set_frequency(get_default_frequency())
		else
			return ..()

/datum/multitool_menu/idtag/freq/proc/get_frequency()
	return

/datum/multitool_menu/idtag/freq/proc/get_default_frequency()
	return

/datum/multitool_menu/idtag/freq/proc/set_frequency(new_frequency)
	return

/datum/multitool_menu/idtag/freq/proc/get_all_air_sensor_tags(frequency)
	var/list/tags = list()
	if(!frequency)
		return tags
	for(var/obj/machinery/air_sensor/sensor in GLOB.machines)
		if(!(sensor.id_tag && sensor.frequency == frequency))
			continue
		tags |= sensor.id_tag
	return tags

////////////////////////////////
//	vent_pump
////////////////////////////////
/datum/multitool_menu/idtag/freq/vent_pump
	holder_type = /obj/machinery/atmospherics/unary/vent_pump
	
/datum/multitool_menu/idtag/freq/vent_pump/get_tag()
	var/obj/machinery/atmospherics/unary/vent_pump/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/freq/vent_pump/set_tag(new_tag)
	if(!new_tag)
		service_message("The ID tag of [holder] cannot be null.")
		return
	var/obj/machinery/atmospherics/unary/vent_pump/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	my_holder.set_tag(new_tag)

/datum/multitool_menu/idtag/freq/vent_pump/get_frequency()
	var/obj/machinery/atmospherics/unary/vent_pump/my_holder = holder
	return my_holder.frequency

/datum/multitool_menu/idtag/freq/vent_pump/get_default_frequency()
	var/obj/machinery/atmospherics/unary/vent_pump/my_holder = holder
	return initial(my_holder.frequency)

/datum/multitool_menu/idtag/freq/vent_pump/set_frequency(new_frequency)
	var/obj/machinery/atmospherics/unary/vent_pump/my_holder = holder
	if(my_holder.frequency == new_frequency)
		return
	my_holder.set_frequency(new_frequency)

////////////////////////////////
//	vent_scrubber
////////////////////////////////
/datum/multitool_menu/idtag/freq/vent_scrubber
	holder_type = /obj/machinery/atmospherics/unary/vent_scrubber
	
/datum/multitool_menu/idtag/freq/vent_scrubber/get_tag()
	var/obj/machinery/atmospherics/unary/vent_scrubber/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/freq/vent_scrubber/set_tag(new_tag)
	if(!new_tag)
		service_message("The ID tag of [holder] cannot be null.")
		return
	var/obj/machinery/atmospherics/unary/vent_scrubber/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	my_holder.set_tag(new_tag)

/datum/multitool_menu/idtag/freq/vent_scrubber/get_frequency()
	var/obj/machinery/atmospherics/unary/vent_scrubber/my_holder = holder
	return my_holder.frequency

/datum/multitool_menu/idtag/freq/vent_scrubber/get_default_frequency()
	var/obj/machinery/atmospherics/unary/vent_scrubber/my_holder = holder
	return initial(my_holder.frequency)

/datum/multitool_menu/idtag/freq/vent_scrubber/set_frequency(new_frequency)
	var/obj/machinery/atmospherics/unary/vent_scrubber/my_holder = holder
	if(my_holder.frequency == new_frequency)
		return
	my_holder.set_frequency(new_frequency)

////////////////////////////////
//	outlet_injector
////////////////////////////////
/datum/multitool_menu/idtag/freq/outlet_injector
	holder_type = /obj/machinery/atmospherics/unary/outlet_injector
	
/datum/multitool_menu/idtag/freq/outlet_injector/get_tag()
	var/obj/machinery/atmospherics/unary/outlet_injector/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/freq/outlet_injector/set_tag(new_tag)
	var/obj/machinery/atmospherics/unary/outlet_injector/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	my_holder.id_tag = new_tag

/datum/multitool_menu/idtag/freq/outlet_injector/get_frequency()
	var/obj/machinery/atmospherics/unary/outlet_injector/my_holder = holder
	return my_holder.frequency

/datum/multitool_menu/idtag/freq/outlet_injector/get_default_frequency()
	var/obj/machinery/atmospherics/unary/outlet_injector/my_holder = holder
	return initial(my_holder.frequency)

/datum/multitool_menu/idtag/freq/outlet_injector/set_frequency(new_frequency)
	var/obj/machinery/atmospherics/unary/outlet_injector/my_holder = holder
	if(my_holder.frequency == new_frequency)
		return
	my_holder.set_frequency(new_frequency)

////////////////////////////////
//	dp_vent_pump
////////////////////////////////
/datum/multitool_menu/idtag/freq/dp_vent_pump
	holder_type = /obj/machinery/atmospherics/binary/dp_vent_pump
	
/datum/multitool_menu/idtag/freq/dp_vent_pump/get_tag()
	var/obj/machinery/atmospherics/binary/dp_vent_pump/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/freq/dp_vent_pump/set_tag(new_tag)
	var/obj/machinery/atmospherics/binary/dp_vent_pump/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	my_holder.id_tag = new_tag

/datum/multitool_menu/idtag/freq/dp_vent_pump/get_frequency()
	var/obj/machinery/atmospherics/binary/dp_vent_pump/my_holder = holder
	return my_holder.frequency

/datum/multitool_menu/idtag/freq/dp_vent_pump/get_default_frequency()
	var/obj/machinery/atmospherics/binary/dp_vent_pump/my_holder = holder
	return initial(my_holder.frequency)

/datum/multitool_menu/idtag/freq/dp_vent_pump/set_frequency(new_frequency)
	var/obj/machinery/atmospherics/binary/dp_vent_pump/my_holder = holder
	if(my_holder.frequency == new_frequency)
		return
	my_holder.set_frequency(new_frequency)

////////////////////////////////
//	air_sensor
////////////////////////////////
/datum/multitool_menu/idtag/freq/air_sensor
	holder_type = /obj/machinery/air_sensor
	menu_id = "air_sensor"

/datum/multitool_menu/idtag/freq/air_sensor/_ui_data()
	var/list/data = list()
	. = ..()
	if(.)
		data.Add(.)
	var/obj/machinery/air_sensor/my_holder = holder
	data["bolts"] = my_holder.bolts
	data["pressureCheck"] = my_holder.output & 1
	data["temperatureCheck"] = my_holder.output & 2
	data["oxygenCheck"] = my_holder.output & 4
	data["toxinsCheck"] = my_holder.output & 8
	data["nitrogenCheck"] = my_holder.output & 16
	data["carbonDioxideCheck"] = my_holder.output & 32
	return data

/datum/multitool_menu/idtag/freq/air_sensor/_ui_act(mob/user, action, list/params)
	. = TRUE
	switch(action)
		if("toggle_bolts")
			toggle_bolts()
		if("toggle_flag")
			var/bitflag = text2num(params["bitflag"])
			toggle_out_flag(bitflag)
		else
			return ..()

/datum/multitool_menu/idtag/freq/air_sensor/get_tag()
	var/obj/machinery/air_sensor/my_holder = holder
	return my_holder.id_tag

/datum/multitool_menu/idtag/freq/air_sensor/set_tag(new_tag)
	var/obj/machinery/air_sensor/my_holder = holder
	if(my_holder.id_tag == new_tag)
		return
	if(!is_unique_tag(new_tag, my_holder.frequency))
		service_message("There is already the same ID tag on this frequency.")
		return
	my_holder.id_tag = new_tag

/datum/multitool_menu/idtag/freq/air_sensor/get_frequency()
	var/obj/machinery/air_sensor/my_holder = holder
	return my_holder.frequency

/datum/multitool_menu/idtag/freq/air_sensor/get_default_frequency()
	var/obj/machinery/air_sensor/my_holder = holder
	return initial(my_holder.frequency)

/datum/multitool_menu/idtag/freq/air_sensor/set_frequency(new_frequency)
	var/obj/machinery/air_sensor/my_holder = holder
	if(my_holder.frequency == new_frequency)
		return
	if(!is_unique_tag(my_holder.id_tag, new_frequency))
		service_message("There is already the same ID tag on this frequency.")
		return
	my_holder.set_frequency(new_frequency)

/datum/multitool_menu/idtag/freq/air_sensor/proc/toggle_out_flag(bitflag_value)
	var/obj/machinery/air_sensor/my_holder = holder
	my_holder.toggle_out_flag(bitflag_value)

/datum/multitool_menu/idtag/freq/air_sensor/proc/toggle_bolts()
	var/obj/machinery/air_sensor/my_holder = holder
	my_holder.toggle_bolts()

/datum/multitool_menu/idtag/freq/air_sensor/proc/is_unique_tag(tag, frequency)
	/*!
	The id_tag of an air_sensor must be unique.
	If there are two identical tags, it is undefined which sensor data will be output to the console.
	*/
	if(!tag)
		return TRUE
	var/tags_on_freq = get_all_air_sensor_tags(frequency)
	if(tag in tags_on_freq)
		return FALSE
	return TRUE

////////////////////////////////
//	general_air_control
//  Does not use the id_tag stuff, only the frequency stuff.
////////////////////////////////
/datum/multitool_menu/idtag/freq/general_air_control
	holder_type = /obj/machinery/computer/general_air_control
	menu_id = "general_air_control"

/datum/multitool_menu/idtag/freq/general_air_control/_ui_data()
	var/list/data = list()
	. = ..()
	if(.)
		data.Add(.)
	var/obj/machinery/computer/general_air_control/my_holder = holder
	data["sensors"] = my_holder.sensors
	return data

/datum/multitool_menu/idtag/freq/general_air_control/_ui_act(mob/user, action, list/params)
	. = TRUE
	switch(action)
		if("add_sensor")
			var/obj/machinery/computer/general_air_control/my_holder = holder
			var/frequency = get_frequency()
			var/list/sensors = get_all_air_sensor_tags(frequency) - my_holder.sensors
			if(!length(sensors))
				service_message("No sensors on this frequency.")
				return FALSE
			var/sensor_tag = input(user, "Select a sensor", "Sensors on the frequency") as null|anything in sensors
			if(!sensor_tag || notify_if_cannot_apply(user))
				return FALSE
			add_sensor(sensor_tag)
		if("del_sensor")
			var/sensor_tag = params["sensor_tag"]
			del_sensor(sensor_tag)
		if("change_label")
			var/sensor_tag = params["sensor_tag"]
			var/new_label = enter_new_label(user, sensor_tag)
			if(!new_label || notify_if_cannot_apply(user))
				return FALSE
			change_label(sensor_tag, new_label)
		if("clear_label")
			var/sensor_tag = params["sensor_tag"]
			change_label(sensor_tag, "")
		if("set_frequency")
			// vent pumps on ATMOS_VENTSCRUB frequency use a different radio filter and cannot communicate with air_control consoles
			if(text2num(params["frequency"]) == ATMOS_VENTSCRUB)
				service_message("This frequency is reserved. Try another one.")
				return FALSE
			return ..()
		else
			return ..()

/datum/multitool_menu/idtag/freq/general_air_control/proc/enter_new_label(mob/user, sensor_tag)
	var/obj/machinery/computer/general_air_control/my_holder = holder
	var/title = "Sensor label"
	var/message = "Choose a sensor label"
	var/default = my_holder.sensors[sensor_tag]
	return reject_bad_text(stripped_input(user=user, message=message, title=title, default=default))

/datum/multitool_menu/idtag/freq/general_air_control/get_frequency()
	var/obj/machinery/computer/general_air_control/my_holder = holder
	return my_holder.frequency

/datum/multitool_menu/idtag/freq/general_air_control/get_default_frequency()
	var/obj/machinery/computer/general_air_control/my_holder = holder
	return initial(my_holder.frequency)

/datum/multitool_menu/idtag/freq/general_air_control/set_frequency(new_frequency)
	var/obj/machinery/computer/general_air_control/my_holder = holder
	if(my_holder.frequency == new_frequency)
		return
	my_holder.set_frequency(new_frequency)

/datum/multitool_menu/idtag/freq/general_air_control/proc/add_sensor(sensor_tag)
	var/obj/machinery/computer/general_air_control/my_holder = holder
	my_holder.sensors[sensor_tag] = ""

/datum/multitool_menu/idtag/freq/general_air_control/proc/del_sensor(sensor_tag)
	var/obj/machinery/computer/general_air_control/my_holder = holder
	my_holder.sensors.Remove(sensor_tag)
	my_holder.sensor_information.Remove(sensor_tag)

/datum/multitool_menu/idtag/freq/general_air_control/proc/change_label(sensor_tag, new_label)
	var/obj/machinery/computer/general_air_control/my_holder = holder
	my_holder.sensors[sensor_tag] = new_label

////////////////////////////////
//	large_tank_control
////////////////////////////////
/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control
	holder_type = /obj/machinery/computer/general_air_control/large_tank_control
	menu_id = "large_tank_control"

/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control/_ui_data()
	var/list/data = list()
	. = ..()
	if(.)
		data.Add(.)
	var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
	data["inputTag"] = my_holder.input_tag
	data["outputTag"] = my_holder.output_tag
	data["bufferFitsInput"] = multitool ? my_holder.can_link_to_input(multitool.buffer) : FALSE
	data["bufferFitsOutput"] = multitool ? my_holder.can_link_to_output(multitool.buffer) : FALSE
	data["doNotLinkAndNotify"] = is_null_idtag() || is_idtag_already_linked()
	return data

/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control/_ui_act(mob/user, action, list/params)
	. = TRUE
	switch(action)
		if("link_input")
			if(notify_if_bad_buffer())
				return FALSE
			var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
			if(!my_holder.link_input(multitool.buffer))
				return FALSE
			frequency_change_reminder(multitool.buffer)
		if("link_output")
			if(notify_if_bad_buffer())
				return FALSE
			var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
			if(!my_holder.link_output(multitool.buffer))
				return FALSE
			frequency_change_reminder(multitool.buffer)
		if("unlink_input")
			var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
			my_holder.unlink_input()
		if("unlink_output")
			var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
			my_holder.unlink_output()
		else
			return ..()
		
/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control/proc/is_null_idtag()
	var/buffer_tag = multitool?.buffer?.multitool_menu?.get_tag()
	if(!buffer_tag)
		return TRUE
	return FALSE

/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control/proc/is_idtag_already_linked()
	var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
	var/buffer_tag = multitool?.buffer?.multitool_menu?.get_tag()
	if((buffer_tag == my_holder.input_tag) || (buffer_tag == my_holder.output_tag))
		return TRUE
	return FALSE

/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control/proc/notify_if_bad_buffer()
	if(is_null_idtag())
		service_message("The ID tag of the device must not be null.")
		return TRUE
	if(is_idtag_already_linked())
		service_message("A device with the same ID tag is already connected to [holder].")
		return TRUE
	return FALSE

/datum/multitool_menu/idtag/freq/general_air_control/large_tank_control/proc/frequency_change_reminder(obj/machinery/device_linked)
	if(!istype(device_linked.multitool_menu, /datum/multitool_menu/idtag/freq))
		return
	var/datum/multitool_menu/idtag/freq/menu_linked = device_linked.multitool_menu
	var/obj/machinery/computer/general_air_control/large_tank_control/my_holder = holder
	if(my_holder.frequency == menu_linked.get_frequency())
		return
	service_message("[holder] and [device_linked] are not on the same frequency, so they will not be able to communicate until the frequency is adjusted.", class="notice")
