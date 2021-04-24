/mob/living/simple_animal/mosquito
	name = "Mosquito"
	desc = "A blood thirsty beast, the carrier of diseases"
	icon_state = "mosquito_alive"
	icon_living = "mosquito_alive"
	icon_dead = "musquito_dead"
	icon = 'icons/mob/mosquito.dmi'
	turns_per_move = 0
	attacktext = "stings"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 10
	health = 10
	faction = list("hostile")
	obj_damage = 0
	environment_smash = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	flying = TRUE
	deathmessage = "Stops flapping it's wings!"

/mob/living/simple_animal/hostile/mosquito/Login()
	..()
	to_chat(src, "<b>You are a mosquito, a common flying insect that needs blood to survive.</b>")
	to_chat(src, "<b>Consuming blood is what you strive and aim for.</b>")
	to_chat(src, "<b>Using your ability on a being with blood will drain a small amount of blood to us</b>")
	to_chat(src, "<b>Prime Directives:</b>")
	to_chat(src, "1. Gather as much blood from biological beings as possible.")
	to_chat(src, "2. Ensure our survival, so we can reproduce later.")

/obj/effect/proc_holder/spell/targeted/click/pass_airlock
	name = "Pass Airlock"
	desc = "You squeeze through the airlock."
	clothes_req = FALSE
	charge_max = 1 SECONDS
	range = 1
	allowed_type = /obj/machinery/door/airlock
	selection_activated_message = "<span class='sinister'>Click on an airlock to try pass it.</span>"
	click_radius = -1
