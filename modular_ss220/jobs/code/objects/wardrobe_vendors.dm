/obj/machinery/economy/vending/medidrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/medical/doctor/intern = 5,
		/obj/item/clothing/under/rank/medical/doctor/intern/skirt = 5,
		/obj/item/clothing/under/rank/medical/doctor/intern/assistant = 5,
		/obj/item/clothing/under/rank/medical/doctor/intern/assistant/skirt = 5,
		/obj/item/clothing/head/surgery/green/light = 5,
		/obj/item/clothing/under/rank/medical/scrubs/green/light = 5,
	)


/obj/machinery/economy/vending/secdrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/security/officer/cadet = 5,
		/obj/item/clothing/under/rank/security/officer/cadet/skirt = 5,
		/obj/item/clothing/under/rank/security/officer/cadet/assistant = 5,
		/obj/item/clothing/under/rank/security/officer/cadet/assistant/skirt = 5,
	)


/obj/machinery/economy/vending/scidrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/rnd/scientist/student = 5,
		/obj/item/clothing/under/rank/rnd/scientist/student/skirt = 5,
		/obj/item/clothing/under/rank/rnd/scientist/student/assistant = 5,
		/obj/item/clothing/under/rank/rnd/scientist/student/assistant/skirt = 5,
	)


/obj/machinery/economy/vending/engidrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/engineering/engineer/trainee = 5,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/skirt = 5,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/assistant = 5,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/assistant/skirt = 5,
	)
