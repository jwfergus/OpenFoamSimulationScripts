#!/usr/bin/env ruby
#
# Script to clean the contents of an OpenFoam simulation folder
#   by removing temporary files. Be sure to check that your 
#   trash can isn't getting full when using this.
#
#  Author: Joshua Ferguson
#  Email: jwfergus@asu.edu / joshuawferguson@gmail.com
#



#
# If the command line argument is a number, it uses it to remove all 
#   folders in the pwd between 20 and the argument at .1 interval
#
if(ARGV[0].to_i > 0 || ARGV[0].nil?)
	if(ARGV[0].nil?)
		endRangeOfRemove = 200
	end
	
	endRangeOfRemove = ARGV[0].to_i
	puts "Removing folders between 20.1 and #{endRangeOfRemove} at .1 interval, inside #{Dir.pwd}"
	
	#
	# Constructs a string from 201 to endOfRange*10+1 and then
	#   inserts a decimal point one integer from the right-hand
	#   side. 
	#
	for i in (201)...(endRangeOfRemove*10 +1)
	  modifiedString = i.to_s
	  if(i%10 == 0)
		  modifiedString = modifiedString.chomp("0")
	  else
		  modifiedString.insert((modifiedString.size-1), ".")
	  end
	  
	  #
	  # Error output from rm function is routed to /dev/null
	  #   to clean up the console this runs in.
	  #
	  system("rm -r #{modifiedString} 2> /dev/null")
	end
	
	#
	# Remove extraneous files.
	#
	system("rm -r Rack* ")
	system("rm -r swak* ")
	system("rm -r probes2 ")
	
else
	#
	# If command line argument is something 
	#   strange (if check at the beginning), abort
	#
	abort('I need an Integer or nothing at all!')
end














