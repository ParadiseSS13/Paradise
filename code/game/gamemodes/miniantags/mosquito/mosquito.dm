/mob/living/simple_animal/mosquito
	name = "Mosquito"
	desc = "A blood thirsty beast, the carrier of diseases"
	icon_state = "mosquito_alive"
	icon_living = "mosquito_alive"
	icon_dead = "mosquito_dead"
	icon = 'icons/mob/mosquito.dmi'
	turns_per_move = 0
	attacktext = "stings"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 10
	health = 10
	faction = list("hostile")
	speed = 0
	obj_damage = 0
	environment_smash = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	blood_volume = BLOOD_VOLUME_NORMAL
	flying = TRUE
	deathmessage = "Stops flapping it's wings!"
	var/list/donors = list()
	var/playstyle_string = 	"<b><font size=3 color='red'>You are a giant mosquito.</font><br> The most annoying being in the universe and \
							a carrier for diseases.<br> Your goal is to take blood from biological beings, feeding and healing yourself \
							in the process <br> "
	var/datum/disease/DiseaseOfM

/mob/living/simple_animal/mosquito/Initialize(mapload,ChosenDisease)
	. = ..()
	remove_from_all_data_huds()
	GrantMosquitoActions()
	DiseaseOfM = new ChosenDisease

/mob/living/simple_animal/mosquito/proc/GrantMosquitoActions()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/click/blood_suck)

/obj/effect/proc_holder/spell/targeted/click/blood_suck // Takes blood off target
	name = "Take blood"
	desc = "Allows you to suck blood from living organisms"
	charge_max = 50
	starts_charged = TRUE
	still_recharging_msg = "We must first digest the previous blood"
	range = 1	//has no effect beyond this range, so setting this makes invalid/useless targets not show up in popup
	action_icon_state = "blood"
	clothes_req = 0
	auto_target_single = FALSE


	selection_activated_message		= "<span class='notice'>You prepare to sting your target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You relax yourself</span>"
	allowed_type = /mob/living/carbon/human

/obj/effect/proc_holder/spell/targeted/click/blood_suck/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/mosquito/U = user

	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/human/target = targets[1]

	if(!target.dna || (NO_BLOOD in target.dna.species.species_traits))
		to_chat(U, "<span class='warning'>That donor has no blood to take.</span>")
		return FALSE

	if(U.donors.Find(target.real_name))
		to_chat(U, "<span class='warning'>We already took a sample of this targets blood .</span>")
		return FALSE

	if(do_mob(U, target, 10))
		to_chat(U, "<span class='notice'> You draw a little blood from [target].</span>")
		if(prob(60)
			target.ForceContractDisease(U.DiseaseOfM)
		U.donors += target.real_name

/obj/effect/proc_holder/spell/targeted/click/blood_suck/valid_target(mob/living/carbon/human/target, user)
	if(!..())
		return FALSE
	return !target.stat

/mob/living/simple_animal/death(gibbed)
	flying = FALSE
	add_splatter_floor(loc)
	return ..()

