#include "map_files220\generic\centcomm.dmm" // SS220 EDIT - ORIGINAL: #include "map_files\generic\centcomm.dmm"
#include "map_files220\generic\Admin_Zone.dmm" // SS220 ADDITION
#define CC_TRANSITION_CONFIG DECLARE_LEVEL(CENTCOMM, SELFLOOPING, list(ADMIN_LEVEL, BLOCK_TELEPORT, IMPEDES_MAGIC))
#ifdef CIMAP
#include "ci_map_testing.dm"
#endif
