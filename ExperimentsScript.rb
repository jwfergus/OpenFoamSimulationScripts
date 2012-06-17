#!/usr/bin/ruby

#
#  Main Options
#
Q = 1466318.6604
CRAC_Q = 111111.1111
firstEndTime = 21
secondEndTime = 90
mainDirectory = Dir.pwd
solverFile = 'transientSimpleFoam.C.smallContainer.original'
openFoamRootDirectory = "/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/"
ChassisList = ['//____CRAC_____', "//rack1chassis1","//rack1chassis2","//rack1chassis3",'//rack1chassis4','//rack1chassis5','//rack1chassis6','//rack2chassis1','//rack2chassis2',
'//rack2chassis3','//rack2chassis4','//rack2chassis5','//rack2chassis6','//rack3chassis1','//rack3chassis2','//rack3chassis3','//rack3chassis4','//rack3chassis5',
'//rack3chassis6','//rack4chassis1','//rack4chassis2','//rack4chassis3','//rack4chassis4','//rack4chassis5','//rack4chassis6']


#
# Make a unique directory to store our results. Directory and experiment 
#   name are based on command line argument
#
if(ARGV[0].nil?)
	abort("Pass name of experiment as command line argument.")
end
experimentName = ARGV[0]
currentTime = Time.new
rootResultsDirectory = "Results_ExperimentName-#{experimentName}_DateTime-" + 
	"#{currentTime.month}.#{currentTime.day}.#{currentTime.year}_" +
	"#{currentTime.hour}.#{currentTime.min}"
system("mkdir #{rootResultsDirectory}")
system("mkdir #{rootResultsDirectory}/MainData")


