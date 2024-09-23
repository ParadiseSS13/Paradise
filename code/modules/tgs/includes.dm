#include "core\_definitions.dm"
#include "core\tgs_core.dm"
#include "core\tgs_datum.dm"
#include "core\tgs_version.dm"

#ifdef TGS_V3_API
#include "v3210\v3_api.dm"
#include "v3210\v3_commands.dm"
#endif

#include "v4\v4_api.dm"
#include "v4\v4_commands.dm"

#include "v5\_v5_defines.dm"
#include "v5\v5_api.dm"
#include "v5\v5_bridge.dm"
#include "v5\v5_chunking.dm"
#include "v5\v5_commands.dm"
#include "v5\v5_serializers.dm"
#include "v5\v5_topic.dm"
#include "v5\v5_undefs.dm"
