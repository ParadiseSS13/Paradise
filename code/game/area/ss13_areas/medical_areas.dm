
/area/station/medical
	ambientsounds = MEDICAL_SOUNDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	min_ambience_cooldown = 90 SECONDS
	max_ambience_cooldown = 180 SECONDS

/area/station/medical/medbay
	name = "Медицинский Отдел"
	icon_state = "medbay"
	request_console_flags = RC_ASSIST

//Medbay is a large area, these additional areas help level out APC load.
/area/station/medical/medbay2
	name = "Медицинский Отдел"
	icon_state = "medbay"

/area/station/medical/medbay3
	name = "Медицинский Отдел"
	icon_state = "medbay"

/area/station/medical/storage
	name = "Склад Медицинского Отдела"
	icon_state = "medbaystorage"
	request_console_flags = RC_ASSIST
	request_console_name = "Медицинский Отдел"

/area/station/medical/reception
	name = "Ресепшен Медицинского Отдела"
	icon_state = "medbaylobby"
	request_console_flags = RC_ASSIST
	request_console_name = "Медицинский Отдел"

/area/station/medical/psych
	name = "Офис Психолога"
	icon_state = "medbaypsych"
	request_console_flags = RC_SUPPLY
	request_console_name = "Psychiatrist"

/area/station/medical/break_room
	name = "Комната Отдыха Медицинского Отдела"
	icon_state = "medbaybreak"

/area/station/medical/patients_rooms
	name = "Психиатрические Палаты"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms1
	name = "Палаты Пациентов"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/patients_rooms_secondary
	name = "Вспомогательные Палаты Пациентов"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/medical/coldroom
	name = "Морозильная Камера Медицинского Отдела"
	icon_state = "coldroom"

/area/station/medical/storage/secondary
	name = "Дополнительный Склад Медицинского Отдела"
	icon_state = "medbaysecstorage"

/area/station/medical/virology
	name = "Вирусология"
	icon_state = "virology"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/medical/virology/lab
	name = "Лаборатория Вирусологии"
	icon_state = "virology"

/area/station/medical/morgue
	name = "Морг"
	icon_state = "morgue"
	ambientsounds = SPOOKY_SOUNDS
	is_haunted = TRUE
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	request_console_flags = RC_ASSIST | RC_INFO

/area/station/medical/chemistry
	name = "Химическая Лаборатория Медицинского Отдела"
	icon_state = "chem"
	request_console_flags = RC_ASSIST | RC_SUPPLY

/area/station/medical/surgery
	name = "Операционное Отделение"
	icon_state = "surgery"

/area/station/medical/surgery/primary
	name = "Первая Операционная"
	icon_state = "surgery1"

/area/station/medical/surgery/secondary
	name = "Вторая Операционная"
	icon_state = "surgery2"

/area/station/medical/surgery/observation
	name = "Комната Оперативного Наблюдения"
	icon_state = "surgery"

/area/station/medical/cryo
	name = "Криогеника"
	icon_state = "cryo"

/area/station/medical/exam_room
	name = "Комната Осмотра Медицинского Отдела"
	icon_state = "exam_room"

/area/station/medical/cloning
	name = "Лаборатория Клонирования"
	icon_state = "cloning"

/area/station/medical/sleeper
	name = "Центр Медицинского Лечения"
	icon_state = "exam_room"

/area/station/medical/paramedic
	name = "Офис Парамедика"
	icon_state = "paramedic"
	request_console_flags = RC_ASSIST
