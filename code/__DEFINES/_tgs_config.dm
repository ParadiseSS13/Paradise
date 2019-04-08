#define TGS_EXTERNAL_CONFIGURATION
#define TGS_V3_API
#define TGS_DEFINE_AND_SET_GLOBAL(Name, Value) GLOBAL_VAR_INIT(##Name, ##Value)
#define TGS_READ_GLOBAL(Name) GLOB.##Name
#define TGS_WRITE_GLOBAL(Name, Value) GLOB.##Name = ##Value
#define TGS_PROTECT_DATUM(Path)
#define TGS_WORLD_ANNOUNCE(message) world << "<span class='boldannounce'>[##message]</span>"
#define TGS_NOTIFY_ADMINS(event) message_admins("TGS: [##event]")
#define TGS_INFO_LOG(message) world.log << "TGS Info: [##message]"
#define TGS_ERROR_LOG(message) world.log << "TGS ERROR: [##message]"
#define TGS_CLIENT_COUNT GLOB.clients.len