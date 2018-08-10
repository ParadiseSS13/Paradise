/obj/item/organ/internal/heart/gland
	name = "fleshy mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	status = ORGAN_ROBOT
	origin_tech = "materials=4;biotech=7;abductor=3"
	beating = TRUE
	var/cooldown_low = 300
	var/cooldown_high = 300
	var/next_activation = 0
	var/uses // -1 For inifinite
	var/human_only = 0
	var/active = 0
	tough = TRUE //not easily broken by combat damage

	var/mind_control_uses = 1
	var/mind_control_duration = 1800
	var/active_mind_control = FALSE

/obj/item/organ/internal/heart/gland/proc/ownerCheck()
	if(ishuman(owner))
		return TRUE
	if(!human_only && iscarbon(owner))
		return TRUE
	return FALSE

/obj/item/organ/internal/heart/gland/proc/Start()
	active = 1
	next_activation = world.time + rand(cooldown_low,cooldown_high)

/obj/item/organ/internal/heart/gland/proc/update_gland_hud()
	if(!owner)
		return
	var/image/holder = owner.hud_list[GLAND_HUD]
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(active_mind_control)
		holder.icon_state = "hudgland_active"
	else if(mind_control_uses)
		holder.icon_state = "hudgland_ready"
	else
		holder.icon_state = "hudgland_spent"

/obj/item/organ/internal/heart/gland/proc/mind_control(command, mob/living/user)
	if(!ownerCheck() || !mind_control_uses || active_mind_control)
		return
	mind_control_uses--
	to_chat(owner, "<span class='userdanger'>You suddenly feel an irresistible compulsion to follow an order...</span>")
	to_chat(owner, "<span class='mind_control'>[command]</span>")
	active_mind_control = TRUE
	log_admin("[key_name(user)] sent an abductor mind control message to [key_name(owner)]: [command]")
	update_gland_hud()

	addtimer(CALLBACK(src, .proc/clear_mind_control), mind_control_duration)

/obj/item/organ/internal/heart/gland/proc/clear_mind_control()
	if(!ownerCheck() || !active_mind_control)
		return
	to_chat(owner, "<span class='userdanger'>You feel the compulsion fade, and you completely forget about your previous orders.</span>")
	active_mind_control = FALSE
	update_gland_hud()

/obj/item/organ/internal/heart/gland/remove(var/mob/living/carbon/M, special = 0)
	active = 0
	if(initial(uses) == 1)
		uses = initial(uses)
	var/datum/atom_hud/abductor/hud = huds[DATA_HUD_ABDUCTOR]
	hud.remove_from_hud(owner)
	clear_mind_control()
	. = ..()

/obj/item/organ/internal/heart/gland/insert(var/mob/living/carbon/M, special = 0)
	..()
	if(special != 2 && uses) // Special 2 means abductor surgery
		Start()
	var/datum/atom_hud/abductor/hud = huds[DATA_HUD_ABDUCTOR]
	hud.add_to_hud(owner)
	update_gland_hud()

/obj/item/organ/internal/heart/gland/on_life()
	if(!beating)
		// alien glands are immune to stopping.
		beating = TRUE
	if(!active)
		return
	if(!ownerCheck())
		active = 0
		return
	if(next_activation <= world.time)
		activate()
		uses--
		next_activation  = world.time + rand(cooldown_low,cooldown_high)
	if(!uses)
		active = 0

/obj/item/organ/internal/heart/gland/proc/activate()
	return

/obj/item/organ/internal/heart/gland/heals
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/heals/activate()
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
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/slime/insert(mob/living/carbon/M, special = 0)
	..()
	owner.faction |= "slime"
	owner.add_language("Bubblish")

/obj/item/organ/internal/heart/gland/slime/activate()
	to_chat(owner, "<span class='warning'>You feel nauseous!</span>")
	owner.vomit(20)

	var/mob/living/carbon/slime/Slime = new/mob/living/carbon/slime(get_turf(owner))
	Slime.Friends = list(owner)
	Slime.Leader = owner

/obj/item/organ/internal/heart/gland/mindshock
	origin_tech = "materials=4;biotech=4;magnets=6;abductor=3"
	cooldown_low = 400
	cooldown_high = 700
	uses = -1
	icon_state = "mindshock"
	mind_control_uses = 1
	mind_control_duration = 6000

