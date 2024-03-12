/obj/item/storage/wallet
	var/photo_overlay = "photo"

/obj/item/storage/wallet/wallet_NT
	name = "leather wallet NT"
	desc = "Ваш кошелек настолько шикарен, что с ним вы выглядите просто потрясающе."
	icon = 'modular_ss220/objects/icons/wallets.dmi'
	icon_state = "wallet_NT"
	photo_overlay = "photo_NT"

/obj/item/storage/wallet/wallet_USSP_1
	name = "leather wallet USSP"
	desc = "Говорят, такие кошельки в СССП носят исключительно для зажигалок."
	icon = 'modular_ss220/objects/icons/wallets.dmi'
	icon_state = "wallet_USSP_1"
	photo_overlay = "photo_USSP"
	storage_slots = 5

/datum/prize_item/wallet_USSP_1
	name = "Настоящий кошелёк СССП!"
	desc = "Красота"
	typepath = /obj/item/storage/wallet/wallet_USSP_1
	cost = 35

/obj/item/storage/wallet/wallet_USSP_2
	name = "leather wallet USSP"
	desc = "Говорят, такие кошельки в СССП носят исключительно для зажигалок."
	icon = 'modular_ss220/objects/icons/wallets.dmi'
	icon_state = "wallet_USSP_2"
	photo_overlay = "photo_USSP"

/obj/item/storage/wallet/wallet_wyci
	name = "Кошелек W.Y.C.I."
	desc = "Кошелек, законодателя моды WYCI,\
	украшен золотой пуговицей cшит позолочеными и платиновыми нитями, сверх прочный.\
	И сверх модный. И сверх дорогой. И сшит по принципу WYCI."
	icon = 'modular_ss220/objects/icons/wallets.dmi'
	icon_state = "wallet_wyci"
	photo_overlay = "photo_wyci_overlay"
