# frozen_string_literal: true

require "optparse"
require_relative "../generators/app"

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = <<~DESC
    \nHanami authorization application generator
    Usage: hanami g auth --app auth --model user
    Flags:
  DESC

  opts.on("-a", "--app APP", "Specify the application name") do |app_name|
    options[:app] = app_name
  end

  opts.on("-m", "--model MODEL", "Specify the model name") do |policy|
    options[:model] = policy
  end

  opts.on("-h", "--help", "Displays help") do
    puts opts
    exit
  end
end

begin
  optparse.parse!
  puts "Add flag -h or --help to see usage instructions." if options.empty?
  mandatory = [:app, :model]
  missing = mandatory.select { |arg| options[arg].nil? }
  raise OptionParser::MissingArgument, missing.join(", ") unless missing.empty?
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts optparse
  puts $ERROR_INFO.to_s
  exit
end

puts "Generating with options: #{options.inspect}"
HanamiId::Genertors::App.generate(options[:app], options[:model])
puts "Generated successfully"
