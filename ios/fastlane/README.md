fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

بناء ورفع إلى TestFlight

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

رفع Metadata فقط (بدون Screenshots أو Binary)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

رفع Screenshots فقط

### ios upload_all

```sh
[bundle exec] fastlane ios upload_all
```

رفع Metadata والـ Screenshots معاً

### ios release

```sh
[bundle exec] fastlane ios release
```

بناء ورفع إلى App Store

### ios status

```sh
[bundle exec] fastlane ios status
```

عرض حالة التطبيق

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
