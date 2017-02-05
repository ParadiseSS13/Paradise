// Atoms
#define isatom(A) istype(A, /atom)
#define ismovableatom(A) istype(A, /atom/movable)

// Mobs 
#define ismegafauna(A) istype(A, /mob/living/simple_animal/hostile/megafauna)

//Turfs
#define issimulatedturf(A) istype(A, /turf/simulated)

#define isspaceturf(A) istype(A, /turf/space)

#define isfloorturf(A) istype(A, /turf/simulated/floor)

#define isunsimulatedturf(A) istype(A, /turf/unsimulated)

#define iswallturf(A) istype(A, /turf/simulated/wall)

#define isreinforcedwallturf(A) istype(A, /turf/simulated/wall/r_wall)

#define ismineralturf(A) istype(A, /turf/simulated/mineral)

// Misc
#define isclient(A) istype(A, /client)
#define isradio(A) istype(A, /obj/item/device/radio)
#define ispill(A) istype(A, /obj/item/weapon/reagent_containers/food/pill)

