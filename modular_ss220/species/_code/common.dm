//Количество урона карапасу, когда не работает броня
#define SERPENTID_CARAPACE_NOARMOR_STATE 30
//Количество урона карапасу, когда не работает скрытность
#define SERPENTID_CARAPACE_NOCHAMELION_STATE 60
//Количество урона карапасу, когда не работает "риг"
#define SERPENTID_CARAPACE_NOPRESSURE_STATE 90
//Количество урона, если присоединить конечность (не протез) другого вида
#define SERPENTID_GENE_DEGRADATION_DAMAGE 0.5
//Количество времени, через сколько происходит нанесение генетического урона
#define SERPENTID_GENE_DEGRADATION_CD 60

//Обычный, здоровый ГБС без дополнительных химикатов и болезней потребляет 0.1 единицы голода в тик (2 секунды), считаем от хорошо насыщенного до истощения
//Сколько голода потребляют легкие (сальбутамол и подвыработка кислорода)
#define SERPENTID_ORGAN_HUNGER_LUNGS 0.75 //15 минут
//Сколько голода потребляют почки (скрытность)
#define SERPENTID_ORGAN_HUNGER_KIDNEYS 0.5 //19 минут
//Сколько голода потребляют глаза (ПНВ)
#define SERPENTID_ORGAN_HUNGER_EYES 0.05  //58 минут
//Сколько голода потребляют уши (сонар)
#define SERPENTID_ORGAN_HUNGER_EARS 0.1  //78 минут

//минимальное цветовосприятие
#define SERPENTID_EYES_LOW_VISIBLE_VALUE 0.5
//Максимальное цветовосприяте
#define SERPENTID_EYES_MAX_VISIBLE_VALUE 1

/datum/species
	var/can_buckle = FALSE
	var/buckle_lying = TRUE
	var/eyes_icon = 'icons/mob/human_face.dmi'
	var/face_icon = 'icons/mob/human_face.dmi'
	var/face_icon_state = "bald_s"
	var/action_mult = 1
	var/equipment_black_list = list()
	var/butt_sprite_icon = 'icons/obj/butts.dmi'
