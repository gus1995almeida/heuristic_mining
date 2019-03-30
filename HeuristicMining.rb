#!/bin/env ruby
# encoding: utf-8

class HeuristicMining
    def initialize(listTasks)
        @listTasks = listTasks
        @start_task = listTasks[0].first       #I'm considering that start and end tasks are in order in the file
        @end_task = listTasks[0].last
    end
    def all_tasks
        allTasksListed = Array.new
        allTasksListed << @start_task
        @listTasks.each do |task_group|
            task_group.each do |task|
                find_task = 0
                allTasksListed.each do |task_listed|
                    if task_listed == task || task == @end_task
                        find_task = 1
                        break
                    end
                end
                if find_task == 0
                    allTasksListed << task
                end
            end
        end
        allTasksListed << @end_task
        return allTasksListed
    end
    def quantify_tasks
        listTasksQuantify = Array.new
        stop_index = Array.new        #Gets the indexs were quantified
        task_group_total_index = (@listTasks.size) - 1
        @listTasks.each_with_index do |task_group, index|       #Run the paths that are in the front of task_group
            if stop_index.include?(index) == false          #Verify case the path was traveled
            amount = 1
                for i in ((index + 1)..task_group_total_index)
                    find = 0        
                    task_group.each_with_index do |task, position|   #The position index will be used to reference position the next array
                        if task != @listTasks[i][position]
                            find = 1
                            break
                        end
                    end
                    if find == 0 
                        amount += 1
                        stop_index << i
                    end
                end
            end
            if stop_index.include?(index) == false
                task_group << amount
                listTasksQuantify << task_group
            end
        end
        return listTasksQuantify
    end
    def summation_matrix(allTasksListed, model)
        tasks_number = allTasksListed.size
        summation_matrix = Array.new(tasks_number){Array.new(tasks_number){0}}
        summation_matrix_column = 0     
        summation_matrix_line = 0
        model.each_with_index do |path, i|
            start = 0
            last = 1
            path.each do |task|
                if start == last && task.class != Fixnum && task.class != Bignum
                    allTasksListed.each_with_index do |task_listed, j|
                         if task == task_listed
                            find_column = 1
                            summation_matrix_column = j
                            break
                         end
                    end
                    allTasksListed.each_with_index do |task_listed, k|
                        if path[last-1] == task_listed
                            summation_matrix_line = k
                            break
                        end
                    end
                    summation_matrix_current_value = summation_matrix[summation_matrix_line][summation_matrix_column]
                    frequency = path.last
                    new_value = summation_matrix_current_value + frequency
                    summation_matrix[summation_matrix_line][summation_matrix_column] = new_value
                    last += 1
                end
                start += 1
            end
        end
        return summation_matrix
    end
    def frequency_matrix(summation_matrix, allTasksListed)
        tasks_number = allTasksListed.size
        frequency_matrix = Array.new(tasks_number){Array.new(tasks_number){0}}
        summation_matrix.each_with_index do |task_line, i|
            summation_matrix.each_with_index do |task_column, j|
                if i == j
                    x = summation_matrix[i][j].to_f
                    result = (x / (x + 1)).to_f.round(3)
                    frequency_matrix[i][j] = result
                else
                    x = summation_matrix[i][j].to_f
                    y = summation_matrix[j][i].to_f
                    result = ((x-y)/(x+y+1)).to_f.round(3)
                    frequency_matrix[i][j] = result
                end
            end
        end
        return frequency_matrix
    end
    def adjunt_matrix(summationMatrix, frequencyMatrix, allTasksListed, threshold, frequency_wish)
        summationMatrix.each_with_index do |line, i|
            summationMatrix.each_with_index do |column, j|
                if summationMatrix[i][j] < threshold
                    summationMatrix[i][j] = 0
                end
            end
        end
        frequencyMatrix.each_with_index do |line, i|
            frequencyMatrix.each_with_index do |column, j|
                if frequencyMatrix[i][j] > 0 && frequencyMatrix[i][j] < frequency_wish
                    frequencyMatrix[i][j] = 0
                elsif frequencyMatrix[i][j] < 0
                    negative_frequency_wish = frequency_wish * (-1)
                    if frequencyMatrix[i][j] > negative_frequency_wish
                        frequencyMatrix[i][j] = 0
                    end
                end
            end
        end
        adjacencyMatrix = Array.new(allTasksListed.size){Array.new(allTasksListed.size){0}}
        adjacencyMatrix.each_with_index do |line, i|
            adjacencyMatrix.each_with_index do |column, j|
                if i != j   #To exclude the laces
                    if summationMatrix[i][j] != 0 && frequencyMatrix[i][j] != 0
                        adjacencyMatrix[i][j] = 1
                    end
                end
            end
        end
        return adjacencyMatrix
    end
    def get_next_node(adjacencyMatrix, number_of_nodes, node)
        next_node = Array.new
        for j in 0..number_of_nodes
          next_node << j if (adjacencyMatrix[node][j] == 1)
        end
        #returns any nodes found OR return false if doesn't find any nodes
        next_node.length >= 1 ? (return next_node) : (return nil)
    end
    def map_path(adjacencyMatrix, number_of_nodes, paths, current_path)
        node = paths[current_path].last
        while next_node = get_next_node(adjacencyMatrix, number_of_nodes, node)
        #checks if only one node was returned
            if (next_node.length == 1)
                paths[current_path] << next_node.first
                #looks for loops by verifying if the current path doesn't include the next node
                #stops the while if a loop is found in the path
                break if paths[current_path].take(paths[current_path].length-1).include?(next_node.first)
                #if more than one node is returned, a gateway was found
            elsif (next_node.length > 1)
                #creates n clones of the current path; n is the number of choices of the gateway -1
                for i in 1...next_node.length
                    paths << paths[current_path].clone
                    paths.last << next_node[i]
                end
                #adds the first choice of the gateway to the current path
                paths[current_path] << next_node.first
            end
            node = paths[current_path].last
        end
    end
    def list_path(adjacencyMatrix)      
        #main variables used in this algorithm
        number_of_nodes = adjacencyMatrix[0].length-1
        current_path = 0 #first path
        paths = Array.new(1){Array.new(1){0}} #Array of arrays, containing one array with 0 as its only value
        #tries to access the current_path in paths listing: it'll only work if its exists
        while paths[current_path]
            map_path(adjacencyMatrix, number_of_nodes, paths, current_path)
            current_path += 1 #after finishing, it'll try to map the next path
        end
        return paths 
    end
end