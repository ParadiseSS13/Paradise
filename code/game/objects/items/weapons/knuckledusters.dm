/obj/item/melee/knuckleduster
	name = "knuckleduster"
	desc = "Simple metal punch enhancers, perfect for bar brawls."
	icon = 'icons/obj/knuckleduster.dmi'
	icon_state = "knuckleduster"
	flags = CONDUCT
	force = 5
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=1"
	attack_verb = list("struck", "bludgeoned", "bashed", "smashed")

/obj/item/melee/knuckleduster/syndie
	name = "syndicate knuckleduster"
	desc = "For feeling like a real Syndicate Elite when threatening to punch someone to death."
	icon_state = "knuckleduster_syndie"
	force = 10
	throwforce = 5
	origin_tech = "combat=2;syndicate=1"

/obj/item/melee/knuckleduster/nanotrasen
	name = "nanotrasen knuckleduster"
	desc = "Perfect for giving that Greytider a golden, painful lesson."
	icon_state = "knuckleduster_nt"
	force = 12
	throwforce = 6
	origin_tech = "combat=3"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	materials = list(MAT_GOLD = 500)
