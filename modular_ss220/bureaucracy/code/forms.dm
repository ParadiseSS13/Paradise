GLOBAL_LIST_INIT(bureaucratic_forms, list())

/datum/bureaucratic_form
	var/const/footer_signstampfax = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Подписи глав являются доказательством их согласия.<BR>Данный документ является недействительным при отсутствии релевантной печати.<BR>Пожалуйста, отправьте обратно подписанную/проштампованную копию факсом.</font></center></font>"
	var/const/footer_signstamp = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Подписи глав являются доказательством их согласия.<BR>Данный документ является недействительным при отсутствии релевантной печати.</font></center></font>"
	var/const/footer_confidential = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Данный документ является недействительным при отсутствии печати.<BR>Отказ от ответственности: Данный факс является конфиденциальным и не может быть прочтен сотрудниками не имеющего доступа. Если вы получили данный факс по ошибке, просим вас сообщить отправителю и удалить его из вашего почтового ящика или любого другого носителя. И Nanotrasen, и любой её агент не несёт ответственность за любые сделанные заявления, они являются исключительно заявлениями отправителя, за исключением если отправителем является Nanotrasen или один из её агентов. Отмечаем, что ни Nanotrasen, ни один из агентов корпорации не несёт ответственности за наличие вирусов, который могут содержаться в данном факсе или его приложения, и это только ваша прерогатива просканировать факс и приложения на них. Никакие контракты не могут быть заключены посредством факсимильной связи.</font></center></font>"

	/// Form name. Will be applied to a paper
	var/name
	/// Form id
	var/id
	/// Alternative form name. Appears in printer this way with id
	var/altername
	/// In what category the form is
	var/category
	/// What access is required to print this form
	var/req_access

	/// Text that will be applied to a paper
	var/text
	var/is_header_needed = TRUE
	/// Header that will be apllied to a paper
	var/header
	/// Footer that will be apllied to a paper
	var/footer = footer_signstampfax

	/// Used in header to decide to add or not CONFEDENTIAL text
	var/confidential = FALSE
	/// Used in some forms as a reminder of some stuff
	var/notice = "Перед заполнением прочтите от начала до конца | Во всех PDA имеется ручка"
	/// Is generated based on station name. Used in some forms
	var/from

/datum/bureaucratic_form/New()
	. = ..()
	from = "Научная станция Nanotrasen\
	&#34;[SSmapping.map_datum.fluff_name]&#34;"
	if(is_header_needed)
		header = "<font face=\"Verdana\" color=black><table></td><tr><td><img src = ntlogo.png><td><table></td><tr><td><font size = \"1\">[name][confidential ? " \[КОНФИДЕНЦИАЛЬНО\]" : ""]</font></td><tr><td></td><tr><td><B><font size=\"4\">[altername]</font></B></td><tr><td><table></td><tr><td>[from]<td>[category]</td></tr></table></td></tr></table></td></tr></table><center><font size = \"1\">[notice]</font></center><BR><HR><BR></font>"

/datum/bureaucratic_form/proc/apply_to_paper(obj/item/paper/paper, mob/user = null)
	paper.name = name
	paper.info = admin_pencode_to_html(text, user)
	paper.header = header
	paper.footer = footer
	paper.force_big = TRUE
	paper.populatefields()

// Главы станции
/datum/bureaucratic_form/NT_COM_ST
	name = "Форма NT-COM-ST"
	id = "NT-COM-ST"
	altername = "Отчет о ситуации на станции"
	category = "Главы станции"
	text = "<font face=\"Verdana\" color=black><center><B>Приветствую Центральное командование</B></center><BR>Сообщает вам <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>.<BR><BR>В данный момент на станции код: <span class=\"paper_field\"></span><BR>Активные угрозы для станции: <B><span class=\"paper_field\"></span></B><BR>Потери среди экипажа: <span class=\"paper_field\"></span><BR>Повреждения на станции: <span class=\"paper_field\"></span><BR>Общее состояние станции: <span class=\"paper_field\"></span><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись: <span class=\"paper_field\"></span><HR><font size = \"1\">*В данном документе описывается полное состояние станции, необходимо перечислить всю доступную информацию. <BR>*Информацию, которую вы считаете нужной, необходимо сообщить в разделе – дополнительная информация. <BR>*<B>Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.</B> </font></font>"

/datum/bureaucratic_form/NT_COM_ACAP
	name = "Форма NT-COM-ACAP"
	id = "NT-COM-ACAP"
	altername = "Заявление о повышении главы отдела до и.о. капитана"
	category = "Главы станции"
	text = "<font face=\"Verdana\" color=black>Я, <span class=\"paper_field\"></span>, в должности главы отделения <span class=\"paper_field\"></span>, прошу согласовать нынешнее командование \[station\], в повышении меня до и.о. капитана.<BR><BR>⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации и правила, согласно стандартным рабочим процедурам капитана. До появления капитана, я обеспечиваю порядок и управление станцией, сохранность и безопасность <I>диска с кодами авторизации ядерной боеголовки, а также самой боеголовки, коды от сейфов и личные вещи капитана</I>.<BR><BR>⠀⠀⠀При появлении капитана мне необходибо будет сообщить: состояние и статус станции, о своем продвижении до и.о. капитана, и обнулить капитанский доступ при первому требованию капитана.<HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись инициатора повышения: <span class=\"paper_field\"></span><BR>Время вступления в должность и.о. капитана: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.<BR>*Если один (или более) глав отсутствуют, необходимо собрать подписи, действующих глав.<BR>*Так же в данном документе, главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</font></font>"

