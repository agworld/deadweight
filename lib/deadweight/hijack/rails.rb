if ENV['DEADWEIGHT'] == 'true'
  puts "deadweight enabled"
  require 'deadweight'
  require 'deadweight/hijack'
  require 'deadweight/rack/capturing_middleware'

  class Deadweight
    module Hijack
	    if defined?( Rails ) 
        if Rails::VERSION::MAJOR == 2
          # Set up a deadweight instance
          root = ::Rails.root
          original_stdout, original_stderr = Deadweight::Hijack.redirect_output(root + 'log/test_')
          dw = Deadweight.new
          dw.root        = root + 'public'
          dw.stylesheets = Dir.chdir(dw.root) { Dir.glob("stylesheets/screen.css") } # can use globs here
          dw.log_file    = original_stderr
          dw.reset!
          at_exit do
            dw.report
            dw.dump(original_stdout)
            Deadweight::Hijack.reset_output
          end
    	    Rails.configuration.middleware.insert_after( 'ActionController::Failsafe', Deadweight::Rack::CapturingMiddleware, dw ) 
        else
          module Rails
            class Railtie < ::Rails::Railtie
              railtie_name :deadweight_hijack
            
              initializer "deadweight.hijack" do |app|
                # Set up a deadweight instance
                root = ::Rails.root
                original_stdout, original_stderr = Deadweight::Hijack.redirect_output(root + 'log/test_')
                dw = Deadweight.new
                dw.root        = root + 'public'
                dw.stylesheets = Dir.chdir(dw.root) { Dir.glob("stylesheets/*.css") }
                dw.log_file    = original_stderr
                dw.reset!
                at_exit do
                  dw.report
                  dw.dump(original_stdout)
                end

                app.middleware.insert(0, Deadweight::Rack::CapturingMiddleware, dw )

              end
          	end
          end
        end
    	end
    end
  end
end

