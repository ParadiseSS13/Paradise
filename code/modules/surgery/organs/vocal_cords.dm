#define COOLDOWN_STUN (120 SECONDS)
#define COOLDOWN_DAMAGE (60 SECONDS)
#define COOLDOWN_MEME (30 SECONDS)
#define COOLDOWN_NONE (10 SECONDS)

/// Used to stop listeners with silly or clown-esque (first) names such as "Honk" or "Flip" from screwing up certain commands.
GLOBAL_DATUM(all_voice_of_god_triggers, /regex)
/// List of all voice of god commands
GLOBAL_LIST_INIT(voice_of_god_commands, init_voice_of_god_commands())

/proc/init_voice_of_god_commands()
	. = list()
	var/all_triggers
	var/separator
	for(var/datum/voice_of_god_command/prototype as anything in subtypesof(/datum/voice_of_god_command))
		var/init_trigger = initial(prototype.trigger)
		if(!init_trigger)
			continue
		. += new prototype
		all_triggers += "[separator][init_trigger]"
		separator = "|" // Shouldn't be at the start or end of the regex, or it won't work.
	GLOB.all_voice_of_god_triggers = regex(all_triggers, "i")

/// organs that are activated through speech with the :x channel
/obj/item/organ/internal/vocal_cords
	name = "vocal cords"
	icon_state = "appendix"
	slot = "vocal_cords"
	parent_organ = "mouth"
	var/spans = null

/obj/item/organ/internal/vocal_cords/proc/can_speak_with() //if there is any limitation to speaking with these cords
	return TRUE

/obj/item/organ/internal/vocal_cords/proc/speak_with(message) //do what the organ does
	return

/obj/item/organ/internal/vocal_cords/proc/handle_speech(message) //change the message
	return message

/obj/item/organ/internal/adamantine_resonator
	name = "adamantine resonator"
	desc = "Fragments of adamantine exist in all golems, stemming from their origins as purely magical constructs. These are used to \"hear\" messages from their leaders."
	parent_organ = "head"
	slot = "adamantine_resonator"
	icon_state = "adamantine_resonator"

/obj/item/organ/internal/vocal_cords/adamantine
	name = "adamantine vocal cords"
	desc = "When adamantine resonates, it causes all nearby pieces of adamantine to resonate as well. Adamantine golems use this to broadcast messages to nearby golems."
	actions_types = list(/datum/action/item_action/organ_action/use/adamantine_vocal_cords)
	icon_state = "adamantine_cords"

/datum/action/item_action/organ_action/use/adamantine_vocal_cords/Trigger(left_click)
	if(!IsAvailable())
		return
	var/message = tgui_input_text(owner, "Resonate a message to all nearby golems.", "Resonate")
	if(QDELETED(src) || QDELETED(owner) || !message)
		return
	owner.say(".~[message]")

/obj/item/organ/internal/vocal_cords/adamantine/handle_speech(message)
	var/msg = "<span class='resonate'><span class='name'>[owner.real_name]</span> <span class='message'>resonates, \"[message]\"</span></span>"
	for(var/m in GLOB.player_list)
		if(iscarbon(m))
			var/mob/living/carbon/C = m
			if(C.get_organ_slot("adamantine_resonator"))
				to_chat(C, msg)

//Colossus drop, forces the listeners to obey certain commands
/obj/item/organ/internal/vocal_cords/colossus
	name = "divine vocal cords"
	desc = "They carry the voice of an ancient god."
	icon_state = "voice_of_god"
	actions_types = list(/datum/action/item_action/organ_action/colossus)
	var/next_command = 0
	var/cooldown_multiplier = 1
	var/base_multiplier = 1
	spans = "colossus yell"

/datum/action/item_action/organ_action/colossus
	name = "Voice of God"
	var/obj/item/organ/internal/vocal_cords/colossus/cords = null

/datum/action/item_action/organ_action/colossus/New()
	..()
	cords = target

/datum/action/item_action/organ_action/colossus/IsAvailable(show_message = TRUE)
	if(world.time < cords.next_command)
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak())
		return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	if(istype(owner.loc, /obj/effect/dummy/spell_jaunt))
		to_chat(owner, "<span class='warning'>No one can hear you when you are jaunting, no point in talking now!</span>")
		return FALSE
	return TRUE

