/obj/item/latexballon
	name = "latex glove"
	desc = "You wanted a fiery fist o' pain, but all you got was this dumb balloon."
	icon_state = "latexballon"
	inhand_icon_state = "lgloves"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	cares_about_temperature = TRUE
	var/state
	var/datum/gas_mixture/air_contents = null

/obj/item/latexballon/Destroy()
	QDEL_NULL(air_contents)
	return ..()

/obj/item/latexballon/proc/blow(obj/item/tank/tank, mob/user)
	if(icon_state == "latexballon_bursted")
		return
	icon_state = "latexballon_blow"
	inhand_icon_state = "latexballon"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	user.update_inv_r_hand()
	user.update_inv_l_hand()
	to_chat(user, "<span class='notice'>You blow up [src] with [tank].</span>")
	air_contents = tank.remove_air_volume(3)

/obj/item/latexballon/proc/burst()
	if(!air_contents || icon_state != "latexballon_blow")
		return
	playsound(src, 'sound/weapons/gunshots/gunshot.ogg', 100, 1)
	icon_state = "latexballon_bursted"
	inhand_icon_state = null
	if(isliving(loc))
		var/mob/living/user = loc
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	var/turf/T = get_turf(src)
	T.blind_release_air(air_contents)

/obj/item/latexballon/ex_act(severity)
	burst()
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)

/obj/item/latexballon/bullet_act(obj/item/projectile/P)
	if(!P.nodamage)
		burst()
	return ..()

/obj/item/latexballon/temperature_expose(temperature, volume)
	..()
	if(temperature > T0C+100)
		burst()

/obj/item/latexballon/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank))
		var/obj/item/tank/T = W
		blow(T, user)
		return
	if(W.sharp || W.get_heat() || is_pointed(W))
		burst()
