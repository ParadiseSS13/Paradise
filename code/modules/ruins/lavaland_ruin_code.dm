/obj/structure/lavaland_door
	name = "necropolis gate"
	desc = "An imposing, seemingly impenetrable door."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door"
	anchored = 1
	density = 1
	bound_width = 96
	bound_height = 96
	burn_state = LAVA_PROOF
	luminosity = 1

/obj/structure/lavaland_door/singularity_pull()
	return 0

/obj/structure/lavaland_door/Destroy()
	return QDEL_HINT_LETMELIVE

/obj/machinery/lavaland_controller
	name = "weather control machine"
	desc = "Controls the weather."
	icon = 'icons/obj/machines/broadcast.dmi'
	icon_state = "broadcaster"
	var/ongoing_weather = FALSE
	var/weather_cooldown = 0

/obj/machinery/lavaland_controller/process()
	if(ongoing_weather || weather_cooldown > world.time)
		return
	ongoing_weather = TRUE
	weather_cooldown = world.time + rand(3500, 6500)
	var/datum/weather/ash_storm/LAVA = new /datum/weather/ash_storm
	LAVA.start()
	ongoing_weather = FALSE

/obj/machinery/lavaland_controller/Destroy()
	return QDEL_HINT_LETMELIVE



//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry = 15,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)

/obj/effect/landmark/corpse/mob_spawn/seed_vault
	name = "sleeper"
	mobname = "Vault Creature"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	//mob_species = /datum/species/podman//TODO: Delete this vault or use existing species
	flavour_text = {"You are a strange, artificial creature. Your creators were a highly advanced and benevolent race, and launched many seed vaults into the stars, hoping to aid fledgling civilizations. You are to tend to the vault and await the arrival of sentient species. You've been waiting quite a while though..."}

/obj/effect/landmark/corpse/mob_spawn/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Brocolli", "Carrot", "Deathcap", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Bannana", "Moss", "Flower", "Bloom", "Spore", "Root", "Bark", "Glowshroom", "Petal", "Leaf", "Venus", "Sprout","Cocao", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper")
	new_spawn.real_name = plant_name

//Greed

/obj/structure/cursed_slot_machine
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/objects.dmi'
	icon_state = "slots-on"
	anchored = 1
	density = 1
	var/win_prob = 5
/*
/obj/structure/cursed_slot_machine/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(in_use)
		return
	in_use = TRUE
	user << "<span class='danger'><B>You feel your very life draining away as you pull the lever...it'll be worth it though, right?</B></span>"
	user.adjustCloneLoss(20)
	if(user.stat)
		user.gib()
	icon_state = "slots2"
	sleep(50)
	icon_state = "slots1"
	in_use = FALSE
	if(prob(win_prob))
		new /obj/item/weapon/dice/d20/fate/one_use(get_turf(src))
		if(user)
			user << "You hear laughter echoing around you as the machine fades away. In it's place...more gambling."
			qdel(src)
	else
		if(user)
			user << "<span class='danger'>Looks like you didn't win anything this time...next time though, right?</span>"
*/
//Gluttony

/obj/effect/gluttony
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = 1
	density = 1
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'

/obj/effect/gluttony/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(height==0)
		return 1
	if(istype(mover, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			return 1
		else
			H << "<span class='danger'><B>You're not gluttonous enough to pass this barrier!</B></span>"
	else
		return 0

//Pride

/obj/structure/mirror/magic/pride
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"
/* TODO:curse and chasm
/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message("<span class='danger'><B>The ground splits beneath [user] as their hand leaves the mirror!</B></span>")
	var/turf/T = get_turf(user)
	T.ChangeTurf(/turf/simulated/chasm/straight_down)
	var/turf/simulated/chasm/straight_down/C = T
	C.drop(user)*/

//Sloth - I'll finish this item later

//Envy

/obj/item/weapon/knife/envy
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 18
	throwforce = 10
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
/*TODO: Attack
/obj/item/weapon/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user << "You assume the face of [H]. Are you satisfied?"*/

///Ash Walkers

/mob/living/simple_animal/hostile/spawner/ash_walker
	name = "ash walker nest"
	desc = "A nest built around a necropolis tendril. The eggs seem to grow unnaturally fast..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/gibspawner, /obj/item/device/assembly/signaler/anomaly)
	del_on_death = 1
	var/meat_counter

/mob/living/simple_animal/hostile/spawner/ash_walker/Life()
	..()
	if(!stat)
		consume()
		spawn_mob()

/mob/living/simple_animal/hostile/spawner/ash_walker/proc/consume()
	for(var/mob/living/H in view(src,1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Tendrils reach out from \the [src.name] pulling [H] in! Blood seeps over the eggs as [H] is devoured.</span>")
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			meat_counter ++
			H.gib()

/mob/living/simple_animal/hostile/spawner/ash_walker/spawn_mob()
	if(meat_counter >= 2)
		new /obj/effect/landmark/corpse/mob_spawn/ash_walker(get_step(src.loc, SOUTH))
		visible_message("<span class='danger'>An egg is ready to hatch!</span>")
		meat_counter -= 2

/obj/effect/landmark/corpse/mob_spawn/ash_walker
	name = "ash walker egg"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/unathi/ashwalker
	corpsehelmet = /obj/item/clothing/head/helmet/gladiator
	corpseuniform = /obj/item/clothing/under/gladiator
	anchored = 0
	density = 0
	flavour_text = {"<B>You are an Ash Walker. Your tribe worships<span class='danger'>the necropolis</span>. The wastes are sacred ground, it's monsters a blessed bounty. You have seen lights in the distance though, the arrival of outsiders seeking to destroy the land. Fresh sacrifices.</B>"}

/obj/effect/landmark/corpse/mob_spawn/ash_walker/special(mob/living/new_spawn)
	new_spawn.real_name = random_name(mob_gender,mob_species)
	new_spawn << "Drag corpes to your nest to feed the young, and spawn more Ash Walkers. Bring glory to the tribe!"
