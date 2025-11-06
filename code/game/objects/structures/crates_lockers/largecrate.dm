/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "largecrate"
	density = TRUE
	var/obj/item/paper/manifest/manifest

/obj/structure/largecrate/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/largecrate/update_overlays()
	. = ..()
	if(manifest)
		. += "manifest"

/obj/structure/largecrate/attack_hand(mob/user as mob)
	if(manifest)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove(loc)
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	else
		to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")
		return

/obj/structure/largecrate/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent != INTENT_HARM)
		attack_hand(user)
		return ITEM_INTERACT_COMPLETE

/obj/structure/largecrate/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return TRUE
	break_open()
	user.visible_message("<span class='notice'>[user] pries [src] open.</span>", \
						"<span class='notice'>You pry open [src].</span>", \
						"<span class='notice'>You hear splitting wood.</span>")
	if(manifest)
		manifest.forceMove(loc)
		manifest = null
		update_icon()
	new /obj/item/stack/sheet/wood(src)
	var/turf/T = get_turf(src)
	for(var/O in contents)
		var/atom/movable/A = O
		A.forceMove(T)
	qdel(src)

/obj/structure/largecrate/proc/break_open()
	return

/obj/structure/largecrate/Destroy()
	var/turf/src_turf = get_turf(src)
	for(var/obj/O in contents)
		O.forceMove(src_turf)
	return ..()

/obj/structure/largecrate/mule

/obj/structure/largecrate/lisa
	icon_state = "lisacrate"

/obj/structure/largecrate/lisa/break_open()
	new /mob/living/simple_animal/pet/dog/corgi/lisa(loc)

/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cow/break_open()
	new /mob/living/basic/cow(loc)

/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/goat/break_open()
	new /mob/living/basic/goat(loc)

/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/chick/break_open()
	var/num = rand(4, 6)
	for(var/i in 1 to num)
		new /mob/living/basic/chick(loc)

/obj/structure/largecrate/cat
	name = "cat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cat/break_open()
	new /mob/living/simple_animal/pet/cat(loc)

/obj/structure/largecrate/secway
	name = "secway crate"

/obj/structure/largecrate/secway/break_open()
	new /obj/vehicle/secway(loc)
	new /obj/item/key/security(loc)
