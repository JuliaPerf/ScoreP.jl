module LibScoreP

using CEnum

mutable struct SCOREP_LibwrapHandle end

@cenum SCOREP_LibwrapMode::UInt32 begin
    SCOREP_LIBWRAP_MODE_SHARED = 0
    SCOREP_LIBWRAP_MODE_STATIC = 1
    SCOREP_LIBWRAP_MODE_WEAK = 2
end

struct SCOREP_LibwrapAttributes
    version::Cint
    name::Ptr{Cchar}
    display_name::Ptr{Cchar}
    mode::SCOREP_LibwrapMode
    init::Ptr{Cvoid}
    number_of_shared_libs::Cint
    shared_libs::Ptr{Ptr{Cchar}}
end

const SCOREP_Allocator_MovableMemory = UInt32

const SCOREP_AnyHandle = SCOREP_Allocator_MovableMemory

const SCOREP_RegionHandle = SCOREP_AnyHandle

function SCOREP_Libwrap_DefineRegion(handle, region, regionFiltered, name, symbol, file,
                                     line)
    ccall((:SCOREP_Libwrap_DefineRegion, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_LibwrapHandle}, Ptr{SCOREP_RegionHandle}, Ptr{Cint}, Ptr{Cchar},
           Ptr{Cchar}, Ptr{Cchar}, Cint), handle, region, regionFiltered, name, symbol,
          file, line)
end

function SCOREP_Libwrap_Create(handle, attributes)
    ccall((:SCOREP_Libwrap_Create, libscorep_adapter_user_event), Cvoid,
          (Ptr{Ptr{SCOREP_LibwrapHandle}}, Ptr{SCOREP_LibwrapAttributes}), handle,
          attributes)
end

function SCOREP_Libwrap_SharedPtrInit(handle, func, funcPtr)
    ccall((:SCOREP_Libwrap_SharedPtrInit, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_LibwrapHandle}, Ptr{Cchar}, Ptr{Ptr{Cvoid}}), handle, func, funcPtr)
end

function SCOREP_Libwrap_EarlySharedPtrInit(func, funcPtr)
    ccall((:SCOREP_Libwrap_EarlySharedPtrInit, libscorep_adapter_user_event), Cvoid,
          (Ptr{Cchar}, Ptr{Ptr{Cvoid}}), func, funcPtr)
end

function SCOREP_Libwrap_EnterMeasurement()
    ccall((:SCOREP_Libwrap_EnterMeasurement, libscorep_adapter_user_event), Cint, ())
end

function SCOREP_Libwrap_ExitMeasurement()
    ccall((:SCOREP_Libwrap_ExitMeasurement, libscorep_adapter_user_event), Cvoid, ())
end

function SCOREP_Libwrap_EnterRegion(region)
    ccall((:SCOREP_Libwrap_EnterRegion, libscorep_adapter_user_event), Cvoid,
          (SCOREP_RegionHandle,), region)
end

function SCOREP_Libwrap_ExitRegion(region)
    ccall((:SCOREP_Libwrap_ExitRegion, libscorep_adapter_user_event), Cvoid,
          (SCOREP_RegionHandle,), region)
end

function SCOREP_Libwrap_EnterWrapper(region)
    ccall((:SCOREP_Libwrap_EnterWrapper, libscorep_adapter_user_event), Cvoid,
          (SCOREP_RegionHandle,), region)
end

function SCOREP_Libwrap_ExitWrapper(region)
    ccall((:SCOREP_Libwrap_ExitWrapper, libscorep_adapter_user_event), Cvoid,
          (SCOREP_RegionHandle,), region)
end

function SCOREP_Libwrap_EnterWrappedRegion()
    ccall((:SCOREP_Libwrap_EnterWrappedRegion, libscorep_adapter_user_event), Cint, ())
end

function SCOREP_Libwrap_ExitWrappedRegion(previous)
    ccall((:SCOREP_Libwrap_ExitWrappedRegion, libscorep_adapter_user_event), Cvoid, (Cint,),
          previous)
end

@cenum SCOREP_MetricPer::UInt32 begin
    SCOREP_METRIC_PER_THREAD = 0
    SCOREP_METRIC_PER_PROCESS = 1
    SCOREP_METRIC_PER_HOST = 2
    SCOREP_METRIC_ONCE = 3
    SCOREP_METRIC_PER_MAX = 4
end

@cenum SCOREP_MetricSynchronicity::UInt32 begin
    SCOREP_METRIC_STRICTLY_SYNC = 0
    SCOREP_METRIC_SYNC = 1
    SCOREP_METRIC_ASYNC_EVENT = 2
    SCOREP_METRIC_ASYNC = 3
    SCOREP_METRIC_SYNC_TYPE_MAX = 4
end

struct SCOREP_Metric_Plugin_Info
    plugin_version::UInt32
    run_per::SCOREP_MetricPer
    sync::SCOREP_MetricSynchronicity
    delta_t::UInt64
    initialize::Ptr{Cvoid}
    finalize::Ptr{Cvoid}
    get_event_info::Ptr{Cvoid}
    add_counter::Ptr{Cvoid}
    get_current_value::Ptr{Cvoid}
    get_optional_value::Ptr{Cvoid}
    set_clock_function::Ptr{Cvoid}
    get_all_values::Ptr{Cvoid}
    synchronize::Ptr{Cvoid}
    reserved::NTuple{92, UInt64}
end

@cenum SCOREP_MetricMode::UInt32 begin
    SCOREP_METRIC_MODE_ACCUMULATED_START = 0
    SCOREP_METRIC_MODE_ACCUMULATED_POINT = 1
    SCOREP_METRIC_MODE_ACCUMULATED_LAST = 2
    SCOREP_METRIC_MODE_ACCUMULATED_NEXT = 3
    SCOREP_METRIC_MODE_ABSOLUTE_POINT = 4
    SCOREP_METRIC_MODE_ABSOLUTE_LAST = 5
    SCOREP_METRIC_MODE_ABSOLUTE_NEXT = 6
    SCOREP_METRIC_MODE_RELATIVE_POINT = 7
    SCOREP_METRIC_MODE_RELATIVE_LAST = 8
    SCOREP_METRIC_MODE_RELATIVE_NEXT = 9
    SCOREP_INVALID_METRIC_MODE = 10
end

@cenum SCOREP_MetricValueType::UInt32 begin
    SCOREP_METRIC_VALUE_INT64 = 0
    SCOREP_METRIC_VALUE_UINT64 = 1
    SCOREP_METRIC_VALUE_DOUBLE = 2
    SCOREP_INVALID_METRIC_VALUE_TYPE = 3
end

@cenum SCOREP_MetricBase::UInt32 begin
    SCOREP_METRIC_BASE_BINARY = 0
    SCOREP_METRIC_BASE_DECIMAL = 1
    SCOREP_INVALID_METRIC_BASE = 2
end

struct SCOREP_Metric_Plugin_MetricProperties
    name::Ptr{Cchar}
    description::Ptr{Cchar}
    mode::SCOREP_MetricMode
    value_type::SCOREP_MetricValueType
    base::SCOREP_MetricBase
    exponent::Int64
    unit::Ptr{Cchar}
end

@cenum SCOREP_MetricSourceType::UInt32 begin
    SCOREP_METRIC_SOURCE_TYPE_PAPI = 0
    SCOREP_METRIC_SOURCE_TYPE_RUSAGE = 1
    SCOREP_METRIC_SOURCE_TYPE_USER = 2
    SCOREP_METRIC_SOURCE_TYPE_OTHER = 3
    SCOREP_METRIC_SOURCE_TYPE_TASK = 4
    SCOREP_METRIC_SOURCE_TYPE_PLUGIN = 5
    SCOREP_METRIC_SOURCE_TYPE_PERF = 6
    SCOREP_INVALID_METRIC_SOURCE_TYPE = 7
end

@cenum SCOREP_MetricProfilingType::UInt32 begin
    SCOREP_METRIC_PROFILING_TYPE_EXCLUSIVE = 0
    SCOREP_METRIC_PROFILING_TYPE_INCLUSIVE = 1
    SCOREP_METRIC_PROFILING_TYPE_SIMPLE = 2
    SCOREP_METRIC_PROFILING_TYPE_MAX = 3
    SCOREP_METRIC_PROFILING_TYPE_MIN = 4
    SCOREP_INVALID_METRIC_PROFILING_TYPE = 5
end

struct SCOREP_Metric_Properties
    name::Ptr{Cchar}
    description::Ptr{Cchar}
    source_type::SCOREP_MetricSourceType
    mode::SCOREP_MetricMode
    value_type::SCOREP_MetricValueType
    base::SCOREP_MetricBase
    exponent::Int64
    unit::Ptr{Cchar}
    profiling_type::SCOREP_MetricProfilingType
end

struct SCOREP_MetricTimeValuePair
    timestamp::UInt64
    value::UInt64
end

@cenum SCOREP_MetricSynchronizationMode::UInt32 begin
    SCOREP_METRIC_SYNCHRONIZATION_MODE_BEGIN = 0
    SCOREP_METRIC_SYNCHRONIZATION_MODE_BEGIN_MPP = 1
    SCOREP_METRIC_SYNCHRONIZATION_MODE_END = 2
    SCOREP_METRIC_SYNCHRONIZATION_MODE_MAX = 3
end

@cenum SCOREP_HandleType::UInt32 begin
    SCOREP_HANDLE_TYPE_ANY = 0
    SCOREP_HANDLE_TYPE_CALLING_CONTEXT = 1
    SCOREP_HANDLE_TYPE_GROUP = 2
    SCOREP_HANDLE_TYPE_INTERIM_COMMUNICATOR = 3
    SCOREP_HANDLE_TYPE_INTERRUPT_GENERATOR = 4
    SCOREP_HANDLE_TYPE_LOCATION = 5
    SCOREP_HANDLE_TYPE_LOCATION_GROUP = 6
    SCOREP_HANDLE_TYPE_LOCATION_PROPERTY = 7
    SCOREP_HANDLE_TYPE_METRIC = 8
    SCOREP_HANDLE_TYPE_PARADIGM = 9
    SCOREP_HANDLE_TYPE_PARAMETER = 10
    SCOREP_HANDLE_TYPE_REGION = 11
    SCOREP_HANDLE_TYPE_RMA_WINDOW = 12
    SCOREP_HANDLE_TYPE_SAMPLING_SET = 13
    SCOREP_HANDLE_TYPE_SAMPLING_SET_RECORDER = 14
    SCOREP_HANDLE_TYPE_SOURCE_CODE_LOCATION = 15
    SCOREP_HANDLE_TYPE_SOURCE_FILE = 16
    SCOREP_HANDLE_TYPE_STRING = 17
    SCOREP_HANDLE_TYPE_SYSTEM_TREE_NODE = 18
    SCOREP_HANDLE_TYPE_SYSTEM_TREE_NODE_PROPERTY = 19
    SCOREP_HANDLE_TYPE_CARTESIAN_TOPOLOGY = 20
    SCOREP_HANDLE_TYPE_CARTESIAN_COORDS = 21
    SCOREP_HANDLE_TYPE_IO_FILE = 22
    SCOREP_HANDLE_TYPE_IO_FILE_PROPERTY = 23
    SCOREP_HANDLE_TYPE_IO_HANDLE = 24
    SCOREP_HANDLE_TYPE_IO_PARADIGM = 25
    SCOREP_HANDLE_TYPE_NUM_HANDLES = 26
