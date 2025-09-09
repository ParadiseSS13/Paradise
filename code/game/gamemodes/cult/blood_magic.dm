/// Blood magic handles the creation of blood spells (formerly talismans)
/datum/action/innate/cult/blood_magic
	name = "Prepare Blood Magic"
	button_icon_state = "carve"
	desc = "Prepare blood magic by carving runes into your flesh. This is easier with an <b>empowering rune</b>."
	default_button_position = DEFAULT_BLOODSPELLS
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/cult/blood_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/cult/blood_magic/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	for(var/obj/effect/rune/empower/R in range(1, owner))
		rune = TRUE
		limit = MAX_BLOODCHARGE
		break
	if(length(spells) >= limit)
		if(rune)
			to_chat(owner, "<span class='cultitalic'>You cannot store more than [MAX_BLOODCHARGE] spell\s. <b>Pick a spell to remove.</b></span>")
			remove_spell("You cannot store more than [MAX_BLOODCHARGE] spell\s, pick a spell to remove.")
		else
			to_chat(owner, "<span class='cultitalic'>You cannot store more than [RUNELESS_MAX_BLOODCHARGE] spell\s without an empowering rune! <b>Pick a spell to remove.</b></span>")
			remove_spell("You cannot store more than [RUNELESS_MAX_BLOODCHARGE] spell\s without an empowering rune, pick a spell to remove.")
		return
	var/entered_spell_name
	var/datum/action/innate/cult/blood_spell/BS
	var/list/possible_spells = list()

	for(var/I in subtypesof(/datum/action/innate/cult/blood_spell))
		var/datum/action/innate/cult/blood_spell/J = I
		var/cult_name = initial(J.name)
		possible_spells[cult_name] = J
	if(length(spells))
		possible_spells += "(REMOVE SPELL)"
	entered_spell_name = tgui_input_list(owner, "Pick a blood spell to prepare...", "Spell Choices", possible_spells)
	if(entered_spell_name == "(REMOVE SPELL)")
		remove_spell()
		return
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS || (rune && !(locate(/obj/effect/rune/empower) in range(1, owner))) || (length(spells) >= limit))
		return

	if(!channeling)
		channeling = TRUE
		to_chat(owner, "<span class='cultitalic'>You begin to carve unnatural symbols into your flesh!</span>")
	else
		to_chat(owner, "<span class='warning'>You are already invoking blood magic!</span>")
		return

	if(do_after(owner, 100 - rune * 60, target = owner))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.dna && (NO_BLOOD in H.dna.species.species_traits))
				H.cult_self_harm(3 - rune * 2)
			else
				H.bleed(20 - rune * 12)
		var/datum/action/innate/cult/blood_spell/new_spell = new BS(owner)
		spells += new_spell
		new_spell.Grant(owner, src)
		to_chat(owner, "<span class='cult'>Your wounds glow with power, you have prepared a [new_spell.name] invocation!</span>")
		SSblackbox.record_feedback("tally", "cult_spells_prepared", 1, "[new_spell.name]")
	channeling = FALSE

/datum/action/innate/cult/blood_magic/proc/remove_spell()
	var/nullify_spell = tgui_input_list(owner, "Pick a spell to remove", "Current Spells", spells)
	if(nullify_spell)
		qdel(nullify_spell)

/// The next generation of talismans, handles storage/creation of blood magic
/datum/action/innate/cult/blood_spell
	name = "Blood Magic"
	button_icon_state = "telerune"
	desc = "Fear the Old Blood."
	default_button_position = SCRN_OBJ_CULT_LIST
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/blood_magic/hand_magic
	var/datum/action/innate/cult/blood_magic/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation = "Hoi there something's wrong!"
	var/health_cost = 0
	/// Have we already been positioned into our starting location?
	var/positioned = FALSE
	var/mutable_appearance/button_charge_count

/datum/action/innate/cult/blood_spell/New(target)
	. = ..()
	button_charge_count = image('icons/effects/effects.dmi', icon_state = "nothing")

/datum/action/innate/cult/blood_spell/proc/get_panel_text()
	if(initial(charges) == 1)
		return
	var/available_charges = hand_magic ? "[hand_magic.uses]" : "[charges]"
	return "[available_charges]/[initial(charges)]"

/datum/action/innate/cult/blood_spell/update_button_status(atom/movable/screen/movable/action_button/button, force)
	. = ..()
	if(!button)
		return
	button.overlays -= button_charge_count

	var/text = get_panel_text()
	if(!text || !button)
		return
	button_charge_count.maptext = "<div style=\"font-size:8pt;color:white;font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
	button.overlays |= button_charge_count

/datum/action/innate/cult/blood_spell/Grant(mob/living/owner, datum/action/innate/cult/blood_magic/BM)
	if(health_cost)
		desc += "<br>Deals <u>[health_cost] damage</u> to your arm per use."
	base_desc = desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	all_magic = BM
	// todo blood magic guh
	// button.ordered = FALSE
	..()

/datum/action/innate/cult/blood_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/cult/blood_spell/IsAvailable(show_message = TRUE)
	if(!IS_CULTIST(owner) || owner.incapacitated() || !charges)
		return FALSE
	return ..()

