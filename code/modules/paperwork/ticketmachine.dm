//Bureaucracy machine!
//Simply set this up in the hopline and you can serve people based on ticket numbers

/obj/machinery/ticket_machine
	name = "ticket machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticketmachine"
	desc = "A marvel of bureaucratic engineering encased in an efficient plastic shell. It can be refilled with a hand labeler refill roll and linked to buttons with a multitool."
	anchored = TRUE
	maptext_height = 26
	maptext_x = 7
	maptext_y = 10
	layer = HIGH_OBJ_LAYER
	var/ticket_number = 0 //Increment the ticket number whenever the HOP presses his button
	var/current_number = 0 //What ticket number are we currently serving?
	var/max_number = 100 //At this point, you need to refill it.
	var/cooldown = 50
	var/ready = TRUE
	var/list/ticket_holders = list()
	var/list/tickets = list()
	var/id = 1
	/// If FALSE, the ticket machine will not dispense tickets. Toggled by swiping  aHoP ID
	var/dispense_enabled = TRUE

/obj/machinery/ticket_machine/Destroy()
	for(var/obj/item/ticket_machine_ticket/ticket in tickets)
		ticket.visible_message("<span class='notice'>\the [ticket] disperses!</span>")
		qdel(ticket)
	tickets.Cut()
	return ..()

/obj/machinery/ticket_machine/emag_act(mob/user) //Emag the ticket machine to dispense burning tickets, as well as randomize its number to destroy the HoP's mind.
	if(emagged)
		return
	to_chat(user, "<span class='warning'>You overload [src]'s bureaucratic logic circuitry to its MAXIMUM setting.</span>")
	ticket_number = rand(0, max_number)
	current_number = ticket_number
	emagged = TRUE
	for(var/obj/item/ticket_machine_ticket/ticket in tickets)
		ticket.visible_message("<span class='notice'>\the [ticket] disperses!</span>")
		qdel(ticket)
	tickets.Cut()
	update_icon()
	return TRUE

/obj/machinery/ticket_machine/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/ticket_machine/proc/increment()
	if(current_number > ticket_number)
		return
	if(current_number && !(emagged) && tickets[current_number])
		var/obj/item/ticket_machine_ticket/ticket = tickets[current_number]
		ticket.audible_message("<span class='notice'>\the [tickets[current_number]] disperses!</span>")
		qdel(ticket)
	if(current_number < ticket_number)
		current_number ++ //Increment the one we're serving.
		playsound(src, 'sound/misc/announce_dig.ogg', 50, FALSE)
		atom_say("Now serving ticket #[current_number]!")
		if(!(emagged) && tickets[current_number])
			var/obj/item/ticket_machine_ticket/ticket = tickets[current_number]
			ticket.audible_message("<span class='notice'>\the [tickets[current_number]] vibrates!</span>")
		update_icon() //Update our icon here rather than when they take a ticket to show the current ticket number being served

/obj/machinery/door_control/ticket_machine_button
	name = "increment ticket counter"
	desc = "Use this button after you've served someone to tell the next person to come forward."
	req_access = list()
	id = 1
	var/cooldown = FALSE


/obj/machinery/door_control/ticket_machine_button/attack_hand(mob/user)
	if(allowed(usr) || user.can_advanced_admin_interact())
		icon_state = "doorctrl1"
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 15)
		for(var/obj/machinery/ticket_machine/M in SSmachines.get_by_type(/obj/machinery/ticket_machine))
			if(M.id == id)
				if(cooldown)
					return
				cooldown = TRUE
				M.increment()
				addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)
	else
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		flick("doorctrl-denied", src)

/obj/machinery/door_control/ticket_machine_button/update_icon_state()
	if(!(stat & NOPOWER))
		icon_state = "doorctrl0"

/obj/machinery/ticket_machine/update_icon_state()
	switch(ticket_number) //Gives you an idea of how many tickets are left
		if(0 to 49)
			icon_state = "ticketmachine_100"
		if(50 to 99)
			icon_state = "ticketmachine_50"
		if(100)
			icon_state = "ticketmachine_0"
	handle_maptext()

/obj/machinery/ticket_machine/proc/handle_maptext()
	if(!dispense_enabled)
		maptext_x = 6
		maptext = "<font face='Small Fonts' color='#960b0b'>OFF</font>"
		return
	switch(ticket_number) //This is here to handle maptext offsets so that the numbers align.
		if(0 to 9)
			maptext_x = 13
		if(10 to 99)
			maptext_x = 10
		if(100)
			maptext_x = 8
	maptext = "<font face='Small Fonts'>[ticket_number]</font>"

