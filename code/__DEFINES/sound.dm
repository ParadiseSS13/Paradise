//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_ADMIN 1023
#define CHANNEL_VOX 1022
#define CHANNEL_JUKEBOX 1021
#define CHANNEL_HEARTBEAT 1020 //sound channel for heartbeats
#define CHANNEL_BUZZ 1019
#define CHANNEL_AMBIENCE 1018

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED

#define CHANNEL_HIGHEST_AVAILABLE 1017

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS 0.5

//Ambience types

#define GENERIC_SOUNDS list('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg',\
								'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg',\
								'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg',\
								'sound/ambience/ambigen8.ogg', 'sound/ambience/ambigen9.ogg',\
								'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg',\
								'sound/ambience/ambigen12.ogg', 'sound/ambience/ambigen14.ogg', 'sound/ambience/ambigen15.ogg')

#define HOLY_SOUNDS list('sound/ambience/ambicha1.ogg', 'sound/ambience/ambicha2.ogg', 'sound/ambience/ambicha3.ogg',\
										'sound/ambience/ambicha4.ogg', 'sound/ambience/ambiholy.ogg', 'sound/ambience/ambiholy2.ogg',\
										'sound/ambience/ambiholy3.ogg')

#define HIGHSEC_SOUNDS list('sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg')

#define RUINS_SOUNDS list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
									'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
									'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
									'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambitech3.ogg',\
									'sound/ambience/ambimystery.ogg', 'sound/ambience/ambimaint1.ogg')

#define ENGINEERING_SOUNDS list('sound/ambience/ambisin1.ogg', 'sound/ambience/ambisin2.ogg', 'sound/ambience/ambisin3.ogg', 'sound/ambience/ambisin4.ogg',\
										'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg')

#define MINING_SOUNDS list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
											'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
											'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
											'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambimaint1.ogg',\
											'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')

#define MEDICAL_SOUNDS list('sound/ambience/ambinice.ogg')

#define SPOOKY_SOUNDS list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg','sound/ambience/ambiruin7.ogg','sound/ambience/ambiruin6.ogg',\
										'sound/ambience/ambiodd.ogg', 'sound/ambience/ambimystery.ogg')

#define SPACE_SOUNDS list('sound/ambience/ambispace.ogg', 'sound/ambience/ambispace2.ogg', 'sound/music/title2.ogg', 'sound/ambience/ambiatmos.ogg')

#define MAINTENANCE_SOUNDS list('sound/ambience/ambimaint1.ogg', 'sound/ambience/ambimaint2.ogg', 'sound/ambience/ambimaint3.ogg', 'sound/ambience/ambimaint4.ogg',\
											'sound/ambience/ambimaint5.ogg', 'sound/voice/lowHiss2.ogg', 'sound/voice/lowHiss3.ogg', 'sound/voice/lowHiss4.ogg', 'sound/ambience/ambitech2.ogg' )

#define AWAY_MISSION_SOUNDS list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiruin.ogg',\
									'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
									'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
									'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambimaint.ogg',\
									'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambiodd.ogg')



#define CREEPY_SOUNDS list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/screech.ogg',\
	'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
	'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
	'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
	'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
