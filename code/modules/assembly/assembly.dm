/obj/item/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100)
	throwforce = 2
	throw_speed = 3
	throw_range = 10
	origin_tech = "magnets=1;engineering=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'

	var/bomb_name = "bomb" // used for naming bombs / mines

	var/secured = TRUE
	var/list/attached_overlays = null
	var/obj/item/assembly_holder/holder = null
	var/cooldown = FALSE //To prevent spam
	var/wires = ASSEMBLY_WIRE_RECEIVE | ASSEMBLY_WIRE_PULSE
	var/datum/wires/connected = null // currently only used by timer/signaler

/obj/item/assembly/proc/activate()									//What the device does when turned on
	return

/obj/item/assembly/proc/pulsed(radio = FALSE)						//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
	return

/obj/item/assembly/proc/toggle_secure()								//Code that has to happen when the assembly is un\secured goes here
	return

/obj/item/assembly/proc/attach_assembly(obj/A, mob/user)	//Called when an assembly is attacked by another
	return

/obj/item/assembly/proc/process_cooldown()							//Called via spawn(10) to have it count down the cooldown var
	return

/obj/item/assembly/proc/holder_movement()							//Called when the holder is moved
	return

/obj/item/assembly/interact(mob/user)					//Called when attack_self is called
	return

/obj/item/assembly/process_cooldown()
	cooldown--
	if(cooldown <= 0)
		return FALSE
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 10)
	return TRUE

/obj/item/assembly/Destroy()
	if(istype(loc, /obj/item/assembly_holder) || istype(holder))
		var/obj/item/assembly_holder/A = loc
		if(A.a_left == src)
			A.a_left = null
		else if(A.a_right == src)
			A.a_right = null
		holder = null
	return ..()

/obj/item/assembly/pulsed(radio = FALSE)
	if(holder && (wires & ASSEMBLY_WIRE_RECEIVE))
		activate()
	if(radio && (wires & ASSEMBLY_WIRE_RADIO_RECEIVE))
		activate()
	return TRUE

//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
/obj/item/assembly/proc/pulse(radio = FALSE)
	if(connected && wires)
		connected.pulse_assembly(src)
		return TRUE
	if(holder && (wires & ASSEMBLY_WIRE_PULSE))
		holder.process_activation(src, 1, 0)
	if(holder && (wires & ASSEMBLY_WIRE_PULSE_SPECIAL))
		holder.process_activation(src, 0, 1)
	if(istype(loc, /obj/item/grenade)) // This is a hack.  Todo: Manage this better -Sayu
		var/obj/item/grenade/G = loc
		G.prime()                // Adios, muchachos
	return TRUE

/obj/item/assembly/activate()
	if(!secured || cooldown > 0)
		return FALSE
	cooldown = 2
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 10)
	return TRUE

/obj/item/assembly/toggle_secure()
	secured = !secured
	update_icon()
	return secured

/obj/item/assembly/attach_assembly(obj/item/assembly/A, mob/user)
	holder = new /obj/item/assembly_holder(get_turf(src))
	if(holder.attach(A, src, user))
		to_chat(user, "<span class='notice'>You attach [A] to [src]!</span>")
		user.put_in_active_hand(holder)
		return TRUE
	return FALSE

/obj/item/assembly/attackby(obj/item/W, mob/user, params)
	if(isassembly(W))
		var/obj/item/assembly/A = W
		if(!A.secured && !secured)
			attach_assembly(A, user)
		return

	return ..()

/obj/item/assembly/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(toggle_secure())
		to_chat(user, "<span class='notice'>[src] is ready!</span>")
	else
		to_chat(user, "<span class='notice'>[src] can now be attached!</span>")

/obj/item/assembly/process()
	STOP_PROCESSING(SSobj, src)

/obj/item/assembly/examine(mob/user)
	. = ..()
	if(in_range(src, user) || loc == user)
		if(secured)
			. += "[src] is ready!"
		else
			. += "[src] can be attached!"

/obj/item/assembly/attack_self(mob/user)
	if(!user)
		return
	user.set_machine(src)
	interact(user)
	return TRUE

/obj/item/assembly/interact(mob/user)
	return
