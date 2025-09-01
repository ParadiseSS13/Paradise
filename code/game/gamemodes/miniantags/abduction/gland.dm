/obj/item/organ/internal/heart/gland
	name = "fleshy mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	dead_icon = null
	status = ORGAN_ROBOT
	origin_tech = "materials=4;biotech=7;abductor=3"
	organ_datums = list(/datum/organ/heart/always_beating, /datum/organ/battery) // alien glands are immune to stopping, and provide power to IPCs
	tough = TRUE //not easily broken by combat damage

	/// Do these organs have an repeatable ongoing effects?
	var/has_ongoing_effect = TRUE
	/// Is this organ's effect currently active
	var/active = FALSE
	/// the low-end of random cooldown times between activations
	var/cooldown_low = 300
	/// the high-end of random cooldown times between activations
	var/cooldown_high = 300
	/// what time will the organ activate next
	var/next_activation = 0
	/// How many uses of this organ remain before it goes dormant; -1 for infinite uses
	var/uses

	var/mind_control_uses = 1
	var/mind_control_duration = 1800
	var/active_mind_control = FALSE

/obj/item/organ/internal/heart/gland/update_icon_state()
	return

/obj/item/organ/internal/heart/gland/proc/Start()
	active = TRUE
	next_activation = world.time + rand(cooldown_low,cooldown_high)

/obj/item/organ/internal/heart/gland/proc/update_gland_hud()
	if(!owner)
		return
	var/image/holder = owner.hud_list[GLAND_HUD]
	if(active_mind_control)
		holder.icon_state = "hudgland_active"
	else if(mind_control_uses)
		holder.icon_state = "hudgland_ready"
	else
		holder.icon_state = "hudgland_spent"

/obj/item/organ/internal/heart/gland/proc/mind_control(command, mob/living/user)
	if(!owner_check() || !mind_control_uses || active_mind_control)
		return
	mind_control_uses--
	to_chat(owner, "<span class='userdanger'>You suddenly feel an irresistible compulsion to follow an order...</span>")
	to_chat(owner, "<span class='mind_control'>[command]</span>")
	active_mind_control = TRUE
	log_admin("[key_name(user)] sent an abductor mind control message to [key_name(owner)]: [command]")
	message_admins("[key_name_admin(user)] sent an abductor mind control message to [key_name_admin(owner)]: [command]")
	user.create_log(CONVERSION_LOG, "sent an abductor mind control message: '[command]'", owner)
	owner.create_log(CONVERSION_LOG, "received an abductor mind control message: '[command]'", user)
	update_gland_hud()

	addtimer(CALLBACK(src, PROC_REF(clear_mind_control)), mind_control_duration)

/obj/item/organ/internal/heart/gland/proc/clear_mind_control()
	if(!owner_check() || !active_mind_control)
		return
	to_chat(owner, "<span class='userdanger'>You feel the compulsion fade, and you completely forget about your previous orders.</span>")
	active_mind_control = FALSE
	update_gland_hud()

/obj/item/organ/internal/heart/gland/remove(mob/living/carbon/M, special = 0)
	if(initial(uses) == 1)
		uses = initial(uses)
	var/datum/atom_hud/abductor/hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	hud.remove_from_hud(owner)
	clear_mind_control()
	. = ..()

/obj/item/organ/internal/heart/gland/insert(mob/living/carbon/M, special = 0)
	..()
	if(special != 2 && uses) // Special 2 means abductor surgery
		Start()
	var/datum/atom_hud/abductor/hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	hud.add_to_hud(owner)
	update_gland_hud()

/obj/item/organ/internal/heart/gland/on_life()
	if(has_ongoing_effect && active)
		if(!owner_check())
			active = FALSE
			return
		if(next_activation <= world.time)
			trigger()
			uses--
			next_activation  = world.time + rand(cooldown_low, cooldown_high)
		if(!uses)
			active = FALSE

/obj/item/organ/internal/heart/gland/proc/trigger()
	return

/obj/item/organ/internal/heart/gland/heals
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/heals/trigger()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	to_chat(owner, "<span class='notice'>You feel curiously revitalized.</span>")
	owner.adjustToxLoss(-20)
	owner.adjustBruteLoss(-20)
	owner.adjustOxyLoss(-20)
	owner.adjustFireLoss(-20)

/obj/item/organ/internal/heart/gland/slime
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/slime/insert(mob/living/carbon/M, special = 0)
	..()
	owner.faction |= "slime"
	owner.add_language("Bubblish")

