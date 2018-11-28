# MetaCLI

> Ruby command-line option parser for the lazy

Allows for defining commands as methods receiving command-line arguments and
options as positional and keyword arguments, respectively.

Instead of having to explicitly declare available commands and their arguments
and options, dynamically extrapolates those from regular method definitions.
Generates concise usage messages upon --help and invalid calls.

## Example

```sh
$ ruby my_script.rb foo bar --baz --qux=123
```

would call:

```ruby
my_obj.cmd_foo("bar", baz: true, qux: "123")
```

## Install

Gemfile:

```ruby
gem 'metacli', github: 'Roman2K/metacli'
```

## Usage

```ruby
require 'metacli'

class MyApp
  def initialize(verbose: false)
    @verbose = verbose
  end

  def cmd_hello(firstname, lastname=nil)
    name = [firstname, lastname].compact * " "
    puts "Hello #{name}"
  end

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
```

## Output

Global usage:

```
$ ruby my_script.rb -h
Usage: my_script.rb hello|echo [options]

Commands:

  hello firstname [lastname]
  echo msg --shout

```

Command usage:

```sh
$ ruby my_script.rb hello -h
Usage: my_script.rb hello firstname [lastname]
```

Successful run:

```sh
$ ruby my_script.rb hello Bob
Hello Bob
```

Successful run (with global option):

```sh
$ ruby my_script.rb hello Bob Sponge --verbose
writing to stdout
Hello Bob Sponge
```

Invalid call (command not specified):

```sh
$ ruby my_script.rb
Traceback (most recent call last):
        1: from my_script.rb:28:in `<main>'
/home/roman/code/metacli/lib/metacli.rb:34:in `run': Usage: my_script.rb hello|echo [options] (ArgumentError)
```

Invalid call (missing name argument to hello command):

```sh
Traceback (most recent call last):
        2: from my_script.rb:28:in `<main>'
        1: from /home/roman/code/metacli/lib/metacli.rb:48:in `run'
/home/roman/code/metacli/lib/metacli.rb:51:in `rescue in run': Usage: my_script.rb hello firstname [lastname] (ArgumentError)
```
