/obj/item/retractor
	name = "retractor"
	desc = "Retracta cosas."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=1;biotech=1"

/obj/item/retractor/augment
	desc = "Micro manipulador mecanico para el retractor"
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/hemostat
	name = "hemostato"
	desc = "Crees que has visto esto antes."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("atacando", "pinchando")

/obj/item/hemostat/augment
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	toolspeed = 0.5

/obj/item/cautery
	name = "cauterizador"
	desc = "Esto detiene el sangrado."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("quemando")

/obj/item/cautery/augment
	desc = "Un instrumento de temperatura elevada que cauteriza."
	toolspeed = 0.5

/obj/item/surgicaldrill
	name = "taladro quirurgico"
	desc = "Puedes perforar usando esta herramienta."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/drill.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15.0
	sharp = 1
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("taladrado")

/obj/item/surgicaldrill/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='suicide'>[user] esta apretando [src] en el templo de [user.p_their()] y activandolo! parece que [user.p_theyre()] esta tratando de cometer un suicidio.</span>",
						"<span class='suicide'>[user] esta apretando [src] en el pecho de [user.p_their()] y activandolo! parece que [user.p_theyre()] esta tratando de cometer un suicidio.</span>"))
	return BRUTELOSS

/obj/item/surgicaldrill/augment
	desc = "Pequeno y efectivo taladro electrico contenido dentro de su mango, para prevenir los danos en la piel"
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/scalpel
	name = "escalpelo"
	desc = "Corta, corta y una vez mas, corta."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	item_state = "scalpel"
	flags = CONDUCT
	force = 10.0
	sharp = 1
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("atacando", "golpeando", "degollando", "rebanando", "tornillando", "rasgando", "rasgando", "cortando")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='suicide'>[user] esta cortando las munecas de [user.p_their()] con [src]! parece que [user.p_theyre()] esta tratando de cometer un suicidio.</span>",
						"<span class='suicide'>[user] esta cortando la garganta de [user.p_their()] con [src]! parece que [user.p_theyre()] esta tratando de cometer un suicidio.</span>",
						"<span class='suicide'>[user] esta cortando el estomago abierto de [user.p_their()] con [src]! parece que [user.p_theyre()] esta tratando de cometer un seppuku.</span>"))
	return BRUTELOSS


/obj/item/scalpel/augment
	desc = "Super filosa hoja ayacida al hueso para extra-precision."
	toolspeed = 0.5

/*
 * Researchable Scalpels
 */
/obj/item/scalpel/laser //parent type
	name = "escalpelo laser"
	desc = "Un escalpelo aumentado con un laser dirigido."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/obj/item/scalpel/laser/laser1 //lasers also count as catuarys
	name = "escalpelo laser"
	desc = "Un escalpelo aumentado con un laser dirigido. Este parece basico y podria mejorarse."
	icon_state = "scalpel_laser1_on"
	toolspeed = 0.8

/obj/item/scalpel/laser/laser2
	name = "escalpelo laser"
	desc = "Un escalpelo aumentado con un laser dirigido. Este parece un poco avanzado"
	icon_state = "scalpel_laser2_on"
	toolspeed = 0.6

/obj/item/scalpel/laser/laser3
	name = "escalpelo laser"
	desc = "Un escalpelo aumentado con un laser dirigido. Este parece ser el pinaculo de los escalpelo laser"
	icon_state = "scalpel_laser3_on"
	toolspeed = 0.4

/obj/item/scalpel/laser/manager //super tool! Retractor/hemostat
	name = "sistema de manejo de incisiones"
	desc = "Una verdadera extension del cuerpo del cirujano, esta maravilla prepara instantanea y completamente una incision que permite el comienzo inmediato de los pasos terapeuticos."
	icon_state = "scalpel_manager_on"
	toolspeed = 0.2

/obj/item/circular_saw
	name = "Sierra circular"
	desc = "Para cortes pesados."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15.0
	sharp = 1
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")

/obj/item/circular_saw/augment
	desc = "Un pequeno pero rapida motosierra. Con bordes opacos que previenen accidentes en la ciruga."
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

//misc, formerly from code/defines/weapons.dm
/obj/item/bonegel
	name = "gel de hueso"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/bonegel/augment
	toolspeed = 0.5

/obj/item/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/FixOVein/augment
	toolspeed = 0.5

/obj/item/bonesetter
	name = "ensalmador"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("atacando", "golpeando", "pegando")
	origin_tech = "materials=1;biotech=1"

/obj/item/bonesetter/augment
	toolspeed = 0.5

/obj/item/surgical_drapes
	name = "panos de cirugia"
	desc = "Panos de cirugia de Nanotrasen que proporcionan optima seguridad ante infecciones."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=1"
	attack_verb = list("abofeteando")
