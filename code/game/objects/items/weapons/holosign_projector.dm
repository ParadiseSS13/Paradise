/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "This shouldnt exist, if it does, tell a coder."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	inhand_icon_state = "electronic"
	belt_icon = "holosign_creator"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	origin_tech = "magnets=1;programming=3"
	flags = NOBLUDGEON
	var/list/signs = list()
	var/max_signs = 6
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = null
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/afterattack__legacy__attackchain(atom/target, mob/user, flag)
	if(flag)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate(holosign_type) in T
		if(H)
			to_chat(user, "<span class='notice'>You use [src] to deactivate [H].</span>")
			qdel(H)
		else
			if(!T.is_blocked_turf(exclude_mobs = TRUE)) //can't put holograms on a tile that has dense stuff
				if(holocreator_busy)
					to_chat(user, "<span class='notice'>[src] is busy creating a hologram.</span>")
					return
				if(length(signs) < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
					if(creation_time)
						holocreator_busy = TRUE
						if(!do_after(user, creation_time, target = target))
							holocreator_busy = FALSE
							return
						holocreator_busy = FALSE
						if(length(signs) >= max_signs)
							return
						if(T.is_blocked_turf(exclude_mobs = TRUE)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target), src)
					to_chat(user, "<span class='notice'>You create [H] with [src].</span>")
					return H
				else
					to_chat(user, "<span class='notice'>[src] is projecting at max capacity!</span>")

/obj/item/holosign_creator/attack__legacy__attackchain(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self__legacy__attackchain(mob/user)
	if(length(signs))
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")

/obj/item/holosign_creator/janitor
	name = "janitorial holosign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	holosign_type = /obj/structure/holosign/wetsign
	max_signs = 18
	var/wet_enabled = TRUE

/obj/item/holosign_creator/janitor/AltClick(mob/user)
	wet_enabled = !wet_enabled
	playsound(loc, 'sound/weapons/empty.ogg', 20)
	if(wet_enabled)
		to_chat(user, "<span class='notice'>You enable the W.E.T. (wet evaporation timer)\nAny newly placed holographic signs will clear after the likely time it takes for a mopped tile to dry.</span>")
	else
		to_chat(user, "<span class='notice'>You disable the W.E.T. (wet evaporation timer)\nAny newly placed holographic signs will now stay indefinitely.</span>")

/obj/item/holosign_creator/janitor/examine(mob/user)
	. = ..()
	if(ishuman(user))
		. += "<span class='notice'>Alt Click to [wet_enabled ? "deactivate" : "activate"] its built-in wet evaporation timer.</span>"


/obj/item/holosign_creator/janitor/afterattack__legacy__attackchain(atom/target, mob/user, flag)
	var/obj/structure/holosign/wetsign/WS = ..()
	if(WS && wet_enabled)
		WS.wet_timer_start(src)

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 30

/obj/item/holosign_creator/detective
	name = "detective holobarrier projector"
	desc = "A holographic projector that creates shocked investigation barriers."
	icon_state = "signmaker_det"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier/cyborg/hacked/detective
	creation_time = 1 SECONDS
	max_signs = 8

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 30

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_engi"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier/atmos
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "energy barrier projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self__legacy__attackchain(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, "<span class='notice'>You clear all active holograms, and reset your projector to normal.</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 0
			return
		else if(R.emagged && !shock)
			to_chat(user, "<span class='warning'>You clear all active holograms, and overload your energy projector!</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 1
			return
		else
			if(length(signs))
				for(var/H in signs)
					qdel(H)
				to_chat(user, "<span class='notice'>You clear all active holograms.</span>")
	if(length(signs))
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")
