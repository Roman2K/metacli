$:.unshift __dir__ + "/../lib"

require 'minitest/autorun'
require 'metacli'

class MetaCLI
  class MethodDocTest < Minitest::Test
    SRC = <<-RB
# ok
def test
end

#test

=begin
AAA
BBB
=end

xx

  # test

=begin
CCC
DDD
=end

#   xxx
# foo
#
# bar

# baz
    RB

    def test_get
      assert_equal [
        " test\n",
        "CCC\n",
        "DDD\n",
        "   xxx\n",
        " foo\n",
        "\n",
        " bar\n",
        " baz\n",
      ], MethodDoc.get(SRC)
    end

    def test_get2
      assert_equal [" some doc\n"], MethodDoc.get(<<-RB)
class Cmds
  # some doc
RB
    end

    # test
    def test_get_loc
      assert_equal [" test\n"],
        MethodDoc.get_loc(*method(__method__).source_location)
      assert_equal [],
        MethodDoc.get_loc("(pry)", 1)
    end
  end
end
