/obj/structure/surgicalcart
	name = "surgical cart"
	desc = "A small metal tray with wheels for your surgical tools."
	icon = 'icons/hispania/obj/tools.dmi'
	icon_state = "medicart"
	anchored = FALSE
	density = TRUE
	buckle_offset = 0
	can_buckle = TRUE
	max_integrity = 200
	buckle_lying = 0
	var/material_drop_type = /obj/item/stack/sheet/mineral/titanium
	var/obj/item/reagent_containers/syringe/mysyringe
	var/obj/item/stack/medical/bruise_pack/advanced/mymbruise
	var/obj/item/surgicaldrill/mydrill
	var/obj/item/circular_saw/mysaw
	var/obj/item/bonesetter/mybones
	var/obj/item/FixOVein/myvein
	var/obj/item/bonegel/mygel
	var/obj/item/hemostat/myhemo
	var/obj/item/retractor/myretra
	var/obj/item/scalpel/myscal
	var/obj/item/cautery/mycaute

/obj/structure/surgicalcart/Destroy()
	QDEL_NULL(mysyringe)
	QDEL_NULL(mymbruise)
	QDEL_NULL(mydrill)
	QDEL_NULL(mysaw)
	QDEL_NULL(mybones)
	QDEL_NULL(myvein)
	QDEL_NULL(mygel)
	QDEL_NULL(myhemo)
	QDEL_NULL(myretra)
	QDEL_NULL(myscal)
	QDEL_NULL(mycaute)
	return ..()

/obj/structure/surgicalcart/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/surgicalcart/wrench_act(mob/user, obj/item/I)
	if(!anchored && !isinspace())
		playsound(src.loc, I.usesound, 50, 1)
		user.visible_message( \
			"[user] tightens \the [src]'s casters.", \
			"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
			"You hear ratchet.")
		anchored = TRUE
	else
		playsound(src.loc, I.usesound, 50, 1)
		user.visible_message( \
			"[user] loosens \the [src]'s casters.", \
			"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
			"You hear ratchet.")
		anchored = FALSE

/obj/structure/surgicalcart/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/drop_amt = 5
		new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

/obj/structure/surgicalcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	updateUsrDialog()
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return

/obj/structure/surgicalcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"
	if(!I.is_robot_module())
		if(istype(I, /obj/item/reagent_containers/syringe))
			if(!mysyringe)
				put_in_cart(I, user)
				mysyringe=I
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/stack/medical/bruise_pack/advanced))
			if(!mymbruise)
				put_in_cart(I, user)
				mymbruise=I
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/surgicaldrill))
			if(!mydrill)
				put_in_cart(I, user)
				mydrill=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/circular_saw))
			if(!mysaw)
				put_in_cart(I, user)
				mysaw=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/bonesetter))
			if(!mybones)
				put_in_cart(I, user)
				mybones=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/FixOVein))
			if(!myvein)
				put_in_cart(I, user)
				myvein=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/bonegel))
			if(!mygel)
				put_in_cart(I, user)
				mygel=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/hemostat))
			if(!myhemo)
				put_in_cart(I, user)
				myhemo=I
				update_icon()
			else
		else if(istype(I, /obj/item/retractor))
			if(!myretra)
				put_in_cart(I, user)
				myretra=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/scalpel))
			if(!myscal)
				put_in_cart(I, user)
				myscal=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/cautery))
			if(!mycaute)
				put_in_cart(I, user)
				mycaute=I
				update_icon()
			else
				to_chat(user, fail_msg)
		else
			to_chat(usr, "<span class='warning'>You cannot put that on [src]!</span>")
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/surgicalcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(mysyringe)
		dat += "<a href='?src=[UID()];syringe=1'>[mysyringe.name]</a><br>"
	if(mymbruise)
		dat += "<a href='?src=[UID()];bruise=1'>[mymbruise.name]</a><br>"
	if(mydrill)
		dat += "<a href='?src=[UID()];drill=1'>[mydrill.name]</a><br>"
	if(mysaw)
		dat += "<a href='?src=[UID()];circular_saw=1'>[mysaw.name]</a><br>"
	if(mybones)
		dat += "<a href='?src=[UID()];bone_setter=1'>[mybones.name]</a><br>"
	if(myvein)
		dat += "<a href='?src=[UID()];fixovein=1'>[myvein.name]</a><br>"
	if(mygel)
		dat += "<a href='?src=[UID()];bone_gel=1'>[mygel.name]</a><br>"
	if(myhemo)
		dat += "<a href='?src=[UID()];hemostat=1'>[myhemo.name]</a><br>"
	if(myretra)
		dat += "<a href='?src=[UID()];retractor=1'>[myretra.name]</a><br>"
	if(myscal)
		dat += "<a href='?src=[UID()];scalpel=1'>[myscal.name]</a><br>"
	if(mycaute)
		dat += "<a href='?src=[UID()];cautery=1'>[mycaute.name]</a><br>"
	var/datum/browser/popup = new(user, "medicart", name, 340, 360)
	popup.set_content(dat)
	popup.open()

