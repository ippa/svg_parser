# Convenience methods for converting between Gosu degrees, radians, and Vec2 vectors
class Numeric 
  def gosu_to_radians
    (self - 90) * Math::PI / 180.0
  end
  
  def radians_to_gosu
    self * 180.0 / Math::PI + 90
  end
  
  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end

#
# When a missing method is called on an array...
# .. Go through each item in the array and call that method on the items.
#
class Array
	def collide_by_radius(items = [])
		self.each do |item|
			items.each do |item2|
				if distance(item.x, item.y, item2.x, item2.y) < item.radius
					yield item, item2
				end
			end
		end
	end

	def method_missing(method, *arg)
		self.each { |item| item.send(method, *arg) }
	end
end