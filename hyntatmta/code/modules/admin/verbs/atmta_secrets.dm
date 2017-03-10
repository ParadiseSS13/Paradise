/client/proc/spawnasadmin()
	message_admins("[key_name_admin(usr)] spawned himself as a Test Dummy.")
	log_admin("[key_name_admin(usr)] spawned himself as a Test Dummy.")
	var/turf/T = get_turf(usr)
	var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(T)
	usr.client.cmd_assume_direct_control(D)
	if(ckey == "itblackwood")
		D.equip_to_slot_or_del(new /obj/item/clothing/under/atmta/hunter(D), slot_w_uniform)
		D.equip_to_slot_or_del(new /obj/item/clothing/shoes/atmta/hunter_boots(D), slot_shoes)
		D.equip_to_slot_or_del(new /obj/item/clothing/head/atmta/helmet/hunter(D), slot_head)
		D.equip_to_slot_or_del(new /obj/item/clothing/suit/atmta/hunter_coat(D), slot_wear_suit)
		D.equip_to_slot_or_del(new /obj/item/clothing/mask/atmta/hunter_mask(D), slot_wear_mask)
		playsound(D.loc, 'sound/misc/adminspawn2.ogg', 50, 0)
		D.name = "ITBlackwood"
		D.real_name = "ITBlackwood"
	else
		D.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/oldman(D), slot_w_uniform)
		D.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(D), slot_shoes)
		D.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(D), slot_back)
		playsound(D.loc, 'sound/misc/adminspawn2.ogg', 50, 0)
		D.name = "Admin"
		D.real_name = "Admin"
	var/atom/movable/overlay/animation = null
	animation = new(D.loc)
	animation.icon_state = "blank" // Зачем? Не знаю.
	animation.icon = 'hyntatmta/icons/effects/32x96.dmi'
	animation.master = src
	flick("beamin", animation)
	spawn(15)
		if(animation)	qdel(animation) //Это чтобы оверлей не оставался висеть.
	var/obj/item/weapon/card/id/admin/admin_id = new(D)
	admin_id.registered_name = D.name
	D.equip_to_slot_or_del(admin_id, slot_wear_id)