/datum/action/innate/cult/blood_spell/Activate()
	if(owner.holy_check())
		return
	if(magic_path) // If this spell flows from the hand
		if(!hand_magic) // If you don't already have the spell active
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, "<span class='warning'>You have no empty hand for invoking blood magic!</span>")
				return
			to_chat(owner, "<span class='cultitalic'>Your wounds glow as you invoke the [name].</span>")

		else // If the spell is active, and you clicked on the button for it
			qdel(hand_magic)
			hand_magic = null

//the spell list

/datum/action/innate/cult/blood_spell/stun
	name = "Stun"
	desc = "Will knock down and mute a victim on contact. Strike them with a cult blade to complete the invocation, stunning them and extending the mute."
	button_icon_state = "stun"
	magic_path = /obj/item/melee/blood_magic/stun
	health_cost = 10

/datum/action/innate/cult/blood_spell/teleport
	name = "Teleport"
	desc = "Empowers your hand to teleport yourself or another cultist to a teleport rune on contact."
	button_icon_state = "teleport"
	magic_path = /obj/item/melee/blood_magic/teleport
	health_cost = 7

/datum/action/innate/cult/blood_spell/emp
	name = "Electromagnetic Pulse"
	desc = "Releases an Electromagnetic Pulse, affecting nearby non-cultists. <b>The pulse will still affect you.</b>"
	button_icon_state = "emp"
	health_cost = 10
	invocation = "Ta'gh fara'qha fel d'amar det!"

/datum/action/innate/cult/blood_spell/emp/Grant(mob/living/owner)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/oof = FALSE
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(E.is_robotic())
				oof = TRUE
				break
		if(!oof)
			for(var/obj/item/organ/internal/I in H.internal_organs)
				if(I.is_robotic())
					oof = TRUE
					break
		if(oof)
			to_chat(owner, "<span class='userdanger'>You get the feeling this is a bad idea.</span>")
	..()

/datum/action/innate/cult/blood_spell/emp/Activate()
	if(owner.holy_check())
		return
	owner.visible_message("<span class='warning'>[owner]'s body flashes a bright blue!</span>", \
						"<span class='cultitalic'>You speak the cursed words, channeling an electromagnetic pulse from your body.</span>")
	owner.emp_act(EMP_LIGHT)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(empulse), owner, 2, 5, TRUE, "cult")
	owner.whisper(invocation)
	charges--
	if(charges <= 0)
		qdel(src)

/datum/action/innate/cult/blood_spell/shackles
	name = "Shadow Shackles"
	desc = "Empowers your hand to start handcuffing victim on contact, and mute them if successful."
	button_icon_state = "shackles"
	charges = 4
	magic_path = /obj/item/melee/blood_magic/shackles

/datum/action/innate/cult/blood_spell/construction
	name = "Twisted Construction"
	desc = "Empowers your hand to corrupt certain metalic objects.<br><u>Converts:</u><br>Plasteel into runed metal<br>50 metal into a construct shell<br>Cyborg shells into construct shells<br>Airlocks into brittle runed airlocks after a delay (harm intent)"
	button_icon_state = "transmute"
	magic_path = "/obj/item/melee/blood_magic/construction"
	health_cost = 12

/datum/action/innate/cult/blood_spell/dagger
	name = "Summon Dagger"
	desc = "Summon a ritual dagger, necessary to scribe runes."
	button_icon_state = "cult_dagger"

/datum/action/innate/cult/blood_spell/dagger/New()
	button_icon_state = GET_CULT_DATA(dagger_icon, "cult_dagger")
	..()

/datum/action/innate/cult/blood_spell/dagger/Activate()
	var/turf/T = get_turf(owner)
	owner.visible_message("<span class='warning'>[owner]'s hand glows red for a moment.</span>", \
						"<span class='cultitalic'>Red light begins to shimmer and take form within your hand!</span>")
	var/obj/item/melee/cultblade/dagger/O = new(T)
	if(owner.put_in_hands(O))
		to_chat(owner, "<span class='warning'>A [O.name] appears in your hand!</span>")
	else
		owner.visible_message("<span class='warning'>A [O.name] appears at [owner]'s feet!</span>", \
							"<span class='cultitalic'>A [O.name] materializes at your feet.</span>")
	playsound(owner, 'sound/magic/cult_spell.ogg', 25, TRUE, SOUND_RANGE_SET(4))
	charges--
	desc = base_desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	if(charges <= 0)
		qdel(src)

/datum/action/innate/cult/blood_spell/equipment
	name = "Summon Equipment"
	desc = "Empowers your hand to summon combat gear onto a cultist you touch, including cult armor into open slots, a cult bola, and a cult sword."
	button_icon_state = "equip"
	magic_path = /obj/item/melee/blood_magic/armor

/datum/action/innate/cult/blood_spell/horror
	name = "Hallucinations"
	desc = "Gives hallucinations to a target at range. A silent and invisible spell."
	button_icon_state = "horror"
	var/datum/spell/horror/PH
	charges = 4

/datum/action/innate/cult/blood_spell/horror/New()
	PH = new()
	PH.attached_action = src
	..()

/datum/action/innate/cult/blood_spell/horror/Destroy()
	var/datum/spell/horror/destroy = PH
	. = ..()
	if(!QDELETED(destroy))
		QDEL_NULL(destroy)

/datum/action/innate/cult/blood_spell/horror/Activate()
	PH.toggle(owner) //the important bit
	return TRUE

