#define SERPENTID_ARMOR_THRESHOLD_1 30
#define SERPENTID_ARMOR_THRESHOLD_2 60
#define SERPENTID_ARMOR_THRESHOLD_3 90

#define SERPENTID_ARMORED_LOW_TEMP 0
#define SERPENTID_ARMORED_HIGH_TEMP 400
#define SERPENTID_ARMORED_STEP_TEMP 30

/obj/item/organ/external/chest/carapace
	min_broken_damage = 40
	encased = CARAPACE_ENCASE_WORD

/obj/item/organ/external/chest/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, FALSE, min_broken_damage)

/obj/item/organ/external/chest/carapace/replaced()
	. = ..()
	AddComponent(/datum/component/carapace_shell, owner, treshold_1 = SERPENTID_ARMOR_THRESHOLD_1, treshold_2 = SERPENTID_ARMOR_THRESHOLD_2, treshold_3 = SERPENTID_ARMOR_THRESHOLD_3, threshold_cold = SERPENTID_ARMORED_LOW_TEMP, threshold_heat = SERPENTID_ARMORED_HIGH_TEMP, temp_progression = SERPENTID_ARMORED_STEP_TEMP)

#undef SERPENTID_ARMOR_THRESHOLD_1
#undef SERPENTID_ARMOR_THRESHOLD_2
#undef SERPENTID_ARMOR_THRESHOLD_3
#undef SERPENTID_ARMORED_LOW_TEMP
#undef SERPENTID_ARMORED_HIGH_TEMP
#undef SERPENTID_ARMORED_STEP_TEMP
