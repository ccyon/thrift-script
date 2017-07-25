namespace py accesspointoverride

struct Coordinate {
    1: required double latitude;
    2: required double longitude;
}

/** Defines the type of the access point */
enum AccessPointType {
    PICKUP = 0;
    DROPOFF = 1;
}

/** Defines the level of the access point */
enum AccessPointLevel {
    GLOBAL = 0;
    PERSONAL = 1;
}

/** Represents a navigable access point */
struct AccessPoint {
    /** Optional stable, unique id representing this access point */
    1: optional string id;

    /** Precise coordinate of the access point */
    2: optional Coordinate coordinate;

    /** Identifies what categories this access point belongs to */
    3: optional set<AccessPointType> types;

    /** Human readable label for this access point */
    4: optional string label;

    /** Identifies which level this access point belongs to */
    5: optional AccessPointLevel level;
}

/** Convenience struct for encapsulating AccessPoints */
struct AccessPoints {
    1: optional list<AccessPoint> accessPoints;
}

/** Represents a time interval */
struct TimeInterval {
    /** Start timestamp of the interval */
    1: optional i64 (js.type = "Long") startTimestamp

    /** end timestamp of the interval */
    2: optional i64 (js.type = "Long") endTimestamp
}

/** Represents an access point override */
struct AccessPointOverride {
    /** Optional unique id representing this access point override */
    1: optional string id;

    /** Precise timestamp of this override */
    2: optional TimeInterval timeInterval;

    /** Identifies what categories (pickup/dropoff) this override will work */
    3: optional AccessPointType type;

    /** access points to replace the usual ones */
    4: optional AccessPoints accessPoints;
}

/** Convenience struct for encapsulating AccessPointOverride */
struct AccessPointOverrides {
    1: optional list<AccessPointOverride> accessPointsOverrides;
}

struct AccessPointOverrideRequest {
    1: optional string provider
    2: optional string id
    3: optional string locale
    4: optional AccessPointOverrides overrides
}
