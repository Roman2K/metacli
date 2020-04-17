class MetaCLI
  autoload :MethodDoc, 'metacli/methoddoc'

  def initialize(argv, prog: File.basename($0))
    @prog, @args = prog, argv.dup
    @opt_help = %w(-h --help).map { |o| !!@args.delete(o) }.any?
    parse_opts!
    @cmd = @args.shift
    @cmd, @opt_help = nil, true if @cmd == "help"
  end

  attr_reader :cmd, :args, :opts

  private def parse_opts!
    @opts = {}
    @args = @args.each_with_object([]).with_index do |(arg, arr), i|
      case arg
      when "--"
        break arr.concat @args[i+1 .. -1]
      when /\A--(.+?)=(.*)\z/
        @opts[$1.to_sym] = $2
      when /\A--no-(.+)\z/
        @opts[$1.to_sym] = false
      when /\A--(.+)\z/
        @opts[$1.to_sym] = true
      else
        arr << arg
      end
    end
  end

  def run(obj)
    runobj = RunObject.new(obj)
    if !@cmd
      cmds = runobj.commands
      msg = usage "%s [options]" % [cmds * "|"]
      raise ArgumentError, msg unless @opt_help
      puts msg,
        "", "Commands:",
        "", cmds.map { |c| "  " + runobj[c].usage_short },
        ""
      exit 0
    end

    cmd = runobj[@cmd]
    if @opt_help
      puts usage(cmd.usage)
      exit 0
    end

    begin
      cmd.run(@args, @opts)
    rescue Command::CommandArgError
      raise ArgumentError, usage(cmd.usage_args)
    end
  end

  private def usage(args)
    "Usage: #{@prog} #{args}"
  end

  class RunObject
    def initialize(obj)
      @obj = obj
    end

    def commands
      @obj.methods.grep(/^cmd_(.+)/) { $1 }
    end

    def [](cmd)
      Command.new(cmd, @obj.public_method("cmd_#{cmd}"))
    end
  end

  class Command
    def initialize(name, meth)
      @name, @meth = name, meth
    end

    def usage
      [usage_args].tap { |lines|
        doc = doc_lines.join.gsub(/^ /, "")
        lines << "" << doc << "" unless doc.strip.empty?
      } * "\n"
    end

    def usage_short
      [usage_args].tap { |parts|
        doc = (doc_lines[0] || "").strip
        parts << doc unless doc.empty?
      } * " · "
    end

    def usage_args
      args = @meth.parameters.map do |type, name|
        case type
        when :req then name
        when :opt then "[#{name}]"
        when :rest then "[#{name} ...]"
        when :key then "--[no-]#{name}"
        else "<#{type}:#{name}>"
        end
      end
      [@name, *args].join " "
    end

    def doc_lines
      MethodDoc.get_loc(*@meth.source_location).tap do |lines|
        lines.shift if lines.first == "#\n"
        i = lines.reverse_each.each_cons(2).find_index { |ls| ls.any? /\S/ }
        lines.pop i+1 if i
      end
    end

    def run(args, opts)
      ##
      # We can't just call @meth with *args, **opts because if args contains
      # less arguments than @meth takes, then opts is passed as one of the
      # arguments instead of as keyword arguments.
      #
      if !opts.empty? \
        && args.size >= @meth.parameters.count { |type,| type == :req }
      then
        args = [*args, opts]
      end
      begin
        @meth.call(*args)
      rescue ArgumentError
        raise unless $!.backtrace[0] =~ /:in `#{@meth.name}'/
        raise CommandArgError
      end
    end

    class CommandArgError < StandardError; end
  end
end