end

const SCOREP_CallingContextHandle = SCOREP_AnyHandle

const SCOREP_CartesianTopologyHandle = SCOREP_AnyHandle

const SCOREP_CartesianCoordsHandle = SCOREP_AnyHandle

const SCOREP_GroupHandle = SCOREP_AnyHandle

const SCOREP_InterimCommunicatorHandle = SCOREP_AnyHandle

const SCOREP_InterruptGeneratorHandle = SCOREP_AnyHandle

const SCOREP_IoFileHandle = SCOREP_AnyHandle

const SCOREP_IoHandleHandle = SCOREP_AnyHandle

const SCOREP_LocationHandle = SCOREP_AnyHandle

const SCOREP_LocationGroupHandle = SCOREP_AnyHandle

const SCOREP_LocationPropertyHandle = SCOREP_AnyHandle

const SCOREP_ParameterHandle = SCOREP_AnyHandle

const SCOREP_RmaWindowHandle = SCOREP_AnyHandle

const SCOREP_SamplingSetRecorderHandle = SCOREP_AnyHandle

const SCOREP_SourceCodeLocationHandle = SCOREP_AnyHandle

const SCOREP_StringHandle = SCOREP_AnyHandle

const SCOREP_SystemTreeNodeHandle = SCOREP_AnyHandle

const SCOREP_SystemTreeNodePropertyHandle = SCOREP_AnyHandle

const SCOREP_ExitStatus = Int64

const SCOREP_LineNo = UInt32

const SCOREP_SourceFileHandle = SCOREP_AnyHandle

const SCOREP_MetricHandle = SCOREP_AnyHandle

const SCOREP_SamplingSetHandle = SCOREP_AnyHandle

const SCOREP_ParadigmHandle = SCOREP_AnyHandle

mutable struct SCOREP_Task end

const SCOREP_TaskHandle = Ptr{SCOREP_Task}

@cenum SCOREP_CollectiveType::UInt32 begin
    SCOREP_COLLECTIVE_BARRIER = 0
    SCOREP_COLLECTIVE_BROADCAST = 1
    SCOREP_COLLECTIVE_GATHER = 2
    SCOREP_COLLECTIVE_GATHERV = 3
    SCOREP_COLLECTIVE_SCATTER = 4
    SCOREP_COLLECTIVE_SCATTERV = 5
    SCOREP_COLLECTIVE_ALLGATHER = 6
    SCOREP_COLLECTIVE_ALLGATHERV = 7
    SCOREP_COLLECTIVE_ALLTOALL = 8
    SCOREP_COLLECTIVE_ALLTOALLV = 9
    SCOREP_COLLECTIVE_ALLTOALLW = 10
    SCOREP_COLLECTIVE_ALLREDUCE = 11
    SCOREP_COLLECTIVE_REDUCE = 12
    SCOREP_COLLECTIVE_REDUCE_SCATTER = 13
    SCOREP_COLLECTIVE_REDUCE_SCATTER_BLOCK = 14
    SCOREP_COLLECTIVE_SCAN = 15
    SCOREP_COLLECTIVE_EXSCAN = 16
    SCOREP_COLLECTIVE_CREATE_HANDLE = 17
    SCOREP_COLLECTIVE_DESTROY_HANDLE = 18
    SCOREP_COLLECTIVE_ALLOCATE = 19
    SCOREP_COLLECTIVE_DEALLOCATE = 20
    SCOREP_COLLECTIVE_CREATE_HANDLE_AND_ALLOCATE = 21
    SCOREP_COLLECTIVE_DESTROY_HANDLE_AND_DEALLOCATE = 22
end

@cenum SCOREP_LocationType::UInt32 begin
    SCOREP_LOCATION_TYPE_CPU_THREAD = 0
    SCOREP_LOCATION_TYPE_GPU = 1
    SCOREP_LOCATION_TYPE_METRIC = 2
    SCOREP_NUMBER_OF_LOCATION_TYPES = 3
    SCOREP_INVALID_LOCATION_TYPE = 4
end

@cenum SCOREP_LockType::UInt32 begin
    SCOREP_LOCK_EXCLUSIVE = 0
    SCOREP_LOCK_SHARED = 1
    SCOREP_INVALID_LOCK_TYPE = 2
end

const SCOREP_MpiRank = Cint

const SCOREP_MpiRequestId = UInt64

@cenum SCOREP_ParadigmClass::UInt32 begin
    SCOREP_PARADIGM_CLASS_MPP = 0
    SCOREP_PARADIGM_CLASS_THREAD_FORK_JOIN = 1
    SCOREP_PARADIGM_CLASS_THREAD_CREATE_WAIT = 2
    SCOREP_PARADIGM_CLASS_ACCELERATOR = 3
    SCOREP_INVALID_PARADIGM_CLASS = 4
end

@cenum SCOREP_ParadigmType::UInt32 begin
    SCOREP_PARADIGM_MEASUREMENT = 0
    SCOREP_PARADIGM_USER = 1
    SCOREP_PARADIGM_COMPILER = 2
    SCOREP_PARADIGM_SAMPLING = 3
    SCOREP_PARADIGM_MEMORY = 4
    SCOREP_PARADIGM_LIBWRAP = 5
    SCOREP_PARADIGM_MPI = 6
    SCOREP_PARADIGM_SHMEM = 7
    SCOREP_PARADIGM_OPENMP = 8
    SCOREP_PARADIGM_PTHREAD = 9
    SCOREP_PARADIGM_ORPHAN_THREAD = 10
    SCOREP_PARADIGM_CUDA = 11
    SCOREP_PARADIGM_OPENCL = 12
    SCOREP_PARADIGM_OPENACC = 13
    SCOREP_PARADIGM_IO = 14
    SCOREP_PARADIGM_KOKKOS = 15
    SCOREP_INVALID_PARADIGM_TYPE = 16
end

@cenum SCOREP_ParameterType::UInt32 begin
    SCOREP_PARAMETER_INT64 = 0
    SCOREP_PARAMETER_UINT64 = 1
    SCOREP_PARAMETER_STRING = 2
    SCOREP_INVALID_PARAMETER_TYPE = 3
end

@cenum SCOREP_RegionType::UInt32 begin
    SCOREP_REGION_UNKNOWN = 0
    SCOREP_REGION_FUNCTION = 1
    SCOREP_REGION_LOOP = 2
    SCOREP_REGION_USER = 3
    SCOREP_REGION_CODE = 4
    SCOREP_REGION_PHASE = 5
    SCOREP_REGION_DYNAMIC = 6
    SCOREP_REGION_DYNAMIC_PHASE = 7
    SCOREP_REGION_DYNAMIC_LOOP = 8
    SCOREP_REGION_DYNAMIC_FUNCTION = 9
    SCOREP_REGION_DYNAMIC_LOOP_PHASE = 10
    SCOREP_REGION_COLL_ONE2ALL = 11
    SCOREP_REGION_COLL_ALL2ONE = 12
    SCOREP_REGION_COLL_ALL2ALL = 13
    SCOREP_REGION_COLL_OTHER = 14
    SCOREP_REGION_POINT2POINT = 15
    SCOREP_REGION_PARALLEL = 16
    SCOREP_REGION_SECTIONS = 17
    SCOREP_REGION_SECTION = 18
    SCOREP_REGION_WORKSHARE = 19
    SCOREP_REGION_SINGLE = 20
    SCOREP_REGION_MASTER = 21
    SCOREP_REGION_CRITICAL = 22
    SCOREP_REGION_ATOMIC = 23
    SCOREP_REGION_BARRIER = 24
    SCOREP_REGION_IMPLICIT_BARRIER = 25
    SCOREP_REGION_FLUSH = 26
    SCOREP_REGION_CRITICAL_SBLOCK = 27
    SCOREP_REGION_SINGLE_SBLOCK = 28
    SCOREP_REGION_WRAPPER = 29
    SCOREP_REGION_TASK = 30
    SCOREP_REGION_TASK_UNTIED = 31
    SCOREP_REGION_TASK_WAIT = 32
    SCOREP_REGION_TASK_CREATE = 33
    SCOREP_REGION_ORDERED = 34
    SCOREP_REGION_ORDERED_SBLOCK = 35
    SCOREP_REGION_ARTIFICIAL = 36
    SCOREP_REGION_RMA = 37
    SCOREP_REGION_THREAD_CREATE = 38
    SCOREP_REGION_THREAD_WAIT = 39
    SCOREP_REGION_ALLOCATE = 40
    SCOREP_REGION_DEALLOCATE = 41
    SCOREP_REGION_REALLOCATE = 42
    SCOREP_REGION_FILE_IO = 43
    SCOREP_REGION_FILE_IO_METADATA = 44
    SCOREP_INVALID_REGION_TYPE = 45
end

@cenum SCOREP_RmaSyncType::UInt32 begin
    SCOREP_RMA_SYNC_TYPE_MEMORY = 0
    SCOREP_RMA_SYNC_TYPE_NOTIFY_IN = 1
    SCOREP_RMA_SYNC_TYPE_NOTIFY_OUT = 2
    SCOREP_INVALID_RMA_SYNC_TYPE = 3
end

@cenum SCOREP_RmaSyncLevel::UInt32 begin
    SCOREP_RMA_SYNC_LEVEL_NONE = 0
    SCOREP_RMA_SYNC_LEVEL_PROCESS = 1
    SCOREP_RMA_SYNC_LEVEL_MEMORY = 2
