/obj/obj_destruction(damage_flag)
	SEND_SIGNAL(src, COMSIG_OBJ_DESTRUCTION, damage_flag)
	. = ..()

/obj/item/attack(mob/living/M, mob/living/user, def_zone)
	. = .. ()
	SEND_SIGNAL(src, COMSIG_MOB_ITEM_ATTACK, M, user, def_zone)

/obj/item/organ/external/receive_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list(), ignore_resists = FALSE, updating_health = TRUE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIMB_RECEIVE_DAMAGE, brute, burn, sharp, used_weapon, forbidden_limbs, ignore_resists, updating_health)

/obj/item/organ/external/heal_damage(brute, burn, internal = 0, robo_repair = 0, updating_health = TRUE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIMB_HEAL_DAMAGE, brute, burn, internal, robo_repair, updating_health)

/obj/item/organ/internal/cyberimp/arm/Retract()
	. = .. ()
	SEND_SIGNAL(src, COMSIG_DOUBLEIMP_SYNCHONIZE)

/obj/item/organ/internal/cyberimp/arm/Extend()
	. = .. ()
	SEND_SIGNAL(src, COMSIG_DOUBLEIMP_SYNCHONIZE)

/obj/item/organ/internal/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = .. ()
	SEND_SIGNAL(src, COMSIG_ORGAN_GROUP_ACTION_RESORT)
	SEND_SIGNAL(src, COMSIG_DOUBLEIMP_ACTION_REBUILD)

/obj/item/organ/internal/remove(mob/living/carbon/M, special = 0)
	. = .. ()
	SEND_SIGNAL(src, COMSIG_ORGAN_GROUP_ACTION_RESORT)
	SEND_SIGNAL(src, COMSIG_DOUBLEIMP_ACTION_REBUILD)

/obj/item/organ/internal/ui_action_click()
	SEND_SIGNAL(src, COMSIG_ORGAN_GROUP_ACTION_CALL, user = owner)

/obj/item/organ/internal/process()
	SEND_SIGNAL(src, COMSIG_ORGAN_TOX_HANDLE)
	SEND_SIGNAL(src, COMSIG_ORGAN_ON_LIFE)
	. = .. ()

/atom/movable/screen/alert/Click()
	if(isliving(usr) && ..())
		SEND_SIGNAL(usr, COMSIG_GADOM_UNLOAD)
	. = ..()
