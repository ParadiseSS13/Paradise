/*
	Paradise Pop reagents
	Created through the bottler machine via bottler_recipes, not through standard reactions
	Eventually will have special effects (minor mostly) tied to their reagents, but for now are purely for flavor

	Make sure to yell at me to finish giving them effects later
	-FalseIncarnate
*/


//Райский удар: Без эффекта, aside from maybe messages about how tasty it is or something
/datum/reagent/consumable/drink/paradise_punch
	name = "Райский удар"
	id = "paradise_punch"
	description = "На вкус именно таков, каким вы себе представляете вкус рая, если бы его можно было разлить по бутылкам."
	reagent_state = LIQUID
	color = "#cc0044"
	taste_description = "рая"

//Яблопокалипсис: Low chance to cause a goonchem vortex that pulls things within a very small radius (2 tiles?) towards the drinker
/datum/reagent/consumable/drink/apple_pocalypse
	name = "Яблопокалипсис"
	id = "apple-pocalypse"
	description = "Если бы судный день имел форму фрукта, скорее всего это было бы яблоко."
	reagent_state = LIQUID
	color = "#44FF44"
	taste_description = "судного дня"

/datum/reagent/consumable/drink/apple_pocalypse/on_mob_life(mob/living/M)
	if(prob(1))
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 1, 0)
		to_chat(M, "<span class='notice'>Вы на мгновение чувствуете себя сверхтяжёлым, как чёрная дыра. Возможно, это просто ваше воображение...</span>")
	return ..()

//Забаненный плод: This one is tasty and safe to drink, might have a low chance of healing a random damage type?
/datum/reagent/consumable/drink/berry_banned
	name = "Забаненный плод"
	id = "berry_banned"
	description = "Причина бана: исключительный вкус."
	reagent_state = LIQUID
	color = "#FF44FF"
	taste_description = "пермабана"

/datum/reagent/consumable/drink/berry_banned/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		var/heal_type = rand(0, 5)		//still prefer the string version
		switch(heal_type)
			if(0)
				update_flags |= M.adjustBruteLoss(-0.25, FALSE)
			if(1)
				update_flags |= M.adjustFireLoss(-0.25, FALSE)
			if(2)
				update_flags |= M.adjustToxLoss(-0.25, FALSE)
			if(3)
				update_flags |= M.adjustOxyLoss(-0.25, FALSE)
			if(4)
				update_flags |= M.adjustCloneLoss(-0.25, FALSE)
			if(5)
				update_flags |= M.adjustBrainLoss(-0.5, FALSE)
		to_chat(M, "<span class='notice'>Вы чувствуете себя слегка помолодевшим!</span>")
	return ..() | update_flags

//Забаненный плод 2: Очень вкусный и токсичный. Наносит урон токсинами и, ВОЗМОЖНО, проигрывает звук "Бьёньк!", убивая кого-то?
/datum/reagent/consumable/drink/berry_banned2
	name = "Забаненный плод"
	id = "berry_banned2"
	description = "Причина бана: исключительный вкус."
	reagent_state = LIQUID
	color = "#FF44FF"
	taste_description = "пермабана"

/datum/reagent/consumable/drink/berry_banned2/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(50))
		update_flags |= M.adjustToxLoss(1, FALSE)		//double strength of poison berry juice alone, because it's concentrated (this is equal to the damage of normal toxin, less often)
	if(prob(10))
		to_chat(M, "<span class='notice'>Вы чувствуете себя слегка помолодевшим!</span>")		//meta this!
	return ..() | update_flags

/datum/reagent/consumable/drink/berry_banned2/on_mob_death(mob/living/M)
	M << sound('sound/effects/adminhelp.ogg',0,1,0,25)
	to_chat(M, "<span class='adminhelp'>ЛС от <b>Администратор</b>: Бьёньк!</span>")
	..()

//Черноглазое варево: Шанс заставить пьющего говорить грейтайдовые фразы, типа "Я думал что клоун был настоящим!"
/datum/reagent/consumable/drink/blackeye_brew
	name = "Черноглазое варево"
	id = "blackeye_brew"
	description = "Сливочный, мягкий вкус, прямо как у лысин толпы ассистентов. Предположительно, выдерживался около 30 лет."
	reagent_state = LIQUID
	color = "#4d2600"
	taste_description = "серой волны"

