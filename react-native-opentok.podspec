require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-opentok"
  s.version      = package["version"]
  s.summary      = "An OpenTok SDK for react-native"
  s.authors      = {
    'Mike Grabowski' => 'mike@callstack.io',
    'Mike Chudziak' => 'mike.chudziak@callstack.io',
  }

  s.homepage     = "https://github.com/callstack/react-native-video"

  s.license      = "MIT"
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/callstack/react-native-opentok.git", :tag => "#{s.version}" }

  s.source_files  = "*.{h,m}"

  s.pod_target_xcconfig = {
    "MACH_O_TYPE" => "staticlib",
    "FRAMEWORK_SEARCH_PATHS" => "${PODS_ROOT}/OpenTok"
  }

  s.dependency "React"
  # This must be included in the root Podfile rather than here due to issues with use_frameworks.
  # s.dependency "OpenTok"
end
