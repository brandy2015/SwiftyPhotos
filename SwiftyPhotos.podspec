Pod::Spec.new do |s|

  s.name         = "SwiftyLocation"
  s.version      = "0.1.0"
  s.summary      = "***Useful tool for CoreLocation*** to boost your productivity."

  s.description  = <<-DESC
                    ***Useful tool for CoreLocation*** to boost your productivity.
                    Swift 3.0.
                   DESC

  s.homepage     = "https://github.com/icetime17/SwiftyLocation"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "Chris Hu" => "icetime017@gmail.com" }

  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/icetime17/SwiftyLocation.git", :tag => s.version }

  s.source_files  = "Sources/SwiftyLocation.swift"

  s.requires_arc = true

end
