////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/a357"
	caliber = "357"
	max_ammo = 7


/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(var/countempties = 1)
	if (!countempties)
		var/boolets = 0
		for (var/i = 1, i <= stored_ammo.len, i++)
			var/obj/item/ammo_casing/bullet = stored_ammo[i]
			if (bullet.BB)
				boolets++
		return boolets
	else
		return stored_ammo.len

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "russian revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/a357"
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rus357/New()
	stored_ammo += new ammo_type(src)

/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "d-tiv revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/c38"
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/cap
	name = "cap gun revolver cylinder"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/cap"
	caliber = "cap"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/shotcom
	name = "combat shotgun internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/shotgun/buckshot"
	caliber = "shotgun"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/dualshot
	name = "double-barrel shotgun internal magazine"
	desc = "This doesn't even exist"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	caliber = "shotgun"
	max_ammo = 2
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/improvised
	name = "improvised shotgun internal magazine"
	desc = "This doesn't even exist"
	ammo_type = "/obj/item/ammo_casing/shotgun/improvised"
	caliber = "shotgun"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/shotriot
	name = "riot shotgun internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/shotgun/rubbershot"
	caliber = "shotgun"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher
	name = "grenade launcher internal magazine"
	ammo_type = "/obj/item/ammo_casing/a40mm"
	caliber = "40mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi
	ammo_type = "/obj/item/ammo_casing/a40mm"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/boltaction
	name = "bolt action rifle internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = "/obj/item/ammo_casing/a762"
	caliber = "a762"
	max_ammo = 5
	multiload = 1

/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = "/obj/item/ammo_casing/caseless/foam_dart"
	caliber = "foam_force"
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
 	max_ammo = 5

/obj/item/ammo_box/magazine/internal/shot/toy/tommygun
 	max_ammo = 10

///////////EXTERNAL MAGAZINES////////////////

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/c10mm"
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	icon_state = "45"
	ammo_type = "/obj/item/ammo_casing/c45"
	caliber = ".45"
	max_ammo = 8

/obj/item/ammo_box/magazine/m45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	icon_state = "46x30mmt-20"
	ammo_type = "/obj/item/ammo_casing/c46x30mm"
	caliber = "4.6x30mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/wt550m9/update_icon()
	..()
	icon_state = "46x30mmt-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	ammo_type = "/obj/item/ammo_casing/c46x30mmap"

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "wt550 magazine (Toxin Tipped 4.6x30mm)"
	ammo_type = "/obj/item/ammo_casing/c46x30mmtox"

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incindiary 4.6x30mm)"
	ammo_type = "/obj/item/ammo_casing/c46x30mminc"

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm-32"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon()
	..()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	caliber = "9mm"
	max_ammo = 30
	materials = list(MAT_METAL = 2000)

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	ammo_type = "/obj/item/ammo_casing/c9mmap"
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "SMG magazine (Toxin Tipped 9mm)"
	ammo_type = "/obj/item/ammo_casing/c9mmtox"
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	ammo_type = "/obj/item/ammo_casing/c9mminc"
	materials = list(MAT_METAL = 3000)

/obj/item/ammo_box/magazine/smgm9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),6)]"

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	icon_state = "c20r45"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_box/magazine/smgm45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = "/obj/item/ammo_casing/c45"
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/a50"
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	icon_state = "75"
	ammo_type = "/obj/item/ammo_casing/caseless/a75"
	caliber = "75"
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	icon_state = "5.56m"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = "/obj/item/ammo_casing/a556"
	caliber = "a556"
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m762
	name = "box magazine (7.62mm)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	caliber = "a762"
	max_ammo = 50

/obj/item/ammo_box/magazine/m762/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/m762/buckshot
	name = "box magazine (buckshot)"
	icon_state = "b762"
	caliber = "shotgun"
	ammo_type ="/obj/item/ammo_casing/shotgun/buckshot"
	max_ammo = 300 // Bluespace!

/obj/item/ammo_box/magazine/m762/buckshot/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),60)]"

/obj/item/ammo_box/magazine/m762/he // I am not a good person.
	name = "box magazine (40mm high explosive)"
	icon_state = "g762"
	caliber = "40mm"
	ammo_type ="/obj/item/ammo_casing/a40mm"
	max_ammo = 25

/obj/item/ammo_box/magazine/m762/he/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),5)]"


/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g slugs)"
	icon_state = "m12gb"
	ammo_type = "/obj/item/ammo_casing/shotgun"
	origin_tech = "combat=3;syndicate=1"
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[Ceiling(ammo_count(0)/8)*8]"

/obj/item/ammo_box/magazine/m12g/buckshot
	name = "shotgun magazine (12g buckshot slugs)"
	icon_state = "m12gb"
	ammo_type = "/obj/item/ammo_casing/shotgun/buckshot"

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	icon_state = "m12gs"
	ammo_type = "/obj/item/ammo_casing/shotgun/stunslug"


/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	icon_state = "m12gf"
	ammo_type = "/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath"

//FOAM DARTS
/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	ammo_type = "/obj/item/ammo_casing/caseless/foam_dart"
	caliber = "foam_force"

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm-30"
	max_ammo = 30

/obj/item/ammo_box/magazine/toy/smg/update_icon()
	..()
	icon_state = "smg9mm-[round(ammo_count(),6)]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = "/obj/item/ammo_casing/caseless/foam_dart/riot"

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = "/obj/item/ammo_casing/caseless/foam_dart/riot"

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	ammo_type = "/obj/item/ammo_casing/caseless/foam_dart/riot"
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon()
	..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	ammo_type = "/obj/item/ammo_casing/caseless/foam_dart/riot"
	max_ammo = 50

/obj/item/ammo_box/magazine/toy/m762/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"
