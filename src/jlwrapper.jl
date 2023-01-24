SCOREP_User_LastFileHandle::LibScoreP.SCOREP_SourceFileHandle = LibScoreP.SCOREP_INVALID_SOURCE_FILE

regions = Dict{String, LibScoreP.SCOREP_User_RegionHandle}()

function region_begin_manual(region_name::String, module_name::String = string(@__MODULE__))
    if !(region_name in keys(regions))
        handle = LibScoreP.SCOREP_USER_INVALID_REGION
        LibScoreP.SCOREP_User_RegionInit(Ref(handle),
                                         C_NULL,
                                         Ref(SCOREP_User_LastFileHandle),
                                         region_name,
                                         LibScoreP.SCOREP_USER_REGION_TYPE_FUNCTION,
                                         @__FILE__,
                                         @__LINE__)
        LibScoreP.SCOREP_User_RegionSetGroup(handle, module_name)
        regions[region_name] = handle
    else
        handle = regions[region_name]
    end
    # LibScoreP.SCOREP_User_RegionEnter(handle)
    return nothing
end

function region_begin(region_name::String, module_name::String = string(@__MODULE__);
                      handle = LibScoreP.SCOREP_USER_INVALID_REGION)
    handle_ref = Ref(handle)
    LibScoreP.SCOREP_User_RegionBegin(handle_ref,
                                      C_NULL,
                                      Ref(SCOREP_User_LastFileHandle),
                                      region_name,
                                      LibScoreP.SCOREP_USER_REGION_TYPE_FUNCTION,
                                      @__FILE__,
                                      @__LINE__)
    return handle_ref[]
end

function region_end(handle::LibScoreP.SCOREP_User_RegionHandle)
    LibScoreP.SCOREP_User_RegionEnd(handle)
    return nothing
end

# macros

macro SCOREP_USER_REGION_DEFINE(handle)
    esc(quote
            $handle = LibScoreP.SCOREP_USER_INVALID_REGION
        end)
end

# macro SCOREP_USER_REGION_DEFINE(handle)
#     esc(quote
#             $handle = LibScoreP.SCOREP_USER_INVALID_REGION
#         end)
# end
