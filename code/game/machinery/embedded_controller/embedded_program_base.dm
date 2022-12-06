
/datum/computer/file/embedded_program
	var/list/memory = list()
	var/obj/machinery/airlock_controller/master

/datum/computer/file/embedded_program/New(obj/machinery/airlock_controller/M)
	master = M

/datum/computer/file/embedded_program/Destroy()
	master = null
	memory.Cut()
	return ..()

/datum/computer/file/embedded_program/proc/receive_user_command(command)
	return

/datum/computer/file/embedded_program/process()
	return FALSE
