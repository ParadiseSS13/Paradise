/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	input_focus = null
	if(s_active)
		s_active.close(src)
	if(!QDELETED(hud_used))
		QDEL_NULL(hud_used)
	if(mind && mind.current == src)
		spellremove()
	mobspellremove()
	QDEL_LIST_CONTENTS(viruses)
	QDEL_LIST_CONTENTS(actions)
	for(var/alert in alerts)
		clear_alert(alert)
	ghostize()
	QDEL_LIST_ASSOC_VAL(tkgrabbed_objects)
	for(var/I in tkgrabbed_objects)
		qdel(tkgrabbed_objects[I])
	tkgrabbed_objects = null
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	if(viewing_alternate_appearances)
		for(var/datum/alternate_appearance/AA in viewing_alternate_appearances)
			AA.viewers -= src
		viewing_alternate_appearances = null
	LAssailant = null
	runechat_msg_location = null
	if(length(observers))
		for(var/mob/dead/observe as anything in observers)
			observe.reset_perspective(null)

	return ..()

/mob/Initialize(mapload)
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	input_focus = src
	reset_perspective(src)
	prepare_huds()
	update_runechat_msg_location()
	ADD_TRAIT(src, TRAIT_CAN_STRIP, TRAIT_GENERIC)
	. = ..()

/atom/proc/prepare_huds()
	hud_list = list()
	var/static/list/hud_dmis = list(
		SPECIALROLE_HUD = 'icons/mob/hud/antaghud.dmi',

		DIAG_TRACK_HUD = 'icons/mob/hud/diaghud.dmi',
		DIAG_AIRLOCK_HUD = 'icons/mob/hud/diaghud.dmi',
		DIAG_STAT_HUD = 'icons/mob/hud/diaghud.dmi',
		DIAG_HUD = 'icons/mob/hud/diaghud.dmi',
		DIAG_BATT_HUD = 'icons/mob/hud/diaghud.dmi',
		DIAG_MECH_HUD = 'icons/mob/hud/diaghud.dmi',
		DIAG_BOT_HUD = 'icons/mob/hud/diaghud.dmi',

		PLANT_NUTRIENT_HUD = 'icons/mob/hud/hydrohud.dmi',
		PLANT_WATER_HUD = 'icons/mob/hud/hydrohud.dmi',
		PLANT_STATUS_HUD = 'icons/mob/hud/hydrohud.dmi',
		PLANT_HEALTH_HUD = 'icons/mob/hud/hydrohud.dmi',
		PLANT_TOXIN_HUD = 'icons/mob/hud/hydrohud.dmi',
		PLANT_PEST_HUD = 'icons/mob/hud/hydrohud.dmi',
		PLANT_WEED_HUD = 'icons/mob/hud/hydrohud.dmi',

		HEALTH_HUD = 'icons/mob/hud/medhud.dmi',
		STATUS_HUD = 'icons/mob/hud/medhud.dmi',

		ID_HUD = 'icons/mob/hud/sechud.dmi',
		WANTED_HUD = 'icons/mob/hud/sechud.dmi',
		IMPMINDSHIELD_HUD = 'icons/mob/hud/sechud.dmi',
		IMPCHEM_HUD = 'icons/mob/hud/sechud.dmi',
		IMPTRACK_HUD = 'icons/mob/hud/sechud.dmi',
	)

	for(var/hud in hud_possible)
		var/use_this_dmi = hud_dmis[hud]
		if(!use_this_dmi)
			use_this_dmi = 'icons/mob/hud/hud_misc.dmi'
		var/image/I = image(use_this_dmi, src, "")
		I.appearance_flags = RESET_COLOR | RESET_TRANSFORM
		hud_list[hud] = I

/mob/proc/generate_name()
	return name

/mob/proc/GetAltName()
	return ""

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "<span class='notice'>Coordinates: [x],[y] \n</span>"
	t+= "<span class='warning'>Temperature: [environment.temperature] \n</span>"
	t+= "<span class='notice'>Nitrogen: [environment.nitrogen] \n</span>"
	t+= "<span class='notice'>Oxygen: [environment.oxygen] \n</span>"
	t+= "<span class='notice'>Plasma : [environment.toxins] \n</span>"
	t+= "<span class='notice'>Carbon Dioxide: [environment.carbon_dioxide] \n</span>"
	t+= "<span class='notice'>N2O: [environment.sleeping_agent] \n</span>"
	t+= "<span class='notice'>Agent B: [environment.agent_b] \n</span>"

	usr.show_message(t, EMOTE_VISIBLE)

