/obj/item/toy/plushie/crewmanplushie
	name = "medic tajaran plushie"
	desc = "Мягкая белая игрушка с доброй, но пугливой улыбкой."
	icon = 'modular_ss220/objects/icons/plushies.dmi'
	icon_state = "crewman"
	item_state = "crewman"
	lefthand_file = 'modular_ss220/objects/icons/inhands/plushies_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/plushies_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/plushie/crewmanplushie/examine_more(mob/user)
	. = ..()
	. += span_notice ("Тайара-медик выглядит точно так же, как её реальный прототип – с трогательно поджатыми ушками, большими добрыми глазами и той самой знаменитой улыбкой, перед которой не может устоять даже самый хмурый член экипажа. \"Является медицинским изделием. Заменяет психотерапевта. При острых приступах тоски рекомендуется гладить по голове не менее 3 минут непрерывно\". \"Не бойся, я тут!\"")
