GhcUnregisterised = YES
GhcEnableTablesNextToCode = NO
GhcLibHcOpts = -optc-g -optc-O0 -pgmc=$(CC_STAGE2) -pgml=$(LD_STAGE2) -pgma=$(CC_STAGE2) $(CFlagOpsStage2) $(LDFlagOpsStage2) $(AFlagOpsStage2) $(XFlagsOpsStage2) -v -fvia-C -keep-hc-files
GhcRtsHcOpts = -optc-g -optc-O0 -pgmc=$(CC_STAGE2) -pgml=$(LD_STAGE2) -pgma=$(CC_STAGE2) $(CFlagOpsStage2) $(LDFlagOpsStage2) $(AFlagOpsStage2) $(XFlagsOpsStage2) -v -fvia-C -keep-hc-files
GhcStage2HcOpts = -optc-g -optc-O0 -pgmc=$(CC_STAGE2) -pgml=$(LD_STAGE2) -pgma=$(CC_STAGE2) $(CFlagOpsStage2) $(LDFlagOpsStage2) $(AFlagOpsStage2) $(XFlagsOpsStage2) -v -fvia-C -keep-hc-files
GhcLibWays = v dyn
GhcRTSWays =
INTEGER_LIBRARY=integer-simple
SplitObjs = NO
GhcWithNativeCodeGen = NO
GhcWithInterpreter = YES
HaveDtrace = NO
HADDOCK_DOCS = NO
UseAssembler = NO

