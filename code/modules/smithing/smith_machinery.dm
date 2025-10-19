/obj/machinery/smithing
	name = "smithing machine"
	desc = "A large unknown smithing machine. If you see this, there's a problem and you should notify the development team."
	icon = 'icons/obj/machines/large_smithing_machines.dmi'
	icon_state = "power_hammer"
	pixel_y = -32
	bound_height = 64
	bound_width = 64
	bound_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	req_one_access = list(ACCESS_SMITH)
	/// How many loops per operation
	var/operation_time = 10
	/// Is this active
	var/operating = FALSE
	/// Cooldown on harming
	var/special_attack_cooldown = 10 SECONDS
	/// Are we on harm cooldown
	var/special_attack_on_cooldown = FALSE
	/// Store the worked component
	var/obj/item/smithed_item/component/working_component
	/// The noise the machine makes when operating
	var/operation_sound
	/// Will the machine auto-repeat?
	var/repeating = FALSE

/obj/machinery/smithing/examine(mob/user)
	. = ..()
	if(working_component)
		. += "<span class='notice'>You can activate the machine with your hand, or remove the component by alt-clicking.</span>"
		. += "<span class='notice'>There is currently a [working_component] in [src].</span>"

/obj/machinery/smithing/power_change()
	if(!..())
		return
	// If power is lost during operation, reset the operating flag to prevent the machine from getting stuck
	if(stat & NOPOWER && operating)
		operating = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/smithing/Destroy()
	if(working_component)
		working_component.forceMove(src.loc)
	. = ..()

/obj/machinery/smithing/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/grab))
		var/obj/item/grab/G = used
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='danger'>Putting [G.affecting] in [src] might hurt them!</span>")
			return ITEM_INTERACT_COMPLETE
		special_attack_grab(G, user)
		return ITEM_INTERACT_COMPLETE

	if(operating)
		to_chat(user, "<span class='warning'>[src] is still operating!</span>")
		return FINISH_ATTACK

	if(istype(used, /obj/item/smithed_item/component))
		if(used.flags & NODROP || !user.drop_item() || !used.forceMove(src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE

		if(working_component)
			user.put_in_active_hand(working_component)
			to_chat(user, "<span class='notice'>You swap [used] with [working_component] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>You insert [used] into [src].</span>")

		working_component = used
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/smithing/emag_act(user as mob)
	if(!emagged)
		playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
		req_one_access = list()
		emagged = TRUE
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")
		return TRUE

/obj/machinery/smithing/proc/operate(loops, mob/living/user)
	operating = TRUE
	update_icon(ALL)
	for(var/i in 1 to loops)
		if(stat & (NOPOWER|BROKEN))
			operating = FALSE
			update_icon(ALL)
			return FALSE
		use_power(500)
		if(operation_sound)
			playsound(src, operation_sound, 50, TRUE)
		sleep(1 SECONDS)
	playsound(src, 'sound/machines/recycler.ogg', 50, FALSE)
	operating = FALSE
	update_icon(ALL)

/obj/machinery/smithing/proc/special_attack_grab(obj/item/grab/G, mob/user)
	if(special_attack_on_cooldown)
		return FALSE
	if(!istype(G))
		return FALSE
	if(!iscarbon(G.affecting))
		to_chat(user, "<span class='warning'>You can't shove that in there!</span>")
		return FALSE
	if(G.state < GRAB_NECK)
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return FALSE
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>You try to shove someone into the machine, but your access is denied!</span>")
		return FALSE
	var/result = special_attack(user, G.affecting)
	user.changeNext_move(CLICK_CD_MELEE)
	special_attack_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, special_attack_on_cooldown, FALSE), special_attack_cooldown)
	if(result && !QDELETED(G))
		qdel(G)

	return TRUE

/obj/machinery/smithing/proc/special_attack(mob/user, mob/living/target)
	return

/obj/machinery/smithing/AltClick(mob/living/user)
	. = ..()
	if(!Adjacent(user))
		return
	if(!working_component)
		to_chat(user, "<span class='notice'>There isn't anything in [src].</span>")
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] is currently operating!</span>")
		return
	if(working_component.burn_check(user))
		working_component.burn_user(user)
		working_component.forceMove(user.loc)
		working_component = null
		return
	user.put_in_hands(working_component)
	working_component = null

/obj/machinery/smithing/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(operating)
		to_chat(user, "<span class='alert'>[src] is busy. Please wait for completion of previous operation.</span>")
		return
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/smithing/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE
