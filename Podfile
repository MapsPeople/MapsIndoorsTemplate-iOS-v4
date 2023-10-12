# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'MapsIndoorsTemplate-iOS-v4' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MapsIndoorsTemplate-iOS-v4
  pod 'MapsIndoorsGoogleMaps', '4.2.5'
  pod 'MapsIndoorsMapbox', '4.2.5'
end

PROJECT_ROOT_DIR = File.dirname(File.expand_path(__FILE__))
PODS_DIR = File.join(PROJECT_ROOT_DIR, 'Pods')
PODS_TARGET_SUPPORT_FILES_DIR = File.join(PODS_DIR, 'Target Support Files')

post_install do |pi|
  # Code for MapsIndoorsGoogleMaps
  remove_static_framework_duplicate_linkage({
                                            'MapsIndoorsGoogleMaps' => ['GoogleMaps']
                                            })
  
  # Code for MapsIndoorsMapbox
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
      bc.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

def remove_static_framework_duplicate_linkage(static_framework_pods)
  puts "Removing duplicate linkage of static frameworks"
  
  Dir.glob(File.join(PODS_TARGET_SUPPORT_FILES_DIR, "Pods-*")).each do |path|
    pod_target = path.split('-', -1).last
    
    static_framework_pods.each do |target, pods|
      next if pod_target == target
      frameworks = pods.map { |pod| identify_frameworks(pod) }.flatten
      
      Dir.glob(File.join(path, "*.xcconfig")).each do |xcconfig|
        lines = File.readlines(xcconfig)
        
        if other_ldflags_index = lines.find_index { |l| l.start_with?('OTHER_LDFLAGS') }
          other_ldflags = lines[other_ldflags_index]
          
          frameworks.each do |framework|
            other_ldflags.gsub!("-framework \"#{framework}\"", '')
          end
          
          File.open(xcconfig, 'w') do |fd|
            fd.write(lines.join)
          end
        end
      end
    end
  end
end

def identify_frameworks(pod)
  frameworks = Dir.glob(File.join(PODS_DIR, pod, "**/*.framework")).map { |path| File.basename(path) }
  
  if frameworks.any?
    return frameworks.map { |f| f.split('.framework').first }
  end
  
  return pod
end