/obj/item/organ/internal/heart/gland/slime/trigger()
	to_chat(owner, "<span class='warning'>You feel nauseous!</span>")
	owner.vomit(20)

	new /mob/living/simple_animal/slime(get_turf(owner), "grey")

/obj/item/organ/internal/heart/gland/mindshock
	origin_tech = "materials=4;biotech=4;magnets=6;abductor=3"
	cooldown_low = 400
	cooldown_high = 700
	uses = -1
	icon_state = "mindshock"
	mind_control_duration = 6000

/obj/item/organ/internal/heart/gland/mindshock/trigger()
	to_chat(owner, "<span class='notice'>You get a headache.</span>")

	var/turf/T = get_turf(owner)
	for(var/mob/living/carbon/H in orange(4,T))
		if(H == owner)
			continue
		switch(pick(1,3))
			if(1)
				to_chat(H, "<span class='userdanger'>You hear a loud buzz in your head, silencing your thoughts!</span>")
				H.Stun(6 SECONDS)
			if(2)
				to_chat(H, "<span class='warning'>You hear an annoying buzz in your head.</span>")
				H.AdjustConfused(30 SECONDS)
				H.adjustBrainLoss(5, 15)
			if(3)
				H.AdjustHallucinate(60 SECONDS)

/obj/item/organ/internal/heart/gland/pop
	cooldown_low = 900
	cooldown_high = 1800
	uses = -1
	icon_state = "species"
	mind_control_uses = 5
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/pop/trigger()
	to_chat(owner, "<span class='notice'>You feel unlike yourself.</span>")
	var/species = pick(/datum/species/unathi, /datum/species/skrell, /datum/species/diona, /datum/species/tajaran, /datum/species/vulpkanin, /datum/species/kidan, /datum/species/grey)
	owner.set_species(species, keep_missing_bodyparts = TRUE)

/obj/item/organ/internal/heart/gland/ventcrawling
	origin_tech = "materials=4;biotech=5;bluespace=4;abductor=3"
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4

/obj/item/organ/internal/heart/gland/ventcrawling/trigger()
	to_chat(owner, "<span class='notice'>You feel very stretchy.</span>")
	owner.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/organ/internal/heart/gland/ventcrawling/remove(mob/living/carbon/M, special = 0)
	owner.ventcrawler = initial(owner.ventcrawler)

/obj/item/organ/internal/heart/gland/viral
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"

/obj/item/organ/internal/heart/gland/viral/trigger()
	to_chat(owner, "<span class='warning'>You feel sick.</span>")
	var/datum/disease/advance/A = random_virus(pick(2, 6), 6)
	A.carrier = TRUE
	owner.ForceContractDisease(A, TRUE)

/obj/item/organ/internal/heart/gland/viral/proc/random_virus(max_symptoms, max_level)
	if(max_symptoms > VIRUS_SYMPTOM_LIMIT)
		max_symptoms = VIRUS_SYMPTOM_LIMIT
	var/datum/disease/advance/A = new /datum/disease/advance()
	A.clear_symptoms()
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(initial(S.level) > max_level)
			continue
		if(initial(S.level) <= 0) //unobtainable symptoms
			continue
		possible_symptoms += S
	while(length(A.symptoms) < max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			A.symptoms += S
	A.Refresh() //just in case someone already made and named the same disease
	return A


/obj/item/organ/internal/heart/gland/teleport
	origin_tech = "materials=4;biotech=4;bluespace=7;abductor=3"
	cooldown_low = 1 MINUTES
	cooldown_high = 1.5 MINUTES
	uses = -1
	icon_state = "teleporting"
	mind_control_uses = 3

/obj/item/organ/internal/heart/gland/teleport/trigger()
	if(!is_teleport_allowed(owner.z)) // check if we can actually teleport on this z level before sending scary messages
		to_chat(owner, "<span class='notice'>You feel like somethings off, but nothing happens?</span>")
		return
	if(prob(10))
		to_chat(owner, "<span class='biggerdanger'>It feels like you are being torn apart atom by atom!</span>")
		owner.emote("scream")
		owner.SetKnockDown(2 SECONDS, TRUE) // even with antistuns, I want them to fall over. Mainly so it conveys how unpleasant it feels
		sleep(2 SECONDS)
		var/turf/possible_area
		possible_area = find_safe_turf()
		do_teleport(owner, pick(possible_area))
		return
	to_chat(owner, "<span class='warning'>You feel a horrible twisting and turning throughout your entire body.</span>")
	owner.emote("scream")
	sleep(1.5 SECONDS) // so they scream, and viewers hear the scream be cut off
	do_teleport(owner, get_turf(owner), 10, safe_turf_pick = TRUE)

/obj/item/organ/internal/heart/gland/spiderman
	cooldown_low = 450
	cooldown_high = 900
	uses = -1
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/spiderman/trigger()
	to_chat(owner, "<span class='warning'>You feel something crawling in your skin.</span>")
	owner.faction |= "spiders"
	var/obj/structure/spider/spiderling/S = new(owner.loc)
	S.master_commander = owner

/obj/item/organ/internal/heart/gland/egg
	cooldown_high = 400
	uses = -1
	icon_state = "egg"
	mind_control_uses = 2

/obj/item/organ/internal/heart/gland/egg/trigger()
	owner.visible_message("<span class='alertalien'>[owner] [pick(EGG_LAYING_MESSAGES)]</span>")
	new /obj/item/food/egg/gland(get_turf(owner))

/obj/item/organ/internal/heart/gland/electric
	cooldown_low = 800
	cooldown_high = 1200
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/internal/heart/gland/electric/insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(owner))
		owner.gene_stability += GENE_INSTABILITY_MODERATE // give them this gene for free
		owner.dna.SetSEState(GLOB.shockimmunityblock, TRUE)
		singlemutcheck(owner, GLOB.shockimmunityblock, MUTCHK_FORCED)

