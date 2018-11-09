/obj/item/seeds/pineapple
  name = "pack of pineapple seeds"
  desc = "These seeds grow into pineapple plants."
  icon_state = "seed-pineapple" //NEEDED
  species = "pineapple"
  plantname = "Pineapple Plant"
  product = /obj/item/reagent_containers/food/snacks/grown/pineapple
  maturation = 6
  lifespan = 55
  endurance = 35
  growthstages = 4
  growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
  icon_grow = "pineapple-grow" //NEEDED
  icon_dead = "pineapple-dead" //NEEDED
  genes = list(/datum/plant_gene/trait/repeated_harvest)
  reagents_add = list("water" = 0.1, "vitamin" = 0.03, "sugar" = 0.02, "plantmatter" = 0.2)

/obj/item/reagent_containers/food/snacks/grown/pineapple
  seed = /obj/item/seeds/pineapple
  name = "pineapple"
  desc = "A soft sweet interior surrounded by a spiky skin."
  slice_path = /obj/item/reagent_containers/food/snacks/pineappleslice
  slices_num = 4
  icon_state = "pineapple"
  filling_color = "#e5b437"
  w_class = WEIGHT_CLASS_NORMAL
  bitesize_mod = 3
  wine_power = 0.4