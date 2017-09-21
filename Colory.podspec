Pod::Spec.new do |s|

  s.name = "Colory"
  s.version = "0.1.0"
  s.summary = "A `UIControl` for picking color from HSB color palette."
  s.description = <<-DESC
  Straight forward UI and simple API, use target-action to receive color updates.
  DESC
  s.homepage = "https://github.com/crazytonyli/Colory"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license = "MIT"
  s.author = { "Tony Li" => "i@crazytony.li" }
  s.social_media_url = "https://twitter.com/crazytonyli"
  s.platform = :ios, "8.0"
  s.source = { :git => "https://github.com/crazytonyli/Colory.git", :tag => "#{s.version}" }
  s.source_files = "Sources/*.{h,swift}"
  s.public_header_files = "Sources/Colory.h"

end