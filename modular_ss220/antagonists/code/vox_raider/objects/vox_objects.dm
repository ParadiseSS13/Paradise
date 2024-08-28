/obj/item/clothing/glasses/meson/cyber/vox
	name = "Мезонный Глаз Воксов"
	desc = "Мезонный кибернетический глаз с системой вставки в глазной разъем. Полностью заменяет функционирующий глаз или его полость. \
	ВНИМАНИЕ! Глаз возможно удалить только хирургическим путем. Из-за своего размера - не позволяет надевать прочие приблуды на глаза, заменяя очки."
	flags = 0

/obj/item/clothing/glasses/meson/cyber/vox/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == SLOT_HUD_GLASSES)
		flags = NODROP
	else
		flags = initial(flags)

/obj/item/clothing/glasses/thermal/cyber/vox
	name = "Термальный Глаз Воксов"
	desc = "Термальный кибернетический глаз с системой вставки в глазной разъем. Полностью заменяет функционирующий глаз или его полость. \
	ВНИМАНИЕ! Глаз возможно удалить только хирургическим путем. Из-за своего размера - не позволяет надевать прочие приблуды на глаза, заменяя очки."
	flags = 0

/obj/item/clothing/glasses/thermal/cyber/vox/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == SLOT_HUD_GLASSES)
		flags = NODROP
	else
		flags = initial(flags)

