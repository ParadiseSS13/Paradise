var/static/regex/stun_words = regex("stop|wait|stand still|hold on|halt")
var/static/regex/weaken_words = regex("drop|fall|trip")
var/static/regex/sleep_words = regex("sleep|slumber")
var/static/regex/vomit_words = regex("vomit|throw up")
var/static/regex/silence_words = regex("shut up|silence|ssh|quiet|hush")
var/static/regex/hallucinate_words = regex("see the truth|hallucinate")
var/static/regex/wakeup_words = regex("wake up|awaken")
var/static/regex/heal_words = regex("live|heal|survive|mend|heroes never die")
var/static/regex/hurt_words = regex("die|suffer")
var/static/regex/bleed_words = regex("bleed")
var/static/regex/burn_words = regex("burn|ignite")
var/static/regex/repulse_words = regex("shoo|go away|leave me alone|begone|flee|fus ro dah")
var/static/regex/whoareyou_words = regex("who are you|say your name|state your name|identify")
var/static/regex/saymyname_words = regex("say my name")
var/static/regex/knockknock_words = regex("knock knock")
var/static/regex/statelaws_words = regex("state laws|state your laws")
var/static/regex/move_words = regex("move")
var/static/regex/walk_words = regex("walk|slow down")
var/static/regex/run_words = regex("run")
var/static/regex/helpintent_words = regex("help")
var/static/regex/disarmintent_words = regex("disarm")
var/static/regex/grabintent_words = regex("grab")
var/static/regex/harmintent_words = regex("harm|fight")
var/static/regex/throwmode_words = regex("throw|catch")
var/static/regex/flip_words = regex("flip|rotate|revolve|roll|somersault")
var/static/regex/rest_words = regex("rest")
var/static/regex/getup_words = regex("get up")
var/static/regex/sit_words = regex("sit")
var/static/regex/stand_words = regex("stand")
var/static/regex/dance_words = regex("dance")
var/static/regex/jump_words = regex("jump")
var/static/regex/salute_words = regex("salute")
var/static/regex/deathgasp_words = regex("play dead")
var/static/regex/clap_words = regex("clap|applaud")
var/static/regex/honk_words = regex("ho+nk") //hooooooonk
var/static/regex/multispin_words = regex("like a record baby")

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
	return TRUE

/datum/action/item_action/organ_action/colossus/Trigger()
	. = ..()
	if(!IsAvailable())
		if(world.time < cords.next_command)
			to_chat(owner, "<span class='notice'>You must wait [(cords.next_command - world.time)/10] seconds before Speaking again.</span>")
		return
	var/command = input(owner, "Speak with the Voice of God", "Command")
	if(!command)
		return
	owner.say(".x[command]")

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
	return TRUE

/obj/item/organ/internal/vocal_cords/colossus/handle_speech(message)
	spans = "colossus yell" //reset spans, just in case someone gets deculted or the cords change owner
	if(iscultist(owner))
		spans += " narsiesmall"
	return "<span class=\"[spans]\">[uppertext(message)]</span>"

