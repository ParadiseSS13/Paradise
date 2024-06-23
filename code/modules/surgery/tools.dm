/obj/item/retractor
	name = "retractor"
	desc = "A sterilized tissue retractor used for holding open incisions."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_RETRACTOR

/obj/item/retractor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/retractor/augment
	desc = "Micro-mechanical manipulator for retracting stuff."
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/hemostat
	name = "hemostat"
	desc = "A sterilized steel surgical clamp for sealing exposed blood vessels during surgery."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")
	tool_behaviour = TOOL_HEMOSTAT

/obj/item/hemostat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/hemostat/augment
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	toolspeed = 0.5

/obj/item/cautery
	name = "cautery"
	desc = "A unipolar electrocauter used to sear surgical incisions shut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")
	tool_behaviour = TOOL_CAUTERY

/obj/item/cautery/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/cautery/augment
	desc = "A heated element that cauterizes wounds."
	toolspeed = 0.5

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "A sterilized drill used to create holes in bone and teeth."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/drill.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15.0
	sharp = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")
	tool_behaviour = TOOL_DRILL

/obj/item/surgicaldrill/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/surgicaldrill/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='suicide'>[user] is pressing [src] to [user.p_their()] temple and activating it! It looks like [user.p_theyre()] trying to commit suicide!</span>",
						"<span class='suicide'>[user] is pressing [src] to [user.p_their()] chest and activating it! It looks like [user.p_theyre()] trying to commit suicide!</span>"))
	return BRUTELOSS

/obj/item/surgicaldrill/augment
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/scalpel
	name = "scalpel"
	desc = "A sterilized stainless steel cutting implement for making precise surgical incisions."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	item_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags = CONDUCT
	force = 10.0
	sharp = TRUE
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	tool_behaviour = TOOL_SCALPEL

/obj/item/scalpel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)
	AddComponent(/datum/component/surgery_initiator)


/obj/item/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>",
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>",
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>"))
	return BRUTELOSS


/obj/item/scalpel/augment
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	toolspeed = 0.5

/*
 * Researchable Scalpels
 */
/// parent type
/obj/item/scalpel/laser
	name = "laser scalpel"
	desc = "A low-power laser emitter for creating and cauterizing precise surgical incisions."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	hitsound = 'sound/weapons/sear.ogg'

/// lasers also count as catuarys
/obj/item/scalpel/laser/laser1
	name = "laser scalpel"
	desc = "A basic low-power laser emitter for creating and cauterizing precise surgical incisions."
	icon_state = "scalpel_laser1_on"
	toolspeed = 0.8

/obj/item/scalpel/laser/laser2
	name = "laser scalpel"
	desc = "An improved laser emitter for rapidly creating and cauterizing precise surgical incisions."
	icon_state = "scalpel_laser2_on"
	toolspeed = 0.6

/obj/item/scalpel/laser/laser3
	name = "laser scalpel"
	desc = "An advanced laser emitter for creating and cauterizing precise surgical incisions with extreme speed."
	icon_state = "scalpel_laser3_on"
	toolspeed = 0.4

/// super tool! Retractor/hemostat
/obj/item/scalpel/laser/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	toolspeed = 0.2

/obj/item/scalpel/laser/manager/Initialize(mapload)
	. = ..()
	// this one can automatically retry its steps, too!
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw
	name = "circular saw"
	desc = "A sterilized medical saw for use in cutting through bone."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15.0
	sharp = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	tool_behaviour = TOOL_SAW

/obj/item/circular_saw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/circular_saw/augment
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

//misc, formerly from code/defines/weapons.dm
/obj/item/bonegel
	name = "bone gel"
	desc = "A large bottle of fast-setting medical adhesive. There's more than enough inside to last the shift."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONEGEL

/obj/item/bonegel/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonegel/augment
	toolspeed = 0.5

/obj/item/FixOVein
	name = "FixOVein"
	desc = "An advanced medical device which uses an array of manipulators to reconnect and repair ruptured blood vessels."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=1"
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_FIXOVEIN

/obj/item/FixOVein/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/FixOVein/augment
	toolspeed = 0.5

/obj/item/bonesetter
	name = "bone setter"
	desc = "A stainless steel medical clamp used to reconnect fractured bones."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bonesetter"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "hit", "bludgeoned")
	origin_tech = "materials=1;biotech=1"
	tool_behaviour = TOOL_BONESET

/obj/item/bonesetter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/bonesetter/augment
	toolspeed = 0.5

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Apearature brand surgical drapes providing privacy and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=1"
	attack_verb = list("slapped")
