require 'ripper'

class MetaCLI::MethodDoc < Ripper::SexpBuilder
  def self.get_loc(file, line)
    lines = begin
      File.readlines(file)
    rescue Errno::ENOENT
      []
    end

    get lines[0,line-1].join
  end

  def self.get(src)
    new(src).tap(&:parse).comment
  end

  def initialize(*)
    super
    @comment = []
  end

  attr_reader :comment

  instance_methods.grep(/^on_(?:#{EVENTS * '|'})$/).each do |m|
    define_method m do |*args, &block|
      super(*args, &block).tap do |exp|
        on_non_comment_exp(exp)
      end
    end
  end

  private def on_non_comment_exp(exp)
    exp.kind_of?(Array) && exp.size >= 2 or return
    case exp[0]
    when :program, :@sp, :@ignored_nl
    when :bodystmt, :parse_error
    when :@embdoc_beg, :@embdoc_end
    when :@embdoc
      @comment << exp[1]
    else
      @comment.clear
    end
  end

  def on_comment(token)
    super.tap do |exp|
      exp.kind_of?(Array) && exp.size >= 2 or break
      @comment << exp[1].sub(/^#/, "")
    end
  end
end
