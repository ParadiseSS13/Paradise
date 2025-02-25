/obj/item/clothing/under/rank/civilian
	icon = 'icons/obj/clothing/under/civilian.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/civilian.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/civilian.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/civilian.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/civilian.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/civilian.dmi'
		)

/obj/item/clothing/under/rank/civilian/hop
	name = "head of personnel's jumpsuit"
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop"
	item_color = "hop"

/obj/item/clothing/under/rank/civilian/hop/skirt
	name = "head of personnel's jumpskirt"
	desc = "It's a jumpskirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	item_color = "hop_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/civilian/hop/dress
	name = "head of personnel's dress uniform"
	desc = "Feminine fashion for the style conscious Head of Personnel."
	icon_state = "hop_dress"
	item_color = "hop_dress"

/obj/item/clothing/under/rank/civilian/hop/formal
	name = "head of personnel's formal uniform"
	desc = "A stylish choice for a formal occasion."
	icon_state = "hop_formal"
	item_color = "hop_formal"

/obj/item/clothing/under/rank/civilian/hop/whimsy
	name = "head of personnel's suit"
	desc = "A blue sweater and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	icon_state = "hop_whimsy"
	item_state = "hop_whimsy"
	item_color = "hop_whimsy"

/obj/item/clothing/under/rank/civilian/hop/oldman
	name = "old man's suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"
	item_state = "oldman"
	item_color = "oldman"

/obj/item/clothing/under/rank/civilian/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	item_state = "ba_suit"
	item_color = "ba_suit"


/obj/item/clothing/under/rank/civilian/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	item_color = "chapblack"

/obj/item/clothing/under/rank/civilian/chaplain/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/civilian/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef"
	item_color = "chef"

/obj/item/clothing/under/rank/civilian/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	item_color = "clown"

/obj/item/clothing/under/rank/civilian/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg' = 1), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/under/rank/civilian/clown/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind && H.mind.assigned_role == "Clown")
			SSticker.score.score_clown_abuse++
	return ..()

/obj/item/clothing/under/rank/civilian/clown/skirt
	name = "clown skirt"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown_skirt"
	item_state = "clown_skirt"
	item_color = "clown_skirt"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you want to practice clown law."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	item_color = "sexyclown"

/obj/item/clothing/under/rank/civilian/clown/nodrop
	flags = NODROP

/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	item_color = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	desc = "It's not very colourful."
	icon_state = "mime_skirt"
	item_state = "mime_skirt"
	item_color = "mime_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	item_color = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/civilian/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/civilian/janitor
	name = "janitor's jumpsuit"
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	icon_state = "janitor"
	item_state = "janitor"
	item_color = "janitor"

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "janitor's jumpskirt"
	desc = "It's the official skirt variant of the janitor's uniform. It has leggings for protection against messes."
	icon_state = "janitor_skirt"
	item_state = "janitor_skirt"
	item_color = "janitor_skirt"

/obj/item/clothing/under/rank/civilian/janitor/overalls
	name = "janitor's overalls"
	desc = "Protective overalls designed to protect the wearer against large amounts of viscera."
	icon_state = "janitor_overalls"
	item_state = "janitor_overalls"
	item_color = "janitor_overalls"

/obj/item/clothing/under/rank/civilian/librarian
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	item_color = "red_suit"


/obj/item/clothing/under/rank/civilian/mime/nodrop
	flags = NODROP

/obj/item/clothing/under/rank/civilian/barber
	desc = "It's a barber's uniform."
	name = "barber's uniform"
	icon_state = "barber"
	item_state = "barber"
	item_color = "barber"