end

@cenum SCOREP_RmaAtomicType::UInt32 begin
    SCOREP_RMA_ATOMIC_TYPE_ACCUMULATE = 0
    SCOREP_RMA_ATOMIC_TYPE_INCREMENT = 1
    SCOREP_RMA_ATOMIC_TYPE_TEST_AND_SET = 2
    SCOREP_RMA_ATOMIC_TYPE_COMPARE_AND_SWAP = 3
    SCOREP_RMA_ATOMIC_TYPE_SWAP = 4
    SCOREP_RMA_ATOMIC_TYPE_FETCH_AND_ADD = 5
    SCOREP_RMA_ATOMIC_TYPE_FETCH_AND_INCREMENT = 6
    SCOREP_RMA_ATOMIC_TYPE_ADD = 7
    SCOREP_RMA_ATOMIC_TYPE_FETCH_AND_ACCUMULATE = 8
    SCOREP_INVALID_RMA_ATOMIC_TYPE = 9
end

@cenum SCOREP_SamplingSetClass::UInt32 begin
    SCOREP_SAMPLING_SET_ABSTRACT = 0
    SCOREP_SAMPLING_SET_CPU = 1
    SCOREP_SAMPLING_SET_GPU = 2
end

@cenum SCOREP_MetricScope::UInt32 begin
    SCOREP_METRIC_SCOPE_LOCATION = 0
    SCOREP_METRIC_SCOPE_LOCATION_GROUP = 1
    SCOREP_METRIC_SCOPE_SYSTEM_TREE_NODE = 2
    SCOREP_METRIC_SCOPE_GROUP = 3
    SCOREP_INVALID_METRIC_SCOPE = 4
end

@cenum SCOREP_MetricOccurrence::UInt32 begin
    SCOREP_METRIC_OCCURRENCE_SYNCHRONOUS_STRICT = 0
    SCOREP_METRIC_OCCURRENCE_SYNCHRONOUS = 1
    SCOREP_METRIC_OCCURRENCE_ASYNCHRONOUS = 2
    SCOREP_INVALID_METRIC_OCCURRENCE = 3
end

@cenum SCOREP_IoParadigmType::UInt32 begin
    SCOREP_IO_PARADIGM_POSIX = 0
    SCOREP_IO_PARADIGM_ISOC = 1
    SCOREP_IO_PARADIGM_MPI = 2
    SCOREP_INVALID_IO_PARADIGM_TYPE = 3
end

@cenum SCOREP_IoAccessMode::UInt32 begin
    SCOREP_IO_ACCESS_MODE_NONE = 0
    SCOREP_IO_ACCESS_MODE_READ_ONLY = 1
    SCOREP_IO_ACCESS_MODE_WRITE_ONLY = 2
    SCOREP_IO_ACCESS_MODE_READ_WRITE = 3
    SCOREP_IO_ACCESS_MODE_EXECUTE_ONLY = 4
    SCOREP_IO_ACCESS_MODE_SEARCH_ONLY = 5
end

@cenum SCOREP_IoCreationFlag::UInt32 begin
    SCOREP_IO_CREATION_FLAG_NONE = 0
    SCOREP_IO_CREATION_FLAG_CREATE = 1
    SCOREP_IO_CREATION_FLAG_TRUNCATE = 2
    SCOREP_IO_CREATION_FLAG_DIRECTORY = 4
    SCOREP_IO_CREATION_FLAG_EXCLUSIVE = 8
    SCOREP_IO_CREATION_FLAG_NO_CONTROLLING_TERMINAL = 16
    SCOREP_IO_CREATION_FLAG_NO_FOLLOW = 32
    SCOREP_IO_CREATION_FLAG_PATH = 64
    SCOREP_IO_CREATION_FLAG_TEMPORARY_FILE = 128
    SCOREP_IO_CREATION_FLAG_LARGEFILE = 256
    SCOREP_IO_CREATION_FLAG_NO_SEEK = 512
    SCOREP_IO_CREATION_FLAG_UNIQUE = 1024
end

@cenum SCOREP_IoStatusFlag::UInt32 begin
    SCOREP_IO_STATUS_FLAG_NONE = 0
    SCOREP_IO_STATUS_FLAG_CLOSE_ON_EXEC = 1
    SCOREP_IO_STATUS_FLAG_APPEND = 2
    SCOREP_IO_STATUS_FLAG_NON_BLOCKING = 4
    SCOREP_IO_STATUS_FLAG_ASYNC = 8
    SCOREP_IO_STATUS_FLAG_SYNC = 16
    SCOREP_IO_STATUS_FLAG_DATA_SYNC = 32
    SCOREP_IO_STATUS_FLAG_AVOID_CACHING = 64
    SCOREP_IO_STATUS_FLAG_NO_ACCESS_TIME = 128
    SCOREP_IO_STATUS_FLAG_DELETE_ON_CLOSE = 256
end

@cenum SCOREP_IoSeekOption::UInt32 begin
    SCOREP_IO_SEEK_FROM_START = 0
    SCOREP_IO_SEEK_FROM_CURRENT = 1
    SCOREP_IO_SEEK_FROM_END = 2
    SCOREP_IO_SEEK_DATA = 3
    SCOREP_IO_SEEK_HOLE = 4
    SCOREP_IO_SEEK_INVALID = 5
end

@cenum SCOREP_IoOperationMode::UInt32 begin
    SCOREP_IO_OPERATION_MODE_READ = 0
    SCOREP_IO_OPERATION_MODE_WRITE = 1
    SCOREP_IO_OPERATION_MODE_FLUSH = 2
end

@cenum SCOREP_IoOperationFlag::UInt32 begin
    SCOREP_IO_OPERATION_FLAG_NONE = 0
    SCOREP_IO_OPERATION_FLAG_BLOCKING = 0
    SCOREP_IO_OPERATION_FLAG_NON_BLOCKING = 1
    SCOREP_IO_OPERATION_FLAG_COLLECTIVE = 2
    SCOREP_IO_OPERATION_FLAG_NON_COLLECTIVE = 0
end

@cenum SCOREP_Ipc_Datatype::UInt32 begin
    SCOREP_IPC_BYTE = 0
    SCOREP_IPC_CHAR = 1
    SCOREP_IPC_UNSIGNED_CHAR = 2
    SCOREP_IPC_INT = 3
    SCOREP_IPC_UNSIGNED = 4
    SCOREP_IPC_INT32_T = 5
    SCOREP_IPC_UINT32_T = 6
    SCOREP_IPC_INT64_T = 7
    SCOREP_IPC_UINT64_T = 8
    SCOREP_IPC_DOUBLE = 9
    SCOREP_IPC_NUMBER_OF_DATATYPES = 10
end

@cenum SCOREP_Ipc_Operation::UInt32 begin
    SCOREP_IPC_BAND = 0
    SCOREP_IPC_BOR = 1
    SCOREP_IPC_MIN = 2
    SCOREP_IPC_MAX = 3
    SCOREP_IPC_SUM = 4
    SCOREP_IPC_NUMBER_OF_OPERATIONS = 5
end

@cenum SCOREP_Substrates_RequirementFlag::UInt32 begin
    SCOREP_SUBSTRATES_REQUIREMENT_CREATE_EXPERIMENT_DIRECTORY = 0
    SCOREP_SUBSTRATES_REQUIREMENT_PREVENT_ASYNC_METRICS = 1
    SCOREP_SUBSTRATES_REQUIREMENT_PREVENT_PER_HOST_AND_ONCE_METRICS = 2
    SCOREP_SUBSTRATES_NUM_REQUIREMENTS = 3
end

# typedef void ( * SCOREP_Substrates_Callback ) ( void )
const SCOREP_Substrates_Callback = Ptr{Cvoid}

mutable struct SCOREP_Location end

@cenum SCOREP_Substrates_Mode::UInt32 begin
    SCOREP_SUBSTRATES_RECORDING_ENABLED = 0
    SCOREP_SUBSTRATES_RECORDING_DISABLED = 1
    SCOREP_SUBSTRATES_NUM_MODES = 2
end

