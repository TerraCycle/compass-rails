module CompassRails
  module Test
    module RailsHelpers
      include FileHelper
      include DebugHelper
      include CommandHelper
        RAILS_6_1   = "6.1"
        RAILS_6_0   = "6.0"
        RAILS_5_2   = "5.2"

        WORKING_DIR = File.join(ROOT_PATH, 'rails-temp')

        VERSION_LOOKUP = {
          RAILS_6_1 => %r{^6\.1\.},
          RAILS_6_0 => %r{^6\.0\.},
          RAILS_5_2 => %r{^5\.2\.},
        }

        GEMFILES = {
          RAILS_6_1 => GEMFILES_DIR.join("rails_edge.gemfile").to_s,
          RAILS_6_0 => GEMFILES_DIR.join("rails60.gemfile").to_s,
          RAILS_5_2 => GEMFILES_DIR.join("rails52.gemfile").to_s,
        }

        GENERATOR_OPTIONS = ['-q', '-G', '-O', '--skip-bundle']

      def rails_command(options)
        debug cmd = "rails #{options.join(' ')}"
        run_command(cmd, GEMFILES[rails_version])
      end

      def rails_version
        @rails_version ||= VERSION_LOOKUP.detect { |version, regex| CompassRails.version_match(regex) }.first
      end

      # Generate a rails application without polluting our current set of requires
      # with the rails libraries. This will allow testing against multiple versions of rails
      # by manipulating the load path.
      def generate_rails_app(name, options = [])
        options += GENERATOR_OPTIONS
        rails_command(['new', name, *options])
      end

      def within_rails_app(named, &block)
        dir = "#{named}-#{rails_version}"
        rm_rf File.join(WORKING_DIR, dir)
        mkdir_p WORKING_DIR
        cd(WORKING_DIR) do
          generate_rails_app(dir, [])
          cd(dir) do
            yield RailsProject.new(File.join(WORKING_DIR, dir), rails_version)
          end
        end
        rm_rf File.join(WORKING_DIR, dir) unless ENV['DEBUG_COMPILE']
      end

    end
  end
end
