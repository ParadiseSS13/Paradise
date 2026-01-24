/datum/action/cooldown/ninja
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	background_icon_state = "bg_ninja"
	button_icon_state = "genetic_view"

/datum/action/cooldown/ninja/ninja_cloak
	name = "Ninja's Stealth"
	desc = "Toggles whether you are currently sneaking, reducing your visibility and movement speed. Enhanced effects in darkness."
	button_icon_state = "vampire_cloak"
	cooldown_time = 2 SECONDS
	var/sneaking = FALSE

/datum/action/cooldown/ninja/ninja_cloak/proc/update_action_name()
	name = "[initial(name)] ([sneaking ? "Deactivate" : "Activate"])"
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME)
	build_all_button_icons()

/datum/action/cooldown/ninja/ninja_cloak/proc/stop_sneaking()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	sneaking = FALSE
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(H, COMSIG_ATTACK)
	UnregisterSignal(H, COMSIG_ATTACK_BY)
	H.set_alpha_tracking(ALPHA_VISIBLE, src)
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOSLOW, src)

/datum/action/cooldown/ninja/ninja_cloak/process()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(H.stat)
		stop_sneaking()
		return
	if(!sneaking)
		stop_sneaking()
		return
	var/turf/simulated/T = get_turf(H)
	var/light_available = T.get_lumcount() * 10

	if(light_available <= 2)
		H.set_alpha_tracking(ALPHA_VISIBLE * 0.1, src)
		return
	H.set_alpha_tracking(ALPHA_VISIBLE * 0.5, src)

/datum/action/cooldown/ninja/ninja_cloak/Activate(atom/target)
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	sneaking = !sneaking
	update_action_name()
	if(sneaking)
		to_chat(H, "<span class='notice'>You are now sneaking around. Stick to the darkness to conceal yourself better.</span>")
		START_PROCESSING(SSobj, src)
		RegisterSignal(owner, COMSIG_ATTACK, PROC_REF(stop_sneaking))
		RegisterSignal(owner, COMSIG_ATTACK_BY, PROC_REF(stop_sneaking))
		ADD_TRAIT(owner, TRAIT_GOTTAGOSLOW, src)
	else
		to_chat(H, "<span class='notice'>You are no longer sneaking around.</span>")
		stop_sneaking()
	StartCooldown()

/datum/action/cooldown/ninja/freedom_shoes
	name = "Ninja's Mobility"
	desc = "Breaks free of leg restraints. 2 Minute cooldown."
	button_icon = 'icons/obj/bio_chips.dmi'
	button_icon_state = "freedom"
	cooldown_time = 2 MINUTES

/datum/action/cooldown/ninja/freedom_shoes/Activate(atom/target)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.clear_legcuffs(TRUE)
	H.SetKnockDown(0)
	H.stand_up(TRUE)
	StartCooldown()

/datum/action/cooldown/ninja/stim_suit
	name = "Ninja's Tenacity"
	desc = "Activates an injector within your suit, pumping you with a small hit of stimulants. 1 Minute cooldown."
	button_icon = 'icons/obj/bio_chips.dmi'
	button_icon_state = "adrenal"
	cooldown_time = 1 MINUTES

/datum/action/cooldown/ninja/stim_suit/Activate(atom/target)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.SetStunned(0)
	H.SetWeakened(0)
	H.SetKnockDown(0)
	H.SetParalysis(0)
	H.adjustStaminaLoss(-75)
	H.stand_up(TRUE)
	SEND_SIGNAL(H, COMSIG_LIVING_CLEAR_STUNS)
	H.reagents.add_reagent("stimulative_agent", 1) // 10 Seconds.
	StartCooldown()
