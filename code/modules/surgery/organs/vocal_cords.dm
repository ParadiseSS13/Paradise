GLOBAL_DATUM_INIT(stun_words, /regex, regex("stop|wait|stand still|hold on|halt"))
GLOBAL_DATUM_INIT(weaken_words, /regex, regex("drop|fall|trip"))
GLOBAL_DATUM_INIT(sleep_words, /regex, regex("sleep|slumber"))
GLOBAL_DATUM_INIT(vomit_words, /regex, regex("vomit|throw up"))
GLOBAL_DATUM_INIT(silence_words, /regex, regex("shut up|silence|ssh|quiet|hush"))
GLOBAL_DATUM_INIT(hallucinate_words, /regex, regex("see the truth|hallucinate"))
GLOBAL_DATUM_INIT(wakeup_words, /regex, regex("wake up|awaken"))
GLOBAL_DATUM_INIT(heal_words, /regex, regex("live|heal|survive|mend|heroes never die"))
GLOBAL_DATUM_INIT(hurt_words, /regex, regex("die|suffer"))
GLOBAL_DATUM_INIT(bleed_words, /regex, regex("bleed"))
GLOBAL_DATUM_INIT(burn_words, /regex, regex("burn|ignite"))
GLOBAL_DATUM_INIT(repulse_words, /regex, regex("shoo|go away|leave me alone|begone|flee|fus ro dah"))
GLOBAL_DATUM_INIT(whoareyou_words, /regex, regex("who are you|say your name|state your name|identify"))
GLOBAL_DATUM_INIT(saymyname_words, /regex, regex("say my name"))
GLOBAL_DATUM_INIT(knockknock_words, /regex, regex("knock knock"))
GLOBAL_DATUM_INIT(statelaws_words, /regex, regex("state laws|state your laws"))
GLOBAL_DATUM_INIT(move_words, /regex, regex("move"))
GLOBAL_DATUM_INIT(walk_words, /regex, regex("walk|slow down"))
GLOBAL_DATUM_INIT(run_words, /regex, regex("run"))
GLOBAL_DATUM_INIT(helpintent_words, /regex, regex("help"))
GLOBAL_DATUM_INIT(disarmintent_words, /regex, regex("disarm"))
GLOBAL_DATUM_INIT(grabintent_words, /regex, regex("grab"))
GLOBAL_DATUM_INIT(harmintent_words, /regex, regex("harm|fight"))
GLOBAL_DATUM_INIT(throwmode_words, /regex, regex("throw|catch"))
GLOBAL_DATUM_INIT(flip_words, /regex, regex("flip|rotate|revolve|roll|somersault"))
GLOBAL_DATUM_INIT(rest_words, /regex, regex("rest"))
GLOBAL_DATUM_INIT(getup_words, /regex, regex("get up"))
GLOBAL_DATUM_INIT(sit_words, /regex, regex("sit"))
GLOBAL_DATUM_INIT(stand_words, /regex, regex("stand"))
GLOBAL_DATUM_INIT(dance_words, /regex, regex("dance"))
GLOBAL_DATUM_INIT(jump_words, /regex, regex("jump"))
GLOBAL_DATUM_INIT(salute_words, /regex, regex("salute"))
GLOBAL_DATUM_INIT(deathgasp_words, /regex, regex("play dead"))
GLOBAL_DATUM_INIT(clap_words, /regex, regex("clap|applaud"))
GLOBAL_DATUM_INIT(honk_words, /regex, regex("ho+nk")) //hooooooonk
GLOBAL_DATUM_INIT(multispin_words, /regex, regex("like a record baby"))

/obj/item/organ/internal/vocal_cords //organs that are activated through speech with the :x channel
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
	var/message = input(owner, "Resonate a message to all nearby golems.", "Resonate")
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
	var/cooldown_stun = 1200
	var/cooldown_damage = 600
	var/cooldown_meme = 300
	var/cooldown_none = 150
	var/base_multiplier = 1
	spans = "colossus yell"

/datum/action/item_action/organ_action/colossus
	name = "Voice of God"
	var/obj/item/organ/internal/vocal_cords/colossus/cords = null

/datum/action/item_action/organ_action/colossus/New()
	..()
	cords = target

