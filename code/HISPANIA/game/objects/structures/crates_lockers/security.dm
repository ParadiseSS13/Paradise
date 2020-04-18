// Adición de un Security Belt para el Detective uwu.

/obj/structure/closet/secure_closet/detective/New()
	..()
	new /obj/item/storage/belt/security(src)

/obj/structure/closet/secure_closet/brigdoc/New()
	..()
	new /obj/item/storage/box/autoinjectors(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/storage/pill_bottle( src )
	new /obj/item/storage/pill_bottle/patch_pack(src)