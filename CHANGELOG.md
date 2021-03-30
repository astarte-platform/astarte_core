# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Extend interface mappings charset to support name prefixed with underscore
- Introspection triggers are part of device triggers. Expose an API closer to other triggers.

### Added
- Add delivery policies to triggers.

## [1.0.3] - 2022-07-04

## [1.0.2] - 2022-03-29

## [1.0.1] - 2021-12-16
### Added
- Handle array values when decoding simple events

### Fixed
- Don't treat structs as object aggregations when decoding simple events

## [1.0.0] - 2021-06-28

## [1.0.0-rc.0] - 2021-05-05

## [1.0.0-beta.2] - 2021-03-23
### Changed
- Update dependencies and Elixir version to 1.11
- If `database_retention_policy` is set to `:no_ttl`, `database_retention_ttl` must not be set. (See #51)

### Fixed
- Correctly handle SimpleEvents JSON encoding even when they contain an object aggregation with a
  binaryblob value.

## [1.0.0-beta.1] - 2021-02-11
### Fixed
- Return an error instead of crashing when the endpoint is not present within a mapping.

## [1.0.0-alpha.1] - 2020-06-18
### Added
- Add `exchange` to `AMQPTriggerTarget` proto. This will allow to send events to any user defined
  AMQP exchange (see [#351](https://github.com/astarte-platform/astarte/issues/351)).
- Add additional options to `AMQPTriggerTarget` such as `priority`, `expiration` and `persistent`.
- Add support for device-specific and group-specific triggers.
- Add `DeviceErrorEvent` to `SimpleEvents`, allowing to react to a device error.

### Changed
- It is now possible to omit the `device_id` in a `device_trigger`. This is equivalent to passing
  `*` as `device_id`. The old behaviour is still supported.

## [0.11.4] - 2021-01-25
### Fixed
- Correctly handle binaryblob value deserialization in events.

## [0.11.3] - 2020-09-24

## [0.11.2] - 2020-08-14
### Changed
- Test against Elixir 1.8.2.

## [0.11.1] - 2020-05-18

## [0.11.0] - 2020-04-06

## [0.11.0-rc.1] - 2020-03-25

## [0.11.0-rc.0] - 2020-02-26
### Changed
- Add support for aggregated server owned interfaces.

### Fixed
- Correctly handle parametric endpoints regardless of the ordering, so that overlapping endpoints are always refused. (See #2)

## [0.11.0-beta.2] - 2020-01-24
### Changed
- Restrict the use of `*` as `interface_name` only to `incoming_data` data triggers.
- Allow hyphens in `interface_name`. Both the top level domain and the last domain component
  must not contain hyphens. ([#7](https://github.com/astarte-platform/astarte_core/issues/7))

### Fixed
- Handle empty `bson_value` in `Triggers.SimpleEvents.Encoder`, avoiding crashes when an empty bson
  value is sent as event (e.g. unset).

## [0.11.0-beta.1] - 2019-12-24
### Changed
- `astarte`, `system` and all names starting with `system_` are now reserved realm names.
- Add `database_retention_policy` and `database_retention_ttl` mapping attributes.

## [0.10.2] - 2019-12-09
### Added
- Add timestamp field to SimpleEvent protobuf.

## [0.10.1] - 2019-10-02
### Fixed
- Fix interface validation: object aggregated properties interfaces are not valid.
- Fix interface validation: server owned object aggregated interfaces are not yet supported, hence not valid.

## [0.10.0] - 2019-04-16

## [0.10.0-rc.0] - 2019-04-03
### Fixed
- Fix endpoint placeholder regex used in Mapping.normalize_endpoint.
- Fix overlapping endpoints detection, it was allowing some corner case overlappings.

## [0.10.0-beta.3] - 2018-12-19
### Changed
- Interface name `device` is reserved now.

### Fixed
- Correctly support Bson.Bin struct.
- False positive overlapping endpoints were detected, EndpointsAutomaton now handles them as valid.
- Correctly serialize triggers on the special "*" interface and device.

## [0.10.0-beta.2] - 2018-10-19
### Added
- Add limit to 64K for string and blobs, 1024 items for arrays.
- Add value validation code for any Astarte type.

## [0.10.0-beta.1] - 2018-08-10
### Added
- First Astarte release.