/datum/action/item_action/organ_action/colossus/Trigger(left_click)
	. = ..()
	if(!IsAvailable())
		if(world.time < cords.next_command)
			to_chat(owner, "<span class='notice'>You must wait [(cords.next_command - world.time)/10] seconds before Speaking again.</span>")
		return
	var/command = tgui_input_text(owner, "Speak with the Voice of God", "Command")
	if(!command)
		return
	owner.say(".~[command]")

/obj/item/organ/internal/vocal_cords/colossus/prepare_eat()
	return

/obj/item/organ/internal/vocal_cords/colossus/can_speak_with()
	if(world.time < next_command)
		to_chat(owner, "<span class='notice'>You must wait [(next_command - world.time)/10] seconds before Speaking again.</span>")
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak())
		to_chat(owner, "<span class='warning'>You are unable to speak!</span>")
		return FALSE
	if(owner.stat)
		return FALSE
	if(istype(owner.loc, /obj/effect/dummy/spell_jaunt))
		to_chat(owner, "<span class='warning'>No one can hear you when you are jaunting, no point in talking now!</span>")
		return FALSE
	return TRUE

/obj/item/organ/internal/vocal_cords/colossus/handle_speech(message)
	spans = "colossus yell" //reset spans, just in case someone gets deculted or the cords change owner
	if(IS_CULTIST(owner))
		spans += "narsiesmall"
	return "<span class=\"[spans]\">[uppertext(message)]</span>"

