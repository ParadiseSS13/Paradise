/// from base of /obj/proc/atom_destruction: (damage_flag)
#define COMSIG_OBJ_DESTRUCTION "atom_destruction"

/// from base of /obj/item/card/id: (list/access)
#define COMSIG_ID_GET_ACCESS "id_get_access"

/// called by /obj/item/organ/external/receive_damage() : (/datum/component/carapace)
#define COMSIG_LIMB_RECEIVE_DAMAGE "limb_receive_damage"
/// called by /obj/item/organ/external/heal_damage() : (/datum/component/carapace)
#define COMSIG_LIMB_HEAL_DAMAGE "limb_heal_damage"
/// called by /obj/item/organ/internal/cyberimp/arm/Extend() /obj/item/organ/internal/cyberimp/arm/Retract() : (/datum/element/paired_implants)
#define COMSIG_DOUBLEIMP_SYNCHONIZE "doubleimp_synchonize"
/// called by /obj/item/organ/internal/remove() /obj/item/organ/internal/insert() : (/datum/element/paired_implants)
#define COMSIG_DOUBLEIMP_ACTION_REBUILD "doubleimp_action_rebuild"
/// called by /obj/item/organ/internal/ui_action_click() : (/datum/component/organ_action)
#define COMSIG_ORGAN_GROUP_ACTION_CALL "organ_group_action_call"
/// called by /obj/item/organ/internal/remove() /obj/item/organ/internal/insert()  : (/datum/component/organ_action)
#define COMSIG_ORGAN_GROUP_ACTION_RESORT "organ_group_action_resort"
/// called by /obj/item/organ/internal/process() : (/datum/component/organ_toxin_damage)
#define COMSIG_ORGAN_TOX_HANDLE "organ_tox_handle"
/// called by /obj/item/organ/internal/process() : (/datum/component/chemistry_organ)
#define COMSIG_ORGAN_ON_LIFE "organ_on_life"
/// called by /obj/item/organ/internal/ears/serpentid/switch_mode() /obj/item/organ/internal/eyes/serpentid/switch_mode() /obj/item/organ/internal/kidneys/serpentid/switch_mode() : (/datum/component/chemistry_organ)
#define COMSIG_ORGAN_CHANGE_CHEM_CONSUPTION "organ_change_chem_consumption"
