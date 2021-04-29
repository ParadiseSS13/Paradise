/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	mob_biotypes = MOB_SPIRIT
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches the"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = -1
	stop_automated_movement = TRUE
	status_flags = 0
	pull_force = 0
	see_invisible = SEE_INVISIBLE_HIDDEN_RUNES
	universal_speak = TRUE
	faction = list("cult")
	status_flags = CANPUSH
	flying = TRUE
	loot = list(/obj/item/reagent_containers/food/snacks/ectoplasm)
	del_on_death = TRUE
	deathmessage = "lets out a contented sigh as their form unwinds."
	var/holy = FALSE

/mob/living/simple_animal/shade/death(gibbed)
	. = ..()
	SSticker.mode.remove_cultist(mind, FALSE)

/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		SS.transfer_soul("SHADE", src, user)
	else
		..()

/mob/living/simple_animal/shade/Process_Spacemove()
	return TRUE


/mob/living/simple_animal/shade/cult/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.shade_icon_state

/mob/living/simple_animal/shade/holy
	holy = TRUE
	icon_state = "shade_angelic"

/mob/living/simple_animal/shade/sword
	faction = list("neutral")

/mob/living/simple_animal/shade/sword/Initialize(mapload)
	.=..()
	status_flags |= GODMODE

/mob/living/simple_animal/shade/update_runechat_msg_location()
	if(istype(loc, /obj/item/soulstone))
		runechat_msg_location = loc
	else
		runechat_msg_location = src