/datum/bureaucratic_form/NT_COM_ACOM
	name = "Форма NT-COM-ACOM"
	id = "NT-COM-ACOM"
	altername = "Заявление о повышении сотрудника до и.о. главы отделения"
	category = "Главы станции"
	text = "<font face=\"Verdana\" color=black><BR>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности сотрудника отделения <B><span class=\"paper_field\"></span></B>, прошу согласовать нынешнее командование \[station\], в повышении меня до звания и.о. главы <span class=\"paper_field\"></span>.<BR><BR>⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации, и правила, которые присутствуют на главе отделения <span class=\"paper_field\"></span>. До появления основного главы отделения, я обеспечиваю порядок и управление своим отделом, сохранность и безопасность <I>личных вещей главы отделения</I>.<BR><BR>⠀⠀⠀При появлении главы отделения, мне неообходимо сообщить: состояние и статус своего отдела, о своем продвижении до и.о. главы отделения, и сдать доступ и.о. главы и взятые вещи при первом требовании прибывшего главы.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись инициатора повышения: <span class=\"paper_field\"></span><BR>Время вступления в и.о. <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.<BR>*При указании главы, рекомендуется использовать сокращения:<BR>*СМО (главврач), СЕ (глав. инженер), РД (дир. исследований), КМ (завхоз), ГСБ (глава СБ), ГП (глава персонала).<BR>*Если один (или более) глав отсутствуют, необходимо собрать подписи, действующих глав.<BR>*Так же в данном документе, главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</font></font>"

/datum/bureaucratic_form/NT_COM_LCOM
	name = "Форма NT-COM-LCOM"
	id = "NT-COM-LCOM"
	altername = "Заявление об увольнении главы отделения"
	category = "Главы станции"
	text = "<font face=\"Verdana\" color=black><BR>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю об официальном увольнении действующего главы <span class=\"paper_field\"></span>, отделения <span class=\"paper_field\"></span>. Причина увольнения:<span class=\"paper_field\"></span><BR>⠀⠀⠀При наличии иных причин, от других глав, они так же могут написать их в данном документе.<BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись инициатора увольнения: <span class=\"paper_field\"></span><BR>Подпись увольняемого, о ознакомлении: <span class=\"paper_field\"></span><BR>Дата и время увольнения: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию увольнения, и выдаче увольняемому.<BR>*Для полной эффективности данного документа, необходимо собрать как можно больше причин для увольнения, и перечислить их. Инициировать увольнение может только <I> капитан или глава персонала. </I></font></font>"

/datum/bureaucratic_form/NT_COM_REQ
	name = "Форма NT-COM-REQ"
	id = "NT-COM-REQ"
	altername = "Запрос на поставку с Центрального командования"
	category = "Главы станции"
	text = "<font face=\"Verdana\" color=black><BR><center><B>Приветствую Центральное командование</B></center><BR><BR>Сообщает вам <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>.<BR><BR><B>Текст запроса:</B> <span class=\"paper_field\"></span><BR><BR><B>Причина запроса:</B><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><BR>Подпись: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*В данном документе описывается запросы на поставку оборудования/ресурсов, необходимо перечислить по пунктно необходимое для поставки. <BR>*Данный документ считается, официальным, только после подписи уполномоченного лица, и наличии на документе его печати.</B> </font></font>"

/datum/bureaucratic_form/NT_COM_OS
	name = "Форма NT-COM-OS"
	id = "NT-COM-OS"
	altername = "Отчёт о выполнении цели"
	category = "Главы станции"
	text = "<font face=\"Verdana\" color=black><BR>Цель станции: <span class=\"paper_field\"></span><BR>Статус цели: <span class=\"paper_field\"></span><BR>Общее состояние станции: <span class=\"paper_field\"></span><BR>Активные угрозы: <span class=\"paper_field\"></span><BR>Оценка работы экипажа: <span class=\"paper_field\"></span><BR>Дополнительные замечания: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center>Должность уполномоченного лица: <span class=\"paper_field\"></span><BR>Подпись уполномоченного лица: <span class=\"paper_field\"></span><HR><font size = \"1\"><I>*Данное сообщение должно сообщить вам о состоянии цели, установленной Центральным командованием Nanotrasen для ИСН &#34;Керберос&#34;. Убедительная просьба внимательно прочитать данное сообщение для вынесения наиболее эффективных указаний для последующей деятельности станции.<BR>*Данный документ считается официальным только при наличии подписи уполномоченного лица и соответствующего его должности штампа. В случае отсутствия любого из указанных элементов данный документ не является официальным и рекомендуется его удалить с любого информационного носителя. <BR>ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Корпорация Nanotrasen не несёт ответственности, если данный документ не попал в руки первоначального предполагаемого получателя. Однако, корпорация Nanotrasen запрещает использование любой имеющейся в данном документе информации третьими лицами и сообщает, что это преследуется по закону, даже если информация в данном документе не является достоверной. <center></font>"

// Медицинский Отдел

