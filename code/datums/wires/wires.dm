// Wire datums. Created by Giacomand.
// Was created to replace a horrible case of copy and pasted code with no care for maintability.
// Goodbye Door wires, Cyborg wires, Vending Machine wires, Autolathe wires
// Protolathe wires, APC wires and Camera wires!

#define MAX_FLAG 65535

var/list/same_wires = list()
// 12 colours, if you're adding more than 12 wires then add more colours here
var/list/wireColours = list("red", "blue", "green", "black", "orange", "brown", "gold", "gray", "cyan", "navy", "purple", "pink")

/datum/wires

	var/random = 0 // Will the wires be different for every single instance.
	var/atom/holder = null // The holder
	var/holder_type = null // The holder type; used to make sure that the holder is the correct type.
	var/wire_count = 0 // Max is 16
	var/wires_status = 0 // BITFLAG OF WIRES

	var/list/wires = list()
	var/list/signallers = list()

	var/table_options = " align='center'"
	var/row_options1 = " width='80px'"
	var/row_options2 = " width='260px'"
	var/window_x = 370
	var/window_y = 470

/datum/wires/New(atom/holder)
	..()
	src.holder = holder
	if(!istype(holder, holder_type))
		CRASH("Our holder is null/the wrong type!")
		return

	// Generate new wires
	if(random)
		GenerateWires()
	// Get the same wires
	else
		// We don't have any wires to copy yet, generate some and then copy it.
		if(!same_wires[holder_type])
			GenerateWires()
			same_wires[holder_type] = src.wires.Copy()
		else
			var/list/wires = same_wires[holder_type]
			src.wires = wires // Reference the wires list.

/datum/wires/Destroy()
	holder = null
	return ..()

/datum/wires/proc/GenerateWires()
	var/list/colours_to_pick = wireColours.Copy() // Get a copy, not a reference.
	var/list/indexes_to_pick = list()
	//Generate our indexes
	for(var/i = 1; i < MAX_FLAG && i < (1 << wire_count); i += i)
		indexes_to_pick += i
	colours_to_pick.len = wire_count // Downsize it to our specifications.

	while(colours_to_pick.len && indexes_to_pick.len)
		// Pick and remove a colour
		var/colour = pick_n_take(colours_to_pick)

		// Pick and remove an index
		var/index = pick_n_take(indexes_to_pick)

		src.wires[colour] = index
		//wires = shuffle(wires)

/datum/wires/proc/get_status()
	return list()

/datum/wires/proc/Interact(mob/user)
	if(user && istype(user) && holder && CanUse(user))
		ui_interact(user)

/datum/wires/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "wires.tmpl", holder.name, window_x, window_y)
		ui.open()

/datum/wires/ui_data(mob/user, ui_key = "main", datum/topic_state/state = physical_state)
	var/data[0]
	var/list/replace_colours = null
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(eyes && H.disabilities & COLOURBLIND)
			replace_colours = eyes.replace_colours


	var/list/W[0]
	for(var/colour in wires)
		var/new_colour = colour
		var/colour_name = colour
		if(colour in replace_colours)
			new_colour = replace_colours[colour]
			if(new_colour in LIST_REPLACE_RENAME)
				colour_name = LIST_REPLACE_RENAME[new_colour]
			else
				colour_name = new_colour
		else
			new_colour = colour
			colour_name = new_colour
		W[++W.len] = list("colour_name" = capitalize(colour_name), "seen_colour" = capitalize(new_colour),"colour" = capitalize(colour), "cut" = IsColourCut(colour), "index" = can_see_wire_index(user) ? GetWireName(GetIndex(colour)) : null, "attached" = IsAttached(colour))

	if(W.len > 0)
		data["wires"] = W

	var/list/status = get_status()
	if(replace_colours)
		var/i
		for(i=1, i<=status.len, i++)
			for(var/colour in replace_colours)
				var/new_colour = replace_colours[colour]
				if(new_colour in LIST_REPLACE_RENAME)
					new_colour = LIST_REPLACE_RENAME[new_colour]
				if(findtext(status[i],colour))
					status[i] = replacetext(status[i],colour,new_colour)
					break
	data["status_len"] = status.len
	data["status"] = status

	return data

/datum/wires/nano_host()
	return holder

/datum/wires/proc/can_see_wire_index(mob/user)
	if(user.can_admin_interact())
		return TRUE
	else if(istype(user.get_active_hand(), /obj/item/multitool))
		var/obj/item/multitool/M = user.get_active_hand()
		if(M.shows_wire_information)
			return TRUE

	return FALSE

