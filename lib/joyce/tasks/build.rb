require 'fileutils'

module Joyce
  module Tasks
    class AppBuilder
      include FileUtils

      def make(app_name:, app_class_name:, template_location:, target_directory:)
        target_app_bundle_root = File.join(target_directory, "#{app_name}.app")
        cp_r template_location, target_app_bundle_root
        puts "--- Ruby.app copied!"

        puts "--- copying your source code..."
        cp_r "lib/.", "#{target_app_bundle_root}/Contents/Resources/lib"
        puts "--- source code copied in!"

        puts "--- let's copy gems in..."
        gem_destination = "#{target_app_bundle_root}/Contents/Resources/vendor"

        gems_to_ignore = %w[ gosu minitest ]
        gems_to_ignore << app_name # since we just copied over source?
        gem_list = vendored_gem_names(ignoring: gems_to_ignore)

        copy_gems(gem_list, destination: File.join(gem_destination))
        puts "--- gems copied"

        # TODO copy assets...?

        puts "--- writing main.rb..."
        write_main_rb(app_class_name: app_class_name, root: target_app_bundle_root, app_name: app_name)
        puts "--- main.rb written!"
      end

      def write_main_rb(root:,app_name:,app_class_name:)
        File.open("#{root}/Contents/Resources/main.rb", "w") do |file|
          require_paths = gemspecs.map do |spec|
            spec.require_paths.map {|path| "#{spec.name}-#{spec.version}/#{path}" }
          end

          file.puts <<-ruby
require 'fileutils'
FileUtils.mkdir_p("#{Dir.home}/#{app_name}/")
$stdout.reopen("#{Dir.home}/#{app_name}/app.log", "w")
$stderr.reopen("#{Dir.home}/#{app_name}/err.log", "w")
GEM_REQUIRE_PATHS = #{require_paths.flatten.inspect}
GEM_REQUIRE_PATHS.each do |path|
  $LOAD_PATH.unshift File.expand_path(File.join("../vendor/gems", path), __FILE__)
end
require 'joyce'
require '#{app_name}'
#{app_class_name}.kickstart!
ruby
        end
      end

      # the gem approach from releasy: https://github.com/Spooner/releasy/blob/master/lib/releasy/mixins/has_gemspecs.rb
      def copy_gems(gems, destination:)
        gems_dir = "#{destination}/gems"
        mkdir_p gems_dir
        gems.each do |gem|
          spec = gemspecs.find { |g| g.name == gem }
          gem_dir = spec.full_gem_path
          puts "Copying gem: #{spec.name} #{spec.version}"
          cp_r gem_dir, gems_dir
        end
      end

      def vendored_gem_names(ignoring:)
        (gemspecs.map(&:name) - ignoring).sort
      end

      private

      def gemspecs
        @gemspecs ||= Bundler.definition.specs_for([:default])
      end
    end
  end
end