@cenum SCOREP_Substrates_EventType::UInt32 begin
    SCOREP_EVENT_ENABLE_RECORDING = 0
    SCOREP_EVENT_DISABLE_RECORDING = 1
    SCOREP_EVENT_ON_TRACING_BUFFER_FLUSH_BEGIN = 2
    SCOREP_EVENT_ON_TRACING_BUFFER_FLUSH_END = 3
    SCOREP_EVENT_ENTER_REGION = 4
    SCOREP_EVENT_EXIT_REGION = 5
    SCOREP_EVENT_SAMPLE = 6
    SCOREP_EVENT_CALLING_CONTEXT_ENTER = 7
    SCOREP_EVENT_CALLING_CONTEXT_EXIT = 8
    SCOREP_EVENT_ENTER_REWIND_REGION = 9
    SCOREP_EVENT_EXIT_REWIND_REGION = 10
    SCOREP_EVENT_MPI_SEND = 11
    SCOREP_EVENT_MPI_RECV = 12
    SCOREP_EVENT_MPI_COLLECTIVE_BEGIN = 13
    SCOREP_EVENT_MPI_COLLECTIVE_END = 14
    SCOREP_EVENT_MPI_ISEND_COMPLETE = 15
    SCOREP_EVENT_MPI_IRECV_REQUEST = 16
    SCOREP_EVENT_MPI_REQUEST_TESTED = 17
    SCOREP_EVENT_MPI_REQUEST_CANCELLED = 18
    SCOREP_EVENT_MPI_ISEND = 19
    SCOREP_EVENT_MPI_IRECV = 20
    SCOREP_EVENT_RMA_WIN_CREATE = 21
    SCOREP_EVENT_RMA_WIN_DESTROY = 22
    SCOREP_EVENT_RMA_COLLECTIVE_BEGIN = 23
    SCOREP_EVENT_RMA_COLLECTIVE_END = 24
    SCOREP_EVENT_RMA_TRY_LOCK = 25
    SCOREP_EVENT_RMA_ACQUIRE_LOCK = 26
    SCOREP_EVENT_RMA_REQUEST_LOCK = 27
    SCOREP_EVENT_RMA_RELEASE_LOCK = 28
    SCOREP_EVENT_RMA_SYNC = 29
    SCOREP_EVENT_RMA_GROUP_SYNC = 30
    SCOREP_EVENT_RMA_PUT = 31
    SCOREP_EVENT_RMA_GET = 32
    SCOREP_EVENT_RMA_ATOMIC = 33
    SCOREP_EVENT_RMA_WAIT_CHANGE = 34
    SCOREP_EVENT_RMA_OP_COMPLETE_BLOCKING = 35
    SCOREP_EVENT_RMA_OP_COMPLETE_NON_BLOCKING = 36
    SCOREP_EVENT_RMA_OP_TEST = 37
    SCOREP_EVENT_RMA_OP_COMPLETE_REMOTE = 38
    SCOREP_EVENT_THREAD_ACQUIRE_LOCK = 39
    SCOREP_EVENT_THREAD_RELEASE_LOCK = 40
    SCOREP_EVENT_TRIGGER_COUNTER_INT64 = 41
    SCOREP_EVENT_TRIGGER_COUNTER_UINT64 = 42
    SCOREP_EVENT_TRIGGER_COUNTER_DOUBLE = 43
    SCOREP_EVENT_TRIGGER_PARAMETER_INT64 = 44
    SCOREP_EVENT_TRIGGER_PARAMETER_UINT64 = 45
    SCOREP_EVENT_TRIGGER_PARAMETER_STRING = 46
    SCOREP_EVENT_THREAD_FORK_JOIN_FORK = 47
    SCOREP_EVENT_THREAD_FORK_JOIN_JOIN = 48
    SCOREP_EVENT_THREAD_FORK_JOIN_TEAM_BEGIN = 49
    SCOREP_EVENT_THREAD_FORK_JOIN_TEAM_END = 50
    SCOREP_EVENT_THREAD_FORK_JOIN_TASK_CREATE = 51
    SCOREP_EVENT_THREAD_FORK_JOIN_TASK_SWITCH = 52
    SCOREP_EVENT_THREAD_FORK_JOIN_TASK_BEGIN = 53
    SCOREP_EVENT_THREAD_FORK_JOIN_TASK_END = 54
    SCOREP_EVENT_THREAD_CREATE_WAIT_CREATE = 55
    SCOREP_EVENT_THREAD_CREATE_WAIT_WAIT = 56
    SCOREP_EVENT_THREAD_CREATE_WAIT_BEGIN = 57
    SCOREP_EVENT_THREAD_CREATE_WAIT_END = 58
    SCOREP_EVENT_TRACK_ALLOC = 59
    SCOREP_EVENT_TRACK_REALLOC = 60
    SCOREP_EVENT_TRACK_FREE = 61
    SCOREP_EVENT_WRITE_POST_MORTEM_METRICS = 62
    SCOREP_EVENT_PROGRAM_BEGIN = 63
    SCOREP_EVENT_PROGRAM_END = 64
    SCOREP_EVENT_IO_CREATE_HANDLE = 65
    SCOREP_EVENT_IO_DESTROY_HANDLE = 66
    SCOREP_EVENT_IO_DUPLICATE_HANDLE = 67
    SCOREP_EVENT_IO_SEEK = 68
    SCOREP_EVENT_IO_CHANGE_STATUS_FLAGS = 69
    SCOREP_EVENT_IO_DELETE_FILE = 70
    SCOREP_EVENT_IO_OPERATION_BEGIN = 71
    SCOREP_EVENT_IO_OPERATION_ISSUED = 72
    SCOREP_EVENT_IO_OPERATION_TEST = 73
    SCOREP_EVENT_IO_OPERATION_COMPLETE = 74
    SCOREP_EVENT_IO_OPERATION_CANCELLED = 75
    SCOREP_EVENT_IO_ACQUIRE_LOCK = 76
    SCOREP_EVENT_IO_RELEASE_LOCK = 77
    SCOREP_EVENT_IO_TRY_LOCK = 78
    SCOREP_SUBSTRATES_NUM_EVENTS = 79
end

# typedef void ( * SCOREP_Substrates_EnableRecordingCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues )
const SCOREP_Substrates_EnableRecordingCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_DisableRecordingCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues )
const SCOREP_Substrates_DisableRecordingCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_OnTracingBufferFlushBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues )
const SCOREP_Substrates_OnTracingBufferFlushBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_OnTracingBufferFlushEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues )
const SCOREP_Substrates_OnTracingBufferFlushEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ProgramBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_StringHandle programName , uint32_t numberOfProgramArgs , SCOREP_StringHandle * programArguments , SCOREP_RegionHandle programRegionHandle , uint64_t processId , uint64_t threadId )
const SCOREP_Substrates_ProgramBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ProgramEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ExitStatus exitStatus , SCOREP_RegionHandle programRegionHandle )
const SCOREP_Substrates_ProgramEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_EnterRegionCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues )
const SCOREP_Substrates_EnterRegionCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ExitRegionCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues )
const SCOREP_Substrates_ExitRegionCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_SampleCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_CallingContextHandle callingContext , SCOREP_CallingContextHandle previousCallingContext , uint32_t unwindDistance , SCOREP_InterruptGeneratorHandle interruptGeneratorHandle , uint64_t * metricValues )
const SCOREP_Substrates_SampleCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_CallingContextEnterCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_CallingContextHandle callingContext , SCOREP_CallingContextHandle previousCallingContext , uint32_t unwindDistance , uint64_t * metricValues )
const SCOREP_Substrates_CallingContextEnterCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_CallingContextExitCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_CallingContextHandle callingContext , SCOREP_CallingContextHandle previousCallingContext , uint32_t unwindDistance , uint64_t * metricValues )
const SCOREP_Substrates_CallingContextExitCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_EnterRewindRegionCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle )
const SCOREP_Substrates_EnterRewindRegionCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ExitRewindRegionCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , bool doRewind )
const SCOREP_Substrates_ExitRewindRegionCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiSendCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRank destinationRank , SCOREP_InterimCommunicatorHandle communicatorHandle , uint32_t tag , uint64_t bytesSent )
const SCOREP_Substrates_MpiSendCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiRecvCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRank sourceRank , SCOREP_InterimCommunicatorHandle communicatorHandle , uint32_t tag , uint64_t bytesReceived )
const SCOREP_Substrates_MpiRecvCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiCollectiveBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp )
const SCOREP_Substrates_MpiCollectiveBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiCollectiveEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_InterimCommunicatorHandle communicatorHandle , SCOREP_MpiRank rootRank , SCOREP_CollectiveType collectiveType , uint64_t bytesSent , uint64_t bytesReceived )
const SCOREP_Substrates_MpiCollectiveEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiIsendCompleteCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRequestId requestId )
const SCOREP_Substrates_MpiIsendCompleteCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiIrecvRequestCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRequestId requestId )
const SCOREP_Substrates_MpiIrecvRequestCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiRequestTestedCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRequestId requestId )
const SCOREP_Substrates_MpiRequestTestedCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiRequestCancelledCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRequestId requestId )
const SCOREP_Substrates_MpiRequestCancelledCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiIsendCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRank destinationRank , SCOREP_InterimCommunicatorHandle communicatorHandle , uint32_t tag , uint64_t bytesSent , SCOREP_MpiRequestId requestId )
const SCOREP_Substrates_MpiIsendCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_MpiIrecvCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_MpiRank sourceRank , SCOREP_InterimCommunicatorHandle communicatorHandle , uint32_t tag , uint64_t bytesReceived , SCOREP_MpiRequestId requestId )
const SCOREP_Substrates_MpiIrecvCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaWinCreateCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle )
const SCOREP_Substrates_RmaWinCreateCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaWinDestroyCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle )
const SCOREP_Substrates_RmaWinDestroyCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaCollectiveBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaSyncLevel syncLevel )
const SCOREP_Substrates_RmaCollectiveBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaCollectiveEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_CollectiveType collectiveOp , SCOREP_RmaSyncLevel syncLevel , SCOREP_RmaWindowHandle windowHandle , uint32_t root , uint64_t bytesSent , uint64_t bytesReceived )
const SCOREP_Substrates_RmaCollectiveEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaTryLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , uint64_t lockId , SCOREP_LockType lockType )
const SCOREP_Substrates_RmaTryLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaAcquireLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , uint64_t lockId , SCOREP_LockType lockType )
const SCOREP_Substrates_RmaAcquireLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaRequestLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , uint64_t lockId , SCOREP_LockType lockType )
const SCOREP_Substrates_RmaRequestLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaReleaseLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , uint64_t lockId )
const SCOREP_Substrates_RmaReleaseLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaSyncCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , SCOREP_RmaSyncType syncType )
const SCOREP_Substrates_RmaSyncCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaGroupSyncCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaSyncLevel syncLevel , SCOREP_RmaWindowHandle windowHandle , SCOREP_GroupHandle groupHandle )
const SCOREP_Substrates_RmaGroupSyncCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaPutCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , uint64_t bytes , uint64_t matchingId )
const SCOREP_Substrates_RmaPutCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaGetCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , uint64_t bytes , uint64_t matchingId )
const SCOREP_Substrates_RmaGetCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaAtomicCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint32_t remote , SCOREP_RmaAtomicType type , uint64_t bytesSent , uint64_t bytesReceived , uint64_t matchingId )
const SCOREP_Substrates_RmaAtomicCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaWaitChangeCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle )
const SCOREP_Substrates_RmaWaitChangeCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaOpCompleteBlockingCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint64_t matchingId )
const SCOREP_Substrates_RmaOpCompleteBlockingCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaOpCompleteNonBlockingCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint64_t matchingId )
const SCOREP_Substrates_RmaOpCompleteNonBlockingCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaOpTestCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint64_t matchingId )
const SCOREP_Substrates_RmaOpTestCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_RmaOpCompleteRemoteCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RmaWindowHandle windowHandle , uint64_t matchingId )
const SCOREP_Substrates_RmaOpCompleteRemoteCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadAcquireLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , uint32_t lockId , uint32_t acquisitionOrder )
const SCOREP_Substrates_ThreadAcquireLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadReleaseLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , uint32_t lockId , uint32_t acquisitionOrder )
const SCOREP_Substrates_ThreadReleaseLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TriggerCounterInt64Cb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_SamplingSetHandle counterHandle , int64_t value )
const SCOREP_Substrates_TriggerCounterInt64Cb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TriggerCounterUint64Cb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_SamplingSetHandle counterHandle , uint64_t value )
const SCOREP_Substrates_TriggerCounterUint64Cb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TriggerCounterDoubleCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_SamplingSetHandle counterHandle , double value )
const SCOREP_Substrates_TriggerCounterDoubleCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TriggerParameterInt64Cb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParameterHandle parameterHandle , int64_t value )
const SCOREP_Substrates_TriggerParameterInt64Cb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TriggerParameterUint64Cb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParameterHandle parameterHandle , uint64_t value )
const SCOREP_Substrates_TriggerParameterUint64Cb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TriggerParameterStringCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParameterHandle parameterHandle , SCOREP_StringHandle string_handle )
const SCOREP_Substrates_TriggerParameterStringCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinForkCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , uint32_t nRequestedThreads , uint32_t forkSequenceCount )
const SCOREP_Substrates_ThreadForkJoinForkCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinJoinCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm )
const SCOREP_Substrates_ThreadForkJoinJoinCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinTeamBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint64_t threadId )
const SCOREP_Substrates_ThreadForkJoinTeamBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinTeamEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam )
const SCOREP_Substrates_ThreadForkJoinTeamEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinTaskCreateCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t threadId , uint32_t generationNumber )
const SCOREP_Substrates_ThreadForkJoinTaskCreateCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinTaskSwitchCb ) ( struct SCOREP_Location * location , uint64_t timestamp , uint64_t * metricValues , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t threadId , uint32_t generationNumber , SCOREP_TaskHandle taskHandle )
const SCOREP_Substrates_ThreadForkJoinTaskSwitchCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinTaskBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t threadId , uint32_t generationNumber , SCOREP_TaskHandle taskHandle )
const SCOREP_Substrates_ThreadForkJoinTaskBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadForkJoinTaskEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_RegionHandle regionHandle , uint64_t * metricValues , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t threadId , uint32_t generationNumber , SCOREP_TaskHandle taskHandle )
const SCOREP_Substrates_ThreadForkJoinTaskEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadCreateWaitCreateCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t createSequenceCount )
const SCOREP_Substrates_ThreadCreateWaitCreateCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadCreateWaitWaitCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t createSequenceCount )
const SCOREP_Substrates_ThreadCreateWaitWaitCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadCreateWaitBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t createSequenceCount , uint64_t threadId )
const SCOREP_Substrates_ThreadCreateWaitBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_ThreadCreateWaitEndCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_ParadigmType paradigm , SCOREP_InterimCommunicatorHandle threadTeam , uint32_t createSequenceCount )
const SCOREP_Substrates_ThreadCreateWaitEndCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TrackAllocCb ) ( struct SCOREP_Location * location , uint64_t timestamp , uint64_t addrAllocated , size_t bytesAllocated , void * substrateData [ ] , size_t bytesAllocatedMetric , size_t bytesAllocatedProcess )
const SCOREP_Substrates_TrackAllocCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TrackReallocCb ) ( struct SCOREP_Location * location , uint64_t timestamp , uint64_t oldAddr , size_t oldBytesAllocated , void * oldSubstrateData [ ] , uint64_t newAddr , size_t newBytesAllocated , void * newSubstrateData [ ] , size_t bytesAllocatedMetric , size_t bytesAllocatedProcess )
const SCOREP_Substrates_TrackReallocCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_TrackFreeCb ) ( struct SCOREP_Location * location , uint64_t timestamp , uint64_t addrFreed , size_t bytesFreed , void * substrateData [ ] , size_t bytesAllocatedMetric , size_t bytesAllocatedProcess )
const SCOREP_Substrates_TrackFreeCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_WriteMetricsCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_SamplingSetHandle samplingSet , const uint64_t * metricValues )
const SCOREP_Substrates_WriteMetricsCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoCreateHandleCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_IoAccessMode mode , SCOREP_IoCreationFlag creationFlags , SCOREP_IoStatusFlag statusFlags )
const SCOREP_Substrates_IoCreateHandleCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoDestroyHandleCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle )
const SCOREP_Substrates_IoDestroyHandleCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoDuplicateHandleCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle oldHandle , SCOREP_IoHandleHandle newHandle , SCOREP_IoStatusFlag statusFlags )
const SCOREP_Substrates_IoDuplicateHandleCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoSeekCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , int64_t offsetRequest , SCOREP_IoSeekOption whence , uint64_t offsetResult )
const SCOREP_Substrates_IoSeekCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoChangeStatusFlagsCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_IoStatusFlag statusFlags )
const SCOREP_Substrates_IoChangeStatusFlagsCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoDeleteFileCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoParadigmType ioParadigm , SCOREP_IoFileHandle ioFile )
const SCOREP_Substrates_IoDeleteFileCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoOperationBeginCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_IoOperationMode mode , SCOREP_IoOperationFlag operationFlags , uint64_t bytesRequest , uint64_t matchingId , uint64_t offset )
const SCOREP_Substrates_IoOperationBeginCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoOperationIssuedCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , uint64_t matchingId )
const SCOREP_Substrates_IoOperationIssuedCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoOperationTestCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , uint64_t matchingId )
const SCOREP_Substrates_IoOperationTestCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoOperationCompleteCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_IoOperationMode mode , uint64_t bytesResult , uint64_t matchingId )
const SCOREP_Substrates_IoOperationCompleteCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoOperationCancelledCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , uint64_t matchingId )
const SCOREP_Substrates_IoOperationCancelledCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoAcquireLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_LockType lockType )
const SCOREP_Substrates_IoAcquireLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoReleaseLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_LockType lockType )
const SCOREP_Substrates_IoReleaseLockCb = Ptr{Cvoid}