/datum/wires/Topic(href, href_list)
	if(..())
		return 1
	var/mob/L = usr
	if(CanUse(L) && href_list["action"])
		var/obj/item/I = L.get_active_hand()
		var/colour = lowertext(href_list["wire"])
		holder.add_hiddenprint(L)
		switch(href_list["action"])
			if("cut") // Toggles the cut/mend status
				if(istype(I, /obj/item/wirecutters) || L.can_admin_interact())
					if(istype(I))
						playsound(holder, I.usesound, 20, 1)
					CutWireColour(colour)
				else
					to_chat(L, "<span class='error'>You need wirecutters!</span>")
			if("pulse")
				if(istype(I, /obj/item/multitool) || L.can_admin_interact())
					playsound(holder, 'sound/weapons/empty.ogg', 20, 1)
					PulseColour(colour)
				else
					to_chat(L, "<span class='error'>You need a multitool!</span>")
			if("attach")
				if(IsAttached(colour))
					var/obj/item/O = Detach(colour)
					if(O)
						L.put_in_hands(O)
				else
					if(istype(I, /obj/item/assembly/signaler))
						if(L.drop_item())
							Attach(colour, I)
						else
							to_chat(L, "<span class='warning'>[L.get_active_hand()] is stuck to your hand!</span>")
					else
						to_chat(L, "<span class='error'>You need a remote signaller!</span>")

	SSnanoui.update_uis(src)
	return 1

//
// Overridable Procs
//

// Called when wires cut/mended.
/datum/wires/proc/UpdateCut(index, mended)
	if(holder)
		SSnanoui.update_uis(holder)

// Called when wire pulsed. Add code here.
/datum/wires/proc/UpdatePulsed(index)
	if(holder)
		SSnanoui.update_uis(holder)

/datum/wires/proc/CanUse(mob/L)
	return 1

/datum/wires/CanUseTopic(mob/user, datum/topic_state/state)
	if(!CanUse(user))
		return STATUS_CLOSE
	return ..()

// Example of use:
/*

var/const/BOLTED= 1
var/const/SHOCKED = 2
var/const/SAFETY = 4
var/const/POWER = 8

/datum/wires/door/UpdateCut(var/index, var/mended)
	var/obj/machinery/door/airlock/A = holder
	switch(index)
		if(BOLTED)
		if(!mended)
			A.bolt()
	if(SHOCKED)
		A.shock()
	if(SAFETY )
		A.safety()

*/


//
// Helper Procs
//

/datum/wires/proc/PulseColour(colour)
	PulseIndex(GetIndex(colour))

/datum/wires/proc/PulseIndex(index)
	if(IsIndexCut(index))
		return
	UpdatePulsed(index)

/datum/wires/proc/GetIndex(colour)
	if(wires[colour])
		var/index = wires[colour]
		return index
	else
		CRASH("[colour] is not a key in wires.")

/datum/wires/proc/GetWireName(index)
	return

//
// Is Index/Colour Cut procs
//

/datum/wires/proc/IsColourCut(colour)
	var/index = GetIndex(colour)
	return IsIndexCut(index)

/datum/wires/proc/IsIndexCut(index)
	return (index & wires_status)

//
// Signaller Procs
//

/datum/wires/proc/IsAttached(colour)
	if(signallers[colour])
		return 1
	return 0

/datum/wires/proc/GetAttached(colour)
	if(signallers[colour])
		return signallers[colour]
	return null

/datum/wires/proc/Attach(colour, obj/item/assembly/signaler/S)
	if(colour && S)
		if(!IsAttached(colour))
			signallers[colour] = S
			S.loc = holder
			S.connected = src
			return S

/datum/wires/proc/Detach(colour)
	if(colour)
		var/obj/item/assembly/signaler/S = GetAttached(colour)
		if(S)
			signallers -= colour
			S.connected = null
			S.loc = holder.loc
			return S


/datum/wires/proc/Pulse(obj/item/assembly/signaler/S)

	for(var/colour in signallers)
		if(S == signallers[colour])
			PulseColour(colour)
			break


//
// Cut Wire Colour/Index procs
//

/datum/wires/proc/CutWireColour(colour)
	var/index = GetIndex(colour)
	CutWireIndex(index)

/datum/wires/proc/CutWireIndex(index)
	if(IsIndexCut(index))
		wires_status &= ~index
		UpdateCut(index, 1)
	else
		wires_status |= index
		UpdateCut(index, 0)

/datum/wires/proc/RandomCut()
	var/r = rand(1, wires.len)
	CutWireIndex(r)

/datum/wires/proc/CutAll()
	for(var/i = 1; i < MAX_FLAG && i < (1 << wire_count); i += i)
		CutWireIndex(i)

/datum/wires/proc/IsAllCut()
	if(wires_status == (1 << wire_count) - 1)
		return 1
	return 0

//
//Shuffle and Mend
//

/datum/wires/proc/Shuffle()
	wires_status = 0
	GenerateWires()