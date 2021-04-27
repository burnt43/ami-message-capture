require 'hashie' 
require 'active_support/inflector'
require 'asterisk-manager-interface-client.rb'
require 'optparse'

class ArgumentParser
  def initialize
    @op = OptionParser.new
    @op.banner =
      "		 #    #     # ###    #     #                #####                \n" \
      "		# #   ##   ##  #     ##   ##  ####   ####  #     #   ##   #####  \n" \
      "	 #   #  # # # #  #     # # # # #      #    # #        #  #  #    # \n" \
      "	#     # #  #  #  #     #  #  #  ####  #      #       #    # #    # \n" \
      "	####### #     #  #     #     #      # #  ### #       ###### #####  \n" \
      "	#     # #     #  #     #     # #    # #    # #     # #    # #      \n" \
      "	#     # #     # ###    #     #  ####   ####   #####  #    # # "
    @op.on(
      '--host HOST',
      "hostname where the Asterisk Manager Interface runs on."
    )
    @op.on(
      '--pass PASS',
      "password for logging into the Asterisk Manager Interface."
    )
    @op.on(
      '--port PORT',
      "port that the Asterisk Manager Interface runs on."
    )
    @op.on(
      '--user USER',
      "username for logging into the Asterisk Manager Interface."
    )
    @op.on(
      '--output OUTPUT',
      "file to write messages to."
    )
    @op.on(
      '--help',
      'display this screen'
    ) do
      puts @op
      exit 0
    end
  end

  def parse
    {}.tap do |result|
      @op.parse!(into: result)
    end
  end
end

options = ArgumentParser.new.parse

options_for_client = {}.tap do |h|
  h[:pass] = options[:pass] if options.key?(:pass)
  h[:port] = options[:port] if options.key?(:port)
  h[:user] = options[:user] if options.key?(:user)
end
client = AmiClient::Client.new(options[:host], **options_for_client)

if options[:output]
  File.open(options[:output], 'a') do |f|
    f.puts '-'*50
    f.puts Time.now
    f.puts options.to_s
    f.puts '-'*50
  end

  client.on_message = ->(message) {
    File.open(options[:output], 'a') do |f|
      f.puts Time.now
      f.puts message.parsed_from
    end
  }
end

client.read!
