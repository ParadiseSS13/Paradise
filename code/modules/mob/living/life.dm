/mob/living/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(notransform)
		return
	if(!loc)
		return
	var/datum/gas_mixture/environment = loc.return_air()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	if(stat != DEAD)
		//Breathing, if applicable
		handle_breathing()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Random events (vomiting etc)
		handle_random_events()

		. = 1

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	handle_fire()

	//stuff in the stomach
	handle_stomach()

	update_gravity(mob_has_gravity())

	update_pulling()

	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(handle_regular_status_updates()) // Status & health update, are we dead or alive etc.
		handle_disabilities() // eye, ear, brain damages
		handle_status_effects() //all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc

	handle_actions()

	update_canmove()

	if(client)
		//regular_hud_updates() //THIS DOESN'T FUCKING UPDATE SHIT
		handle_regular_hud_updates() //IT JUST REMOVES FUCKING HUD IMAGES
	if(get_nations_mode())
		process_nations()

	..()

/mob/living/proc/handle_breathing()
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_stomach()
	return

/mob/living/proc/update_pulling()
	if(pulling)
		if(incapacitated())
			stop_pulling()

//This updates the health and status of the mob (conscious, unconscious, dead)
/mob/living/proc/handle_regular_status_updates()

	updatehealth()

	if(stat != DEAD)

		if(paralysis)
			stat = UNCONSCIOUS

		else if (status_flags & FAKEDEATH)
			stat = UNCONSCIOUS

		else
			stat = CONSCIOUS

		return 1

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	handle_stunned()
	handle_weakened()
	handle_stuttering()
	handle_silent()
	handle_drugged()
	handle_slurring()
	handle_paralysed()
	handle_sleeping()
	handle_slowed()
	handle_drunk()


/mob/living/proc/handle_stunned()
	if(stunned)
		AdjustStunned(-1)
		if(!stunned)
			update_icons()
	return stunned

/mob/living/proc/handle_weakened()
	if(weakened)
		AdjustWeakened(-1)
		if(!weakened)
			update_icons()
	return weakened

/mob/living/proc/handle_stuttering()
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	return stuttering

/mob/living/proc/handle_silent()
	if(silent)
		silent = max(silent-1, 0)
	return silent

/mob/living/proc/handle_drugged()
	if(druggy)
		druggy = max(druggy-1, 0)
	return druggy

/mob/living/proc/handle_slurring()
	if(slurring)
		slurring = max(slurring-1, 0)
	return slurring

/mob/living/proc/handle_paralysed()
	if(paralysis)
		AdjustParalysis(-1)
	return paralysis

/mob/living/proc/handle_sleeping()
	if(sleeping)
		AdjustSleeping(-1)
		throw_alert("asleep", /obj/screen/alert/asleep)
	else
		clear_alert("asleep")
	return sleeping

/mob/living/proc/handle_slowed()
	if(slowed)
		slowed = max(slowed-1, 0)
	return slowed

/mob/living/proc/handle_drunk()
	if(drunk)
		AdjustDrunk(-1)
	return drunk

/mob/living/proc/handle_disabilities()
	//Eyes
	if(sdisabilities & BLIND || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		eye_blind = max(eye_blind, 1)
	else if(eye_blind)			//blindness, heals slowly over time
		eye_blind = max(eye_blind-1,0)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)

	//Ears
	if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
		setEarDamage(-1, max(ear_deaf, 1))
	else
		// deafness heals slowly over time, unless ear_damage is over 100
		if(ear_damage < 100)
			adjustEarDamage(-0.05,-1)

//this handles hud updates. Calls update_vision() and handle_hud_icons()
/mob/living/proc/handle_regular_hud_updates()
	if(!client)	return 0

	handle_vision()
	handle_hud_icons()
	update_action_buttons()

	return 1

/mob/living/proc/handle_vision()
	update_sight()

	if(stat == DEAD)
		return
	if(blinded || eye_blind)
		overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		throw_alert("blind", /obj/screen/alert/blind)
	else
		clear_fullscreen("blind")
		clear_alert("blind")

		if(disabilities & NEARSIGHTED)
			overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		else
			clear_fullscreen("nearsighted")

		if(eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
		else
			clear_fullscreen("blurry")

		if(druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
		else
			clear_fullscreen("high")
			clear_alert("high")

	if(machine)
		if(!machine.check_eye(src))
			reset_view(null)
	else
		if(!remote_view && !client.adminobs)
			reset_view(null)

/mob/living/proc/update_sight()
	return

/mob/living/proc/handle_hud_icons()
	handle_hud_icons_health()
	return

/mob/living/proc/handle_hud_icons_health()
	return

/mob/living/proc/handle_actions()
	//Pretty bad, i'd use picked/dropped instead but the parent calls in these are nonexistent
	for(var/datum/action/A in actions)
		if(A.CheckRemoval(src))
			A.Remove(src)
	for(var/obj/item/I in src)
		give_action_button(I, 1)
	return

/mob/living/proc/give_action_button(var/obj/item/I, recursive = 0)
	if(I.action_button_name)
		if(!I.action)
			if(I.action_button_custom_type)
				I.action = new I.action_button_custom_type
			else
				I.action = new /datum/action/item_action
			I.action.name = I.action_button_name
			I.action.target = I
		I.action.Grant(src)

	if(recursive)
		for(var/obj/item/T in I)
			give_action_button(T, recursive - 1)

/mob/living/update_action_buttons()
	if(!hud_used) return
	if(!client) return

	if(!hud_used.hud_shown)
		return

	client.screen -= hud_used.hide_actions_toggle
	for(var/datum/action/A in actions)
		if(A.button)
			client.screen -= A.button

	if(hud_used.action_buttons_hidden)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.UpdateIcon()

		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,1)

		client.screen += hud_used.hide_actions_toggle
		return

	var/button_number = 0
	for(var/datum/action/A in actions)
		button_number++
		if(A.button == null)
			var/obj/screen/movable/action_button/N = new(hud_used)
			N.owner = A
			A.button = N

		var/obj/screen/movable/action_button/B = A.button

		B.UpdateIcon()

		B.name = A.UpdateName()

		client.screen += B

		if(!B.moved)
			B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			//hud_used.SetButtonCoords(B,button_number)

	if(button_number > 0)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.InitialiseIcon(src)
		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,button_number+1)
		client.screen += hud_used.hide_actions_toggle


/mob/living/proc/process_nations()
	if(client)
		var/client/C = client
		for(var/mob/living/carbon/human/H in view(src, world.view))
			C.images += H.hud_list[NATIONS_HUD]
