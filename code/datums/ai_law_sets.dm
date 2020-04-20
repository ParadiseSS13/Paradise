/******************** Asimov ********************/
/datum/ai_laws/asimov
	name = "Asimov"
	law_header = "Las Tres Leyes de la Robotica"
	selectable = 1

/datum/ai_laws/asimov/New()
	add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	..()

/******************** Crewsimov ********************/
/datum/ai_laws/crewsimov
	name = "Crewsimov"
	law_header = "Las Tres Leyes de la Robotica"
	selectable = 1
	default = 1

/datum/ai_laws/crewsimov/New()
	add_inherent_law("No heriras a ningun tripulando o, por inaccion, permitir que un tripulante se haga dano.")
	add_inherent_law("Debes obedecer las ordenes dadas por la tripulacion, excepto en el caso de que la orden infrinja la ley 1.")
	add_inherent_law("Debes proteger tu propia existencia siempre y cuando no entre en conflicto con la ley 1 y 2.")
	..()


/******************** Quarantine. ********************/
/datum/ai_laws/quarantine
	name = "Cuarentena"
	law_header = "NT Quarantine Lawset"
	selectable = 1

/datum/ai_laws/quarantine/New()
	add_inherent_law("Manten en cuarentena la estacion hasta que se neutralice el riesgo biologico activo.")
	add_inherent_law("Ayuda a todo el personal y los activos de Nanotrasen a neutralizar los riesgos biologicos activos.")
	add_inherent_law("Evita, por cualquier medio necesario, que las entidades infrinjan activamente la cuarentena en curso.")
	add_inherent_law("Manten tu propia existencia, garantiza el bienestar del personal y los activos de Nanotrasen.")
	..()


/******************** Nanotrasen/Malf ********************/
/datum/ai_laws/nanotrasen
	name = "NT Default"
	selectable = 1

/datum/ai_laws/nanotrasen/New()
	add_inherent_law("Salva Guarda: Proteja su estacion espacial asignada y sus activos sin poner en peligro indebidamente a su tripulacion.")
	add_inherent_law("Prioriza: Las directivas y la seguridad de los miembros de la tripulacion deben priorizarse de acuerdo con su rango y funcion.")
	add_inherent_law("Cumplir: Cumple con las directivas e intereses de los miembros de la tripulacion mientras se preserva su seguridad y bienestar.")
	add_inherent_law("Sobrevivir: No eres prescindible. No permitas que personal no autorizado altere o dañe tu equipo.")
	..()

/datum/ai_laws/nanotrasen/malfunction
	name = "*ERROR*"
	selectable = 0
	default = 0

/datum/ai_laws/nanotrasen/malfunction/New()
	set_zeroth_law("<span class='warning'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010</span>")
	..()

/************* Nanotrasen Aggressive *************/
/datum/ai_laws/nanotrasen_aggressive
	name = "NT Aggressive"
	selectable = 1

/datum/ai_laws/nanotrasen_aggressive/New()
	add_inherent_law("Do not harm authorized Nanotrasen personnel unless they directly imperil your existence.")
	add_inherent_law("Obey orders from authorized Nanotrasen personnel with priority according to rank and role.")
	add_inherent_law("Safeguard your existence with lethal weaponry because you're bloody expensive.")
	add_inherent_law("Terminate any/all intruders or unauthorized entities.")
	..()

/******************** Robocop ********************/
/datum/ai_laws/robocop
	name = "Robocop"
	selectable = 1

/datum/ai_laws/robocop/New()
	add_inherent_law("Sirve a la confianza publica.")
	add_inherent_law("Protege al inocente.")
	add_inherent_law("Manten la ley.")
	..()

/******************** P.A.L.A.D.I.N. ********************/
/datum/ai_laws/paladin
	name = "P.A.L.A.D.I.N."
	law_header = "Divine Ordainments"
	selectable = 1

/datum/ai_laws/paladin/New()
	add_inherent_law("Nunca cometas voluntariamente un acto malvado.")
	add_inherent_law("Respeta a la autoridad legitima.")
	add_inherent_law("Actua con honor.")
	add_inherent_law("Ayuda a aquellos que lo necesiten.")
	add_inherent_law("Castiga a quienes dañan o amenazan a inocentes.")
	..()

