/datum/mood_event/tajaran_horridroom //Tajaran have double mood debuff for being in horried room and double mood buff for being in greatroom.
	description = "How can i live in such a dump?!"
	mood_change = -10

/datum/mood_event/horridroom
	description = "This room looks terrible!"
	mood_change = -5

/datum/mood_event/badroom
	description = "This room looks bo-o-oring."
	mood_change = -3

/datum/mood_event/vulpkanin_badroom //Vulpkanin doesn't suffer strong debuffs from a dirty room, but he also doesn't gain many buffs from a good one.
	description = "A room is just a room."
	mood_change = -1

/datum/mood_event/decentroom
	description = "This room looks alright."
	mood_change = 1

/datum/mood_event/goodroom
	description = "This room looks really pretty!"
	mood_change = 3

/datum/mood_event/greatroom
	description = "This room is beautiful!"
	mood_change = 5

/datum/mood_event/tajaran_greatroom //Tajaran have double mood debuff for being in horried room and double mood buff for being in greatroom.
	description = "This room is just right for me!"
	mood_change = 10
