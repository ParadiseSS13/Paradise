/obj/item/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-autoimplanter"
	item_state = "walkietalkie"//left as this so as to intentionally not have inhands
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/weapons/circsawhit.ogg'
	var/obj/item/organ/internal/cyberimp/storedorgan

/obj/item/autoimplanter/old
	icon_state = "autoimplanter"

/obj/item/autoimplanter/attack_self(mob/user)//when the object it used...
	if(!storedorgan)
		to_chat(user, "<span class='notice'>[src] currently has no implant stored.</span>")
		return FALSE
	storedorgan.insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), usesound, 50, 1)
	storedorgan = null
	return TRUE

/obj/item/autoimplanter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/internal/cyberimp))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] already has an implant stored.</span>")
			return
		if(!user.temporarily_remove_item_from_inventory(I))
			return
		I.forceMove(src)
		storedorgan = I
		to_chat(user, "<span class='notice'>You insert the [I] into [src].</span>")
	else if(istype(I, /obj/item/screwdriver))
		if(!storedorgan)
			to_chat(user, "<span class='notice'>There's no implant in [src] for you to remove.</span>")
		else
			storedorgan.forceMove(get_turf(user))
			storedorgan = null
			to_chat(user, "<span class='notice'>You remove the [storedorgan] from [src].</span>")
			playsound(get_turf(user), I.usesound, 50, 1)

/obj/item/autoimplanter/oneuse
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. At once."

/obj/item/autoimplanter/oneuse/attack_self(mob/user)
	. = ..()
	user.drop_from_active_hand()
	visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/autoimplanter/oneuse/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		storedorgan.forceMove(get_turf(user))
		storedorgan = null
		to_chat(user, "<span class='notice'>You remove the [storedorgan] from [src].</span>")
		playsound(get_turf(user), I.usesound, 50, 1)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
	. = ..()

/obj/item/autoimplanter/oneuse/mantisblade
	name = "autoimplanter(mantis blade right)"
	storedorgan = new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/horlex

/obj/item/autoimplanter/oneuse/mantisblade/l
	name = "autoimplanter(mantis blade left)"
	storedorgan = new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/horlex/l

/obj/item/autoimplanter/traitor
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. This model is capable of implanting up to three implants before destroing."
	var/uses = 3

/obj/item/autoimplanter/traitor/attack_self(mob/user)
	if(!..())
		return
	uses--
	if(uses == 0)
		user.drop_from_active_hand()
		visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)

/obj/item/autoimplanter/traitor/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class = 'notice'>There are [uses] uses left.</span>"
