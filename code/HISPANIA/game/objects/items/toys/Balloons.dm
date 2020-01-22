/obj/item/toy/balloon
	name = "Balloon"
	desc = "There is a tag on the back that reads NT."
	throwforce = 0
	throw_speed = 1
	throw_range = 100
	force = 0
	icon_state = "balloon"
	item_state = "balloon"
	w_class = WEIGHT_CLASS_BULKY
	var/lastused = null
	resistance_flags = FLAMMABLE

/obj/item/toy/syndicateballoon/attack_self(mob/user)
	if(world.time - lastused < CLICK_CD_MELEE)
		return
	var/playverb = pick("bat [src]", "tug on [src]'s string", "play with [src]")
	user.visible_message("<span class='notice'>[user] plays with [src].</span>", "<span class='notice'>You [playverb].</span>")
	lastused = world.time

/obj/item/toy/balloon/red
	name = "Balloon"
	desc = "It's a red balloon"
	icon_state = "balloon_red"
	item_state = "balloon_red"
/obj/item/toy/balloon/yellow
	name = "Yellow balloon"
	desc = "It's a yellow balloon"
	icon_state = "balloon_yellow"
	item_state = "balloon_yellow"
/obj/item/toy/balboon/blue
	name = "Blue Balloon"
	desc = "It's a blue Da ba dee da ba daa"
	icon_state = "balloon_blue"
	item_state = "balloon_blue"
/obj/item/toy/balloon/green
	name = "Green balloon"
	desc = "It's a green balloon"
	icon_state = "balloon_green"
	item_state = "balloon_green"
/obj/item/toy/balloon/corgi
	name = "Corgi balloon"
	desc = "Man's Best Friend"
	icon_state = "Bcorgi"
	item_state = "Bcorgi"
/obj/item/toy/balloon/m
	name = "Mcdonalds balloon"
	desc = "Fat,Very fat"
	icon_state = "Mballoon"
	item_state = "Mballoon"
	throw_range = 50