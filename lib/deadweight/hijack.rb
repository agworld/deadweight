class Deadweight
  module Hijack
    def self.redirect_output(log_file_prefix)
      @original_stdout, @original_stderr = STDOUT.clone, STDERR.clone
      STDOUT.reopen( File.open( "#{log_file_prefix}stdout.log", 'w') )
      STDERR.reopen( File.open( "#{log_file_prefix}stderr.log", 'w') )

      [@original_stdout, @original_stderr]
    end
    
    def self.reset_output
      if @original_stderr
        @original_stderr.flush
        @hijacked_stderr = STDERR.clone
        STDERR.reopen( @original_stderr )
        @hijacked_stderr.close
        warn File.read( @hijacked_stderr.path )
      end
      if @original_stdout
        @original_stdout.flush
        @hijacked_stdout = STDOUT.clone
        STDOUT.reopen( @original_stdout )
        @hijacked_stdout.close
        puts File.read( @hijacked_stdout.path )
      end
    end
  end
end

