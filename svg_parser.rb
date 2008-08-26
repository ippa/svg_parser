#!/usr/bin/env ruby
require 'hpricot'
require 'gosu'		rescue nil
require 'points'

#
# SVGParser - Reads out info from a SVGfile
# 
# Currently it it reads out the coordinates for
# Coordinates for a certain id is stored using Points-class which in turn enables .to_chipmunk, .normalize! etc
#
#
class SVGParser
	attr_reader :filename, :paths
	def initialize(filename)
		@filename = filename
		
		@fh = @filename				if @filename.is_a? File
		@fh = open(@filename)	if @filename.is_a? String
		
		@paths = Hash.new
		@rects = Hash.new
		
		@doc = Hpricot(@fh)
	end

	def inspect; @doc; end
	def to_s;	@doc.to_s;	end

	#
	# Get points for a "path" (inkscape Shift+F6) with a certain id
	#
	def rect(id)
		points = Points.new
		
		if rect = @doc.at("//g rect[@id='#{id.to_s}']")
			#
			# Generate all the points in a rectangle
			#
			top_left = [rect[:x].to_f, rect[:y].to_f]
			top_right = [rect[:x].to_f + rect[:width].to_f, rect[:y].to_f ]
			bottom_right = [rect[:x].to_f + rect[:width].to_f, rect[:y].to_f + rect[:height].to_f ]
			bottom_left = [rect[:x].to_f, rect[:y].to_f + rect[:height].to_f ]
			points << top_left
			points << top_right
			points <<  bottom_right
			points << bottom_left
			points << top_left
		end
		
		puts points.inspect
		puts
		@rects[id.to_sym] = points
	end


	#
	# Get points for a "path" (inkscape Shift+F6) with a certain id
	#
	def path(id)
		points = Points.new
		
		if path = @doc.at("//g path[@id='#{id.to_s}']")
			path[:d].split(" ").each do |point|	
				x, y = point.split(",")
				points << [x.to_f, y.to_f]	if x and y
			end
		end
		puts points.inspect
		puts
		@paths[id.to_sym] = points
	end

end
	
