/obj/item/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE
	var/static/list/lipstick_colors

/obj/item/lipstick/Initialize(mapload)
	. = ..()
	if(!lipstick_colors)
		lipstick_colors = list(
			"black" = "#000000",
			"white" = "#FFFFFF",
			"red" = "#FF0000",
			"green" = "#00C000",
			"blue" = "#0000FF",
			"purple" = "#D55CD0",
			"jade" = "#216F43",
			"lime" = "#00FF00",
		)

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/lipstick/lime
	name = "lime lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/green
	name = "green lipstick"
	colour = "green"

/obj/item/lipstick/blue
	name = "blue lipstick"
	colour = "blue"

/obj/item/lipstick/white
	name = "white lipstick"
	colour = "white"

/obj/item/lipstick/random
	name = "lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	colour = pick(lipstick_colors)
	name = "[colour] lipstick"

/obj/item/lipstick/attack_self__legacy__attackchain(mob/user)
	cut_overlays()
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		var/mutable_appearance/colored = mutable_appearance('icons/obj/items.dmi', "lipstick_uncap_color")
		colored.color = lipstick_colors[colour]
		icon_state = "lipstick_uncap"
		add_overlay(colored)
	else
		icon_state = "lipstick"

/obj/item/lipstick/attack__legacy__attackchain(mob/M, mob/user)
	if(!open || !istype(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	// If they already have lipstick on
			to_chat(user, "<span class='notice'>You need to wipe off the old lipstick first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does [user.p_their()] lips with [src].</span>", \
								"<span class='notice'>You take a moment to apply [src]. Perfect!</span>")
			H.lip_style = "lipstick"
			H.lip_color = lipstick_colors[colour]
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								"<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20, target = H))
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									"<span class='notice'>You apply \the [src].</span>")
				H.lip_style = "lipstick"
				H.lip_color = lipstick_colors[colour]
				H.update_body()
	else
		to_chat(user, "<span class='notice'>Where are the lips on that?</span>")

/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon_state = "razor"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	usesound = 'sound/items/welder2.ogg'

/obj/item/razor/attack__legacy__attackchain(mob/living/carbon/M as mob, mob/user as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/C = H.get_organ("head")
		if(!istype(C))
			to_chat(user, "<span class='warning'>There's nothing to cut, [M] [M.p_are()] missing [M.p_their()] head!</span>")
			return ..()
		var/datum/robolimb/robohead = GLOB.all_robolimbs[C.model]
		if(user.zone_selected == "mouth")
			if(!get_location_accessible(H, "mouth"))
				to_chat(user, "<span class='warning'>The mask is in the way.</span>")
				return
			if((C.dna.species.bodyflags & ALL_RPARTS) && robohead.is_monitor) //If the target is of a species that can have prosthetic heads, but the head doesn't support human hair 'wigs'...
				to_chat(user, "<span class='warning'>You find yourself disappointed at the appalling lack of facial hair.</span>")
				return
			if(C.f_style == "Shaved")
				to_chat(user, "<span class='notice'>Already clean-shaven.</span>")
				return
			if(H == user) //shaving yourself
				user.visible_message("<span class='notice'>[user] starts to shave [user.p_their()] facial hair with [src].</span>", \
				"<span class='notice'>You take a moment shave your facial hair with \the [src].</span>")
				if(do_after(user, 50 * toolspeed, target = H))
					user.visible_message("<span class='notice'>[user] shaves [user.p_their()] facial hair clean with [src].</span>", \
					"<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
					C.f_style = "Shaved"
					H.update_fhair()
					playsound(src.loc, usesound, 20, 1)
			else
				var/turf/user_loc = user.loc
				var/turf/H_loc = H.loc
				user.visible_message("<span class='danger'>[user] tries to shave [H]'s facial hair with \the [src].</span>", \
				"<span class='warning'>You start shaving [H]'s facial hair.</span>")
				if(do_after(user, 50 * toolspeed, target = H))
					if(user_loc == user.loc && H_loc == H.loc)
						user.visible_message("<span class='danger'>[user] shaves off [H]'s facial hair with \the [src].</span>", \
						"<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						C.f_style = "Shaved"
						H.update_fhair()
						playsound(src.loc, usesound, 20, 1)
		if(user.zone_selected == "head")
			if(!get_location_accessible(H, "head"))
				to_chat(user, "<span class='warning'>The headgear is in the way.</span>")
				return
			if((C.dna.species.bodyflags & ALL_RPARTS) && robohead.is_monitor) //If the target is of a species that can have prosthetic heads, but the head doesn't support human hair 'wigs'...
				to_chat(user, "<span class='warning'>You find yourself disappointed at the appalling lack of hair.</span>")
				return
			if(C.h_style == "Bald" || C.h_style == "Balding Hair" || C.h_style == "Skinhead")
				to_chat(user, "<span class='notice'>There is not enough hair left to shave...</span>")
				return
			if(isskrell(M))
				to_chat(user, "<span class='warning'>Your razor isn't going to cut through tentacles.</span>")
				return
			if(H == user) //shaving yourself
				user.visible_message("<span class='warning'>[user] starts to shave [user.p_their()] head with [src].</span>", \
				"<span class='warning'>You start to shave your head with \the [src].</span>")
				if(do_after(user, 50 * toolspeed, target = H))
					user.visible_message("<span class='notice'>[user] shaves [user.p_their()] head with [src].</span>", \
					"<span class='notice'>You finish shaving with \the [src].</span>")
					C.h_style = "Skinhead"
					H.update_hair()
					playsound(src.loc, usesound, 40, 1)
			else
				var/turf/user_loc = user.loc
				var/turf/H_loc = H.loc
				user.visible_message("<span class='danger'>[user] tries to shave [H]'s head with \the [src]!</span>", \
				"<span class='warning'>You start shaving [H]'s head.</span>")
				if(do_after(user, 50 * toolspeed, target = H))
					if(user_loc == user.loc && H_loc == H.loc)
						user.visible_message("<span class='danger'>[user] shaves [H]'s head bald with \the [src]!</span>", \
						"<span class='warning'>You shave [H]'s head bald.</span>")
						C.h_style = "Skinhead"
						H.update_hair()
						playsound(src.loc, usesound, 40, 1)
		else
			..()
	else
		..()
