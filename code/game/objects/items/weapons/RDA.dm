/obj/item/weapon/RDA
	name = "broken RDA"
	desc = "Rebuildable Dripping Atomizer, part of vape device."
	icon = 'icons/obj/vape.dmi'
	icon_state = "RDA-normal"
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=20)
	var/clouds = 0
	var/rdain = ""

/obj/item/weapon/RDA/normal
	name = "RDA"
	clouds = 2
	rdain = "-normalrda"

/obj/item/weapon/RDA/wide
	name = "Wide RDA"
	desc = "Rebuildable Dripping Atomizer, part of vape device. Wide type."
	icon_state = "RDA-wide"
	clouds = 3
	rdain = "-widerda"

/obj/item/weapon/RDA/tight
	name = "miniRDA"
	desc = "Rebuildable Dripping Atomizer, part of vape device. Mini type."
	icon_state = "RDA-tight"
	clouds = 1
	rdain = "-tightrda"