/datum/action/item_action/organ_action/colossus/IsAvailable()
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
	var/command = input(owner, "Speak with the Voice of God", "Command")
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
	if(iscultist(owner))
		spans += "narsiesmall"
	return "<span class=\"[spans]\">[uppertext(message)]</span>"

/obj/item/organ/internal/vocal_cords/colossus/speak_with(message)
	var/log_message = uppertext(message)
	message = lowertext(message)
	playsound(get_turf(owner), 'sound/magic/invoke_general.ogg', 300, 1, 5)

	var/list/mob/living/listeners = list()
	for(var/mob/living/L in get_mobs_in_view(8, owner, TRUE))
		if(L.can_hear() && !L.null_rod_check() && L != owner && L.stat != DEAD)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
					continue
			listeners += L

	if(!listeners.len)
		next_command = world.time + cooldown_none
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
	if(iscultist(owner))
		power_multiplier *= 2

	//It's magic, they are a wizard.
	if(iswizard(owner))
		power_multiplier *= 2.5

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	for(var/V in listeners)
		var/mob/living/L = V
		if(findtext(message, L.real_name) == 1)
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.real_name

		else if(L.mind && findtext(message, L.mind.assigned_role) == 1)
			specific_listeners += L //focus on those with the specified job
			//Cut out the job so it doesn't trigger commands
			found_string = L.mind.assigned_role

	if(specific_listeners.len)
		listeners = specific_listeners
		power_multiplier *= (1 + (1/specific_listeners.len)) //2x on a single guy, 1.5x on two and so on
		message = copytext(message, 0, 1)+copytext(message, 1 + length(found_string), length(message) + 1)

	//STUN
	if(findtext(message, GLOB.stun_words))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Stun(6 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(findtext(message, GLOB.weaken_words))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Weaken(6 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//SLEEP
	else if((findtext(message, GLOB.sleep_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Sleeping(4 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//VOMIT
	else if((findtext(message, GLOB.vomit_words)))
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if((findtext(message, GLOB.silence_words)))
		for(var/mob/living/carbon/C in listeners)
			if(owner.mind && (owner.mind.assigned_role == "Librarian" || owner.mind.assigned_role == "Mime"))
				power_multiplier *= 3
			C.AdjustSilence(20 SECONDS * power_multiplier)
		next_command = world.time + cooldown_stun

	//HALLUCINATE
	else if((findtext(message, GLOB.hallucinate_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			new /obj/effect/hallucination/delusion(get_turf(L), L)
		next_command = world.time + cooldown_meme

	//WAKE UP
	else if((findtext(message, GLOB.wakeup_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SetSleeping(0)
		next_command = world.time + cooldown_damage

	//HEAL
	else if((findtext(message, GLOB.heal_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, TRUE, 0, 0)
		next_command = world.time + cooldown_damage

	//BRUTE DAMAGE
	else if((findtext(message, GLOB.hurt_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.apply_damage(15 * power_multiplier, def_zone = "chest")
		next_command = world.time + cooldown_damage

	//BLEED
	else if((findtext(message, GLOB.bleed_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)
		next_command = world.time + cooldown_damage

	//FIRE
	else if((findtext(message, GLOB.burn_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()
		next_command = world.time + cooldown_damage

	//REPULSE
	else if((findtext(message, GLOB.repulse_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at(throwtarget, 3 * power_multiplier, 1)
		next_command = world.time + cooldown_damage

	//WHO ARE YOU?
	else if((findtext(message, GLOB.whoareyou_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			/*if(L.mind && L.mind.devilinfo)
				L.say("[L.mind.devilinfo.truename]")
			else*/
			L.say("[L.real_name]")
		next_command = world.time + cooldown_meme

	//SAY MY NAME
	else if((findtext(message, GLOB.saymyname_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("[owner.name]!") //"Unknown!"
		next_command = world.time + cooldown_meme

	//KNOCK KNOCK
	else if((findtext(message, GLOB.knockknock_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("Who's there?")
		next_command = world.time + cooldown_meme

	//STATE LAWS
	else if((findtext(message, GLOB.statelaws_words)))
		for(var/mob/living/silicon/S in listeners)
			S.statelaws(S.laws)
		next_command = world.time + cooldown_stun

	//MOVE
	else if((findtext(message, GLOB.move_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			step(L, pick(GLOB.cardinal))
		next_command = world.time + cooldown_meme

	//WALK
	else if((findtext(message, GLOB.walk_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_WALK)
				L.m_intent = MOVE_INTENT_WALK
				if(L.hud_used)
					L.hud_used.move_intent.icon_state = "walking"
		next_command = world.time + cooldown_meme

	//RUN
	else if((findtext(message, GLOB.run_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_RUN)
				L.m_intent = MOVE_INTENT_RUN
				if(L.hud_used)
					L.hud_used.move_intent.icon_state = "running"
		next_command = world.time + cooldown_meme

	//HELP INTENT
	else if((findtext(message, GLOB.helpintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HELP)
		next_command = world.time + cooldown_meme

	//DISARM INTENT
	else if((findtext(message, GLOB.disarmintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_DISARM)
		next_command = world.time + cooldown_meme

	//GRAB INTENT
	else if((findtext(message, GLOB.grabintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_GRAB)
		next_command = world.time + cooldown_meme

	//HARM INTENT
	else if((findtext(message, GLOB.harmintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HARM)
		next_command = world.time + cooldown_meme

	//THROW/CATCH
	else if((findtext(message, GLOB.throwmode_words)))
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()
		next_command = world.time + cooldown_meme

	//FLIP
	else if((findtext(message, GLOB.flip_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("flip")
		next_command = world.time + cooldown_meme

	//REST
	else if((findtext(message, GLOB.rest_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(!IS_HORIZONTAL(L))
				L.lay_down()
		next_command = world.time + cooldown_meme

	//GET UP
	else if((findtext(message, GLOB.getup_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(IS_HORIZONTAL(L))
				L.resting = FALSE
				L.stand_up()
			L.SetStunned(0)
			L.SetWeakened(0)
			L.SetKnockDown(0)
			L.SetParalysis(0) //i said get up i don't care if you're being tazed
		next_command = world.time + cooldown_damage

	//SIT
	else if((findtext(message, GLOB.sit_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			for(var/obj/structure/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break
		next_command = world.time + cooldown_meme

	//STAND UP
	else if((findtext(message, GLOB.stand_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.buckled && istype(L.buckled, /obj/structure/chair))
				L.buckled.unbuckle_mob(L)
		next_command = world.time + cooldown_meme

	//DANCE
	else if((findtext(message, GLOB.dance_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("dance")
		next_command = world.time + cooldown_meme

	//JUMP
	else if((findtext(message, GLOB.jump_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("HOW HIGH?!!")
			L.emote("jump")
		next_command = world.time + cooldown_meme

	//SALUTE
	else if((findtext(message, GLOB.salute_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("salute")
		next_command = world.time + cooldown_meme

	//PLAY DEAD
	else if((findtext(message, GLOB.deathgasp_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("deathgasp")
		next_command = world.time + cooldown_meme

	//PLEASE CLAP
	else if((findtext(message, GLOB.clap_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("clap")
		next_command = world.time + cooldown_meme

	//HONK
	else if((findtext(message, GLOB.honk_words)))
		spawn(25)
			playsound(get_turf(owner), 'sound/items/bikehorn.ogg', 300, 1)
		if(owner.mind && owner.mind.assigned_role == "Clown")
			for(var/mob/living/carbon/C in listeners)
				C.slip("your feet", 14 SECONDS * power_multiplier)
			next_command = world.time + cooldown_stun
		else
			next_command = world.time + cooldown_meme

	//RIGHT ROUND
	else if((findtext(message, GLOB.multispin_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SpinAnimation(speed = 10, loops = 5)
		next_command = world.time + cooldown_meme

	else
		next_command = world.time + cooldown_none

	message_admins("[key_name_admin(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("[key_name(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")

/obj/item/organ/internal/vocal_cords/colossus/wizard
	desc = "They carry the voice of an ancient god. This one is enchanted to implant it into yourself when used in hand"

/obj/item/organ/internal/vocal_cords/colossus/wizard/attack_self(mob/living/user)
	user.drop_item()
	insert(user)
