//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "gray cloak"
	desc = "It's a cape that can be worn around your neck in a pretty dull color."
	icon_state = "cloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/neck/cloak/head_of_security
	name = "head of security's cloak"
	desc = "Worn by the leader of Brigston, ruling the station with an iron fist."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/quartermaster
	name = "quartermaster's cloak"
	desc = "Worn by the God-emperor of Cargonia, supplying the station with the necessary tools for survival."
	icon_state = "qmcloak"

/obj/item/clothing/neck/cloak/chief_medical_officer
	name = "chief medical officer's cloak"
	desc = "Worn by the leader of Medistan, the valiant men and women keeping pestilence at bay."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/chief_engineer
	name = "chief engineer's cloak"
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power."
	icon_state = "cecloak"

/obj/item/clothing/neck/cloak/chief_engineer/white
	name = "chief engineer's cloak"
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power. This one is white."
	icon_state = "cecloak_white"

/obj/item/clothing/neck/cloak/research_director
	name = "research director's cloak"
	desc = "Worn by the leader of Scientopia, the greatest thaumaturgist and researcher of rapid unexpected self disassembly."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/captain
	name = "captain's cloak"
	desc = "Worn by the supreme leader of Space Station 13."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/captain/Initialize(mapload)
	. = ..()
	desc = "Worn by the supreme leader of [station_name()]."

/obj/item/clothing/neck/cloak/head_of_personnel
	name = "head of personnel's cloak"
	desc = "Worn by the Head of Personnel. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/neck/cloak/janitor
	name = "holographic janitor's cloak"
	desc = "Worn by the most skilled custodians, or the ones that got their hands on it first."
	icon_state = "cleanercloak"

/obj/item/clothing/neck/cloak/healer
	name = "holographic healer's cloak"
	desc = "Worn by the best and most skilled healers, the handlers of hyposprays, pills, auto-menders and first-aid kits."
	icon_state = "healercloak"

/obj/item/clothing/neck/cloak/gaming //Prize counter
	name = "holographic gamer's cloak"
	desc = "Worn by the most skilled professional gamers on the station, this legendary cloak is only attainable by achieving true gaming enlightenment. This status symbol represents the awesome might of a being of focus, commitment, and sheer fucking will. Something casual gamers will never begin to understand."
	icon_state = "gamercloak"

/obj/item/clothing/neck/cloak/rainbow
	name = "holographic rainbow cloak"
	desc = "A holographic cloak capable of rapidly changing colors."
	icon_state = "rainbowcloak"

/obj/item/clothing/neck/cloak/mining //Mining equipment vendor
	name = "holographic miner's cloak"
	desc = "Worn by the most skilled miners, this legendary cloak is only attainable by achieving true mineral enlightenment. This status symbol represents a being who has forgotten more about rocks than most miners will ever know, a being who has moved mountains and filled valleys."
	icon_state = "minercloak"