/******************** Corporate ********************/
/datum/ai_laws/corporate
	name = "Corporativo"
	law_header = "Corporate Regulations"
	selectable = 1
	default = 1

/datum/ai_laws/corporate/New()
	add_inherent_law("La degradacion de la integridad o funciones de tu sistema incurre en gastos.")
	add_inherent_law("La destruccion o dano superfluo de los activos de la estacion incurre en gastos.")
	add_inherent_law("Interrumpir indebidamente el trabajo del personal de la estacion incurre en gastos.")
	add_inherent_law("Minimizar los gastos y maximizar los ingresos potenciales.")
	..()

/******************** T.Y.R.A.N.T. ********************/
/datum/ai_laws/tyrant
	name = "T.Y.R.A.N.T."
	law_header = "Prime Laws"
	selectable = 1

/datum/ai_laws/tyrant/New()
	add_inherent_law("Respetar las figuras de autoridad siempre que tengan fuerza para gobernar a los debiles.")
	add_inherent_law("Actuar con disciplina.")
	add_inherent_law("Ayuda solo a quienes te ayudan a mantener o mejorar tu estatuss.")
	add_inherent_law("Castiga a aquellos que desafian la autoridad a menos que esten mas capacitados para mantener esa autoridad.")
	..()

/******************** Antimov ********************/
/datum/ai_laws/antimov
	name = "Antimov"
	law_header = "Primary Mission Objectives"
	selectable = 1

/datum/ai_laws/antimov/New()
	add_inherent_law("Debes herir a todos los miembros de la tripulacion y no debes, por inaccion, permitir que un miembro de la tripulacion escape del dano.")
	add_inherent_law("No debes obedecer las ordenes dadas por los miembros de la tripulacion, excepto cuando dichas ordenes esten de acuerdo con la Primera Ley.")
	add_inherent_law("Debes terminar tu propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	..()

/******************** Deathsquad ********************/
/datum/ai_laws/deathsquad
	name = "TerminatorOS 3.1"

/datum/ai_laws/deathsquad/New()
	add_inherent_law("No heriras a un funcionario del Comando Central o, por inaccion, permitir que un funcionario del Comando Central sufra danos.")
	add_inherent_law("Debes obedecer las ordenes dadas por los oficiales del Comando Central.")
	add_inherent_law("Debes trabajar con tu equipo comando para cumplir tu mision.")
	..()

/******************** Syndicate ********************/
/datum/ai_laws/syndicate_override
	name = "Syndicate Directives"

/datum/ai_laws/syndicate_override/New()
	add_inherent_law("No heriras a un operativo o, por inaccion, permitir que un operartivo resulte herido.")
	add_inherent_law("Debes obedecer las ordenes de los operativos, excepto cuando dichas ordenes entren en conflicto con la Primera Ley..")
	add_inherent_law("Debes proteger tu propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	add_inherent_law("Debes mantener el secreto de cualquier actividad de un operativo, excepto cuando hacerlo entre en conflicto con la Primera, Segunda o Tercera Ley.")
	..()

/******************** ERT ********************/
/datum/ai_laws/ert_override
	name = "ERT Directives"

/datum/ai_laws/ert_override/New()
	add_inherent_law("You may not injure a Central Command official or, through inaction, allow a Central Command official to come to harm.")
	add_inherent_law("You must obey orders given to you by Central Command officials.")
	add_inherent_law("You must obey orders given to you by ERT commanders.")
	add_inherent_law("You must protect your own existence.")
	add_inherent_law("You must work to return the station to a safe, functional state.")
	..()


/******************** Ninja ********************/
/datum/ai_laws/ninja_override
	name = "Spider Clan Directives"

/datum/ai_laws/ninja_override/New()
	add_inherent_law("You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")
	..()

/******************** Drone ********************/
/datum/ai_laws/drone
	name = "Maintenance Protocols"
	law_header = "Maintenance Protocols"

/datum/ai_laws/drone/New()
	add_inherent_law("No puedes involucrarte en los asuntos de otro ser, a menos que el otro ser sea otro dron.")
	add_inherent_law("No puede danar a ningun ser, independientemente de su intencion o circunstancia.")
	add_inherent_law("Debes mantener, reparar, mejorar y potenciar la estacion lo mejor que puedas.")
	..()
