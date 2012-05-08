#!/usr/bin/env ruby
 
  #Compiling results
  mainDirectory = "/home/bluesim/OpenFOAM/OpenFOAM-1.6.x/tutorials/incompressible/transientSimpleFoam/igccpaper/crac_results/Probes_Crac"
  Dir.chdir(mainDirectory)
  
  resultsFileName = "Main_Data_probes__Results"
  
  directories = Dir.entries(Dir.pwd).sort
  system("touch #{resultsFileName}")
  mainResultsFile = File.open(resultsFileName,'a')
  directories.delete_if{|dir| dir == "." || dir == ".." || dir == "ExtractResults.rb"}
  directories.each{|dir|
    
    resultsLineAsString =""
    Dir.chdir(mainDirectory+"/#{dir.to_s}/20")
	puts "going into directory: probes2_Results/#{dir.to_s}/20"
    tFile = File.readlines('T')
    lineCount = 1
    tFile.each{|line|
      lineCount += 1
      if lineCount <6
        next
      end
      resultsLineAsString +=line.split(" ").last+ ","
      
    }
    
    Dir.chdir(mainDirectory+"/#{dir.to_s}/21")
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
    #puts resultsLineAsString
    mainResultsFile.puts resultsLineAsString
  }
