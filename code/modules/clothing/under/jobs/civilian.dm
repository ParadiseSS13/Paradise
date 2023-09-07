/obj/item/clothing/under/rank/civilian
	icon = 'icons/obj/clothing/under/civilian.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/civilian.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/civilian.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/civilian.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/civilian.dmi'
		)

/obj/item/clothing/under/rank/civilian/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	item_color = "hop"

/obj/item/clothing/under/rank/civilian/head_of_personnel/dress
	name = "head of personnel's dress uniform"
	desc = "Feminine fashion for the style conscious Head of Personnel."
	icon_state = "dress_hop"
	item_color = "dress_hop"

/obj/item/clothing/under/rank/civilian/head_of_personnel_whimsy
	desc = "A blue jacket and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	name = "head of personnel's suit"
	icon_state = "hopwhimsy"
	item_state = "hopwhimsy"
	item_color = "hopwhimsy"

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

/obj/item/clothing/under/rank/civilian/clown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg' = 1), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/under/rank/civilian/clown/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind && H.mind.assigned_role == "Clown")
			SSticker.score.score_clown_abuse++
	return ..()

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
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
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

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


/obj/item/clothing/under/rank/civilian/internalaffairs
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "Internal Affairs uniform"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	item_color = "internalaffairs"

/obj/item/clothing/under/rank/civilian/lawyer
	name = "lawyer suit"
	desc = "Slick threads."

/obj/item/clothing/under/rank/civilian/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	item_color = "lawyer_black"

/obj/item/clothing/under/rank/civilian/lawyer/red
	name = "lawyer red suit"
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	item_color = "lawyer_red"

/obj/item/clothing/under/rank/civilian/lawyer/blue
	name = "lawyer blue suit"
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	item_color = "lawyer_blue"

/obj/item/clothing/under/rank/civilian/lawyer/purple
	name = "lawyer purple suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	item_color = "lawyer_purp"

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	name = "blue suit"
	desc = "A classy suit and tie"
	icon_state = "bluesuit"
	item_state = "bluesuit"
	item_color = "bluesuit"

/obj/item/clothing/under/rank/civilian/lawyer/oldman
	name = "Old Man's Suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"
	item_state = "oldman"
	item_color = "oldman"

/obj/item/clothing/under/rank/civilian/lawyer/dress_hr
	name = "human resources director's uniform"
	desc = "Superior class for the nosy H.R. Director."
	icon_state = "huresource"
	item_color = "huresource"
