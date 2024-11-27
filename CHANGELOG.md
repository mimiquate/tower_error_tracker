# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.4] - 2024-11-27

### Added

- Includes `Tower.Event.metadata` in reported ErrorTracker occurrence context

## [0.3.3] - 2024-11-19

### Fixed

- Properly format reported throw values

### Changed

- Updates `tower` dependency from `{:tower, "~> 0.6.0"}` to `{:tower, "~> 0.7.1"}`.

## [0.3.2] - 2024-10-24

### Fixed

- Properly report common `:gen_server` abnormal exits

## [0.3.1] - 2024-10-21

### Added

- Allow `error_tracker` 0.4+

## [0.3.0] - 2024-10-04

### Added

- Can include less verbose `TowerErrorTracker` as reporter instead of `TowerErrorTracker.Reporter`.

### Changed

- No longer necessary to call `Tower.attach()` in your application `start`. It is done
automatically.

- Updates `tower` dependency from `{:tower, "~> 0.5.0"}` to `{:tower, "~> 0.6.0"}`.

## [0.2.0] - 2024-09-27

### Added

- Also reports uncaught `throw`s
- Also reports abnomarl `exit`s
- Includes request `method` and `url` as error context, if available

## [0.1.0] - 2024-09-26

- Reports exceptions

[0.3.4]: https://github.com/mimiquate/tower_error_tracker/compare/v0.3.3...v0.3.4/
[0.3.3]: https://github.com/mimiquate/tower_error_tracker/compare/v0.3.2...v0.3.3/
[0.3.2]: https://github.com/mimiquate/tower_error_tracker/compare/v0.3.1...v0.3.2/
[0.3.1]: https://github.com/mimiquate/tower_error_tracker/compare/v0.3.0...v0.3.1/
[0.3.0]: https://github.com/mimiquate/tower_error_tracker/compare/v0.2.0...v0.3.0/
[0.2.0]: https://github.com/mimiquate/tower_error_tracker/compare/v0.1.0...v0.2.0/