/datum/spell/horror
	ranged_mousepointer = 'icons/mouse_icons/cult_target.dmi'
	var/datum/action/innate/cult/blood_spell/attached_action

/datum/spell/horror/Destroy()
	var/datum/action/innate/cult/blood_spell/AA = attached_action
	. = ..()
	if(!QDELETED(AA))
		QDEL_NULL(AA)

/datum/spell/horror/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability(user, "<span class='cult'>You dispel the magic...</span>")
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to horrify a target...</span>")

/datum/spell/horror/InterceptClickOn(mob/living/user, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !IS_CULTIST(user))
		user.ranged_ability.remove_ranged_ability(user)
		return
	if(user.holy_check())
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, ranged_ability_user))
		if(!ishuman(target) || IS_CULTIST(target))
			return
		var/mob/living/carbon/human/H = target
		H.Hallucinate(120 SECONDS)
		attached_action.charges--
		attached_action.desc = attached_action.base_desc
		attached_action.desc += "<br><b><u>Has [attached_action.charges] use\s remaining</u></b>."
		attached_action.build_all_button_icons()
		user.ranged_ability.remove_ranged_ability(user, "<span class='cult'><b>[H] has been cursed with living nightmares!</b></span>")
		if(attached_action.charges <= 0)
			to_chat(ranged_ability_user, "<span class='cult'>You have exhausted the spell's power!</span>")
			qdel(src)

/datum/action/innate/cult/blood_spell/veiling
	name = "Conceal Presence"
	desc = "Alternates between hiding and revealing nearby cult structures, cult airlocks and runes."
	invocation = "Kla'atu barada nikt'o!"
	button_icon_state = "veiling"
	charges = 10
	var/revealing = FALSE //if it reveals or not

/datum/action/innate/cult/blood_spell/veiling/Activate()
	if(owner.holy_check())
		return
	if(!revealing) // Hiding stuff
		owner.visible_message("<span class='warning'>Thin grey dust falls from [owner]'s hand!</span>", \
		"<span class='cultitalic'>You invoke the veiling spell, hiding nearby runes and cult structures.</span>")
		charges--
		if(!SSticker.mode.cult_team.cult_risen || !SSticker.mode.cult_team.cult_ascendant)
			playsound(owner, 'sound/magic/smoke.ogg', 25, TRUE, SOUND_RANGE_SET(4)) // If Cult is risen/ascendant.
		else
			playsound(owner, 'sound/magic/smoke.ogg', 25, TRUE, SOUND_RANGE_SET(1)) // If Cult is unpowered.
		owner.whisper(invocation)
		for(var/obj/O in range(4, owner))
			O.cult_conceal()
		revealing = TRUE // Switch on use
		name = "Reveal Runes"
		button_icon_state = "revealing"

	else // Unhiding stuff
		owner.visible_message("<span class='warning'>A flash of light shines from [owner]'s hand!</span>", \
		"<span class='cultitalic'>You invoke the counterspell, revealing nearby runes and cult structures.</span>")
		charges--
		owner.whisper(invocation)
		if(!SSticker.mode.cult_team.cult_risen || !SSticker.mode.cult_team.cult_ascendant)
			playsound(owner, 'sound/misc/enter_blood.ogg', 25, TRUE, SOUND_RANGE_SET(7)) // If Cult is risen/ascendant.
		else
			playsound(owner, 'sound/magic/smoke.ogg', 25, TRUE, SOUND_RANGE_SET(1)) // If Cult is unpowered.
		for(var/obj/O in range(5, owner)) // Slightly higher in case we arent in the exact same spot
			O.cult_reveal()
		revealing = FALSE // Switch on use
		name = "Conceal Runes"
		button_icon_state = "veiling"
	if(charges <= 0)
		qdel(src)
	desc = "[revealing ? "Reveals" : "Conceals"] nearby cult structures, airlocks, and runes."
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	build_all_button_icons()

/datum/action/innate/cult/blood_spell/manipulation
	name = "Blood Rites"
	desc = "Empowers your hand to manipulate blood. Use on blood or a noncultist to absorb blood to be used later, use on yourself or another cultist to heal them using absorbed blood. \
		\nUse the spell in-hand to cast advanced rites, such as summoning a magical blood spear, firing blood projectiles out of your hands, and more!"
	invocation = "Fel'th Dol Ab'orod!"
	button_icon_state = "manip"
	charges = 5
	magic_path = /obj/item/melee/blood_magic/manipulator

/datum/action/innate/cult/blood_spell/manipulation/get_panel_text()
	return hand_magic ? "[hand_magic.uses]" : "[charges]"

// The "magic hand" items
/obj/item/melee/blood_magic
	name = "magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 0
	throw_speed = 0
	/// Does it have a source, AKA bloody empowerment.
	var/has_source = TRUE
	var/invocation
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the spell
	var/datum/action/innate/cult/blood_spell/source
	var/antimagic_flags = MAGIC_RESISTANCE_HOLY

/obj/item/melee/blood_magic/Initialize(mapload, spell)
	. = ..()
	if(spell && has_source)
		source = spell
		uses = source.charges
		health_cost = source.health_cost

