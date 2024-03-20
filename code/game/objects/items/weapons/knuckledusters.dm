/obj/item/melee/knuckleduster
	name = "knuckleduster"
	desc = "Simple metal punch enhancers, perfect for bar brawls."
	icon = 'icons/obj/weapons/knuckleduster.dmi'
	icon_state = "knuckleduster"
	flags = CONDUCT
	force = 10
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=2"
	attack_verb = list("struck", "bludgeoned", "bashed", "smashed")
	hitsound = null
	/// Is the weapon gripped or not?
	var/gripped = FALSE
	/// Can the weapon damage organs directly or not?
	var/elite = FALSE
	/// How much organ damage can the weapon do?
	var/trauma = 5

/obj/item/melee/knuckleduster/attack_self(mob/user)
	if(!gripped)
		gripped = TRUE
		to_chat(user, "You tighten your grip on [src], ensuring you won't drop it.")
		flags |= (NODROP | ABSTRACT)
	else
		gripped = FALSE
		to_chat(user, "You relax your grip on [src].")
		flags &= ~(NODROP | ABSTRACT)

/obj/item/melee/knuckleduster/dropped(mob/user, silent)
	. = ..()
	gripped = FALSE
	flags &= ~(NODROP | ABSTRACT)

/obj/item/melee/knuckleduster/attack/(mob/living/user)
	hitsound = pick('sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')
	return ..()

/obj/item/melee/knuckleduster/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!ishuman(target))
		return

	var/obj/item/organ/external/punched = target.get_organ(user.zone_selected)
	if(!length(punched.internal_organs))
		return

	var/obj/item/organ/internal/squishy = pick(punched.internal_organs)
	if(gripped && elite)
		squishy.receive_damage(trauma)
	if(punched.is_broken())
		squishy.receive_damage(trauma) // Probably not so good for your organs to have your already broken ribs punched hard by a metal object

/obj/item/melee/knuckleduster/syndie
	name = "syndicate knuckleduster"
	desc = "For feeling like a real Syndicate Elite when threatening to punch someone to death."
	icon_state = "knuckleduster_syndie"
	force = 15
	throwforce = 5
	origin_tech = "combat=2;syndicate=1"
	elite = TRUE

/obj/item/melee/knuckleduster/nanotrasen
	name = "engraved knuckleduster"
	desc = "Perfect for giving that Greytider a golden, painful lesson."
	icon_state = "knuckleduster_nt"
	force = 10
	throwforce = 5
	origin_tech = "combat=3"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Steal objectives shouldnt be easy to destroy.
	materials = list(MAT_GOLD = 500)
	trauma = 10

/obj/item/melee/knuckleduster/admin
	name = "handheld bone-breaker"
	desc = "Your bones just hurt looking at it."
	icon_state = "knuckleduster_nt"
	force = 25
	throwforce = 25
	elite = TRUE
	trauma = 30
