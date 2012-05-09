#!/usr/bin/expect -f
# Script created to move the results of our simulation to the server.
#   The file passed in as an argument ($argv) is rcp'ed to a directory 
#   under my home dir on the server. The file is then chmod'ed to have 
#   write permissions for everyone.
#
#   May 9th, 2012
#   Joshua Ferguson
#   jwfergus@asu.edu || joshuawferguson@gmail.com



# IMPORTANT VARIABLE, WILL NOT WORK WITHOUT CHANGE
set pass ""

# file to send is grabbed from the input argument and the general 
#   timeout of responses is set to 15 seconds
set fileToSend $argv
set timeout 15
send "echo $fileToSend"

# spawn the scp thread
spawn scp $fileToSend jwfergus@impact.asu.edu:/home/jwfergus/simulationResults/

# The OpenFoam machine has issues with a key conflict on the server, so we have to 
#  change the trust for the server
expect "?"
send "yes\r"


# When prompted for a password, give it (MUST BE SET AT THE TOP OF THE FILE)
expect "password:" 
send "$pass\r" 

# Sleep long enough for the file to upload
sleep 15

#######################################################
# Now we begin the section to change the permissions of the file
#
spawn ssh jwfergus@impact.asu.edu

expect "?"
send "yes\r"
expect "password:" 
send "$pass\r" 

sleep 1
send "cd /home/jwfergus/simulationResults/\r"
sleep 1 
send "chmod 666 $fileToSend\r"
sleep 1