# typedef void ( * SCOREP_Substrates_IoTryLockCb ) ( struct SCOREP_Location * location , uint64_t timestamp , SCOREP_IoHandleHandle handle , SCOREP_LockType lockType )
const SCOREP_Substrates_IoTryLockCb = Ptr{Cvoid}

struct SCOREP_SubstratePluginInfo
    plugin_version::UInt32
    init::Ptr{Cvoid}
    assign_id::Ptr{Cvoid}
    init_mpp::Ptr{Cvoid}
    finalize::Ptr{Cvoid}
    create_location::Ptr{Cvoid}
    activate_cpu_location::Ptr{Cvoid}
    deactivate_cpu_location::Ptr{Cvoid}
    delete_location::Ptr{Cvoid}
    pre_unify::Ptr{Cvoid}
    write_data::Ptr{Cvoid}
    core_task_create::Ptr{Cvoid}
    core_task_complete::Ptr{Cvoid}
    new_definition_handle::Ptr{Cvoid}
    get_event_functions::Ptr{Cvoid}
    set_callbacks::Ptr{Cvoid}
    get_requirement::Ptr{Cvoid}
    dump_manifest::Ptr{Cvoid}
    undeclared::NTuple{99, Ptr{Cvoid}}
end

struct SCOREP_SubstratePluginCallbacks
    SCOREP_GetExperimentDirName::Ptr{Cvoid}
    SCOREP_Ipc_GetSize::Ptr{Cvoid}
    SCOREP_Ipc_GetRank::Ptr{Cvoid}
    SCOREP_Ipc_Send::Ptr{Cvoid}
    SCOREP_Ipc_Recv::Ptr{Cvoid}
    SCOREP_Ipc_Barrier::Ptr{Cvoid}
    SCOREP_Ipc_Bcast::Ptr{Cvoid}
    SCOREP_Ipc_Gather::Ptr{Cvoid}
    SCOREP_Ipc_Gatherv::Ptr{Cvoid}
    SCOREP_Ipc_Allgather::Ptr{Cvoid}
    SCOREP_Ipc_Reduce::Ptr{Cvoid}
    SCOREP_Ipc_Allreduce::Ptr{Cvoid}
    SCOREP_Ipc_Scatter::Ptr{Cvoid}
    SCOREP_Ipc_Scatterv::Ptr{Cvoid}
    SCOREP_Location_GetType::Ptr{Cvoid}
    SCOREP_Location_GetName::Ptr{Cvoid}
    SCOREP_Location_GetId::Ptr{Cvoid}
    SCOREP_Location_GetGlobalId::Ptr{Cvoid}
    SCOREP_Location_SetData::Ptr{Cvoid}
    SCOREP_Location_GetData::Ptr{Cvoid}
    SCOREP_CallingContextHandle_GetRegion::Ptr{Cvoid}
    SCOREP_CallingContextHandle_GetParent::Ptr{Cvoid}
    SCOREP_MetricHandle_GetValueType::Ptr{Cvoid}
    SCOREP_MetricHandle_GetName::Ptr{Cvoid}
    SCOREP_MetricHandle_GetProfilingType::Ptr{Cvoid}
    SCOREP_MetricHandle_GetMode::Ptr{Cvoid}
    SCOREP_MetricHandle_GetSourceType::Ptr{Cvoid}
    SCOREP_ParadigmHandle_GetClass::Ptr{Cvoid}
    SCOREP_ParadigmHandle_GetName::Ptr{Cvoid}
    SCOREP_ParadigmHandle_GetType::Ptr{Cvoid}
    SCOREP_ParameterHandle_GetName::Ptr{Cvoid}
    SCOREP_ParameterHandle_GetType::Ptr{Cvoid}
    SCOREP_RegionHandle_GetId::Ptr{Cvoid}
    SCOREP_RegionHandle_GetName::Ptr{Cvoid}
    SCOREP_RegionHandle_GetCanonicalName::Ptr{Cvoid}
    SCOREP_RegionHandle_GetFileName::Ptr{Cvoid}
    SCOREP_RegionHandle_GetBeginLine::Ptr{Cvoid}
    SCOREP_RegionHandle_GetEndLine::Ptr{Cvoid}
    SCOREP_RegionHandle_GetType::Ptr{Cvoid}
    SCOREP_RegionHandle_GetParadigmType::Ptr{Cvoid}
    SCOREP_SamplingSetHandle_GetNumberOfMetrics::Ptr{Cvoid}
    SCOREP_SamplingSetHandle_GetMetricHandles::Ptr{Cvoid}
    SCOREP_SamplingSetHandle_GetMetricOccurrence::Ptr{Cvoid}
    SCOREP_SamplingSetHandle_IsScoped::Ptr{Cvoid}
    SCOREP_SamplingSetHandle_GetScope::Ptr{Cvoid}
    SCOREP_SamplingSetHandle_GetSamplingSetClass::Ptr{Cvoid}
    SCOREP_SourceFileHandle_GetName::Ptr{Cvoid}
    SCOREP_StringHandle_Get::Ptr{Cvoid}
    SCOREP_Metric_WriteStrictlySynchronousMetrics::Ptr{Cvoid}
    SCOREP_Metric_WriteSynchronousMetrics::Ptr{Cvoid}
    SCOREP_Metric_WriteAsynchronousMetrics::Ptr{Cvoid}
    SCOREP_ConfigManifestSectionHeader::Ptr{Cvoid}
    SCOREP_ConfigManifestSectionEntry::Ptr{Cvoid}