/obj/machinery/ticket_machine/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/hand_labeler_refill))
		if(!(ticket_number >= max_number))
			to_chat(user, "<span class='notice'>[src] refuses [used]! There [max_number-ticket_number==1 ? "is" : "are"] still [max_number-ticket_number] ticket\s left!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You start to refill [src]'s ticket holder (doing this will reset its ticket count!).</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You insert [used] into [src] as it whirs nondescriptly.</span>")
			user.drop_item()
			qdel(used)
			ticket_number = 0
			current_number = 0
			for(var/obj/item/ticket_machine_ticket/ticket in tickets)
				ticket.audible_message("<span class='notice'>\the [ticket] disperses!</span>")
				qdel(ticket)
			tickets.Cut()
			max_number = initial(max_number)
			update_icon()

		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/heldID = used
		if(ACCESS_HOP in heldID.access)
			dispense_enabled = !dispense_enabled
			to_chat(user, "<span class='notice'>You [dispense_enabled ? "enable" : "disable"] [src], it will [dispense_enabled ? "now" : "no longer"] dispense tickets!</span>")
			handle_maptext()
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='warning'>You do not have the required access to [dispense_enabled ? "disable" : "enable"] the ticket machine.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/ticket_machine/proc/reset_cooldown()
	ready = TRUE

/obj/machinery/ticket_machine/attack_hand(mob/living/carbon/user)
	. = ..()
	if(!ready)
		to_chat(user,"<span class='warning'>You press the button, but nothing happens...</span>")
		return
	if(!dispense_enabled)
		to_chat(user, "<span class='warning'>[src] is disabled.</span>")
		return
	if(ticket_number >= max_number)
		to_chat(user,"<span class='warning'>Ticket supply depleted, please refill this unit with a hand labeller refill cartridge!</span>")
		return
	if((user.UID() in ticket_holders) && !(emagged))
		to_chat(user, "<span class='warning'>You already have a ticket!</span>")
		return
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, FALSE)
	ticket_number ++
	to_chat(user, "<span class='notice'>You take a ticket from [src], looks like you're ticket number #[ticket_number]...</span>")
	var/obj/item/ticket_machine_ticket/theirticket = new /obj/item/ticket_machine_ticket(get_turf(src))
	theirticket.name = "Ticket #[ticket_number]"
	theirticket.maptext = "<font color='#000000' face='Small Fonts'>[ticket_number]</font>"
	theirticket.saved_maptext = "<font color='#000000' face='Small Fonts'>[ticket_number]</font>"
	theirticket.ticket_number = ticket_number
	theirticket.source = src
	theirticket.owner = user.UID()
	user.put_in_hands(theirticket)
	ticket_holders += user.UID()
	tickets += theirticket
	if(emagged) //Emag the machine to destroy the HOP's life.
		ready = FALSE
		addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), cooldown)//Small cooldown to prevent piles of flaming tickets
		theirticket.fire_act()
		user.drop_item()
		user.adjust_fire_stacks(1)
		user.IgniteMob()

// Stop AI penetrating the bureaucracy
/obj/machinery/ticket_machine/attack_ai(mob/user)
	return

/obj/machinery/ticket_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use an ID card with <b>Head of Personnel</b> access on this machine to [dispense_enabled ? "disable" : "enable"] ticket dispensing.</span>"

/obj/item/ticket_machine_ticket
	name = "Ticket"
	desc = "A ticket which shows your place in the Head of Personnel's line. Made from Nanotrasen patented NanoPaper. Though solid, its form seems to shimmer slightly. Feels (and burns) just like the real thing."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticket"
	maptext_x = 7
	maptext_y = 10
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/saved_maptext = null
	var/owner //soft ref of the ticket owner's UID()
	var/obj/machinery/ticket_machine/source
	var/ticket_number

/obj/item/ticket_machine_ticket/attack_hand(mob/user)
	. = ..()
	maptext = saved_maptext //For some reason, storage code removes all maptext off objs, this stops its number from being wiped off when taken out of storage.

/obj/item/ticket_machine_ticket/attackby__legacy__attackchain(obj/item/P, mob/living/carbon/human/user, params) //Stolen from papercode
	..()
	if(P.get_heat())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_themselves()]!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.drop_item()
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

/obj/item/paper/extinguish()
	..()
	update_icon()

/obj/item/ticket_machine_ticket/Destroy()
	if(owner && source)
		source.ticket_holders -= owner
		source.tickets[ticket_number] = null
		source = null
	return ..()
