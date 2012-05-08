#  Main Options
Q = 733159.3302
firstEndTime = 21
secondEndTime = 110


ChassisList = ["//rack1chassis2","//rack1chassis4","//rack1chassis6",'//rack2chassis2','//rack2chassis4','//rack2chassis6','//rack3chassis2','//rack3chassis4',
'//rack3chassis6','//rack4chassis2','//rack4chassis4','//rack4chassis6','//rack5chassis2','//rack5chassis4','//rack5chassis6','//rack6chassis2','//rack6chassis4',
'//rack6chassis6','//rack7chassis2','//rack7chassis4','//rack7chassis6','//rack8chassis2','//rack8chassis4','//rack8chassis6']

Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper')
timeFile = File.open('timeStamps', 'w')

system("rm -r rack* ")
#Main Simulation Loop
ChassisList.each{ |chassis|
timeFile.puts chassis.to_s + " start :-: " + Time.now.getutc.to_s

Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper')
	#
	# Clearing Previous Results
	#
	for i in (201)...(secondEndTime*10 +1)
	  modifiedString = i.to_s
	  if(i%10 == 0)
		  modifiedString = modifiedString.chomp("0")
	  else
		  modifiedString.insert((modifiedString.size-1), ".")
	  end
	  system("rm -r #{modifiedString} ")
	end
	system("rm -r Rack* ")
	system("rm -r swak* ")
	system("rm -r probes2 ")

	#
	#	Section to handle changing transientSimpleFoam.C file.
	#
	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/applications/solvers/incompressible/transientSimpleFoam')
	origTransientSimpleFoamC = File.readlines('transientSimpleFoam.C.original')
	setTransientSimpleFoamC = File.open('transientSimpleFoam.C', 'w')
	origTransientSimpleFoamC.each{|line|
	if line.include?( chassis.to_s)
	  setTransientSimpleFoamC.puts "//"+line.to_s
	  puts
	else
	  setTransientSimpleFoamC.puts(line)
	end
	}  
	setTransientSimpleFoamC.close
	system("wmake libso ")
	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/applications')
	system("./Allwmake ")


	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper/system')
	origSetFieldsDictFile = File.readlines('setFieldsDict.original')
	setFieldsDictFile = File.open('setFieldsDict', 'w')
	origSetFieldsDictFile.each{|line|
	if line.include?( chassis.to_s)
	  setFieldsDictFile.puts "\t\tvolScalarFieldValue Q "+Q.to_s+" "+chassis.to_s
	  puts
	else
	  setFieldsDictFile.puts(line)
	end
	}  
	setFieldsDictFile.close




	origControlDict = File.readlines('controlDict.original')
	setControlDict = File.open('controlDict', 'w')
	passedFirst = false
	origControlDict.each{|line|
	if line.include?( 'endTime')
	  if passedFirst==false
		passedFirst = true
		setControlDict.puts(line)
	  else
		setControlDict.puts "endTime\t\t"+firstEndTime.to_s+';'
		puts
	  end
	else
	  setControlDict.puts(line)
	end

	}
	setControlDict.close

	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper')

	#puts "Check files *********************"
	#puts "transientSimpleFoam.C should have #{chassis.to_s} commented out,"
	#puts "setFieldsDict should have #{chassis.to_s}'s Q set high, and"
	#puts "controlDict should have endTime set to #{firstEndTime.to_s}"
	#nothingHere = gets

	system("setFields -latestTime ")
	system("transientSimpleFoam ")

	#
	#
	#  1        tt     TTTTTTT iii                      SSSSS  iii              DDDDD                        
	# 111  sss  tt       TTT       mm mm mmmm    eee   SS          mm mm mmmm   DD  DD   oooo  nn nnn    eee 
	#  11 s     tttt     TTT   iii mmm  mm  mm ee   e   SSSSS  iii mmm  mm  mm  DD   DD oo  oo nnn  nn ee   e
	#  11  sss  tt       TTT   iii mmm  mm  mm eeeee        SS iii mmm  mm  mm  DD   DD oo  oo nn   nn eeeee 
	# 111     s  tttt    TTT   iii mmm  mm  mm  eeeee   SSSSS  iii mmm  mm  mm  DDDDDD   oooo  nn   nn  eeeee
	#       sss                                                                                               

	#
	#	Section to handle changing transientSimpleFoam.C file.
	#
	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/applications/solvers/incompressible/transientSimpleFoam')
	origTransientSimpleFoamC = File.readlines('transientSimpleFoam.C.original')
	system("cp transientSimpleFoam.C.original transientSimpleFoam.C")

	#
	# Remake solver
	#
	system("wmake libso ")
	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/applications')
	system("./Allwmake ")


	#
	# Change Q Value back to zero
	#
	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper/system')

	origSetFieldsDictFile = File.readlines('setFieldsDict.original')
	setFieldsDictFile = File.open('setFieldsDict', 'w')
	origSetFieldsDictFile.each{|line|
	if line.include?( chassis.to_s)
	  setFieldsDictFile.puts "\t\tvolScalarFieldValue Q 0 "+chassis.to_s
	  puts
	else
	  setFieldsDictFile.puts(line)
	end
	}  
	setFieldsDictFile.close


	#
	# Update endtime to final endtime
	#
	origControlDict = File.readlines('controlDict.original')
	setControlDict = File.open('controlDict', 'w')
	passedFirst = false
	origControlDict.each{|line|
	if line.include?( 'endTime')
	  if passedFirst==false
		passedFirst = true
		setControlDict.puts(line)
	  else
		setControlDict.puts "endTime\t\t"+secondEndTime.to_s+';'
		puts
	  end
	else
	  setControlDict.puts(line)
	end

	}
	setControlDict.close


	Dir.chdir('/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper')
	system("setFields -latestTime ")
	system("transientSimpleFoam ")

	#Sim done - moving results files into results folder
	directoryFolder = chassis
	directoryFolder.slice!(0)
	directoryFolder.slice!(0)
	directoryFolder+='__Results'
	system("mkdir #{directoryFolder} ")
	system("cp -r Rack* #{directoryFolder} ")
	system("cp -r probes2 #{directoryFolder} ")

	#Compiling results
	Dir.chdir("/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper/#{directoryFolder}")

	resultsFileName = "Main_Data_"+directoryFolder

	directories = Dir.entries(Dir.pwd).sort
	system("touch #{resultsFileName}")
	mainResultsFile = File.open(resultsFileName,'a')
	directories.delete_if{|dir| dir == "." || dir == ".."}
	directories.each{|dir|

	resultsLineAsString =""
	Dir.chdir("/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper/#{directoryFolder}/#{dir.to_s}/20")
	tFile = File.readlines('T')
	lineCount = 1
	tFile.each{|line|
	  lineCount += 1
	  if lineCount <6
		next
	  end
	  resultsLineAsString +=line.split(" ").last+ ","
	  
	}

	Dir.chdir("/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper/#{directoryFolder}/#{dir.to_s}/#{firstEndTime}")
	tFile = File.readlines('T')
	lineCount = 1
	tFile.each{|line|
	  lineCount += 1
	  if lineCount <6
		next
	  end
	  
	  resultsLineAsString +=line.split(" ").last+ ","
	  
	  
	}
	n = resultsLineAsString.length - 1
	resultsLineAsString = resultsLineAsString[0...n]
	puts resultsLineAsString
	mainResultsFile.puts resultsLineAsString
	}
	mainResultsFile.close
	system("rm -rf ~/.local/share/Trash/* ")
	timeFile.puts chassis.to_s + " end :-: " + Time.now.getutc.to_s
	timeFile.puts
} 