/datum/reagent/consumable/drink/blackeye_brew/on_mob_life(mob/living/M)
	if(prob(25))
		var/list/tider_talk = list("ЭТО ТЕПЕРЬ МОЯ СТАНЦИЯ, Я ЕЁ ТОЛЬКО ЧТО КУПИЛ.",
									"СЕКРЕТНАЯ ТЕХНИКА: ТУЛБОКСОМ ПО РОЖЕ!",
									"СЕКРЕТНАЯ ТЕХНИКА: ПОДПАЛИТЬ КАНИСТРУ ПЛАЗМЫ!",
									"СЕКРЕТНАЯ ТЕХНИКА: НА СТОЛ И В МУСОРКУ!",
									"ЭТО СДЕЛАЛ [pick("МОЙ БРАТ", "МОЙ ПЁС", "МОЙ ЛУЧШИЙ ДРУГ", "БОРЕР", "САРДЕЛЬКА", "ПУНПУН")]!",
									";s ЧТО ЕЩЁ ЗА КОСМОЗАКОН?!",
									"Я ЭТИ ПЕРЧАТКИ КУПИЛ, А НЕ УКРАЛ",
									"ЭТА ДВЕРЬ УЖЕ БИЛАСЬ ТОКОМ КОГДА Я ПРИШЁЛ",
									"ЖИВОТНЫЕ НЕ ЧЛЕНЫ ЭКИПАЖА")
		M.say(pick(tider_talk))
	return ..()

//Grape Granade: causes the drinker to sometimes burp, has a low chance to cause a goonchem vortex that pushes things within a very small radius (1-2 tiles) away from the drinker
/datum/reagent/consumable/drink/grape_granade
	name = "Гранатовый взрыв"
	id = "grape_granade"
	description = "Взрывной гранатовый вкус, любимый сотрудниками ОБР по всей системе."
	reagent_state = LIQUID
	color = "#9933ff"
	taste_description = "дедов"

/datum/reagent/consumable/drink/grape_granade/on_mob_life(mob/living/M)
	if(prob(1))
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 0, 0)
		M.emote("burp")
		to_chat(M, "<span class='notice'>Вы чувствуете, что готовы взорваться! А, нет, это просто отрыжка…</span>")
	else if(prob(25))
		M.emote("burp")
	return ..()

//Meteor Malt: Sometimes causes screen shakes for the drinker like a meteor impact, low chance to add 1-5 units of a random mineral reagent to the drinker's blood (iron, copper, silver, gold, uranium, carbon, etc)
/datum/reagent/consumable/drink/meteor_malt
	name = "Метеорный солод"
	id = "meteor_malt"
	description = "Зафиксировано движение безалкогольных напитков на встречном с вашими вкусовыми рецепторами курсе."
	reagent_state = LIQUID
	color = "#cc9900"
	taste_description = "летающих космических скал"

/datum/reagent/consumable/drink/meteor_malt/on_mob_life(mob/living/M)
	if(prob(25))
		M << sound('sound/effects/meteorimpact.ogg',0,1,0,25)
		shake_camera(M, 3, 1)
	if(prob(5))
		var/amount = rand(1, 5)
		var/mineral = pick("copper", "iron", "gold", "carbon", "silver", "aluminum", "silicon", "sodiumchloride", "plasma")
		M.reagents.add_reagent(mineral, amount)
	return ..()

/datum/reagent/consumable/ethanol/moonlight_skuma
	name = "Moon'drin"
	id = "moonlight_skuma"
	description = "Double distilled Moon'lin. Soft mint taste which is loved by all tajarans. Used in cocktails."
	reagent_state = LIQUID
	color = "#6734df"
	taste_description = "alcohol, mint and you feel funny"
	drink_icon = "moonlight_skuma"
	drink_name = "Moon'drin"
	drink_desc = "Double distilled Moon'lin. Soft mint taste which is loved by all tajarans. Used in cocktails."
	addiction_chance = 2
	dizzy_adj = 3
	alcohol_perc = 0.5

/datum/reagent/consumable/ethanol/moonlight_skuma/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(30, FALSE)
	M.Dizzy(5)
	if(prob(15))
		M.emote(pick("twitch","giggle"))
		M.Dizzy(3)
	if(prob(5))
		M.Jitter(5)
		M.emote("smile")
		to_chat(M, "<span class='notice'>Вы испытываете приятные, теплые чувства, словно вы дома...</span>")
	return ..() | update_flags
