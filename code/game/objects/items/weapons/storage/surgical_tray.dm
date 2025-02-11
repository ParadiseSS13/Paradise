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
		/obj/item/tool/scalpel,
		/obj/item/tool/cautery,
		/obj/item/tool/hemostat,
		/obj/item/tool/retractor,
		/obj/item/tool/fix_o_vein,
		/obj/item/tool/surgicaldrill,
		/obj/item/tool/circular_saw,
		/obj/item/tool/bonegel,
		/obj/item/tool/bonesetter,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/surgical_drapes
	)

/obj/item/storage/surgical_tray/Initialize(mapload)
	. = ..()
	new /obj/item/tool/scalpel(src)
	new /obj/item/tool/cautery(src)
	new /obj/item/tool/hemostat(src)
	new /obj/item/tool/retractor(src)
	new /obj/item/tool/fix_o_vein(src)
	new /obj/item/tool/surgicaldrill(src)
	new /obj/item/tool/circular_saw(src)
	new /obj/item/tool/bonegel(src)
	new /obj/item/tool/bonesetter(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)

/obj/item/storage/surgical_tray/update_icon_state()
	if(!length(contents))
		icon_state = "surgical_tray_e"
	else
		icon_state = "surgical_tray"
