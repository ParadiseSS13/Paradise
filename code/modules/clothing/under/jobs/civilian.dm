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
	item_state = "hop"
	item_color = "hop"

/obj/item/clothing/under/rank/civilian/hop/skirt
	name = "head of personnel's jumpskirt"
	desc = "It's a jumpskirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	item_state = "hop_skirt"
	item_color = "hop_skirt"

/obj/item/clothing/under/rank/civilian/hop/formal
	name = "formal head of personnel uniform"
	desc = "A formal uniform for the Head of Personnel."
	icon_state = "hop_formal"
	item_state = "hop_formal"
	item_color = "hop_formal"

/obj/item/clothing/under/rank/civilian/hop/dress
	name = "head of personal's dress uniform"
	desc = "Feminine fashion for the style conscious Head of Personnel."
	icon_state = "hop_dress"
	item_state = "hop_dress"
	item_color = "hop_dress"

/obj/item/clothing/under/rank/civilian/hop/whimsy
	name = "head of personnel's suit"
	desc = "A blue sweater and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	icon_state = "hop_whimsy"
	item_state = "hop_whimsy"
	item_color = "hop_whimsy"

/obj/item/clothing/under/rank/civilian/bartender
	name = "bartender's uniform"
	desc = "It looks like it could use some more flair."
	icon_state = "bartender"
	item_state = "bartender"
	item_color = "bartender"

/obj/item/clothing/under/rank/civilian/bartender/skirt
	name = "bartender's skirt"
	icon_state = "bartender_skirt"
	item_state = "bartender_skirt"
	item_color = "bartender_skirt"

/obj/item/clothing/under/rank/civilian/chaplain
	name = "chaplain's jumpsuit"
	desc = "It's a black jumpsuit, often worn by religious folk."
	icon_state = "chaplain"
	item_state = "chaplain"
	item_color = "chaplain"

/obj/item/clothing/under/rank/civilian/chaplain/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/civilian/chaplain/skirt
	name = "chaplain's jumpskirt"
	desc = "It's a black jumpskirt, often worn by religious folk."
	icon_state = "chaplain_skirt"
	item_state = "chaplain_skirt"
	item_color = "chaplain_skirt"

/obj/item/clothing/under/rank/civilian/chef
	name = "chef's uniform"
	desc = "A white shirt and black slacks for the humble chef."
	icon_state = "chef"
	item_state = "chef"
	item_color = "chef"

/obj/item/clothing/under/rank/civilian/chef/skirt
	name = "chef's skirt"
	desc = "A white shirt and black skirt for the humble chef."
	icon_state = "chef_skirt"
	item_state = "chef_skirt"
	item_color = "chef_skirt"

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

/obj/item/clothing/under/rank/civilian/clown/skirt
	name = "clown skirt"
	icon_state = "clown_skirt"
	item_state = "clown_skirt"
	item_color = "clown_skirt"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you want to practice Clown Law!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	item_color = "sexyclown"

/obj/item/clothing/under/rank/civilian/clown/nodrop
	flags = NODROP

/obj/item/clothing/under/rank/civilian/expedition
	name = "expedition jumpsuit"
	desc = "A grey jumpsuit with Nanotrasen markings for identification and a black safety harness for their space suits."
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"

/obj/item/clothing/under/rank/civilian/expedition/overalls
	name = "expedition overalls"
	desc = "A black set of overalls over a grey turtleneck, designed to protect the wearer from microscopic space debris. Does not protect against larger objects."
	icon_state = "explorer_overalls"
	item_state = "explorer_overalls"
	item_color = "explorer_overalls"

