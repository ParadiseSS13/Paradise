	///////////
var/BLINDBLOCK = 0
var/COLOURBLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/FAKEBLOCK = 0
var/COUGHBLOCK = 0
var/GLASSESBLOCK = 0
var/EPILEPSYBLOCK = 0
var/TWITCHBLOCK = 0
var/NERVOUSBLOCK = 0
var/WINGDINGSBLOCK = 0
var/MONKEYBLOCK = 50 // Monkey block will always be the DNA_SE_LENGTH

var/BLOCKADD = 0
var/DIFFMUT = 0

var/BREATHLESSBLOCK = 0
var/REMOTEVIEWBLOCK = 0
var/REGENERATEBLOCK = 0
var/INCREASERUNBLOCK = 0
var/REMOTETALKBLOCK = 0
var/MORPHBLOCK = 0
var/COLDBLOCK = 0
var/HALLUCINATIONBLOCK = 0
var/NOPRINTSBLOCK = 0
var/SHOCKIMMUNITYBLOCK = 0
var/SMALLSIZEBLOCK = 0

///////////////////////////////
// Goon Stuff
///////////////////////////////
// Disabilities
var/LISPBLOCK = 0
var/MUTEBLOCK = 0
var/RADBLOCK = 0
var/FATBLOCK = 0
var/CHAVBLOCK = 0
var/SWEDEBLOCK = 0
var/SCRAMBLEBLOCK = 0
var/STRONGBLOCK = 0
var/HORNSBLOCK = 0
var/COMICBLOCK = 0

// Powers
var/SOBERBLOCK = 0
var/PSYRESISTBLOCK = 0
var/SHADOWBLOCK = 0
var/CHAMELEONBLOCK = 0
var/CRYOBLOCK = 0
var/EATBLOCK = 0
var/JUMPBLOCK = 0
var/EMPATHBLOCK = 0
var/IMMOLATEBLOCK = 0
var/POLYMORPHBLOCK = 0

///////////////////////////////
// /vg/ Mutations
///////////////////////////////
var/LOUDBLOCK = 0
var/DIZZYBLOCK = 0

var/list/reg_dna = list(  ) //this appears to be a list of UE == real_name correlations
var/list/global_mutations = list() // list of hidden mutation things
