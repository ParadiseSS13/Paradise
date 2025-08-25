///Хитиновые конечности - прочее
/obj/item/organ/external/groin/carapace
	min_broken_damage = 40
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/groin/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, FALSE, min_broken_damage)

/obj/item/organ/external/arm/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/arm/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/arm/right/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/arm/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/leg/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/leg/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/hand/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/hand/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/hand/right/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/hand/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/leg/right/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/leg/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/foot/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/foot/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)

/obj/item/organ/external/foot/right/carapace
	min_broken_damage = 20
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/foot/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, TRUE, min_broken_damage)
