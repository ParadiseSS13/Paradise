/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by it's charge, ever vigilant."
	speak_emote = list("intones")
	tts_seed = "Earth"
	bubble_icon = "guardian"
	response_help  = "gently pets"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = INTENT_HARM
	can_change_intents = 0
	stop_automated_movement = 1
	universal_speak = TRUE
	flying = TRUE
	attack_sound = 'sound/weapons/punch1.ogg'
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	attacktext = "бьёт"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	environment_smash = 0
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	move_resist = MOVE_FORCE_STRONG
	AIStatus = AI_OFF
	butcher_results = list(/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	var/summoned = FALSE
	var/cooldown = 0
	var/damage_transfer = 1 //how much damage from each attack we transfer to the owner
	var/light_on = 0
	var/luminosity_on = 3
	var/mob/living/carbon/human/summoner
	var/range = 10 //how far from the user the spirit can be
	var/playstyle_string = "You are a standard Guardian. You shouldn't exist!"
	var/magic_fluff_string = " You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!"
	var/tech_fluff_string = "BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!"
	var/bio_fluff_string = "Your scarabs fail to mutate. This shouldn't happen! Submit a bug report!"
	var/admin_fluff_string = "URK URF!"//the wheels on the bus...
	var/name_color = "white"//only used with protector shields for the time being

/mob/living/simple_animal/hostile/guardian/Initialize(mapload, mob/living/host)
	. = ..()
	if(!host)
		return
	summoner = host
	host.grant_guardian_actions(src)

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Life(seconds, times_fired)
	..()
	if(summoner)
		if(summoner.stat == DEAD || (!summoner.check_death_method() && summoner.health <= HEALTH_THRESHOLD_DEAD) || QDELETED(summoner))
			summoner.remove_guardian_actions()
			to_chat(src, "<span class='danger'>Ваш призыватель умер!</span>")
			visible_message("<span class='danger'>[src] умирает вместе с носителем!</span>")
			ghostize()
			qdel(src)
	snapback()
	if(summoned && !summoner && !admin_spawned)
		to_chat(src, "<span class='danger'>Каким-то образом у вас нет призывателя! Вы исчезаете!</span>")
		ghostize()
		qdel(src)

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	// If the summoner dies instantly, the summoner's ghost may be drawn into null space as the protector is deleted. This check should prevent that.
	if(summoner && loc && summoner.loc)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src, "<span class='holoparasite'>Вас откинуло назад, так как превышена дальность связи! Ваша дальность всего [range] метров от [summoner.real_name]!</span>")
			visible_message("<span class='danger'>\The [src] вернулся к носителю.</span>")
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/temp_visual/guardian/phase/out(loc)
				forceMove(summoner.loc) //move to summoner's tile, don't recall
				new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/proc/is_deployed()
	return loc != summoner

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(!is_deployed() && a_intent == INTENT_HARM)
		to_chat(src, "<span class='danger'>Вы должны показать себя для атаки!</span>")
		return FALSE
	else if(!is_deployed() && a_intent == INTENT_HELP)
		return FALSE
	else
		return ..()

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	. = ..()
	snapback()

/mob/living/simple_animal/hostile/guardian/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	to_chat(summoner, "<span class='danger'>Ваш [name] как-то умер!</span>")
	summoner.death()


/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100)
		if(hud_used)
			hud_used.guardianhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * damage_transfer
	if(summoner)
		if(loc == summoner)
			return
		summoner.adjustBruteLoss(damage)
		if(damage)
			to_chat(summoner, "<span class='danger'>Ваш [name] под атакой! Вы получаете урон!</span>")
			summoner.visible_message("<span class='danger'>Кровь хлещет из [summoner] ибо [src] получает урон!</span>")
		if(summoner.stat == UNCONSCIOUS)
			to_chat(summoner, "<span class='danger'>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span>")
			summoner.adjustCloneLoss(damage/2)

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)

		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		to_chat(summoner, "<span class='danger'>Ваш [src] взорвался!</span>")
		summoner.Weaken(10)// your fermillier has died! ROLL FOR CON LOSS!
	ghostize()
	qdel(src)

//Manifest, Recall, Communicate

/mob/living/simple_animal/hostile/guardian/proc/Manifest()
	if(cooldown > world.time)
		return
	if(!summoner) return
	if(loc == summoner)
		forceMove(get_turf(summoner))
		new /obj/effect/temp_visual/guardian/phase(loc)
		reset_perspective()
		cooldown = world.time + 10

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced = FALSE)
	if(!summoner || loc == summoner || (cooldown > world.time && !forced))
		return
	if(!summoner) return
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
	forceMove(summoner)
	buckled = null
	cooldown = world.time + 10

