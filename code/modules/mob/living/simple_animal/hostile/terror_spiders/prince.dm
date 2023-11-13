
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCE OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: boss
// -------------: AI: no special ai
// -------------: SPECIAL: massive health
// -------------: TO FIGHT IT: a squad of at least 4 people with laser rifles.
// -------------: SPRITES FROM: Travelling Merchant, https://www.paradisestation.org/forum/profile/2715-travelling-merchant/

/mob/living/simple_animal/hostile/poison/terror_spider/prince
	name = "Prince of Terror spider"
	desc = "An enormous, terrifying spider. It looks like it is judging everything it sees. Its hide seems armored, and it bears the scars of many battles."
	spider_role_summary = "Miniboss terror spider. Lightning bruiser."
	spider_intro_text = "As a Prince of Terror Spider, your role is to slaughter the crew with no remorse. \
	You have extremely high health and your attacks deal massive brute damage, while also dealing high stamina damage and knocking down crew. \
	You can also force open powered doors, smash down walls and lay webs which take longer to destroy and block vision. \
	However, your large size makes you unable to ventcrawl and you regenerate health slower than other spiders."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_allblack"
	icon_living = "terror_allblack"
	icon_dead = "terror_allblack_dead"
	maxHealth = 600 // 30 laser shots
	health = 600
	regen_points_per_hp = 6 // double the normal - IE halved regen speed
	move_to_delay = 3
	speed = 0.5
	melee_damage_lower = 30
	melee_damage_upper = 40
	ventcrawler = 0
	ai_ventcrawls = FALSE
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	idle_ventcrawl_chance = 0
	spider_tier = TS_TIER_3
	loudspeaker = TRUE
	spider_opens_doors = 2
	web_type = /obj/structure/spider/terrorweb/purple
	ai_spins_webs = FALSE
	gender = MALE

/mob/living/simple_animal/hostile/poison/terror_spider/prince/spider_specialattack(mob/living/carbon/human/L)
	L.KnockDown(10 SECONDS)
	L.adjustStaminaLoss(40)
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/prince/Initialize(mapload)
	. = ..()
	if(mind)
		var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/princely_charge()
		mind.AddSpell(spell)
	else
		RegisterSignal(src, COMSIG_MOB_LOGIN, TYPE_PROC_REF(/mob/living/simple_animal/hostile/poison/terror_spider/prince, give_spell))

/mob/living/simple_animal/hostile/poison/terror_spider/prince/proc/give_spell()
	SIGNAL_HANDLER
	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/princely_charge()
	mind.AddSpell(spell)
	UnregisterSignal(src, COMSIG_MOB_LOGIN)

/obj/effect/proc_holder/spell/princely_charge
	name = "Princely Charge"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	action_icon_state = "terror_prince"

/obj/effect/proc_holder/spell/princely_charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/princely_charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, 9, 1, L, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))

/mob/living/simple_animal/hostile/poison/terror_spider/prince/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	if(!has_status_effect(STATUS_EFFECT_CHARGING) || has_status_effect(STATUS_EFFECT_IMPACT_IMMUNE))
		return

	var/hit_something = FALSE
	if(ismovable(hit_atom))
		var/atom/movable/AM = hit_atom
		var/atom/throw_target = get_edge_target_turf(AM, dir)
		if(!AM.anchored || ismecha(AM))
			AM.throw_at(throw_target, 5, 12, src)
			hit_something = TRUE
	if(isobj(hit_atom))
		var/obj/O = hit_atom
		O.take_damage(150, BRUTE)
		hit_something = TRUE
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		L.adjustBruteLoss(60)
		L.KnockDown(12 SECONDS)
		L.Confused(10 SECONDS)
		shake_camera(L, 4, 3)
		hit_something = TRUE
	if(isturf(hit_atom))
		var/turf/T = hit_atom
		if(iswallturf(T))
			T.dismantle_wall(TRUE)
			hit_something = TRUE
	if(hit_something)
		visible_message("<span class='danger'>[src] slams into [hit_atom]!</span>", "<span class='userdanger'>You slam into [hit_atom]!</span>")
		playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 100, TRUE)