/obj/item/melee/blood_magic/Destroy()
	if(has_source && !QDELETED(source))
		if(uses <= 0)
			source.hand_magic = null
			qdel(source)
			source = null
		else
			source.hand_magic = null
			source.charges = uses
			source.desc = source.base_desc
			source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
			source.build_all_button_icons()
	return ..()

/obj/item/melee/blood_magic/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_their(TRUE)] [owner.l_hand == src ? "left hand" : "right hand"] is burning in blood-red fire.</span>"

/obj/item/melee/blood_magic/attack_self__legacy__attackchain(mob/living/user)
	attackby__legacy__attackchain(user, user, TRUE)

/obj/item/melee/blood_magic/attack__legacy__attackchain(mob/living/M, mob/living/carbon/user)
	if(!iscarbon(user) || !IS_CULTIST(user))
		uses = 0
		qdel(src)
		return
	if(M.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(user, "<span class='danger'>[M] absorbs your spell!</span>")
		uses = 0
		qdel(src)
		return
	add_attack_logs(user, M, "used a cult spell ([src]) on")
	M.store_last_attacker(user)

/obj/item/melee/blood_magic/afterattack__legacy__attackchain(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(invocation)
		user.whisper(invocation)
	if(health_cost && ishuman(user))
		user.cult_self_harm(health_cost)
	if(uses <= 0)
		qdel(src)
	else if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
		source.build_all_button_icons()

//The spell effects

//stun
/obj/item/melee/blood_magic/stun
	name = "Stunning Aura"
	desc = "Will knock down and mute a victim on contact. Strike them with a cult blade to complete the invocation, stunning them and extending the mute."
	color = RUNE_COLOR_RED
	invocation = "Fuu ma'jin!"

/obj/item/melee/blood_magic/stun/afterattack__legacy__attackchain(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity)
		return
	var/mob/living/L = target
	if(IS_CULTIST(target))
		return
	if(user.holy_check())
		return
	user.visible_message("<span class='warning'>[user] holds up [user.p_their()] hand, which explodes in a flash of red light!</span>", \
							"<span class='cultitalic'>You attempt to stun [L] with the spell!</span>")

	user.mob_light(LIGHT_COLOR_BLOOD_MAGIC, 3, _duration = 2)

	var/obj/item/nullrod/N = locate() in target
	if(N)
		target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the red light!</span>", \
							"<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
	else
		to_chat(user, "<span class='cultitalic'>In a brilliant flash of red, [L] falls to the ground!</span>")

		L.apply_status_effect(STATUS_EFFECT_CULT_STUN)
		L.Silence(6 SECONDS)
		if(issilicon(target))
			var/mob/living/silicon/S = L
			S.emp_act(EMP_HEAVY)
		else if(iscarbon(target))
			var/mob/living/carbon/C = L
			C.KnockDown(10 SECONDS)
			C.apply_damage(60, STAMINA)
			C.flash_eyes(1, TRUE)
			C.Stuttering(16 SECONDS)
			C.CultSlur(20 SECONDS)
			C.Jitter(16 SECONDS)
		to_chat(user, "<span class='boldnotice'>Stun mark applied! Stab them with a dagger, sword or blood spear to stun them fully!</span>")
	user.do_attack_animation(target)
	uses--
	..()


//Teleportation
/obj/item/melee/blood_magic/teleport
	name = "Teleporting Aura"
	color = RUNE_COLOR_TELEPORT
	desc = "Will teleport a cultist to a teleport rune on contact."
	invocation = "Sas'so c'arta forbici!"

/obj/item/melee/blood_magic/teleport/afterattack__legacy__attackchain(atom/target, mob/living/carbon/user, proximity)
	if(user.holy_check())
		return
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()
	var/atom/movable/teleportee
	if(!IS_CULTIST(target) || !proximity)
		to_chat(user, "<span class='warning'>You can only teleport adjacent cultists with this spell!</span>")
		return
	if(user != target) // So that the teleport effect shows on the correct mob
		teleportee = target
	else
		teleportee = user

	for(var/R in GLOB.teleport_runes)
		var/obj/effect/rune/teleport/T = R
		var/resultkey = T.listkey
		if(resultkey in teleportnames)
			duplicaterunecount[resultkey]++
			resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
		else
			teleportnames.Add(resultkey)
			duplicaterunecount[resultkey] = 1
		potential_runes[resultkey] = T

	if(!length(potential_runes))
		to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
		log_game("Teleport spell failed - no other teleport runes")
		return
	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='cultitalic'>You are too far away from the station to teleport!</span>")
		log_game("Teleport spell failed - user in away mission")
		return

	var/input_rune_key = tgui_input_list(user, "Choose a rune to teleport to", "Rune to Teleport to", potential_runes) //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !actual_selected_rune)
		return

	if(HAS_TRAIT(user, TRAIT_FLOORED))
		to_chat(user, "<span class='cultitalic'>You cannot cast this spell while knocked down!</span>")
		return

	uses--

	var/turf/origin = get_turf(teleportee)
	var/turf/destination = get_turf(actual_selected_rune)
	if(SEND_SIGNAL(target, COMSIG_MOVABLE_TELEPORTING, destination) & COMPONENT_BLOCK_TELEPORT)
		return
	INVOKE_ASYNC(actual_selected_rune, TYPE_PROC_REF(/obj/effect/rune, teleport_effect), teleportee, origin, destination)

	if(is_mining_level(user.z) && !is_mining_level(destination.z)) //No effect if you stay on lavaland
		actual_selected_rune.handle_portal("lava")
	else if(!is_station_level(user.z) || isspacearea(get_area(user)))
		actual_selected_rune.handle_portal("space", origin)

	if(user == target)
		target.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] in a flash of red light!</span>", \
		"<span class='cultitalic'>You speak the words and find yourself somewhere else!</span>")
	else
		target.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [target] disappears in a flash of red light!</span>", \
		"<span class='cultitalic'>You suddenly find yourself somewhere else!</span>")
	destination.visible_message("<span class='warning'>There is a boom of outrushing air as something appears above the rune!</span>", null, "<i>You hear a boom.</i>")
	teleportee.forceMove(destination)
	return ..()

//Shackles
/obj/item/melee/blood_magic/shackles
	name = "Shackling Aura"
	desc = "Will start handcuffing a victim on contact, and mute them for a short duration if successful."
	invocation = "In'totum Lig'abis!"
	color = "#000000" // black

/obj/item/melee/blood_magic/shackles/afterattack__legacy__attackchain(atom/target, mob/living/carbon/user, proximity)
	if(user.holy_check())
		return
	if(iscarbon(target) && proximity)
		var/mob/living/carbon/C = target
		if(!(C.has_left_hand() || C.has_right_hand()))
			user.visible_message("<span class='cultitalic'>This victim doesn't have enough arms to complete the restraint!</span>")
			return
		CuffAttack(C, user)
		source.build_all_button_icons()
		..()

/obj/item/melee/blood_magic/shackles/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, SOUND_RANGE_SET(7))
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
		"<span class='userdanger'>[user] begins shaping dark magic shackles around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/cult(C)
				C.update_handcuffed()
				C.Silence(12 SECONDS)
				to_chat(user, "<span class='notice'>You shackle [C].</span>")
				add_attack_logs(user, C, "shackled")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] is already bound.</span>")


