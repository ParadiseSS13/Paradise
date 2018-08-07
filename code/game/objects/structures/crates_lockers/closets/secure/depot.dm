
/obj/structure/closet/secure_closet/syndicate/depot
	name = "depot supply closet"
	desc = ""
	locked = 0
	anchored = 1
	health = 200
	req_access = list()


/obj/structure/closet/secure_closet/syndicate/depot/New()
	. = ..()
	update_icon()

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
	var/area/syndicate_depot/core/depotarea = areaMaster
	if(depotarea)
		depotarea.locker_looted()

/obj/structure/closet/secure_closet/syndicate/depot/attack_animal(mob/M)
	if(isanimal(M) && "syndicate" in M.faction)
		to_chat(M, "<span class='warning'>The [src] resists your attack!</span>")
		return
	return ..(M)

/obj/structure/closet/secure_closet/syndicate/depot/emp_act(severity)
	return

/obj/structure/closet/secure_closet/syndicate/depot/togglelock(mob/user)
	. = ..()
	if(!locked)
		loot_pickup()