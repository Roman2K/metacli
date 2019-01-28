$:.unshift __dir__ + "/../lib"

require 'minitest/autorun'
require 'metacli'

class MetaCLITest < Minitest::Test
  def test_args_opts
    args = %w( mycmd a --foo --no-foo --bar b --baz=quux -- --myopt c )
    args2 = args.dup

    cli = MetaCLI.new(args)
    assert_equal args2, args
    assert_equal "mycmd", cli.cmd
    assert_equal %w( a b --myopt c ), cli.args
    assert_equal({
      foo: false,
      bar: true,
      baz: "quux",
    }, cli.opts)

    assert_equal %w( a ), MetaCLI.new(%w( mycmd a -- )).args
  end

  module Cmds
    # Some doc
    def self.cmd_foo
    end

    ##
    # Some doc
    #
    def self.cmd_bar
    end
  end

  def test_doc_lines
    lines = -> cmd do
      MetaCLI::RunObject.new(Cmds)[cmd].doc_lines
    end
    assert_equal [" Some doc\n"], lines[:foo]
    assert_equal [" Some doc\n"], lines[:bar]
  end
end
