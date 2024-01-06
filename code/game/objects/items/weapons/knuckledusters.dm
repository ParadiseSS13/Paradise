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
	origin_tech = "combat=2"
	attack_verb = list("struck", "bludgeoned", "bashed", "smashed")
	var/gripped = FALSE
	var/elite = FALSE
	var/robust = 10
	var/trauma = 5

/obj/item/melee/knuckleduster/attack_self(mob/user)
	if(!gripped)
		gripped = TRUE
		to_chat(user, "You tighten your grip on [src], ensuring you won't drop it.")
		flags |= NODROP
		return
	if(gripped)
		gripped = FALSE
		to_chat(user, "You relax your grip on [src].")
		flags &= ~NODROP
		return

/obj/item/melee/knuckleduster/attack(mob/living/target, mob/living/user, obj/item/organ/external, obj/item/organ/internal/)
	. = ..()
	if(!ishuman(target))
		return

	var/obj/item/organ/external/punched = target.get_organ(user.zone_selected)
	if(gripped && prob(robust) && target.health < 90) // Better at throwing strong punches when gripped
		if(isslimeperson(target))
			punched.cause_internal_bleeding() // Slimes get no quarter, they too shall suffer. IPCs get a pass, they have it bad enough
		else
			punched.fracture()
		return

	if(!length(punched.internal_organs))
		return

	var/obj/item/organ/internal/squishy = pick(punched.internal_organs)
	if(gripped & elite && target.health < 90) // Syndie variant gets to directly damage organs, as a treat
		squishy.receive_damage(trauma)
	if(punched.is_broken())
		squishy.receive_damage(trauma) // Probably not so good for your organs to have your already broken ribs punched hard again
		return


/obj/item/melee/knuckleduster/syndie
	name = "syndicate knuckleduster"
	desc = "For feeling like a real Syndicate Elite when threatening to punch someone to death."
	icon_state = "knuckleduster_syndie"
	force = 10
	throwforce = 5
	origin_tech = "combat=2;syndicate=1"
	elite = TRUE
	robust = 15

/obj/item/melee/knuckleduster/nanotrasen
	name = "engraved knuckleduster"
	desc = "Perfect for giving that Greytider a golden, painful lesson."
	icon_state = "knuckleduster_nt"
	force = 10
	throwforce = 5
	origin_tech = "combat=3"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	materials = list(MAT_GOLD = 500)
	robust = 20

/obj/item/melee/knuckleduster/test
	name = "handheld bone-breakers"
	desc = "Your bones just hurt looking at it."
	icon_state = "knuckleduster_nt"
	force = 25
	throwforce = 25
	elite = TRUE
	robust = 100
	trauma = 30
