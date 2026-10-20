# Changelog

All notable changes to this project will be documented in this file.


## [1.1.1] - 2026-10-20

### Added
- Added a new station: BFM 89.9, a Malaysian business focused station in English

### Fixed
- Updated URLs of Jazz de Ville due to unavailability of old ones


## [1.1.0] - 2026-07-26

### Added
- Function that retrieves XML from radiko and displays information according to time

### Changed
- Removed station name from `nowInfo`
- Changed interval of `updateStatus()` and `getVolume()`
- Changed some DOM element retrieval process to global variables in JS file

### Fixed
- Fixed forgetting LED blinking settings to rc.local


## [1.0.1] - 2026-06-14

### Added
- NHK-AM station icon

### Changed
- Updated `playRadiko()` arguments from `id` to `name`, `img`, `id`
- Changed NHK stream type from `ordinary` to `radiko`

### Fixed
- Fixed an issue where NHK stream could not be received due to service deprecation

### Removed
- NHK-R1-Osaka station icon


## [1.0.0] - 2026-06-09

Initial release
- Releasing this system as radiko-box
- Implemented Web UI and station select