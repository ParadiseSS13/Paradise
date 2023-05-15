/obj/effect/proc_holder/spell/aoe/conjure/summon_supermatter
	name = "Summon supermatter crystal"
	desc = "Summons an active supermatter crystal. Imbues you with some supermatter, giving you resistance to it's hallucinations and radiation immunity."
	base_cooldown = 5 MINUTES
	cooldown_min = 60 SECONDS
	summon_type = list(/obj/machinery/atmospherics/supermatter_crystal/shard)
	summon_amt = 1
	aoe_range = 0

/obj/effect/proc_holder/spell/aoe/conjure/summon_supermatter/cast(list/targets, mob/living/user = usr)
	..()
	for(var/turf/our_target_turf in targets)
		for(var/obj/machinery/atmospherics/supermatter_crystal/our_crystal in our_target_turf.contents)
			addtimer(CALLBACK(our_crystal, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, manual_start), 3000), 3 SECONDS)

