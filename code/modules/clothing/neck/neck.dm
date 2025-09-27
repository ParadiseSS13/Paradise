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
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to adjust if it is worn under or over your suit.</span>"

/obj/item/clothing/neck/tie/AltClick(mob/living/carbon/human/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !istype(user))
		return

	under_suit = !under_suit
	if(user.neck == src)
		user.update_inv_neck()
	to_chat(user, "<span class='notice'>You adjust [src] to be worn [under_suit ? "under" : "over"] your suit.</span>")

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus, used to get a rough idea of the condition of the heart and lungs. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/attack__legacy__attackchain(mob/living/carbon/human/M, mob/living/user)
	if(!ishuman(M) || !isliving(user))
		return ..(M, user)

	if(user == M)
		user.visible_message("[user] places [src] against [user.p_their()] chest and listens attentively.", "You place [src] against your chest...")
	else
		user.visible_message("[user] places [src] against [M]'s chest and listens attentively.", "You place [src] against [M]'s chest...")
	var/datum/organ/heart/heart_datum = M.get_int_organ_datum(ORGAN_DATUM_HEART)
	var/datum/organ/lungs/lung_datum = M.get_int_organ_datum(ORGAN_DATUM_LUNGS)
	if(!lung_datum || !heart_datum)
		to_chat(user, "<span class='warning'>You don't hear anything.</span>")
		return

	var/obj/item/organ/internal/H = heart_datum.linked_organ
	var/obj/item/organ/internal/L = lung_datum.linked_organ
	if(!M.pulse || (!H || !(L && !HAS_TRAIT(M, TRAIT_NOBREATH))))
		to_chat(user, "<span class='warning'>You don't hear anything.</span>")
		return

	var/color = "notice"
	if(H)
		var/heart_sound
		switch(H.damage)
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

	if(L)
		var/lung_sound
		switch(L.damage)
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
