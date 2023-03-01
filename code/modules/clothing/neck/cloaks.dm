//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "grey cloak"
	desc = "It's a cloak that can be worn around your neck in a pretty dull color."
	icon_state = "cloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = UPPER_TORSO | ARMS

/obj/item/clothing/neck/cloak/head_of_security
	name = "head of security's cloak"
	desc = "Worn by the leader of Brigston, ruling the station with an iron fist."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/security
	name = "security officer's cloak"
	desc = "Worn by security officers."
	icon_state = "seccloak"
/obj/item/clothing/neck/cloak/quartermaster
	name = "quartermaster's cloak"
	desc = "Worn by the God-emperor of Cargonia, supplying the station with the necessary tools for survival."
	icon_state = "qmcloak"

/obj/item/clothing/neck/cloak/chief_medical_officer
	name = "chief medical officer's cloak"
	desc = "Worn by the leader of Medistan, the valiant men and women keeping pestilence at bay."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/chief_engineer
	name = "chief engineer's white cloak"
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power."
	icon_state = "cecloak"

/obj/item/clothing/neck/cloak/chief_engineer/white
	name = "chief engineer's white cloak"
	desc = "Worn by the leader of both Atmosia and Delamistan, wielder of unlimited power. This one is white."
	icon_state = "cecloak_white"

/obj/item/clothing/neck/cloak/research_director
	name = "research director's cloak"
	desc = "Worn by the leader of Scientopia, the greatest thaumaturgist and researcher of rapid unexpected self disassembly."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/captain
	name = "captain's cloak"
	desc = "Worn by the supreme leader of the NSS Cyberiad."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/captain/Initialize(mapload)
	. = ..()
	desc = "Worn by the supreme leader of [station_name()]."

/obj/item/clothing/neck/cloak/head_of_personnel
	name = "head of personnel's cloak"
	desc = "Worn by the Head of Personnel. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/neck/cloak/nanotrasen_representative
	name = "NanoTrasen Representative's cloak"
	desc = "Worn by a NanoTrasen representative. A faint whisper of denunciation can be heard from under the cloak."
	icon_state = "ntrcloak"

/obj/item/clothing/neck/cloak/blueshield
	name = "Blueshield's cloak"
	desc = "Worn by a Blueshield officer, that faithfully defends its goals."
	icon_state = "blueshieldcloak"

/obj/item/clothing/neck/cloak/healer
	name = "healer's cloak"
	desc = "Worn by the best and most skilled healers, the handlers of hyposprays, pills, auto-menders and first-aid kits."
	icon_state = "healercloak"

/obj/item/clothing/neck/cloak/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "owl_wings"
	actions_types = list(/datum/action/item_action/toggle_wings)

/obj/item/clothing/neck/cloak/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	item_state = "griffin_wings"

/obj/item/clothing/neck/cloak/bishop
	name = "bishop's cloak"
	desc = "Become the space pope."
	icon_state = "bishopcloak"
	item_state = "bishopcloak"

/obj/item/clothing/neck/cloak/bishopblack
	name = "black bishop cloak"
	desc = "Become the space pope."
	icon_state = "blackbishopcloak"
	item_state = "blackbishopcloak"

/obj/item/clothing/neck/cloak/syndiecap
	name = "syndicate captain's cloak"
	desc = "A cloak that inspires fear among Nanotrasen employees, worn by the greatest Syndicate captains."
	icon_state = "syndcapt"
	item_state = "syndcapt"

/obj/item/clothing/neck/cloak/syndiecap/comms
	name = "syndicate officer's cloak"
	desc = "A cloak that inspires fear among Nanotrasen employees, worn by the greatest Syndicate officers."

/obj/item/clothing/neck/cloak/syndieadm
	name = "syndicate admiral's cloak"
	desc = "A deep red cloak, worn by only the greatest of the Syndicate. If you are looking at this, you probably won't be looking at it for much longer."
	icon_state = "syndadmiral"
	item_state = "syndadmiral"

/obj/item/clothing/neck/toggle/attack_self(mob/user)
	if(icon_state == initial(icon_state))
		icon_state = icon_state + "_t"
		item_state = icon_state + "_t"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	user.update_inv_neck()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/neck/cloak/New()
	..()
	AddComponent(/datum/component/spraycan_paintable)
	START_PROCESSING(SSobj, src)
	update_icon()
