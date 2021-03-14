/obj/item/robot_module/janitor/New()
	..()
	modules += new /obj/item/reagent_containers/spray/cleaner/drone(src)

/obj/item/robot_module/janitor/respawn_consumable(mob/living/silicon/robot/R)
	var/obj/item/reagent_containers/spray/cleaner/C = locate() in modules
	C.reagents.add_reagent("cleaner", 3)
	..()
