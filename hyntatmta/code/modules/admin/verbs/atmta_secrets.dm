/client/proc/spawnasadmin()
	message_admins("[key_name_admin(usr)] spawned himself as a Test Dummy.")
	log_admin("[key_name_admin(usr)] spawned himself as a Test Dummy.")
	var/turf/T = get_turf(usr)
	var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(T)
	usr.client.cmd_assume_direct_control(D)
	D.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/oldman(D), slot_w_uniform)
	D.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(D), slot_shoes)
	D.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(D), slot_back)
	playsound(D.loc, 'sound/misc/adminspawn.ogg', 50, 0)
	var/atom/movable/overlay/animation = null
	animation = new(D.loc)
	animation.icon_state = "blank" // Зачем? Не знаю.
	animation.icon = 'hyntatmta/icons/effects/32x96.dmi'
	animation.master = src
	flick("beamin", animation)
	spawn(15)
		if(animation)	qdel(animation) //Это чтобы оверлей не оставался висеть.
	D.name = "Admin"
	D.real_name = "Admin"
	var/newname = ""
	newname = copytext(sanitize(input(D, "Before you step out as an embodied god, what name do you wish for?", "Choose your name.", "Admin") as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = "Admin"
		D.name = newname
		D.real_name = newname
		var/obj/item/weapon/card/id/admin/admin_id = new(D)
		admin_id.registered_name = newname
		D.equip_to_slot_or_del(admin_id, slot_wear_id)