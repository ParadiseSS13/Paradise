/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	icon = 'icons/mob/cult.dmi'
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
	pull_force = 0
	see_invisible = SEE_INVISIBLE_HIDDEN_RUNES
	universal_speak = TRUE
	faction = list("cult")
	loot = list(/obj/item/food/ectoplasm)
	del_on_death = TRUE
	deathmessage = "lets out a contented sigh as their form unwinds."
	initial_traits = list(TRAIT_FLYING, TRAIT_SHOCKIMMUNE)
	var/holy = FALSE

/mob/living/simple_animal/shade/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		SS.transfer_soul("SHADE", src, user)
		return ITEM_INTERACT_COMPLETE

/mob/living/simple_animal/shade/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/shade/holy
	holy = TRUE
	icon_state = "shade_angelic"

/mob/living/simple_animal/shade/cult

/mob/living/simple_animal/shade/cult/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(shade_icon_state, initial(icon_state))

/mob/living/simple_animal/shade/sword
	faction = list("neutral")
	a_intent = INTENT_HARM // scuffed sword mechanics bad
	can_change_intents = FALSE // same here
	health = 100
	maxHealth = 100
	weather_immunities = list("ash")
	hud_type = /datum/hud/sword

/mob/living/simple_animal/shade/sword/Initialize(mapload)
	.=..()
	AddSpell(new /datum/spell/sentient_sword_lunge)
	var/obj/item/nullrod/scythe/talking/host_sword = loc
	if(istype(host_sword))
		health = host_sword.obj_integrity

/mob/living/simple_animal/shade/sword/generic_item
	name = "Trapped spirit"

/mob/living/simple_animal/shade/sword/generic_item/update_runechat_msg_location()
	runechat_msg_location = loc.UID()

/mob/living/simple_animal/shade/sword/generic_item/proc/handle_item_deletion(source)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/simple_animal/shade/update_runechat_msg_location()
	if(istype(loc, /obj/item/soulstone) || istype(loc, /obj/item/nullrod/scythe/talking))
		runechat_msg_location = loc.UID()
	else
		return ..()