/mob/living/simple_animal/hostile/guardian/proc/Communicate(message)
	var/input
	if(!message)
		input = stripped_input(src, "Введите сообщение для отправки вашему призывателю.", "Guardian", "")
	else
		input = message
	if(!input)
		return

	// Show the message to the host and to the guardian.
	to_chat(summoner, "<span class='alien'><i>[src]:</i> [input]</span>")
	to_chat(src, "<span class='alien'><i>[src]:</i> [input]</span>")
	add_say_logs(src, input, summoner, "Guardian")

	// Show the message to any ghosts/dead players.
	for(var/mob/M in GLOB.dead_mob_list)
		if(M && M.client && M.stat == DEAD && !isnewplayer(M))
			to_chat(M, "<span class='alien'><i>Guardian Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")

//override set to true if message should be passed through instead of going to host communication
/mob/living/simple_animal/hostile/guardian/say(message, override = FALSE)
	if(admin_spawned || override)//if it's an admin-spawned guardian without a host it can still talk normally
		return ..(message)
	Communicate(message)


/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	to_chat(src, "<span class='danger'>У вас нет другого режима!</span>")


/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!light_on)
		set_light(luminosity_on)
		to_chat(src, "<span class='notice'>Вы активировали свет.</span>")
	else
		set_light(0)
		to_chat(src, "<span class='notice'>Вы выключили свет.</span>")
	light_on = !light_on

////////Creation

/obj/item/guardiancreator
	name = "Колода карт Таро"
	desc = "Зачарованная колода карт, по слухам - источник невероятной силы. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Дух-хранитель"
	var/confirmation_message = "Карты все еще не использованы. Желаете попытать счастье?"
	var/use_message = "Вы перетасовываете колоду..."
	var/used_message = "Все карты выглядят пустыми."
	var/failure_message = "..и вытаскиваете карту! Она...пустая? Возможно лучше попытаться позже."
	var/ling_failure = "Колода отказывается реагировать на отродия по типу ВАС."
	var/list/possible_guardians = list("Хаос", "Стандарт", "Стрелок", "Поддержка", "Подрывник", "Ассасин", "Молния", "Налетчик", "Защитник")
	var/random = FALSE
	/// What type was picked the first activation
	var/picked_random_type
	var/color_list = list("Pink" = "#FFC0CB",
		"Red" = "#FF0000",
		"Orange" = "#FFA500",
		"Green" = "#008000",
		"Blue" = "#0000FF")
	var/name_list = list("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")

/obj/item/guardiancreator/attack_self(mob/living/user)
	for(var/mob/living/simple_animal/hostile/guardian/G in GLOB.alive_mob_list)
		if(G.summoner == user)
			to_chat(user, "У вас уже есть [mob_name]!")
			return
	if(user.mind && (user.mind.changeling || user.mind.vampire))
		to_chat(user, "[ling_failure]")
		return
	if(used == TRUE)
		to_chat(user, "[used_message]")
		return
	used = TRUE // Set this BEFORE the popup to prevent people using the injector more than once, polling ghosts multiple times, and receiving multiple guardians.
	var/choice = alert(user, "[confirmation_message]",, "Да", "Нет")
	if(choice == "Нет")
		to_chat(user, "<span class='warning'>Вы решили не использовать [name].</span>")
		used = FALSE
		return
	to_chat(user, "[use_message]")

	var/guardian_type
	if(random)
		if(!picked_random_type) // Only pick the type once. No type fishing
			picked_random_type = pick(possible_guardians)
		guardian_type = picked_random_type
	else
		guardian_type = input(user, "Выберите тип [mob_name]", "Создание [mob_name] ") as null|anything in possible_guardians
		if(!guardian_type)
			to_chat(user, "<span class='warning'>Вы решили не использовать [name].</span>")
			used = FALSE
			return

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть за [mob_name] ([guardian_type]) у [user.real_name]?", ROLE_GUARDIAN, FALSE, 10 SECONDS, source = src, role_cleanname = "[mob_name] ([guardian_type])")
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key, guardian_type)
	else
		to_chat(user, "[failure_message]")
		used = FALSE

/obj/item/guardiancreator/examine(mob/user, distance)
	. = ..()
	if(used)
		. += "<span class='notice'>[used_message]</span>"

