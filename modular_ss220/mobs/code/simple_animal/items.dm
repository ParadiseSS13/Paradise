// Meat
/obj/item/food/meat/dog
	name = "dog meat"
	desc = "Не слишком питательно. Но говорят деликатес космокорейцев."
	list_reagents = list("protein" = 2, "epinephrine" = 2)

/obj/item/food/meat/security
	name = "security meat"
	desc = "Мясо наполненное чувством мужества и долга."
	list_reagents = list("protein" = 3, "epinephrine" = 5)

/obj/item/food/meat/pug
	name = "pug meat"
	desc = "Чуть менее очарователен в нарезке."
	list_reagents = list("protein" = 2, "epinephrine" = 2)

/obj/item/food/meat/ham/old
	name = "жесткая ветчина"
	desc = "Мясо почтенного хряка."
	list_reagents = list("protein" = 2, "porktonium" = 10)

/obj/item/food/meat/mouse
	name = "мышатина"
	desc = "На безрыбье и мышь мясо. Кто знает чем питался этот грызун до его подачи к столу."
	icon = 'modular_ss220/mobs/icons/items.dmi'
	icon_state = "meat_clear"
	list_reagents = list("nutriment" = 2, "blood" = 3, "toxin" = 1)

/obj/item/food/salmonmeat/snailmeat
	name = "snail meat"
	desc = "Сырая космо-улитка в собственном соку."
	filling_color = "#6bb4a8"
	list_reagents = list("protein" = 5, "vitamin" = 5)

/obj/item/food/salmonmeat/turtlemeat
	name = "snail meat"
	desc = "Сырая космо-улитка в собственном соку."
	filling_color = "#2fa24c"
	list_reagents = list("protein" = 10, "vitamin" = 8)

/obj/structure/bed/dogbed/pet
	name = "Удобная лежанка"
	desc = "Комфортная лежанка для любимейшего питомца отдела."
	anchored = TRUE

// Останки
/obj/effect/decal/remains/mouse
	name = "remains"
	desc = "Некогда бывшая мышь. Её останки. Больше не будет пищать..."
	icon = 'modular_ss220/mobs/icons/items.dmi'
	icon_state = "mouse_skeleton"
	anchored = FALSE
	move_resist = MOVE_FORCE_EXTREMELY_WEAK

/obj/effect/decal/remains/mouse/water_act(volume, temperature, source, method)
	. = ..()
