/obj/item/clothing/neck/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	var/under_suit = FALSE

/obj/item/clothing/neck/tie/blue
	name = "blue tie"
	icon_state = "bluetie"

/obj/item/clothing/neck/tie/red
	name = "red tie"
	icon_state = "redtie"

/obj/item/clothing/neck/tie/black
	name = "black tie"
	icon_state = "blacktie"

/obj/item/clothing/neck/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"

/obj/item/clothing/neck/tie/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("You can <b>Alt-Click</b> [src] to adjust if it is worn under or over your suit.")

/obj/item/clothing/neck/tie/AltClick(mob/living/carbon/human/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !istype(user))
		return

	under_suit = !under_suit
	if(user.neck == src)
		user.update_inv_neck()
	to_chat(user, SPAN_NOTICE("You adjust [src] to be worn [under_suit ? "under" : "over"] your suit."))

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus, used to get a rough idea of the condition of the heart and lungs. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ishuman(target) || !isliving(user))
		return ..()

	if(user == target)
		user.visible_message(
			SPAN_NOTICE("[user] places [src] against [user.p_their()] chest and listens attentively."),
			SPAN_NOTICE("You place [src] against your chest...")
		)
	else
		user.visible_message(
			SPAN_NOTICE("[user] places [src] against [target]'s chest and listens attentively."),
			SPAN_NOTICE("You place [src] against [target]'s chest...")
		)
	var/mob/living/carbon/human/H = target
	var/datum/organ/heart/heart_datum = H.get_int_organ_datum(ORGAN_DATUM_HEART)
	var/datum/organ/lungs/lung_datum = H.get_int_organ_datum(ORGAN_DATUM_LUNGS)
	if(!lung_datum || !heart_datum)
		to_chat(user, SPAN_WARNING("You don't hear anything."))
		return ITEM_INTERACT_COMPLETE

	var/obj/item/organ/internal/heart = heart_datum.linked_organ
	var/obj/item/organ/internal/lungs = lung_datum.linked_organ
	if(!H.pulse || (!heart || !(lungs && !HAS_TRAIT(H, TRAIT_NOBREATH))))
		to_chat(user, SPAN_WARNING("You don't hear anything."))
		return ITEM_INTERACT_COMPLETE

	var/color = "notice"
	if(heart)
		var/heart_sound
		switch(heart.damage)
			if(0 to 1)
				heart_sound = "healthy"
			if(1 to 25)
				heart_sound = "offbeat"
			if(25 to 50)
				heart_sound = "uneven"
				color = "warning"
			if(50 to INFINITY)
				heart_sound = "weak, unhealthy"
				color = "warning"
		to_chat(user, "<span class='[color]'>You hear \an [heart_sound] pulse.</span>")

	if(lungs)
		var/lung_sound
		switch(lungs.damage)
			if(0 to 1)
				lung_sound = "healthy respiration"
			if(1 to 25)
				lung_sound = "labored respiration"
			if(25 to 50)
				lung_sound = "pained respiration"
				color = "warning"
			if(50 to INFINITY)
				lung_sound = "gurgling"
				color = "warning"
		to_chat(user, "<span class='[color]'>You hear [lung_sound].</span>")
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/neck/neckerchief
	name = "white neckerchief"
	desc = "A neatly tied neckerchief for the service professional."
	icon_state = "neckerchief_white"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/neck.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/neck.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/neck.dmi'
	)

/obj/item/clothing/neck/neckerchief/black
	name = "black neckerchief"
	icon_state = "neckerchief_black"

/obj/item/clothing/neck/neckerchief/green
	name = "green neckerchief"
	icon_state = "neckerchief_green"

/obj/item/clothing/neck/neckerchief/red
	name = "red neckerchief"
	icon_state = "neckerchief_red"