/obj/item/organ/internal/heart/gland/electric/remove(mob/living/carbon/M, special = 0)
	if(ishuman(owner))
		owner.gene_stability -= GENE_INSTABILITY_MODERATE // but return it to normal once it's removed
		owner.dna.SetSEState(GLOB.shockimmunityblock, FALSE)
		singlemutcheck(owner, GLOB.shockimmunityblock, MUTCHK_FORCED)
	return ..()

/obj/item/organ/internal/heart/gland/electric/trigger()
	owner.visible_message("<span class='danger'>[owner]'s skin starts emitting electric arcs!</span>",\
	"<span class='warning'>You feel electric energy building up inside you!</span>")
	playsound(get_turf(owner), "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	addtimer(CALLBACK(src, PROC_REF(zap)), rand(30, 100))

/obj/item/organ/internal/heart/gland/electric/proc/zap()
	tesla_zap(owner, 4, 8000, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN)
	playsound(get_turf(owner), 'sound/magic/lightningshock.ogg', 50, 1)

/obj/item/organ/internal/heart/gland/chem
	cooldown_low = 50
	cooldown_high = 50
	uses = -1
	mind_control_uses = 3
	mind_control_duration = 1200

/obj/item/organ/internal/heart/gland/chem/trigger()
	owner.reagents.add_reagent(get_random_reagent_id(), 2)
	owner.adjustToxLoss(-2)
	..()

/obj/item/organ/internal/heart/gland/bloody
	cooldown_low = 200
	cooldown_high = 400
	uses = -1

/obj/item/organ/internal/heart/gland/bloody/trigger()
	owner.blood_volume = max(owner.blood_volume - 20, 0)
	owner.visible_message("<span class='danger'>[owner]'s skin erupts with blood!</span>",\
	"<span class='userdanger'>Blood pours from your skin!</span>")

	for(var/turf/T in oview(3,owner)) //Make this respect walls and such
		owner.add_splatter_floor(T)
	for(var/mob/living/carbon/human/H in oview(3,owner)) //Blood decals for simple animals would be neat. aka Carp with blood on it.
		H.add_mob_blood(owner)


/obj/item/organ/internal/heart/gland/plasma
	cooldown_low = 1200
	cooldown_high = 1800
	origin_tech = "materials=4;biotech=4;plasmatech=6;abductor=3"
	uses = -1
	mind_control_duration = 800

/obj/item/organ/internal/heart/gland/plasma/trigger()
	spawn(0)
		to_chat(owner, "<span class='warning'>You feel bloated.</span>")
		sleep(150)
		if(!owner)
			return
		to_chat(owner, "<span class='userdanger'>A massive stomachache overcomes you.</span>")
		sleep(50)
		if(!owner)
			return
		owner.visible_message("<span class='danger'>[owner] vomits a cloud of plasma!</span>")
		var/turf/simulated/T = get_turf(owner)
		if(istype(T))
			T.atmos_spawn_air(LINDA_SPAWN_TOXINS|LINDA_SPAWN_20C,50)
		owner.vomit()