/obj/item/guardiancreator/proc/spawn_guardian(mob/living/user, key, guardian_type)
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(guardian_type)

		if("Хаос")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Стандарт")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Стрелок")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Поддержка")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Подрывник")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

		if("Ассасин")
			pickedtype = /mob/living/simple_animal/hostile/guardian/assassin

		if("Молния")
			pickedtype = /mob/living/simple_animal/hostile/guardian/beam

		if("Налетчик")
			pickedtype = /mob/living/simple_animal/hostile/guardian/charger

		if("Защитник")
			pickedtype = /mob/living/simple_animal/hostile/guardian/protector

	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user, user)
	G.summoned = TRUE
	G.key = key
	to_chat(G, "Вы [mob_name], обязанный служить [user.real_name].")
	to_chat(G, "Вы можете появляться или возвращаться к вашему хозяину с помощью кнопок на панели Стража. Там же вы найдете кнопку связи с хозяином.")
	to_chat(G, "Будучи лично неуязвимым, Вы умрете если [user.real_name] умрет, и любой урон попавший по вам будет пропорционально перенесен хозяину, так как вы питаетесь от его жизненной силы.")
	to_chat(G, "[G.playstyle_string]")
	G.faction = user.faction

	var/color = pick(color_list)
	G.name_color = color_list[color]
	var/picked_name = pick(name_list)
	create_theme(G, user, picked_name, color)

/obj/item/guardiancreator/proc/create_theme(mob/living/simple_animal/hostile/guardian/G, mob/living/user, picked_name, color)
	G.name = "[picked_name] [color]"
	G.real_name = "[picked_name] [color]"
	G.icon_living = "[theme][color]"
	G.icon_state = "[theme][color]"
	G.icon_dead = "[theme][color]"
	to_chat(user, "[G.magic_fluff_string].")

/obj/item/guardiancreator/choose
	random = FALSE

