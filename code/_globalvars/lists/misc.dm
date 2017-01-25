var/global/list/alphabet = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
var/global/list/alphabet_uppercase = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
var/global/list/zero_character_only = list("0")
var/global/list/hex_characters = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
var/global/list/binary = list("0","1")

var/global/list/day_names = list("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
var/global/list/month_names = list("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")

var/list/restricted_camera_networks = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"CentComm",
	"ERT",
	"NukeOps",
	"Thunderdome",
	"UO45",
	"UO45R",
	"Xeno",
	"Hotel"
	)

var/list/mineral_turfs = list()
