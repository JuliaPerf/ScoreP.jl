Includes from [here](https://gitlab.com/score-p/scorep/-/tree/v7.x/include/scorep) (for ScoreP v7.x) downloaded as tarball and extracted such that the `include` folder is here (i.e. include are under `./resources/include/scorep` eventually).

Relevant instrumenting API seems to be in `libscorep_adapter_user_event.so`:

```
➜  bauerc@ln-0002 scorep git:(main)  nm -D ~/.local/lib/libscorep_adapter_user_event.so
                 w __cxa_finalize@GLIBC_2.2.5
                 U free@GLIBC_2.2.5
                 w __gmon_start__
                 U __gxx_personality_v0@CXXABI_1.3
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
                 U malloc@GLIBC_2.2.5
                 U memset@GLIBC_2.2.5
                 U SCOREP_AddLocationProperty
                 U SCOREP_Definitions_NewCartesianCoords
                 U SCOREP_Definitions_NewCartesianTopology
                 U SCOREP_Definitions_NewInterimCommunicator
                 U SCOREP_Definitions_NewMetric
                 U SCOREP_Definitions_NewParameter
                 U SCOREP_Definitions_NewRegion
                 U SCOREP_Definitions_NewSamplingSet
                 U SCOREP_Definitions_NewSourceFile
                 U SCOREP_DisableRecording
                 U SCOREP_EnableRecording
                 U SCOREP_EnterRegion
                 U SCOREP_EnterRewindRegion
                 U SCOREP_ExitRegion
                 U SCOREP_ExitRewindRegion
0000000000009360 T scorep_f_begin
000000000000a8f0 T scorep_f_begin_
000000000000be80 T scorep_f_begin__
0000000000007dd0 T SCOREP_F_BEGIN
0000000000009b50 T scorep_f_carttopologyadddim
000000000000b0e0 T scorep_f_carttopologyadddim_
000000000000c670 T scorep_f_carttopologyadddim__
00000000000085c0 T SCOREP_F_CARTTOPOLOGYADDDIM
0000000000009910 T scorep_f_carttopologycreate
000000000000aea0 T scorep_f_carttopologycreate_
000000000000c430 T scorep_f_carttopologycreate__
0000000000008380 T SCOREP_F_CARTTOPOLOGYCREATE
0000000000009d10 T scorep_f_carttopologyinit
000000000000b2a0 T scorep_f_carttopologyinit_
000000000000c830 T scorep_f_carttopologyinit__
0000000000008780 T SCOREP_F_CARTTOPOLOGYINIT
0000000000009e80 T scorep_f_carttopologysetcoords
000000000000b410 T scorep_f_carttopologysetcoords_
000000000000c9a0 T scorep_f_carttopologysetcoords__
00000000000088f0 T SCOREP_F_CARTTOPOLOGYSETCOORDS
0000000000008ac0 T scorep_f_disablerecording
000000000000a050 T scorep_f_disablerecording_
000000000000b5e0 T scorep_f_disablerecording__
0000000000007530 T SCOREP_F_DISABLERECORDING
0000000000008a60 T scorep_f_enablerecording
0000000000009ff0 T scorep_f_enablerecording_
000000000000b580 T scorep_f_enablerecording__
00000000000074d0 T SCOREP_F_ENABLERECORDING
                 U SCOREP_Filtering_Match
00000000000092b0 T scorep_f_init
000000000000a840 T scorep_f_init_
000000000000bdd0 T scorep_f_init__
0000000000007d20 T SCOREP_F_INIT
0000000000008b90 T scorep_f_initmetric
000000000000a120 T scorep_f_initmetric_
000000000000b6b0 T scorep_f_initmetric__
0000000000007600 T SCOREP_F_INITMETRIC
0000000000008d50 T scorep_f_metricdouble
000000000000a2e0 T scorep_f_metricdouble_
000000000000b870 T scorep_f_metricdouble__
00000000000077c0 T SCOREP_F_METRICDOUBLE
0000000000008cb0 T scorep_f_metricint64
000000000000a240 T scorep_f_metricint64_
000000000000b7d0 T scorep_f_metricint64__
0000000000007720 T SCOREP_F_METRICINT64
0000000000008d00 T scorep_f_metricuint64
000000000000a290 T scorep_f_metricuint64_
000000000000b820 T scorep_f_metricuint64__
0000000000007770 T SCOREP_F_METRICUINT64
00000000000097e0 T scorep_f_oabegin
000000000000ad70 T scorep_f_oabegin_
000000000000c300 T scorep_f_oabegin__
0000000000008250 T SCOREP_F_OABEGIN
00000000000098a0 T scorep_f_oaend
000000000000ae30 T scorep_f_oaend_
000000000000c3c0 T scorep_f_oaend__
0000000000008310 T SCOREP_F_OAEND
0000000000008da0 T scorep_f_parameterint64
000000000000a330 T scorep_f_parameterint64_
000000000000b8c0 T scorep_f_parameterint64__
0000000000007810 T SCOREP_F_PARAMETERINT64
0000000000008f20 T scorep_f_parameterstring
000000000000a4b0 T scorep_f_parameterstring_
000000000000ba40 T scorep_f_parameterstring__
0000000000007990 T SCOREP_F_PARAMETERSTRING
0000000000008e60 T scorep_f_parameteruint64
000000000000a3f0 T scorep_f_parameteruint64_
000000000000b980 T scorep_f_parameteruint64__
00000000000078d0 T SCOREP_F_PARAMETERUINT64
0000000000008b20 T scorep_f_recordingenabled
000000000000a0b0 T scorep_f_recordingenabled_
000000000000b640 T scorep_f_recordingenabled__
0000000000007590 T SCOREP_F_RECORDINGENABLED
0000000000009420 T scorep_f_regionbynamebegin
000000000000a9b0 T scorep_f_regionbynamebegin_
000000000000bf40 T scorep_f_regionbynamebegin__
0000000000007e90 T SCOREP_F_REGIONBYNAMEBEGIN
0000000000009650 T scorep_f_regionbynameend
000000000000abe0 T scorep_f_regionbynameend_
000000000000c170 T scorep_f_regionbynameend__
00000000000080c0 T SCOREP_F_REGIONBYNAMEEND
00000000000095e0 T scorep_f_regionend
000000000000ab70 T scorep_f_regionend_
000000000000c100 T scorep_f_regionend__
0000000000008050 T SCOREP_F_REGIONEND
0000000000009760 T scorep_f_regionenter
000000000000acf0 T scorep_f_regionenter_
000000000000c280 T scorep_f_regionenter__
00000000000081d0 T SCOREP_F_REGIONENTER
0000000000009520 T scorep_f_rewindbegin
000000000000aab0 T scorep_f_rewindbegin_
000000000000c040 T scorep_f_rewindbegin__
0000000000007f90 T SCOREP_F_REWINDBEGIN
00000000000096e0 T scorep_f_rewindregionend
000000000000ac70 T scorep_f_rewindregionend_
000000000000c200 T scorep_f_rewindregionend__
0000000000008150 T SCOREP_F_REWINDREGIONEND
                 U scorep_get_in_measurement
                 U SCOREP_Hashtab_Find
                 U SCOREP_Hashtab_InsertPtr
                 U SCOREP_InitMeasurement
                 U scorep_in_measurement
                 U SCOREP_Location_GetCurrentCPULocation
                 U SCOREP_Location_GetId
                 U scorep_measurement_phase
                 U SCOREP_Memory_AllocForMisc
                 U SCOREP_Memory_GetAddressFromMovableMemory
                 U SCOREP_Memory_GetLocalDefinitionPageManager
                 U SCOREP_OA_PhaseBegin
                 U SCOREP_OA_PhaseEnd
                 U SCOREP_RecordingEnabled
                 U SCOREP_RegionHandle_GetName
                 U SCOREP_RegionHandle_SetGroup
                 U SCOREP_RegisterExitCallback
                 U scorep_selective_check_enter
                 U scorep_selective_check_exit
                 U SCOREP_SourceFileHandle_GetName
                 U SCOREP_Status_GetRank
00000000000074a0 T SCOREP_Tau_AddLocationProperty
0000000000007050 T SCOREP_Tau_DefineRegion
0000000000007390 T SCOREP_Tau_EnterRegion
00000000000073c0 T SCOREP_Tau_ExitRegion
0000000000006ff0 T SCOREP_Tau_InitMeasurement
0000000000007410 T SCOREP_Tau_InitMetric
00000000000073f0 T SCOREP_Tau_Metric
0000000000007470 T SCOREP_Tau_Parameter_INT64
0000000000007020 T SCOREP_Tau_RegisterExitCallback
0000000000007440 T SCOREP_Tau_TriggerMetricDouble
                 U SCOREP_TriggerCounterDouble
                 U SCOREP_TriggerCounterInt64
                 U SCOREP_TriggerCounterUint64
                 U SCOREP_TriggerParameterInt64
                 U SCOREP_TriggerParameterString
                 U SCOREP_TriggerParameterUint64
0000000000006b20 T SCOREP_User_CartTopologyAddDim
0000000000006910 T SCOREP_User_CartTopologyCreate
0000000000006c80 T SCOREP_User_CartTopologyInit
0000000000006de0 T SCOREP_User_CartTopologySetCoords
                 U scorep_user_create_region
0000000000005570 T SCOREP_User_DisableRecording
0000000000005510 T SCOREP_User_EnableRecording
                 U scorep_user_enable_topologies
                 U scorep_user_file_table_mutex
0000000000005630 T SCOREP_User_InitMetric
                 U scorep_user_metric_mutex
0000000000006030 T SCOREP_User_OaPhaseBegin
0000000000006190 T SCOREP_User_OaPhaseEnd
00000000000058e0 T SCOREP_User_ParameterInt64
0000000000005a00 T SCOREP_User_ParameterString
0000000000005970 T SCOREP_User_ParameterUint64
00000000000055d0 T SCOREP_User_RecordingEnabled
0000000000005ee0 T SCOREP_User_RegionBegin
0000000000006400 T scorep_user_region_by_name_begin
0000000000006670 T SCOREP_User_RegionByNameBegin
00000000000066f0 T scorep_user_region_by_name_end
00000000000067a0 T SCOREP_User_RegionByNameEnd
                 U scorep_user_region_by_name_hash_table
                 U scorep_user_region_by_name_mutex
0000000000006120 T SCOREP_User_RegionEnd
0000000000005eb0 T scorep_user_region_enter
0000000000005fa0 T SCOREP_User_RegionEnter
00000000000060f0 T scorep_user_region_exit
0000000000005e00 T SCOREP_User_RegionInit
0000000000005b30 T scorep_user_region_init_c_cxx
                 U scorep_user_region_mutex
0000000000005ab0 T SCOREP_User_RegionSetGroup
                 U scorep_user_region_table
0000000000006230 T SCOREP_User_RewindRegionBegin
0000000000006390 T SCOREP_User_RewindRegionEnd
0000000000006200 T scorep_user_rewind_region_enter
00000000000062f0 T SCOREP_User_RewindRegionEnter
0000000000006360 T scorep_user_rewind_region_exit
                 U scorep_user_topo_mutex
0000000000005a90 T scorep_user_to_scorep_region_type
00000000000058a0 T SCOREP_User_TriggerMetricDouble
0000000000005820 T SCOREP_User_TriggerMetricInt64
0000000000005860 T SCOREP_User_TriggerMetricUint64
                 U SCOREP_UTILS_CStr_dup
                 U SCOREP_UTILS_Error_Abort
                 U SCOREP_UTILS_Error_Handler
                 U SCOREP_UTILS_IO_SimplifyPath
                 U strlen@GLIBC_2.2.5
                 U strncmp@GLIBC_2.2.5
                 U strncpy@GLIBC_2.2.5
0000000000006800 T _ZN23SCOREP_User_RegionClassC1EPP18SCOREP_User_RegionPKcjPS4_PjS4_j
0000000000006800 T _ZN23SCOREP_User_RegionClassC2EPP18SCOREP_User_RegionPKcjPS4_PjS4_j
00000000000068b0 T _ZN23SCOREP_User_RegionClassD1Ev
00000000000068b0 T _ZN23SCOREP_User_RegionClassD2Ev
```