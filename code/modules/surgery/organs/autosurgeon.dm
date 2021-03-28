#define INFINITE -1

/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = ""
	w_class = WEIGHT_CLASS_SMALL
	var/uses = INFINITE

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/organ
	name = "implant autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."
	var/organ_type = /obj/item/organ/internal
	var/starting_organ
	var/obj/item/organ/internal/storedorgan

/obj/item/autosurgeon/organ/syndicate
	name = "suspicious implant autosurgeon"
	icon_state = "syndicate_autoimplanter"

/obj/item/autosurgeon/organ/Initialize(mapload)
	. = ..()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/autosurgeon/organ/proc/insert_organ(obj/item/I)
	storedorgan = I
	I.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/autosurgeon/organ/attack_self(mob/user) //when the object it used...
	if(!uses)
		to_chat(user, "<span class='alert'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return
	else if(!storedorgan)
		to_chat(user, "<span class='alert'>[src] currently has no implant stored.</span>")
		return
	storedorgan.insert(user) //insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/organ/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='alert'>[src] already has an implant stored.</span>")
			return
		else if(!uses)
			to_chat(user, "<span class='alert'>[src] has already been used up.</span>")
			return
		if(!user.drop_item())
			return
		I.forceMove(src)
		storedorgan = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/organ/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, "<span class='warning'>There's no implant in [src] for you to remove!</span>")
	else
		storedorgan.forceMove(user.drop_location())

		to_chat(user, "<span class='notice'>You remove [storedorgan] from [src].</span>")
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/organ/syndicate/laser_arm
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/arm/gun/laser

/obj/item/autosurgeon/organ/syndicate/thermal_eyes
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/thermals

/obj/item/autosurgeon/organ/syndicate/xray_eyes
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/xray

/obj/item/autosurgeon/organ/syndicate/anti_stun
	starting_organ = /obj/item/organ/internal/cyberimp/brain/anti_stun/hardened

/obj/item/autosurgeon/organ/syndicate/reviver
	starting_organ = /obj/item/organ/internal/cyberimp/chest/reviver/hardened

#undef INFINITE