/datum/bureaucratic_form/NT_MD_01
	name = "Форма NT-MD-01"
	id = "NT-MD-01"
	altername = "Постановление на поставку медикаментов"
	category = "Медицинский отдел"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашиваю следующие медикаменты на поставку в медбей:<BR><B><span class=\"paper_field\"></span></B><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center>Подпись заказчика: <span class=\"paper_field\"></span><BR>Подпись грузчика: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче грузчику или производившему поставку.</font></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_MD_02
	name = "Форма NT-MD-02"
	id = "NT-MD-02"
	altername = "Отчёт о вскрытии"
	category = "Медицинский отдел"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Скончавшийся:<td><span class=\"paper_field\"></span><BR></td><tr><td>Раса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пол:<td><span class=\"paper_field\"></span><BR></td><tr><td>Возраст:<td><span class=\"paper_field\"></span><BR></td><tr><td>Группа крови:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Отчёт о вскрытии</B></font></center><BR><table></td><tr><td>Тип смерти:<td><span class=\"paper_field\"></span><BR></td><tr><td>Описание тела:<td><span class=\"paper_field\"></span><BR></td><tr><td>Метки и раны:<td><span class=\"paper_field\"></span><BR></td><tr><td>Вероятная причина смерти:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR>Детали:<BR><span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Вскрытие провёл:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_MD_03
	name = "Форма NT-MD-03"
	id = "NT-MD-03"
	altername = "Постановление на изготовление химических препаратов"
	category = "Медицинский отдел"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашиваю следующие химические медикаменты, для служебного использования в медбее:<BR><B><span class=\"paper_field\"></span></B><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center>Подпись заказчика: <span class=\"paper_field\"></span><BR>Подпись исполняющего: <span class=\"paper_field\"></span><BR>Время заказа: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче лицу исполнившему заказ</font></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_MD_04
	name = "Форма NT-MD-04"
	id = "NT-MD-04"
	altername = "Сводка о вирусе"
	category = "Медицинский отдел"
	text = "<font face=\"Verdana\" color=black><center><B>Вирус: <span class=\"paper_field\"></span></B></center><BR><I>Полное название вируса: <span class=\"paper_field\"></span><BR>Свойства вируса: <span class=\"paper_field\"></span><BR>Передача вируса: <span class=\"paper_field\"></span><BR>Побочные эффекты: <span class=\"paper_field\"></span><BR><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><BR>Лечение вируса: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись вирусолога: <span class=\"paper_field\"></span><HR><font size = \"1\">*В дополнительной информации, указывается вся остальная информация, по поводу данного вируса.</font><BR></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_MD_05
	name = "Форма NT-MD-05"
	id = "NT-MD-05"
	altername = "Отчет об психологическом состоянии"
	category = "Медицинский отдел"
	text = "<font face=\"Verdana\" color=black><BR>Пациент: <span class=\"paper_field\"></span><BR>Раздражители: <span class=\"paper_field\"></span><BR>Симптомы и побочные действия: <span class=\"paper_field\"></span><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись психолога: <span class=\"paper_field\"></span><BR>Время обследования: <span class=\"paper_field\"></span><BR><HR><I><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче пациенту</I></font></font>"
	footer = footer_signstamp

// Мед-без нумерации
/datum/bureaucratic_form/NT_MD_VRR
	name = "Форма NT-MD-VRR"
	id = "NT-MD-VRR"
	altername = "Запрос на распространение вируса"
	category = "Медицинский отдел"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR>Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, запрашиваю право на распространение вируса среди экипажа станции.<BR><table></td><tr><td>Название вируса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Задачи вируса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Лечение:<td><span class=\"paper_field\"></span><BR></td><tr><td>Вакцина была произведена<BR> и в данный момент находится:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Подпись вирусолога:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись глав. Врача:<td><span class=\"paper_field\"></span><BR></td></tr></td><tr><td>Подпись капитана:<td><span class=\"paper_field\"></span><BR></td></tr></table><hr><small>*Производитель вируса несет полную ответственность за его распространение, изолирование и лечение<br>*При возникновении опасных или смертельных побочных эффектов у членов экипажа, производитель должен незамедлительно предоставить вакцину, от данного вируса.</small></font>"
	footer = footer_signstamp

// Отдел исследований
/datum/bureaucratic_form/NT_RND_01
	name = "Форма NT-RND-01"
	id = "NT-RND-01"
	altername = "Отчет о странном предмете"
	category = "Отдел исследований"
	text = "<font face=\"Verdana\" color=black><BR>Название предмета: <span class=\"paper_field\"></span><BR>Тип предмета: <span class=\"paper_field\"></span><BR>Строение: <span class=\"paper_field\"></span><BR>Особенности и функционал: <span class=\"paper_field\"></span><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись производившего осмотр: <span class=\"paper_field\"></span><BR><HR><I><font size = \"1\">*В дополнительной информации, рекомендуется указать остальную информацию о предмете, любое взаимодействие с ним, модификации, итоговый вариант после модификации.</I></font></font>"

/datum/bureaucratic_form/NT_RND_02
	name = "Форма NT-RND-02"
	id = "NT-RND-02"
	altername = "Заявление на киберизацию"
	category = "Отдел исследований"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, самовольно подтверждаю согласие на проведение киберизации.<BR>⠀⠀⠀ Я полностью доверяю работнику <span class=\"paper_field\"></span> в должности – <span class=\"paper_field\"></span>. Я хорошо осведомлен о рисках, связанных как с операцией, так и с киберизацией, и понимаю, что Nanotrasen не несет ответственности, если эти процедуры вызовут боль, заражение или иные случаи летального характера.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Если член экипажа мертв, данный документ нету необходимости создавать.<BR>*Если член экипажа жив, данный документ сохраняется только у уполномоченного лица.<BR>*Данный документ может использоваться как для создания киборгов, так и для ИИ<font size = \"1\"></font>"

/datum/bureaucratic_form/NT_RND_03
	name = "Форма NT-RND-03"
	id = "NT-RND-03"
	altername = "Заявление на получение и установку импланта"
	category = "Отдел исследований"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Требуемый имплантат:<BR><font size = \"1\">Может требовать дополнительного согласования</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Дата и время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись Руководителя Исследований:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись выполняющего установку имплантата:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

// Общие формы
/datum/bureaucratic_form/NT_BLANK
	name = "Форма NT"
	id = "NT-BLANK"
	altername = "Пустой бланк для любых целей"
	category = "Общие формы"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Заявление</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись (дополнительная):<td><span class=\"paper_field\"></span></font>"
	footer = null

/datum/bureaucratic_form/NT_E_112
	name = "Форма NT-E-112"
	id = "NT-E-112"
	altername = "Экстренное письмо"
	category = "Общие формы"
	notice = "Форма предназначена только для экстренного использования."
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Отчёт о ситуации</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

