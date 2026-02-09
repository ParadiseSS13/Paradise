/datum/heretic_knowledge_tree_column/blade_to_rust
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/blade
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/rust

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/armor
	tier2 = list(/datum/heretic_knowledge/crucible, /datum/heretic_knowledge/rifle)
	tier3 = /datum/heretic_knowledge/dummy_rust_to_blade

// Sidepaths for knowledge between Rust and Blade.

/datum/heretic_knowledge/dummy_rust_to_blade
	name = "Rust and Blade ways"
	desc = "Research this to gain access to the other path"
	gain_text = "For what is rust, but the tale of a blade used well."
	cost = 1


/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "Allows you to transmute a table and a gas mask to create Eldritch Armor. \
		Eldritch Armor provides great protection while also acting as a focus when hooded."
	gain_text = "The Rusted Hills welcomed the Blacksmith in their generosity. And the Blacksmith \
		returned their generosity in kind."

	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	desc = "Allows you to transmute a portable water tank and a table to create a Mawed Crucible. \
		The Mawed Crucible can brew powerful potions for combat and utility, but must be fed bodyparts and organs between uses."
	gain_text = "This is pure agony. I wasn't able to summon the figure of the Aristocrat, \
		but with the Priest's attention I stumbled upon a different recipe..."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/eldritch_crucible)
	cost = 1

	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "crucible"


/datum/heretic_knowledge/rifle
	name = "Lionhunter's Rifle"
	desc = "Allows you to transmute a piece of wood, with hide \
		from any animal,and a camera to create the Lionhunter's rifle. \
		The Lionhunter's Rifle is a long ranged ballistic weapon with three shots. \
		These shots function as normal, albeit weak high-caliber munitions when fired from \
		close range or at inanimate objects. You can aim the rifle at distant foes, \
		causing the shot to mark your victim with your grasp and teleport you directly to them. \
		Grants thermal vision when scoped in."
	gain_text = "I met an old man in an antique shop who wielded a very unusual weapon. \
		I could not purchase it at the time, but they showed me how they made it ages ago."

	required_atoms = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/projectile/shotgun/boltaction/lionhunter)
	cost = 1


	research_tree_icon_path = 'icons/obj/weapons/wide_guns.dmi'
	research_tree_icon_state = "lionhunter"

/datum/heretic_knowledge/rifle_ammo
	name = "Lionhunter Rifle Ammunition"
	desc = "Allows you to transmute 3 ballistic ammo casings (used or unused) of any caliber, \
		including shotgun shells to create an extra clip of ammunition for the Lionhunter Rifle."
	gain_text = "The weapon came with three rough iron balls, intended to be used as ammunition. \
		They were very effective, for simple iron, but used up quickly. I soon ran out. \
		No replacement munitions worked in their stead. It was peculiar in what it wanted."
	required_atoms = list(
		list(/obj/item/ammo_casing, /obj/item/trash/spentcasing) = 3,
	)
	banned_atom_types = list(/obj/item/ammo_casing/lionhunter) // The gods are very generous with ingredients, but not *that* generous
	result_atoms = list(/obj/item/ammo_box/lionhunter)

	research_tree_icon_path = 'icons/obj/ammo.dmi'
	research_tree_icon_state = "310_strip"



