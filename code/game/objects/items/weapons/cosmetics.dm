/obj/item/weapon/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = 1
	var/colour = "red"
	var/open = 0

/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/weapon/lipstick/green
	name = "green lipstick"
	colour = "green"

/obj/item/weapon/lipstick/blue
	name = "blue lipstick"
	colour = "blue"

/obj/item/weapon/lipstick/white
	name = "white lipstick"
	colour = "white"

/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/New()
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"


/obj/item/weapon/lipstick/attack_self(mob/user)
	overlays.Cut()
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		var/image/colored = image("icon"='icons/obj/items.dmi', "icon_state"="lipstick_uncap_color")
		colored.color = colour
		icon_state = "lipstick_uncap"
		overlays += colored
	else
		icon_state = "lipstick"

/obj/item/weapon/lipstick/attack(mob/M, mob/user)
	if(!open)
		return

	if(!ismob(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, "<span class='notice'>You need to wipe off the old lipstick first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20, target = H))
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		to_chat(user, "<span class='notice'>Where are the lips on that?</span>")

/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = CONDUCT
	w_class = 1

/obj/item/weapon/razor/attack(mob/living/carbon/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/C = H.get_organ("head")
		var/datum/robolimb/robohead = all_robolimbs[C.model]
		if(user.zone_sel.selecting == "mouth")
			if(!get_location_accessible(H, "mouth"))
				to_chat(user, "<span class='warning'>The mask is in the way.</span>")
				return
			if((C.species && C.species.flags & ALL_RPARTS) && robohead.is_monitor) //If the target is of a species that can have prosthetic heads, but the head doesn't support human hair 'wigs'...
				to_chat(user, "<span class='warning'>You find yourself disappointed at the appalling lack of facial hair.</span>")
				return
			if(C.f_style == "Shaved")
				to_chat(user, "<span class='notice'>Already clean-shaven.</span>")
				return
			if(H == user) //shaving yourself
				user.visible_message("<span class='notice'>[user] starts to shave their facial hair with \the [src].</span>", \
				"<span class='notice'>You take a moment shave your facial hair with \the [src].</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("<span class='notice'>[user] shaves his facial hair clean with the [src].</span>", \
					"<span class='notice'>You finish shaving with the [src]. Fast and clean!</span>")
					C.f_style = "Shaved"
					H.update_fhair()
					playsound(loc, 'sound/items/Welder2.ogg', 20, 1)
			else
				var/turf/user_loc = user.loc
				var/turf/H_loc = H.loc
				user.visible_message("<span class='danger'>[user] tries to shave [H]'s facial hair with \the [src].</span>", \
				"<span class='warning'>You start shaving [H]'s facial hair.</span>")
				if(do_after(user, 50, target = H))
					if(user_loc == user.loc && H_loc == H.loc)
						user.visible_message("<span class='danger'>[user] shaves off [H]'s facial hair with \the [src].</span>", \
						"<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						C.f_style = "Shaved"
						H.update_fhair()
						playsound(loc, 'sound/items/Welder2.ogg', 20, 1)
		if(user.zone_sel.selecting == "head")
			if(!get_location_accessible(H, "head"))
				to_chat(user, "<span class='warning'>The headgear is in the way.</span>")
				return
			if((C.species && C.species.flags & ALL_RPARTS) && robohead.is_monitor) //If the target is of a species that can have prosthetic heads, but the head doesn't support human hair 'wigs'...
				to_chat(user, "<span class='warning'>You find yourself disappointed at the appalling lack of hair.</span>")
				return
			if(C.h_style == "Bald" || C.h_style == "Balding Hair" || C.h_style == "Skinhead")
				to_chat(user, "<span class='notice'>There is not enough hair left to shave...</span>")
				return
			if(H == user) //shaving yourself
				user.visible_message("<span class='warning'>[user] starts to shave their head with \the [src].</span>", \
				"<span class='warning'>You start to shave your head with \the [src].</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("<span class='notice'>[user] shaves his head with the [src].</span>", \
					"<span class='notice'>You finish shaving with the [src].</span>")
					C.h_style = "Skinhead"
					H.update_hair()
					playsound(loc, 'sound/items/Welder2.ogg', 40, 1)
			else
				var/turf/user_loc = user.loc
				var/turf/H_loc = H.loc
				user.visible_message("<span class='danger'>[user] tries to shave [H]'s head with \the [src]!</span>", \
				"<span class='warning'>You start shaving [H]'s head.</span>")
				if(do_after(user, 50, target = H))
					if(user_loc == user.loc && H_loc == H.loc)
						user.visible_message("<span class='danger'>[user] shaves [H]'s head bald with \the [src]!</span>", \
						"<span class='warning'>You shave [H]'s head bald.</span>")
						C.h_style = "Skinhead"
						H.update_hair()
						playsound(loc, 'sound/items/Welder2.ogg', 40, 1)
		else
			..()
	else
		..()

#define INVISIBLESPRAY "invisiblespray"

/obj/item/weapon/invisible_spray
	name = "invisible spray"
	desc = "A can of... invisibility? The label reads: \"Wears off after five minutes.\""
	icon = 'icons/obj/items.dmi'
	icon_state = "invisible_spray"
	w_class = 2
	var/permanent = FALSE
	var/invisible_time = 3000
	var/sprays_left = 1

/obj/item/weapon/invisible_spray/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FALSE
	if(isturf(target))
		return
	if(!sprays_left)
		to_chat(user, "\The [src] is empty.")
		return
	if(target.invisibility || target.alpha <= 1)
		to_chat(user, "\The [target] is already invisible!")
		return
	if(ismob(target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.body_alphas[INVISIBLESPRAY] = 1
			H.regenerate_icons()
			if(!permanent)
				spawn(invisible_time)
					if(H)
						H.body_alphas.Remove(INVISIBLESPRAY)
						H.regenerate_icons()
		else
			var/mob/M = target
			M.alpha = 1	//to cloak immediately instead of on the next Life() tick
			M.alphas[INVISIBLESPRAY] = 1
			if(!permanent)
				spawn(invisible_time)
					if(M)
						M.alpha = initial(M.alpha)
						M.alphas.Remove(INVISIBLESPRAY)
	else
		if(isobj(target))
			var/obj/O = target
			O.alpha = 1
			O.has_been_invisible_sprayed = TRUE
			if(O.loc == user)
				user.regenerate_icons()
			if(!permanent)
				spawn(invisible_time)
					if(O)
						O.alpha = initial(O.alpha)
						O.has_been_invisible_sprayed = FALSE
						if(ismob(O.loc))
							var/mob/M = O.loc
							M.regenerate_icons()
	if(target == user)
		to_chat(user, "You spray yourself with \the [src].")
	else
		to_chat(user, "You spray \the [target] with \the [src].")
	playsound(get_turf(src), 'sound/effects/spray2.ogg', 50, 1, -6)
	sprays_left--
	return TRUE

/obj/item/weapon/invisible_spray/permanent
	desc = "A can of... invisibility?"
	permanent = TRUE