end

const SCOREP_User_ParameterHandle = UInt64

function SCOREP_Tau_InitMeasurement()
    ccall((:SCOREP_Tau_InitMeasurement, libscorep_adapter_user_event), Cvoid, ())
end

const SCOREP_Tau_LineNo = UInt32

# typedef int ( * SCOREP_Tau_ExitCallback ) ( void )
const SCOREP_Tau_ExitCallback = Ptr{Cvoid}

@cenum SCOREP_Tau_ParadigmType::UInt32 begin
    SCOREP_TAU_PARADIGM_USER = 0
    SCOREP_TAU_PARADIGM_COMPILER = 1
    SCOREP_TAU_PARADIGM_MPP = 2
    SCOREP_TAU_PARADIGM_MPI = 3
    SCOREP_TAU_PARADIGM_THREAD_FORK_JOIN = 4
    SCOREP_TAU_PARADIGM_OPENMP = 5
    SCOREP_TAU_PARADIGM_THREAD_CREATE_WAIT = 6
    SCOREP_TAU_PARADIGM_ACCELERATOR = 7
    SCOREP_TAU_PARADIGM_CUDA = 8
    SCOREP_TAU_PARADIGM_MEASUREMENT = 9
    SCOREP_TAU_PARADIGM_SHMEM = 10
    SCOREP_TAU_PARADIGM_PTHREAD = 11
    SCOREP_TAU_PARADIGM_OPENCL = 12
    SCOREP_TAU_INVALID_PARADIGM_TYPE = 13
end

@cenum SCOREP_Tau_RegionType::UInt32 begin
    SCOREP_TAU_REGION_UNKNOWN = 0
    SCOREP_TAU_REGION_FUNCTION = 1
    SCOREP_TAU_REGION_LOOP = 2
    SCOREP_TAU_REGION_USER = 3
    SCOREP_TAU_REGION_CODE = 4
    SCOREP_TAU_REGION_PHASE = 5
    SCOREP_TAU_REGION_DYNAMIC = 6
    SCOREP_TAU_REGION_DYNAMIC_PHASE = 7
    SCOREP_TAU_REGION_DYNAMIC_LOOP = 8
    SCOREP_TAU_REGION_DYNAMIC_FUNCTION = 9
    SCOREP_TAU_REGION_DYNAMIC_LOOP_PHASE = 10
    SCOREP_TAU_REGION_COLL_BARRIER = 11
    SCOREP_TAU_REGION_COLL_ONE2ALL = 12
    SCOREP_TAU_REGION_COLL_ALL2ONE = 13
    SCOREP_TAU_REGION_COLL_ALL2ALL = 14
    SCOREP_TAU_REGION_COLL_OTHER = 15
    SCOREP_TAU_REGION_POINT2POINT = 16
    SCOREP_TAU_REGION_PARALLEL = 17
    SCOREP_TAU_REGION_SECTIONS = 18
    SCOREP_TAU_REGION_SECTION = 19
    SCOREP_TAU_REGION_WORKSHARE = 20
    SCOREP_TAU_REGION_SINGLE = 21
    SCOREP_TAU_REGION_MASTER = 22
    SCOREP_TAU_REGION_CRITICAL = 23
    SCOREP_TAU_REGION_ATOMIC = 24
    SCOREP_TAU_REGION_BARRIER = 25
    SCOREP_TAU_REGION_IMPLICIT_BARRIER = 26
    SCOREP_TAU_REGION_FLUSH = 27
    SCOREP_TAU_REGION_CRITICAL_SBLOCK = 28
    SCOREP_TAU_REGION_SINGLE_SBLOCK = 29
    SCOREP_TAU_REGION_WRAPPER = 30
    SCOREP_TAU_REGION_TASK = 31
    SCOREP_TAU_REGION_TASK_WAIT = 32
    SCOREP_TAU_REGION_TASK_CREATE = 33
    SCOREP_TAU_REGION_ORDERED = 34
    SCOREP_TAU_REGION_ORDERED_SBLOCK = 35
    SCOREP_TAU_REGION_ARTIFICIAL = 36
    SCOREP_TAU_REGION_THREAD_CREATE = 37
    SCOREP_TAU_REGION_THREAD_WAIT = 38
    SCOREP_TAU_REGION_TASK_UNTIED = 39
    SCOREP_TAU_REGION_RMA = 40
    SCOREP_TAU_REGION_ALLOCATE = 41
    SCOREP_TAU_REGION_DEALLOCATE = 42
    SCOREP_TAU_REGION_REALLOCATE = 43
    SCOREP_TAU_REGION_FILE_IO = 44
    SCOREP_TAU_REGION_FILE_IO_METADATA = 45
    SCOREP_TAU_INVALID_REGION_TYPE = 46
end

function SCOREP_Tau_DefineRegion(regionName, fileHandle, beginLine, endLine, paradigm,
                                 regionType)
    ccall((:SCOREP_Tau_DefineRegion, libscorep_adapter_user_event), UInt64,
          (Ptr{Cchar}, SCOREP_SourceFileHandle, SCOREP_Tau_LineNo, SCOREP_Tau_LineNo,
           SCOREP_Tau_ParadigmType, SCOREP_Tau_RegionType), regionName, fileHandle,
          beginLine, endLine, paradigm, regionType)
end

function SCOREP_Tau_EnterRegion(regionHandle)
    ccall((:SCOREP_Tau_EnterRegion, libscorep_adapter_user_event), Cvoid, (UInt64,),
          regionHandle)
end

function SCOREP_Tau_ExitRegion(regionHandle)
    ccall((:SCOREP_Tau_ExitRegion, libscorep_adapter_user_event), Cvoid, (UInt64,),
          regionHandle)
end

function SCOREP_Tau_RegisterExitCallback(arg1)
    ccall((:SCOREP_Tau_RegisterExitCallback, libscorep_adapter_user_event), Cvoid,
          (SCOREP_Tau_ExitCallback,), arg1)
end

function SCOREP_Tau_Metric(metricHandle)
    ccall((:SCOREP_Tau_Metric, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_SamplingSetHandle},), metricHandle)
end

function SCOREP_Tau_InitMetric(metricHandle, name, unit)
    ccall((:SCOREP_Tau_InitMetric, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_SamplingSetHandle}, Ptr{Cchar}, Ptr{Cchar}), metricHandle, name, unit)
end

function SCOREP_Tau_TriggerMetricDouble(metricHandle, value)
    ccall((:SCOREP_Tau_TriggerMetricDouble, libscorep_adapter_user_event), Cvoid,
          (SCOREP_SamplingSetHandle, Cdouble), metricHandle, value)
end

function SCOREP_Tau_Parameter_INT64(paramHandle, name, value)
    ccall((:SCOREP_Tau_Parameter_INT64, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_ParameterHandle}, Ptr{Cchar}, Int64), paramHandle, name, value)
end

function SCOREP_Tau_AddLocationProperty(name, value)
    ccall((:SCOREP_Tau_AddLocationProperty, libscorep_adapter_user_event), Cvoid,
          (Ptr{Cchar}, Ptr{Cchar}), name, value)
end

mutable struct SCOREP_User_Region end

const SCOREP_User_RegionHandle = Ptr{SCOREP_User_Region}

const SCOREP_User_RegionType = UInt32

function SCOREP_User_RegionBegin(handle, lastFileName, lastFile, name, regionType, fileName,
                                 lineNo)
    ccall((:SCOREP_User_RegionBegin, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_RegionHandle}, Ptr{Ptr{Cchar}}, Ptr{SCOREP_SourceFileHandle},
           Ptr{Cchar}, SCOREP_User_RegionType, Ptr{Cchar}, UInt32), handle, lastFileName,
          lastFile, name, regionType, fileName, lineNo)
end

function SCOREP_User_RegionEnd(handle)
    ccall((:SCOREP_User_RegionEnd, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_RegionHandle,), handle)
end

function SCOREP_User_RegionSetGroup(handle, groupName)
    ccall((:SCOREP_User_RegionSetGroup, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_RegionHandle, Ptr{Cchar}), handle, groupName)
end

function SCOREP_User_RegionByNameBegin(name, regionType, fileName, lineNo)
    ccall((:SCOREP_User_RegionByNameBegin, libscorep_adapter_user_event), Cvoid,
          (Ptr{Cchar}, SCOREP_User_RegionType, Ptr{Cchar}, UInt32), name, regionType,
          fileName, lineNo)
end

function SCOREP_User_RegionByNameEnd(name)
    ccall((:SCOREP_User_RegionByNameEnd, libscorep_adapter_user_event), Cvoid,
          (Ptr{Cchar},), name)
end

function SCOREP_User_RegionInit(handle, lastFileName, lastFile, name, regionType, fileName,
                                lineNo)
    ccall((:SCOREP_User_RegionInit, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_RegionHandle}, Ptr{Ptr{Cchar}}, Ptr{SCOREP_SourceFileHandle},
           Ptr{Cchar}, SCOREP_User_RegionType, Ptr{Cchar}, UInt32), handle, lastFileName,
          lastFile, name, regionType, fileName, lineNo)
end

function SCOREP_User_RegionEnter(handle)
    ccall((:SCOREP_User_RegionEnter, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_RegionHandle,), handle)
end

function SCOREP_User_RewindRegionBegin(handle, lastFileName, lastFile, name, regionType,
                                       fileName, lineNo)
    ccall((:SCOREP_User_RewindRegionBegin, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_RegionHandle}, Ptr{Ptr{Cchar}}, Ptr{SCOREP_SourceFileHandle},
           Ptr{Cchar}, SCOREP_User_RegionType, Ptr{Cchar}, UInt32), handle, lastFileName,
          lastFile, name, regionType, fileName, lineNo)
end

function SCOREP_User_RewindRegionEnd(handle, value)
    ccall((:SCOREP_User_RewindRegionEnd, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_RegionHandle, Bool), handle, value)
end

