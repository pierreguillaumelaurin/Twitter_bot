require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing"
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length <= 140
		  @client.update(message)
		else
		  puts "Sorry your message is #{message.length-140} caracters too long"
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message: "
		puts message
		message = "d @#{target} #{message}"
		screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name}
		if screen_names.include?(target)
			tweet(message)
		else
			print "Sorry, you can only DM people following you"
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each {screen_names << @client.user(follower).screen_name}
		return screen_names
	end

	def spam_my_followers(message)
		followers_list.each{|follower| dm(follower,message)}
	end

	def everyones_last_tweet
		friends = @client.friends.sort_by { |friend| friend.screen_name.downcase }
        friends.each do |friend|
          timestamp = friend.status.created_at
          puts "#{friend.screen_name.upcase} (#{timestamp.strftime("%b %d")}): #{friend.status.text}"
        end
    end

    def shorten(original_url)
        bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
        puts "Shortening this URL: #{original_url}"
        bitly.shorten(original_url).short_url
    end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
		  print "enter command: "
		  input = String(gets).chomp
		  parts = input.split(" ")
		  command = parts[0]
		  case command
		    when 'q' then puts "Goodbye!"
		    when 't' then puts "Tweeting!" && tweet(parts[1..-1].join(" "))
		    when 'dm' then "DMing!" && dm(parts[1], parts[2..-1].join(" "))
		    when 'spam' then puts "Spamming!" && spam_my_followers(parts[1..-1].join(" "))
		    when 'last' then puts "Showings lasts!" && everyones_last_tweet
		    when 'turl' then tweet(parts[1..-2].join(' ') + ' ' + shorten(parts[-1]))
		    else
		  	  puts "Sorry, I don't know how to #{command}"
		  end
		end
	end


end

#execution script
blogger = MicroBlogger.new
blogger.run