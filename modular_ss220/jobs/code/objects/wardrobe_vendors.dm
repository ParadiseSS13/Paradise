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
	prices |= list(
		/obj/item/clothing/under/rank/medical/doctor/intern = 50,
		/obj/item/clothing/under/rank/medical/doctor/intern/skirt = 50,
		/obj/item/clothing/under/rank/medical/doctor/intern/assistant = 50,
		/obj/item/clothing/under/rank/medical/doctor/intern/assistant/skirt = 50,
		/obj/item/clothing/head/surgery/green/light = 20,
		/obj/item/clothing/under/rank/medical/scrubs/green/light = 50,
	)


/obj/machinery/economy/vending/secdrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/security/officer/cadet = 5,
		/obj/item/clothing/under/rank/security/officer/cadet/skirt = 5,
		/obj/item/clothing/under/rank/security/officer/cadet/assistant = 5,
		/obj/item/clothing/under/rank/security/officer/cadet/assistant/skirt = 5,
	)
	contraband |= list(
		/obj/item/clothing/head/helmet/cop = 2,
		/obj/item/clothing/head/helmet/cop/v2 = 1,
		/obj/item/clothing/suit/armor/cop = 3,
	)
	prices |= list(
		/obj/item/clothing/under/rank/security/officer/cadet = 50,
		/obj/item/clothing/under/rank/security/officer/cadet/skirt = 50,
		/obj/item/clothing/under/rank/security/officer/cadet/assistant = 50,
		/obj/item/clothing/under/rank/security/officer/cadet/assistant/skirt = 50,
		/obj/item/clothing/head/helmet/cop = 200,
		/obj/item/clothing/head/helmet/cop/v2 = 200,
		/obj/item/clothing/suit/armor/cop = 200,
	)


/obj/machinery/economy/vending/scidrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/rnd/scientist/student = 5,
		/obj/item/clothing/under/rank/rnd/scientist/student/skirt = 5,
		/obj/item/clothing/under/rank/rnd/scientist/student/assistant = 5,
		/obj/item/clothing/under/rank/rnd/scientist/student/assistant/skirt = 5,
	)
	prices |= list(
		/obj/item/clothing/under/rank/rnd/scientist/student = 50,
		/obj/item/clothing/under/rank/rnd/scientist/student/skirt = 50,
		/obj/item/clothing/under/rank/rnd/scientist/student/assistant = 50,
		/obj/item/clothing/under/rank/rnd/scientist/student/assistant/skirt = 50,
	)

/obj/machinery/economy/vending/engidrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/engineering/engineer/trainee = 5,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/skirt = 5,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/assistant = 5,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/assistant/skirt = 5,
	)
	prices |= list(
		/obj/item/clothing/under/rank/engineering/engineer/trainee = 50,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/skirt = 50,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/assistant = 50,
		/obj/item/clothing/under/rank/engineering/engineer/trainee/assistant/skirt = 50,
	)