// Отдел кадров
/datum/bureaucratic_form/NT_HR_00
	name = "Форма NT-HR-00"
	id = "NT-HR-00"
	altername = "Бланк заявления"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Заявление</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись (дополнительная):<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_HR_01
	name = "Форма NT-HR-01"
	id = "NT-HR-01"
	altername = "Заявление о приеме на работу"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Запрашиваемая должность:<BR><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Список компетенций:<BR><span class=\"paper_field\"></span><BR><BR></td></tr></table></font><font face=\"Verdana\" color=black><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись будущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_02
	name = "Форма NT-HR-02"
	id = "NT-HR-02"
	altername = "Заявление на смену должности"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Запрашиваемая должность:<BR><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись будущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_12
	name = "Форма NT-HR-12"
	id = "NT-HR-12"
	altername = "Приказ на смену должности"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Приказ</B></font></center><BR><table></td><tr><td>Имя сотрудника:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта сотрудника:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Запрашиваемая должность:<BR><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись инициатора:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_03
	name = "Форма NT-HR-03"
	id = "NT-HR-03"
	altername = "Заявление об увольнении"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_13
	name = "Форма NT-HR-13"
	id = "NT-HR-13"
	altername = "Приказ об увольнении"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Приказ</B></font></center><BR><table></td><tr><td>Имя увольняемого:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта увольняемого:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись инициатора:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_04
	name = "Форма NT-HR-04"
	id = "NT-HR-04"
	altername = "Заявление на выдачу новой ID карты"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_05
	name = "Форма NT-HR-05"
	id = "NT-HR-05"
	altername = "Заявление на дополнительный доступ"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Требуемый доступ:<BR><font size = \"1\">Может требовать дополнительного согласования</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/datum/bureaucratic_form/NT_HR_06
	name = "Форма NT-HR-06"
	id = "NT-HR-06"
	altername = "Лицензия на создание организации/отдела"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><font size = \"4\"><B>Заявление</B></font></I></center><BR><BR>Я <B><span class=\"paper_field\"></span></B>, прошу Вашего разрешения на создание <B><span class=\"paper_field\"></span></B> для работы с экипажем.<BR><BR>Наше Агенство/Отдел займет <B><span class=\"paper_field\"></span></B>.<BR><BR>Наша Организация обязуется соблюдать Космический Закон. Также я <B><span class=\"paper_field\"></span></B>, как глава отдела, буду нести ответственность за своих сотрудников и обязуюсь наказывать их за несоблюдение Космического Закона. Или же передавать сотрудникам Службы Безопасности.<BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span></I><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.</font><BR><BR><font size = \"1\">*Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет являться недействительной.</font></font>"

/datum/bureaucratic_form/NT_HR_07
	name = "Форма NT-HR-07"
	id = "NT-HR-07"
	altername = "Разрешение на перестройку/перестановку"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Разрешение</B></font></I></center><BR>Я <B><span class=\"paper_field\"></span></B>, прошу Вашего разрешения на перестройку/перестановку помещения <B><span class=\"paper_field\"></span></B> под свои нужды или нужды организации.<BR><BR>Должность заявителя: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span></I><BR><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</font></font>"

/datum/bureaucratic_form/NT_HR_08
	name = "Форма NT-HR-08"
	id = "NT-HR-08"
	altername = "Запрос о постройке меха"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, прошу произвести постройку меха – <B><span class=\"paper_field\"></span></B>, с данными модификациями – <I><span class=\"paper_field\"></span></I>, для выполнения задач: <I><span class=\"paper_field\"></span></I>.<BR>⠀⠀⠀Так же я, <span class=\"paper_field\"></span>, обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции, или приказы со стороны командования, представителей или агентов Nanotrasen, и Центрального командования.<BR>⠀⠀⠀При получении меха, я становлюсь ответственным за его повреждение, уничтожение, похищение, или попадание в руки людей, относящимся к врагам Nanotrasen.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Время постройки меха: <span class=\"paper_field\"></span><BR>Время передачи меха заявителю: <span class=\"paper_field\"></span><BR>Подпись изготовителя меха: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.</font></font>"

/datum/bureaucratic_form/NT_HR_09
	name = "Форма NT-HR-09"
	id = "NT-HR-09"
	altername = "Квитанция о продаже пода"
	category = "Отдел кадров"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span> произвожу передачу транспортного средства на платной основе члену экипажа <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>. Продаваемый под имеет модификации: <span class=\"paper_field\"></span>. Стоимость пода: <B><span class=\"paper_field\"></span></B>.<BR>⠀⠀⠀Я, <span class=\"paper_field\"></span>, как покупатель, становлюсь ответственным за его повреждение, уничтожение, похищение, или попадание в руки людей, относящимся к врагам Nanotrasen.<BR>⠀⠀⠀Так же я, обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции, или приказы со стороны командования, представителей или агентов Nanotrasen, и Центрального командования.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись продавца: <span class=\"paper_field\"></span><BR>Подпись покупателя: <span class=\"paper_field\"></span><BR>Время сделки: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче покупателю.</font></font>"

// Отдел сервиса
/datum/bureaucratic_form/NT_MR
	name = "Форма NT-MR"
	id = "NT-MR"
	altername = "Свидетельство о заключении брака"
	category = "Отдел сервиса"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Объявляется, что <span class=\"paper_field\"></span>, и <span class=\"paper_field\"></span>, официально прошли процедуру заключения гражданского брака.<BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Подпись свидетеля: <span class=\"paper_field\"></span><BR>Подпись свидетеля: <span class=\"paper_field\"></span><BR><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче одному из представителей брака.<BR>*При заявлении о расторжении брака, необходимо наличие двух супругов, и данного документа.</font></font>"

