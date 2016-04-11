/obj/item/weapon/book/databook
	var/keyfragA = "A"
	var/keyfragB = "B"
	var/keyfragC = "C"
	var/keyfragD = "D"
	var/keyfragE = "E"
	var/list/keyfraglist()



/obj/item/weapon/book/databook/New()
	..()


	keyfraglist=list("fortress","olive","ruler","bit","powder",
	"drip","gargoyle","swindler","village","grinning","predator",
	"echo","bauble","alley","wastes","coil","red","raisins","pass","card")

	keyfragA = keyfraglist[rand(1,20)]
	keyfragB = keyfraglist[rand(1,20)]
	keyfragC = keyfraglist[rand(1,20)]
	keyfragD = keyfraglist[rand(1,20)]
	keyfragE = keyfraglist[rand(1,20)]

//  unique databooks with unique rewards, very rare spawn chance. Not guarenteed to spawn during rounds.
/obj/item/weapon/book/databook/rare/codex
	name = "Ham-U-Rabi codex"
	icon_state = "book6"
	title = "The laws of the hampire"
	author = "Randy Birch, The hamperor of the hampire"
	dat = {"<html>
				<head>
				<style>
				p  {font-style: italic;}
				</style>
				</head>
				<body>
				<p> You read through laws and legal texts concerning an ancient forgotten empire.
				There seem to be a variety of references to individual legal cases and specific legal precedents.
				</p>
				</body>
				</html>"}



/obj/item/weapon/book/databook/rare/compendium
	name = "Compendium of the ancient defender's tales"
	icon_state = "book3"
	title = "Defense of the Ancients: A tale of rage and fury"
	author = "Ayse F. Rogge"
	dat = {"<html>
				<head>
				<style>
				p  {font-style: italic;}
				</style>
				</head>
				<body>
				<p> You read about a long forgotten battlefield, fueled by rage and despair, in the end nothing was left but salted earth and crushed thrones...
				</p>
				</body>
		</html>"}
	var/poop = 1


/obj/item/weapon/book/databook/rare/chart
	name = "Some old chart"
	icon_state = "book1"
	title = "The world as we know it"
	author = "Mer C. Ator"
	dat = {"<html>
				<head>
				<style>
				p  {font-style: italic;}
				</style>
				</head>
				<body>
				<p> You carefully study the ancient chart, it seems familiar somehow, maybe you've seen this before?
				</p>
				</body>
	</html>"}

/obj/item/weapon/book/databook/rare/mythos
	name = "A Space Illead"
	icon_state = "book2"
	title = "The wonderous adventures of Day Vid Bew-Ey"
	author = "Hom Er"
	dat = {"<html>
	<head>
				<style>
				p  {font-style: italic;}
				</style>
				</head>
				<body>
				<p> You read the legendary stories of one of the greatest bards to have ever lived in ancient times. You can almost hear the music discribed here come to life.
				</p>
				</body>
	</html>"}

/obj/item/weapon/book/databook/rare/tablet
	name = "Tablet of Eyped Eir"
	icon_state = "book5"
	title = "How to succeed at marketing."
	author = "Boj evetS"
	dat = {"<html>
	<head>
				<style>
				p  {font-style: italic;}
				</style>
				</head>
				<body>
				<p> It quickly becomes clear just how good the man who wrote this was at manipulation people into buying his wares. Astonishing how easy it is to trick people like that isn't it?
				</p>
				</body>
	</html>"}

// frequent spawning books, randomizing the more than just the names would be neat

/obj/item/weapon/book/databook/generic/coordinates
	name ="Databook1"
	icon_state="triangulate"
	dat = {"<html>
			<head>
				<style>
				p  {font-style: italic;}
				</style>
			</head>
			<body>
				<p> you read about faraway places in exotic tales...
				</p>
			</body>
	</html>"}

/obj/item/weapon/book/databook/generic/coordinates/New()
	..()
	var/name_part1
	var/name_part2

	name_part1 = pick("The journey","The kingdom","The lost legion","The final voyage","The grand expedition","The Chronicles","The myth","The last stand","The legacy")
	name_part2 = pick("Captain Krellian","Kirgon Blackguard","Numun Util","Odhu Ereh","Kisma Vradelm","Tahi Bhunbin","Cheasren Ilgom","Svodfa","Taursi Honeyward","Queen Yanra")
	name = name_part1+" of "+name_part2
	author = name_part2 +"'s personal servant"
	title = name




/obj/item/weapon/book/databook/generic/food
	name ="Databook2"
	icon_state="cooked_book"
	dat = {"<html>
			<head>
				<style>
				p  {font-style: italic;}
				</style>
			</head>
			<body>
				<p> you read about Strange dining customs and royal feasts in ancient, remote courts of royalty...
				</p>
			</body>

	</html>"}



/obj/item/weapon/book/databook/generic/food/New()
	..()
	var/name_part1
	var/name_part2

	name_part1 = pick("Kitchen","Food","Cuisine","Desserts","101 easy appitizers","Grilling techniques","Fine pastries and baked goods","Fruits and Vegetables","Poultry dishes")
	name_part2 = pick("Shcran","Bellatan","Thesulan","Tarklon","Volkodan","Mabuberan","Mazon","Ubukan","Veneran","Pavonian",)
	name = name_part1 +" of the "+name_part2+"s"
	title = name
	author= " the royal chef's guild of the"+name_part2+" people"

/obj/item/weapon/book/databook/generic/clothes
	name ="Databook3"
	icon_state="evabook"
	dat = {"<html>
			<head>
				<style>
				p  {font-style: italic;}
				</style>
			</head>
			<body>
				<p> you see pictures of people wearing all sorts of colourful and exotic clothes."
				</p>
			</body>

	</html>"}



/obj/item/weapon/book/databook/generic/clothes/New()
	..()
	var/name_part1
	var/name_part2



	name_part1 = pick("A holiday guide: ","This summer: ","Stay warm this Winter: ","Make spring look alive: ","Keep autumn fancy: ","Turning heads: ","Get the attention you deserve: ")
	name_part2 = pick("The traditional garb of Hasweyles. ","The fashionista's must-haves of Cloisau.","Looking fabulous in Osmington.","The hottest clothes in Moslousil.","How to dress for success in Sospary.","Our new collection in Qepliuwana.")
	name = name_part1+name_part2
	title = name
	author = "The fashion police" //JK, don't know yet

//spawning in random books, uses code from lootdrop.dm

/obj/effect/spawner/lootdrop/databooks
	loot = list(
	/obj/item/weapon/book/databook/rare/codex = 1,
	/obj/item/weapon/book/databook/rare/compendium = 1,
	/obj/item/weapon/book/databook/rare/chart = 1,
	/obj/item/weapon/book/databook/rare/tablet = 1,
	/obj/item/weapon/book/databook/rare/mythos =1,
	/obj/item/weapon/book/databook/generic/coordinates = 15,
	/obj/item/weapon/book/databook/generic/food = 15,
	/obj/item/weapon/book/databook/generic/clothes =  15
	)

