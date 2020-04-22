/obj/item/reagent_containers/food/snacks/breadslice/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/reagent_containers/food/snacks/customizable/sandwich/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/snacks/bun/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/reagent_containers/food/snacks/customizable/burger/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)

/obj/item/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/reagent_containers/food/snacks/customizable/pizza/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()


/obj/item/reagent_containers/food/snacks/boiledspaghetti/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/reagent_containers/food/snacks/customizable/pasta/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()


/obj/item/trash/plate/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/reagent_containers/food/snacks/customizable/fullycustom/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()

/obj/item/trash/bowl
	name = "cuenco"
	desc = "Un cuenco vacio, pon un poco de comida en el para hacer una sopa."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "soup"

/obj/item/trash/bowl/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/reagent_containers/food/snacks/customizable/soup/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon_state = "breadslice"
	baseicon = "sandwichcustom"
	basename = "sandwich"
	toptype = new /obj/item/reagent_containers/food/snacks/breadslice()



/obj/item/reagent_containers/food/snacks/customizable
	name = "sandwich"
	desc = "A sandwich! Un viejo clasico."
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "sandwichcustom"
	var/baseicon = "sandwichcustom"
	var/basename = "sandwichcustom"
	bitesize = 4
	var/top = 1	//Do we have a top?
	var/obj/item/toptype
	var/snack_overlays = 1	//Do we stack?