function SCOREP_User_RewindRegionEnter(handle)
    ccall((:SCOREP_User_RewindRegionEnter, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_RegionHandle,), handle)
end

function SCOREP_User_OaPhaseBegin(handle, lastFileName, lastFile, name, regionType,
                                  fileName, lineNo)
    ccall((:SCOREP_User_OaPhaseBegin, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_RegionHandle}, Ptr{Ptr{Cchar}}, Ptr{SCOREP_SourceFileHandle},
           Ptr{Cchar}, SCOREP_User_RegionType, Ptr{Cchar}, UInt32), handle, lastFileName,
          lastFile, name, regionType, fileName, lineNo)
end

function SCOREP_User_OaPhaseEnd(handle)
    ccall((:SCOREP_User_OaPhaseEnd, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_RegionHandle,), handle)
end

function SCOREP_User_ParameterInt64(handle, name, value)
    ccall((:SCOREP_User_ParameterInt64, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_ParameterHandle}, Ptr{Cchar}, Int64), handle, name, value)
end

function SCOREP_User_ParameterUint64(handle, name, value)
    ccall((:SCOREP_User_ParameterUint64, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_ParameterHandle}, Ptr{Cchar}, UInt64), handle, name, value)
end

function SCOREP_User_ParameterString(handle, name, value)
    ccall((:SCOREP_User_ParameterString, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_ParameterHandle}, Ptr{Cchar}, Ptr{Cchar}), handle, name, value)
end

const SCOREP_User_MetricType = UInt32

function SCOREP_User_InitMetric(metricHandle, name, unit, metricType, context)
    ccall((:SCOREP_User_InitMetric, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_SamplingSetHandle}, Ptr{Cchar}, Ptr{Cchar}, SCOREP_User_MetricType,
           Int8), metricHandle, name, unit, metricType, context)
end

function SCOREP_User_TriggerMetricInt64(metricHandle, value)
    ccall((:SCOREP_User_TriggerMetricInt64, libscorep_adapter_user_event), Cvoid,
          (SCOREP_SamplingSetHandle, Int64), metricHandle, value)
end

function SCOREP_User_TriggerMetricUint64(metricHandle, value)
    ccall((:SCOREP_User_TriggerMetricUint64, libscorep_adapter_user_event), Cvoid,
          (SCOREP_SamplingSetHandle, UInt64), metricHandle, value)
end

function SCOREP_User_TriggerMetricDouble(metricHandle, value)
    ccall((:SCOREP_User_TriggerMetricDouble, libscorep_adapter_user_event), Cvoid,
          (SCOREP_SamplingSetHandle, Cdouble), metricHandle, value)
end

mutable struct SCOREP_User_Topology end

const SCOREP_User_CartesianTopologyHandle = Ptr{SCOREP_User_Topology}

function SCOREP_User_CartTopologyCreate(topologyHandle, name, nDims)
    ccall((:SCOREP_User_CartTopologyCreate, libscorep_adapter_user_event), Cvoid,
          (Ptr{SCOREP_User_CartesianTopologyHandle}, Ptr{Cchar}, UInt32), topologyHandle,
          name, nDims)
end

function SCOREP_User_CartTopologyAddDim(topologyHandle, size, periodic, name)
    ccall((:SCOREP_User_CartTopologyAddDim, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_CartesianTopologyHandle, UInt32, Bool, Ptr{Cchar}), topologyHandle,
          size, periodic, name)
end

function SCOREP_User_CartTopologyInit(topologyHandle)
    ccall((:SCOREP_User_CartTopologyInit, libscorep_adapter_user_event), Cvoid,
          (SCOREP_User_CartesianTopologyHandle,), topologyHandle)
end

function SCOREP_User_EnableRecording()
    ccall((:SCOREP_User_EnableRecording, libscorep_adapter_user_event), Cvoid, ())
end

function SCOREP_User_DisableRecording()
    ccall((:SCOREP_User_DisableRecording, libscorep_adapter_user_event), Cvoid, ())
end

function SCOREP_User_RecordingEnabled()
    ccall((:SCOREP_User_RecordingEnabled, libscorep_adapter_user_event), Bool, ())
end

const SCOREP_LIBWRAP_VERSION = 1

const SCOREP_LIBWRAP_NULL = C_NULL

const SCOREP_METRIC_PLUGIN_VERSION = 1

# Skipping MacroDefinition: EXTERN extern

const SCOREP_INVALID_PID = 0

const SCOREP_INVALID_TID = 0

# const SCOREP_INVALID_EXIT_STATUS = int64_t(~(~(uint64_t(Cuint(0))) >> 1))
# const SCOREP_INVALID_EXIT_STATUS = Clong(~(~(Culong(Cuint(0))) >> 1)) # throws InexactError
const SCOREP_INVALID_EXIT_STATUS = -9223372036854775808 # taken from compiled C

const SCOREP_INVALID_LINE_NO = 0

const SCOREP_MOVABLE_NULL = 0

const SCOREP_INVALID_SOURCE_FILE = SCOREP_MOVABLE_NULL

const SCOREP_INVALID_METRIC = SCOREP_MOVABLE_NULL

const SCOREP_INVALID_SAMPLING_SET = SCOREP_MOVABLE_NULL

const SCOREP_INVALID_REGION = SCOREP_MOVABLE_NULL

const SCOREP_INVALID_PARADIGM = SCOREP_MOVABLE_NULL

const SCOREP_IO_UNKNOWN_OFFSET = typemax(UInt64) #UINT64_MAX

# Skipping MacroDefinition: SCOREP_LOCATION_TYPE ( NAME , name_string ) SCOREP_LOCATION_TYPE_ ## NAME ,

# const SCOREP_LOCATION_TYPES = ((((SCOREP_LOCATION_TYPE(CPU_THREAD, "CPU thread"))(SCOREP_LOCATION_TYPE))(GPU, "GPU"))(SCOREP_LOCATION_TYPE))(METRIC, "metric location")

const SCOREP_ALL_TARGET_RANKS = -1

const SCOREP_INVALID_ROOT_RANK = -1

# Skipping MacroDefinition: SCOREP_PARADIGM_CLASS ( NAME , name , OTF2_NAME ) SCOREP_PARADIGM_CLASS_ ## NAME ,

# const SCOREP_PARADIGM_CLASSES = ((((((SCOREP_PARADIGM_CLASS(MPP, "multi-process", PROCESS))(SCOREP_PARADIGM_CLASS))(THREAD_FORK_JOIN, "fork/join", THREAD_FORK_JOIN))(SCOREP_PARADIGM_CLASS))(THREAD_CREATE_WAIT, "create/wait", THREAD_CREATE_WAIT))(SCOREP_PARADIGM_CLASS))(ACCELERATOR, "accelerator", ACCELERATOR)

# Skipping MacroDefinition: SCOREP_PARADIGM ( NAME , name_str , OTF2_NAME ) SCOREP_PARADIGM_ ## NAME ,

# const SCOREP_PARADIGMS = ((((((((((((((((((((((((((((((SCOREP_PARADIGM(MEASUREMENT, "measurement", MEASUREMENT_SYSTEM))(SCOREP_PARADIGM))(USER, "user", USER))(SCOREP_PARADIGM))(COMPILER, "compiler", COMPILER))(SCOREP_PARADIGM))(SAMPLING, "sampling", SAMPLING))(SCOREP_PARADIGM))(MEMORY, "memory", NONE))(SCOREP_PARADIGM))(LIBWRAP, "libwrap", NONE))(SCOREP_PARADIGM))(MPI, "mpi", MPI))(SCOREP_PARADIGM))(SHMEM, "shmem", SHMEM))(SCOREP_PARADIGM))(OPENMP, "openmp", OPENMP))(SCOREP_PARADIGM))(PTHREAD, "pthread", PTHREAD))(SCOREP_PARADIGM))(ORPHAN_THREAD, "orphan thread", UNKNOWN))(SCOREP_PARADIGM))(CUDA, "cuda", CUDA))(SCOREP_PARADIGM))(OPENCL, "opencl", OPENCL))(SCOREP_PARADIGM))(OPENACC, "openacc", OPENACC))(SCOREP_PARADIGM))(IO, "io", NONE))(SCOREP_PARADIGM))(KOKKOS, "kokkos", KOKKOS)

# Skipping MacroDefinition: SCOREP_REGION_TYPE ( NAME , name_str ) SCOREP_REGION_ ## NAME ,

# const SCOREP_REGION_TYPES = ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((SCOREP_REGION_TYPE(COLL_ONE2ALL, "one2all"))(SCOREP_REGION_TYPE))(COLL_ALL2ONE, "all2one"))(SCOREP_REGION_TYPE))(COLL_ALL2ALL, "all2all"))(SCOREP_REGION_TYPE))(COLL_OTHER, "other collective"))(SCOREP_REGION_TYPE))(POINT2POINT, "point2point"))(SCOREP_REGION_TYPE))(PARALLEL, "parallel"))(SCOREP_REGION_TYPE))(SECTIONS, "sections"))(SCOREP_REGION_TYPE))(SECTION, "section"))(SCOREP_REGION_TYPE))(WORKSHARE, "workshare"))(SCOREP_REGION_TYPE))(SINGLE, "single"))(SCOREP_REGION_TYPE))(MASTER, "master"))(SCOREP_REGION_TYPE))(CRITICAL, "critical"))(SCOREP_REGION_TYPE))(ATOMIC, "atomic"))(SCOREP_REGION_TYPE))(BARRIER, "barrier"))(SCOREP_REGION_TYPE))(IMPLICIT_BARRIER, "implicit barrier"))(SCOREP_REGION_TYPE))(FLUSH, "flush"))(SCOREP_REGION_TYPE))(CRITICAL_SBLOCK, "critical sblock"))(SCOREP_REGION_TYPE))(SINGLE_SBLOCK, "single sblock"))(SCOREP_REGION_TYPE))(WRAPPER, "wrapper"))(SCOREP_REGION_TYPE))(TASK, "task"))(SCOREP_REGION_TYPE))(TASK_UNTIED, "untied task"))(SCOREP_REGION_TYPE))(TASK_WAIT, "taskwait"))(SCOREP_REGION_TYPE))(TASK_CREATE, "task create"))(SCOREP_REGION_TYPE))(ORDERED, "ordered"))(SCOREP_REGION_TYPE))(ORDERED_SBLOCK, "ordered sblock"))(SCOREP_REGION_TYPE))(ARTIFICIAL, "artificial"))(SCOREP_REGION_TYPE))(RMA, "rma"))(SCOREP_REGION_TYPE))(THREAD_CREATE, "thread create"))(SCOREP_REGION_TYPE))(THREAD_WAIT, "thread wait"))(SCOREP_REGION_TYPE))(ALLOCATE, "allocate"))(SCOREP_REGION_TYPE))(DEALLOCATE, "deallocate"))(SCOREP_REGION_TYPE))(REALLOCATE, "reallocate"))(SCOREP_REGION_TYPE))(FILE_IO, "file_io"))(SCOREP_REGION_TYPE))(FILE_IO_METADATA, "file_io metadata")

