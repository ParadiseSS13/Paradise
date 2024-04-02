/mob/living/simple_animal/pet/cat
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	holder_type = /obj/item/holder/cat2

/mob/living/simple_animal/pet/cat/Runtime
	holder_type = /obj/item/holder/cat

/mob/living/simple_animal/pet/cat/cak
	holder_type = /obj/item/holder/cak

/mob/living/simple_animal/pet/cat/fat
	name = "fat cat"
	desc = "Упитана. Счастлива."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "iriska"
	icon_living = "iriska"
	icon_dead = "iriska_dead"
	icon_resting = "iriska"
	gender = FEMALE
	mob_size = MOB_SIZE_LARGE // THICK!!!
	//canmove = FALSE
	butcher_results = list(/obj/item/food/snacks/meat = 8)
	maxHealth = 40 // Sooooo faaaat...
	health = 40
	speed = 10 // TOO FAT
	wander = 0 // LAZY
	can_hide = 0
	resting = TRUE
	holder_type = /obj/item/holder/fatcat

/mob/living/simple_animal/pet/cat/fat/handle_automated_action()
	return

/mob/living/simple_animal/pet/cat/white
	name = "white cat"
	desc = "Белоснежная шерстка. Плохо различается на белой плитке, зато отлично виден в темноте!"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "penny"
	icon_living = "penny"
	icon_dead = "penny_dead"
	icon_resting = "penny_rest"
	gender = MALE
	holder_type = /obj/item/holder/cak

/mob/living/simple_animal/pet/cat/birman
	name = "birman cat"
	real_name = "birman cat"
	desc = "Священная порода Бирма."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "crusher"
	icon_living = "crusher"
	icon_dead = "crusher_dead"
	icon_resting = "crusher_rest"
	gender = MALE
	holder_type = /obj/item/holder/crusher


/mob/living/simple_animal/pet/cat/black
	name = "black cat"
	real_name = "black cat"
	desc = "Он ужас летящий на крыльях ночи! Он - тыгыдык и спотыкание во тьме ночной! Бойся не заметить черного кота в тени!"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "salem"
	icon_living = "salem"
	icon_dead = "salem_dead"
	icon_resting = "salem_rest"
	gender = MALE
	holder_type = /obj/item/holder/cat

/mob/living/simple_animal/pet/cat/spacecat
	name = "spacecat"
	desc = "Space Kitty!!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	icon_resting = "spacecat_rest"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	holder_type = /obj/item/holder/spacecat

//named
/mob/living/simple_animal/pet/cat/Floppa
	name = "Большой Шлёпа"
	desc = "Он выглядит так, будто собирается совершить военное преступление."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "floppa"
	icon_living = "floppa"
	icon_dead = "floppa_dead"
	icon_resting = "floppa_rest"
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/fat/Iriska
	name = "Ириска"
	desc = "Упитана. Счастлива. Бюрократы её обожают. И похоже даже черезчур сильно."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/white/Penny
	name = "Копейка"
	desc = "Любит таскать монетки и мелкие предметы. Успевайте прятать их!"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	resting = TRUE

/mob/living/simple_animal/pet/cat/birman/Crusher
	name = "Бедокур"
	desc = "Любит крушить всё что не прикручено. Нужно вовремя прибираться."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	resting = TRUE

/mob/living/simple_animal/pet/cat/spacecat/Musya
	name = "Муся"
	desc = "Любимая почтенная кошка отдела токсинов. Всегда готова к вылетам!"

/mob/living/simple_animal/pet/cat/black/Salem
	name = "Салем"
	real_name = "Салем"
	desc = "Говорят что это бывший колдун, лишенный всех своих сил и превратившейся в черного кота Советом Колдунов из-за попытки захватить мир, а в руки НТ попал чтобы отбывать своё наказание. Судя по его скверному нраву, это может быть похоже на правду."
