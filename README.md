# bitbox_flutter (experimental)

Flutter bindings for the BitBox02 hardware wallet using Rust and flutter_rust_bridge.

## Features

- Connect to BitBox02 hardware wallet on Android
- Perform device handshake
- Get root fingerprint
- Full Rust-powered crypto operations

## Prerequisites

Use Flutter 3.50.0 (Dart 3.14) or newer and the Rust 1.100.0 toolchain pinned in `rust/rust-toolchain.toml`. Android consumers also need the Android SDK and NDK configured for Flutter.

Install the pinned FRB code generator when changing the Rust API:

```bash
make install-deps
```

## Setup

1. Clone the repository and resolve dependencies:

```bash
fvm flutter pub get --enforce-lockfile
```

2. When changing the Rust API, regenerate bindings through the package wrapper:

```bash
make codegen
```

The wrapper requires FRB codegen 2.13.0 and restores the default Native Assets loader after generation. See [tool/README.md](tool/README.md).

3. Verify the default native library loads:

```bash
fvm flutter test test/native_asset_loader_test.dart
```

The `hook/build.dart` Native Assets hook compiles the Rust crate with the locked dependencies and supplies the code asset to Flutter. Consuming applications build it automatically with their normal Flutter build commands; no separate `cargo ndk` build or manual `jniLibs` copying is required.

## Usage

```dart
import 'package:bitbox_flutter/bitbox_flutter.dart';

// Initialize
await BitBoxFlutterApi.initialize();

// Scan for devices
final devices = await BitBoxFlutterApi.scanDevices();

// Request USB permission
await BitBoxFlutterApi.requestPermission(devices.first.deviceName);

// Open device (and start coordinator)
await BitBoxFlutterApi.openDevice(
  devices.first.deviceName,
  devices.first.serialNumber,
);

// Start pairing (returns pairing code if needed)
final pairingCode = await BitBoxFlutterApi.startPairing(
  devices.first.serialNumber,
);
// Optionally display pairingCode to the user if not null

// Confirm pairing on the device
final confirmed = await BitBoxFlutterApi.confirmPairing(
  devices.first.serialNumber,
);

// Get root fingerprint
final fingerprint = await BitBoxFlutterApi.getRootFingerprint(devices.first.serialNumber);
```

### Wallet policies

The wallet-policy APIs support native and nested SegWit multisig, native SegWit
Miniscript, and Taproot descriptors. Every signature key must be an extended
public key with exactly two unhardened multipath branches; the first branch is
used for receive addresses and the second for change addresses. The descriptor
network must match the selected device network. Native and nested SegWit
multisig policies require the standard `<0;1>` branch pair. Other wallet-policy
descriptors may use one or more custom disjoint pairs in the `/<M;N>/*` form.
Derivation after the branch is not supported. Exactly one account xpub in the
policy may belong to the connected BitBox, including a Taproot internal key.
Miniscript hashlocks are not supported by the BitBox firmware.

For example:

```text
wsh(sortedmulti(2,[f00dbabe/48'/0'/0'/2']xpub.../<0;1>/*,[deadbeef/48'/0'/0'/2']xpub.../<0;1>/*))
```

Use `isWalletPolicyRegistered` and `registerWalletPolicy` before
`verifyWalletAddress` or `signWalletPsbt`. Unsupported descriptors and firmware
versions are rejected instead of being approximated.

## Building a Consumer

Build the consuming Flutter application normally. For example, from an Android application's root:

```bash
fvm flutter build apk --debug --target-platform android-arm64
```

Flutter invokes the package's Native Assets hook to build and bundle the Rust library for the selected target.

## License

Apache-2.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
