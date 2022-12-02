require 'securerandom'

desc "Trigger build_container task"
task :default do
  Rake::Task[:build_container].execute
end

desc "Build and push docker container"
task :build_container do
  puts "Building container"
  `docker build --platform linux/amd64 . -t registry.digitalocean.com/cam-tainers/escher`
  puts "Pushing container"
  `docker push registry.digitalocean.com/cam-tainers/escher`
end
