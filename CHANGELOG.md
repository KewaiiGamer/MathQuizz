# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2018-05-21
### Added
Added messages when a round is scheduled and started
Added translations for English and Portuguese

### Changes
Improved check for flags. Now properly checks for at least one of the required flags.

### Fixed
Fixed RoundStart event not getting Hooked.
Players should not be able to pick up weapons during a Knife Round anymore.

### Dependencies
Added CSGOColors. Included in source code
Added (KewLib)[https://github.com/KewaiiGamer/SM-KewLib]

## [0.0.2] - 2018-05-20
### Fixed
Fixed configs not getting created.

## [0.0.1] - 2018-05-20
### Added
Initial alpha version.
Added command to create a knife round.
Added two convars. One for allowed flags and other for limiting the amount knife rounds of per map.
