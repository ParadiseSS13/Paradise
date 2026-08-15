/mob/living/basic/bot/secbot/griefsky // This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror. Emag him for best results.
	name = "General Griefsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "grievous"
	base_icon_state = "grievous"
	health = 150
	maxHealth = 150
	ai_controller = /datum/ai_controller/basic_controller/bot/secbot/super_beepsky
	baton_type = /obj/item/melee/energy/sword/saber
	a_intent = INTENT_HARM
	speed = 0 // he's a fast fucker
	var/spin_icon = "griefsky-c"
	/// Damage to deal
	var/dmg = 30
	/// chance we block bullets
	var/block_chance = 80
	/// is our sword currently active?
	var/sword_active = FALSE
	/// Chance to stun victims
	var/stun_chance = 50
	/// Flag to stop it spamming messages
	var/spam_flag = 0

/mob/living/basic/bot/secbot/griefsky/Initialize(mapload)
	. = ..()
	var/static/list/abilities = list(
		/datum/action/cooldown/mob_cooldown/bot/sword = null,
	)
	grant_actions_by_list(abilities)

/mob/living/basic/bot/secbot/griefsky/proc/on_weapon_transform(obj/item/source, mob/user, active)
	if(active)
		visible_message(SPAN_WARNING("[src] ignites his energy swords!"))
	sword_active = active
	update_icon(UPDATE_ICON_STATE)

/mob/living/basic/bot/secbot/griefsky/add_arrest_component() // i dont think we'll be arresting people...
	return

/mob/living/basic/bot/secbot/griefsky/bullet_act(obj/projectile/P) // so uncivilized
	if(stat != CONSCIOUS)
		return FALSE

	if(!sword_active || !prob(block_chance))
		return NONE

	visible_message(SPAN_WARNING("[src] deflects [P] with its energy swords!"))
	playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE)

/mob/living/basic/bot/secbot/griefsky/on_entered(datum/source, atom/movable/movable_target)
	. = ..()
	if(!ismob(movable_target) || !ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == movable_target)
		return
	visible_message(SPAN_WARNING("[src] flails his swords and cuts [movable_target]!"))
	playsound(src, 'sound/voice/beepsky/beepskyspinsabre.ogg' , 100, TRUE, -1)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, ClickOn), movable_target)

/mob/living/basic/bot/secbot/griefsky/update_icon_state()
	. = ..()

	icon_state = "[base_icon_state][ sword_active ? "-c" : ""]"

/mob/living/basic/bot/secbot/griefsky/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/basic/bot/secbot/griefsky/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!sword_active)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		sword_attack(C)

/mob/living/basic/bot/secbot/griefsky/proc/sword_attack(mob/living/carbon/C)     // esword attack
	do_attack_animation(C)
	playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
	addtimer(CALLBACK(src, PROC_REF(do_sword_attack), C), 2)

/mob/living/basic/bot/secbot/griefsky/proc/do_sword_attack(mob/living/carbon/C)
	icon_state = spin_icon
	var/threat = ai_controller.blackboard[BB_CURRENT_CRIMINAL_ASSESSMENT]
	if(ishuman(C))
		C.apply_damage(dmg, BRUTE)
		if(prob(stun_chance))
			C.Weaken(10 SECONDS)
	if(dmg)
		add_attack_logs(src, C, "sliced")
	if(security_mode_flags & SECBOT_DECLARE_ARRESTS)
		var/area/location = get_area(src)
		if(!spam_flag)
			speak("Back away! I will deal with this level [threat] swine <b>[C]</b> in [location] myself!.", radio_channel)
			spam_flag = 1
			addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 100) // to avoid spamming comms of sec for each hit
			visible_message("[src] flails his swords and cuts [C]!")

/mob/living/basic/bot/secbot/griefsky/explode()
	var/atom/drop_location = drop_location()
	// Parent is dropping the weapon, so let's drop 3 more to make up for it.
	for(var/i in 0 to 3)
		drop_part(weapon, drop_location)

	return ..()

/mob/living/basic/bot/secbot/griefsky/proc/spam_flag_false() // used for addtimer to not spam comms
	spam_flag = 0

/mob/living/basic/bot/secbot/griefsky/toy // A toy version of general beepsky!
	name = "Genewul Gwiefsky"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	health = 50
	maxHealth = 50
	block_chance = 0
	baton_type = /obj/item/toy/sword
