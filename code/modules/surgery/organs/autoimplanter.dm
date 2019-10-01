/obj/item/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "walkietalkie"//left as this so as to intentionally not have inhands
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/weapons/circsawhit.ogg'
	var/uses = -1  // -1 is infinite as far as we care
	var/implanttime = 5 //fast for syndicate, .5sec
	var/obj/item/organ/internal/cyberimp/storedorgan
	var/possible_implants = list() //can put implant type references in here to let the user pick which one they want

/obj/item/autoimplanter/attack_self(mob/user)//when the object it used...
	if(uses == 0) // uses check before stored check here because a single use implanter probably wont have an implant in it after its been used up.
		to_chat(user, "<span class='notice'>[src] appears to be permanently jammed.</span>")
		return
	if(!storedorgan && length(possible_implants) > 0)
		var/selectedimplant = input("Select what to program the implant as.","Program Implant",/obj/item/organ/internal/cyberimp/eyes/hud/medical) in possible_implants
		storedorgan = new selectedimplant()
		return
	else if(!storedorgan)
		to_chat(user, "<span class='notice'>[src] currently has no implant stored.</span>")
		return
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	if(!do_mob(user,user,implanttime))
		user.show_message("<spam class='notice'>The autoimplanter detected movement and safely closed up and retracted itself.</span>")
		return
	storedorgan.insert(user)//insert stored organ into the user
	uses--
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
			to_chat(user, "<span class='notice'>You remove the [storedorgan.name] from [src].</span>")
			if(uses > 0)
				uses--
			if(!uses)
				desc = "[initial(desc)] Looks like it's been used up."
			else
				desc = "[initial(desc)] It has [uses] uses left."
			playsound(get_turf(user), I.usesound, 50, 1)
/obj/item/autoimplanter/head
	uses = 1 // only one time use!
	implanttime = 300 // slow for nanotrasen, 30sec

/obj/item/autoimplanter/head/Initialize()
	name = "[storedorgan.name] autoimplanter"
	desc = "A single use autoimplanter that contains a [storedorgan.name] augment. A screwdriver can be used to remove it, but implants can't be placed back in."

/obj/item/autoimplanter/head/cmo
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/medical()

/obj/item/autoimplanter/head/hos
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/security()

/obj/item/autoimplanter/head/rd
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic()

/obj/item/autoimplanter/head/meson
	storedorgan = new /obj/item/organ/internal/cyberimp/eyes/meson()

/obj/item/autoimplanter/head/blueshield
	possible_implants = list(/obj/item/organ/internal/cyberimp/eyes/hud/medical,/obj/item/organ/internal/cyberimp/eyes/hud/security)

/obj/item/autoimplanter/head/blueshield/Initialize()
	name = "Programmable autoimplanter"
	desc = "A single use autoimplanter that contains a programmable augment, able to be programmed permamently to either medical or security modes. A screwdriver can be used to remove it once programmed, but implants can't be placed back in."