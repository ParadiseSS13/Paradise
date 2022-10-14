/datum/slime_age
	var/age
	var/health
	var/damage
	var/attacked			//доп. урон наносимый слайму
	var/stat_text			//Текст для игрока что готов делиться
	var/stat_text_evolve	//Доп. текст для игрока, что готов эволюционировать
	var/amount_grown		//созревание для эволюции, максимальное значение созревания
	var/amount_grown_for_split	//созревание для деления
	var/max_nutrition		//Can't go above it
	var/grow_nutrition		//Above it we grow, below it we can eat
	var/hunger_nutrition	//Below it we will always eat
	var/starve_nutrition	//Below it we will eat before everything else
	var/nutrition_steal		//сколько ворует нутриентов у других слаймов
	var/nutrition_handle	//корректировка питания
	var/matrix_size			//изменения размера под матрицу
	var/baby_counts			//Количество возможных детей. Распределение: 1 = BABY, 2 = ADULT, 3 = OLD
	var/cores				//Число ядер
	var/feed				//дополнительные максимум значения для кормежки, урон и доп. нутриенты

/datum/slime_age/baby
	age = SLIME_BABY
	health = 150
	damage = 3
	attacked = -2
	stat_text = ""
	stat_text_evolve = "evolve to adult form"
	amount_grown = SLIME_EVOLUTION_THRESHOLD
	amount_grown_for_split = SLIME_EVOLUTION_THRESHOLD
	max_nutrition = 1000
	grow_nutrition = 800
	hunger_nutrition = 500
	starve_nutrition = 200
	nutrition_steal = 0
	nutrition_handle = 0
	matrix_size = matrix(1, 0, 0, 0, 1, 0)
	baby_counts	= 0
	cores = 1
	feed = 2

/datum/slime_age/adult
	age = SLIME_ADULT
	health = 200
	damage = 5
	attacked = 0
	stat_text = "reproduce"
	stat_text_evolve = "evolve to old form"
	amount_grown = SLIME_EVOLUTION_THRESHOLD_OLD
	amount_grown_for_split = SLIME_EVOLUTION_THRESHOLD
	max_nutrition = 1200
	grow_nutrition = 1000
	hunger_nutrition = 600
	starve_nutrition = 300
	nutrition_steal = 40
	nutrition_handle = 1
	matrix_size = matrix(1, 0, 0, 0, 1, 0)
	baby_counts	= 4
	cores = 1
	feed = 4

/datum/slime_age/old
	age = SLIME_OLD
	health = 300
	damage = 7
	attacked = 2
	stat_text = "big reproduce"
	stat_text_evolve = "evolve to elder form"
	amount_grown = SLIME_EVOLUTION_THRESHOLD_EVOLVE
	amount_grown_for_split = SLIME_EVOLUTION_THRESHOLD_OLD
	max_nutrition = 3000
	grow_nutrition = 2000
	hunger_nutrition = 800
	starve_nutrition = 500
	nutrition_steal = 70
	nutrition_handle = 2
	matrix_size = matrix(1.25, 0, 0, 0, 1.25, 2)
	baby_counts	= 9
	cores = 4
	feed = 8

/datum/slime_age/elder
	age = SLIME_ELDER
	health = 400
	damage = 10
	attacked = 5
	stat_text = "huge reproduce"
	stat_text_evolve = "evolve to slimeman"
	amount_grown = SLIME_EVOLUTION_THRESHOLD_EVOLVE_SLIMEMAN
	amount_grown_for_split = SLIME_EVOLUTION_THRESHOLD_OLD
	max_nutrition = 6000
	grow_nutrition = 3200
	hunger_nutrition = 1200
	starve_nutrition = 800
	nutrition_steal = 100
	nutrition_handle = 3
	matrix_size = matrix(1.75, 0, 0, 0, 1.75, 4)
	baby_counts	= 18
	cores = 8
	feed = 10

/datum/slime_age/slimeman
	age = SLIME_SLIMEMAN

