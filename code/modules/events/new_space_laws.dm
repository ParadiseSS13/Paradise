/datum/event/new_space_law
	announceWhen = 1

/datum/event/new_space_law/announce()
	var/list/new_space_laws = file2list("strings/new_space_laws.txt")
	GLOB.major_announcement.Announce("В связи с последними событиями в космической политике, [pick(new_space_laws)] теперь признается (или признаются) незаконным(-ыми) по кодовому номеру «1xx» Космического Закона. Вы обязаны незамедлительно исправить ситуацию в течение 15 минут. Мы настоятельно рекомендуем вам поторопиться, чтобы избежать возможных негативных последствий.", "Юридический отдел Нанотрейзен")