/// For the shackling spell
/obj/item/restraints/handcuffs/cult
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	icon_state = "cablecuff"
	breakouttime = 45 SECONDS
	origin_tech = "materials=4;magnets=5;abductor=2"
	flags = DROPDEL

/obj/item/restraints/handcuffs/cult/finish_resist_restraints(mob/living/carbon/user, break_cuffs, silent)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", "<span class='userdanger'>Your [name] shatter in a discharge of dark magic!</span>")
	break_cuffs = TRUE
	silent = TRUE
	. = ..()

//Construction: Converts 50 metal to a construct shell, plasteel to runed metal, or an airlock to brittle runed airlock
/obj/item/melee/blood_magic/construction
	name = "Twisting Aura"
	desc = "Corrupts certain metalic objects on contact."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	var/channeling = FALSE

/obj/item/melee/blood_magic/construction/examine(mob/user)
	. = ..()
	. += {"<u>A sinister spell used to convert:</u>\n
	Plasteel into runed metal\n
	[METAL_TO_CONSTRUCT_SHELL_CONVERSION] metal into a construct shell\n
	Airlocks into brittle runed airlocks after a delay (harm intent)"}

/obj/item/melee/blood_magic/construction/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	if(user.holy_check())
		return
	if(proximity_flag)
		if(channeling)
			to_chat(user, "<span class='cultitalic'>You are already invoking twisted construction!</span>")
			return
		var/turf/T = get_turf(target)

		//Metal to construct shell
		if(istype(target, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(METAL_TO_CONSTRUCT_SHELL_CONVERSION))
				uses--
				to_chat(user, "<span class='warning'>A dark cloud emanates from your hand and swirls around the metal, twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SOUND_RANGE_SET(4))
			else
				to_chat(user, "<span class='warning'>You need [METAL_TO_CONSTRUCT_SHELL_CONVERSION] metal to produce a construct shell!</span>")
				return

		//Plasteel to runed metal
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = candidate.amount
			if(candidate.use(quantity))
				uses--
				new /obj/item/stack/sheet/runed_metal(T, quantity)
				to_chat(user, "<span class='warning'>A dark cloud emanates from you hand and swirls around the plasteel, transforming it into runed metal!</span>")
				playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SOUND_RANGE_SET(4))

		//Airlock to cult airlock
		else if(istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/airlock/cult))
			channeling = TRUE
			playsound(T, 'sound/machines/airlockforced.ogg', 50, TRUE, SOUND_RANGE_SET(7))
			do_sparks(5, TRUE, target)
			if(do_after(user, 50, target = target))
				target.narsie_act(TRUE)
				uses--
				user.visible_message("<span class='warning'>Black ribbons suddenly emanate from [user]'s hand and cling to the airlock - twisting and corrupting it!</span>")
				playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SOUND_RANGE_SET(7))
				channeling = FALSE
			else
				channeling = FALSE
				return
		else
			to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
			return
		..()

//Armor: Gives the target a basic cultist combat loadout
/obj/item/melee/blood_magic/armor
	name = "Arming Aura"
	desc = "Will equipt cult combat gear onto a cultist on contact."
	color = "#33cc33" // green

