/mob/living/simple_animal/hostile/shitcur_goblin
	name = "\improper Shitcurity Goblin"
	desc = "You better start praying, boy."
	icon = 'icons/mob/shitkur_v6.dmi'
	icon_state = "ShitKur"
	maxHealth = 3000
	health = 3000 //so griefers had a rough time with it
	loot = list(/obj/item/banhammer)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | LETPASSTHROW | PASSGLASS | PASSBLOB
	a_intent = INTENT_HARM
	environment_smash = 2
	lose_patience_timeout = 300 MINUTES //i mean, it will be impressive, if he can survive him and admin for 5 hours
	attacktext = "bans"
	ranged = TRUE
	ranged_message = "thorws a warn"
	ranged_cooldown_time = 3 SECONDS
	projectiletype = /obj/item/projectile/energy/electrode
	projectilesound = 'sound/weapons/taser.ogg'

/mob/living/simple_animal/hostile/shitcur_goblin/Initialize()
	. = ..()
	playsound(src, 'sound/misc/Wild_Griefer_Appeared.ogg', 50, 1, -1)

/mob/living/simple_animal/hostile/shitcur_goblin/proc/stun_attack(mob/living/carbon/griefer)
	griefer.SetStuttering(5)
	griefer.Stun(5)
	griefer.Weaken(5)
	griefer.visible_message("<span class='danger'>[src] dealing with [griefer]!</span>",\
							"<span class='userdanger'>You have been BANNED FOR NO REASON</span>")

/mob/living/simple_animal/hostile/shitcur_goblin/LoseTarget()
	message_admins("Smiting shitcurity goblin was deleted due to a lack of valid target. Someone killed them first, or they ceased to exist.")
	qdel(src) //so we dont shitcur after banning

/mob/living/simple_animal/hostile/shitcur_goblin/AttackingTarget()
	stun_attack(target)
	playsound(loc, 'sound/misc/BAAN.ogg', 50, 1, -1)
