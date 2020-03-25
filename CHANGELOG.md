# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
