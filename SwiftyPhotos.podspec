Pod::Spec.new do |s|

  s.name         = "SwiftyPhotos"
  s.version      = "0.4.0"
  s.summary      = "***Useful tool for PhotoKit framework*** to boost your productivity."

  s.description  = <<-DESC
                    ***Useful tool for PhotoKit framework*** to boost your productivity.
                    Swift 3.0.
                   DESC

  s.homepage     = "https://github.com/icetime17/SwiftyPhotos"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "Chris Hu" => "icetime017@gmail.com" }

  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/icetime17/SwiftyPhotos.git", :tag => s.version }

  s.source_files  = "Sources/**/*.swift"

  s.requires_arc = true

end
