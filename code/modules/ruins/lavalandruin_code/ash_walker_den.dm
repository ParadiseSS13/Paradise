#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/ash_walker
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"

	move_resist = INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

	var/meat_counter = 6

/obj/structure/lavaland/ash_walker/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/deconstruct(disassembled)
	new /obj/item/assembly/signaler/anomaly/random(get_step(loc, pick(GLOB.alldirs)))
	new	/obj/effect/collapse(loc)
	return ..()

/obj/structure/lavaland/ash_walker/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/ash_walker/proc/consume()
	for(var/mob/living/H in view(src, 1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Serrated tendrils eagerly pull [H] to [src], tearing the body apart as its blood seeps over the eggs.</span>")
			playsound(get_turf(src),'sound/magic/demon_consume.ogg', 100, 1)
			for(var/obj/item/W in H)
				if(!H.drop_item_to_ground(W))
					qdel(W)
			if(ismegafauna(H))
				meat_counter += 20
			else
				meat_counter++
			H.gib()
			obj_integrity = min(obj_integrity + max_integrity*0.05,max_integrity)//restores 5% hp of tendril

/obj/structure/lavaland/ash_walker/proc/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/human/alive/ash_walker(get_step(loc, pick(GLOB.alldirs)))
		visible_message("<span class='danger'>One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!</span>")
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD

/obj/effect/mob_spawn/human/alive/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	role_name = "ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	important_info = "Do not leave Lavaland without admin permission. Do not attack the mining outpost without being provoked."
	description = "You are an ashwalker, a native inhabitant of Lavaland. Try to survive with nothing but spears and other tribal technology. Bring dead bodies back to your tendril to create more of your kind. You are free to attack miners and other outsiders."
	flavour_text = "Your tribe worships the Necropolis. The wastes are sacred ground, its monsters a blessed bounty. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Necropolis and its domain. Fresh sacrifices for your nest. \
	Keep in mind - your speed is given to you by the power of the Necropolis, <b>leaving the planet will make your body more lethargic!</b>"
	assignedrole = "Ash Walker"
	density = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	death_cooldown = 300 SECONDS
	allow_gender_pick = TRUE
	mob_species = /datum/species/unathi/ashwalker
	outfit = /datum/outfit/ashwalker

/obj/effect/mob_spawn/human/alive/ash_walker/special(mob/living/carbon/human/new_spawn)
	to_chat(new_spawn, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Necropolis!</b>")
	to_chat(new_spawn, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Ash_Walker)</span>")

/obj/effect/mob_spawn/human/alive/ash_walker/New()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("An ash walker egg is ready to hatch in \the [A.name].", source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/datum/outfit/ashwalker
	name = "Ashwalker"
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker
	suit = /obj/item/clothing/suit/hooded/bone_light

#undef ASH_WALKER_SPAWN_THRESHOLD