/obj/item/organ/internal/vocal_cords/colossus/speak_with(message)
	var/log_message = uppertext(message)
	message = lowertext(message)
	playsound(get_turf(owner), 'sound/magic/invoke_general.ogg', 300, 1, 5)

	var/mob/living/list/listeners = list()
	for(var/mob/living/L in get_mobs_in_view(8, owner, TRUE))
		if(!L.ear_deaf && !L.null_rod_check() && L != owner && L.stat != DEAD)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
					continue
			listeners += L

	if(!listeners.len)
		next_command = world.time + cooldown_none
		return

	var/power_multiplier = base_multiplier

	if(owner.mind)
		//Chaplains are very good at speaking with the voice of god
		if(owner.mind.assigned_role == "Chaplain")
			power_multiplier *= 2
		//Command staff has authority
		if(owner.mind.assigned_role in command_positions)
			power_multiplier *= 1.4
		//Why are you speaking
		if(owner.mind.assigned_role == "Mime")
			power_multiplier *= 0.5

	//Cultists are closer to their gods and are more powerful, but they'll give themselves away
	if(iscultist(owner))
		power_multiplier *= 2

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	for(var/V in listeners)
		var/mob/living/L = V
		/*if(L.mind && L.mind.devilinfo && findtext(message, L.mind.devilinfo.truename))
			var/start = findtext(message, L.mind.devilinfo.truename)
			listeners = list(L) //let's be honest you're never going to find two devils with the same name
			power_multiplier *= 5 //if you're a devil and god himself addressed you, you fucked up
			//Cut out the name so it doesn't trigger commands
			message = copytext(message, 0, start)+copytext(message, start + length(L.mind.devilinfo.truename), length(message) + 1)
			break*/
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
	if(findtext(message, stun_words))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Stun(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//WEAKEN
	else if(findtext(message, weaken_words))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Weaken(3 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SLEEP
	else if((findtext(message, sleep_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.Sleeping(2 * power_multiplier)
		next_command = world.time + cooldown_stun

	//VOMIT
	else if((findtext(message, vomit_words)))
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//SILENCE
	else if((findtext(message, silence_words)))
		for(var/mob/living/carbon/C in listeners)
			if(owner.mind && (owner.mind.assigned_role == "Librarian" || owner.mind.assigned_role == "Mime"))
				power_multiplier *= 3
			C.silent += (10 * power_multiplier)
		next_command = world.time + cooldown_stun

	//HALLUCINATE
	else if((findtext(message, hallucinate_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			new /obj/effect/hallucination/delusion(get_turf(L),L,duration=150 * power_multiplier,skip_nearby=0)
		next_command = world.time + cooldown_meme

	//WAKE UP
	else if((findtext(message, wakeup_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SetSleeping(0)
		next_command = world.time + cooldown_damage

	//HEAL
	else if((findtext(message, heal_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier, 0, 0)
		next_command = world.time + cooldown_damage

	//BRUTE DAMAGE
	else if((findtext(message, hurt_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.apply_damage(15 * power_multiplier, def_zone = "chest")
		next_command = world.time + cooldown_damage

	//BLEED
	else if((findtext(message, bleed_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)
		next_command = world.time + cooldown_damage

	//FIRE
	else if((findtext(message, burn_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()
		next_command = world.time + cooldown_damage

	//REPULSE
	else if((findtext(message, repulse_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(L, owner)))
			L.throw_at(throwtarget, 3 * power_multiplier, 1)
		next_command = world.time + cooldown_damage

	//WHO ARE YOU?
	else if((findtext(message, whoareyou_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			/*if(L.mind && L.mind.devilinfo)
				L.say("[L.mind.devilinfo.truename]")
			else*/
			L.say("[L.real_name]")
		next_command = world.time + cooldown_meme

	//SAY MY NAME
	else if((findtext(message, saymyname_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("[owner.name]!") //"Unknown!"
		next_command = world.time + cooldown_meme

	//KNOCK KNOCK
	else if((findtext(message, knockknock_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("Who's there?")
		next_command = world.time + cooldown_meme

	//STATE LAWS
	else if((findtext(message, statelaws_words)))
		for(var/mob/living/silicon/S in listeners)
			S.statelaws(S.laws)
		next_command = world.time + cooldown_stun

	//MOVE
	else if((findtext(message, move_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			step(L, pick(cardinal))
		next_command = world.time + cooldown_meme

	//WALK
	else if((findtext(message, walk_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_WALK)
				L.m_intent = MOVE_INTENT_WALK
				if(L.hud_used)
					L.hud_used.move_intent.icon_state = "walking"
		next_command = world.time + cooldown_meme

	//RUN
	else if((findtext(message, run_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_RUN)
				L.m_intent = MOVE_INTENT_RUN
				if(L.hud_used)
					L.hud_used.move_intent.icon_state = "running"
		next_command = world.time + cooldown_meme

	//HELP INTENT
	else if((findtext(message, helpintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HELP)
		next_command = world.time + cooldown_meme

	//DISARM INTENT
	else if((findtext(message, disarmintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_DISARM)
		next_command = world.time + cooldown_meme

	//GRAB INTENT
	else if((findtext(message, grabintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_GRAB)
		next_command = world.time + cooldown_meme

	//HARM INTENT
	else if((findtext(message, harmintent_words)))
		for(var/mob/living/carbon/human/H in listeners)
			H.a_intent_change(INTENT_HARM)
		next_command = world.time + cooldown_meme

	//THROW/CATCH
	else if((findtext(message, throwmode_words)))
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()
		next_command = world.time + cooldown_meme

	//FLIP
	else if((findtext(message, flip_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("flip")
		next_command = world.time + cooldown_meme

	//REST
	else if((findtext(message, rest_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(!L.resting)
				L.lay_down()
		next_command = world.time + cooldown_meme

	//GET UP
	else if((findtext(message, getup_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.resting)
				L.lay_down() //aka get up
			L.SetStunned(0)
			L.SetWeakened(0)
			L.SetParalysis(0) //i said get up i don't care if you're being tazed
		next_command = world.time + cooldown_damage

	//SIT
	else if((findtext(message, sit_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			for(var/obj/structure/stool/bed/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break
		next_command = world.time + cooldown_meme

	//STAND UP
	else if((findtext(message, stand_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.buckled && istype(L.buckled, /obj/structure/stool/bed/chair))
				L.buckled.unbuckle_mob(L)
		next_command = world.time + cooldown_meme

	//DANCE
	else if((findtext(message, dance_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("dance")
		next_command = world.time + cooldown_meme

	//JUMP
	else if((findtext(message, jump_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.say("HOW HIGH?!!")
			L.emote("jump")
		next_command = world.time + cooldown_meme

	//SALUTE
	else if((findtext(message, salute_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("salute")
		next_command = world.time + cooldown_meme

	//PLAY DEAD
	else if((findtext(message, deathgasp_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("deathgasp")
		next_command = world.time + cooldown_meme

	//PLEASE CLAP
	else if((findtext(message, clap_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("clap")
		next_command = world.time + cooldown_meme

	//HONK
	else if((findtext(message, honk_words)))
		spawn(25)
			playsound(get_turf(owner), 'sound/items/bikehorn.ogg', 300, 1)
		if(owner.mind && owner.mind.assigned_role == "Clown")
			for(var/mob/living/carbon/C in listeners)
				C.slip("your feet", 0, 7 * power_multiplier)
			next_command = world.time + cooldown_stun
		else
			next_command = world.time + cooldown_meme

	//RIGHT ROUND
	else if((findtext(message, multispin_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			L.SpinAnimation(speed = 10, loops = 5)
		next_command = world.time + cooldown_meme

	else
		next_command = world.time + cooldown_none

	message_admins("[key_name_admin(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("[key_name(owner)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
