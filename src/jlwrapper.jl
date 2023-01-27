SCOREP_User_LastFileHandle::LibScoreP.SCOREP_SourceFileHandle = LibScoreP.SCOREP_INVALID_SOURCE_FILE

function region_begin(region_name::String;
                      handle = LibScoreP.SCOREP_USER_INVALID_REGION,
                      file = @__FILE__,
                      line = @__LINE__,
                      type = LibScoreP.SCOREP_USER_REGION_TYPE_COMMON)
    handle_ref = Ref(handle)
    LibScoreP.SCOREP_User_RegionBegin(handle_ref,
                                      C_NULL,
                                      Ref(SCOREP_User_LastFileHandle),
                                      region_name,
                                      type,
                                      file,
                                      line)
    return handle_ref[]
end

function region_end(handle::LibScoreP.SCOREP_User_RegionHandle)
    LibScoreP.SCOREP_User_RegionEnd(handle)
    return nothing
end

enable_recording() = LibScoreP.SCOREP_User_EnableRecording()
disable_recording() = LibScoreP.SCOREP_User_DisableRecording()
isrecording() = LibScoreP.SCOREP_User_RecordingEnabled()

function parameter_int(name, value::Int)
    param_ref = Ref(LibScoreP.SCOREP_USER_INVALID_PARAMETER)
    LibScoreP.SCOREP_User_ParameterInt64(param_ref, name, value)
    return nothing
end

function parameter_uint(name, value::UInt)
    param_ref = Ref(LibScoreP.SCOREP_USER_INVALID_PARAMETER)
    LibScoreP.SCOREP_User_ParameterUint64(param_ref, name, value)
    return nothing
end

function parameter_string(name, value::AbstractString)
    param_ref = Ref(LibScoreP.SCOREP_USER_INVALID_PARAMETER)
    LibScoreP.SCOREP_User_ParameterString(param_ref, name, value)
    return nothing
end

# macros / wrapper functions

function scorep_user_region(f, region_name; kwargs...)
    handle = ScoreP.region_begin(region_name; kwargs...)
    f()
    ScoreP.region_end(handle)
end

macro scorep_user_region(region_name, expr)
    file = string(__source__.file)
    line = __source__.line
    handlesym = gensym()
    q = quote
        $handlesym = ScoreP.region_begin($(region_name); line = $line, file = $file)
        $expr
        ScoreP.region_end($handlesym)
    end
    return esc(q)
end

# ---- Global handle storage ----
# regions = Dict{String, LibScoreP.SCOREP_User_RegionHandle}()

# function region_begin_stored(region_name::String;
#                              module_name = string(@__MODULE__),
#                              file = @__FILE__,
#                              line = @__LINE__,
#                              type = LibScoreP.SCOREP_USER_REGION_TYPE_COMMON)
#     if !(region_name in keys(regions))
#         handle_ref = Ref(LibScoreP.SCOREP_USER_INVALID_REGION)
#         LibScoreP.SCOREP_User_RegionInit(handle_ref,
#                                          C_NULL,
#                                          Ref(SCOREP_User_LastFileHandle),
#                                          region_name,
#                                          type,
#                                          file,
#                                          line)
#         LibScoreP.SCOREP_User_RegionSetGroup(handle_ref[], module_name)
#         handle = handle_ref[]
#         regions[region_name] = handle
#     else
#         handle = regions[region_name]
#     end
#     LibScoreP.SCOREP_User_RegionEnter(handle)
#     return nothing
# end

# function region_end_stored(region_name::String)
#     handle = regions[region_name]
#     LibScoreP.SCOREP_User_RegionEnd(handle)
#     return nothing
# end

# macro scorep_user_region_stored(region_name, expr)
#     mod = string(__module__)
#     file = string(__source__.file)
#     line = __source__.line
#     q = quote
#         ScoreP.region_begin_stored($(region_name);
#                                    module_name = $mod,
#                                    line = $line,
#                                    file = $file)
#         $expr
#         ScoreP.region_end_stored($(region_name))
#     end
#     return esc(q)
# end
