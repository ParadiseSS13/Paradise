/datum/spell/aoe/conjure/summon_supermatter
	name = "Summon Supermatter Crystal"
	desc = "Summons an active supermatter crystal. Imbues you with some supermatter, giving you resistance to it's hallucinations and radiation immunity."
	base_cooldown = 5 MINUTES
	cooldown_min = 60 SECONDS
	summon_type = list(/obj/machinery/atmospherics/supermatter_crystal/shard)
	action_icon_state = "summon_supermatter"
	aoe_range = 0

/datum/spell/aoe/conjure/summon_supermatter/cast(list/targets, mob/living/user = usr)
	var/list/summoned_objects = ..()
	for(var/obj/machinery/atmospherics/supermatter_crystal/our_crystal in summoned_objects)
		addtimer(CALLBACK(our_crystal, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, manual_start), 3000), 3 SECONDS)
