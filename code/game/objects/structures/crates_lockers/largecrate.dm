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

/obj/structure/largecrate/attackby(obj/item/W as obj, mob/user as mob, params)
	if(user.a_intent != INTENT_HARM)
		attack_hand(user)
	else
		return ..()

/obj/structure/largecrate/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(manifest)
		manifest.forceMove(loc)
		manifest = null
		update_icon()
	new /obj/item/stack/sheet/wood(src)
	var/turf/T = get_turf(src)
	for(var/O in contents)
		var/atom/movable/A = O
		A.forceMove(T)
	user.visible_message("<span class='notice'>[user] pries [src] open.</span>", \
						"<span class='notice'>You pry open [src].</span>", \
						"<span class='notice'>You hear splitting wood.</span>")
	qdel(src)

/obj/structure/largecrate/Destroy()
	var/turf/src_turf = get_turf(src)
	for(var/obj/O in contents)
		O.forceMove(src_turf)
	return ..()

/obj/structure/largecrate/mule

/obj/structure/largecrate/lisa
	icon_state = "lisacrate"

/obj/structure/largecrate/lisa/crowbar_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	new /mob/living/simple_animal/pet/dog/corgi/Lisa(loc)
	return ..()

/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cow/crowbar_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	new /mob/living/simple_animal/cow(loc)
	return ..()

/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/goat/crowbar_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	new /mob/living/simple_animal/hostile/retaliate/goat(loc)
	return ..()

/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/chick/crowbar_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	var/num = rand(4, 6)
	for(var/i in 1 to num)
		new /mob/living/simple_animal/chick(loc)
	return ..()

/obj/structure/largecrate/cat
	name = "cat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cat/crowbar_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	new /mob/living/simple_animal/pet/cat(loc)
	return ..()

/obj/structure/largecrate/secway
	name = "secway crate"

/obj/structure/largecrate/secway/crowbar_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	new /obj/vehicle/secway(loc)
	new /obj/item/key/security(loc)
	return ..()
