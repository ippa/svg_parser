#!/usr/bin/env ruby
$: << "../"
require 'svg_parser'
require 'gosu_game_common'

require 'rubygems'
require 'RMagick'
require 'chipmunk'
require 'gosu'
include Gosu


SCREEN_WIDTH = 1024
SCREEN_HEIGHT = 768
SUBSTEPS = 6

class GameWindow < Gosu::Window
  def initialize
    $screen = super(800, 600, false)
		
		#
		# Since there's some odd shapes in this SVG collision isn't working (only convex polygons with chipmunk)
		#
		@game_objects = []
		@game_objects << PathObject.new(:x => 100, :y => 0, :id => :boulder)
		@game_objects << PathObject.new(:x => 300, :y => 0, :id => :triangle)
		@game_objects << PathObject.new(:x => 400, :y => 200, :id => :hat)
		@game_objects << PathObject.new(:x => 600, :y => 200, :id => :thing)
		@game_objects << RectObject.new(:x => 100, :y => 300, :id => :rect)

    @dt = (1.0/60.0)
		@space = CP::Space.new
    @space.damping = 0.9
		@space.gravity = CP::Vec2.new(0, 1.5)
    
		@game_objects.each do |game_object|
			@space.add_body(game_object.body)
			@space.add_shape(game_object.shape)		
		end
	end
	
	def update
		SUBSTEPS.times do
			@game_objects.each { |game_object| game_object.shape.body.reset_forces }
			@space.step(@dt)
		end
	end
	
	def draw
		@game_objects.each { |game_object| game_object.draw }
	end
	
	def button_down(id)
		close								if id == Button::KbEscape	
  end
	
end

class GameObject
	attr_reader :shape, :body
	
  def initialize(options = {})		
		@x = options[:x] || 100.0
		@y = options[:y] || 200.0
		@id = options[:id] || nil
		@color = Gosu::Color.new(255,255,255,255)
		
		#
		# Standard chipmunk stuff
		# Only interesting part here is @points.to_chipmunk which returns the points in chipmunks vec2-format
		#
		@body = CP::Body.new(Float::MAX, Float::MAX)
    @shape = CP::Shape::Poly.new(@body, @points.to_chipmunk, CP::Vec2.new(@x, @y))
    @shape.body.p = vec2(@x, @y) 		# position
    @shape.body.v = vec2(0.0, 0.0) 	# velocity
		@shape.e = 1
		@shape.u = 1
		@shape.collision_type = self.class.to_s.to_sym
		@shape.body.a = (3*Math::PI/2.0) # angle in radians; faces towards top of screen
	
		#
		# Just a simple helper to materelize our polygon using rmagick
		#
		@image = polygon_to_image(@points, @points.size)
	end
	
	def polygon_to_image(polygon, size)
		drawing = Magick::Draw.new
    drawing.stroke_width(1)
    drawing.stroke('black')
    drawing.fill('gray')
	
		#
		# rmagick wants it's polyon in it's own format
		#
		#magick_polygon = polygon.collect { |point| [point.x, point.y] }.flatten		
		#drawing.polygon(*magick_polygon)
		drawing.polygon(*polygon.points.flatten)
		
		magick_image = Magick::Image.new(*size) { self.background_color = 'transparent' }
		drawing.draw(magick_image)
		
		image = Gosu::Image.new($screen, magick_image, true)
		
		return image
	end
	
	def draw
		@image.draw_rot(@body.p.x, @body.p.y, 0, @body.a.radians_to_gosu, 0, 0)
	end
end

class PathObject < GameObject
	def initialize(options = {})
		@id = options[:id] || nil	
		# Open a SVG-file, get the points for "path" with id @id
		# Normalize the points/coordinates (meaning the leftmost coordinate will have x=0, same with top)
		@points = SVGParser.new("inkscape_objects.svg").path(@id).normalize!
		super
	end
end

class RectObject < GameObject
	def initialize(options = {})
		@id = options[:id] || nil	
		# Open a SVG-file, get the points for "rect" with id @id
		# Normalize the points/coordinates (meaning the leftmost coordinate will have x=0, same with top)
		@points = SVGParser.new("inkscape_objects.svg").rect(@id).normalize!
		super
	end
end

GameWindow.new.show