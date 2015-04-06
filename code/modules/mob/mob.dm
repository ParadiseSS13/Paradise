/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	mob_list -= src
	dead_mob_list -= src
	living_mob_list -= src
	ghostize()
	..()

/mob/New()
	mob_list += src
	if(stat == DEAD)
		dead_mob_list += src
	else
		living_mob_list += src
	..()

/mob/proc/generate_name()
	return name


/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "\blue Coordinates: [x],[y] \n"
	t+= "\red Temperature: [environment.temperature] \n"
	t+= "\blue Nitrogen: [environment.nitrogen] \n"
	t+= "\blue Oxygen: [environment.oxygen] \n"
	t+= "\blue Plasma : [environment.toxins] \n"
	t+= "\blue Carbon Dioxide: [environment.carbon_dioxide] \n"
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "\blue [trace_gas.type]: [trace_gas.moles] \n"

	usr.show_message(t, 1)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)	return

	if (type)
		if(type & 1 && (sdisabilities & BLIND || blinded || paralysis) )//Vision related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if (type & 2 && (sdisabilities & DEAF || ear_deaf))//Hearing related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && sdisabilities & BLIND))
					return
	// Added voice muffling for Issue 41.
	if(stat == UNCONSCIOUS || (sleeping > 0 && stat != 2))
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		M.show_message( message, 1, blind_message, 2)

// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/mob/audible_message(var/message, var/deaf_message, var/hearing_distance, var/self_message)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	var/msg = message
	for(var/mob/M in get_mobs_in_view(range, src))
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 2, deaf_message, 1)

// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/atom/proc/audible_message(var/message, var/deaf_message, var/hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_mobs_in_view(range, src))
		M.show_message( message, 2, deaf_message, 1)

/mob/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
//	handle_typing_indicator()
//	if(organStructure)
//		organStructure.ProcessOrgans()
	return


/mob/proc/restrained()
	return

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_hand()

	if(istype(W))
		if (istype(W, /obj/item/clothing))
			var/obj/item/clothing/C = W
			if(C.rig_restrict_helmet)
				src << "\red You must fasten the helmet to a hardsuit first. (Target the head and use on a hardsuit)" // Stop eva helms equipping.
			else
				equip_to_slot_if_possible(C, slot)
		else
			equip_to_slot_if_possible(W, slot)

	if(ishuman(src) && W == src:head)
		src:update_hair()

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = 0, disable_warning = 1, redraw_mob = 1)
	if(equip_to_slot_if_possible(W, slot_l_hand, del_on_fail, disable_warning, redraw_mob))
		return 1
	else if(equip_to_slot_if_possible(W, slot_r_hand, del_on_fail, disable_warning, redraw_mob))
		return 1
	return 0



//This is a SAFE proc. Use this instead of equip_to_slot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W as obj, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1)
	if(!istype(W)) return 0

	if(!W.mob_can_equip(src, slot, disable_warning))
		if(del_on_fail)
			del(W)
		else
			if(!disable_warning)
				src << "\red You are unable to equip that." //Only print if del_on_fail is false
		return 0

	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
	return 1

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W as obj, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, 1, 1, 0)

// Convinience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(var/obj/item/W, var/slot)
	if(W.mob_can_equip(src, slot, 1))
		//Mob can equip.  Equip it.
		equip_to_slot_or_del(W, slot)
	else
		//Mob can't equip it.  Put it in a bag B.
		// Do I have a backpack?
		var/obj/item/weapon/storage/B
		if(istype(back,/obj/item/weapon/storage))
			//Mob is wearing backpack
			B = back
		else
			//not wearing backpack.  Check if player holding plastic bag
			B=is_in_hands(/obj/item/weapon/storage/bag/plasticbag)
			if(!B) //If not holding plastic bag, give plastic bag
				B=new /obj/item/weapon/storage/bag/plasticbag(null) // Null in case of failed equip.
				if(!put_in_hands(B))
					return // Bag could not be placed in players hands.  I don't know what to do here...
		//Now, B represents a container we can insert W into.
		B.handle_item_insertion(W,1)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list( \
		slot_back,\
		slot_wear_id,\
		slot_wear_pda,\
		slot_w_uniform,\
		slot_wear_suit,\
		slot_wear_mask,\
		slot_head,\
		slot_shoes,\
		slot_gloves,\
		slot_l_ear,\
		slot_r_ear,\
		slot_glasses,\
		slot_belt,\
		slot_s_store,\
		slot_tie,\
		slot_l_store,\
		slot_r_store\
	)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W)) return 0

	for(var/slot in slot_equipment_priority)
		if(istype(W,/obj/item/weapon/storage/) && slot == slot_head) // Storage items should be put on the belt before the head
			continue
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1)) //del_on_fail = 0; disable_warning = 0; redraw_mob = 1
			return 1

	return 0