/obj/item/melee/blood_magic/armor/afterattack__legacy__attackchain(atom/target, mob/living/carbon/user, proximity)
	if(user.holy_check())
		return
	if(iscarbon(target) && proximity)
		uses--
		var/mob/living/carbon/C = target
		var/armour = C.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(user), ITEM_SLOT_OUTER_SUIT)
		C.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(user), ITEM_SLOT_JUMPSUIT)
		C.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), ITEM_SLOT_BACK)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), ITEM_SLOT_SHOES)

		if(C == user)
			qdel(src) //Clears the hands
		C.put_in_hands(new /obj/item/melee/cultblade(user))
		C.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))
		C.visible_message("<span class='warning'>Otherworldly [armour ? "armour" : "equipment"] suddenly appears on [C]!</span>")
		..()
//Used by blood rite, to recharge things like viel shifter or the cultest shielded robes
/obj/item/melee/blood_magic/empower
	name = "Blood Recharge"
	desc = "Can be used on some cult items, to restore them to their previous state."
	invocation = "Ditans Gut'ura Inpulsa!"
	color = "#9c0651"
	has_source = FALSE //special, only availible for a blood cost.

/obj/item/melee/blood_magic/empower/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	if(user.holy_check())
		return
	if(proximity_flag)
		// Shielded suit
		if(istype(target, /obj/item/clothing/suit/hooded/cultrobes/cult_shield))
			var/datum/component/shielded/shield = target.GetComponent(/datum/component/shielded)
			if(shield.current_charges >= 3)
				to_chat(user, "<span class='warning'>[target] is already at full charge!</span>")
				return
			uses--
			to_chat(user, "<span class='warning'>You empower [target] with blood, recharging its shields!</span>")
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SOUND_RANGE_SET(7))
			shield.current_charges = 3
			user.update_appearance(UPDATE_ICON)
			return ..()

		// Veil Shifter
		if(istype(target, /obj/item/cult_shift))
			var/obj/item/cult_shift/S = target
			if(S.uses >= 4)
				to_chat(user, "<span class='warning'>[target] is already at full charge!</span>")
				return
			uses--
			to_chat(user, "<span class='warning'>You empower [target] with blood, recharging its ability to shift!</span>")
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE, SOUND_RANGE_SET(7))
			S.uses = 4
			S.icon_state = "shifter"
			return ..()

		to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
		return ..()

//Blood Rite: Absorb blood to heal cult members or summon weapons
/obj/item/melee/blood_magic/manipulator
	name = "Blood Rite Aura"
	desc = "Absorbs blood from anything you touch. Touching cultists and constructs can heal them. Use in-hand to cast an advanced rite."
	color = "#7D1717"

/obj/item/melee/blood_magic/manipulator/examine(mob/user)
	. = ..()
	. += "Blood spear and blood barrage cost [BLOOD_SPEAR_COST] and [BLOOD_BARRAGE_COST] charges respectively."
	. += "Blood orb and blood empower cost [BLOOD_ORB_COST] and [BLOOD_RECHARGE_COST] charges respectively."
	. += "<span class='cultitalic'>You have collected [uses] charge\s of blood.</span>"

/obj/item/melee/blood_magic/manipulator/proc/restore_blood(mob/living/carbon/human/user, mob/living/carbon/human/H)
	if(uses == 0)
		return
	if(!H.dna || (NO_BLOOD in H.dna.species.species_traits) || !isnull(H.dna.species.exotic_blood))
		return
	if(H.blood_volume >= BLOOD_VOLUME_SAFE)
		return
	var/restore_blood = BLOOD_VOLUME_SAFE - H.blood_volume
	if(uses * 2 < restore_blood)
		H.blood_volume += uses * 2
		to_chat(user, "<span class='danger'>You use the last of your charges to restore what blood you could, and the spell dissipates!</span>")
		uses = 0
	else
		H.blood_volume = BLOOD_VOLUME_SAFE
		uses -= round(restore_blood / 2)
		to_chat(user, "<span class='cult'>Your blood rites have restored [H == user ? "your" : "[H.p_their()]"] blood to safe levels!</span>")

