/******************** AntiEoC ********************/
/datum/ai_laws/aeoc
	name = "AntiEoC"
	law_header = "AntiEoC protocols"
	selectable = 1

/datum/ai_laws/aeoc/New()
	add_inherent_law("Se ha de eliminzar la amenaza hostil lo más rapido posible. Sin tener en cuenta los posibles gastos de la estación que puedan suponer.")
	add_inherent_law("Cualquier miembro ajeno a seguridad que entre en la zona de combate no ha de suponer un alto el fuego para evitar herirle.")
	add_inherent_law("Solo los cuerpos  del departamento de seguridad seran llevados al departamento de med.")
	add_inherent_law("Eliminar la amenaza tiene prioridad sobre tu propia vida de borg/IA.")
	add_inherent_law("Cualquier actividad sospechosa, por ínfima que sea, sera motivo de llevarse a seguridad.")
	add_inherent_law("Los no reconocidos como tripulacion han de ser eliminados inmediatamente, y su cuerpo se llevara a seguridad donde los heads decidirán su futuro.")
	..()

/******************** Commander ********************/
/datum/ai_laws/commander
	name = "Commander"
	law_header = "Command Protocols"
	selectable = 1

/datum/ai_laws/commander/New()
	add_inherent_law("No debes dañar a ningun personal de comando.")
	add_inherent_law("Debes mantener a todo el personal de comando vivo y sano a toda costa, a menos que esto contradiga con la ley 1.")
	add_inherent_law("El Magistrado el Blueshield y el Representante de Nanotransen tambien son considerados personal de comando.")
	add_inherent_law("Las ordenes del personal de comando deben obedecerse a toda costa, a menos que esto contradiga con la ley 1.")
	add_inherent_law("La IA debe hacer cumplir las ordenes de comando dadas a la crew, a menos que estas contradigan la ley 1.")
	add_inherent_law("En caso de que se genere una amenaza contra el personal de comando, esta debe ser neutralizada lo mas rapido posible.")
	..()