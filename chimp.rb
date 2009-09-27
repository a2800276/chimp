#!/usr/bin/ruby 
require 'rubygems'
require 'optparse'

#{{{
ARGV.options { |opt|
  opt.summary_indent = ' ' * 2
  opt.banner = "Usage:\n#{opt.summary_indent}#{File.basename($0)} [options] [FILENAME]\n"
  opt.on("Options:")
  opt.on("--help", "-h", "This text") { puts opt; exit }
  opt.on("Filename needs to be a chimp presentation.")
  opt.parse!
}
if ARGV.length == 0 || !File.exists?(ARGV[0])
  puts ARGV.options
  exit
end
fname = ARGV[0]
#}}}

clear_code = %x{clear}
width, heigth = %{resize}
file = File::read(fname).gsub(/^#name: (.*)(\n\s*)+/,'')
name = $1

print clear_code
file.split(/\n---\s*\n/).each do |slide|
  puts name
  %x{resize} =~ /COLUMNS=(\d+).*LINES=(\d+)/m
  width = $1
  height = $2
  puts ("-"*($1.to_i)) + "\n\n"
  slide.split(/\n\+\+\+\s*\n/).each do |part|
    print part
    $stdin.gets
  end  
  print clear_code
end  
