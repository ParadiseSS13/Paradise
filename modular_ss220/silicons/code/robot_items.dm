// =============
// ENGINEER
// =============



// Небольшой багфикс "непрозрачного открытого шлюза"
/obj/structure/inflatable/door/operate()
	. = ..()
	opacity = FALSE


// =============
// MEDICAL
// =============

/obj/item/reagent_containers/borghypo/basic/Initialize(mapload)
	. = ..()
	reagent_ids |= list("sal_acid", "charcoal")

/obj/item/reagent_containers/borghypo/basic/upgraded
	name = "Upgraded Medical Hypospray"
	desc = "Upgraded medical hypospray, capable of providing standart medical treatment."
	reagent_ids = list("salglu_solution", "epinephrine", "spaceacillin", "sal_acid",
	"charcoal", "hydrocodone", "mannitol", "salbutamol", "styptic_powder")
	total_reagents = 60
	maximum_reagents = 60



// =============
// SERVICE
// =============
/obj/item/rsf/attack_self(mob/user)
	if(..() && power_mode >= 3000)
		power_mode /= 2

/obj/item/eftpos/cyborg
	name = "Silicon EFTPOS"
	desc = "Проведите ID картой для оплаты налогов."
	transaction_purpose = "Оплата счета от робота."

/obj/item/eftpos/cyborg/Initialize(mapload)
	. = ..()
	transaction_purpose = "Оплата счета от [usr.name]."

/obj/item/eftpos/ui_act(action, list/params, datum/tgui/ui)
	var/mob/living/user = ui.user

	switch(action)
		if("toggle_lock")
			if(transaction_locked)
				if(!check_user_position(user))
					return
				transaction_locked = FALSE
				transaction_paid = FALSE
			else if(linked_account)
				transaction_locked = TRUE
			else
				to_chat(user, span_warning("[bicon(src)]No account connected to send transactions to.<"))
			return TRUE
		// if(isrobot(user))
		// 	card_account = attempt_account_access(id_card.associated_account_number, pin_needed = FALSE)
	. = ..()

// =============
// MINER
// =============