/obj/item/organ/internal/heart/gland/mindshock/activate()
	to_chat(owner, "<span class='notice'>You get a headache.</span>")

	var/turf/T = get_turf(owner)
	for(var/mob/living/carbon/H in orange(4,T))
		if(H == owner)
			continue
		switch(pick(1,3))
			if(1)
				to_chat(H, "<span class='userdanger'>You hear a loud buzz in your head, silencing your thoughts!</span>")
				H.Stun(3)
			if(2)
				to_chat(H, "<span class='warning'>You hear an annoying buzz in your head.</span>")
				H.AdjustConfused(15)
				H.adjustBrainLoss(5, 15)
			if(3)
				H.hallucination += 60

/obj/item/organ/internal/heart/gland/pop
	cooldown_low = 900
	cooldown_high = 1800
	uses = -1
	human_only = TRUE
	icon_state = "species"
	mind_control_uses = 5
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/pop/activate()
	to_chat(owner, "<span class='notice'>You feel unlike yourself.</span>")
	var/species = pick(/datum/species/unathi, /datum/species/skrell, /datum/species/diona, /datum/species/tajaran, /datum/species/vulpkanin, /datum/species/kidan, /datum/species/grey)
	owner.set_species(species)

/obj/item/organ/internal/heart/gland/ventcrawling
	origin_tech = "materials=4;biotech=5;bluespace=4;abductor=3"
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/ventcrawling/activate()
	to_chat(owner, "<span class='notice'>You feel very stretchy.</span>")
	owner.ventcrawler = 2


/obj/item/organ/internal/heart/gland/viral
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"
	mind_control_uses = 1
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/viral/activate()
	to_chat(owner, "<span class='warning'>You feel sick.</span>")
	var/datum/disease/advance/A = random_virus(pick(2, 6), 6)
	A.carrier = TRUE
	owner.ForceContractDisease(A)

/obj/item/organ/internal/heart/gland/viral/proc/random_virus(max_symptoms, max_level)
	if(max_symptoms > VIRUS_SYMPTOM_LIMIT)
		max_symptoms = VIRUS_SYMPTOM_LIMIT
	var/datum/disease/advance/A = new /datum/disease/advance()
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(initial(S.level) > max_level)
			continue
		if(initial(S.level) <= 0) //unobtainable symptoms
			continue
		possible_symptoms += S
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			A.symptoms += S
	A.Refresh() //just in case someone already made and named the same disease
	return A


/obj/item/organ/internal/heart/gland/emp //TODO : Replace with something more interesting
	origin_tech = "materials=4;biotech=4;magnets=6;abductor=3"
	cooldown_low = 800
	cooldown_high = 1200
	uses = 10
	icon_state = "emp"
	mind_control_uses = 3
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/emp/activate()
	to_chat(owner, "<span class='warning'>You feel a spike of pain in your head.</span>")
	empulse(get_turf(owner), 2, 5, 1)

/obj/item/organ/internal/heart/gland/spiderman
	cooldown_low = 450
	cooldown_high = 900
	uses = -1
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/spiderman/activate()
	to_chat(owner, "<span class='warning'>You feel something crawling in your skin.</span>")
	owner.faction |= "spiders"
	var/obj/structure/spider/spiderling/S = new(owner.loc)
	S.master_commander = owner

/obj/item/organ/internal/heart/gland/egg
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	icon_state = "egg"
	mind_control_uses = 2
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/egg/activate()
	owner.visible_message("<span class='alertalien'>[owner] [pick(EGG_LAYING_MESSAGES)]</span>")
	new /obj/item/reagent_containers/food/snacks/egg/gland(get_turf(owner))

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
		owner.dna.SetSEState(SHOCKIMMUNITYBLOCK, TRUE)
		genemutcheck(owner, SHOCKIMMUNITYBLOCK,  null, MUTCHK_FORCED)

/obj/item/organ/internal/heart/gland/electric/remove(mob/living/carbon/M, special = 0)
	if(ishuman(owner))
		owner.gene_stability -= GENE_INSTABILITY_MODERATE // but return it to normal once it's removed
		owner.dna.SetSEState(SHOCKIMMUNITYBLOCK, FALSE)
		genemutcheck(owner, SHOCKIMMUNITYBLOCK,  null, MUTCHK_FORCED)
	return ..()