/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	item_color = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	icon_state = "mime_skirt"
	item_state = "mime_skirt"
	item_color = "mime_skirt"

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	item_color = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/civilian/hydroponics
	name = "botanist's jumpsuit"
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	icon_state = "hydroponics"
	item_state = "hydroponics"
	item_color = "hydroponics"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	name = "botanist's jumpskirt"
	desc = "It's a jumpskirt designed to protect against minor plant-based hazards."
	icon_state = "hydroponics_skirt"
	item_state = "hydroponics_skirt"
	item_color = "hydroponics_skirt"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/civilian/janitor
	name = "janitor's jumpsuit"
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	icon_state = "janitor"
	item_state = "janitor"
	item_color = "janitor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "janitor's jumpskirt"
	desc = "It's a skirt version of the janitor's uniform with leggings. It has minor protection from biohazards."
	icon_state = "janitor_skirt"
	item_state = "janitor_skirt"
	item_color = "janitor_skirt"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/civilian/janitor/overalls
	name = "janitor's overalls"
	desc = "A pair of purple overalls, specifically designed to protect the wearer against high levels of viscera."
	icon_state = "janitor_overalls"
	item_state = "janitor_overalls"
	item_color = "janitor_overalls"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/civilian/librarian
	name = "librarian's suit"
	desc = "A red sweater and grey slacks, usually worn by the station's librarian."
	icon_state = "librarian"
	item_state = "librarian"
	item_color = "librarian"

/obj/item/clothing/under/rank/civilian/librarian/skirt
	name = "librarian's skirt"
	desc = "A red sweater and grey skirt, usually worn by the station's librarian."
	icon_state = "librarian_skirt"
	item_state = "librarian_skirt"
	item_color = "librarian_skirt"

/obj/item/clothing/under/rank/civilian/mime/nodrop
	flags = NODROP

/obj/item/clothing/under/rank/civilian/barber
	name = "barber's uniform"
	desc = "It's a barber's uniform."
	icon_state = "barber"
	item_state = "barber"
	item_color = "barber"

/obj/item/clothing/under/rank/civilian/barber/skirt
	name = "barber's skirt"
	desc = "It's a barber's uniform. This one has a skirt."
	icon_state = "barber_skirt"
	item_state = "barber_skirt"
	item_color = "barber_skirt"

/obj/item/clothing/under/rank/civilian/internalaffairs
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "Internal Affairs uniform"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	item_color = "internalaffairs"

/obj/item/clothing/under/rank/civilian/lawyer
	name = "lawyer suit"
	desc = "Slick threads."

/obj/item/clothing/under/rank/civilian/lawyer/skirt
	name = "lawyer skirt"
	desc = "Slick threads."

/obj/item/clothing/under/rank/civilian/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	item_color = "lawyer_black"

/obj/item/clothing/under/rank/civilian/lawyer/skirt/black
	icon_state = "lawyer_black_skirt"
	item_state = "lawyer_black_skirt"
	item_color = "lawyer_black_skirt"

/obj/item/clothing/under/rank/civilian/lawyer/red
	name = "lawyer red suit"
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	item_color = "lawyer_red"

/obj/item/clothing/under/rank/civilian/lawyer/skirt/red
	name = "lawyer red skirt"
	icon_state = "lawyer_red_skirt"
	item_state = "lawyer_red_skirt"
	item_color = "lawyer_red_skirt"

/obj/item/clothing/under/rank/civilian/lawyer/blue
	name = "lawyer blue suit"
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	item_color = "lawyer_blue"

/obj/item/clothing/under/rank/civilian/lawyer/skirt/blue
	name = "lawyer blue skirt"
	icon_state = "lawyer_blue_skirt"
	item_state = "lawyer_blue_skirt"
	item_color = "lawyer_blue_skirt"

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

/obj/item/clothing/under/rank/civilian/lawyer/goodsuit
	name = "good man's suit"
	desc = "It's all good, man!"
	icon_state = "good_suit"
	item_state = "good_suit"
	item_color = "good_suit"

/obj/item/clothing/under/rank/civilian/lawyer/skirt/goodsuit
	name = "good man's skirt"
	desc = "It's all good, man!"
	icon_state = "good_suit_skirt"
	item_state = "good_suit_skirt"
	item_color = "good_suit_skirt"
