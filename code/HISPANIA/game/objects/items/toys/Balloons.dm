//Globo
/obj/item/toy/balloon_H
	name = "Balloon"
	desc = "There is a tag on the back that reads NT."
	throwforce = 0
	throw_speed = 1
	throw_range = 15
	force = 0
	icon = 'icons/hispania/obj/balloons.dmi'
	icon_state = "balloon_w"
	item_state = "balloon_w"
	lefthand_file = 'icons/hispania/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/balloons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	var/lastused = null
	resistance_flags = FLAMMABLE

//Aviso al atacar
/obj/item/toy/balloon_H/attack_self(mob/user)
	if(world.time - lastused < CLICK_CD_MELEE)
		return
	var/playverb = pick("bat [src]", "tug on [src]'s string", "play with [src]")
	user.visible_message("<span class='notice'>[user] plays with [src].</span>", "<span class='notice'>You [playverb].</span>")
	lastused = world.time

//Tipos de globos
/obj/item/toy/balloon_H/red
	name = "Balloon"
	desc = "It's a red balloon."
	icon_state = "balloon_red"
	item_state = "balloon_red"

/obj/item/toy/balloon_H/yellow
	name = "Yellow balloon"
	desc = "It's a yellow balloon."
	icon_state = "balloon_yellow"
	item_state = "balloon_yellow"

/obj/item/toy/balloon_H/blue
	name = "Blue Balloon"
	desc = "It's a blue Da ba dee da ba daa."
	icon_state = "balloon_blue"
	item_state = "balloon_blue"

/obj/item/toy/balloon_H/green
	name = "Green balloon"
	desc = "It's a green balloon."
	icon_state = "balloon_green"
	item_state = "balloon_green"

/obj/item/toy/balloon_H/corgi
	name = "Corgi balloon"
	desc = "Man's Best Friend."
	icon_state = "Bcorgi"
	item_state = "Bcorgi"
/obj/item/toy/balloon_H/m
	name = "Mcdonalds balloon."
	desc = "Fat,Very fat"
	icon_state = "Mballoon"
	item_state = "Mballoon"
	throw_range = 10

/obj/item/toy/balloon_H/clown
	name = "Clown balloon."
	desc = "Made by clowns to clowns."
	icon_state = "balloon_clown"
	item_state = "balloon_clown"

/obj/item/toy/balloon_H/mime
	name = "Mime balloon."
	desc = "..."
	icon_state = "ballon_mime"
	item_state = "ballon_mime"