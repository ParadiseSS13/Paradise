
/datum/unit_test/github_pr/pr_14637

/datum/unit_test/github_pr/pr_14637/odysseus/Run()
	var/turf/pilot_turf = run_loc_bottom_left
	var/mob/living/carbon/human/pilot = new (pilot_turf)
	var/turf/mecha_turf = NORTH_OF_TURF(pilot_turf)
	var/obj/mecha/medical/odysseus/ody = new /obj/mecha/medical/odysseus(mecha_turf)
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/gun = new /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun()
	ody.attackby(gun, pilot) // install the gun
	sleep(0.1) // attackby has a spawn() inside it. We're waiting for it to finish
	ody.moved_inside(pilot) // pilot

	var/turf/victim_turf = run_loc_top_right
	var/mob/living/carbon/human/victim = new /mob/living/carbon/human/monkey(victim_turf)

	// editing volume after creation is not really supported, so this is hacky
	var/syringes_used = gun.max_syringes
	gun.max_volume = syringes_used * 15
	gun.create_reagents(gun.max_volume)
	gun.synth_speed = gun.max_volume

	gun.processed_reagents += gun.known_reagents[1]
	gun.process()
	for (var/i=0; i < syringes_used; i++)
		var/obj/item/reagent_containers/syringe/s = new /obj/item/reagent_containers/syringe(pilot_turf)
		gun.load_syringe(s)

		gun.action(victim)
		sleep(1)  // not technically needed, but it looks fancy
	sleep(10) // wait for syringes to finish flying
	var/reagents_expected = syringes_used  * 15 - 1 // allow some decay due to metabolism
	var/reagents_found = victim.reagents.total_volume
	if (reagents_found < reagents_expected)
		Fail("Victim has [reagents_found] reagents total after being shot with syringe gun. Expected at least [reagents_expected].")


/datum/unit_test/github_pr/pr_14637/terror_spider/Run()
	var/turf/spider_turf = run_loc_bottom_left
	var/mob/living/simple_animal/hostile/poison/terror_spider/white/spidey = new /mob/living/simple_animal/hostile/poison/terror_spider/white(spider_turf)

	// A monkey with no armor. Should be infectable
	var/turf/monkey_turf = NORTH_OF_TURF(spider_turf)
	var/mob/living/carbon/human/monkey/monkey = new /mob/living/carbon/human/monkey(monkey_turf)

	// An engineer in a hardsuit. Should not be infectable
	var/turf/engi_turf = EAST_OF_TURF(spider_turf)
	var/mob/living/carbon/human/engi = new /mob/living/carbon/human(engi_turf)
	var/obj/item/clothing/suit/space/hardsuit/hardsuit =  new /obj/item/clothing/suit/space/hardsuit/engine()
	engi.equip_to_slot_if_possible(hardsuit, slot_wear_suit)
	hardsuit.ToggleHelmet()

	spidey.UnarmedAttack(monkey)
	for (var/i=0; i < 5; i++)   // for good measure
		spidey.UnarmedAttack(engi)

	if (!IsTSInfected(monkey))
		Fail("Mokey was bitten by a terror white and not infected.")
	if (IsTSInfected(engi))
		Fail("Engineer in a hardsuit was bitten by a terror and somehow got infected")