/mob/living/simple_animal/slime/proc/mutation_table(colour)
	var/list/slime_mutation[4]
	switch(colour)
		//Tier 1
		if("grey")
			slime_mutation[1] = "orange"
			slime_mutation[2] = "metal"
			slime_mutation[3] = "blue"
			slime_mutation[4] = "purple"
		//Tier 2
		if("purple")
			slime_mutation[1] = "dark purple"
			slime_mutation[2] = "dark blue"
			slime_mutation[3] = "green"
			slime_mutation[4] = "green"
		if("metal")
			slime_mutation[1] = "silver"
			slime_mutation[2] = "yellow"
			slime_mutation[3] = "gold"
			slime_mutation[4] = "gold"
		if("orange")
			slime_mutation[1] = "dark purple"
			slime_mutation[2] = "yellow"
			slime_mutation[3] = "red"
			slime_mutation[4] = "red"
		if("blue")
			slime_mutation[1] = "dark blue"
			slime_mutation[2] = "silver"
			slime_mutation[3] = "pink"
			slime_mutation[4] = "pink"
		//Tier 3
		if("dark blue")
			slime_mutation[1] = "purple"
			slime_mutation[2] = "blue"
			slime_mutation[3] = "cerulean"
			slime_mutation[4] = "cerulean"
		if("dark purple")
			slime_mutation[1] = "purple"
			slime_mutation[2] = "orange"
			slime_mutation[3] = "sepia"
			slime_mutation[4] = "sepia"
		if("yellow")
			slime_mutation[1] = "metal"
			slime_mutation[2] = "orange"
			slime_mutation[3] = "bluespace"
			slime_mutation[4] = "bluespace"
		if("silver")
			slime_mutation[1] = "metal"
			slime_mutation[2] = "blue"
			slime_mutation[3] = "pyrite"
			slime_mutation[4] = "pyrite"
		//Tier 4
		if("pink")
			slime_mutation[1] = "pink"
			slime_mutation[2] = "pink"
			slime_mutation[3] = "light pink"
			slime_mutation[4] = "light pink"
		if("red")
			slime_mutation[1] = "red"
			slime_mutation[2] = "red"
			slime_mutation[3] = "oil"
			slime_mutation[4] = "oil"
		if("gold")
			slime_mutation[1] = "gold"
			slime_mutation[2] = "gold"
			slime_mutation[3] = "adamantine"
			slime_mutation[4] = "adamantine"
		if("green")
			slime_mutation[1] = "green"
			slime_mutation[2] = "green"
			slime_mutation[3] = "black"
			slime_mutation[4] = "black"
		// Tier 5
		else
			slime_mutation[1] = colour
			slime_mutation[2] = colour
			slime_mutation[3] = colour
			slime_mutation[4] = colour
	return(slime_mutation)

/mob/living/simple_animal/slime/proc/colour_rgb(colour)
	var/colour_choose = "#000000"
	switch(colour)
		if("grey")
			colour_choose = "#9e9e9e"
		if("silver")
			colour_choose = "#dfdfdf"
		if("metal")
			colour_choose = "#7d7d7d"
		if("bluespace")
			colour_choose = "#e7e7e7"
		if("orange")
			colour_choose = "#e69419"
		if("blue")
			colour_choose = "#45cece"
		if("dark blue")
			colour_choose = "#3e8dd1"
		if("cerulean")
			colour_choose = "#5b7c9c"
		if("purple")
			colour_choose = "#ab37ce"
		if("dark purple")
			colour_choose = "#6f1cce"
		if("sepia")
			colour_choose = "#8a7d71"
		if("pyrite")
			colour_choose = "#f4f445"
		if("yellow")
			colour_choose = "#cec745"
		if("gold")
			colour_choose = "#eaaa01"
		if("pink")
			colour_choose = "#e658ad"
		if("light pink")
			colour_choose = "#e6cbe2"
		if("red")
			colour_choose = "#ce2f2f"
		if("oil")
			colour_choose = "#3b3b3b"
		if("adamantine")
			colour_choose = "#57a58e"
		if("green")
			colour_choose = "#44e659"
		if("black")
			colour_choose = "#191919"
		if("rainbow")
			colour_choose = "#ffffff"
	return colour_choose
