// Defines for all genetics/DNA related stuff

// What each index means:
#define DNA_OFF_LOWERBOUND 1		// changed as lists start at 1 not 0
#define DNA_OFF_UPPERBOUND 2
#define DNA_ON_LOWERBOUND  3
#define DNA_ON_UPPERBOUND  4

// Define block bounds (off-low,off-high,on-low,on-high)
// Used in setupgame.dm
#define DNA_DEFAULT_BOUNDS list(1,2049,2050,4095)
#define DNA_HARDER_BOUNDS  list(1,3049,3050,4095)
#define DNA_HARD_BOUNDS    list(1,3490,3500,4095)

// UI Indices (can change to mutblock style, if desired)
#define DNA_UI_HAIR_R		1
#define DNA_UI_HAIR_G		2
#define DNA_UI_HAIR_B		3
#define DNA_UI_HAIR2_R		4
#define DNA_UI_HAIR2_G		5
#define DNA_UI_HAIR2_B		6
#define DNA_UI_BEARD_R		7
#define DNA_UI_BEARD_G		8
#define DNA_UI_BEARD_B		9
#define DNA_UI_BEARD2_R		10
#define DNA_UI_BEARD2_G		11
#define DNA_UI_BEARD2_B		12
#define DNA_UI_SKIN_TONE	13
#define DNA_UI_SKIN_R		14
#define DNA_UI_SKIN_G		15
#define DNA_UI_SKIN_B		16
#define DNA_UI_HACC_R		17
#define DNA_UI_HACC_G		18
#define DNA_UI_HACC_B		19
#define DNA_UI_HEAD_MARK_R	20
#define DNA_UI_HEAD_MARK_G	21
#define DNA_UI_HEAD_MARK_B	22
#define DNA_UI_BODY_MARK_R	23
#define DNA_UI_BODY_MARK_G	24
#define DNA_UI_BODY_MARK_B	25
#define DNA_UI_TAIL_MARK_R	26
#define DNA_UI_TAIL_MARK_G	27
#define DNA_UI_TAIL_MARK_B	28
#define DNA_UI_EYES_R		29
#define DNA_UI_EYES_G		30
#define DNA_UI_EYES_B		31
#define DNA_UI_GENDER		32
#define DNA_UI_BEARD_STYLE	33
#define DNA_UI_HAIR_STYLE	34
/*#define DNA_UI_BACC_STYLE	23*/
#define DNA_UI_HACC_STYLE	35
#define DNA_UI_HEAD_MARK_STYLE	36
#define DNA_UI_BODY_MARK_STYLE	37
#define DNA_UI_TAIL_MARK_STYLE	38
#define DNA_UI_LENGTH		38 // Update this when you add something, or you WILL break shit.

#define DNA_SE_LENGTH 55 // Was STRUCDNASIZE, size 27. 15 new blocks added = 42, plus room to grow.
