#!/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'rexml/parsers/baseparser'

class Xes
    include REXML
    def initialize(xesFile)
        @xes_parser = Parsers::BaseParser.new(xesFile) 
    end
    def read_xes
        listEvents = Array.new  
        control_trace = 0
        control_event = 0
        while @xes_parser.has_next?
            x = @xes_parser.pull
            if x.first.to_s == 'start_element' && x[1].to_s == 'trace'
                control_trace = 1
                listEvents << ['start_trace']
            end
            if control_trace != 0
                listEvents << x
                if x.first.to_s == 'end_element' && x[1].to_s == 'trace'
                    control_trace = 0
                    listEvents << ['end_trace']
                end
            end
        end
        listHashEvents = Array.new
        listEvents.each do |event|
            event.each do |element|
                if element == 'start_trace' || element == 'end_trace'
                    listHashEvents << element
                elsif element.class == Hash
                    listHashEvents << element
                end
            end
        end
        listTasks = Array.new
        listHashEvents.each do |task|
            if task == 'start_trace'
                @trace = Array.new
            elsif task["key"] == 'concept:name'
                @trace << task["value"].upcase
            elsif task == 'end_trace'
                listTasks << @trace
            end
        end
        listTraces = Array.new      #Created only to calculate the quantify of traces and to see the names of the traces in the log
        listTasks.each do |task_groups|
            listTraces << task_groups.shift
        end
        return listTasks
    end
end