/obj/structure/surgicalcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["syringe"])
		if(mysyringe)
			user.put_in_hands(mysyringe)
			to_chat(user, "<span class='notice'>You take [mysyringe] from [src].</span>")
			mysyringe = null
	if(href_list["bruise"])
		if(mymbruise)
			user.put_in_hands(mymbruise)
			to_chat(user, "<span class='notice'>You take [mymbruise] from [src].</span>")
			mymbruise = null
	if(href_list["drill"])
		if(mydrill)
			user.put_in_hands(mydrill)
			to_chat(user, "<span class='notice'>You take [mydrill] from [src].</span>")
			mydrill = null
	if(href_list["circular_saw"])
		if(mysaw)
			user.put_in_hands(mysaw)
			to_chat(user, "<span class='notice'>You take [mysaw] from [src].</span>")
			mysaw = null
	if(href_list["bone_setter"])
		if(mybones)
			user.put_in_hands(mybones)
			to_chat(user, "<span class='notice'>You take [mybones] from [src].</span>")
			mybones = null
	if(href_list["fixovein"])
		if(myvein)
			user.put_in_hands(myvein)
			to_chat(user, "<span class='notice'>You take [myvein] from [src].</span>")
			myvein = null
	if(href_list["bone_gel"])
		if(mygel)
			user.put_in_hands(mygel)
			to_chat(user, "<span class='notice'>You take [mygel] from [src].</span>")
			mygel = null
	if(href_list["hemostat"])
		if(myhemo)
			user.put_in_hands(myhemo)
			to_chat(user, "<span class='notice'>You take [myhemo] from [src].</span>")
			myhemo = null
	if(href_list["retractor"])
		if(myretra)
			user.put_in_hands(myretra)
			to_chat(user, "<span class='notice'>You take [myretra] from [src].</span>")
			myretra = null
	if(href_list["scalpel"])
		if(myscal)
			user.put_in_hands(myscal)
			to_chat(user, "<span class='notice'>You take [myscal] from [src].</span>")
			myscal = null
	if(href_list["cautery"])
		if(mycaute)
			user.put_in_hands(mycaute)
			to_chat(user, "<span class='notice'>You take [mycaute] from [src].</span>")
			mycaute = null
	updateUsrDialog()
	update_icon()

/obj/structure/surgicalcart/update_icon()
	overlays.Cut()
	if(mydrill)
		overlays += "mydrill"
	if(mysaw)
		overlays += "mysaw"
	if(mybones)
		overlays += "mysetter"
	if(myvein)
		overlays += "myfix"
	if(mygel)
		overlays += "mybone"
	if(myhemo)
		overlays += "myhemo"
	if(myretra)
		overlays += "my_retractor"
	if(mycaute)
		overlays += "my_cautery"
	if(myscal)
		overlays += "myscalpel"

/obj/structure/surgicalcart/full/New()
	. = ..()
	mysyringe = new /obj/item/reagent_containers/syringe/antiviral(src) ///Esto es spacellin, le juro no son nanomachines
	mymbruise = new /obj/item/stack/medical/bruise_pack/advanced(src)
	mydrill = new /obj/item/surgicaldrill(src)
	mysaw = new /obj/item/circular_saw(src)
	mybones = new /obj/item/bonesetter(src)
	myvein = new /obj/item/FixOVein(src)
	mygel = new /obj/item/bonegel(src)
	myhemo = new /obj/item/hemostat(src)
	myretra = new /obj/item/retractor(src)
	myscal = new /obj/item/scalpel(src)
	mycaute = new /obj/item/cautery(src)
	update_icon()
