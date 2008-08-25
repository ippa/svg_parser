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
		
		@doc = Hpricot(@fh)
	end

	def inspect; @doc; end
	def to_s;	@doc.to_s;	end
	
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
		
		@paths[id.to_sym] = points
	end

end
	
