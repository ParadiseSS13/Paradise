//dogs
/obj/structure/closet/critter/corgi
	name = "dog corgi crate"

/obj/structure/closet/critter/pug
	name = "dog pug crate"

/obj/structure/closet/critter/dog_bullterrier
	name = "dog bullterrier crate"
	content_mob = /mob/living/simple_animal/pet/dog/bullterrier

/obj/structure/closet/critter/dog_tamaskan
	name = "dog tamaskan crate"
	content_mob = /mob/living/simple_animal/pet/dog/tamaskan

/obj/structure/closet/critter/dog_german
	name = "dog german crate"
	content_mob = /mob/living/simple_animal/pet/dog/german

/obj/structure/closet/critter/dog_brittany
	name = "dog brittany crate"
	content_mob = /mob/living/simple_animal/pet/dog/brittany


// cats
/obj/structure/closet/critter/cat/populate_contents()
	. = ..()
	if(prob(5))
		content_mob = /mob/living/simple_animal/pet/cat/fat

/obj/structure/closet/critter/cat_white
	name = "white cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/white

/obj/structure/closet/critter/cat_birman
	name = "birman cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/birman

// fox
/obj/structure/closet/critter/fox/populate_contents()
	. = ..()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/dog/fox/forest

/obj/structure/closet/critter/fennec
	name = "fennec crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox/fennec

// amphibians
/obj/structure/closet/critter/frog
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog

/obj/structure/closet/critter/frog/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/frog/toxic
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog/toxic

/obj/structure/closet/critter/frog/toxic/populate_contents()
	. = ..()
	if(prob(25))
		content_mob = /mob/living/simple_animal/frog/toxic/scream

/obj/structure/closet/critter/frog/scream
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog/scream

/obj/structure/closet/critter/snail
	name = "snail crate"
	content_mob = /mob/living/simple_animal/snail

/obj/structure/closet/critter/snail/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/turtle
	name = "turtle crate"
	content_mob = /mob/living/simple_animal/turtle

// lizards
/obj/structure/closet/critter/iguana
	name = "iguana crate"
	content_mob = /mob/living/simple_animal/hostile/lizard

/obj/structure/closet/critter/gator
	name = "gator crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/gator

/obj/structure/closet/critter/croco
	name = "croco crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/croco

//misc
/obj/structure/closet/critter/sloth
	name = "sloth crate"
	content_mob = /mob/living/simple_animal/pet/sloth

/obj/structure/closet/critter/goose
	name = "goose crate"
	content_mob = /mob/living/simple_animal/goose

/obj/structure/closet/critter/gosling
	name = "gosling crate"
	content_mob = /mob/living/simple_animal/goose/gosling

/obj/structure/closet/critter/gosling/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/hamster
	name = "hamster crate"
	content_mob = /mob/living/simple_animal/mouse/hamster

/obj/structure/closet/critter/hamster/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/possum
	name = "possum crate"
	content_mob = /mob/living/simple_animal/possum

/obj/structure/closet/critter/possum/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/moth	//ящик дорогих шуб поели моли. Увынск.
	name = "ящик дорогих шуб"
	content_mob = /mob/living/simple_animal/moth
	var/static/prob_clothes = 50
	var/static/possible_clothes_list = list(
		/obj/item/clothing/suit/pimpcoat = 50,

		/obj/item/clothing/suit/tailcoat = 25,
		/obj/item/clothing/suit/victcoat = 25,
		/obj/item/clothing/suit/victcoat/red = 25,
		/obj/item/clothing/suit/draculacoat = 25,
		/obj/item/clothing/suit/browntrenchcoat = 25,
		/obj/item/clothing/suit/neocoat = 25,
		/obj/item/clothing/suit/blacktrenchcoat = 25,

		/obj/item/clothing/suit/storage/blueshield = 5,
		/obj/item/clothing/suit/sovietcoat = 5,

		/obj/item/clothing/suit/armor/vest/capcarapace/jacket = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/coat = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/coat/white = 1,
		)

/obj/structure/closet/critter/moth/populate_contents()
	amount = rand(1, 5)
	if(prob(50))
		content_mob = /mob/living/simple_animal/nian_caterpillar

	if(prob(prob_clothes))
		//contains = list()
		var/clothes_amount = rand(1, 8)
		for(var/i in 1 to clothes_amount)
			var/picked = pick(possible_clothes_list)
			new picked(src)
			//contains.add(picked)
