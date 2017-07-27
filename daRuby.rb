# ZGFSdWJ5IHYxIC0tIG1hZGUgYnkgQGRhc2lua2luZyB3aXRoIDwzIC0tIDIwMTc=
@version = "daRuby_v1"
@configrev = 1                                                              #should you rewrite your whole config system, just increase this number by one

require 'yaml'
require 'twitter'
require 'oauth'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE                       #only needed for some ruby installations on windows, when you get a certificate error (fuck that)

#####twitter_auth#####
@Twitter = Twitter::REST::Client.new do |config|  
  config.consumer_key       = "EaodjDROpCmM0ehTXH09izFDa"                             #wooooooah! api keys!
  config.consumer_secret    = "LSBJrtlGe7E9lfT3LFN2ndpHV9rvlxERGRP2OAUOf3jVU8Nzwy"    #those are the public keys for the daRuby Twitter app. You can use them for testing. :)
end
#####twitter_auth_end#####

def setup
  if File.file?("config.yml") == true then                                    #check for existing config 
    $config = {                                                               #opening the hash

    }.merge(YAML.load_file File.expand_path '../config.yml', __FILE__)        #merging the existing config to check it's contents

    if $config[:revision] != @configrev then                                  #check the revision.
      begin                                                                   
        puts ""                                                               
        puts "Welcome to #{@version}! Looks like your update was successful, but we're not done yet."
        puts "Your existing configuration is based on an older installation of daRuby."
        puts "A new configuration will be created, but before that, we need to delete the old one."
        puts "If you have any emotional connection to it, create a backup now."
        puts "When you're done, or you don't care, press enter."
        stub = $stdin.gets.strip                                              #wait for enter press
        File.delete("config.yml")                                             #delete old config
        $config = {}                                                          #zero the variable
        setup                                                                 #rerun setup for configuring the new config file
      end                                                                                      #yo dawg, i heard you like configurations
    else                                                                      #config is found which is up-to-date. it's configurations will be set
      begin
        @Twitter.access_token = $config[:twitter_token]                       #adding twitter tokens from the valid config
        @Twitter.access_token_secret = $config[:twitter_token_secret]
        #set all your api tokens, usernames, etc. (everything that's config stuff) here
      end
    end
  else                                                                        #o fuc, we need to setup
    puts ""
    puts "Welcome, new user of daRuby!"
    puts "Before we can start spamming you and your friends' timeline, we need to configure some things."
    puts "It won't take long!"

    $config = {}                                                              #opening the hash for incoming entries
                                                                              #it's an hash, because we'll save those settings to an external file later. it's easier like that.
    #####twitter_auth#####
      puts ""
      puts "First we need access to Twitter."
      consumer = OAuth::Consumer.new(@Twitter.consumer_key,@Twitter.consumer_secret, :site => "https://api.twitter.com")  #define where to send the request and it's parameters
      request_token = consumer.get_request_token(:oauth_callback => @callback_url)                                        #requesting and saving first oauth answer

      url = request_token.authorize_url(oauth_callback: @callback_url)                                                    #saving the auth url separately 

      puts "Open this URL in a browser: #{url}"
      pin = ''                                    #init pin variable (zeroing)
      until pin =~ /^\d+$/                        #loop for typing in the auth pin
        print "Enter PIN => "
        pin = $stdin.gets.strip                   #saving pin
      end

      @access_token = request_token.get_access_token(oauth_verifier: pin)   #requesting the tokens with the auth pin and saving it

      $config[:twitter_token] = @access_token.token                         #defining the tokens in the config
      $config[:twitter_token_secret] = @access_token.secret                 #like that, we need to reload setup in the end, so it defines the tokens

      if @Twitter.user("dasinking").id == 78006580 then                     #test whether or not i can access the api
        puts ""
        puts "Successfully logged into Twitter!"                            #although it's basically impossible to get to this step without a valid auth
      else 
        puts ""                                                             #but i already programmed it so yeah
        puts "somethings wrong with the auth process wtf"                   #all it does is requesting the user id of my profile and checking it
        puts "that should be impossible actually"                           #technically it's not even a good test, as the user id is requestable over public api
        setup                                                               #so maybe i'll scrap this later on or improve it, we'll see
      end
    #####twitter_auth_end#####

    #####create the config file#####
      $config[:revision] = @configrev
      File.open "config.yml", 'w' do |f|              #save contents of the config hash 
        f.write $config.to_yaml                       #... in yaml
      end
      setup                                           #rerun setup for setting the parameters
    #####create the config file_end#####
  end
end

def tweet(content) #function for creating the tweet, modify as you like (example: github.com/dasinking/tweetFM)
  if "#{content}".size < 140 then                                                           #just a check for the character limit
    begin
      @Twitter.update("#{content}")                                                         #lets tweet it out
      puts "[#{Time.new.strftime("%d-%m-%Y %H:%M:%S").to_s}] Tweet sent: #{content}"        #console output and stuff
    rescue => e 
      puts "rescued (probably twitter is down or some other shit): " + e.message            #rescue when twitter is down when trying to tweet it (or some other shit)
      sleep(3)                                                                              #lets maybe wait a few seconds, if it's really down
      retry while true                                                                      #this rescue should be made more specific tbh, otherwise some bad shit can happen
    end
  else
    begin
      @tweetoutput = "#{content[0...137]}..."                                               #chomping the contents and put together the tweet
      @Twitter.update(@tweetoutput)                                                         #tweet that shit
      puts "[#{Time.new.strftime("%d-%m-%Y %H:%M:%S").to_s}] Tweet sent: #{@tweetoutput}"
    rescue => e 
      puts "rescued (probably twitter is down or some other shit): " + e.message
      sleep(3)
      retry while true
    end
  end
end

#####MAINLOOP#####
begin
  setup           #the setup! either create a config file, or init from a valid existing one
  @Twitter.update("[#{Time.new.strftime("%d-%m-%Y %H:%M:%S").to_s}] #{@version} by @dasinking == online")  #welcome online
  puts "[#{Time.new.strftime("%d-%m-%Y %H:%M:%S").to_s}] #{@version} by @dasinking == online"

  while 1 != 2 do         #endless loop
    begin                                                               
        #####WRITE THE LOGIC FOR YOUR BOT HERE#####
    end
  end
end