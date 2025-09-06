/obj/structure/closet/secure_closet/depot
	name = "depot supply closet"
	desc = "A red and black lootbox full of things the Head of Security is going to flip their shit over."
	locked = FALSE
	anchored = TRUE
	req_access = list(ACCESS_SYNDICATE)
	icon_state = "tac"
	layer = 2.9 // ensures the loot they drop always appears on top of them.
	var/is_armory = FALSE
	var/ignore_use = FALSE

/obj/structure/closet/secure_closet/depot/emag_act()
	. = ..()
	loot_pickup()

/obj/structure/closet/secure_closet/depot/open()
	. = ..()
	if(opened)
		loot_pickup()

/obj/structure/closet/secure_closet/depot/dump_contents()
	loot_pickup()
	. = ..()

/obj/structure/closet/secure_closet/depot/proc/loot_pickup()
	if(!ignore_use)
		var/area/syndicate_depot/core/depotarea = get_area(src)
		if(istype(depotarea))
			depotarea.locker_looted()
			if(is_armory)
				depotarea.armory_locker_looted()

/obj/structure/closet/secure_closet/depot/attack_animal(mob/M)
	if(isanimal_or_basicmob(M) && ("syndicate" in M.faction))
		to_chat(M, "<span class='warning'>[src] resists your attack!</span>")
		return
	return ..()

/obj/structure/closet/secure_closet/depot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/rcs))
		to_chat(user, "<span class='warning'>Bluespace interference prevents [W] from locking onto [src]!</span>")
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/structure/closet/secure_closet/depot/emp_act(severity)
	return

/obj/structure/closet/secure_closet/depot/togglelock(mob/user)
	. = ..()
	if(!locked)
		loot_pickup()

/obj/structure/closet/secure_closet/depot/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		ignore_use = TRUE
		toggle(user)
		ignore_use = FALSE

/obj/structure/closet/secure_closet/depot/armory
	req_access = list(ACCESS_SYNDICATE_COMMAND) // can't open without killing QM/breaking a closet
	is_armory = TRUE
	icon_state = "armory"