/obj/item/organ/internal/vocal_cords/colossus/speak_with(message)
	var/log_message = uppertext(message)
	message = lowertext(message)
	playsound(get_turf(owner), 'sound/magic/invoke_general.ogg', 300, TRUE, 5)

	var/list/mob/living/listeners = list()
	for(var/mob/living/L as anything in get_mobs_in_view(8, owner, TRUE))
		if(L.can_hear() && !L.null_rod_check() && L != owner && L.stat != DEAD)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
					continue
			if(istype(L, /mob/camera/eye/ai))
				var/mob/camera/eye/ai/ai_eye = L
				if(ai_eye.relay_speech && ai_eye.ai)
					listeners += ai_eye.ai
			else
				listeners += L

	if(!length(listeners))
		next_command = world.time + COOLDOWN_NONE
		return

	var/power_multiplier = base_multiplier

	if(owner.mind)
		//Holy characters are very good at speaking with the voice of god
		if(HAS_MIND_TRAIT(owner, TRAIT_HOLY))
			power_multiplier *= 2
		//Command staff has authority
		if(owner.mind.assigned_role in GLOB.command_positions)
			power_multiplier *= 1.4
		//Why are you speaking
		if(owner.mind.assigned_role == "Mime")
			power_multiplier *= 0.5

	//Cultists are closer to their gods and are more powerful, but they'll give themselves away
	if(IS_CULTIST(owner))
		power_multiplier *= 2

	//It's magic, they are a wizard.
	if(iswizard(owner))
		power_multiplier *= 2.5

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	// string to remove at the end of the following of the following loop, so saying "Burn Mr. Hopkins" doesn't also burn the HoP later when we check jobs.
	var/to_remove_string
	for(var/mob/living/candidate in listeners)
		//Let's ensure the listener's name is not matched within another word or command (and vice-versa). e.g. "Saul" in "somersault"
		var/their_first_name = first_name(candidate.name)
		if(!GLOB.all_voice_of_god_triggers.Find(their_first_name) && findtext(message, regex("(\\L|^)[their_first_name](\\L|$)", "i")))
			specific_listeners += candidate //focus on those with the specified name
			to_remove_string += "[to_remove_string ? "|" : null][their_first_name]"
			continue
		var/their_last_name = last_name(candidate.name)
		if(their_last_name != their_first_name && !GLOB.all_voice_of_god_triggers.Find(their_last_name) && findtext(message, regex("(\\L|^)[their_last_name](\\L|$)", "i")))
			specific_listeners += candidate // Ditto
			to_remove_string += "[to_remove_string ? "|" : null][their_last_name]"

	if(to_remove_string)
		to_remove_string = "(\\L|^)([to_remove_string])(\\L|$)"
		message = replacetext(message, regex(to_remove_string, "i"), "")

	//Now get the proper job titles and check for matches.
	var/job_message = get_full_job_name(message)
	for(var/mob/living/candidate in listeners)
		var/their_role = candidate.mind?.assigned_role
		if(their_role && findtext(job_message, lowertext(their_role)))
			specific_listeners |= candidate //focus on those with the specified job. "|=" instead "+=" so "Mrs. Capri the Captain" doesn't get affected twice.

	if(length(specific_listeners))
		listeners = specific_listeners
		power_multiplier *= (1 + (1/length(specific_listeners))) //2x on a single guy, 1.5x on two and so on


	for(var/datum/voice_of_god_command/command as anything in GLOB.voice_of_god_commands)
		if(findtext(message, command.trigger))
			. = command.execute(listeners, owner, power_multiplier, message) || command.cooldown
			break

	message_admins("[key_name_admin(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("[key_name(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	next_command = world.time + .

/// Voice of god command datums that are used in [/proc/voice_of_god()]
/datum/voice_of_god_command
	///a text string or regex that triggers the command.
	var/trigger
	/// Is the trigger supposed to be a regex? If so, convert it to such on New()
	var/is_regex = TRUE
	/// cooldown variable which is normally returned to [proc/voice_of_god] and used as its return value.
	var/cooldown = COOLDOWN_MEME

/datum/voice_of_god_command/New()
	if(is_regex)
		trigger = regex(trigger)

/*
 * What happens when the command is triggered.
 * If a return value is set, it'll be used in place of the 'cooldown' var.
 * Args:
 * * listeners: the list of living mobs who are affected by the command.
 * * user: the one who casted Voice of God
 * * power_multiplier: multiplies the power of the command, most times.
 */
/datum/voice_of_god_command/proc/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	return

/datum/voice_of_god_command/stun
	trigger = "stop|wait|stand\\s*still|hold\\s*on|halt"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/stun/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.Stun(6 SECONDS * power_multiplier)

/datum/voice_of_god_command/weaken
	trigger = "drop|fall|trip"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/knockdown/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.Weaken(6 SECONDS * power_multiplier)

/datum/voice_of_god_command/sleeping
	trigger = "sleep|slumber"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/sleeping/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.Sleeping(4 SECONDS * power_multiplier)

/datum/voice_of_god_command/vomit
	trigger = "vomit|throw\\s*up|sick"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/vomit/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		target.vomit(10 * power_multiplier)

/// This command silences the listeners. Thrice as effective is the user is a mime or curator.
/datum/voice_of_god_command/silence
	trigger = "shut\\s*up|silence|be\\s*silent|ssh|quiet|hush"
	cooldown = COOLDOWN_STUN

/datum/voice_of_god_command/silence/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	if(user.mind && (user.mind.assigned_role == "Librarian" || user.mind.assigned_role == "Mime"))
		power_multiplier *= 3
	for(var/mob/living/carbon/target in listeners)
		target.AdjustSilence(20 SECONDS * power_multiplier)

/// This command makes the listeners see others as corgis, carps, skellies etcetera etcetera.
/datum/voice_of_god_command/hallucinate
	trigger = "see\\s*the\\s*truth|hallucinate"

/datum/voice_of_god_command/hallucinate/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target in listeners)
		new /obj/effect/hallucination/delusion(get_turf(target), target)

/// This command wakes up the listeners.
/datum/voice_of_god_command/wake_up
	trigger = "wake\\s*up|awaken"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/wake_up/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SetSleeping(0)

/// This command heals the listeners for 10 points of total damage.
/datum/voice_of_god_command/heal
	trigger = "live|heal|survive|mend|life|heroes\\s*never\\s*die"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/heal/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, TRUE, 0, 0)

/// This command applies 15 points of brute damage to the listeners. There's subtle theological irony in this being more powerful than healing.
/datum/voice_of_god_command/brute
	trigger = "die|suffer|hurt|pain|death"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/brute/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.apply_damage(15 * power_multiplier, def_zone = "chest")

/// This command makes carbon listeners bleed from a random body part.
/datum/voice_of_god_command/bleed
	trigger = "bleed|there\\s*will\\s*be\\s*blood"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/bleed/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/human/H in listeners)
		H.bleed_rate += (5 * power_multiplier)

