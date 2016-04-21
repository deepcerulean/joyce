module Joyce
  module Tasks
    class AppBuilder
      include FileUtils

      def make(app_name:)
        target_app_bundle_root = File.join("..", "dist", "#{app_name}.app")

        puts "--- build os x app here!"
        cp_r "../dist/Ruby.app", target_app_bundle_root
        puts "--- Ruby.app copied!"

        puts "--- copying your source code..."
        cp_r "lib", "#{target_app_bundle_root}/Contents/Resources/lib"

        puts "--- Analyzing your gems..."
        p Bundler.definition.specs_for([:default])

        puts "--- Okay, let's copy gems in..."

        gem_destination = "#{target_app_bundle_root}/Contents/Resources/vendor"

        # info "Copying source gems from system"
        binary_gems_to_ignore = %w[ gosu minitest ]
        gem_list = vendored_gem_names(ignoring: binary_gems_to_ignore)

        copy_gems(gem_list, destination: File.join(gem_destination))

        write_main_rb(root: target_app_bundle_root) #(app_class: "#{app_name}::Application")
      end

      def write_main_rb(root:)
	File.open("#{root}/Contents/Resources/main.rb", "w") do |file|
	  require_paths = gemspecs.map do |spec|
	    spec.require_paths.map {|path| "#{spec.name}-#{spec.version}/#{path}" }
	  end

	  file.puts <<-ruby
            $stdout.reopen("/Users/joe/joyce/game.log", "w")
            $stderr.reopen("/Users/joe/joyce/err.log", "w")

            puts "--- unshifting gem paths"

	    GEM_REQUIRE_PATHS = #{require_paths.flatten.inspect}

	    GEM_REQUIRE_PATHS.each do |path|
	      $LOAD_PATH.unshift File.expand_path(File.join("../vendor/gems", path), __FILE__)
	    end

            puts "--- gems shifted"

            require 'forwardable'
            require 'joyce'
            require 'application'
            
            Example::Application.kickstart!
            ruby
	end
      end

      # the gem approach from releasy: https://github.com/Spooner/releasy/blob/master/lib/releasy/mixins/has_gemspecs.rb
      # basically just copy over your own system gems, ignoring binary things
      # then we'll write out a prelude in main.rb that $unshifts the load path for each of these :/
      # but it should almost certainly work!
      def copy_gems(gems, destination:)
	gems_dir = "#{destination}/gems"
	# specs_dir = "#{destination}/specifications"
	mkdir_p gems_dir #, fileutils_options
	# mkdir_p specs_dir, fileutils_options

	gems.each do |gem|
	  spec = gemspecs.find {|g| g.name == gem }
	  gem_dir = spec.full_gem_path
	  puts "Copying gem: #{spec.name} #{spec.version}"

	  cp_r gem_dir, gems_dir
	  #,  fileutils_options
	  # spec_file = File.expand_path("../../specifications/#{File.basename gem_dir}.gemspec", gem_dir)
	  # cp_r spec_file, specs_dir, fileutils_options
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