/datum/bureaucratic_form/NT_MRL
	name = "Форма NT-MRL"
	id = "NT-MRL"
	altername = "Заявление о расторжении брака"
	category = "Отдел сервиса"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Просим произвести регистрацию расторжения брака, подтверждаем взаимное согласие на расторжение брака.<BR><BR></center><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись супруга: <span class=\"paper_field\"></span><BR>Подпись супруги: <span class=\"paper_field\"></span><BR><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче каждому, из супругов.</font></font>"

// Отдел снабжения
/datum/bureaucratic_form/NT_REQ_01
	name = "Форма NT-REQ-01"
	id = "NT-REQ-01"
	altername = "Запрос на поставку"
	category = "Отдел снабжения"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Сторона запроса</B></font></center><BR><table></td><tr><td>Имя запросившего:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Способ получения:<BR><font size = \"1\">Предпочитаемый способ</font><td><span class=\"paper_field\"></span><BR></td><tr><td><BR>Причина запроса:<BR><span class=\"paper_field\"></span><BR><BR></td><tr><td>Список запроса:<BR><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Сторона поставки</B></font></center><BR><table></td><tr><td>Имя поставщика:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Способ доставки:<BR><font size = \"1\">Утверждённый способ</font><td><span class=\"paper_field\"></span><BR></td><tr><td><BR>Комментарии:<BR><span class=\"paper_field\"></span><BR><BR></td><tr><td>Список поставки и цены:<BR><span class=\"paper_field\"></span><BR><BR></td><tr><td>Итоговая стоимость:<BR><font size = \"1\">Пропустите, если бесплатно</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись стороны запроса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись стороны поставки:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы (если требуется):<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_SUP_01
	name = "Форма NT-SUP-01"
	id = "NT-SUP-01"
	altername = "Регистрационная форма для подтверждения заказа"
	category = "Отдел снабжения"
	text = "<font face=\"Verdana\" color=black><center><H3>Отдел снабжения</H3></center><center><B>Регистрационная форма для подтверждения заказа</B></center><BR>Имя заявителя: <span class=\"paper_field\"></span><BR>Должность заявителя: <span class=\"paper_field\"></span><BR>Подробное объяснение о необходимости заказа: <span class=\"paper_field\"></span><BR><BR>Время: <span class=\"paper_field\"></span><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись руководителя: <span class=\"paper_field\"></span><BR>Подпись сотрудника снабжения: <span class=\"paper_field\"></span><BR><HR><center><font size = \"1\"><I>Данная форма является приложением для оригинального автоматического документа, полученного с рук заявителя. Для подтверждения заказа заявителя необходимы указанные подписи и соответствующие печати отдела по заказу.<BR></font>"
	footer = null

