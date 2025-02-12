/*
===Модуль панциря (карапаса)
Цепляется на конечность. Особенность в том, что изначально придает конечности усиленную броню, но по достиженю трешхолда слома (устаналивается тут) конечность ломается

Сломанная конечность увеличивает входящий по ней урон. Считает и брут и берн уроны. В случае получения берн урона процент урона переносится на органы.area

Сопротивление/уязвимость к урону ожогами всегда ниже/выше сопротивления травмам.

Панцирь блокирует стандартные операции, пока не будет сломан.

Панцирь самовосстановится, если полностью вылечить конечность. Но есть параметр, который разрешает 100% или иное заживление при исцелении урона конечности.
*/
//Базовый трешхолд урона, при достижение или выше которого будет слом.
#define CARAPACE_BROKEN_STATE 20
//Базовая уязвимость к урону травмами (0.8 = 80%)
#define CARAPACE_BASIC_BRUTE_VULNERABILITY 0.8
//Бонус к уязвимости ожогу относительно урона травм
#define CARAPACE_ADDITIVE_BURN_VULNERABILITY 0.1
//Функция на будущее - позволяет переносить проценты урона
#define CARAPACE_DAMAGE_TRANSFER_PERCENTAGES 1
//Вероятность восстановления конечности при достижении 0 урона
#define CARAPACE_HEAL_BROKEN_PROB 50
//Список операций, которые будут заблокированы пока панцирь не будет сломан
#define CARAPACE_BLOCK_OPERATION list(/datum/surgery/bone_repair,/datum/surgery/bone_repair/skull,/datum/surgery/organ_manipulation,/datum/surgery/organ_manipulation/soft)
#define CARAPACE_ENCASE_WORD "chitin"

/datum/component/carapace
	var/self_mending = FALSE
	var/broken_treshold = CARAPACE_BROKEN_STATE

/datum/component/carapace/Initialize(allow_self_mending, break_threshold)
	src.self_mending = allow_self_mending
	src.broken_treshold = break_threshold
	var/obj/item/organ/external/affected_limb = parent
	affected_limb.encased = CARAPACE_ENCASE_WORD

/datum/component/carapace/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIMB_RECEIVE_DAMAGE, PROC_REF(receive_damage))
	RegisterSignal(parent, COMSIG_LIMB_HEAL_DAMAGE, PROC_REF(heal_damage))

/datum/component/carapace/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIMB_RECEIVE_DAMAGE)
	UnregisterSignal(parent, COMSIG_LIMB_HEAL_DAMAGE)

//Проки, срабатываемые при получении или исцелении урона
/datum/component/carapace/proc/receive_damage(obj/item/organ/external/affected_limb, brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list(), ignore_resists = FALSE, updating_health = TRUE)
	SIGNAL_HANDLER
	if(affected_limb.get_damage() > broken_treshold)
		affected_limb.fracture()
	if(length(affected_limb.internal_organs))
		var/obj/item/organ/internal/O = pick(affected_limb.internal_organs)
		O.receive_damage(burn * affected_limb.burn_dam)

/datum/component/carapace/proc/heal_damage(obj/item/organ/external/affected_limb, brute, burn, internal = 0, robo_repair = 0, updating_health = TRUE)
	SIGNAL_HANDLER
	if((affected_limb.status & ORGAN_BROKEN) && affected_limb.get_damage() == 0)
		if(self_mending || prob(CARAPACE_HEAL_BROKEN_PROB))
			affected_limb.mend_fracture()

//////////////////////////////////////////////////////////////////
//					Хирургия для панциря						//
//////////////////////////////////////////////////////////////////
///Датумы для операций
/datum/surgery/carapace_break
	name = "Break carapace"
	steps = list(
		/datum/surgery_step/saw_carapace,
		/datum/surgery_step/cut_carapace,
		/datum/surgery_step/retract_carapace
	)

	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)
	requires_organic_bodypart = TRUE

/datum/surgery/organ_manipulation/carapace
	name = "Organ Manipulation"
	steps = list(
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/internal/manipulate_organs/finish,
	)
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)
	requires_organic_bodypart = TRUE

/datum/surgery/bone_repair/carapace
	name = "Carapace Repair"
	steps = list(
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)
	requires_organic_bodypart = TRUE

//Оверрайды для операций, которые могут применяться для панциря.
//Возможный рефактор - отослать сигнал в компоненнт с параметрами "операция, зона операции" и вернуть значение оттуда?
/datum/surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected?.encased == CARAPACE_ENCASE_WORD)
		if((src.type in CARAPACE_BLOCK_OPERATION) || !(affected.status & ORGAN_BROKEN)) //отключить стандартные операции класса "манипуляция органов", восстановить кость/череп.
			return FALSE
	. = .. ()

//Общие операции - проверка, на доступной карапасовых карапасовым и vice versa
/datum/surgery/bone_repair/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected?.encased == CARAPACE_ENCASE_WORD)
		return FALSE
	. = .. ()

//Чинить карапас можно если он сломан
/datum/surgery/bone_repair/carapace/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if((affected?.encased == CARAPACE_ENCASE_WORD) && (affected.status & ORGAN_BROKEN))
		return TRUE
	return FALSE

//Ломать карапас можно если он цел
/datum/surgery/carapace_break/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if((affected?.encased == CARAPACE_ENCASE_WORD) && !(affected.status & ORGAN_BROKEN))
		return TRUE
	return FALSE

//Манипуляция органов возможна если карапас и он сломан
/datum/surgery/organ_manipulation/carapace/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if((affected?.encased == CARAPACE_ENCASE_WORD) && (affected.status & ORGAN_BROKEN))
		return TRUE
	return FALSE

//Блокировка простого скальпеля (базовый начальный шаг любой операции), если карапас не был сломан, но появилась какая-то операция, которая не должна быть
/datum/surgery_step/generic/cut_open/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if((affected?.encased == CARAPACE_ENCASE_WORD) && !(affected.status & ORGAN_BROKEN))
		to_chat(user, span_notice("[capitalize(target.declent_ru(NOMINATIVE))] покрыта крепким хитином. Сломайте его, прежде чем начать операцию."))
		return SURGERY_BEGINSTEP_ABORT
	. = .. ()

/datum/surgery_step/retract_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if((affected?.encased == CARAPACE_ENCASE_WORD) && !(affected.status & ORGAN_BROKEN))
		affected.fracture()
	. = .. ()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if((affected?.encased == CARAPACE_ENCASE_WORD) && !(affected.status & ORGAN_BROKEN))
		affected.mend_fracture()
	. = .. ()

#undef CARAPACE_BROKEN_STATE
#undef CARAPACE_BASIC_BRUTE_VULNERABILITY
#undef CARAPACE_ADDITIVE_BURN_VULNERABILITY
#undef CARAPACE_DAMAGE_TRANSFER_PERCENTAGES
#undef CARAPACE_HEAL_BROKEN_PROB
#undef CARAPACE_BLOCK_OPERATION
