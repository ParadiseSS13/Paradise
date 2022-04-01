
/obj/structure/closet/secure_closet/syndicate/depot
	name = "depot supply closet"
	desc = ""
	locked = 0
	anchored = 1
	req_access = list()
	max_integrity = 250
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"
	var/is_armory = FALSE
	var/ignore_use = FALSE

/obj/structure/closet/secure_closet/syndicate/depot/emag_act()
	. = ..()
	loot_pickup()

/obj/structure/closet/secure_closet/syndicate/depot/open()
	. = ..()
	if(opened)
		loot_pickup()

/obj/structure/closet/secure_closet/syndicate/depot/dump_contents()
	loot_pickup()
	. = ..()

/obj/structure/closet/secure_closet/syndicate/depot/proc/loot_pickup()
	if(!ignore_use)
		var/area/syndicate_depot/core/depotarea = get_area(src)
		if(istype(depotarea))
			depotarea.locker_looted()
			if(is_armory)
				depotarea.armory_locker_looted()

/obj/structure/closet/secure_closet/syndicate/depot/attack_animal(mob/M)
	if(isanimal(M) && ("syndicate" in M.faction))
		to_chat(M, "<span class='warning'>The [src] resists your attack!</span>")
		return
	return ..()

/obj/structure/closet/secure_closet/syndicate/depot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcs))
		to_chat(user, "<span class='warning'>Bluespace interference prevents the [W] from locking onto [src]!</span>")
		return
	return ..()

/obj/structure/closet/secure_closet/syndicate/depot/emp_act(severity)
	return

/obj/structure/closet/secure_closet/syndicate/depot/togglelock(mob/user)
	. = ..()
	if(!locked)
		loot_pickup()

/obj/structure/closet/secure_closet/syndicate/depot/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		ignore_use = TRUE
		toggle(user)
		ignore_use = FALSE

/obj/structure/closet/secure_closet/syndicate/depot/armory
	req_access = list(ACCESS_SYNDICATE)
	is_armory = TRUE
