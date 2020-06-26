# MetaCLI

> Ruby command-line option parser for the lazy

Allows for defining commands as methods receiving command-line arguments and
options as positional and keyword arguments, respectively.

Instead of having to explicitly declare available commands and their arguments
and options, dynamically extrapolates those from regular method definitions.
Generates concise usage messages upon --help and invalid calls.

Command descriptions may be specified as method documentation.

## Example

```sh
$ ruby my_script.rb foo bar --baz --qux=123
```

would call:

```ruby
my_obj.cmd_foo("bar", baz: true, qux: "123")
```

Used in:

* [alerterr](https://github.com/Roman2K/alerterr)

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
```

## Output

Global usage:

```sh
$ ruby my_script.rb -h
Usage: my_script.rb echo|hello [options]

Commands:

  echo msg --[no-]shout · Prints its argument
  hello firstname [lastname]

```

Command usage:

```sh
$ ruby my_script.rb hello -h
Usage: my_script.rb hello firstname [lastname]
```

Command usage (with description):

```sh
$ ruby my_script.rb echo -h
Usage: my_script.rb echo msg --[no-]shout

Prints its argument

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
(metacli)/metacli.rb:38:in `run': Usage: my_script.rb echo|hello [options] (ArgumentError)
	from my_script.rb:29:in `<main>'
```

Invalid call (missing argument):

```sh
$ ruby my_script.rb hello
(metacli)/metacli.rb:55:in `rescue in run': Usage: my_script.rb hello firstname [lastname] (MetaCLI::UsageError)
	from (metacli)/metacli.rb:52:in `run'
	from my_script.rb:29:in `<main>'
(metacli)/metacli.rb:131:in `rescue in run': MetaCLI::CommandArgError (MetaCLI::CommandArgError)
	from (metacli)/metacli.rb:124:in `run'
	from (metacli)/metacli.rb:53:in `run'
	from my_script.rb:29:in `<main>'
my_script.rb:8:in `cmd_hello': wrong number of arguments (given 0, expected 1..2) (ArgumentError)
	from (metacli)/metacli.rb:126:in `call'
	from (metacli)/metacli.rb:126:in `run'
	from (metacli)/metacli.rb:53:in `run'
	from my_script.rb:29:in `<main>'
```
