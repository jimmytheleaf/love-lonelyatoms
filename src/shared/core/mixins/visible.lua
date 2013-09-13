require 'external.middleclass'
require 'core.color'
require 'core.mixins.movable'

Visible = {}

function Visible.visibleInit(self)
	--assert(includes(Movable, self), "Must be a Movable to be able to be visible")
	self.visible = true
	self.img = nil
	self.color = Color(0, 0, 0, 255)
	self.fill_mode = 'fill'
end


function Visible.draw(self)

	--[[
	if self.img then
		love.graphics.draw(self.img, self.shape.position.x, self.transform.position.y, self.width, self.height)
	else
		love.graphics.setColor(self.fill[1], self.fill[2], self.fill[3])
		love.graphics.rectangle("fill", self.transform.position.x, self.transform.position.y, self.width, self.height)
	end
	-- ]]

	-- Leave no trace

	if self.visible then
		local r, g, b, a = love.graphics.getColor()
		
		assert(instanceOf(Color, self.color), "color must be a Color class, instead is " .. tostring(self.color))

		love.graphics.setColor(self.color:unpack())

		-- TODO -- special-case images
		self:render(self.fill_mode)

		love.graphics.setColor(r, g, b, a)
	end
end

function Visible.setImg(self, img)
	self.img = img
end

function Visible.setColor(self, r, g, b, a)
	self.color = Color(r, g, b, a)
end

function Visible.setFillMode(self, fm)
	self.fill_mode = fm
end