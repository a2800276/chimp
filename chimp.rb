#!/usr/bin/ruby 
#{{{
curpath = __FILE__
while ::File::symlink?(curpath)
  curpath = ::File::dirname(curpath) + '/' + ::File::readlink(curpath)
end  
require 'optparse'
require 'pp'
require 'rubygems'
require ::File::dirname(curpath) + "/lib/ChimpParser"
require ::File::dirname(curpath) + "/lib/ChimpParser-Grammar"
require ::File::dirname(curpath) + "/output/screen"

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
#}}}

grammy = Chimp::Parser::SimpleGrammar.parse File::read(ARGV[0])
screen = Chimp::Parser::Screen.new
grammy.prepare(screen)
grammy.output(screen)
