namespace java com.uber.michelangelo.server.generated

//include "../common/errors.thrift"

struct MLException {
  // next id: 4
	// Indication whether retry will fix the error
	1: optional bool shouldRetry
	// Error reason
	2: optional string message
	// Usually the error stack
	3: optional string cause
}

exception PlatformException {
	1: optional MLException info
}

exception UserException {
	1: optional MLException info
}

enum EncodingType {
    ARROW = 0,
    JSON = 1,
    REQ_THRIFT = 2,
    RES_THRIFT = 3,
}

struct ModelStatus {
  // next id: 7
  1: optional string projectId,
  2: optional string modelId,
  3: optional bool loaded,
  4: optional i64 (js.type = "Date") lastUsedTimeStamp,
  5: optional i64 (js.type = "Date") version,
  6: optional string virtualShard,
  7: optional string physicalShard,
}

struct LabelStatus {
  // next id: 5
  1: optional string projectId,
  2: optional string labelName,
  3: optional list<string> modelId,
  4: optional i64 (js.type = "Date") lastUsedTimeStamp,
}

struct Status {
  // next id: 6
  1: optional list<LabelStatus> labelStatus,
  2: optional list<ModelStatus> modelStatus,
  3: optional list<string> virtualShards,
  4: optional HealthStatus healthStatus,
  5: optional HostInfo hostInfo,
}

struct HostInfo {
  // next id: 6
  1: optional string hostPort,
  2: optional string serviceName,
  3: optional string environment,
  4: optional string deploymentGroup,
  // instanceId is the full identifier of an instance in uDeploy: sjc1-prod01:michelangelo-prediction-group35:production:8 
  5: optional string instanceId,
}

struct ValueItem {
  // next id: 6
  1: optional string key,
  // Only one of stringValue, doubleValue, binaryValue should be used at a time
  2: optional string stringValue,
  3: optional double doubleValue,
  4: optional binary binaryValue,
}

struct PredictionRequest {
  // next id: 10
  1: optional string projectId,
  // Model id can be either raw model id or model alias
  2: optional string modelId,
  // note: only one of basisFeatures or binaryBasisFeatures should be used at a time
  3: optional list<ValueItem> basisFeatures,
  4: optional string label,
  5: optional string joinKey,
  6: optional bool returnTransformedFeatures,
  7: optional bool testTraffic,
  // note: binary format features (currently, only supported by containerized models)
  8: optional binary binaryBasisFeatures,
  9: optional EncodingType binaryBasisFeaturesEncodingType,
  // note: when true the request is always logged 
 10: optional bool sampleRequest,
}

struct Observation {
  // next id: 3
  1: optional list<ValueItem> basisFeatures,
  2: optional string joinKey,
}

struct BatchPredictionRequest {
  // next id: 7
  1: optional string projectId,
  2: optional string modelId,
  3: optional list<Observation> observations,
  4: optional string label,
  5: optional bool returnTransformedFeatures,
  6: optional bool testTraffic,
  // note: when true all the requests in the batch are logged 
  7: optional bool sampleRequest,
}

struct PredictionResponse {
  // next id: 9
  1: optional list<ValueItem> transformedFeatures,
  2: optional list<ValueItem> result,
  3: optional ValueItem prediction,

  // The categorical feature in transformed features with unknown categorical value
  4: optional list<string> categoricalFeaturesWithUnkownValues,
  5: optional list<ValueItem> publishResult,
  6: optional bool holdback,

  // note: binary format features (currently, only supported by containerized models)
  7: optional binary binaryPredictionResult,
  8: optional EncodingType binaryPredictionResultEncodingType,
  9: optional string modelId,
}

exception PredictionError {
  1: optional string errorMessage,
//  2: optional errors.ErrorCode code,
}

struct PredictionResult {
  // next id: 3
  1: optional PredictionError error,
  2: optional PredictionResponse response,
  3: optional string projectId
  4: optional string modelId
}

struct MultiModelRequest {
    1: optional list<PredictionRequest> requests
}

struct MultiModelResult {
    1: optional list<PredictionResult> responses
}

service PredictionService {
  PredictionResponse predict(
    1: PredictionRequest request,
  ) throws (
    1: PredictionError failed,
  ) (cerberus.enabled = "true", cerberus.type = "read")
  list<PredictionResult> batchPredict(
  	1: BatchPredictionRequest request,
  ) throws (
	1: PlatformException platformException
	2: UserException userException
  ) (cerberus.enabled = "true", cerberus.type = "read")
  MultiModelResult multiModelPredict(
    1: MultiModelRequest multiModelRequest
  ) throws (
    1: PlatformException platformException
    2: UserException userException
  ) (cerberus.enabled = "true", cerberus.type = "read")
  list<ModelStatus> getModels(
    1: optional string projectId,
    2: optional string modelId,
  ) (cerberus.enabled = "true", cerberus.type = "read")

  Status getStatus(
    1: optional string projectId
  ) (cerberus.enabled = "true", cerberus.type = "read")

  // Returns the status for all models on a prediction host
  Status getStatusForAllModels(
  ) (cerberus.enabled = "true", cerberus.type = "read")
}

// github.com/uber/tchannel/meta.thrift doesn't define a java namespace, and this causes downstream java consumers
// of this thrift file to totally break. since they can't compile the generated code without hacking in a namespace
// manually. Instead, we duplicate the structs we need. The generated bytes should be backwards compatible.

// The HealthState provides additional information when the
// health endpoint returns !ok.
enum HealthState {
    REFUSING = 0,
    ACCEPTING = 1,
    STOPPING = 2,
    STOPPED = 3,
}

// The HealthRequestType is the type of health check, as a process may want to
// return that it's running, but not ready for traffic.
enum HealthRequestType {
    // PROCESS indicates that the health check is for checking that
    // the process is up. Handlers should always return "ok".
    PROCESS = 0,

    // TRAFFIC indicates that the health check is for checking whether
    // the process wants to receive traffic. The process may want to reject
    // traffic due to warmup, or before shutdown to avoid in-flight requests
    // when the process exits.
    TRAFFIC = 1,
}

struct HealthRequest {
    1: optional HealthRequestType type
}

struct HealthStatus {
    1: required bool ok
    2: optional string message
    3: optional HealthState state
}

typedef string filename

struct ThriftIDLs {
    // map: filename -> contents
    1: required map<filename, string> idls
    // the entry IDL that imports others
    2: required filename entryPoint
}

struct VersionInfo {
  // short string naming the implementation language
  1: required string language
  // language-specific version string representing runtime or build chain
  2: required string language_version
  // semver version indicating the version of the tchannel library
  3: required string version
}

service Meta {
    // All arguments are optional. The default is a PROCESS health request.
    HealthStatus health(1: HealthRequest hr)

    ThriftIDLs thriftIDL()
    VersionInfo versionInfo()
}
