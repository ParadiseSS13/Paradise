/obj/structure/closet/cabinet
	name = "cabinet"
	desc = "Old will forever be in fashion."
	icon_state = "cabinet"
	door_anim_time = 0
	resistance_flags = FLAMMABLE
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	max_integrity = 70

/obj/structure/closet/cabinet/wizard
	name = "magical cabinet"

/obj/structure/closet/cabinet/wizard/populate_contents()
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/suit/wizrobe(src)
	new /obj/item/clothing/head/wizard(src)
	new /obj/item/clothing/suit/wizrobe/red(src)
	new /obj/item/storage/backpack/satchel(src)
	new /obj/item/storage/backpack/satchel(src)
	new /obj/item/clothing/head/wizard/red(src)
	new /obj/item/clothing/under/color/purple(src)
	new /obj/item/clothing/under/color/lightpurple(src)

/obj/structure/closet/acloset
	name = "strange closet"
	desc = "It looks alien!"
	icon_state = "alien"

/obj/structure/closet/gimmick
	name = "administrative supply closet"
	desc = "It's a storage unit for things that have no right being here."
	icon_state = "syndicate1"

/obj/structure/closet/gimmick/soviet
	name = "soviet surplus closet"
	desc = "A storage unit for surplus USSP equipment."

/obj/structure/closet/gimmick/soviet/populate_contents()
	new /obj/item/clothing/head/sovietsidecap(src)
	new /obj/item/clothing/head/sovietsidecap(src)
	new /obj/item/clothing/head/sovietsidecap(src)
	new /obj/item/clothing/head/sovietsidecap(src)
	new /obj/item/clothing/head/sovietsidecap(src)
	new /obj/item/clothing/under/new_soviet(src)
	new /obj/item/clothing/under/new_soviet(src)
	new /obj/item/clothing/under/new_soviet(src)
	new /obj/item/clothing/under/new_soviet(src)
	new /obj/item/clothing/under/new_soviet(src)


/obj/structure/closet/gimmick/tacticool
	name = "tacticool gear closet"
	desc = "It's a storage unit for Tacticool gear."

/obj/structure/closet/gimmick/tacticool/populate_contents()
	new /obj/item/clothing/glasses/eyepatch(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/head/helmet/swat(src)
	new /obj/item/clothing/head/helmet/swat(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/shoes/combat/swat(src)
	new /obj/item/clothing/shoes/combat/swat(src)
	new /obj/item/clothing/suit/space/deathsquad(src)
	new /obj/item/clothing/suit/space/deathsquad(src)
	new /obj/item/clothing/under/syndicate/tacticool(src)
	new /obj/item/clothing/under/syndicate/tacticool(src)


/obj/structure/closet/thunderdome
	name = "\improper Thunderdome closet"
	desc = "Everything you need!"
	icon_state = "syndicate"
	opened_door_sprite = "syndicate"
	closed_door_sprite = "syndicate"
	anchored = TRUE

/obj/structure/closet/thunderdome/tdred
	name = "red-team Thunderdome closet"

/obj/structure/closet/thunderdome/tdred/populate_contents()
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)

/obj/structure/closet/thunderdome/tdgreen
	name = "green-team Thunderdome closet"
	icon_state = "syndicate1"
	opened_door_sprite = "syndicate1"
	closed_door_sprite = "syndicate1"

/obj/structure/closet/thunderdome/tdgreen/populate_contents()
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/melee/energy/sword/saber(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)

/obj/structure/closet/crate/cargo_pod
	name = "supply pod"
	desc = "A supply drop pod."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "pod"
	icon_opened = "pod_open"
	icon_closed = "pod"
	pixel_x = -16 // 2x2 sprite
	material_drop = /obj/item/stack/sheet/plasteel
	material_drop_amount = 5
	max_integrity = 250
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 100, RAD = 100, FIRE = 100, ACID = 30)
	anchored = TRUE
	climbable = FALSE
	light_range = 3
	light_color = LIGHT_COLOR_ORANGE

/obj/structure/closet/crate/cargo_pod/Initialize(mapload)
	. = ..()
	var/type = pick("norm", "adv", "dark")
	switch(type)
		if("norm")
			return
		if("adv")
			icon_state = "advpod"
			icon_opened = "advpod_open"
			icon_closed = "advpod"
			material_drop = /obj/item/stack/sheet/mineral/titanium
		if("dark")
			icon_state = "darkpod"
			icon_opened = "darkpod_open"
			icon_closed = "darkpod"
			material_drop = /obj/item/stack/sheet/mineral/plastitanium

/obj/structure/closet/crate/cargo_pod/open(by_hand = FALSE)
	if(opened)
		return FALSE
	if(!can_open())
		return FALSE

	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	for(var/obj/O in src) // Objects
		O.forceMove(loc)
	for(var/mob/M in src) // Mobs
		M.forceMove(loc)
	opened = TRUE
	icon_state = icon_opened
	return TRUE

/obj/structure/closet/crate/cargo_pod/update_overlays()
	. = ..()
	overlays.Cut()
	. += "pod_rubble"

/obj/structure/closet/crate/cargo_pod/close()
	if(!opened)
		return FALSE
	if(!can_close())
		return FALSE

	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	var/itemcount = 0
	for(var/atom/movable/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.anchored)
			continue
		O.forceMove(src)
		itemcount++

	opened = FALSE
	icon_state = icon_closed
	return TRUE
