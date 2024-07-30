/mob/living/simple_animal/pig/Sanya
	name = "Саня"
	desc = "Старый добрый хряк с сединой. Слегка подслеповат, но нюх и харизма по прежнему с ним. Чудом не пущен на мясо и дожил до почтенного возраста."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "pig_old"
	icon_living = "pig_old"
	icon_dead = "pig_old_dead"
	butcher_results = list(/obj/item/food/meat/ham/old = 10)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80
	health = 80

/mob/living/simple_animal/pig/Sanya/npc_safe(mob/user) // depriving the chef of his animals is not cool
	return FALSE

/mob/living/simple_animal/hostile/retaliate/goat/chef
	name = "Боря"
	desc = "Этот козёл - парнокопытное гурме шефа, в его мрачных глазах-бусинках так и читается амибициозный нрав! Он не твой друг, ведь за каждым игривым прыжком может скрываться неожиданный выпад."
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/cow/betsy
	name = "Бетси"
	desc = "Старая добрая старушка. Нескончаемый источник природного молока без ГМО. Ну почти без ГМО..."
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/chicken/Wife
	name = "Галя"
	desc = "Почетная наседка. Жена Коммандора, следующая за ним в коммандировки по космическим станциям."
	icon_state = "chicken_white"
	icon_living = "chicken_white"
	icon_dead = "chicken_white_dead"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/chicken/Wife/npc_safe(mob/user) // depriving the chef of his animals is not cool
	return FALSE

/mob/living/simple_animal/cock/Clucky
	name = "Коммандор Клакки"
	desc = "Его великая армия бесчисленна. Ко-ко-ко."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 40 // Veteran
	health = 40

/mob/living/simple_animal/cock/Clucky/npc_safe(mob/user) // depriving the chef of his animals is not cool
	return FALSE

/mob/living/simple_animal/goose/Scientist
	name = "Гуськор"
	desc = "Учёный Гусь. Везде учусь. Крайне умная и задиристая птица. Обожает генетику. Надеемся это не бывший пропавший генетик..."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "goose_labcoat"
	icon_living = "goose_labcoat"
	icon_dead = "goose_labcoat_dead"
	icon_resting = "goose_labcoat_rest"
	attacktext = "умно щипает"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80
	health = 80
	resting = TRUE

/mob/living/simple_animal/goose/Scientist/npc_safe(mob/user)
	return FALSE

/mob/living/simple_animal/hostile/lizard/croco/Gena
	name = "Гена"
	desc = "Крокодил обожающий музыкальные инструменты и плюшевые игрушки. Пожевать."
	faction = list("neutral")

// rats
/mob/living/simple_animal/mouse/rat/Ratatui
	name = "Рататуй"
	real_name = "Рататуй"
	desc = "Личная крыса шеф повара, помогающая ему при готовке наиболее изысканных блюд. До момента пока он не пропадет и повар не начнет готовить что-то новенькое..."
	mouse_color = "gray"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/rat/irish/Remi
	name = "Реми"
	real_name = "Реми"
	desc = "Близкий друг Рататуя. Не любимец повара, но пока тот не мешает на кухне, ему разрешили здесь остаться. Очень толстая крыса."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 25
	health = 25
	transform = matrix(1.250, 0, 0, 0, 1, 0) // Толстячок на +2 пикселя

/mob/living/simple_animal/mouse/rat/white/Brain
	name = "Брейн"
	real_name = "Брейн"
	desc = "Сообразительная личная лабораторная крыса директора исследований, даже освоившая речь. Настолько часто сбегал, что его перестали помещать в клетку. Он явно хочет захватить мир. Где-то спрятался его напарник..."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20
	universal_speak = 1
	resting = TRUE

/obj/effect/decal/remains/mouse/Pinkie
	name = "Пинки"
	desc = "Когда-то это был напарник самой сообразительной крысы в мире. К сожалению он таковым не являлся..."
	anchored = TRUE

// hamster
/mob/living/simple_animal/mouse/hamster/Representative
	name = "представитель Алексей"
	desc = "Представитель федерации хомяков. Проявите уважение при его виде, ведь он с позитивным исходом решил немало дипломатических вопросов между федерацией мышей, республикой крыс и корпорацией Нанотрейзен. Да и кто вообще хомяка так назвал?!"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "hamster_rep"
	icon_living = "hamster_rep"
	icon_dead = "hamster_rep_dead"
	icon_resting = "hamster_rep_rest"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	holder_type = /obj/item/holder/hamster_rep
	maxHealth = 20
	health = 20
	resting = TRUE

/mob/living/simple_animal/possum/Poppy
	name = "Ключик"
	desc = "Маленький работяга. Его жилетка подчеркивает его рабочие... лапы. Тот еще трудяга. Очень не любит ассистентов в инженерном отделе. И Полли. Интересно, почему?"
	icon_state = "possum_poppy"
	icon_living = "possum_poppy"
	icon_dead = "possum_poppy_dead"
	icon_resting = "possum_poppy_sleep"
	icon_harm = "possum_poppy_aaa"
	maxHealth = 50
	health = 50
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	holder_type = /obj/item/holder/possum/poppy

/mob/living/simple_animal/frog/Wednesday
	name = "Среда"
	real_name = "Среда"
	desc = "Это Среда, мои чуваки!"
	maxHealth = 20
	health = 20
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
