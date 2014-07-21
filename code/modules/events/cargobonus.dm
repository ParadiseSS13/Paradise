/datum/event/cargo_bonus
	announceWhen	= 5

/datum/event/cargo_bonus/announce()
	command_alert("Congratulations! [station_name()] was chosen for supply limit increase, please contact local cargo department for details!.", "Supply Alert")

/datum/event/cargo_bonus/start()
	supply_controller.points+=rand(100,500)