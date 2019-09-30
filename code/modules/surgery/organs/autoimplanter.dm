/obj/item/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "walkietalkie"//left as this so as to intentionally not have inhands
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/weapons/circsawhit.ogg'
	var/uses = -1  // -1 is infinite as far as we care
	var/obj/item/organ/internal/cyberimp/storedorgan

/obj/item/autoimplanter/attack_self(mob/user)//when the object it used...
	if(uses == 0) // uses check before stored check here because a single use implanter probably wont have an implant in it after its been used up.
		to_chat(user, "<span class='notice'>[src] appears to be permanently jammed.</span>")
		return
	if(!storedorgan)
		to_chat(user, "<span class='notice'>[src] currently has no implant stored.</span>")
		return
	storedorgan.insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	uses = uses > 0 ? uses-1 : uses
	playsound(get_turf(user), usesound, 50, 1)
	storedorgan = null

/obj/item/autoimplanter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/internal/cyberimp))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] already has an implant stored.</span>")
			return
		if(uses == 0)
			to_chat(user, "<span class='notice'>[src] appears to be permanently jammed.</span>")
			return
		if(!user.drop_item())
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
			if(uses > 0)
				uses = uses - 1
			if(!uses)
				desc = "[initial(desc)] Looks like it's been used up."
			playsound(get_turf(user), I.usesound, 50, 1)

/obj/item/autoimplanter/cmo
	name = "Medical HUD autoimplanter"
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1 //only one time use!
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/medical()

/obj/item/autoimplanter/hos
	name = "Security HUD autoimplanter"
	desc = "A single use autosurgeon that contains a security heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1 
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/security()

/obj/item/autoimplanter/rd
	name = "Diagnostic HUD autoimplanter"
	desc = "A single use autosurgeon that contains a diagnostic heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1 
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic()

/obj/item/autoimplanter/meson
	name = "Meson scanner autoimplanter"
	desc = "A single use autosurgeon that contains a meson scanner augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1 
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/meson()