/mob/proc/show_message(msg, type, alt, alt_type, chat_message_type) // Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)
		return

	if(type)
		if(type & EMOTE_VISIBLE && !has_vision(information_only = TRUE)) // Vision related
			if(!alt)
				return
			msg = alt
			type = alt_type

		if(type & EMOTE_AUDIBLE && !can_hear()) // Hearing related
			if(!alt)
				return
			msg = alt
			type = alt_type
			if(type & EMOTE_VISIBLE && !has_vision(information_only = TRUE))
				return

	// Added voice muffling for Issue 41.
	if(stat == UNCONSCIOUS)
		to_chat(src, "<i>... You can almost hear someone talking ...</i>", MESSAGE_TYPE_LOCALCHAT)
		return

	to_chat(src, msg, chat_message_type)

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(message, self_message, blind_message, chat_message_type)
	if(!isturf(loc)) // mobs inside objects (such as lockers) shouldn't have their actions visible to those outside the object
		for(var/mob/M as anything in get_mobs_in_view(3, src))
			if(M.see_invisible < invisibility)
				continue //can't view the invisible
			var/msg = message
			if(self_message && M == src)
				msg = self_message
			if(M.loc != loc)
				if(!blind_message) // for some reason VISIBLE action has blind_message param so if we are not in the same object but next to it, lets show it
					continue
				msg = blind_message
			M.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE, chat_message_type)
		return
	for(var/mob/M as anything in get_mobs_in_view(7, src))
		if(M.see_invisible < invisibility)
			continue //can't view the invisible
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		M.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE, chat_message_type)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, blind_message)
	for(var/mob/M as anything in get_mobs_in_view(7, src))
		if(!M.client)
			continue
		M.show_message(message, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE)

// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/mob/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	var/msg = message
	for(var/mob/M as anything in get_mobs_in_view(range, src))
		M.show_message(msg, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)

	// based on say code
	var/omsg = replacetext(message, "<B>[src]</B> ", "")
	var/list/listening_obj = new
	for(var/atom/movable/A in view(range, src))
		if(ismob(A))
			var/mob/M = A
			for(var/obj/O in M.contents)
				listening_obj |= O
		else if(isobj(A))
			var/obj/O = A
			listening_obj |= O
	for(var/obj/O in listening_obj)
		O.hear_message(src, omsg)

// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M as anything in get_mobs_in_view(range, src))
		M.show_message(message, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)

/mob/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if(M.real_name == "[msg]")
			return M
	return 0

/mob/proc/movement_delay()
	return 0

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_hand()

	if(istype(W))
		equip_to_slot_if_possible(W, slot)
	else if(!restrained())
		W = get_item_by_slot(slot)
		if(W)
			W.attack_hand(src)

	if(ishuman(src) && W == src:head)
		src:update_hair()
		src:update_fhair()

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = 0, disable_warning = 1)
	if(equip_to_slot_if_possible(W, SLOT_HUD_LEFT_HAND, del_on_fail, disable_warning))
		return 1
	else if(equip_to_slot_if_possible(W, SLOT_HUD_RIGHT_HAND, del_on_fail, disable_warning))
		return 1
	return 0



//This is a SAFE proc. Use this instead of equip_to_slot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, del_on_fail = FALSE, disable_warning = FALSE, initial = FALSE)
	if(!istype(W)) return 0

	if(!W.mob_can_equip(src, slot, disable_warning))
		if(del_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if del_on_fail is false

		return 0

	equip_to_slot(W, slot, initial) //This proc should not ever fail.
	return 1

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W, slot, initial = FALSE)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, initial = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, initial)

// Convinience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(obj/item/W, slot, initial = FALSE)
	if(W.mob_can_equip(src, slot, TRUE))
		//Mob can equip.  Equip it.
		equip_to_slot_or_del(W, slot, initial)
	else
		//Mob can't equip it.  Put it their backpack or toss it on the floor
		if(isstorage(back))
			var/obj/item/storage/S = back
			//Now, S represents a container we can insert W into.
			S.handle_item_insertion(W, src, TRUE, TRUE)
			return S
		if(ismodcontrol(back))
			var/obj/item/mod/control/C = back
			if(C.bag)
				C.bag.handle_item_insertion(W, src, TRUE, TRUE)
			return C.bag

		var/turf/T = get_turf(src)
		if(istype(T))
			W.forceMove(T)
			return T


//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
GLOBAL_LIST_INIT(slot_equipment_priority, list( \
		SLOT_HUD_BACK,\
		SLOT_HUD_WEAR_PDA,\
		SLOT_HUD_WEAR_ID,\
		SLOT_HUD_JUMPSUIT,\
		SLOT_HUD_OUTER_SUIT,\
		SLOT_HUD_WEAR_MASK,\
		SLOT_HUD_HEAD,\
		SLOT_HUD_SHOES,\
		SLOT_HUD_GLOVES,\
		SLOT_HUD_LEFT_EAR,\
		SLOT_HUD_RIGHT_EAR,\
		SLOT_HUD_GLASSES,\
		SLOT_HUD_BELT,\
		SLOT_HUD_SUIT_STORE,\
		SLOT_HUD_TIE,\
		SLOT_HUD_LEFT_STORE,\
		SLOT_HUD_RIGHT_STORE\
	))

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W)) return 0

	for(var/slot in GLOB.slot_equipment_priority)
		if(isstorage(W) && slot == SLOT_HUD_HEAD) // Storage items should be put on the belt before the head
			continue
		if(equip_to_slot_if_possible(W, slot, FALSE, TRUE)) //del_on_fail = 0; disable_warning = 0
			return 1

	return 0