//	var/offsetstuff = 1 //Do we offset the overlays?
	var/sandwich_limit = 40
	var/fullycustom = 0
	trash = /obj/item/trash/plate
	var/list/ingredients = list()
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person.Una pizz"
	icon_state = "personal_pizza"
	baseicon = "personal_pizza"
	basename = "personal pizza"
	snack_overlays = 0
	top = 0
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/customizable/pasta
	name = "spaghetti"
	desc = "Pasta. Con cosas. Delicioso"
	icon_state = "pasta_bot"
	baseicon = "pasta_bot"
	basename = "pasta"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	desc = "Tasty bread."
	icon_state = "breadcustom"
	baseicon = "breadcustom"
	basename = "bread"
	snack_overlays = 0
	top = 0
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/customizable/cook/pie
	name = "pastel"
	desc = "Delicioso pastel"
	icon_state = "piecustom"
	baseicon = "piecustom"
	basename = "pie"
	snack_overlays = 0
	top = 0
	tastes = list("pie" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	baseicon = "cakecustom"
	basename = "cake"
	snack_overlays = 0
	top = 0
	tastes = list("cake" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/jelly
	name = "gelatina"
	desc = "Totalmente gelatinoso"
	icon_state = "jellycustom"
	baseicon = "jellycustom"
	basename = "jelly"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin-Oh nevermind."
	icon_state = "donkcustom"
	baseicon = "donkcustom"
	basename = "donk pocket"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	desc = "Kebab or Kabab?"
	icon_state = "kababcustom"
	baseicon = "kababcustom"
	basename = "kebab"
	snack_overlays = 0
	top = 0
	tastes = list("meat" = 3, "metal" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/salad
	name = "ensalada"
	desc = "Muy delicioso."
	icon_state = "saladcustom"
	baseicon = "saladcustom"
	basename = "salad"
	snack_overlays = 0
	top = 0
	tastes = list("leaves" = 1)

/obj/item/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Hechos con amor."
	icon_state = "wafflecustom"
	baseicon = "wafflecustom"
	basename = "waffles"
	snack_overlays = 0
	top = 0
	tastes = list("waffles" = 1)

/obj/item/reagent_containers/food/snacks/customizable/candy/cookie
	name = "galleta"
	desc = "GALLETA!!1!"
	icon_state = "cookiecustom"
	baseicon = "cookiecustom"
	basename = "cookie"
	snack_overlays = 0
	top = 0
	tastes = list("cookie" = 1)

/obj/item/reagent_containers/food/snacks/customizable/candy/cotton
	name = "algodon de azucar"
	desc = "Quien puede tomar un altardecer, espolvorealo con el rocio."
	icon_state = "cottoncandycustom"
	baseicon = "cottoncandycustom"
	basename = "flavored cotton candy"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "osito de gominola gigante"
	desc = "Cubrelo en chocolate con un milagro o dos,"
	icon_state = "gummybearcustom"
	baseicon = "gummybearcustom"
	basename = "flavored giant gummy bear"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "gusanito de gominola gigante"
	desc = "El hombre dulce puede porque el lo mezcla con amor."
	icon_state = "gummywormcustom"
	baseicon = "gummywormcustom"
	basename = "flavored giant gummy worm"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "gomita"
	desc = "Hace al mundo saber bien."
	icon_state = "jellybeancustom"
	baseicon = "jellybeancustom"
	basename = "flavored giant jelly bean"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "rompemuelas"
	desc = "Quien puede tomar un arcoiris, envuelvelo en un suspiro"
	icon_state = "jawbreakercustom"
	baseicon = "jawbreakercustom"
	basename = "flavored jawbreaker"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/candycane
	name = "baston de caramelo"
	desc = "bañalo en sol y haz tarta de frutilla y limon"
	icon_state = "candycanecustom"
	baseicon = "candycanecustom"
	basename = "flavored candy cane"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/gum
	name = "chicle"
	desc = "El hombre del dulce puede porque el mezcla con el amor y hace al mundo saber bien. Y el mundo sabe bien porque el hombre del dulce piensa que deberia ser asi..."
	icon_state = "gumcustom"
	baseicon = "gumcustom"
	basename = "flavored gum"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/donut
	name = "rosquilla rellena"
	desc = "Donut come esto!" // kill me
	icon_state = "donutcustom"
	baseicon = "donutcustom"
	basename = "filled donut"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/bar
	name = "barra de chocolate"
	desc = "Hecho en una fabrica"
	icon_state = "barcustom"
	baseicon = "barcustom"
	basename = "flavored chocolate bar"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/sucker
	name = "chupachup"
	desc = "lame lame lame lame."
	icon_state = "suckercustom"
	baseicon = "suckercustom"
	basename = "flavored sucker"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/cash
	name = "billete de chocolate"
	desc = "Tengo hemorroides!"
	icon_state = "cashcustom"
	baseicon = "cashcustom"
	basename = "flavored cash"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/candy/coin
	name = "moneda de chocolate"
	desc = "Clink, clink, clink."
	icon_state = "coincustom"
	baseicon = "coincustom"
	basename = "flavored coin"
	snack_overlays = 0
	top = 0

/obj/item/reagent_containers/food/snacks/customizable/fullycustom // In the event you fuckers find something I forgot to add a customizable food for.
	name = "sobre un plato."
	desc = "A unique dish."
	icon_state = "fullycustom"
	baseicon = "fullycustom"
	basename = "on a plate"
	snack_overlays = 0
	top = 0
	sandwich_limit = 20
	fullycustom = 1

/obj/item/reagent_containers/food/snacks/customizable/soup
	name = "sopa"
	desc = "Un cuenco con liquido con... cosas dentro"
	icon_state = "soup"
	baseicon = "soup"
	basename = "soup"
	snack_overlays = 0
	trash = /obj/item/trash/bowl
	top = 0
	tastes = list("soup" = 1)

/obj/item/reagent_containers/food/snacks/customizable/burger
	name = "pan de hamburguesa"
	desc = "Un pan para una hamburguesa, delicioso"
	icon_state = "burger"
	baseicon = "burgercustom"
	basename = "burger"
	toptype = new /obj/item/reagent_containers/food/snacks/bun()
	tastes = list("bun" = 4)

/obj/item/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(contents.len > sandwich_limit)
		to_chat(user, "<span class='warning'>Si pones algo en [src] se hara un desastre.</span>")
		return
	if(!istype(I, /obj/item/reagent_containers/food/snacks))
		to_chat(user, "\The [I] no es algo que te gustaria comer.")
		return
	to_chat(user, "<span class='notice'>Anades [I] a [src].</span>")
	if(istype(I,  /obj/item/reagent_containers/))
		var/obj/item/reagent_containers/F = I
		F.reagents.trans_to(src, F.reagents.total_volume)
	if(istype(I, /obj/item/reagent_containers/food/snacks/customizable))
		var/obj/item/reagent_containers/food/snacks/customizable/origin = I
		ingredients += origin.ingredients
	user.drop_item()
	cooktype[basename] = 1
	I.loc = src
	if(!istype(I, toptype))
		ingredients += I
	updateicon()
	name = newname()


/obj/item/reagent_containers/food/snacks/customizable/proc/updateicon()
	overlays = 0
	var/i=0
	for(var/obj/item/O in ingredients)
		i++
		if(!fullycustom)
			var/image/I = new(icon, "[baseicon]_filling")
			if(istype(O, /obj/item/reagent_containers/food/snacks))
				var/obj/item/reagent_containers/food/snacks/food = O
				if(!food.filling_color == "#FFFFFF")
					I.color = food.filling_color
				else
					I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			else
				I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			if(snack_overlays)
				I.pixel_x = pick(list(-1,0,1))
				I.pixel_y = (i*2)+1
			overlays += I
		else
			var/image/F = new(O.icon, O.icon_state)
			F.pixel_x = pick(list(-1,0,1))
			F.pixel_y = pick(list(-1,0,1))
			overlays += F
			overlays += O.overlays

	if(top)
		var/image/T = new(icon, "[baseicon]_top")
		T.pixel_x = pick(list(-1,0,1))
		T.pixel_y = (ingredients.len * 2)+1
		overlays += T

/obj/item/reagent_containers/food/snacks/customizable/Destroy()
	QDEL_LIST(ingredients)
	return ..()

/obj/item/reagent_containers/food/snacks/customizable/examine(mob/user)
	. = ..()
	if(LAZYLEN(ingredients))
		var/whatsinside = pick(ingredients)
		. += "<span class='notice'> Crees que logras ver [whatsinside].</span>"


/obj/item/reagent_containers/food/snacks/customizable/proc/newname()
	var/unsorteditems[0]
	var/sorteditems[0]
	var/unsortedtypes[0]
	var/sortedtypes[0]
	var/endpart = ""
	var/c = 0
	var/ci = 0
	var/ct = 0
	var/seperator = ""
	var/sendback = ""
	var/list/levels = list("", "double", "triple", "quad", "huge")

	for(var/obj/item/ing in ingredients)
		if(istype(ing, /obj/item/shard))
			continue


		if(istype(ing, /obj/item/reagent_containers/food/snacks/customizable))				// split the ingredients into ones with basenames (sandwich, burger, etc) and ones without, keeping track of how many of each there are
			var/obj/item/reagent_containers/food/snacks/customizable/gettype = ing
			if(unsortedtypes[gettype.basename])
				unsortedtypes[gettype.basename]++
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
			else
				(unsortedtypes[gettype.basename]) = 1
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
		else
			if(unsorteditems[ing.name])
				unsorteditems[ing.name]++
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]
			else
				unsorteditems[ing.name] = 1
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]

	sorteditems = sortlist(unsorteditems, ci)				//order both types going from the lowest number to the highest number
	sortedtypes = sortlist(unsortedtypes, ct)

	for(var/ings in sorteditems)			   //add the non-basename items to the name, sorting out the , and the and
		c++
		if(c == sorteditems.len - 1)
			seperator = " and "
		else if(c == sorteditems.len)
			seperator = " "
		else
			seperator = ", "

		if(sorteditems[ings] > levels.len)
			sorteditems[ings] = levels.len

		if(sorteditems[ings] <= 1)
			sendback +="[ings][seperator]"
		else
			sendback +="[levels[sorteditems[ings]]] [ings][seperator]"

	for(var/ingtype in sortedtypes)   // now add the types basenames, keeping the src one seperate so it can go on the end
		if(sortedtypes[ingtype] > levels.len)
			sortedtypes[ingtype] = levels.len
		if(ingtype == basename)
			if(sortedtypes[ingtype] < levels.len)
				sortedtypes[ingtype]++
			endpart = "[levels[sortedtypes[ingtype]]] decker [basename]"
			continue
		if(sortedtypes[ingtype] >= 2)
			sendback += "[levels[sortedtypes[ingtype]]] decker [ingtype] "
		else
			sendback += "[ingtype] "

	if(endpart)
		sendback += endpart
	else
		sendback += basename

	if(length(sendback) > 80)
		sendback = "[pick(list("absurd","colossal","enormous","ridiculous","massive","oversized","cardiac-arresting","pipe-clogging","edible but sickening","sickening","gargantuan","mega","belly-burster","chest-burster"))] [basename]"
	return sendback

/obj/item/reagent_containers/food/snacks/customizable/proc/sortlist(list/unsorted, highest)
	var/sorted[0]
	for(var/i = 1, i<= highest, i++)
		for(var/it in unsorted)
			if(unsorted[it] == i)
				sorted[it] = i
	return sorted
