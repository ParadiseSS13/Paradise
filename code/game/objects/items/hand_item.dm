/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	item_state = ""
	force = 0
	throwforce = 0
	flags = DROPDEL | ABSTRACT
	attack_verb = list("slaps")
	hitsound = 'sound/weapons/slap.ogg'

/obj/item/slapper/attack(mob/M, mob/living/carbon/human/user)
	user.do_attack_animation(M)
	playsound(M, hitsound, 50, TRUE, -1)
	user.visible_message("<span class='danger'>[user] slaps [M]!</span>", "<span class='notice'>You slap [M]!</span>", "<span class='hear'>You hear a slap.</span>")

/obj/item/kisser
	name = "kiss"
	desc = "I want you all to know, everyone and anyone, to seal it with a kiss."
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	item_state = ""
	force = 0
	throwforce = 0
	flags = DROPDEL | ABSTRACT
	/// The kind of projectile this version of the kiss blower fires
	var/kiss_type = /obj/item/projectile/kiss

/obj/item/kisser/afterattack(atom/target, mob/user, flag, params)
	var/turf/user_turf = get_turf(user)
	var/obj/item/projectile/blown_kiss = new kiss_type(user_turf)
	user.visible_message("<b>[user]</b> blows \a [blown_kiss] at [target]!", "<span class='notice'>You blow \a [blown_kiss] at [target]!</span>")

	//Shooting Code:
	blown_kiss.spread = 0
	blown_kiss.original = target
	blown_kiss.firer = user // don't hit ourself that would be really annoying
	blown_kiss.preparePixelProjectile(target, user_turf, user, params)
	blown_kiss.fire()
	qdel(src)

/obj/item/kisser/death
	name = "kiss of death"
	desc = "If looks could kill, they'd be this."
	color = COLOR_BLACK
	kiss_type = /obj/item/projectile/kiss/death

/obj/item/projectile/kiss
	name = "kiss"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	hitsound = 'sound/effects/kiss.ogg'
	hitsound_wall = 'sound/effects/kiss.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	speed = 1.6
	damage_type = BRUTE
	damage = 0
	nodamage = TRUE // love can't actually hurt you
	armour_penetration = 100 // but if it could, it would cut through even the thickest plate
	flag = "magic" // and most importantly, love is magic~

/obj/item/projectile/kiss/fire(angle)
	if(firer)
		name = "[name] blown by [firer]"
	return ..()

/obj/item/projectile/kiss/on_hit(atom/target, blocked, hit_zone)
	def_zone = BODY_ZONE_HEAD // let's keep it PG, people
	. = ..()

/obj/item/projectile/kiss/death
	name = "kiss of death"
	nodamage = FALSE // okay i kinda lied about love not being able to hurt you
	damage = 35
	sharp = TRUE
	color = COLOR_BLACK

/obj/item/projectile/kiss/death/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/heartbreakee = target
	var/obj/item/organ/internal/heart/dont_go_breakin_my_heart = heartbreakee.get_organ_slot("heart")
	if(dont_go_breakin_my_heart)
		dont_go_breakin_my_heart.receive_damage(999)
	else // You're probably a snowflakey species or Xenomorph
		heartbreakee.adjustFireLoss(1000) // the sickest of burns
