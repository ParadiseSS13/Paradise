/datum/skill
	var/name = "Standard skill"
	var/id
	var/combat_skill = FALSE
	var/showing_text = TRUE
	var/base_stat
	var/base_mod
	var/spec
	var/no_default = FALSE

/datum/skill/melee
	name = "Melee Combat"
	combat_skill = TRUE
	id = SKILL_MELEE
	base_stat = STAT_DX
	base_mod = -4
	spec = FALSE

/datum/skill/unarmed
	name = "Unarmed Combat"
	combat_skill = TRUE
	id = SKILL_UNARM
	showing_text = TRUE
	base_stat = SKILL_MELEE
	base_mod = -5
	spec = TRUE
/datum/skill/ranged
	name = "Ranged Combat"
	combat_skill = TRUE
	id = SKILL_RANGE
	base_stat = STAT_PR
	base_mod = -4
	spec = FALSE
/datum/skill/throwing
	name = "Throwing"
	combat_skill = TRUE
	id = SKILL_THROW
	base_stat = STAT_PR
	base_mod = -5
	spec = FALSE
/datum/skill/farming
	name = "Farming"
	id = SKILL_FARM
	base_stat = STAT_IN
	base_mod = -5
	spec = FALSE
/datum/skill/cooking
	name = "Cooking"
	id = SKILL_COOK
	base_stat = STAT_IN
	base_mod = -5
	spec = FALSE
/datum/skill/engineering
	name = "Engineering"
	id = SKILL_ENGINE
	base_stat = STAT_IN
	base_mod = -6
	spec = FALSE
/datum/skill/medicine
	name = "Medicine"
	id = SKILL_MEDIC
	base_stat = STAT_IN
	base_mod = -5
	spec = FALSE
/datum/skill/cleaning
	name = "Cleaning"
	id = SKILL_CLEAN
	base_stat = STAT_IN
	base_mod = -4
	spec = FALSE
/datum/skill/smithing
	name = "Smithing"
	id = SKILL_SMITH
	base_stat = STAT_IN
	base_mod = -4
	spec = FALSE
/datum/skill/climbing
	name = "Climbing"
	id = SKILL_CLIMB
	base_stat = STAT_DX
	base_mod = -5
	spec = FALSE
/datum/skill/masonry
	name = "Masonry"
	id = SKILL_MASON
	base_stat = STAT_IN
	base_mod = -4
	spec = FALSE
/datum/skill/steal
	name = "Pickpocketing"
	id = SKILL_STEAL
	base_stat = STAT_DX
	base_mod = -6
	spec = FALSE
/datum/skill/swimming
	name = "Swimming"
	id = SKILL_SWIM
	base_stat = STAT_HT
	base_mod = -5
	spec = FALSE
/datum/skill/party
	name = "Party"
	id = SKILL_PARTY
	base_stat = STAT_HT
	base_mod = -4
	spec = FALSE
/datum/skill/mining
	name = "Mining"
	id = SKILL_MINE
	base_stat = STAT_ST
	base_mod = -5
	spec = FALSE
/datum/skill/tanning
	name = "Tanning"
	id = SKILL_TAN
	base_stat = STAT_DX
	base_mod = -4
	spec = FALSE
/datum/skill/shroomcutting
	name = "Shroomcutting"
	id = SKILL_CUT
	base_stat = STAT_ST
	base_mod = -5
	spec = FALSE
/datum/skill/alchemy
	name = "Alchemy"
	id = SKILL_ALCH
	base_stat = SKILL_NONE
	base_mod = 0
	spec = FALSE
/datum/skill/survival
	name = "Survival"
	id = SKILL_SURVIV
	base_stat = STAT_PR
	base_mod = -5
	spec = FALSE
/datum/skill/fishing
	name = "Fishing"
	id = SKILL_FISH
	base_stat = STAT_PR
	base_mod = -4
	spec = FALSE
/datum/skill/lockpicking
	name = "Lockpicking"
	id = SKILL_LOCK
	base_stat = STAT_IN
	base_mod = -5
	spec = FALSE
/datum/skill/sneak
	name = "Sneak"
	id = SKILL_SNEAK
	base_stat = STAT_DX
	base_mod = -5
	spec = FALSE
/datum/skill/riding
	name = "Riding"
	id = SKILL_RIDE
	base_stat = STAT_DX
	base_mod = -5
	spec = FALSE
/datum/skill/music
	name = "Music"
	id = SKILL_MUSIC
	base_stat = SKILL_NONE
	base_mod = 0
	spec = FALSE
/datum/skill/traps
	name = "Traps"
	id = SKILL_TRAP
	base_stat = STAT_IN
	base_mod = -5
	spec = FALSE
/datum/skill/craft
	name = "Craft"
	id = SKILL_CRAFT
	base_stat = STAT_IN
	base_mod = -4
	spec = FALSE
/datum/skill/boating
	name = "Boating"
	id = SKILL_BOAT
	base_stat = STAT_DX
	base_mod = -5
	spec = FALSE
/datum/skill/observation
	name = "Observation"
	id = SKILL_OBSERV
	base_stat = STAT_PR
	base_mod = -5
	spec = FALSE

//specialization
/datum/skill/sword
	name = "Swords"
	combat_skill = TRUE
	id = SKILL_SWORD
	showing_text = FALSE
	base_stat = SKILL_MELEE
	base_mod = -5
	spec = TRUE
/datum/skill/knife
	name = "Knives"
	combat_skill = TRUE
	id = SKILL_KNIFE
	showing_text = FALSE
	base_stat = SKILL_MELEE
	base_mod = -4
	spec = TRUE
/datum/skill/swing
	name = "Axes/Clubs"
	combat_skill = TRUE
	id = SKILL_SWING
	showing_text = FALSE
	base_stat = SKILL_MELEE
	base_mod = -5
	spec = TRUE
/datum/skill/staff
	name = "Staffs/Spears"
	combat_skill = TRUE
	id = SKILL_STAFF
	showing_text = FALSE
	base_stat = SKILL_MELEE
	base_mod = -5
	spec = TRUE
/datum/skill/crossbow
	name = "Crossbows"
	combat_skill = TRUE
	id = SKILL_CBOW
	showing_text = FALSE
	base_stat = SKILL_RANGE
	base_mod = -4
	spec = TRUE
/datum/skill/bow
	name = "Bows"
	combat_skill = TRUE
	id = SKILL_BOW
	showing_text = FALSE
	base_stat = SKILL_RANGE
	base_mod = -5
	spec = TRUE
/datum/skill/flail
	name = "Flails"
	combat_skill = TRUE
	id = SKILL_FLAIL
	showing_text = FALSE
	base_stat = SKILL_MELEE
	base_mod = -6
	spec = TRUE
/datum/skill/surgery
	name = "Surgery"
	id = SKILL_SURG
	base_stat = SKILL_MEDIC
	base_mod = -4
	spec = TRUE
	no_default = TRUE