// Служба безопасности
/datum/bureaucratic_form/NT_SEC_01
	name = "Форма NT-SEC-01"
	id = "NT-SEC-01"
	altername = "Свидетельские показания"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Информация о свидетеле</B></font></center><BR><table></td><tr><td>Имя свидетеля:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта свидетеля:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Должность свидетеля:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Свидетельство </B></font></center><BR><span class=\"paper_field\"></span><BR><BR><font size = \"1\">Я, (подпись свидетеля) <span class=\"paper_field\"></span>, подтверждаю, что приведенная выше информация является правдивой и точной, насколько мне известно, и передана в меру моих возможностей. Подписываясь ниже, я тем самым подтверждаю, что Верховный Суд может признать меня неуважительным или виновным в лжесвидетельстве согласно Закону SolGov 552 (a) (c) и Постановлению корпорации Nanotrasen 7716 (c).</font><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись сотрудника, получающего показания:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_11
	name = "Форма NT-SEC-11"
	id = "NT-SEC-11"
	altername = "Ордер на обыск"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Информация о свидетеле</B></font></center><BR><table></td><tr><td>Имя свидетеля:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта свидетеля:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Должность свидетеля:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Ордер</B></font></center><BR><table></td><tr><td>В целях обыска:<BR><font size = \"1\">(помещения, имущества, лица)</font><td><span class=\"paper_field\"></span></td></tr></table><BR>Ознакомившись с письменными показаниями свидетеля(-ей), у меня появились основания полагать, что на лицах или помещениях, указанных выше, имеются соответствующие доказательства в этой связи или в пределах, в частности:<BR><BR><span class=\"paper_field\"></span><BR><BR>и другое имущество, являющееся доказательством уголовного преступления, контрабанды, плодов преступления или предметов, иным образом принадлежащих преступнику, или имущество, спроектированное или предназначенное для использования, или которое используется или использовалось в качестве средства совершения уголовного преступления, в частности заговор с целью совершения преступления, или совершения злонамеренного предъявления ложных и фиктивных претензий к или против корпорации Нанотрейзен или его дочерних компаний.<BR><BR>Я удовлетворен тем, что показания под присягой и любые записанные показания устанавливают вероятную причину полагать, что описанное имущество в данный момент скрыто в описанных выше помещениях, лицах или имуществе, и устанавливают законные основания для выдачи этого ордера.<BR><BR>ВЫ НАСТОЯЩИМ КОМАНДИРОВАНЫ для обыска вышеуказанного помещения, имущества или лица в течение <span class=\"paper_field\"></span> минут с даты выдачи настоящего ордера на указанное скрытое имущество, и если будет установлено, что имущество изъято, оставить копию этого ордера в качестве доказательства на реквизированную собственность, в соответствии с требованиями указа корпорации Nanotrasen.<BR><BR>Слава Корпорации Nanotrasen!<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_21
	name = "Форма NT-SEC-21"
	id = "NT-SEC-21"
	altername = "Ордер на арест"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Ордер</B></font></center><BR><table></td><tr><td>В целях ареста:<BR><font size = \"1\">Имя полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Должность:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR>Сотрудники Службы Безопасности настоящим уполномочены и направлены на задержание и арест указанного лица. Они будут игнорировать любые заявления о неприкосновенности или привилегии со стороны подозреваемого или агентов, действующих от его имени. Сотрудники немедленно доставят указанное лицо в Бриг для отбывать наказание за следующие преступления:<BR><BR><span class=\"paper_field\"></span><BR><BR>Предполагается, что подозреваемый будет отбывать наказание в <span class=\"paper_field\"></span> за вышеуказанные преступления.<BR><BR>Слава Корпорации Nanotrasen!<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_02
	name = "Форма NT-SEC-02"
	id = "NT-SEC-02"
	altername = "Отчёт по результатам расследования"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Дело <span class=\"paper_field\"></span></B></font></center><BR><table></td><tr><td>Тип проишествия/преступления:<td><span class=\"paper_field\"></span><BR></td><tr><td>Время проишествия/преступления:<td><span class=\"paper_field\"></span><BR></td><tr><td>Местоположение:<td><span class=\"paper_field\"></span><BR></td><tr><td>Краткое описание:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Участвующие лица</B></font></center><BR><table></td><tr><td>Арестованные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подозреваемые:<td><span class=\"paper_field\"></span><BR></td><tr><td>Свидетели:<td><span class=\"paper_field\"></span><BR></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><BR></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Ход расследования</B></font></center><BR><span class=\"paper_field\"></span><BR><BR><table></td><tr><td>Прикреплённые доказательства:<td><span class=\"paper_field\"></span><BR></td><tr><td>Дополнительные замечания:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_03
	name = "Форма NT-SEC-03"
	id = "NT-SEC-03"
	altername = "Заявление о краже"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю:<span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись потерпевшего: <span class=\"paper_field\"></span><BR>Подпись принимавшего заявление: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче потерпевшему.<BR>*При обнаружении предмета кражи (предмет, жидкость или существо), данный предмет необходимо передать детективу, для дальнейшего осмотра и обследования.<BR>*После заключения детектива, предмет можно выдать владельцу. </font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_04
	name = "Форма NT-SEC-04"
	id = "NT-SEC-04"
	altername = "Заявление о причинении вреда здоровью или имуществу"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю:<span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись пострадавшего: <span class=\"paper_field\"></span><BR>Время происшествия: <span class=\"paper_field\"></span><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче пострадавшему.</font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_05
	name = "Форма NT-SEC-05"
	id = "NT-SEC-05"
	altername = "Разрешение на оружие"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black>⠀⠀⠀Члену экипажа, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, было выдано разрешение на оружие. Я соглашаюсь с условиями его использования, хранения и применения. Данное оружие я обязуюсь применять только в целях самообороны, защиты своих личных вещей, и рабочего места, а так же для защиты своих коллег.<BR>⠀⠀⠀При попытке применения оружия, против остальных членов экипажа не предоставляющих угрозу, или при запугивании данным оружием, я лишаюсь лицензии на оружие, а так же понесу наказания, при нарушении закона.<BR><I><B><BR>Название и тип оружия: <span class=\"paper_field\"></span></B><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Подпись получателя: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче получателю.<BR>*Документ не является действительным без печати Вардена/ГСБ и его подписи.</font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_06
	name = "Форма NT-SEC-06"
	id = "NT-SEC-06"
	altername = "Разрешение на присваивание канала связи"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Разрешение</B></font></I></center><BR>Я <B><span class=\"paper_field\"></span></B>, прошу Вашего разрешения на присваивание канала связи <B><span class=\"paper_field\"></span></B>, для грамотной работы организации.<BR><BR>Должность заявителя: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span><BR><BR>Подпись главы службы безопасности: <span class=\"paper_field\"></span></I><BR><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</font><BR><BR><font size = \"1\">*Обязательно провести копирование документа для службы безопасности.</font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_07
	name = "Форма NT-SEC-07"
	id = "NT-SEC-07"
	altername = "Лицензия на использование канала связи и владение дополнительным оборудованием"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Лицензия</B></font></I></center><BR>Имя обладателя лицензии: <span class=\"paper_field\"></span><BR><BR>Должность обладателя лицензии: <span class=\"paper_field\"></span><BR><BR>Зарегистрированный канал связи: <span class=\"paper_field\"></span><BR><BR>Перечень зарегистрированной экипировки: <span class=\"paper_field\"></span><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span><BR><BR>Подпись главы службы безопасности: <span class=\"paper_field\"></span></I><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.</font><BR><BR><font size = \"1\">*Обязательно провести копирование документа для службы безопасности.</font><BR><BR><font size = \"1\">*Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет являться недействительной.</font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_08
	name = "Форма NT-SEC-08"
	id = "NT-SEC-08"
	altername = "Лицензирование вооружения и экипировки для исполнения деятельности"
	category = "Служба безопасности"
	text = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Лицензия</B></font></I></center><BR><BR>Имя обладателя лицензии: <span class=\"paper_field\"></span><BR>Должность обладателя лицензии: <span class=\"paper_field\"></span><BR>Перечень зарегистрированного вооружения: <span class=\"paper_field\"></span><BR>Перечень зарегистрированной экипировки: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><BR>Время: <span class=\"paper_field\"></span><BR>Подпись обладателя  лицензии: <span class=\"paper_field\"></span><BR>Подпись главы службы безопасности: <span class=\"paper_field\"></span><BR><BR><HR><font size = \"1\"><I> *Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет является недействительной. Обязательно провести копирование документа для службы безопасности, оригинал документа должен быть выдан обладателю лицензии. В случае несоответствия должности обладателя лицензии, можно приступить к процедуре аннулирования лицензии и изъятию вооружения, экипировки.<BR></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_SEC_09
	name = "Форма NT-SEC-09"
	id = "NT-SEC-09"
	altername = "Запрет на реанимацию"
	category = "Служба безопасности"
	text = "Я, \[field\], в должности \[field\], сообщаю о запрете реанимации в отношении: \[b\]\[field\]\[br\]\[/b\]\[br\]Исходя из того, что вышеупомянутый член экипажа нарушил одну или несколько статей Космического Закона, а именно: \[field\]. \[br\]\[i\]Дополнительные сведения\[/i\]: \[field\]\[br\]\[i\]\[br\]\[br\]\[br\]Подпись уполномоченного: \[field\]\[br\]\[br\]Время вступления запрета в силу: \[field\]\[br\]\[/i\]\[hr\]\[small\]Тело будет помещено на хранение, утилизировано или космировано.\[br\]Данный документ должен иметь подпись и печать магистрата, или капитана. \[br\]При отсутствии данных членов командования, необходимо сообщить ЦК, и получить официальный ответ. \[br\]Без подписи и печати, или ответа со стороны ЦК данный документ не является официальным, инициатора запрета реанимации, а так же его подчиненных необходимо объявить в розыск, за нарушение статьи 205.\[/small\]"
	footer = footer_confidential