/mob/proc/check_for_open_slot(obj/item/W)
	if(!istype(W)) return 0
	var/openslot = 0
	for(var/slot in GLOB.slot_equipment_priority)
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
			if(SLOT_HUD_LEFT_HAND)
				if(H.l_hand)
					return 0
				return 1
			if(SLOT_HUD_RIGHT_HAND)
				if(H.r_hand)
					return 0
				return 1
			if(SLOT_HUD_WEAR_MASK)
				if(!(slot_flags & SLOT_FLAG_MASK))
					return 0
				if(H.wear_mask)
					return 0
				return 1
			if(SLOT_HUD_BACK)
				if(!(slot_flags & SLOT_FLAG_BACK))
					return 0
				if(H.back)
					if(!(H.back.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_OUTER_SUIT)
				if(!(slot_flags & SLOT_FLAG_OCLOTHING))
					return 0
				if(H.wear_suit)
					if(!(H.wear_suit.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_GLOVES)
				if(!(slot_flags & SLOT_FLAG_GLOVES))
					return 0
				if(H.gloves)
					if(!(H.gloves.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_SHOES)
				if(!(slot_flags & SLOT_FLAG_FEET))
					return 0
				if(H.shoes)
					if(!(H.shoes.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_BELT)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(!(slot_flags & SLOT_FLAG_BELT))
					return 0
				if(H.belt)
					if(!(H.belt.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_GLASSES)
				if(!(slot_flags & SLOT_FLAG_EYES))
					return 0
				if(H.glasses)
					if(!(H.glasses.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_HEAD)
				if(!(slot_flags & SLOT_FLAG_HEAD))
					return 0
				if(H.head)
					if(!(H.head.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_LEFT_EAR)
				if(!(slot_flags & SLOT_HUD_LEFT_EAR))
					return 0
				if(H.l_ear)
					if(!(H.l_ear.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_RIGHT_EAR)
				if(!(slot_flags & SLOT_HUD_RIGHT_EAR))
					return 0
				if(H.r_ear)
					if(!(H.r_ear.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_JUMPSUIT)
				if(!(slot_flags & SLOT_FLAG_ICLOTHING))
					return 0
				if(H.w_uniform)
					if(!(H.w_uniform.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_WEAR_ID)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(!(slot_flags & SLOT_FLAG_ID))
					return 0
				if(H.wear_id)
					if(!(H.wear_id.flags & NODROP))
						return 2
					else
						return 0
				return 1
			if(SLOT_HUD_LEFT_STORE)
				if(H.l_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(w_class <= WEIGHT_CLASS_SMALL || (slot_flags & SLOT_FLAG_POCKET))
					return 1
			if(SLOT_HUD_RIGHT_STORE)
				if(H.r_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(w_class <= WEIGHT_CLASS_SMALL || (slot_flags & SLOT_FLAG_POCKET))
					return 1
				return 0
			if(SLOT_HUD_SUIT_STORE)
				if(!H.wear_suit)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return 0
				if(w_class > H.wear_suit.max_suit_w)
					if(!disable_warning)
						to_chat(usr, "The [name] is too big to attach.")
					return 0
				if(istype(src, /obj/item/pda) || is_pen(src) || is_type_in_list(src, H.wear_suit.allowed))
					if(H.s_store)
						if(!(H.s_store.flags & NODROP))
							return 2
						else
							return 0
					else
						return 1
				return 0
			if(SLOT_HUD_HANDCUFFED)
				if(H.handcuffed)
					return 0
				if(!istype(src, /obj/item/restraints/handcuffs))
					return 0
				return 1
			if(SLOT_HUD_LEGCUFFED)
				if(H.legcuffed)
					return 0
				if(!istype(src, /obj/item/restraints/legcuffs))
					return 0
				return 1
			if(SLOT_HUD_IN_BACKPACK)
				if(H.back && istype(H.back, /obj/item/storage/backpack))
					var/obj/item/storage/backpack/B = H.back
					if(length(B.contents) < B.storage_slots && w_class <= B.max_w_class)
						return 1
				return 0
		return 0 //Unsupported slot
		//END HUMAN

/mob/proc/get_visible_mobs()
	var/list/seen_mobs = list()
	for(var/mob/M in view(src))
		seen_mobs += M

	return seen_mobs

/**
 * Returns an assoc list which contains the mobs in range and their "visible" name.
 * Mobs out of view but in range will be listed as unknown. Else they will have their visible name
*/
/mob/proc/get_telepathic_targets()
	var/list/validtargets = new /list()
	var/turf/T = get_turf(src)
	var/list/mobs_in_view = get_visible_mobs()

	for(var/mob/living/M in range(14, T))
		if(M && M.mind)
			if(M == src)
				continue
			var/mob_name
			if(M in mobs_in_view)
				mob_name = M.name
			else
				mob_name = "Unknown entity"
			var/i = 0
			var/result_name
			do
				result_name = mob_name
				if(i++)
					result_name += " ([i])" // Avoid dupes
			while(validtargets[result_name])
			validtargets[result_name] = M
	return validtargets

// If you're looking for `reset_perspective`, that's a synonym for this proc.
/mob/proc/reset_perspective(atom/A)
	if(client)
		if(istype(A, /atom/movable))
			if(is_ventcrawling(src))
				client.eye = get_turf(A)
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
		else
			if(isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
		return 1

/mob/living/reset_perspective(atom/A)
	. = ..()
	if(.)
		// Above check means the mob has a client
		update_sight()
		if(client.eye != src)
			var/atom/AT = client.eye
			AT.get_remote_view_fullscreens(src)
		else
			clear_fullscreen("remote_view", 0)
		update_pipe_vision()

/mob/dead/reset_perspective(atom/A)
	. = ..()
	if(.)
		// Allows sharing HUDs with ghosts
		if(hud_used)
			client.clear_screen()
			hud_used.show_hud(hud_used.hud_version)

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_examinate), A))

/mob/proc/run_examinate(atom/A)
	if(!has_vision(information_only = TRUE) && !isobserver(src))
		to_chat(src, chat_box_regular("<span class='notice'>Something is there but you can't see it.</span>"), MESSAGE_TYPE_INFO, confidential = TRUE)
		return TRUE

	face_atom(A)
	if(!client)
		var/list/result = A.examine(src)
		to_chat(src, chat_box_examine(result.Join("\n")))
		return

	var/list/result
	LAZYINITLIST(client.recent_examines)
	for(var/key in client.recent_examines)
		if(client.recent_examines[key] < world.time)
			client.recent_examines -= key
	var/ref_to_atom = A.UID()
	if(LAZYACCESS(client.recent_examines, ref_to_atom))
		result = A.examine_more(src)
		if(!length(result))
			result += "<span class='notice'><i>You examine [A] closer, but find nothing of interest...</i></span>"
	else
		result = A.examine(src)
		client.recent_examines[ref_to_atom] = world.time + EXAMINE_MORE_WINDOW // set to when we should not examine something

	to_chat(src, chat_box_examine(result.Join("\n")), MESSAGE_TYPE_INFO, confidential = TRUE)

/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if((!istype(l_hand, /obj/item/grab) && !istype(r_hand, /obj/item/grab)))
		if(!L)
			return null
		else
			return L.container
	else
		if(!L)
			L = new /obj/effect/list_container/mobl( null )
			L.container += src
			L.master = src
		if(istype(l_hand, /obj/item/grab))
			var/obj/item/grab/G = l_hand
			if(!L.container.Find(G.affecting))
				L.container += G.affecting
				if(G.affecting)
					G.affecting.ret_grab(L, 1)
		if(istype(r_hand, /obj/item/grab))
			var/obj/item/grab/G = r_hand
			if(!L.container.Find(G.affecting))
				L.container += G.affecting
				if(G.affecting)
					G.affecting.ret_grab(L, 1)
		if(!flag)
			if(L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				qdel(L)
				return temp
			else
				return L.container
	return


/mob/verb/mode()
	set name = "Activate Held Object"
	set category = null

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_mode)))

///proc version to finish /mob/verb/mode() execution. used in case the proc needs to be queued for the tick after its first called
/mob/proc/run_mode()
	if(ismecha(loc)) return

	if(hand)
		var/obj/item/W = l_hand
		if(W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if(W)
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
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize_simple(html_encode(msg), list("\n" = "<br>"))

	var/combined = length(memory + msg)
	if(mind && (combined < MAX_PAPER_MESSAGE_LEN))
		mind.store_memory(msg)
	else if(combined >= MAX_PAPER_MESSAGE_LEN)
		to_chat(src, "Your brain can't hold that much information!")
		return
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if(sane)
		msg = sanitize(msg)

	if(length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if(popup)
		memory()

/mob/proc/update_flavor_text()
	if(usr != src)
		to_chat(usr, "<span class='notice'>You can't change the flavor text of this mob</span>")
		return
	if(stat)
		to_chat(usr, "<span class='notice'>You have to be conscious to change your flavor text</span>")
		return

	var/msg = tgui_input_text(usr, "Set the flavor text in your 'examine' verb. The flavor text should be a physical descriptor of your character at a glance. SFW Drawn Art of your character is acceptable.", "Flavor Text", flavor_text, multiline = TRUE)
	if(isnull(msg))
		return
	if(stat)
		to_chat(usr, "<span class='notice'>You have to be conscious to change your flavor text</span>")
		return
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	flavor_text = msg

/mob/proc/print_flavor_text(shrink = TRUE)
	if(flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(length(msg) <= 40 || !shrink)
			return "<span class='notice'>[msg]</span>" // There is already encoded by tgui_input
		else
			return "<span class='notice'>[copytext_preserve_html(msg, 1, 37)]... <a href='byond://?src=[UID()];flavor_more=1'>More...</a></span>"

/mob/proc/is_dead()
	return stat == DEAD

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_perspective(null)
	unset_machine()
	if(isliving(src))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/Topic(href, href_list)
	..()
	if(href_list["mach_close"])
		var/t1 = "window=[href_list["mach_close"]]"
		unset_machine()
		src << browse(null, t1)

	if(href_list["flavor_more"])
		usr << browse(text("<html><meta charset='utf-8'><head><title>[]</title></head><body><tt>[]</tt></body></html>", name, replacetext(flavor_text, "\n", "<br>")), "window=[name];size=500x200")
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()

	if(href_list["scoreboard"])
		usr << browse(GLOB.scoreboard, "window=roundstats;size=500x600")

/mob/MouseDrop(mob/M as mob, src_location, over_location, src_control, over_control, params)
	if((M != usr) || !istype(M))
		..()
		return
	if(isliving(M))
		var/mob/living/L = M
		if(L.mob_size <= MOB_SIZE_SMALL)
			return // Stops pAI drones and small mobs (parrots, crabs) from stripping people. --DZD
	if(!HAS_TRAIT(M, TRAIT_CAN_STRIP))
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(IsFrozen(src) && !is_admin(usr))
		to_chat(usr, "<span class='boldannounceic'>Interacting with admin-frozen players is not permitted.</span>")
		return
	if(isLivingSSD(src) && M.client && M.client.send_ssd_warning(src))
		return
	SEND_SIGNAL(src, COMSIG_DO_MOB_STRIP, M, usr)

/mob/proc/can_use_hands()
	return

/mob/proc/is_mechanical()
	return mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI")

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/is_in_brig()
	if(!loc || !loc.loc)
		return 0

	// They should be in a cell or the Brig portion of the shuttle.
	var/area/A = loc.loc
	if(!istype(A, /area/station/security/prison))
		if(!istype(A, /area/shuttle/escape) || loc.name != "Brig floor")
			return 0

	// If they still have their ID they're not brigged.
	for(var/obj/item/card/id/card in src)
		return 0
	for(var/obj/item/pda/P in src)
		if(P.id)
			return 0

	return 1

/mob/proc/get_gender()
	return gender

/mob/proc/is_muzzled()
	return FALSE

/mob/proc/get_status_tab_items()
	SHOULD_CALL_PARENT(TRUE)
	var/list/status_tab_data = list()
	return status_tab_data

// facing verbs
/mob/proc/canface()
	if(client.moving)
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(restrained())
		return FALSE
	return TRUE

/mob/living/canface()
	if(!(mobility_flags & MOBILITY_MOVE))
		return FALSE
	. = ..()

/mob/proc/fall()
	drop_l_hand()
	drop_r_hand()

/mob/living/fall()
	..()
	set_body_position(LYING_DOWN)

/mob/proc/facedir(ndir)
	if(!canface())
		return FALSE
	setDir(ndir)
	return TRUE


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
	return FALSE

/mob/proc/swap_hand()
	return

/mob/proc/activate_hand(selhand)
	return FALSE

/mob/dead/observer/verb/respawn()
	set name = "Respawn as NPC"
	set category = "Ghost"

	if(jobban_isbanned(usr, ROLE_SENTIENT))
		to_chat(usr, "<span class='warning'>You are banned from playing as sentient animals.</span>")
		return

	if(!SSticker || SSticker.current_state < 3)
		to_chat(src, "<span class='warning'>You can't respawn as an NPC before the game starts!</span>")
		return

	if((HAS_TRAIT(usr, TRAIT_RESPAWNABLE)) && (stat == DEAD || isobserver(usr)))
		var/list/creatures = list("Mouse")
		for(var/mob/living/simple_animal/L in GLOB.alive_mob_list)
			if(!(is_station_level(L.z) || is_admin_level(L.z))) // Prevents players from spawning in space
				continue
			if(L.npc_safe(src) && L.stat != DEAD && !L.key)
				creatures += L
		var/picked = tgui_input_list(usr, "Please select an NPC to respawn as", "Respawn as NPC", creatures)
		switch(picked)
			if("Mouse")
				become_mouse()
			else
				var/mob/living/NPC = picked
				if(istype(NPC) && !NPC.key)
					NPC.key = key
	else
		to_chat(usr, "You are not dead or you have given up your right to be respawned!")
		return

/**
 * Returns true if the player successfully becomes a mouse
 */
/mob/proc/become_mouse()
	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= GLOB.mouse_respawn_time * 600)
		var/timedifference_text = time2text(GLOB.mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [GLOB.mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return FALSE

	//find a viable mouse candidate
	var/list/found_vents = get_valid_vent_spawns()
	if(!length(found_vents))
		found_vents = get_valid_vent_spawns(min_network_size = 0)
		if(!length(found_vents))
			to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")
			return FALSE
	var/obj/vent_found = pick(found_vents)
	var/mob/living/simple_animal/mouse/host = prob(20) ? new /mob/living/simple_animal/mouse/rat(vent_found.loc) : new(vent_found.loc) // SS220 EDIT
	host.ckey = src.ckey
	to_chat(host, "<span class='info'>You are now a mouse, a small and fragile creature capable of scurrying through vents and under doors. Be careful who you reveal yourself to, for that will decide whether you receive cheese or death.</span>")
	host.forceMove(vent_found)
	host.add_ventcrawl(vent_found)
	return TRUE

/mob/proc/assess_threat() //For sec bot threat assessment
	return 5

/mob/proc/get_ghost(even_if_they_cant_reenter = 0)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter)

/mob/proc/grab_ghost(force)
	if(mind)
		return mind.grab_ghost(force = force)

/mob/proc/notify_ghost_cloning(message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", sound = 'sound/effects/genetics.ogg', atom/source = null, flashwindow = TRUE)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		if(flashwindow)
			window_flash(ghost.client)
		ghost.notify_cloning(message, sound, source)
		return ghost

/mob/proc/fakevomit(green = 0, no_text = 0) //for aesthetic vomits that need to be instant and do not stun. -Fox
	if(stat==DEAD)
		return
	var/turf/location = loc
	if(issimulatedturf(location))
		if(green)
			if(!no_text)
				visible_message("<span class='warning'>[src] vomits up some green goo!</span>","<span class='warning'>You vomit up some green goo!</span>")
			add_vomit_floor(FALSE, TRUE)
		else
			if(!no_text)
				visible_message("<span class='warning'>[src] pukes all over [p_themselves()]!</span>","<span class='warning'>You puke all over yourself!</span>")
			add_vomit_floor(TRUE)

/mob/proc/AddSpell(datum/spell/S)
	mob_spell_list += S
	S.action.Grant(src)

/mob/proc/RemoveSpell(datum/spell/spell) //To remove a specific spell from a mind
	if(!spell)
		return
	for(var/datum/spell/S in mob_spell_list)
		if(istype(S, spell))
			qdel(S)
			mob_spell_list -= S

//override to avoid rotating pixel_xy on mobs
/mob/shuttleRotate(rotation)
	dir = angle2dir(rotation+dir2angle(dir))

/mob/proc/handle_ventcrawl()
	return // Only living mobs can ventcrawl

/**
  * Buckle to another mob
  *
  * You can buckle on mobs if you're next to them since most are dense
  *
  * Turns you to face the other mob too
  */
/mob/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(M.buckled)
		return 0
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density
		density = FALSE
		var/can_step = step_towards(M, T)
		density = old_density
		if(!can_step)
			return 0
	return ..()

///Call back post buckle to a mob to offset your visual height
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1

///Call back post unbuckle from a mob, (reset your visual height here)
/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

///returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	if(isliving(seat))
		var/mob/living/L = seat
		if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
			return 0
	return 9

///can the mob be buckled to something by default?
/mob/proc/can_buckle()
	return TRUE

///can the mob be unbuckled from something by default?
/mob/proc/can_unbuckle()
	return TRUE


// Can the mob see reagents inside of transparent containers?
/mob/proc/reagent_vision()
	return FALSE

// Can the mob see reagents inside any container and also identify blood types?
/mob/proc/advanced_reagent_vision()
	return FALSE

//Can this mob leave its location without breaking things terrifically?
/mob/proc/can_safely_leave_loc()
	return TRUE // Yes, you can

/mob/proc/IsVocal()
	return TRUE

/mob/proc/cannot_speak_loudly()
	return FALSE

/mob/proc/get_access()
	return list() //must return list or IGNORE_ACCESS

/mob/proc/create_attack_log(text, collapse = TRUE)
	LAZYINITLIST(attack_log_old)
	create_log_in_list(attack_log_old, text, collapse, last_log)
	last_log = world.timeofday

/mob/proc/create_debug_log(text, collapse = TRUE)
	LAZYINITLIST(debug_log)
	create_log_in_list(debug_log, text, collapse, world.timeofday)

/mob/proc/create_log(log_type, what, target = null, turf/where = get_turf(src))
	if(!ckey)
		return
	var/real_ckey = ckey
	if(ckey[1] == "@") // Admin aghosting will do this
		real_ckey = copytext(ckey, 2)
	var/datum/log_record/record = new(log_type, src, what, target, where, world.time)
	GLOB.logging.add_log(real_ckey, record)

/proc/create_log_in_list(list/target, text, collapse = TRUE, last_log)//forgive me code gods for this shitcode proc
	//this proc enables lovely stuff like an attack log that looks like this: "[18:20:29-18:20:45]21x John Smith attacked Andrew Jackson with a crowbar."
	//That makes the logs easier to read, but because all of this is stored in strings, weird things have to be used to get it all out.
	var/new_log = "\[[time_stamp()]] [text]"

	if(length(target))//if there are other logs already present
		var/previous_log = target[length(target)]//get the latest log
		var/last_log_is_range = (copytext(previous_log, 10, 11) == "-") //whether the last log is a time range or not. The "-" will be an indicator that it is.
		var/x_sign_position = findtext(previous_log, "x")

		if(world.timeofday - last_log > 100)//if more than 10 seconds from last log
			collapse = 0//don't collapse anyway

		//the following checks if the last log has the same contents as the new one
		if(last_log_is_range)
			if(!(copytext(previous_log, x_sign_position + 13) == text))//the 13 is there because of span classes; you won't see those normally in-game
				collapse = 0
		else
			if(!(copytext(previous_log, 12) == text))
				collapse = 0


		if(collapse == 1)
			var/rep = 0
			var/old_timestamp = copytext(previous_log, 2, 10)//copy the first time value. This one doesn't move when it's a timespan, so no biggie
			//An attack log entry can either be a time range with multiple occurences of an action or a single one, with just one time stamp
			if(last_log_is_range)

				rep = text2num(copytext(previous_log, 44, x_sign_position))//get whatever number is right before the 'x'

			new_log = "\[[old_timestamp]-[time_stamp()]]<font color='purple'><b>[rep?rep+1:2]x</b></font> [text]"
			target -= target[length(target)]//remove the last log

	target += new_log

/mob/vv_get_dropdown()
	. = ..()
	.["Show player panel"] = "?_src_=vars;mob_player_panel=[UID()]"

	.["Give Spell"] = "?_src_=vars;give_spell=[UID()]"
	.["Give Martial Art"] = "?_src_=vars;givemartialart=[UID()]"
	.["Give Disease"] = "?_src_=vars;give_disease=[UID()]"
	.["Toggle Godmode"] = "?_src_=vars;godmode=[UID()]"
	.["Toggle Build Mode"] = "?_src_=vars;build_mode=[UID()]"

	.["Make 2spooky"] = "?_src_=vars;make_skeleton=[UID()]"
	.["Hallucinate"] = "?_src_=vars;hallucinate=[UID()]"

	.["Assume Direct Control"] = "?_src_=vars;direct_control=[UID()]"
	.["Offer Control to Ghosts"] = "?_src_=vars;offer_control=[UID()]"
	.["Drop Everything"] = "?_src_=vars;drop_everything=[UID()]"

	.["Regenerate Icons"] = "?_src_=vars;regenerateicons=[UID()]"
	.["Add Language"] = "?_src_=vars;addlanguage=[UID()]"
	.["Remove Language"] = "?_src_=vars;remlanguage=[UID()]"
	.["Add Organ"] = "?_src_=vars;addorgan=[UID()]"
	.["Remove Organ"] = "?_src_=vars;remorgan=[UID()]"

	.["Add Verb"] = "?_src_=vars;addverb=[UID()]"
	.["Remove Verb"] = "?_src_=vars;remverb=[UID()]"

	.["Gib"] = "?_src_=vars;gib=[UID()]"

///Can this mob resist (default FALSE)
/mob/proc/can_resist()
	return FALSE		//overridden in living.dm

/mob/proc/spin(spintime, speed)
	set waitfor = FALSE
	if(!spintime || !speed || spintime > 100)
		CRASH("Aborted attempted call of /mob/proc/spin with invalid args ([spintime],[speed]) which could have frozen the server.")
	while(spintime >= speed)
		sleep(speed)
		switch(dir)
			if(NORTH)
				setDir(EAST)
			if(SOUTH)
				setDir(WEST)
			if(EAST)
				setDir(SOUTH)
			if(WEST)
				setDir(NORTH)
		spintime -= speed

/mob/proc/is_literate()
	return FALSE

/mob/proc/faction_check_mob(mob/target, exact_match)
	if(!target)
		return faction_check(faction, null, FALSE)
	if(exact_match) //if we need an exact match, we need to do some bullfuckery.
		var/list/faction_src = faction.Copy()
		var/list/faction_target = target.faction.Copy()
		if(!("\ref[src]" in faction_target)) //if they don't have our ref faction, remove it from our factions list.
			faction_src -= "\ref[src]" //if we don't do this, we'll never have an exact match.
		if(!("\ref[target]" in faction_src))
			faction_target -= "\ref[target]" //same thing here.
		return faction_check(faction_src, faction_target, TRUE)
	return faction_check(faction, target.faction, FALSE)

/proc/faction_check(list/faction_A, list/faction_B, exact_match)
	var/list/match_list
	if(exact_match)
		match_list = faction_A & faction_B //only items in both lists
		var/length = LAZYLEN(match_list)
		if(length)
			return (length == LAZYLEN(faction_A)) //if they're not the same len(gth) or we don't have a len, then this isn't an exact match.
	else
		match_list = faction_A & faction_B
		return LAZYLEN(match_list)
	return FALSE

/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/proc/set_sight(datum/vision_override/O)
	QDEL_NULL(vision_type)
	if(O) //in case of null
		vision_type = new O
	update_sight()

/mob/proc/sync_lighting_plane_alpha()
	if(hud_used)
		var/atom/movable/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if(L)
			L.alpha = lighting_alpha
		var/atom/movable/screen/plane_master/smoke/S = hud_used.plane_masters["[SMOKE_PLANE]"]
		if(S)
			S.alpha = 255
			if(sight & SEE_MOBS)
				S.alpha = 200
			if((sight & SEE_TURFS|SEE_MOBS|SEE_OBJS) == (SEE_TURFS|SEE_MOBS|SEE_OBJS))
				S.alpha = 128

	sync_nightvision_screen() //Sync up the overlay used for nightvision to the amount of see_in_dark a mob has. This needs to be called everywhere sync_lighting_plane_alpha() is.

/mob/proc/sync_nightvision_screen()
	var/atom/movable/screen/fullscreen/stretch/see_through_darkness/S = screens["see_through_darkness"]
	if(S)
		var/suffix = ""
		switch(see_in_dark)
			if(3 to 8)
				suffix = "_[see_in_dark]"
			if(8 to INFINITY)
				suffix = "_8"

		S.icon_state = "[initial(S.icon_state)][suffix]"

///Adjust the nutrition of a mob
/mob/proc/adjust_nutrition(change)
	nutrition = max(0, nutrition + change)

///Force set the mob nutrition
/mob/proc/set_nutrition(change)
	nutrition = max(0, change)

/mob/clean_blood(radiation_clean = FALSE, clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	. = ..()
	if(bloody_hands && clean_hands)
		bloody_hands = 0
		update_inv_gloves()
	if(l_hand)
		if(l_hand.clean_blood(radiation_clean))
			update_inv_l_hand()
	if(r_hand)
		if(r_hand.clean_blood(radiation_clean))
			update_inv_r_hand()
	if(back)
		if(back.clean_blood(radiation_clean))
			update_inv_back()
	if(wear_mask && clean_mask)
		if(wear_mask.clean_blood(radiation_clean))
			update_inv_wear_mask()
	if(clean_feet)
		feet_blood_color = null
		qdel(feet_blood_DNA)
		bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0,  BLOOD_STATE_NOT_BLOODY = 0, BLOOD_BASE_ALPHA = BLOODY_FOOTPRINT_BASE_ALPHA)
		blood_state = BLOOD_STATE_NOT_BLOODY
		update_inv_shoes()
	update_icons()	//apply the now updated overlays to the mob

/**
 * Updates the mob's runechat maptext display location.
 *
 * By default, we set this to the src mob's `UID()`.
 */
/mob/proc/update_runechat_msg_location()
	runechat_msg_location = UID()


/**
 * Show an overlay of radiation levels on radioactive objects.
 */
/mob/proc/show_rads(range)
	for(var/turf/place in range(range, src))
		var/rads = SSradiation.get_turf_radiation(place)
		if(rads < RAD_BACKGROUND_RADIATION)
			continue

		var/strength = round(rads / 1000, 0.1)
		var/image/pic = image(loc = place)
		var/mutable_appearance/MA = new()
		MA.maptext = MAPTEXT("[strength]k")
		MA.color = "#04e604"
		MA.layer = RAD_TEXT_LAYER
		MA.plane = GAME_PLANE
		pic.appearance = MA
		flick_overlay(pic, list(client), 10)


GLOBAL_LIST_INIT(holy_areas, typecacheof(list(
	/area/station/service/chapel
)))

/mob/proc/holy_check()
	if(!is_type_in_typecache(loc.loc, GLOB.holy_areas))
		return FALSE

	if(!mind)
		return FALSE

	//Allows cult to bypass holy areas once they summon
	if(mind.has_antag_datum(/datum/antagonist/cultist) && SSticker.mode.cult_team.cult_status == NARSIE_HAS_RISEN)
		return FALSE

	//Execption for Holy Constructs
	if(isconstruct(src) && !mind.has_antag_datum(/datum/antagonist/cultist))
		return FALSE

	to_chat(src, "<span class='warning'>Your powers are useless on this holy ground.</span>")
	return TRUE

/mob/proc/reset_visibility()
	invisibility = initial(invisibility)
	alpha = initial(alpha)
	add_to_all_human_data_huds()

/mob/proc/make_invisible()
	invisibility = INVISIBILITY_LEVEL_TWO
	alpha = 128
	remove_from_all_data_huds()

/mob/proc/set_stat(new_stat)
	if(new_stat == stat)
		return
	. = stat
	stat = new_stat
	SEND_SIGNAL(src, COMSIG_MOB_STATCHANGE, new_stat, .)
	if(.)
		set_typing_indicator(FALSE)

///Makes a call in the context of a different usr. Use sparingly
/world/proc/invoke_callback_with_usr(mob/user_mob, datum/callback/invoked_callback, ...)
	var/temp = usr
	usr = user_mob
	if(length(args) > 2)
		. = invoked_callback.Invoke(arglist(args.Copy(3)))
	else
		. = invoked_callback.Invoke()
	usr = temp

/mob/verb/give_kudos(mob/living/target as mob in oview())
	set category = null
	set name = "Give Kudos (OOC)"

	if(target == src)
		to_chat(src, "<span class='warning'>You cannot give kudos to yourself!</span>")
		return

	to_chat(src, "<span class='notice'>You've given kudos to [target]!</span>")

	// Pretend we've always succeeded when we might not have.
	// This should prevent people from using it to suss anything out about mobs' states
	if(!client || !target.mind)
		return

	target.mind.kudos_received_from |= ckey


