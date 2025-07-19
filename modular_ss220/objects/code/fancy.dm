// Советские сиги
/obj/item/storage/fancy/cigarettes/cigpack_soviet
	name = "\improper Despojnsko Belovodje packet"
	desc = "Любимые многими моряками сигареты прямиком с Деспойны. Не имеют каких-либо фильтров и отдают вкусом морской соли."
	icon = 'modular_ss220/objects/icons/fancy.dmi'
	icon_state = "sovietpacket"
	item_state = "sovietpacket"
	lefthand_file = 'modular_ss220/objects/icons/inhands/fancy_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/fancy_righthand.dmi'
	cigarette_type = /obj/item/clothing/mask/cigarette/rollie/soviet

/obj/item/clothing/mask/cigarette/rollie/soviet
	list_reagents = list("nicotine" = 40, "ash" = 10, "sodiumchloride" = 10)

/obj/machinery/economy/vending/cigarette/Initialize(mapload)
	products += list(/obj/item/storage/fancy/cigarettes/cigpack_soviet = 6)
	prices += list(/obj/item/storage/fancy/cigarettes/cigpack_soviet = 35)
	return ..()

// Самодельная сигаретная пачка
/obj/item/storage/fancy/cigarettes/cigpack_diy
	name = "\improper cigarette packet"
	desc = "Простая самодельная пачка для сигарет и косяков."
	icon = 'modular_ss220/objects/icons/fancy.dmi'
	icon_state = "diypacket"
	item_state = "diypacket"
	lefthand_file = 'modular_ss220/objects/icons/inhands/fancy_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/fancy_righthand.dmi'
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1

/obj/item/storage/fancy/cigarettes/cigpack_diy/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