/mob/proc/check_for_open_slot(obj/item/W)
	if(!istype(W)) return 0
	var/openslot = 0
	for(var/slot in slot_equipment_priority)
		if(W.mob_check_equip(src, slot, 1) == 1)
			openslot = 1
			break
	return openslot

/obj/item/proc/mob_check_equip(M as mob, slot, disable_warning = 0)
	if(!M) return 0
	if(!slot) return 0
	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M

		switch(slot)
			if(slot_l_hand)
				if(H.l_hand)
					return 0
				return 1
			if(slot_r_hand)
				if(H.r_hand)
					return 0
				return 1
			if(slot_wear_mask)
				if( !(slot_flags & SLOT_MASK) )
					return 0
				if(H.wear_mask)
					return 0
				return 1
			if(slot_back)
				if( !(slot_flags & SLOT_BACK) )
					return 0
				if(H.back)
					if(!(H.back.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_wear_suit)
				if( !(slot_flags & SLOT_OCLOTHING) )
					return 0
				if(H.wear_suit)
					if(!(H.wear_suit.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return 0
				if(H.gloves)
					if(!(H.gloves.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return 0
				if(H.shoes)
					if(!(H.shoes.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_belt)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if( !(slot_flags & SLOT_BELT) )
					return 0
				if(H.belt)
					if(!(H.belt.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_glasses)
				if( !(slot_flags & SLOT_EYES) )
					return 0
				if(H.glasses)
					if(!(H.glasses.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_head)
				if( !(slot_flags & SLOT_HEAD) )
					return 0
				if(H.head)
					if(!(H.head.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_l_ear)
				if( !(slot_flags & slot_l_ear) )
					return 0
				if(H.l_ear)
					if(!(H.l_ear.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_r_ear)
				if( !(slot_flags & slot_r_ear) )
					return 0
				if(H.r_ear)
					if(!(H.r_ear.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_w_uniform)
				if( !(slot_flags & SLOT_ICLOTHING) )
					return 0
				if((FAT in H.mutations) && !(flags & ONESIZEFITSALL))
					return 0
				if(H.w_uniform)
					if(!(H.w_uniform.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if( !(slot_flags & SLOT_ID) )
					return 0
				if(H.wear_id)
					if(!(H.wear_id.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(slot_l_store)
				if(H.l_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					return 1
			if(slot_r_store)
				if(H.r_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						H << "\red You need a jumpsuit before you can attach this [name]."
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return 0
				if( w_class <= 2 || (slot_flags & SLOT_POCKET) )
					return 1
				return 0
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						H << "\red You need a suit before you can attach this [name]."
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return 0
				if(src.w_class > 4)
					if(!disable_warning)
						usr << "The [name] is too big to attach."
					return 0
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					if(H.s_store)
						if(!(H.s_store.flags & NODROP))
							return 2
						else
							return 0
					else
						return 1
				return 0
			if(slot_handcuffed)
				if(H.handcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/restraints/handcuffs))
					return 0
				return 1
			if(slot_legcuffed)
				if(H.legcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/restraints/legcuffs))
					return 0
				return 1
			if(slot_in_backpack)
				if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(B.contents.len < B.storage_slots && w_class <= B.max_w_class)
						return 1
				return 0
		return 0 //Unsupported slot
		//END HUMAN

/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return


/mob/proc/show_inv(mob/user as mob)
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand && !(l_hand.flags & ABSTRACT)) ? l_hand  : "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand && !(r_hand.flags & ABSTRACT)) ? r_hand : "Nothing"]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back && !(back.flags & ABSTRACT)) ? back : "Nothing"]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob\ref[src]")
	return

/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/effect/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				del(L)
				return temp
			else
				return L.container
	return


/mob/verb/mode()
	set name = "Activate Held Object"
	set category = null
	set src = usr

	if(istype(loc,/obj/mecha)) return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/


/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		usr << "No."
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		src << "<h2 class='alert'>OOC Warning:</h2>"
		src << "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>"

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(lentext(msg) <= 40)
			return "\blue [msg]"
		else
			return "\blue [copytext(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a>"

/mob/proc/is_dead()
	return stat == DEAD


/*
/mob/verb/help()
	set name = "Help"
	src << browse('html/help.html', "window=help")
	return
*/


/mob

	var/newPlayerType = /mob/new_player

/*
/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (!( abandon_allowed ))
		usr << "\blue Respawn is disabled."
		return
	if ((stat != 2 || !( ticker )))
		usr << "\blue <B>You must be dead to use this!</B>"
		return
	if (ticker.mode.name == "meteor" || ticker.mode.name == "epidemic") //BS12 EDIT
		usr << "\blue Respawn is disabled."
		return
	else
		var/deathtime = world.time - src.timeofdeath
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		usr << "You have been dead for[pluralcheck] [deathtimeseconds] seconds."
		if (deathtime < 18000)
			usr << "You must wait 30 minutes to respawn!"
			return
		else
			usr << "You can respawn now, enjoy your new life!"

	log_game("[usr.name]/[usr.key] used abandon mob.")

	usr << "\blue <B>Make sure to play a different character, and please roleplay correctly!</B>"

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.Cut()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/newPlayer = new newPlayerType()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		del(newPlayer)
		return

	newPlayer.key = key
	return
*/
/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = 0

	if(client.holder && (client.holder.rights & R_ADMIN))
		is_admin = 1
	else if(stat != DEAD || istype(src, /mob/new_player))
		usr << "\blue You must be observing to use this!"
		return

	if(is_admin && stat == DEAD)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for(var/obj/O in world)				//EWWWWWWWWWWWWWWWWWWWWWWWW ~needs to be optimised
		if(!O.loc)
			continue
		if(istype(O, /obj/item/weapon/disk/nuclear))
			var/name = "Nuclear Disk"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/machinery/singularity))
			var/name = "Singularity"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/machinery/bot))
			var/name = "BOT: [O.name]"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O


	for(var/mob/M in sortAtom(mob_list))
		var/name = M.name
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M


	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	if(client && mob_eye)
		client.eye = mob_eye
		if (is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	unset_machine()
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["flavor_more"])
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, replacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()


//	..()
	return


/mob/proc/pull_damage()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.health - H.halloss <= config.health_threshold_softcrit)
			for(var/name in H.organs_by_name)
				var/obj/item/organ/external/e = H.organs_by_name[name]
				if(e && H.lying)
					if(((e.status & ORGAN_BROKEN && !(e.status & ORGAN_SPLINTED)) || e.status & ORGAN_BLEEDING) && (H.getBruteLoss() + H.getFireLoss() >= 100))
						return 1
						break
		return 0

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(M.small) return // Stops pAI drones and small mobs (borers, parrots, crabs) from stripping people. --DZD
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(istype(M,/mob/living/silicon/ai)) return
	show_inv(usr)


/mob/verb/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null

/mob/proc/start_pulling(var/atom/movable/AM)

	if ( !AM || !usr || src==AM || !isturf(src.loc) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	if (AM.anchored)
		return

	var/mob/M = AM
	if(ismob(AM))
		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = usr

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return

	src.pulling = AM
	AM.pulledby = src

	//Attempted fix for people flying away through space when cuffed and dragged.
	if(ismob(AM))
		var/mob/pulled = AM
		pulled.inertia_dir = 0

/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI"))
		return 1
	return istype(src, /mob/living/silicon) || get_species() == "Machine"

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/is_in_brig()
	if(!loc || !loc.loc)
		return 0

	// They should be in a cell or the Brig portion of the shuttle.
	var/area/A = loc.loc
	if(!istype(A, /area/security/prison) && !istype(A, /area/prison))
		if(!istype(A, /area/shuttle/escape) || loc.name != "Brig floor")
			return 0

	// If they still have their ID they're not brigged.
	for(var/obj/item/weapon/card/id/card in src)
		return 0
	for(var/obj/item/device/pda/P in src)
		if(P.id)
			return 0

	return 1

/mob/proc/get_gender()
	return gender

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/is_muzzled()
	return 0

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/Stat()
	..()

	if(client && client.holder)

		if(statpanel("Status"))	//not looking at that panel
			stat(null, "Location:\t([x], [y], [z])")
			stat(null, "CPU:\t[world.cpu]")
			stat(null, "Instances:\t[world.contents.len]")

			if (garbageCollector)
				stat(null, "\tqdel - [garbageCollector.del_everything ? "off" : "on"]")
				stat(null, "\ton queue - [garbageCollector.queue.len]")
				stat(null, "\ttotal delete - [garbageCollector.dels_count]")
				stat(null, "\tsoft delete - [garbageCollector.soft_dels]")
				stat(null, "\thard delete - [garbageCollector.hard_dels]")
			else
				stat(null, "Garbage Controller is not running.")

			if(processScheduler.getIsRunning())
				var/datum/controller/process/process

				process = processScheduler.getProcess("ticker")
				stat(null, "TIC\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("air")
				stat(null, "AIR\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("lighting")
				stat(null, "LIG\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("mob")
				stat(null, "MOB([mob_list.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("machinery")
				stat(null, "MAC([machines.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("obj")
				stat(null, "OBJ([processing_objects.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("bot")
				stat(null, "BOT([aibots.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("pipenet")
				stat(null, "PIP([pipe_networks.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("powernet")
				stat(null, "POW([powernets.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("nanoui")
				stat(null, "NAN([nanomanager.processing_uis.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("disease")
				stat(null, "DIS([active_diseases.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				process = processScheduler.getProcess("garbage")
				stat(null, "GAR\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("sun")
				//stat(null, "SUN\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("garbage")
				//stat(null, "GAR\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("vote")
				//stat(null, "VOT\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("shuttle controller")
				//stat(null, "SHT\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("emergency shuttle")
				//stat(null, "EME\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("inactivity")
				//stat(null, "IAC\t - #[process.getTicks()]\t - [process.getLastRunTime()]")

				//process = processScheduler.getProcess("event")
				//stat(null, "EVE([events.len])\t - #[process.getTicks()]\t - [process.getLastRunTime()]")
			else
				stat(null, "processScheduler is not running.")

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			for(var/atom/A in listed_turf)
				if(A.invisibility > see_invisible)
					continue
				if(is_type_in_list(A, shouldnt_see))
					continue
				statpanel(listed_turf.name, null, A)

	if(mind && mind.changeling)
		add_stings_to_statpanel(mind.changeling.purchasedpowers)

	if(spell_list && spell_list.len)
		for(var/obj/effect/proc_holder/spell/wizard/S in spell_list)
			switch(S.charge_type)
				if("recharge")
					statpanel(S.panel,"[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel(S.panel,"[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel(S.panel,"[S.holder_var_type] [S.holder_var_amount]",S)


/mob/proc/add_stings_to_statpanel(var/list/stings)
	for(var/obj/effect/proc_holder/changeling/S in stings)
		if(S.chemical_cost >=0 && S.can_be_used_by(src))
			statpanel("[S.panel]",((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""),S)
	/* // Why have a duplicate set of turfs in the stat panel?
	if(listed_turf)
		if(get_dist(listed_turf,src) > 1)
			listed_turf = null
		else
			statpanel(listed_turf.name,listed_turf.name,listed_turf)
			for(var/atom/A in listed_turf)
				if(A.invisibility > see_invisible)
					continue
				statpanel(listed_turf.name,A.name,A)
	*/


// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(world.time < client.move_delay)	return 0
	if(stat==2)							return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(restrained())					return 0
	return 1

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	var/ko = weakened || paralysis || stat || (status_flags & FAKEDEATH)
	if(ko || resting || buckled)
		canmove = 0
		if(!lying)
			if(resting) //Presuming that you're resting on a bed, which would look goofy lying the wrong way
				lying = 90
			else
				lying = pick(90, 270) //180 looks like shit since BYOND inverts rather than turns in that case
	else if(stunned)
		canmove = 0
	else
		lying = 0
		canmove = 1
	var/is_movable
	if(buckled && istype(buckled))
		is_movable = buckled.movable

	if(istype(buckled, /obj/vehicle))
		var/obj/vehicle/V = buckled
		if(stat || weakened || paralysis || resting || sleeping || (status_flags & FAKEDEATH))
			lying = 1
			canmove = 0
			pixel_y = V.mob_offset_y - 5
		else
			lying = 0
			canmove = 1
			pixel_y = V.mob_offset_y
	else if(buckled && (!buckled.movable))
		anchored = 1
		canmove = 0
		if( istype(buckled,/obj/structure/stool/bed/chair) )
			lying = 0
		else
			lying = 1
	else if(buckled && is_movable)
		anchored = 0
		canmove = 1
		lying = 0
	else if( stat || weakened || paralysis || resting || sleeping || (status_flags & FAKEDEATH))
		lying = 1
		canmove = 0
	else if( stunned )
		canmove = 0
	else
		lying = 0
		canmove = 1

	if(lying)
		density = 0
		drop_l_hand()
		drop_r_hand()
	else
		density = 1

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn

	if(lying != lying_prev)
		if(lying && !lying_prev)
			fall(ko)

	if(update_icon)	//forces a full overlay update
		update_icon = 0
		regenerate_icons()
	else if( lying != lying_prev )
		update_icons()

	return canmove

/mob/proc/fall(var/forced)
	drop_l_hand()
	drop_r_hand()

/mob/proc/facedir(var/ndir)
	if(!canface())	return 0
	dir = ndir
	if(buckled && buckled.movable)
		buckled.dir = ndir
		buckled.handle_rotation()
	client.move_delay += movement_delay()
	return 1


/mob/verb/eastface()
	set hidden = 1
	return facedir(EAST)


/mob/verb/westface()
	set hidden = 1
	return facedir(WEST)


/mob/verb/northface()
	set hidden = 1
	return facedir(NORTH)


/mob/verb/southface()
	set hidden = 1
	return facedir(SOUTH)


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0


/mob/proc/Jitter(amount)
	jitteriness = max(jitteriness,amount,0)

/mob/proc/Dizzy(amount)
	dizziness = max(dizziness,amount,0)

/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		update_canmove()
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
		update_canmove()
	return

/mob/proc/Weaken(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(max(weakened,amount),0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/SetWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(weakened + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(max(paralysis,amount),0)
		update_canmove()
	return

/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount,0)
		update_canmove()
	return

/mob/proc/Sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
	update_canmove()
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	update_canmove()
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	update_canmove()
	return

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
	update_canmove()
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	update_canmove()
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	update_canmove()
	return

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	flick("weak_pain",pain)

/mob/proc/get_visible_implants(var/class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.changeNext_move(CLICK_CD_RESIST)

	if(usr.stat == 1)
		usr << "You are unconcious and cannot do that!"
		return

	if(usr.restrained())
		usr << "You are restrained and cannot do that!"
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	valid_objects = get_visible_implants(0)
	if(!valid_objects.len)
		if(self)
			src << "You have nothing stuck in your body that is large enough to remove."
		else
			U << "[src] has nothing stuck in their wounds that is large enough to remove."
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		src << "<span class='warning'>You attempt to get a good grip on [selection] in your body.</span>"
	else
		U << "<span class='warning'>You attempt to get a good grip on [selection] in [S]'s body.</span>"

	if(!do_after(U, 80))
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>")
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>")
	valid_objects = get_visible_implants(0)
	if(valid_objects.len == 1) //Yanking out last object - removing verb.
		src.verbs -= /mob/proc/yank_out_object

	if(ishuman(src))

		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/affected

		for(var/obj/item/organ/external/organ in H.organs) //Grab the organ holding the implant.
			for(var/obj/item/weapon/O in organ.implants)
				if(O == selection)
					affected = organ

		affected.implants -= selection
		H.shock_stage+=10

		if(prob(10)) //I'M SO ANEMIC I COULD JUST -DIE-.
			var/datum/wound/internal_bleeding/I = new ()
			affected.wounds += I
			H.custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 1)

		if (ishuman(U))
			var/mob/living/carbon/human/human_user = U
			human_user.bloody_hands(H)

	selection.loc = get_turf(src)
	if(!(U.l_hand && U.r_hand))
		U.put_in_hands(selection)

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	return 1



/mob/dead/observer/verb/respawn()
	set name = "Respawn as NPC"
	set category = "Ghost"

	if(jobban_isbanned(usr, "NPC"))
		usr << "<span class='warning'>You are banned from playing as NPC's.</span>"
		return

	if((usr in respawnable_list) && (stat==2 || istype(usr,/mob/dead/observer)))
		var/list/creatures = list("Mouse")
		for(var/mob/living/L in living_mob_list)
			if(safe_respawn(L.type) && L.stat!=2)
				if(!L.key)
					creatures += L
		var/picked = input("Please select an NPC to respawn as", "Respawn as NPC")  as null|anything in creatures
		switch(picked)
			if("Mouse")
				respawnable_list -= usr
				become_mouse()
				spawn(5)
					respawnable_list += usr
			else
				var/mob/living/NPC = picked
				if(istype(NPC) && !NPC.key)
					respawnable_list -= usr
					NPC.key = key
					spawn(5)
						respawnable_list += usr
				else
//					message_admins("Failed to check type")
	else
		usr << "You are not dead or you have given up your right to be respawned!"
		return


/mob/proc/become_mouse()
	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		src << "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>"
		return

	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in world)
		if(!v.welded && v.z == src.z)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		src << "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>"

	if(host)
		host.ckey = src.ckey
		host << "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>"

/mob/living/proc/handle_statuses()
	handle_stunned()
	handle_weakened()
	handle_stuttering()
	handle_silent()
	handle_drugged()
	handle_slurring()

/mob/living/proc/handle_stunned()
	if(stunned)
		AdjustStunned(-1)
	return stunned

/mob/living/proc/handle_weakened()
	if(weakened)
		weakened = max(weakened-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times
	return weakened

/mob/living/proc/handle_stuttering()
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	return stuttering

/mob/living/proc/handle_silent()
	if(silent)
		silent = max(silent-1, 0)
	return silent

/mob/living/proc/handle_drugged()
	if(druggy)
		druggy = max(druggy-1, 0)
	return druggy

/mob/living/proc/handle_slurring()
	if(slurring)
		slurring = max(slurring-1, 0)
	return slurring

/mob/living/proc/handle_paralysed() // Currently only used by simple_animal.dm, treated as a special case in other mobs
	if(paralysis)
		AdjustParalysis(-1)
	return paralysis

/mob/proc/assess_threat() //For sec bot threat assessment
	return

/mob/proc/get_ghost(even_if_they_cant_reenter = 0)
	if(mind)
		for(var/mob/dead/observer/G in dead_mob_list)
			if(G.mind == mind)
				if(G.can_reenter_corpse || even_if_they_cant_reenter)
					return G
				break


/mob/proc/fakevomit(green=0) //for aesthetic vomits that need to be instant and do not stun. -Fox
	if(stat==DEAD)
		return
	var/turf/location = loc
	if (istype(location, /turf/simulated))
		if(green)
			src.visible_message("<span class='warning'>[src] vomits up some green goo!</span>","<span class='warning'>You vomit up some green goo!</span>")
			new /obj/effect/decal/cleanable/vomit/green(location)
		else
			src.visible_message("<span class='warning'>[src] pukes all over \himself!</span>","<span class='warning'>You puke all over yourself!</span>")
			location.add_vomit_floor(src, 1)
		playsound(location, 'sound/effects/splat.ogg', 50, 1)