/obj/item/guardiancreator/tech
	name = "Инъектор голопаразитов"
	desc = "Содержит нанороботов неизвестного производства. Хотя он способен на почти колдовские подвиги с помощью голограмм жесткого света и наномашин, ему требуется органический носитель в качестве домашней базы и источника топлива."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Голопаразит"
	confirmation_message =  "Инъектор все еще содержит голопаразитов. Вы хотите использовать его?"
	use_message = "Вы начинаете подавать питание на инъектор..."
	used_message = "Инъектор уже был использован."
	failure_message = "<B>...ОШИБКА. ПОСЛЕДОВАТЕЛЬНОСТЬ ЗАГРУЗКИ ПРЕРВАНА. AI НЕ УДАЛОСЬ ИНИЦИАЛИЗИРОВАТЬ. ОБРАТИТЕСЬ В СЛУЖБУ ПОДДЕРЖКИ ИЛИ ПОВТОРИТЕ ПОПЫТКУ ПОЗЖЕ.</B>"
	ling_failure = "Голопаразиты отпрянули в ужасе. Они не хотят иметь ничего общего с таким существом, как вы."
	color_list = list("Rose" = "#F62C6B",
		"Peony" = "#E54750",
		"Lily" = "#F6562C",
		"Daisy" = "#ECCD39",
		"Zinnia" = "#89F62C",
		"Ivy" = "#5DF62C",
		"Iris" = "#2CF6B8",
		"Petunia" = "#51A9D4",
		"Violet" = "#8A347C",
		"Lilac" = "#C7A0F6",
		"Orchid" = "#F62CF5")
	name_list = list("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

/obj/item/guardiancreator/tech/create_theme(mob/living/simple_animal/hostile/guardian/G, mob/living/user, picked_name, color)
	G.name = "[picked_name] [color]"
	G.real_name = "[picked_name] [color]"
	G.icon_living = "[theme][color]"
	G.icon_state = "[theme][color]"
	G.icon_dead = "[theme][color]"
	to_chat(user, "[G.tech_fluff_string].")
	G.speak_emote = list("states")

/obj/item/guardiancreator/tech/check_uplink_validity()
	return !used

/obj/item/guardiancreator/tech/choose
	random = FALSE

/obj/item/guardiancreator/biological
	name = "Скопление яиц скарабаеев"
	desc = "Паразитический вид, который при рождении будет гнездиться в ближайшем живом существе. Хотя это и не очень полезно для вашего здоровья, они будут защищать свой новый улей насмерть."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "eggs"
	theme = "bio"
	mob_name = "Рой Скарабеев"
	use_message = "Яйца начинают дергаться..."
	confirmation_message =  "Эти яйца все еще в спящем состоянии. Хотите ли вы активировать их?"
	used_message = "Скопление уже вылупилось."
	failure_message = "<B>..но вскоре снова успокаиваются. Видимо, они не были готовы к вылуплению.</B>"
	color_list = list("Rose" = "#F62C6B",
		"Peony" = "#E54750",
		"Lily" = "#F6562C",
		"Daisy" = "#ECCD39",
		"Zinnia" = "#89F62C",
		"Ivy" = "#5DF62C",
		"Iris" = "#2CF6B8",
		"Petunia" = "#51A9D4",
		"Violet" = "#8A347C",
		"Lilac" = "#C7A0F6",
		"Orchid" = "#F62CF5")
	name_list = list("brood", "hive", "nest")

/obj/item/guardiancreator/biological/create_theme(mob/living/simple_animal/hostile/guardian/G, mob/living/user, picked_name, color)
	G.name = "[color] [picked_name]"
	G.real_name = "[color] [picked_name]"
	G.icon_living = "[theme][color]"
	G.icon_state = "[theme][color]"
	G.icon_dead = "[theme][color]"
	to_chat(user, "[G.bio_fluff_string].")
	G.attacktext = "swarms"
	G.speak_emote = list("chitters")

/obj/item/guardiancreator/biological/choose
	random = FALSE


/obj/item/paper/guardian
	name = "Справочник по голопаразитам"
	icon_state = "paper"
	info = {"<b>Cписок видов голопаразитов</b><br>

 <br>
 <b>Хаос</b>: Телепортирует врагов при ударе(не всегда), телепортация приводит к вашим легким галлюцинациям. Поджигает врагов при прикосновении. Автоматически тушит носителя. Имеет в арсенале заклинание, накладывающее на всех в огромном радиусе оглушающие галлюцинации с быстрой перезарядкой.<br>
 <br>
 <b>Стандарт</b>: Сокрушительные атаки ближнего боя способные пробивать стены, экстремально высокая прочность, имеет ауру замедления на врагов. Может кричать на врагов при ударе.<br>
 <br>
 <b>Стрелок</b>: Имеет два режима. Дальнобойный: очень хрупкий, очень часто выпускает опасные дальнобойные снаряды, игнорирующие броню, но тратящие энергию. Скаут: не может атаковать, но слабо видим и может перемещаться сквозь стены на огромные расстояния. Может ставить силки для наблюдения в любом режиме.<br>
 <br>
 <b>Поддержка</b>: Имеет два режима: Боевой: урон токсинами пробивающий броню и средняя защита. Лекарь: Атаки лечат все виды урона, но становится медленным. Может поставить блюспейс маяк на пол и телепортировать всё и всех не прибитых к полу на него на Alt+Click. Имеет в арсенале навык, исцеляющий сломанные кости, органы и внутренние кровотечения.<br>
 <br>
 <b>Подрывник</b>: Слабая броня и атака. Может превратить любой объект в скрытую бомбу, подрывающую любого кто коснулся неё. Может минировать вещи даже будучи внутри хозяина.<br>
 <br>
 <b>Ассасин</b>: Катастрофически высокий урон грубым уроном и ядом, может входить в невидимость для нанесения удара ещё большей силы, игнорирующего броню. Совершенно нет никакой защиты, а в невидимости получает даже больше урона чем это возможно.<br>
 <br>
 <b>Налетчик</b>: Слабая атака с двойной скоростью атаки, средняя броня, невероятно быстр, имеет особый рывок, который при столкновении пробивает броню и опрокидывает жертву.<br>
 <br>
 <b>Молния</b>: Слабая атака и средняя броня, имеет цепь молнии между собой и хозяином, что дезинтегрирует любую цель при нахождении в ней. Может метать молнии во врагов.<br>
 <br>
 <b>Защитник</b>: При нарушении дальности связи хозяин призывается к нему, а не наоборот. Имеет два режима: низкая атака с высокой защитой, и режим ультра-защиты, практически полностью нивелирующий входящий и исходящий урон. В режиме ультра-защиты способен пережить даже взрыв бомбы, лишь слегка ранив хозяина. Может ставить силовые барьеры, через которые могут пройти только вы и ваш подопечный.<br>
"}

/obj/item/paper/guardian/update_icon()
	return


/obj/item/storage/box/syndie_kit/guardian
	name = "Набор инжектора голопаразита"

/obj/item/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/guardiancreator/tech/choose(src)
	new /obj/item/paper/guardian(src)
	return
