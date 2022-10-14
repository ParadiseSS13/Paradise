/mob/living/carbon/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || ninja == src || !ninja_suit.s_initialized || drain_act_protected)
		return INVALID_DRAIN

	. = DRAIN_MOB_SHOCK_FAILED

	//Default cell = 10,000 charge, 10,000/1000 = 10 uses without charging/upgrading
	if(ninja_suit.cell?.charge && ninja_suit.cell.use(1000))
		. = DRAIN_MOB_SHOCK
		//Got that electric touch
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)
		playsound(src, 'sound/machines/defib_zap.ogg', 50, TRUE, 5)
		visible_message(span_danger("[ninja] electrocutes [src] with [ninja.p_their()] touch!"), span_userdanger("[ninja] electrocutes you with [ninja.p_their()] touch!"))
		Weaken(3)
		add_attack_logs(ninja, src, "zap-touched with ninja-gloves")