/// This command sets the listeners ablaze.
/datum/voice_of_god_command/burn
	trigger = "burn|ignite"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/burn/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_fire_stacks(3 * power_multiplier)
		target.IgniteMob()

/// This command throws the listeners away from the user.
/datum/voice_of_god_command/repulse
	trigger = "shoo|go\\s*away|leave\\s*me\\s*alone|begone|flee|fus\\s*ro\\s*dah|get\\s*away|repulse|back\\s*you\\s*savages"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/repulse/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(target, user)))
		target.throw_at(throwtarget, 3 * power_multiplier, 1 * power_multiplier)


/// This command throws the listeners at the user.
/datum/voice_of_god_command/attract
	trigger = "come\\s*here|come\\s*to\\s*me|get\\s*over\\s*here|attract"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/attract/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.throw_at(get_step_towards(user, target), 3 * power_multiplier, 1 * power_multiplier)

/// This command forces the listeners to say their true name (so masks and hoods won't help).
/// Basic and simple mobs who are forced to state their name and don't have one already will... reveal their actual one!
/datum/voice_of_god_command/who_are_you
	trigger = "who\\s*are\\s*you|say\\s*your\\s*name|state\\s*your\\s*name|identify"

/datum/voice_of_god_command/who_are_you/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.say("[target.real_name]")

/// This command forces the listeners to say the user's name
/datum/voice_of_god_command/say_my_name
	trigger = "say\\s*my\\s*name|who\\s*am\\s*i"

/datum/voice_of_god_command/say_my_name/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/regex/smartass_regex = regex(@"^say my name[.!]*$")
	for(var/mob/living/target as anything in listeners)
		var/to_say = user.name
		// 0.1% chance to be a smartass
		if(findtext(lowertext(message), smartass_regex) && prob(0.1))
			to_say = "My name"
		target.say("[to_say]!") //"Unknown!"

/// This command forces the listeners to say "Who's there?".
/datum/voice_of_god_command/knock_knock
	trigger = "knock\\s*knock"

/datum/voice_of_god_command/knock_knock/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.say("Who's there?") //"Unknown

/// This command forces silicon listeners to state all their laws.
/datum/voice_of_god_command/state_laws
	trigger = "state\\s*(your)?\\s*laws"

/datum/voice_of_god_command/state_laws/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/silicon/target in listeners)
		target.statelaws(target.laws)

/// This command forces the listeners to take step in a direction chosen by the user, otherwise a random cardinal one.
/datum/voice_of_god_command/move
	trigger = "move"
	var/static/up_words = regex("up|north|fore")
	var/static/down_words = regex("down|south|aft")
	var/static/left_words = regex("left|west|port")
	var/static/right_words = regex("right|east|starboard")

/datum/voice_of_god_command/move/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	var/direction
	if(findtext(message, up_words))
		direction = NORTH
	else if(findtext(message, down_words))
		direction = SOUTH
	else if(findtext(message, left_words))
		direction = WEST
	else if(findtext(message, right_words))
		direction = EAST
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, direction || pick(GLOB.cardinal)), 1 SECONDS * (iteration - 1))
		iteration++

/// This command forces the listeners to switch to walk intent.
/datum/voice_of_god_command/walk
	trigger = "slow\\s*down|walk"

/datum/voice_of_god_command/walk/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.m_intent != MOVE_INTENT_WALK)
			target.m_intent = MOVE_INTENT_WALK
			if(target.hud_used)
				target.hud_used.move_intent.icon_state = "walking"

/// This command forces the listeners to switch to run intent.
/datum/voice_of_god_command/run
	trigger = "run"
	is_regex = FALSE

/datum/voice_of_god_command/run/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.m_intent != MOVE_INTENT_RUN)
			target.m_intent = MOVE_INTENT_RUN
			if(target.hud_used)
				target.hud_used.move_intent.icon_state = "running"

/// This command turns the listeners' throw mode on.
/datum/voice_of_god_command/throw_catch
	trigger = "throw|catch"