/obj/item/organ/internal/heart/gland/electric/activate()
	owner.visible_message("<span class='danger'>[owner]'s skin starts emitting electric arcs!</span>",\
	"<span class='warning'>You feel electric energy building up inside you!</span>")
	playsound(get_turf(owner), "sparks", 100, 1, -1)
	addtimer(CALLBACK(src, .proc/zap), rand(30, 100))

/obj/item/organ/internal/heart/gland/electric/proc/zap()
	tesla_zap(owner, 4, 8000)
	playsound(get_turf(owner), 'sound/magic/lightningshock.ogg', 50, 1)

/obj/item/organ/internal/heart/gland/chem
	cooldown_low = 50
	cooldown_high = 50
	uses = -1
	mind_control_uses = 3
	mind_control_duration = 1200

/obj/item/organ/internal/heart/gland/chem/activate()
	owner.reagents.add_reagent(get_random_reagent_id(), 2)
	owner.adjustToxLoss(-2)
	..()

/obj/item/organ/internal/heart/gland/bloody
	cooldown_low = 200
	cooldown_high = 400
	uses = -1

/obj/item/organ/internal/heart/gland/bloody/activate()
	owner.blood_volume = max(owner.blood_volume - 20, 0)
	owner.visible_message("<span class='danger'>[owner]'s skin erupts with blood!</span>",\
	"<span class='userdanger'>Blood pours from your skin!</span>")

	for(var/turf/T in oview(3,owner)) //Make this respect walls and such
		owner.add_splatter_floor(T)
	for(var/mob/living/carbon/human/H in oview(3,owner)) //Blood decals for simple animals would be neat. aka Carp with blood on it.
		H.add_mob_blood(owner)

/obj/item/organ/internal/heart/gland/bodysnatch
	cooldown_low = 600
	cooldown_high = 600
	human_only = 1
	uses = 1

/obj/item/organ/internal/heart/gland/bodysnatch/activate()
	to_chat(owner, "<span class='warning'>You feel something moving around inside you...</span>")
	//spawn cocoon with clone greytide snpc inside
	if(ishuman(owner))
		var/obj/effect/cocoon/abductor/C = new (get_turf(owner))
		C.Copy(owner)
		C.Start()
	owner.adjustBruteLoss(40)
	owner.add_splatter_floor()

/obj/effect/cocoon/abductor
	name = "slimy cocoon"
	desc = "Something is moving inside."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon_large3"
	color = rgb(10,120,10)
	density = 1
	var/hatch_time = 0

/obj/effect/cocoon/abductor/proc/Copy(mob/living/carbon/human/H)
	var/mob/living/carbon/human/interactive/greytide/clone = new(src)
	var/datum/dna/owner_dna = H.dna
	clone.rename_character(clone.name, owner_dna.real_name)
	clone.set_species(owner_dna.species.type)
	clone.dna = owner_dna.Clone()
	clone.body_accessory = H.body_accessory
	domutcheck(clone)

	for(var/obj/item/I in clone)
		if(istype(I, /obj/item/implant))
			continue
		if(istype(I, /obj/item/organ))
			continue
		qdel(I)

	//There's no define for this / get all items ?
	var/list/slots = list(slot_back,slot_w_uniform,slot_wear_suit,\
	slot_wear_mask,slot_head,slot_shoes,slot_gloves,slot_l_ear,slot_r_ear,\
	slot_glasses,slot_belt,slot_s_store,slot_l_store,slot_r_store,slot_wear_id,slot_wear_pda)

	for(var/slot in slots)
		var/obj/item/I = H.get_item_by_slot(slot)
		if(I)
			clone.equip_to_slot_or_del(new I.type(clone), slot)

/obj/effect/cocoon/abductor/proc/Start()
	hatch_time = world.time + 600
	processing_objects.Add(src)

/obj/effect/cocoon/abductor/process()
	if(world.time > hatch_time)
		processing_objects.Remove(src)
		for(var/mob/M in contents)
			src.visible_message("<span class='warning'>[src] hatches!</span>")
			M.forceMove(get_turf(src))
		qdel(src)


/obj/item/organ/internal/heart/gland/plasma
	cooldown_low = 1200
	cooldown_high = 1800
	origin_tech = "materials=4;biotech=4;plasmatech=6;abductor=3"
	uses = -1
	mind_control_uses = 1
	mind_control_duration = 800

/obj/item/organ/internal/heart/gland/plasma/activate()
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
			T.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C,50)
		owner.vomit()
