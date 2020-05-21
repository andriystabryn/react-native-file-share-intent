
Pod::Spec.new do |s|
  s.name         = "RNFileShareIntent"
  s.version      = "1.6"
  s.summary      = "RNFileShareIntent"
  s.description  = <<-DESC
                  Adds the application to the share intent of the device, so it can be launched from other apps and receive data from them
                   DESC
  s.homepage     = "https://github.com/andriystabryn/react-native-file-share-intent"
  s.license      = "MIT"
  s.author             = { "author" => "andriy.stabryn@agiliway.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/andriystabryn/react-native-file-share-intent.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
end

  
