require 'metacli'

class MyApp
  def initialize(verbose: false)
    @verbose = verbose
  end

  def cmd_hello(firstname, lastname=nil)
    name = [firstname, lastname].compact * " "
    puts "Hello #{name}"
  end

  # Prints its argument
  def cmd_echo(msg, shout: false)
    msg = msg.upcase if shout
    puts msg
  end

  private def puts(msg)
    $stderr.puts "writing to stdout" if @verbose
    $stdout.puts msg
  end
end

cli = MetaCLI.new ARGV
verbose = cli.opts.delete :verbose  # --verbose is a global flag. Delete it so
                                    # it won't be passed to the command
app = MyApp.new verbose: verbose
cli.run app