#
# Main Simulation Loop
#  Loops over our list of chassis, defined at top of file
ChassisList.each{ |chassis|
Dir.chdir(mainDirectory)

	#
	# Clearing Previous Results
	#
	system("ruby clean.rb #{secondEndTime}")

	############################################################################################
	#### Running simulation until steady state (20 seconds)
	############################################################################################
	
	#
	#	Section to handle changing transientSimpleFoam.C file. Setting all outlets to original Temp.
	#
	Dir.chdir(openFoamRootDirectory + 'applications/solvers/incompressible/transientSimpleFoam')
	origTransientSimpleFoamC = File.readlines(solverFile)
	system("cp #{solverFile} transientSimpleFoam.C")

	#
	# Remake solver
	#
	system("wmake libso ")
	Dir.chdir(openFoamRootDirectory + 'applications')
	system("./Allwmake ")


	#
	# Change All Q Values to zero
	#
	Dir.chdir(mainDirectory+'/system')

	origSetFieldsDictFile = File.readlines('setFieldsDict.original')
	setFieldsDictFile = File.open('setFieldsDict', 'w')
	origSetFieldsDictFile.each{|line|
	  setFieldsDictFile.puts(line)
	}  
	setFieldsDictFile.close


	#
	# Update endtime to 20 (Steady State time)
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
		setControlDict.puts "endTime\t\t20;"
		puts
	  end
	else
	  setControlDict.puts(line)
	end

	}
	setControlDict.close


	#
	# Run final time series of simulation with final endTime
	#
	Dir.chdir(mainDirectory)
	system("setFields -latestTime ")
	system("transientSimpleFoam ")


	############################################################################################
	#### Steady State Reached - Beginning First End Time Simulation
	############################################################################################

	#
	#	Suppress temperature control in transientSimpleFoam.C (within the solver)
	#
	Dir.chdir(openFoamRootDirectory + 'applications/solvers/incompressible/transientSimpleFoam')
	origTransientSimpleFoamC = File.readlines(solverFile)
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
	
	
	#
	#   Recompile our solver
	#
	system("wmake libso ")
	Dir.chdir(openFoamRootDirectory + 'applications')
	system("./Allwmake ")



	#
	#   Set the Q value (temperature?) high for these time steps
	#
	Dir.chdir(mainDirectory+'/system')
	origSetFieldsDictFile = File.readlines('setFieldsDict.original')
	setFieldsDictFile = File.open('setFieldsDict', 'w')
	origSetFieldsDictFile.each{|line|
	if line.include?( chassis.to_s)
		if(chassis.to_s == '//____CRAC_____')
	  		setFieldsDictFile.puts "\t\tvolScalarFieldValue Q "+CRAC_Q.to_s+" "+chassis.to_s
	 		puts
		else
	  		setFieldsDictFile.puts "\t\tvolScalarFieldValue Q "+Q.to_s+" "+chassis.to_s
	 		puts
		end
	else
	  setFieldsDictFile.puts(line)
	end
	}  
	setFieldsDictFile.close


	#
	#   Setting our endTime to be the first endTime
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
		setControlDict.puts "endTime\t\t"+firstEndTime.to_s+';'
		puts
	  end
	else
	  setControlDict.puts(line)
	end

	}
	setControlDict.close

	#
	# Get back to our root simulation directory, setFields and run the simulation
	#
	Dir.chdir(mainDirectory)
	system("setFields -latestTime ")
	system("transientSimpleFoam ")

	############################################################################################
	#### First End Time Reached - Beginning Second End Time Simulation
	############################################################################################
	
	#
	#	Section to handle changing transientSimpleFoam.C file. Setting all outlets to original Temp.
	#
	Dir.chdir(openFoamRootDirectory + 'applications/solvers/incompressible/transientSimpleFoam')
	origTransientSimpleFoamC = File.readlines(solverFile)
	system("cp #{solverFile} transientSimpleFoam.C")

	#
	# Remake solver
	#
	system("wmake libso ")
	Dir.chdir(openFoamRootDirectory + 'applications')
	system("./Allwmake ")


	#
	# Change Q Value back to zero
	#
	Dir.chdir(mainDirectory+'/system')

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


	#
	# Run final time series of simulation with final endTime
	#
	Dir.chdir(mainDirectory)
	system("setFields -latestTime ")
	system("transientSimpleFoam ")


	############################################################################################
	#### Simulation Over - Moving Simulation Results into Results Folder
	############################################################################################
		
	#Sim done - moving results files into results folder
	directoryFolder = chassis
	directoryFolder.slice!(0)
	directoryFolder.slice!(0)
	directoryFolder+='__Results'
	system("mkdir #{directoryFolder} ")
	system("cp -r Chassis* #{directoryFolder} ")
	system("cp -r probes2 #{directoryFolder} ")

	#Compiling results
	Dir.chdir(mainDirectory + "/#{directoryFolder}")

	resultsFileName = "Main_Data_"+directoryFolder

	directories = Dir.entries(Dir.pwd).sort
	system("touch #{resultsFileName}")
	mainResultsFile = File.open(resultsFileName,'a')
	directories.delete_if{|dir| dir == "." || dir == ".."}
	directories.each{|dir|

	resultsLineAsString =""
	Dir.chdir(mainDirectory+"/#{directoryFolder}/#{dir.to_s}/20")
	tFile = File.readlines('T')
	lineCount = 1
	tFile.each{|line|
	  lineCount += 1
	  if lineCount <6
		next
	  end
	  resultsLineAsString +=line.split(" ").last+ ","
	  
	}

	Dir.chdir(mainDirectory+"/#{directoryFolder}/#{dir.to_s}/#{firstEndTime}")
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
	system("cp #{mainDirectory}/#{directoryFolder}/#{resultsFileName} #{mainDirectory}/#{rootResultsDirectory}/MainData/")
	system("mv #{mainDirectory}/#{directoryFolder} #{mainDirectory}/#{rootResultsDirectory}/")
	system("rm -rf ~/.local/share/Trash/* ")
} 
Dir.chdir("#{mainDirectory}")
system("zip -r #{rootResultsDirectory}.zip #{rootResultsDirectory}")
system("./MoveResultsToServer.sh #{rootResultsDirectory}.zip")
