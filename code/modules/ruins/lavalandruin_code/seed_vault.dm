/obj/effect/spawner/random/seed_vault
	name = "seed vault seeds"
	loot = list(
		/obj/item/food/grown/mushroom/glowshroom/glowcap = 10,
		/obj/item/seeds/cherry/bomb = 10,
		/obj/item/seeds/berry/glow = 10,
		/obj/item/seeds/sunflower/moonflower = 8,
	)

/obj/effect/mob_spawn/human/alive/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	role_name = "lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	mob_species = /datum/species/diona/pod
	description = "You are a diona on Lavaland with access to a full botany setup. Perfect to mess around with plants in peace."
	flavour_text = "You are a sentient ecosystem, an example of the mastery over life that your creators possessed. Your masters, benevolent as they were, created uncounted \
	seed vaults and spread them across the universe to every planet they could chart. You are in one such seed vault. Your goal is to cultivate and spread life wherever it will go while waiting \
	for contact from your creators. Estimated time of last contact: Deployment, 5x10^3 millennia ago."
	assignedrole = "Seed Vault Diona"

/obj/effect/mob_spawn/human/alive/seed_vault/Initialize(mapload)
	mob_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout", "Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	return ..()

/obj/effect/mob_spawn/human/alive/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()
