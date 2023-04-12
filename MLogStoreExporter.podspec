Pod::Spec.new do |spec|

  spec.name         = "MLogStoreExporter"
  spec.version      = "1.0.0"
  spec.summary      = "Export logs from Apple Unified Logging System store"

  spec.homepage     = "https://gitlab.sca.im/iOS/alphahomswiftykit"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Wen Yongyang" => "raeyeung.mon@gmail.com" }
  spec.social_media_url   = "https://github.com/monsoir"

  spec.swift_version = "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/monsoir/MLogStoreExporter.git", :branch => "master", :tag => "#{spec.version}" }

  spec.source_files  = ["MLogStoreExporter/MLogStoreExporter.h", "MLogStoreExporter/Source/**/*.swift"]

  spec.requires_arc = true

end
