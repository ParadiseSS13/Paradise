/obj/item/melee/knuckleduster
  name = "knuckleduster"
  desc = "Metal knuckle reinforcers, perfect for getting the upper hand in bar brawls."
//  icon = 'icons/obj/knuckleduster.dmi'
  flags = CONDUCT
  force = 10
  throwforce = 5
  w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
  origin_tech = "combat=2"
  attack_verb = list("struck", "bludgeoned", "bashed", "smashed")
  hitsound = 'sound/weapons/genhit.ogg'
  var/improvised = FALSE

/obj/item/melee/knuckleduster/improvised
  name = "improvised knuckleduster"
  desc = "Poor quality and easy to drop, but good enough for making your fists more dangerous."
  force = 8
  throwforce = 4
  resistance_flags = FLAMMABLE
  armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 0)
  origin_tech = "materials=1;combat=2"
  improvised = TRUE

/obj/item/melee/knuckleduster/attack(mob/living/target, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return
  if((target.stat != DEAD) && (target.getStaminaLoss() > 20) && (user.zone_selected = HEAD))
		target.visible_message("<span class='danger'>[user] has knocked [target] down with a concussion!</span>", \
							"<span class='userdanger'>[user] has knocked [target] down with a concussion!</span>")
		target.Weaken(5 SECONDS)
    
  if(!improvised && user.a == INTENT_HARM)
    flags |? NODROP
  else
    flags &= ~NODROP
