# DMAPI V5

This DMAPI implements bridge requests using HTTP GET requests to TGS. It has no security restrictions.

- [v5_interop_version.dm](./v5_interop_version.dm) contains the version of the API used between the DMAPI and TGS.
- [_v5_defines.dm](./_v5_defines.dm) contains constant definitions.
- [v5_api.dm](./v5_api.dm) contains the bulk of the API code.
- [v5_bridge.dm](./v5_bridge.dm) contains functions related to making bridge requests.
- [v5_chunking.dm](./v5_chunking.dm) contains common function for splitting large raw data sets into chunks BYOND can natively process.
- [v5_commands.dm](./v5_commands.dm) contains functions relating to `/datum/tgs_chat_command`s.
- [v5_serializers.dm](./v5_serializers.dm) contains function to help convert interop `/datum`s into a JSON encodable `list()` format.
- [v5_topic.dm](./v5_topic.dm) contains functions related to processing topic requests.
- [v5_undefs.dm](./v5_undefs.dm) Undoes the work of `_defines.dm`.