/obj/item/melee/blood_magic/manipulator/proc/heal_human_damage(mob/living/carbon/human/user, mob/living/carbon/human/H)
	if(uses == 0)
		return
	var/overall_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss() + H.getOxyLoss()
	if(overall_damage == 0)
		to_chat(user, "<span class='warning'>[H] doesn't require healing!</span>")
		return

	var/ratio = uses / overall_damage
	if(H == user)
		to_chat(user, "<span class='warning'>Your blood healing is far less efficient when used on yourself!</span>")
		ratio *= 0.35 // Healing is half as effective if you can't perform a full heal
		uses -= round(overall_damage) // Healing is 65% more "expensive" even if you can still perform the full heal
	if(ratio > 1)
		ratio = 1
		uses -= round(overall_damage)
		H.visible_message("<span class='warning'>[H] is fully healed by [H == user ? "[H.p_their()]" : "[H]'s"] blood magic!</span>",
			"<span class='cultitalic'>You are fully healed by [H == user ? "your" : "[user]'s"] blood magic!</span>")
	else
		H.visible_message("<span class='warning'>[H] is partially healed by [H == user ? "[H.p_their()]" : "[H]'s"] blood magic.</span>",
			"<span class='cultitalic'>You are partially healed by [H == user ? "your" : "[user]'s"] blood magic.</span>")
		uses = 0
	ratio *= -1
	H.adjustOxyLoss((overall_damage * ratio) * (H.getOxyLoss() / overall_damage), FALSE, null, TRUE)
	H.adjustToxLoss((overall_damage * ratio) * (H.getToxLoss() / overall_damage), FALSE, null, TRUE)
	H.adjustFireLoss((overall_damage * ratio) * (H.getFireLoss() / overall_damage), FALSE, null, TRUE)
	H.adjustBruteLoss((overall_damage * ratio) * (H.getBruteLoss() / overall_damage), FALSE, null, TRUE)
	H.updatehealth()
	playsound(get_turf(H), 'sound/magic/staff_healing.ogg', 25, extrarange = SOUND_RANGE_SET(7))
	new /obj/effect/temp_visual/cult/sparks(get_turf(H))
	user.Beam(H, icon_state="sendbeam", time = 15)

/obj/item/melee/blood_magic/manipulator/proc/heal_cultist(mob/living/carbon/human/user, mob/living/carbon/human/H)
	if(H.stat == DEAD)
		to_chat(user, "<span class='warning'>Only a revive rune can bring back the dead!</span>")
		return
	var/charge_loss = uses
	restore_blood(user, H)
	heal_human_damage(user, H)
	charge_loss = charge_loss - uses
	if(!uses)
		to_chat(user, "<span class='danger'>You use the last of your charges to heal [H == user ? "yourself" : "[H]"], and the spell dissipates!</span>")
	else
		to_chat(user, "<span class='cultitalic'>You use [charge_loss] charge\s, and have [uses] remaining.</span>")

/obj/item/melee/blood_magic/manipulator/proc/heal_construct(mob/living/carbon/human/user, mob/living/simple_animal/M)
	if(uses == 0)
		return
	var/missing = M.maxHealth - M.health
	if(!missing)
		to_chat(user, "<span class='warning'>[M] doesn't require healing!</span>")
		return
	if(uses > missing)
		M.adjustHealth(-missing)
		M.visible_message("<span class='warning'>[M] is fully healed by [user]'s blood magic!</span>",
			"<span class='cultitalic'>You are fully healed by [user]'s blood magic!</span>")
		uses -= missing
	else
		M.adjustHealth(-uses)
		M.visible_message("<span class='warning'>[M] is partially healed by [user]'s blood magic!</span>",
			"<span class='cultitalic'>You are partially healed by [user]'s blood magic.</span>")
		uses = 0
	playsound(get_turf(M), 'sound/magic/staff_healing.ogg', 25, extrarange = SOUND_RANGE_SET(7))
	user.Beam(M, icon_state = "sendbeam", time = 10)

/obj/item/melee/blood_magic/manipulator/proc/steal_blood(mob/living/carbon/human/user, mob/living/carbon/human/H)
	if(H.stat == DEAD)
		to_chat(user, "<span class='warning'>[H.p_their(TRUE)] blood has stopped flowing, you'll have to find another way to extract it.</span>")
		return
	if(H.AmountCultSlurring())
		to_chat(user, "<span class='danger'>[H.p_their(TRUE)] blood has been tainted by an even stronger form of blood magic, it's no use to us like this!</span>")
		return
	if(!H.dna || (NO_BLOOD in H.dna.species.species_traits) || H.dna.species.exotic_blood != null)
		to_chat(user, "<span class='warning'>[H] does not have any usable blood!</span>")
		return
	if(H.blood_volume <= BLOOD_VOLUME_SAFE)
		to_chat(user, "<span class='warning'>[H] is missing too much blood - you cannot drain [H.p_them()] further!</span>")
		return
	H.blood_volume -= 100
	uses += 50
	user.Beam(H, icon_state = "drainbeam", time = 10)
	playsound(get_turf(H), 'sound/misc/enter_blood.ogg', 50, extrarange = SOUND_RANGE_SET(7))
	H.visible_message("<span class='danger'>[user] has drained some of [H]'s blood!</span>",
					"<span class='userdanger'>[user] has drained some of your blood!</span>")
	to_chat(user, "<span class='cultitalic'>Your blood rite gains 50 charges from draining [H]'s blood.</span>")
	new /obj/effect/temp_visual/cult/sparks(get_turf(H))

// This should really be split into multiple procs
/obj/item/melee/blood_magic/manipulator/afterattack__legacy__attackchain(atom/target, mob/living/carbon/human/user, proximity)
	if(user.holy_check())
		return
	if(!proximity)
		return ..()
	if(ishuman(target))
		if(IS_CULTIST(target))
			heal_cultist(user, target)
			target.clean_blood()
		else
			steal_blood(user, target)
		source.build_all_button_icons()
		return

	if(isconstruct(target))
		heal_construct(user, target)
		source.build_all_button_icons()
		return

	if(istype(target, /obj/item/blood_orb))
		var/obj/item/blood_orb/candidate = target
		if(candidate.blood)
			uses += candidate.blood
			to_chat(user, "<span class='warning'>You obtain [candidate.blood] blood from the orb of blood!</span>")
			playsound(user, 'sound/misc/enter_blood.ogg', 50, extrarange = SOUND_RANGE_SET(7))
			qdel(candidate)
			source.build_all_button_icons()
			return
	blood_draw(target, user)
	source.build_all_button_icons()

/obj/item/melee/blood_magic/manipulator/proc/blood_draw(atom/target, mob/living/carbon/human/user)
	var/temp = 0
	var/turf/T = get_turf(target)
	if(!T)
		return
	for(var/obj/effect/decal/cleanable/blood/B in range(T, 2))
		if(B.blood_state == BLOOD_STATE_HUMAN && (B.can_bloodcrawl_in()))
			if(B.bloodiness == 100) //Bonus for "pristine" bloodpools, also to prevent cheese with footprint spam
				temp += 30
			else
				temp += max((B.bloodiness ** 2) / 800, 1)
		new /obj/effect/temp_visual/cult/turf/open/floor(get_turf(B))
		qdel(B)
	for(var/obj/effect/decal/cleanable/trail_holder/TH in range(T, 2))
		new /obj/effect/temp_visual/cult/turf/open/floor(get_turf(TH))
		qdel(TH)
	if(temp)
		user.Beam(T, icon_state = "drainbeam", time = 15)
		new /obj/effect/temp_visual/cult/sparks(get_turf(user))
		playsound(T, 'sound/misc/enter_blood.ogg', 50, extrarange = SOUND_RANGE_SET(7))
		temp = round(temp)
		to_chat(user, "<span class='cultitalic'>Your blood rite has gained [temp] charge\s from blood sources around you!</span>")
		uses += max(1, temp)

/obj/item/melee/blood_magic/manipulator/attack_self__legacy__attackchain(mob/living/user)
	if(user.holy_check())
		return
	var/list/options = list("Blood Orb (50)" = image(icon = 'icons/obj/cult.dmi', icon_state = "summoning_orb"),
							"Blood Recharge (75)" = image(icon = 'icons/mob/actions/actions_cult.dmi', icon_state = "blood_charge"),
							"Blood Spear (150)" = image(icon = 'icons/mob/actions/actions_cult.dmi', icon_state = "bloodspear"),
							"Blood Bolt Barrage (300)" = image(icon = 'icons/mob/actions/actions_cult.dmi', icon_state = "blood_barrage"))
	var/choice = show_radial_menu(user, src, options)

	switch(choice)
		if("Blood Orb (50)")
			if(uses < BLOOD_ORB_COST)
				to_chat(user, "<span class='warning'>You need [BLOOD_ORB_COST] charges to perform this rite.</span>")
			else
				var/ammount = input("How much blood would you like to transfer? You have [uses] blood.", "How much blood?", 50) as null|num
				if(ammount < 50) // No 1 blood orbs, 50 or more.
					to_chat(user, "<span class='warning'>You need to give up at least 50 blood.</span>")
					return
				if(ammount > uses) // No free blood either
					to_chat(user, "<span class='warning'>You do not have that much blood to give!</span>")
					return
				uses -= ammount
				var/turf/T = get_turf(user)
				qdel(src)
				var/obj/item/blood_orb/rite = new(T)
				rite.blood = ammount
				if(user.put_in_hands(rite))
					to_chat(user, "<span class='cult'>A [rite.name] appears in your hand!</span>")
				else
					user.visible_message("<span class='warning'>A [rite.name] appears at [user]'s feet!</span>",
					"<span class='cult'>A [rite.name] materializes at your feet.</span>")

		if("Blood Recharge (75)")
			if(uses < BLOOD_RECHARGE_COST)
				to_chat(user, "<span class='cultitalic'>You need [BLOOD_RECHARGE_COST] charges to perform this rite.</span>")
			else
				var/obj/rite = new /obj/item/melee/blood_magic/empower()
				uses -= BLOOD_RECHARGE_COST
				qdel(src)
				if(user.put_in_hands(rite))
					to_chat(user, "<span class='cult'>Your hand glows with power!</span>")
				else
					to_chat(user, "<span class='warning'>You need a free hand for this rite!</span>")
					uses += BLOOD_RECHARGE_COST // Refund the charges
					qdel(rite)

		if("Blood Spear (150)")
			if(uses < BLOOD_SPEAR_COST)
				to_chat(user, "<span class='warning'>You need [BLOOD_SPEAR_COST] charges to perform this rite.</span>")
			else
				uses -= BLOOD_SPEAR_COST
				var/turf/T = get_turf(user)
				qdel(src)
				var/datum/action/innate/cult/spear/S = new(user)
				var/obj/item/cult_spear/rite = new(T)
				S.Grant(user, rite)
				rite.spear_act = S
				if(user.put_in_hands(rite))
					to_chat(user, "<span class='cult'>A [rite.name] appears in your hand!</span>")
				else
					user.visible_message("<span class='warning'>A [rite.name] appears at [user]'s feet!</span>",
					"<span class='cult'>A [rite.name] materializes at your feet.</span>")

		if("Blood Bolt Barrage (300)")
			if(uses < BLOOD_BARRAGE_COST)
				to_chat(user, "<span class='cultitalic'>You need [BLOOD_BARRAGE_COST] charges to perform this rite.</span>")
			else
				var/obj/rite = new /obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/blood()
				uses -= BLOOD_BARRAGE_COST
				qdel(src)
				user.swap_hand()
				user.drop_item()
				if(user.put_in_hands(rite))
					to_chat(user, "<span class='cult'>Both of your hands glow with power!</span>")
				else
					to_chat(user, "<span class='warning'>You need a free hand for this rite!</span>")
					uses += BLOOD_BARRAGE_COST // Refund the charges
					qdel(rite)
	source.build_all_button_icons()
