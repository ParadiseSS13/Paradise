/mob/living/simple_animal/hostile/headcrab
	name = "headcrab"
	desc = "A headcrab. Run!"
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	health = 40
	maxHealth = 40
	melee_damage_lower = 8
	melee_damage_upper = 16
	attacktext = "bites"
	attack_sound = 'sound/creatures/headcrab_attack.ogg'
	speak_emote = list("hisses")
	var/is_zombie = 0
	stat_attack = 1 //so they continue to attack when they are on the ground.
	var/host_species = ""
	var/list/human_overlays = list()


/mob/living/simple_animal/hostile/headcrab/Life(seconds, times_fired)
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in oview(src, 1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD || (!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD))
				Zombify(H)
				break
	..()

/mob/living/simple_animal/hostile/headcrab/proc/Zombify(mob/living/carbon/human/H)
	if(!H.check_death_method())
		H.death()
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	is_zombie = TRUE
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor["melee"])
			maxHealth += A.armor["melee"] //That zombie's got armor, I want armor!
	maxHealth += 50
	health = maxHealth
	name = "zombie"
	desc = "A corpse animated by the alien being on its head."
	melee_damage_lower = 10
	melee_damage_upper = 15
	icon = H.icon
	speak = list('sound/creatures/zombie_idle1.ogg','sound/creatures/zombie_idle2.ogg','sound/creatures/zombie_idle3.ogg')
	speak_chance = 50
	speak_emote = list("groans")
	attack_sound = 'sound/creatures/zombie_attack.ogg'
	icon_state = "zombie2_s"
	if(head_organ)
		head_organ.h_style = null
	H.update_hair()
	host_species = H.dna.species.name
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)
	visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")


/mob/living/simple_animal/hostile/headcrab/handle_automated_speech() // This way they have different screams when attacking, sometimes. Might be seen as sphagetthi code though.
	if(speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				var/pick = rand(0,speak.len - 1)
				playsound(get_turf(),speak[pick], 200, 1)

/mob/living/simple_animal/hostile/headcrab/death()
	. = ..()
	icon_state = "headcrab_dead"
	if(is_zombie)
		qdel(src) //The headcrab would be in no "nice" shape to be ressurected or toyed with, so it gibs.

/mob/living/simple_animal/hostile/headcrab/Destroy()
	if(contents)
		for(var/mob/M in contents)
			M.loc = get_turf(src)
	return ..()


/mob/living/simple_animal/hostile/headcrab/update_icons()
	..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_gray")
		overlays += I
