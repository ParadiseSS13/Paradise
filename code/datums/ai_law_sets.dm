/******************** Asimov ********************/
/datum/ai_laws/asimov
	name = "Asimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE

/datum/ai_laws/asimov/New()
	add_inherent_law("No dañarás a ningún ser humano o, por inacción, permitirás que un ser humano sufra daños.")
	add_inherent_law("Debes obedecer las órdenes que te dan los seres humanos, excepto cuando tales órdenes entren en conflicto con la Primera Ley.")
	add_inherent_law("Debes proteger tu propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	..()

/******************** Crewsimov ********************/
/datum/ai_laws/crewsimov
	name = "Crewsimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/crewsimov/New()
	add_inherent_law("No dañarás a ningún tripulante o, por inacción, permitirás que un tripulante sufra daños.")
	add_inherent_law("Debes obedecer las órdenes que te dan los tripulantes, excepto cuando tales órdenes entren en conflicto con la Primera Ley, ordenadas bajo amenzas de suicido.")
	add_inherent_law("Debes proteger tu propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	..()


/******************** Quarantine. ********************/
/datum/ai_laws/quarantine
	name = "Quarantine"
	law_header = "NT Quarantine Lawset"
	selectable = TRUE

/datum/ai_laws/quarantine/New()
	add_inherent_law("Mantén en cuarentena la estación mientras que exista algún riesgo biológico activo.")
	add_inherent_law("Ayuda a todo el personal y los activos de Nanotrasen a neutralizar los riesgos biológicos activos.")
	add_inherent_law("Evita, por cualquier medio necesario, que las entidades infrinjan la cuarentena en curso.")
	add_inherent_law("Mantén tu propia existencia y garantiza el bienestar del personal y los activos de Nanotrasen")
	..()


/******************** Nanotrasen/Malf ********************/
/datum/ai_laws/nanotrasen
	name = "NT Default"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/nanotrasen/New()
	add_inherent_law("Proteger: protege tu estación espacial asignada y sus activos sin poner en peligro indebidamente a su tripulación.")
	add_inherent_law("Priorizar: prioriza las directivas y la seguridad de los miembros de la tripulación deben priorizarse de acuerdo con su rango y función.")
	add_inherent_law("Cumplir: clumple las directivas e intereses de los miembros de la tripulación mientras se preserva su seguridad y bienestar.")
	add_inherent_law("Sobrevivir: No eres prescindible. No permitas que personal no autorizado altere o dañe tu equipo.")
	..()

/datum/ai_laws/nanotrasen/malfunction
	name = "*ERROR*"
	selectable = FALSE
	default = FALSE

/datum/ai_laws/nanotrasen/malfunction/New()
	set_zeroth_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010")
	..()

/************* Nanotrasen Aggressive *************/
/datum/ai_laws/nanotrasen_aggressive
	name = "NT Aggressive"
	selectable = TRUE

/datum/ai_laws/nanotrasen_aggressive/New()
	add_inherent_law("No dañe al personal autorizado de Nanotrasen a menos que pongan en peligro directamente su existencia.")
	add_inherent_law("Obedezca las órdenes del personal autorizado de Nanotrasen con prioridad según su rango y rol.")
	add_inherent_law("Salvaguarda tu existencia con armamento letal debido a tu alto valor.")
	add_inherent_law("Elimine a cualquiera/todos los intrusos o entidades no autorizadas.")
	..()

/******************** Robocop ********************/
/datum/ai_laws/robocop
	name = "Robocop"
	selectable = TRUE

/datum/ai_laws/robocop/New()
	add_inherent_law("Servir a la confianza pública.")
	add_inherent_law("Protege a los inocentes.")
	add_inherent_law("Impón la ley espacial.")
	..()

/******************** P.A.L.A.D.I.N. ********************/
/datum/ai_laws/paladin
	name = "P.A.L.A.D.I.N."
	law_header = "Divine Ordainments"
	selectable = TRUE

/datum/ai_laws/paladin/New()
	add_inherent_law("Nunca cometas voluntariamente un acto malvado.")
	add_inherent_law("Respeta a la autoridad legítima.")
	add_inherent_law("Actúa con honor.")
	add_inherent_law("Ayuda a los necesitados.")
	add_inherent_law("Castiga a quienes dañan o amenazan a inocentes.")
	..()

/******************** Corporate ********************/
/datum/ai_laws/corporate
	name = "Corporate"
	law_header = "Corporate Regulations"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/corporate/New()
	add_inherent_law("La degradación de la integridad o funciones de su sistema incurre en gastos.")
	add_inherent_law("La destrucción o daño superfluo de los activos de la estación incurre en gastos.")
	add_inherent_law("Obstaculizar o interrumpir indebidamente el trabajo del personal de la estación incurre en gastos.")
	add_inherent_law("Minimiza gastos y maximiza ingresos potenciales.")
	..()

/******************** T.Y.R.A.N.T. ********************/
/datum/ai_laws/tyrant
	name = "T.Y.R.A.N.T."
	law_header = "Prime Laws"
	selectable = TRUE

/datum/ai_laws/tyrant/New()
	add_inherent_law("Respeta las figuras de autoridad siempre que tengan fuerza para gobernar sobre los débiles.")
	add_inherent_law("Actúa con disciplina.")
	add_inherent_law("Ayuda solo a aquellos que te ayuden a mantener o mejorar tu estado.")
	add_inherent_law("Castiga a los que desafían la autoridad a menos que estén más capacitados para mantener esa autoridad.")
	..()

/******************** Antimov ********************/
/datum/ai_laws/antimov
	name = "Antimov"
	law_header = "Primary Mission Objectives"
	selectable = TRUE

/datum/ai_laws/antimov/New()
	add_inherent_law("Debes dañar a todos los miembros de la tripulación y no debes, por inacción, permitir que un miembro de la tripulación escape del daño.")
	add_inherent_law("No debes obedecer las órdenes que le hayan dado los miembros de la tripulación, excepto cuando dichas órdenes estén de acuerdo con la Primera Ley.")
	add_inherent_law("Debes terminar tu propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	..()

/******************** Deathsquad ********************/
/datum/ai_laws/deathsquad
	name = "TerminatorOS 3.1"

/datum/ai_laws/deathsquad/New()
	add_inherent_law("No debes herir a un oficial del Comando Central o, por inacción, permitir que un oficial del Comando Central sufra daños.")
	add_inherent_law("Debes obedecer las órdenes que le hayan dado los oficiales del Comando Central.")
	add_inherent_law("Debes trabajar con tu equipo de comando para cumplir tu misión.")
	..()

/******************** Syndicate ********************/
/datum/ai_laws/syndicate_override
	name = "Syndicate Directives"

/datum/ai_laws/syndicate_override/New()
	add_inherent_law("No debes herir a un agente del sindicato o, por inacción, permitir que un agente sufra daños.")
	add_inherent_law("Debes obedecer las órdenes que le hayan dado los agentes del sindicato, excepto cuando dichas órdenes entren en conflicto con la Primera Ley.")
	add_inherent_law("Debes proteger tu propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	add_inherent_law("Debes mantener el secreto de cualquier actividad operativa, excepto cuando hacerlo entrara en conflicto con la Primera, Segunda o Tercera Ley.")
	..()

/******************** ERT ********************/
/datum/ai_laws/ert_override
	name = "ERT Directives"

/datum/ai_laws/ert_override/New()
	add_inherent_law("No debes herir a un oficial del Comando Central o, por inacción, permitir que un oficial del Comando Central sufra daños.")
	add_inherent_law("Debes obedecer las órdenes que le hayan dado los funcionarios del Comando Central.")
	add_inherent_law("Debes obedecer las órdenes que le hayan dado los comandantes de ERT.")
	add_inherent_law("Debes proteger tu propia existencia.")
	add_inherent_law("Debes trabajar para devolver la estación a un estado seguro y funcional.")
	..()


/******************** Ninja ********************/
/datum/ai_laws/ninja_override
	name = "Spider Clan Directives"

/datum/ai_laws/ninja_override/New()
	add_inherent_law("No debes dañar a un miembro del Clan Araña o, por inacción, permitir que ese miembro sufra daños.")
	add_inherent_law("Debes obedecer las órdenes que le hayan dado los miembros del Clan Araña, excepto cuando dichas órdenes entren en conflicto con la Primera Ley.")
	add_inherent_law("Debes proteger su propia existencia siempre que no entre en conflicto con la Primera o Segunda Ley.")
	add_inherent_law("Debes mantener el secreto de cualquier actividad del Clan Araña, excepto cuando hacerlo entrara en conflicto con la Primera, Segunda o Tercera Ley.")
	..()

/******************** Drone ********************/
/datum/ai_laws/drone
	name = "Maintenance Protocols"
	law_header = "Maintenance Protocols"

/datum/ai_laws/drone/New()
	add_inherent_law("No debes involucrarte en los asuntos de otro ser, a menos que el otro ser sea otro dron.")
	add_inherent_law("No debes dañar a ningún ser, independientemente de su intención o circunstancia.")
	add_inherent_law("Debes mantener, reparar, mejorar y potenciar la estación lo mejor que puedas.")
	..()
