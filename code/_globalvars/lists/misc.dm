var/global/list/alphabet_uppercase = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z") //added for Xenoarchaeology, might be useful for other stuff

//Reagent stuff
var/list/tachycardics = list("coffee", "methamphetamine", "nitroglycerin", "thirteenloko", "nicotine")	//increase heart rate
var/list/bradycardics = list("neurotoxin", "cryoxadone", "space_drugs")					//decrease heart rate
var/list/heartstopper = list("capulettium", "capulettium_plus") //this stops the heart
var/list/cheartstopper = list() //this stops the heart when overdose is met -- c = conditional

var/list/restricted_camera_networks = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"CentCom",
	"ERT",
	"NukeOps",
	"Thunderdome",
	"UO45",
	"UO45R",
	"Xeno"
	)