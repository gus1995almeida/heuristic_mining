#!/bin/env ruby
# encoding: utf-8

require_relative 'Xes.rb'
require_relative 'HeuristicMining'

xesFile = File.new('ArquivosXes/arquivo3_1.xes')      #Gets the xes file
xes_parser = Xes.new(xesFile)           #Create the xes parser 
listTasks = xes_parser.read_xes         #Gets the tasks

heuristicMiningExe = HeuristicMining.new(listTasks)     #Create an object to execute the Heuristic Mining
allTasksListed = heuristicMiningExe.all_tasks           #There are cases that the tasks names are written the differents forms, but   
p "------------------Tarefas Listadas---------------------"
p allTasksListed
allTasksQuantified = heuristicMiningExe.quantify_tasks   #Returns the sum of the amount of the equal traces     
p "--------------------Lista de Traces Iniciais----------------------"
allTasksQuantified.each do |path|
    p path
end

summationMatrix = heuristicMiningExe.summation_matrix(allTasksListed, allTasksQuantified)
p "-----------------Matriz Somatória--------------------"
summationMatrix.each do |line|
    p line
end

frequencyMatrix = heuristicMiningExe.frequency_matrix(summationMatrix, allTasksListed)
p "--------------------Matriz Frequência-------------------"
frequencyMatrix.each do |line|
    p line
end

puts "Valor de threshold: "
threshold = gets.chomp.to_i         #Reads the params that user want
puts "Valor da frequência: "
frequency_wish = gets.chomp.to_f 
adjacencyMatrix = heuristicMiningExe.adjunt_matrix(summationMatrix, frequencyMatrix, allTasksListed, threshold, frequency_wish)
p "---------------------Matriz Adjacência---------------------"
adjacencyMatrix.each do |line|
    p line
end
p "---------------------Novos Caminhos----------------------"
newPath = heuristicMiningExe.list_path(adjacencyMatrix)
newPath.each do |line|
    p line
end