# Skipping MacroDefinition: SCOREP_RMA_SYNC_TYPE ( upper , lower , name ) SCOREP_RMA_SYNC_TYPE_ ## upper ,

# const SCOREP_RMA_SYNC_TYPES = ((((SCOREP_RMA_SYNC_TYPE(MEMORY, memory, "memory"))(SCOREP_RMA_SYNC_TYPE))(NOTIFY_IN, notify_in, "notify in"))(SCOREP_RMA_SYNC_TYPE))(NOTIFY_OUT, notify_out, "notify out")

# Skipping MacroDefinition: SCOREP_RMA_SYNC_LEVEL ( upper , lower , name , value ) SCOREP_RMA_SYNC_LEVEL_ ## upper = value ,

# const SCOREP_RMA_SYNC_LEVELS = ((((SCOREP_RMA_SYNC_LEVEL(NONE, none, "none", 0))(SCOREP_RMA_SYNC_LEVEL))(PROCESS, process, "process", 1 << 0))(SCOREP_RMA_SYNC_LEVEL))(MEMORY, memory, "memory", 1 << 1)

# Skipping MacroDefinition: SCOREP_RMA_ATOMIC_TYPE ( upper , lower , name ) SCOREP_RMA_ATOMIC_TYPE_ ## upper ,

# const SCOREP_RMA_ATOMIC_TYPES = ((((((((((((((((SCOREP_RMA_ATOMIC_TYPE(ACCUMULATE, accumulate, "accumulate"))(SCOREP_RMA_ATOMIC_TYPE))(INCREMENT, increment, "increment"))(SCOREP_RMA_ATOMIC_TYPE))(TEST_AND_SET, test_and_set, "test and set"))(SCOREP_RMA_ATOMIC_TYPE))(COMPARE_AND_SWAP, compare_and_swap, "compare and swap"))(SCOREP_RMA_ATOMIC_TYPE))(SWAP, swap, "swap"))(SCOREP_RMA_ATOMIC_TYPE))(FETCH_AND_ADD, fetch_and_add, "fetch and add"))(SCOREP_RMA_ATOMIC_TYPE))(FETCH_AND_INCREMENT, fetch_and_increment, "fetch and increment"))(SCOREP_RMA_ATOMIC_TYPE))(ADD, add, "add"))(SCOREP_RMA_ATOMIC_TYPE))(FETCH_AND_ACCUMULATE, fetch_and_op, "fetch and accumulate with user-specified operator")

# Skipping MacroDefinition: SCOREP_IO_PARADIGM ( upper , lower , id_name ) SCOREP_IO_PARADIGM_ ## upper ,

# const SCOREP_IO_PARADIGMS = ((((SCOREP_IO_PARADIGM(POSIX, posix, "POSIX"))(SCOREP_IO_PARADIGM))(ISOC, isoc, "ISOC"))(SCOREP_IO_PARADIGM))(MPI, mpi, "MPI-IO")

# const SCOREP_NUM_IO_PARADIGMS = SCOREP_INVALID_IO_PARADIGM_TYPE

# Skipping MacroDefinition: SCOREP_IPC_DATATYPE ( datatype ) SCOREP_IPC_ ## datatype ,

# const SCOREP_IPC_DATATYPES = ((((((((((((((((((SCOREP_IPC_DATATYPE(BYTE))(SCOREP_IPC_DATATYPE))(CHAR))(SCOREP_IPC_DATATYPE))(UNSIGNED_CHAR))(SCOREP_IPC_DATATYPE))(INT))(SCOREP_IPC_DATATYPE))(UNSIGNED))(SCOREP_IPC_DATATYPE))(INT32_T))(SCOREP_IPC_DATATYPE))(UINT32_T))(SCOREP_IPC_DATATYPE))(INT64_T))(SCOREP_IPC_DATATYPE))(UINT64_T))(SCOREP_IPC_DATATYPE))(DOUBLE)

# Skipping MacroDefinition: SCOREP_IPC_OPERATION ( op ) SCOREP_IPC_ ## op ,

# const SCOREP_IPC_OPERATIONS = ((((((((SCOREP_IPC_OPERATION(BAND))(SCOREP_IPC_OPERATION))(BOR))(SCOREP_IPC_OPERATION))(MIN))(SCOREP_IPC_OPERATION))(MAX))(SCOREP_IPC_OPERATION))(SUM)

const SCOREP_SUBSTRATE_PLUGIN_VERSION = 3

const SCOREP_SUBSTRATE_PLUGIN_UNDEFINED_MANAGEMENT_FUNCTIONS = 99

const SCOREP_TAU_INVALID_LINE_NO = SCOREP_INVALID_LINE_NO

const SCOREP_TAU_INVALID_SOURCE_FILE = SCOREP_INVALID_SOURCE_FILE

const SCOREP_TAU_ADAPTER_USER = SCOREP_TAU_PARADIGM_USER

const SCOREP_TAU_ADAPTER_COMPILER = SCOREP_TAU_PARADIGM_COMPILER

const SCOREP_TAU_ADAPTER_MPI = SCOREP_TAU_PARADIGM_MPI

const SCOREP_TAU_ADAPTER_POMP = SCOREP_TAU_PARADIGM_OPENMP

const SCOREP_TAU_ADAPTER_PTHREAD = SCOREP_TAU_PARADIGM_THREAD_CREATE_WAIT

const SCOREP_TAU_ADAPTER_SHMEM = SCOREP_TAU_PARADIGM_SHMEM

const SCOREP_TAU_INVALID_ADAPTER_TYPE = SCOREP_TAU_INVALID_PARADIGM_TYPE

const SCOREP_TAU_REGION_MPI_COLL_BARRIER = SCOREP_TAU_REGION_COLL_BARRIER

const SCOREP_TAU_REGION_MPI_COLL_ONE2ALL = SCOREP_TAU_REGION_COLL_ONE2ALL

const SCOREP_TAU_REGION_MPI_COLL_ALL2ONE = SCOREP_TAU_REGION_COLL_ALL2ONE

const SCOREP_TAU_REGION_MPI_COLL_ALL2ALL = SCOREP_TAU_REGION_COLL_ALL2ALL

const SCOREP_TAU_REGION_MPI_COLL_OTHER = SCOREP_TAU_REGION_COLL_OTHER

const SCOREP_TAU_REGION_OMP_PARALLEL = SCOREP_TAU_REGION_PARALLEL

const SCOREP_TAU_REGION_OMP_LOOP = SCOREP_TAU_REGION_LOOP

const SCOREP_TAU_REGION_OMP_SECTIONS = SCOREP_TAU_REGION_SECTIONS

const SCOREP_TAU_REGION_OMP_SECTION = SCOREP_TAU_REGION_SECTION

const SCOREP_TAU_REGION_OMP_WORKSHARE = SCOREP_TAU_REGION_WORKSHARE

const SCOREP_TAU_REGION_OMP_SINGLE = SCOREP_TAU_REGION_SINGLE

const SCOREP_TAU_REGION_OMP_MASTER = SCOREP_TAU_REGION_MASTER

const SCOREP_TAU_REGION_OMP_CRITICAL = SCOREP_TAU_REGION_CRITICAL

const SCOREP_TAU_REGION_OMP_ATOMIC = SCOREP_TAU_REGION_ATOMIC

const SCOREP_TAU_REGION_OMP_BARRIER = SCOREP_TAU_REGION_BARRIER

const SCOREP_TAU_REGION_OMP_IMPLICIT_BARRIER = SCOREP_TAU_REGION_IMPLICIT_BARRIER

const SCOREP_TAU_REGION_OMP_FLUSH = SCOREP_TAU_REGION_FLUSH

const SCOREP_TAU_REGION_OMP_CRITICAL_SBLOCK = SCOREP_TAU_REGION_CRITICAL_SBLOCK

const SCOREP_TAU_REGION_OMP_SINGLE_SBLOCK = SCOREP_TAU_REGION_SINGLE_SBLOCK

const SCOREP_TAU_REGION_OMP_WRAPPER = SCOREP_TAU_REGION_WRAPPER

const SCOREP_Tau_RegionHandle = Culong # uint64_t

const SCOREP_Tau_SourceFileHandle = SCOREP_SourceFileHandle

const SCOREP_Tau_MetricHandle = SCOREP_SamplingSetHandle

const SCOREP_TAU_INIT_METRIC_HANDLE = SCOREP_INVALID_SAMPLING_SET

const SCOREP_Tau_ParamHandle = SCOREP_User_ParameterHandle

const SCOREP_USER_INVALID_PARAMETER = -1

const SCOREP_TAU_INIT_PARAM_HANDLE = SCOREP_USER_INVALID_PARAMETER

# Skipping MacroDefinition: SCOREP_USER_FUNCTION_NAME __func__

const SCOREP_USER_INVALID_REGION = C_NULL

const SCOREP_USER_INVALID_TOPOLOGY = -1

const SCOREP_USER_INVALID_CARTESIAN_TOPOLOGY = C_NULL

const SCOREP_USER_REGION_TYPE_COMMON = 0

const SCOREP_USER_REGION_TYPE_FUNCTION = 1

const SCOREP_USER_REGION_TYPE_LOOP = 2

const SCOREP_USER_REGION_TYPE_DYNAMIC = 4

const SCOREP_USER_REGION_TYPE_PHASE = 8

const SCOREP_USER_METRIC_TYPE_INT64 = 0

const SCOREP_USER_METRIC_TYPE_UINT64 = 1

const SCOREP_USER_METRIC_TYPE_DOUBLE = 2

const SCOREP_USER_METRIC_CONTEXT_GLOBAL = 0

const SCOREP_USER_METRIC_CONTEXT_CALLPATH = 1

# exports
const PREFIXES = ["SCOREP_User"]
for name in names(@__MODULE__; all = true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
