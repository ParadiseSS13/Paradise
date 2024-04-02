/mob/living/simple_animal/pet/dog
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	maxHealth = 50
	health = 50
	melee_damage_type = STAMINA
	melee_damage_lower = 6
	melee_damage_upper = 10
	attacktext = "кусает"
	var/growl_sound = list('modular_ss220/mobs/sound/creatures/dog_grawl1.ogg','modular_ss220/mobs/sound/creatures/dog_grawl2.ogg') //Used in emote.

	butcher_results = list(/obj/item/food/snacks/meat/dog = 4)
	collar_type = "dog"

/mob/living/simple_animal/pet/dog/wuv(change, mob/M)
	. = ..()
	if(change)
		if(change < 0)
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				playsound(src, pick(src.growl_sound), 75, TRUE)


/mob/living/simple_animal/pet/dog/corgi
	holder_type = /obj/item/holder/corgi

/mob/living/simple_animal/pet/dog/corgi/Ian/persistent_load()
	. = ..()
	if(age == record_age)
		holder_type = /obj/item/holder/old_corgi

/mob/living/simple_animal/pet/dog/corgi/narsie
	holder_type = /obj/item/holder/narsian
	maxHealth = 300
	health = 300
	melee_damage_type = STAMINA	//Пади ниц!
	melee_damage_lower = 50
	melee_damage_upper = 100

/*	// При добавлении Ратвара
/mob/living/simple_animal/pet/dog/corgi/ratvar
	name = "Cli-k"
	desc = "It's a coolish Ian that clicks!"
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "clik"
	icon_living = "clik"
	icon_dead = "clik_dead"
	faction = list("neutral", "clockwork_cult")
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE
	maxHealth = 100
	health = 100

/mob/living/simple_animal/pet/dog/corgi/ratvar/update_corgi_fluff()
	..()
	speak = list("V'z fuvavat jneevbe!", "CLICK!", "KL-KL-KLIK")
	speak_emote = list("growls", "barks ominously")
	emote_hear = list("barks echoingly!", "woofs hauntingly!", "yaps in an judicial manner.", "mutters something unspeakable.")
	emote_see = list("communes with the unnameable.", "seeks the light in souls.", "shakes.")

/mob/living/simple_animal/pet/dog/corgi/ratvar/ratvar_act()
	adjustBruteLoss(-maxHealth)
*/

/mob/living/simple_animal/pet/dog/corgi/puppy
	maxHealth = 20
	health = 20
	butcher_results = list(/obj/item/food/snacks/meat/corgi = 1)

/mob/living/simple_animal/pet/dog/corgi/puppy/void
	maxHealth = 60
	health = 60
	holder_type = /obj/item/holder/void_puppy

/mob/living/simple_animal/pet/dog/corgi/puppy/slime
	name = "\improper slime puppy"
	real_name = "slimy"
	desc = "Крайне склизкий. Но прикольный!"
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	nofur = TRUE
	holder_type = /obj/item/holder/slime_puppy
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY

/mob/living/simple_animal/pet/dog/corgi/Lisa
	holder_type = /obj/item/holder/lisa

/mob/living/simple_animal/pet/dog/corgi/borgi
	holder_type = /obj/item/holder/borgi

/mob/living/simple_animal/pet/dog/pug
	holder_type = /obj/item/holder/pug
	maxHealth = 30
	health = 30

/mob/living/simple_animal/pet/dog/bullterrier
	name = "bullterrier"
	real_name = "bullterrier"
	desc = "Кого-то его мордочка напоминает..."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	holder_type = /obj/item/holder/bullterrier

/mob/living/simple_animal/pet/dog/tamaskan
	name = "tamaskan"
	real_name = "tamaskan"
	desc = "Хорошая семейная собака. Уживается с другими собаками и ассистентами."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "tamaskan"
	icon_living = "tamaskan"
	icon_dead = "tamaskan_dead"
	holder_type = /obj/item/holder/bullterrier

/mob/living/simple_animal/pet/dog/german
	name = "german"
	real_name = "german"
	desc = "Немецкая овчарка с помесью двортерьера. Судя по крупу - явно не породистый."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "german"
	icon_living = "german"
	icon_dead = "german_dead"

/mob/living/simple_animal/pet/dog/brittany
	name = "brittany"
	real_name = "brittany"
	desc = "Старая порода, которую любят аристократы."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "brittany"
	icon_living = "brittany"
	icon_dead = "brittany_dead"



// named
/mob/living/simple_animal/pet/dog/brittany/Psycho
	name = "Перрито"
	real_name = "Перрито"
	desc = "Собака, обожающая котов, особенно в сапогах, прекрасно лающая на Испанском, прошла терапевтические курсы, готова выслушать все ваши проблемы и выдать вам целебных объятий с завершением в виде почесыванием животика."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/dog/pug/Frank
	name = "Фрэнк"
	real_name = "Фрэнк"
	desc = "Мопс полученный в результате эксперимента ученых в черном. Почему его не забрали интересный вопрос. Похоже он всем надоел своей болтовней, после чего его лишили дара речи."
	resting = TRUE
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN


/mob/living/simple_animal/pet/dog/bullterrier/Genn
	name = "Геннадий"
	desc = "Собачий аристократ. Выглядит очень важным и начитанным. Доброжелательный любимец ассистентов."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	maxHealth = 5
	health = 5
	resting = TRUE

