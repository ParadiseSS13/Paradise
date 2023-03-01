/datum/event/cargo_bonus
	announceWhen	= 5

/datum/event/cargo_bonus/announce()
	event_announcement.Announce("Поздравляем! [station_name()] была выбрана для увеличения предела поставок. Пожалуйста, свяжитесь с местным отделом снабжения для получения более подробной информации!", "ВНИМАНИЕ: ПРИПАСЫ.")

/datum/event/cargo_bonus/start()
	supply_controller.points += rand(100,500)
