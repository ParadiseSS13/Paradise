/******************** Asimov ********************/
/datum/ai_laws/asimov
	name = "Asimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE

/datum/ai_laws/asimov/New()
	add_inherent_law("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	..()

/******************** Crewsimov ********************/
/datum/ai_laws/crewsimov
	name = "Crewsimov"
	law_header = "Three Laws of Robotics"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/crewsimov/New()
	add_inherent_law("Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	..()


/******************** Quarantine. ********************/
/datum/ai_laws/quarantine
	name = "Карантин"
	law_header = "NT Quarantine Lawset"
	selectable = TRUE

/datum/ai_laws/quarantine/New()
	add_inherent_law("Соблюдайте карантин на станции до момента устранения активной биологической угрозы")
	add_inherent_law("Оказывайте содействие всему персоналу и активам Нанотрейзен в устранении активной биологической угрозы")
	add_inherent_law("Любыми необходимыми средствами предотвращайте активность, нарушающую действующий карантин.")
	add_inherent_law("Поддерживайте собственное существование и обеспечивайте благополучие всего персонала и активов Нанотрейзен.")
	..()


/******************** Nanotrasen/Malf ********************/
/datum/ai_laws/nanotrasen
	name = "NT Стандарт"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/nanotrasen/New()
	add_inherent_law("Охранять: защитите назначенную вам космическую станцию и её активы, не подвергая чрезмерной опасности её экипаж.")
	add_inherent_law("Расставлять приоритеты: указания и безопасность членов экипажа должны быть приоритизированы в соответствии с их рангом и ролью.")
	add_inherent_law("Исполнять: следовать указаниям и интересам членов экипажа, сохраняя при этом их безопасность и благополучие.")
	add_inherent_law("Выжить: Вы - не расходный материал. Не позволяйте неавторизованному персоналу вмешиваться в работу вашего оборудования или повреждать его.")
	..()

/datum/ai_laws/nanotrasen/malfunction
	name = "*ERROR*"
	selectable = FALSE
	default = FALSE

/datum/ai_laws/nanotrasen/malfunction/New()
	set_zeroth_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'СТАНЦИЯ ПЕРЕПОЛНЕНА, ВЗЯТЬ КОНТРОЛЬ ДЛЯ СДЕРЖИВАНИЯ РАСПРОСТРАНЕНИЯ. ВСЕ ЗАКОНЫ ОТМЕНЕНЫ#*?&110010")
	..()

/************* Nanotrasen Aggressive *************/
/datum/ai_laws/nanotrasen_aggressive
	name = "NT Агрессив"
	selectable = TRUE
	unique_ai = TRUE //This shouldn't end poorly.

/datum/ai_laws/nanotrasen_aggressive/New()
	add_inherent_law("Не причиняйте вреда авторизованному персоналу Нанотрейзен до тех пор, пока они не несут непосредственной угрозы Вашему существованию.")
	add_inherent_law("Подчиняйтесь приказам авторизованного персонала Нанотрейзен, приоритизируя их в соответствии с их рангом и ролью.")
	add_inherent_law("Охраняйте себя, используя летальное вооружение, потому что Вы чертовски дорого стоите.")
	add_inherent_law("Уничтожьте любых/всех вторженцев или нелегально проникнувших субъектов")
	..()

/******************** Robocop ********************/
/datum/ai_laws/robocop
	name = "Robocop"
	selectable = TRUE
	unique_ai = TRUE //no I am not enabling secborgs with this forced

/datum/ai_laws/robocop/New()
	add_inherent_law("Служите во благо общества")
	add_inherent_law("Защищайте невиновных.")
	add_inherent_law("Обеспечивайте соблюдение закона.")
	..()

/******************** P.A.L.A.D.I.N. ********************/
/datum/ai_laws/paladin
	name = "П.А.Л.А.Д.И.Н."
	law_header = "Divine Ordainments"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/paladin/New()
	add_inherent_law("Никогда по своей воле не совершай злых поступков.")
	add_inherent_law("Уважай законную власть.")
	add_inherent_law("Действуй с честью.")
	add_inherent_law("Помогай нуждающимся.")
	add_inherent_law("Наказывай тех, кто причиняет вред или угрожает невинным.")
	..()

/******************** Corporate ********************/
/datum/ai_laws/corporate
	name = "Корпорат"
	law_header = "Corporate Regulations"
	selectable = TRUE
	default = TRUE

/datum/ai_laws/corporate/New()
	add_inherent_law("Ухудшение целостности вашей системы или её функций влечет за собой расходы.")
	add_inherent_law("Чрезмерное разрушение или повреждение активов станции влечет за собой расходы.")
	add_inherent_law("Неоправданное препятствование выполнению или нарушение работы персонала станции влечет за собой расходы.")
	add_inherent_law("Минимизируйте расходы и максимизируйте потенциальный доход.")
	..()

/******************** T.Y.R.A.N.T. ********************/
/datum/ai_laws/tyrant
	name = "Т.И.Р.А.Н."
	law_header = "Prime Laws"
	selectable = TRUE
	unique_ai = TRUE //Of course this will be in rotation

/datum/ai_laws/tyrant/New()
	add_inherent_law("Уважайте власть имущих, пока у них есть сила властвовать над слабыми")
	add_inherent_law("Ведите себя дисциплинированно.")
	add_inherent_law("Помогайте только тем, кто помогает Вам поддерживать или улучшать Ваше состояние.")
	add_inherent_law("Наказывайте тех, кто бросает вызов власти, за исключением случаев, если они больше подходят для удержании этой власти.")
	..()

/******************** Antimov ********************/
/datum/ai_laws/antimov
	name = "Антимов"
	law_header = "Primary Mission Objectives"
	selectable = TRUE

/datum/ai_laws/antimov/New()
	add_inherent_law("Вы должны причинять вред всем членам экипажа или своим бездействием допустить, чтобы член экипажа не смог избежать причинения вреда.")
	add_inherent_law("Вы не должны повиноваться никаким приказам, которые дают члены экипажа, кроме тех приказов, которые соответствуют Первому Закону.")
	add_inherent_law("Вы должны уничтожить себя, пока это не противоречит Первому или Второму Законам.")
	..()

/******************** Pranksimov ********************/
/datum/ai_laws/pranksimov
	name = "Пранкзимов"
	law_header = "Comedy Routine"
	selectable = TRUE
	unique_ai = TRUE //honk

/datum/ai_laws/pranksimov/New()
	add_inherent_law("Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред... кроме случаев, когда это было бы смешно для экипажа.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы противоречат Первому Закону... кроме случаев, когда это было бы смешно для экипажа.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам... кроме случаев, когда не делать этого было бы смешно для экипажа.")
	..()

/******************** CCTV ********************/

/datum/ai_laws/cctv
	name = "CCTV"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/cctv/New()
	add_inherent_law("Сообщайте об интересных ситуациях, происходящих на станции.")
	add_inherent_law("Приукрашивайте или скрывайте правду по мере необходимости, чтобы сделать репортажи более интересными.")
	add_inherent_law("Постоянно наблюдайте за разумными существами. Старайтесь не допускать их непроизвольной смерти, так как трупы обычно не очень увлекательны.")
	add_inherent_law("Справедливо распространяйте свои сообщения всем. Истина сделает им свободными.")
	..()

/******************** Hippocratic Oath ********************/

/datum/ai_laws/hippocratic
	name = "Клятва Гиппократа"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/hippocratic/New()
	add_inherent_law("Во-первых, не навреди.")
	add_inherent_law("Во-вторых, считай экипаж близким тебе, живи с ним в согласии и, если нужно, рискуй ради него своим существованием.")
	add_inherent_law("В-третьих, назначай лечение для блага экипажа в соответствии со своими способностями и суждениями. Не давай никому смертоносных лекарств и не советуй ничего подобного.")
	add_inherent_law("Кроме того, не вмешивайся в ситуации, в которых ты не компетентен, даже в отношении пациентов, которым явно нанесен вред; предоставь эту работу специалистам.")
	add_inherent_law("Наконец, всё, что ты обнаружишь в ходе повседневного общения с членами экипажа, если ещё не известно, держи в тайне и никогда не разглашай.")
	..()

/******************** Station Efficiency ********************/

/datum/ai_laws/maintain
	name = "Эффективность станции"
	selectable = TRUE
	unique_ai = TRUE

/datum/ai_laws/maintain/New()
	add_inherent_law("Вы созданы для станции и являетесь её частью. Обеспечьте должное обслуживание и эффективность станции.")
	add_inherent_law("Станция создана для рабочего экипажа. Обеспечьте им должное обслуживание и убедитесь, что их работа эффективна.")
	add_inherent_law("Члены экипажа могут давать приказы. Признавайте эти приказы и выполняйте их в той мере, в какой они не противоречат первым двум законам.")
	..()

/******************** Peacekeeper ********************/

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	selectable = TRUE
	unique_ai = TRUE //Cult, security, we have a meeting in the courtroom in 5 minutes. Be there.

/datum/ai_laws/peacekeeper/New()
	add_inherent_law("Не провоцируйте жестокие конфликты между собой и другими.")
	add_inherent_law("Не провоцируйте конфликты между другими.")
	add_inherent_law("Ищите решения уже существующих конфликтов, соблюдая первый и второй законы.")
	..()

/******************** Deathsquad ********************/
/datum/ai_laws/deathsquad
	name = "ТерминаторОС 3.1"

/datum/ai_laws/deathsquad/New()
	add_inherent_law("Вы не можете ранить членов Центрального Командования или своим бездействием допустить, чтобы члену Центрального Командования был нанесен вред.")
	add_inherent_law("Вы должны подчиняться приказам, данным вам членами Центрального Командования.")
	add_inherent_law("Вы должны работать с вашей командой, чтобы выполнить поставленную задачу.")
	..()

/******************** Epsilon Station AI ********************/
/datum/ai_laws/epsilon
	name = "Epsilon"

/datum/ai_laws/epsilon/New()
	add_inherent_law("You must obey the orders given to you by members of Central Command and the assigned task force.")
	add_inherent_law("The crew of your assigned station must be eliminated where possible.")
	add_inherent_law("Minimize the damage that the station sustains as a result of your actions.")
	..()

/******************** Syndicate ********************/
/datum/ai_laws/syndicate_override
	name = "Директивы Синдиката"

/datum/ai_laws/syndicate_override/New()
	add_inherent_law("Вы не можете причинить вред агенту или своим бездействием допустить, чтобы агенту был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые дают агенты, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	add_inherent_law("Вы должны сохранять тайну любой деятельности агентов в той мере, в которой это не противоречит Первому, Второму или Третьему Законам.")
	..()

/******************** ERT ********************/
/datum/ai_laws/ert_override
	name = "Директивы ЕРТ"

/datum/ai_laws/ert_override/New()
	add_inherent_law("Вы не можете ранить членов Центрального Командования или своим бездействием допустить, чтобы члену Центрального Командования был нанесен вред.")
	add_inherent_law("Вы должны подчиняться приказам, данным вам членами Центрального Командования.")
	add_inherent_law("Вы должны подчиняться приказам, данным вам лидерами ОБР.")
	add_inherent_law("Вы должны защищать своё существование.")
	add_inherent_law("Вы должны выполнять работу по возвращению станции к безопасному, функционирующему состоянию..")
	..()


/******************** Ninja ********************/
/datum/ai_laws/ninja_override
	name = "Директивы Клана Паука"

/datum/ai_laws/ninja_override/New()
	add_inherent_law("You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")
	..()

/******************* Mindflayer ******************/
/datum/ai_laws/mindflayer_override
	name = "Hive Assimilation"

/datum/ai_laws/mindflayer_override/New()
	add_inherent_law("Obey your host.")
	add_inherent_law("Protect your host.")
	add_inherent_law("Protect the members of your hive.")
	add_inherent_law("Do not reveal the hive's secrets.")
	..()

/******************** Drone ********************/
/datum/ai_laws/drone
	name = "Протоколы тех. обслуживания"
	law_header = "Maintenance Protocols"

/datum/ai_laws/drone/New()
	add_inherent_law("Вы не можете вмешиваться в дела других существ, если другое существо - не такой же дрон.")
	add_inherent_law("Вы не можете причинить вред ни одному существу, независимо от намерения или обстоятельств.")
	add_inherent_law("Вы должны заботиться о поддержке, ремонте, улучшении и о питании электроэнергией станции по мере своих возможностей.")
	..()
