//1000-1999
#pragma FileAlreadyIncluded error
#pragma MissingIncludedFile error
#pragma InvalidWarningCode warning
#pragma MisplacedDirective error
#pragma UndefineMissingDirective error
#pragma DefinedMissingParen error
#pragma ErrorDirective error
#pragma WarningDirective error
#pragma MiscapitalizedDirective error

//2000-2999
#pragma SoftReservedKeyword error
#pragma DuplicateVariable error
#pragma DuplicateProcDefinition error
#pragma PointlessParentCall error
#pragma PointlessBuiltinCall error
#pragma SuspiciousMatrixCall error
#pragma FallbackBuiltinArgument error
#pragma PointlessScopeOperator error
#pragma MalformedRange error
#pragma InvalidRange error
#pragma InvalidSetStatement error
#pragma InvalidOverride error
#pragma InvalidIndexOperation error
#pragma DanglingVarType error
#pragma MissingInterpolatedExpression error
#pragma AmbiguousResourcePath error
#pragma SuspiciousSwitchCase error
#pragma PointlessPositionalArgument error
// NOTE: The next few pragmas are for OpenDream's experimental type checker
// This feature is still in development, elevating these pragmas outside of local testing is discouraged
// An RFC to finalize this feature is coming soon(TM)
// BEGIN TYPEMAKER
#pragma UnsupportedTypeCheck disabled
#pragma InvalidReturnType disabled
#pragma InvalidVarType disabled
#pragma ImplicitNullType disabled
#pragma LostTypeInfo disabled
// END TYPEMAKER
#pragma UnimplementedAccess error

//3000-3999
#pragma EmptyBlock error
#pragma EmptyProc error
#pragma UnsafeClientAccess disabled
#pragma AssignmentInConditional error
#pragma PickWeightedSyntax disabled
#pragma AmbiguousInOrder error
