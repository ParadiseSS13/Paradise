/**
 * SS220 EDIT - START
 * ORIGINAL: #include "map_files\generic\centcomm.dmm"
 * Uncomment define bellow if you need faster init for testing.
 */
//#define ENABLE_TEST_CC

#ifdef GAME_TEST
#define ENABLE_TEST_CC
#endif

#ifndef ENABLE_TEST_CC
#include "map_files220\generic\centcomm.dmm"
#include "map_files220\generic\Admin_Zone.dmm"
#else
#include "map_files220\generic\centcomm_test.dmm"
#endif
// SS220 EDIT - END
#define CC_TRANSITION_CONFIG DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC))
#ifdef CIMAP
#include "ci_map_testing.dm"
#endif
