/obj/structure/closet/cabinet
	name = "cabinet"
	desc = "Old will forever be in fashion."
	icon_state = "cabinet"
	open_door_sprite = "cabinet_door"
	resistance_flags = FLAMMABLE
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
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
	open_door_sprite = "alien_door"

/obj/structure/closet/gimmick
	name = "administrative supply closet"
	desc = "It's a storage unit for things that have no right being here."
	icon_state = "syndicate1"
	open_door_sprite = "syndicate1_door"
	anchored = FALSE

/obj/structure/closet/gimmick/russian
	name = "russian surplus closet"
	desc = "It's a storage unit for Russian standard-issue surplus."
	icon_state = "syndicate1"
	open_door_sprite = "syndicate1_door"

/obj/structure/closet/gimmick/russian/populate_contents()
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
	icon_state = "syndicate1"
	open_door_sprite = "syndicate1_door"

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
	open_door_sprite = "syndicate_door"
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
	open_door_sprite = "syndicate1_door"

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

