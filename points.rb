#!/usr/bin/env ruby
#require 'gosu'		rescue nil

#
# Class to create a array of points (to use with draw_polygon*) in an easy and natural way.	
#
# Example of drawing a flat green 10pixel thick terrain with a 20x20 bump on:
#
# points = Points.new(0,0)
# points.up(10).right(100).up(20).right(20).down(20).right(20).down(10).to(0,0)
# surface.draw_polygon_s(points, Color[:green])
#
class Points
	attr_reader :points
	def initialize(x=nil, y=nil)
		@x = x	if x
		@y = y	if y
		
		@points = []
		@points = [[@x, @y]]	if @x and @y
	end

	def inspect
		@points.inspect
	end
		
	def to_x(x)
		@x = x
		add_current_point
		self
	end
	def to_y(y)
		@y = y
		add_current_point
		self
	end
	def up(amount)
		@y += amount
		add_current_point
		self
	end
	def down(amount)
		@y -= amount
		add_current_point
		self
	end
	def left(amount)
		@x -= amount
		add_current_point
		self
	end
	def right(amount)
		@x += amount
		add_current_point
		self
	end
	def move(x, y)
		@x += x
		@y += y
		add_current_point
		self
	end
	def to(x, y)
		@x = x
		@y = y
		add_current_point
		self
	end
		
	def to_a
		@screen_coords
	end
	def to_screen_coords(screen_height)
		@screen_coords = []
		@points.each do |x, y|
			@screen_coords << [x, (screen_height - y)]
		end
		@screen_coords
	end
		
	def <<(point)
		@points << point
	end
	
	#
	# Returns size as an array [width, height]
	#
	def size
		x,y = 0,0
		@points.each do |point|
			x = point[0]	if point[0] > x
			y = point[1]	if point[1] > y
		end
		return [x,y]
	end
		
	def normalize!
		lowest_x = lowest_y = nil

		@points.each do |point|
			lowest_x ||= point[0]
			lowest_y ||= point[1]
			
			lowest_x = point[0]		if point[0] < lowest_x and point[0] > 0
			lowest_y = point[1]		if point[1] < lowest_y and point[1] > 0
		end
		@points.each do |point|
			point[0] -= lowest_x
			point[1] -= lowest_y
		end
		self
	end
		
	#
	# Returns all points in chipmunks vec2-format
	#
	def to_chipmunk
		@points.collect { |point| vec2(point[0].to_i,point[1].to_i)}
	end
	
	
	private
	
	def add_current_point
		@points << [@x, @y]
	end
end
	