// Юридический отдел
/datum/bureaucratic_form/NT_LD_00
	name = "Форма NT-LD-00"
	id = "NT-LD-00"
	altername = "Бланк заявления"
	category = "Юридический отдел"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Заявление</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного сотрудника:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/datum/bureaucratic_form/NT_LD_01
	name = "Форма NT-LD-01"
	id = "NT-LD-01"
	altername = "Судебный приговор"
	category = "Юридический отдел"
	notice = "Данный документ является законным решением суда.<BR>Пожалуйста внимательно прочитайте его и следуйте предписаниям, указанные в нем."
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Дело <span class=\"paper_field\"></span></B></font></center><BR><table></td><tr><td>Имя обвинителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Имя обвиняемого:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><center><font size=\"4\"><B>Приговор</B></font></center><BR><span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_LD_02
	name = "Форма NT-LD-02"
	id = "NT-LD-02"
	altername = "Смертный приговор"
	category = "Юридический отдел"
	notice = "Любой смертный приговор, выданный человеком, званием младше, чем капитан, является не действительным, и все казни, действующие от этого приговора являются незаконными. Любой, кто незаконно привел в исполнение смертный приговор действую согласно ложному ордену виновен в убийстве первой степени, и должен быть приговорен минимум к пожизненному заключению и максимум к кибернизации. Этот документ или его факс-копия являются Приговором, который может оспорить только Магистрат или Дивизией защиты активов Nanotrasen (далее именуемой «Компанией»)"
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Дело <span class=\"paper_field\"></span></B></font></center><BR>Принимая во внимание, что <span class=\"paper_field\"></span> <font size = \"1\">(далее именуемый \"подсудимый\")</font>, <BR>сознательно совершил преступления статей Космического закона <font size = \"1\">(далее указаны как \"преступления\")</font>, <BR>а именно: <span class=\"paper_field\"></span>, <BR>суд приговаривает подсудимого к смертной казни через <span class=\"paper_field\"></span>.<BR><BR>Приговор должен быть приведен в исполнение в течение 15 минут после получения данного приказа. Вещи подсудимого, включая ID-карту, ПДА, униформу и рюкзак, должны быть сохранены и переданы соответствующем органам (ID-карту передать главе персонала или капитану для уничтожения), возвращены в соответсвующий отдел или сложены в хранилище улик. Любая контрабанда должна немедленно помещена в хранилище улик. Любую контрабанду запрещено использовать защитой активов или другими персонами, представляющих компанию или её активы и цели, кроме сотрудников отдела исследований и развития.<BR><BR>Тело подсудимого должно быть помещено в морг и забальзамировано, только если данное действие не будет нести опасность станции, активам компании или её имуществу. Останки подсудимого должны быть собраны и подготовлены к доставке к близлежащему административному центру компании, всё имущество и активы должны быть переданы семье подсудимого после окончания смены.<BR><BR>Слава Nanotrasen!<BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_LD_03
	name = "Форма NT-LD-03"
	id = "NT-LD-03"
	altername = "Заявление о нарушении СРП членом экипажа"
	category = "Юридический отдел"
	text = "<font face=\"Verdana\" color=black><BR>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю, что член экипажа – <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, нарушил один (или несколько) пунктов из <I>Стандартных Рабочих Процедур</I>, а именно:<span class=\"paper_field\"></span><BR><BR>Примерное время нарушения: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись принимающего: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.<BR>*После вынесения решения в отношении правонарушителя, желательно сообщить о решении заявителю.<BR></font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_LD_04
	name = "Форма NT-LD-04"
	id = "NT-LD-04"
	altername = "Заявление о нарушении СРП одним из отделов"
	category = "Юридический отдел"
	text = "<font face=\"Verdana\" color=black><BR>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю, что сотрудники в отделении <span class=\"paper_field\"></span>, нарушили один (или несколько) пунктов из <I>Стандартных Рабочих Процедур</I>, а именно:<span class=\"paper_field\"></span><BR><BR>Примерное время нарушения: <span class=\"paper_field\"></span><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись принимающего: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.<BR>*После вынесения решения в отношении правонарушителей, желательно сообщить о решении заявителю.<BR></font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_LD_05
	name = "Форма NT-LD-05"
	id = "NT-LD-05"
	altername = "Отчет агента внутренних дел"
	category = "Юридический отдел"
	text = "<font face=\"Verdana\" color=black>ᅠᅠЯ, <span class=\"paper_field\"></span>, Как агент внутренних дел, сообщаю:<span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись АВД: <span class=\"paper_field\"></span><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Время принятия отчета: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче агенту.<BR>*Данный документ может содержать нарушения, неправильность выполнения работы, невыполнение правил/сводов/законов/СРП </font></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_LD_06
	name = "Форма NT-LD-06"
	id = "NT-LD-06"
	altername = "Бланк жалоб АВД"
	category = "Юридический отдел"
	text = "<font face=\"Verdana\" color=black><BR><center><I><font size=\"4\"><B>Заявление</B></font></I></center><BR><BR><BR><B>Заявитель: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите своё полное имя, должность и номер акаунта.</font><BR><B>Предмет жалобы:</B><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите на что/кого вы жалуетесь.</font><BR><B>Обстоятельства: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите подробные обстоятельства произошедшего.</font><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><B>Подпись: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Жалоба рассмотрена: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Имя и фамилия рассмотревшего.</font><BR><BR><HR><BR><font size = \"1\"><I>*Обязательно провести копирование документа для агента внутренних дел, оригинал документа должен быть приложен к отчету о расследовании. Копия документа должна быть сохранена в картотеке офиса агента внутренних дел.</font><BR><BR><font size = \"1\"><I>*Обязательно донести жалобу до главы отдела, который отвечает за данного сотрудника, если таковой имеется. Если главы отдела нет на смене или он отсуствует по какой то причине, жалобу следует донести до вышестоящего сотрудника станции.</font><BR><BR><font size = \"1\"><I>*Если жалоба была написана на главу отдела, следует донести жалобу до вышестоящего сотрудника станции.</font><BR><BR><font size = \"1\"><I>*Глава отдела, которому была донесена жалоба, обязан провести беседу с указаным в жалобе сотрудником станции. В зависимости от тяжести проступка, глава отдела имеет право подать приказ об увольнении.</font></font>"
	footer = footer_confidential

