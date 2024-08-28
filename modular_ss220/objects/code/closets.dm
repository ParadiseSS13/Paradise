/obj/structure/closet/secure_closet/expedition
	name = "expeditors locker"
	req_access = list(ACCESS_EXPEDITION)
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "explorer"
	icon_opened = "explorer_open"
	open_door_sprite = "explorer_door"

/obj/structure/closet/secure_closet/expedition/populate_contents()
	new /obj/item/gun/energy/laser/awaymission_aeg/rnd(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/paper/pamphlet/gateway(src)

/obj/structure/closet/crate/freezer/iv_storage/organ
	name = "organ freezer"
	desc = "Холодильник для хранения органов и пакетов с кровью."
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "organ_freezer"
	icon_opened = "organ_freezer_open"
	icon_closed = "organ_freezer"
	storage_capacity = 60
