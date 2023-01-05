
# macro SCOREP_USER_REGION_DEFINE(handle)
#     esc(quote
#             $handle = ScoreP.LibScoreP.SCOREP_USER_INVALID_REGION
#         end)
# end

# #define SCOREP_USER_REGION_BEGIN( handle, name, type ) SCOREP_User_RegionBegin( \
# #       &handle, &SCOREP_User_LastFileName, &SCOREP_User_LastFileHandle, name, \
# #       type, __FILE__, __LINE__ );

# macro SCOREP_USER_REGION_BEGIN(handle, name, type)
#     lastfilename = ["lastfilename"]
#     # lastfile = ScoreP.LibScoreP.SCOREP_User_LastFileHandle
#     lastfile = ScoreP.LibScoreP.SCOREP_INVALID_SOURCE_FILE
#     esc(quote
#             ScoreP.LibScoreP.SCOREP_User_RegionBegin($handle,
#                                                      $lastfilename,
#                                                      $lastfile,
#                                                      $name,
#                                                      $type,
#                                                      @__FILE__,
#                                                      @__LINE__)
#         end)
# end

function test_regionbegin()
    handle = ScoreP.LibScoreP.SCOREP_USER_INVALID_REGION
    lastfilename = ["lastfilename"]
    # lastfile = ScoreP.LibScoreP.SCOREP_INVALID_SOURCE_FILE
    # lastfile = Ptr{UInt32}()
    lastfile = Ref(UInt32(0))
    name = "carsten"
    type = ScoreP.LibScoreP.SCOREP_USER_REGION_TYPE_COMMON

    ScoreP.LibScoreP.SCOREP_User_RegionBegin(handle,
                                             lastfilename,
                                             lastfile,
                                             name,
                                             type,
                                             @__FILE__,
                                             @__LINE__)
end
