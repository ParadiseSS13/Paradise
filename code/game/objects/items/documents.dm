/obj/item/documents
	name = "secret documents"
	desc = "Documents printed on special copy-protected paper."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	inhand_icon_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/documents/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/documents/nanotrasen
	desc = "Nanotrasen documents printed on special copy-protected paper. They are filled with complex diagrams, technical documentation, and lists of names, dates, and coordinates."
	icon_state = "docs_verified"

/obj/item/documents/nanotrasen/examine(mob/user)
	. = ..()
	. += "<span class='warning'>These documents are marked \"<b>TOP SECRET</b> - property of Nanotrasen\".</span>"

/obj/item/documents/syndicate
	desc = "Documents printed on special copy-protected paper. They detail sensitive Syndicate operational intelligence."

/obj/item/documents/syndicate/red
	name = "'Red' secret documents"
	icon_state = "docs_red"

/obj/item/documents/syndicate/red/examine(mob/user)
	. = ..()
	. += "<span class='warning'>These documents are marked with \"<b>TOP SECRET - RED</b>\" and the logo of the Syndicate.</span>"

/obj/item/documents/syndicate/blue
	name = "'Blue' secret documents"
	icon_state = "docs_blue"

/obj/item/documents/syndicate/blue/examine(mob/user)
	. = ..()
	. += "<span class='warning'>These documents are marked with \"<b>TOP SECRET - BLUE</b>\" and the logo of the Syndicate.</span>"

/obj/item/documents/syndicate/yellow
	name = "'Yellow' secret documents"
	icon_state = "docs_yellow"
	resistance_flags = NONE

/obj/item/documents/syndicate/yellow/examine(mob/user)
	. = ..()
	. += "<span class='warning'>These documents are marked with \"<b>TOP SECRET - YELLOW</b>\" and the logo of the Syndicate.</span>"

/obj/item/documents/syndicate/yellow/trapped
	desc = "Documents printed on special copy-protected paper. They detail sensitive Syndicate operational intelligence, and have a thin film of clear material covering their surface."
	var/poison_type = "amanitin"
	var/poison_dose = 20
	var/poison_total = 60

/obj/item/documents/syndicate/mining
	desc = "Documents detailing Syndicate plasma mining operations."

/obj/item/documents/syndicate/mining/examine(mob/user)
	. = ..()
	. += "<span class='warning'>These documents are marked with \"<b>SECRET</b>\" and the logo of the Syndicate.</span>"

/obj/item/documents/syndicate/yellow/trapped/pickup(user)
	if(ishuman(user) && poison_total > 0)
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(poison_type, poison_dose)
			poison_total -= poison_dose
			add_attack_logs(src, user, "Picked up [src], the trapped syndicate documents")
	return ..()

/obj/item/documents/syndicate/dvorak_blackbox
	name = "\improper D.V.O.R.A.K Blackbox Disk"
	desc = "This disk contains a full record of all information that passed through D.V.O.R.A.K's systems during its uptime, not to mention what may have gone wrong. NT might be interested in this."
	icon = 'icons/obj/module.dmi'
	icon_state = "holodisk"
	inhand_icon_state = "card-id"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
