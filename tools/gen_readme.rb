require 'erb'
require 'open3'

LIB = "../lib"
LIB_ABS = File.expand_path File.join __dir__, LIB

def run(status, *args)
  cmd = "ruby", "my_script.rb", *args
  out, st = Open3.capture2e({"RUBYLIB" => LIB+":"+ENV["RUBYLIB"]}, *cmd)
  st.exitstatus == status or raise "command returned %d (expected %d): %p" \
    % [st.exitstatus, status, cmd]
  out.gsub! %r{\B#{Regexp.escape LIB_ABS}\b}, "(metacli)"
  [cmd * " ", out] * "\n"
end

def chomp(s)
  s.chomp
end

print ERB.new(File.read("README.md.erb")).result(binding)
