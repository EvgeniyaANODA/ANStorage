Pod::Spec.new do |spec|
  spec.name     = 'ANStorage'
  spec.version  = '1.0'
  spec.license  = { :type => 'MIT' }
  spec.homepage = 'https://github.com/anodamobi/ANStorage'
  spec.authors  = { 'Oksana Kovalchuk' => 'oksana@anoda.mobi' }
  spec.summary  = 'Storage component for Table and CollectionView'
  spec.source   = { :git => 'https://github.com/anodamobi/ANStorage.git', :tag => '1.0' }

  spec.source_files = "Core/*.{h,m}", "CoreData/*.{h,m}", "Memory/*.{h,m}", "Utilities/*.{h,m}"

  spec.public_header_files = "Core/*.h", "CoreData/*.h", "Memory/*.h", "Utilities/*.h"

  spec.framework = "Foundation", "UIKit"
  spec.requires_arc = true

  spec.dependency 'ANHelperFunctions', '~> 1.0'
end