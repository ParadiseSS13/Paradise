// Sprites from CM13
/obj/item/storage/surgical_tray
	name = "surgical tray"
	desc = "A small metallic tray covered in sterile tarp. Intended to store surgical tools in a neat and clean fashion."
	icon_state = "surgical_tray"
	storage_slots = 22 // 11 Items, x2 to be sure
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 38 // Items listed add up to 19, x2 to be sure
	can_hold = list(
		/obj/item/scalpel,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/fix_o_vein,
		/obj/item/surgicaldrill,
		/obj/item/circular_saw,
		/obj/item/bonegel,
		/obj/item/bonesetter,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/surgical_drapes,
		/obj/item/dissector,
	)

/obj/item/storage/surgical_tray/Initialize(mapload)
	. = ..()
	new /obj/item/scalpel(src)
	new /obj/item/cautery(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/fix_o_vein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/surgical_drapes(src)

/obj/item/storage/surgical_tray/update_icon_state()
	if(!length(contents))
		icon_state = "surgical_tray_e"
	else
		icon_state = "surgical_tray"
