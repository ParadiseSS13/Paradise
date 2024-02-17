//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "wall locker"
	icon = 'icons/obj/walllocker.dmi'
	icon_state = "wall-locker"
	density = FALSE
	anchored = TRUE
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"
	picks_up_mobs = FALSE

/obj/structure/closet/walllocker/close()
	. = ..()
	density = FALSE //It's a locker in a wall, you aren't going to be walking into it.

/obj/structure/closet/walllocker/MouseDrop_T(atom/movable/O, mob/living/user)
	// don't call parent here -- we don't want to try to climb
	if(!isliving(O) || !Adjacent(user) || !O.Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !opened)
		return

	user.visible_message(
		"<span class='warning'>[user] starts trying to stuff [user == O ? user.p_themselves() : O] into [src]!</span>",
		"<span class='danger'>You start trying to stuff [user == O ? "yourself" : O] into [src]!</span>",
		"<span class='notice'>You hear something rustling.</span>"
	)
	if(!do_after_once(user, 3 SECONDS, target = O) || !opened)
		return

	if(user == O)
		user.visible_message("<span class='notice'>[src] slams shut!</span>", "<span class='warning'>You manage to squeeze yourself into [src].</span>")
	else
		user.visible_message("span class='warning'>[user] stuffs [O] into [src]!</span>")

	O.forceMove(src)
	close()

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "A wall mounted locker with emergency supplies"
	icon_state = "emerg"
	icon_closed = "emerg"
	icon_opened = "emerg_open"

/obj/structure/closet/walllocker/emerglocker/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/crowbar(src)
	new /obj/item/crowbar(src)
	new /obj/item/crowbar(src)

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST
