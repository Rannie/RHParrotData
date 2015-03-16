Pod::Spec.new do |s|
  s.name         = "RHParrotData"
  s.version      = "0.1.5"
  s.summary      = "CoreData stack management and quick query language library."
  s.homepage     = "https://github.com/Rannie/RHParrotData"
  s.license      = "MIT"
  s.author    	 = "Hanran Liu"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/Rannie/RHParrotData.git", :tag => s.version }
  s.source_files = "RHParrotData", "RHParrotData/*.{h,m}"
  s.framework    = "CoreData"
  s.requires_arc = true
end
