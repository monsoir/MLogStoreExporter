# MLogStoreExporter

Export logs from Apple Unified Logging System store

## Installation

```rb
pod 'MLogStoreExporter', :git => "https://github.com/monsoir/MLogStoreExporter.git", :tag => 'v1.0.0'
```

## Usage

```swift
import MLogStoreExporter

let exporter = MLogStoreExporter()
let file = try exporter.export(to: <#local path to log file#>, startDate: <#start date#>, overrideIfNeeded: true)
```

- `file` contains the url to dumped file

## Caveats

- It's caller's responsibility to take care of the thread or queue in which the export executes