/datum/voice_of_god_command/throw_catch/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		target.throw_mode_on()

/datum/voice_of_god_command/help
	trigger = "help|pacify"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/help/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/human/H in listeners)
		H.apply_status_effect(STATUS_EFFECT_PACIFIED, 10 SECONDS * power_multiplier)

/// This command forces the listeners to get the fuck up, resetting all stuns.
/datum/voice_of_god_command/getup
	trigger = "get\\s*up"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/getup/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SetWeakened(0)
		target.SetStunned(0)
		target.SetKnockDown(0)
		target.SetParalysis(0)
		target.setStaminaLoss(0)
		target.stand_up(TRUE)
		SEND_SIGNAL(target, COMSIG_LIVING_CLEAR_STUNS)

/// This command forces each listener to buckle to a chair found on the same tile.
/datum/voice_of_god_command/sit
	trigger = "sit"
	is_regex = FALSE

/datum/voice_of_god_command/sit/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		for(var/obj/structure/chair/chair in get_turf(target))
			chair.buckle_mob(target)
			break

/// This command forces each listener to unbuckle from whatever they are buckled to.
/datum/voice_of_god_command/stand
	trigger = "stand"
	is_regex = FALSE

/datum/voice_of_god_command/stand/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.unbuckle()

/datum/voice_of_god_command/rest
	trigger = "rest"
	is_regex = FALSE

/datum/voice_of_god_command/rest/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(!IS_HORIZONTAL(target))
			target.lay_down()

/// This command forces the listener to do the jump emote 3/4 of the times or reply "HOW HIGH?!!".
/datum/voice_of_god_command/jump
	trigger = "jump"
	is_regex = FALSE

/datum/voice_of_god_command/jump/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		if(prob(25))
			target.say("HOW HIGH?!!")
		else
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/, emote), "jump"), 0.5 SECONDS * iteration)
		iteration++

///This command plays a bikehorn sound after 2 seconds and a half have passed, and also slips listeners if the user is a clown.
/datum/voice_of_god_command/honk
	trigger = "ho+nk"

/datum/voice_of_god_command/honk/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(user), 'sound/items/bikehorn.ogg', 300, 1), 2.5 SECONDS)
	if(user.mind && user.mind.assigned_role == "Clown")
		. = COOLDOWN_STUN //it slips.
		for(var/mob/living/carbon/target in listeners)
			target.slip(14 SECONDS * power_multiplier)

///This command spins the listeners 1800° degrees clockwise.
/datum/voice_of_god_command/multispin
	trigger = "like\\s*a\\s*record\\s*baby|right\\s*round"

/datum/voice_of_god_command/multispin/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SpinAnimation(speed = 10, loops = 5)

/// Supertype of all those commands that make people emote and nothing else. Fuck copypasta.
/datum/voice_of_god_command/emote
	/// The emote to run.
	var/emote_name = "dance"

/datum/voice_of_god_command/emote/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/, emote), emote_name), 0.5 SECONDS * iteration)
		iteration++

/datum/voice_of_god_command/emote/flip
	trigger = "flip|rotate|revolve|roll|somersault"
	emote_name = "flip"

/datum/voice_of_god_command/emote/dance
	trigger = "dance"
	is_regex = FALSE

/datum/voice_of_god_command/emote/salute
	trigger = "salute"
	emote_name = "salute"
	is_regex = FALSE

/datum/voice_of_god_command/emote/play_dead
	trigger = "play\\s*dead"
	emote_name = "deathgasp"

/datum/voice_of_god_command/emote/clap
	trigger = "clap|applaud"
	emote_name = "clap"

/obj/item/organ/internal/vocal_cords/colossus/wizard
	desc = "They carry the voice of an ancient god. This one is enchanted to implant it into yourself when used in hand."
	var/has_implanted = FALSE

/obj/item/organ/internal/vocal_cords/colossus/wizard/attack_self__legacy__attackchain(mob/living/user)
	if(has_implanted)
		return
	user.drop_item()
	insert(user)
	has_implanted = TRUE

#undef COOLDOWN_STUN
#undef COOLDOWN_DAMAGE
#undef COOLDOWN_MEME
#undef COOLDOWN_NONE