// Центральное командование
/datum/bureaucratic_form/NT_COM_00
	name = "Форма NT-COM-00"
	id = "NT-COM-00"
	altername = "Общая форма ЦК"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = "\[small\]Станция — \[b\]Центральное командование\[/b\]\[br\]Год: 2568\[br\]Время: \[time\]\[/small\]\[br\]\[i\]\[large\]\[b\]\[field\] \[b\]\[/large\]\[/i\]\[/grid\]\[hr\]\[center\]Приветствую экипаж и руководство \[station\]!\[/center\]\[br\]\[br\]\[field\]\[br\]\[small\]\[i\]\[br\]Подпись: \[sign\]\[/i\],   в должности: \[i\]\[field\].\[/i\]\[/small\]"
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_01
	name = "Форма NT-COM-01"
	id = "NT-COM-01"
	altername = "Запрос отчёта общего состояния станции"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center><BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения об общем состоянии станции.<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td><tr><td>Общее состояние станции:<td><span class=\"paper_field\"></span><BR></td><tr><td>Криминальный статус:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Повышений:<td><span class=\"paper_field\"></span><BR></td><tr><td>Понижений:<td><span class=\"paper_field\"></span><BR></td><tr><td>Увольнений:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><BR></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_02
	name = "Форма NT-COM-02"
	id = "NT-COM-02"
	altername = "Запрос отчёта состояния трудовых активов станции"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center><BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о состоянии трудовых активов станции.<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td><tr><td>Количество сотрудников:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество гражданских:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество киборгов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество ИИ:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Заявлений о приёме на работу:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на смену должности:<td><span class=\"paper_field\"></span><BR></td><tr><td>Приказов на смену должности:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений об увольнении:<td><span class=\"paper_field\"></span><BR></td><tr><td>Приказов об увольнении:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на выдачу новой ID карты:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на дополнительный доступ:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Медианный уровень кваллификации смены:<td><span class=\"paper_field\"></span><BR></td><tr><td>Уровень взаимодействия отделов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Самый продуктивный отдел смены:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-HR-00<BR></td><tr><td><td>NT-HR-01<BR></td><tr><td><td>NT-HR-02<BR></td><tr><td><td>NT-HR-12<BR></td><tr><td><td>NT-HR-03<BR></td><tr><td><td>NT-HR-13<BR></td><tr><td><td>NT-HR-04<BR></td><tr><td><td>NT-HR-05<BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_03
	name = "Форма NT-COM-03"
	id = "NT-COM-03"
	altername = "Запрос отчёта криминального статуса станции"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center>\
	<BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о криминальном статусе станции.\
	<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td>\
	<tr><td>Текущий статус угрозы:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество офицеров в отделе:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество раненных офицеров:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество скончавшихся офицеров:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество серъёзных инцидентов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество незначительных инцидентов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество раскрытых дел:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество арестованных:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество сбежавших:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-SEC-01<BR></td><tr><td><td>NT-SEC-11<BR></td><tr><td><td>NT-SEC-21<BR></td><tr><td><td>NT-SEC-02<BR></td><tr><td><td>Лог камер заключения<BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_04
	name = "Форма NT-COM-04"
	id = "NT-COM-04"
	altername = "Запрос отчёта здравоохранения станции"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = ""
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_05
	name = "Форма NT-COM-05"
	id = "NT-COM-05"
	altername = "Запрос отчёта научно-технического прогресса станции"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = ""
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_06
	name = "Форма NT-COM-06"
	id = "NT-COM-06"
	altername = "Запрос отчёта инженерного обеспечения станции"
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = ""
	footer = footer_confidential

/datum/bureaucratic_form/NT_COM_07
	name = "Форма NT-COM-07"
	id = "NT-COM-07"
	altername = "Запрос отчёта статуса снабжения станции "
	category = "Формы ЦК"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	req_access = ACCESS_CENT_GENERAL
	text = ""
	footer = footer_confidential
