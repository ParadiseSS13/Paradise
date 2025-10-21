/obj/item/clothing/under/rank/civilian
	icon = 'icons/obj/clothing/under/civilian.dmi'
	worn_icon = 'icons/mob/clothing/under/civilian.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/civilian.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/civilian.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/civilian.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/civilian.dmi'
	)

/obj/item/clothing/under/rank/civilian/hop
	name = "head of personnel's uniform"
	desc = "It's a blue dress shirt and black slacks worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop"

/obj/item/clothing/under/rank/civilian/hop/skirt
	name = "head of personnel's skirt"
	desc = "It's a blue dress shirt and black skirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/civilian/hop/dress
	name = "head of personnel's dress"
	desc = "Feminine fashion for the style conscious Head of Personnel."
	icon_state = "hop_dress"

/obj/item/clothing/under/rank/civilian/hop/formal
	name = "head of personnel's formal uniform"
	desc = "A stylish choice for a formal occasion."
	icon_state = "hop_formal"

/obj/item/clothing/under/rank/civilian/hop/whimsy
	name = "head of personnel's suit"
	desc = "A blue sweater and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	icon_state = "hop_whimsy"

/obj/item/clothing/under/rank/civilian/hop/oldman
	name = "old man's suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"

/obj/item/clothing/under/rank/civilian/hop/turtleneck
	name = "head of personnel's turtleneck"
	desc = "A fancy turtleneck designed to keep the wearer cozy in a cold office. Due to budget cuts, the material does not offer any external protection."
	icon_state = "hop_turtle"

/obj/item/clothing/under/rank/civilian/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	inhand_icon_state = null

/obj/item/clothing/under/rank/civilian/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's black jumpsuit"
	icon_state = "chapblack"

/obj/item/clothing/under/rank/civilian/chaplain/white
	desc = "It's a white jumpsuit, often worn by religious folk."
	name = "chaplain's white jumpsuit"
	icon_state = "chapwhite"

/obj/item/clothing/under/rank/civilian/chaplain/bw
	desc = "It's a black and white jumpsuit, often worn by religious folk."
	name = "chaplain's black and white jumpsuit"
	icon_state = "chapbw"

/obj/item/clothing/under/rank/civilian/chaplain/orange
	desc = "Saffron cloth to wrap a Buddhist monk."
	name = "kasaya"
	icon_state = "chaporange"

/obj/item/clothing/under/rank/civilian/chaplain/green
	desc = "A green modest dress."
	name = "chaplain's dress"
	icon_state = "chapgreen"

/obj/item/clothing/under/rank/civilian/chaplain/thobe
	desc = "A modest and dignified robe."
	name = "chaplain's thobe"
	icon_state = "chapthobe"

/obj/item/clothing/under/rank/civilian/chaplain/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/civilian/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef"

/obj/item/clothing/under/rank/civilian/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	inhand_icon_state = "clown"

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
	icon_state = "clown_skirt"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you want to practice clown law."
	icon_state = "sexyclown"

/obj/item/clothing/under/rank/civilian/clown/nodrop
	flags = NODROP

/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	icon_state = "mime_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/civilian/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards. This one has blue markings."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	inhand_icon_state = "g_suit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/civilian/hydroponics/alt
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards. This one has brown markings."
	name = "hydroponicist's jumpsuit"
	icon_state = "hydroponics_alt"

/obj/item/clothing/under/rank/civilian/janitor
	name = "janitor's jumpsuit"
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	icon_state = "janitor"
	inhand_icon_state = "janitor"

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "janitor's jumpskirt"
	desc = "It's the official skirt variant of the janitor's uniform. It has leggings for protection against messes."
	icon_state = "janitor_skirt"

/obj/item/clothing/under/rank/civilian/janitor/overalls
	name = "janitor's overalls"
	desc = "Protective overalls designed to protect the wearer against large amounts of viscera."
	icon_state = "janitor_overalls"

/obj/item/clothing/under/rank/civilian/librarian
	name = "librarian's uniform"
	desc = "A collared shirt with dapper pinstripe pants guaranteed to make you stand out at any Halloween party."
	icon_state = "red_suit"

/obj/item/clothing/under/rank/civilian/mime/nodrop
	flags = NODROP

/obj/item/clothing/under/rank/civilian/barber
	desc = "It's a barber's uniform."
	name = "barber's uniform"
	icon_state = "barber"
