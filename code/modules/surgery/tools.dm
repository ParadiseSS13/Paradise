/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = 2
	origin_tech = "materials=1;biotech=1"


/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = 1
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")


/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = 1
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")


/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/drill.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15.0
	sharp = 1
	edge = 1
	w_class = 3
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")

	suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='suicide'>[user] is pressing [src] to \his temple and activating it! It looks like \he's trying to commit suicide.</span>",
							"<span class='suicide'>[user] is pressing [src] to \his chest and activating it! It looks like \he's trying to commit suicide.</span>"))
		return (BRUTELOSS)


/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags = CONDUCT
	force = 10.0
	sharp = 1
	edge = 1
	w_class = 1
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

	suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='suicide'>[user] is slitting \his wrists with [src]! It looks like \he's trying to commit suicide.</span>",
							"<span class='suicide'>[user] is slitting \his throat with [src]! It looks like \he's trying to commit suicide.</span>",
							"<span class='suicide'>[user] is slitting \his stomach open with [src]! It looks like \he's trying to commit seppuku.</span>"))
		return (BRUTELOSS)


/*
 * Researchable Scalpels
 */
/obj/item/weapon/scalpel/laser1 //lasers also count as catuarys
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser.  This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	item_state = "scalpel"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/weapon/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser. This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	item_state = "scalpel"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/weapon/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	item_state = "scalpel"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/weapon/scalpel/manager //super tool! Retractor/hemostat
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	item_state = "scalpel"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags = CONDUCT
	force = 15.0
	sharp = 1
	edge = 1
	w_class = 3
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")

//misc, formerly from code/defines/weapons.dm
/obj/item/weapon/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	w_class = 2
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	w_class = 2

/obj/item/weapon/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = 2
	attack_verb = list("attacked", "hit", "bludgeoned")
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = 1
	origin_tech = "biotech=1"
	attack_verb = list("slapped")
