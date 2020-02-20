# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2020-02-19

### Changed
- Removed Alamo Fire Dependency
- Updated unit test cases

## [2.0.0] - 2019-11-08

### Added
- Keychain support for PRID and Device Token
- Added more unit test cases
- Added `EMSAPI` object to handle API calls

### Changed
- Followed coding guidelines which changed some of the capitalization of the methods
- Removed unnecessary throws on some methods. Errors will now be passed through completion closures
- Changed `StringCompletionType` type alias to `(_ result: String?, _ error: Error?) -> Void`
- Renamed `checkOSNotificationSettings` to `updateEMSSubscriptionIfNeeded`

### Fixed
- Fixed unnecessary logging even when the `watcherDelegate` is empty

## [1.4.0] - 2019-11-08

### Changed
- Update Swift version to 5.0
- Set Minimum deployment target to iOS 10.0
- Set `Alamofire` pod version dependency to 4.9.1

[Unreleased]: https://github.com/Marketing-Suite/ios-sdk/compare/release-1.0.0...HEAD
[2.0.0]: https://github.com/Marketing-Suite/ios-sdk/releases/tag/v2.0.0
[1.4.0]: https://github.com/Marketing-Suite/ios-sdk/releases/tag/v1.4.0
