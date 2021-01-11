-- Copyright (C) 2020 David Vogel
--
-- This file is part of D3bot.
--
-- D3bot is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- D3bot is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with D3bot.  If not, see <http://www.gnu.org/licenses/>.

local D3bot = D3bot
local RENDER_UTIL = D3bot.RenderUtil

-- A list of matrices that rotate something to all 6 sides of a cube.
local matricesRot6Sided = {Matrix(), Matrix(), Matrix(), Matrix(), Matrix(), Matrix()}
matricesRot6Sided[1]:Rotate(Angle(0, 0, 0))
matricesRot6Sided[2]:Rotate(Angle(0, 180, 0))
matricesRot6Sided[3]:Rotate(Angle(0, 90, 0))
matricesRot6Sided[4]:Rotate(Angle(0, 270, 0))
matricesRot6Sided[5]:Rotate(Angle(90, 0, 0))
matricesRot6Sided[6]:Rotate(Angle(-90, 0, 0))

-- Draws a 3D arrow (pyramid) pointing in positive x direction.
-- The tip is at Vector(0,0,0).
local Draw3DArrowP1, Draw3DArrowP2, Draw3DArrowP3, Draw3DArrowP4, Draw3DArrowP5 = Vector(0,0,0), Vector(-1,1,1), Vector(-1,1,-1), Vector(-1,-1,-1), Vector(-1,-1,1)
function RENDER_UTIL.Draw3DArrow(color)
	render.DrawQuad(Draw3DArrowP1, Draw3DArrowP2, Draw3DArrowP3, Draw3DArrowP4, color)
	render.DrawQuad(Draw3DArrowP1, Draw3DArrowP4, Draw3DArrowP5, Draw3DArrowP2, color)
	render.DrawQuad(Draw3DArrowP5, Draw3DArrowP4, Draw3DArrowP3, Draw3DArrowP2, color)
end

-- Draws a spinning 3D cursor.
-- This is basically 6 arrows pointing inwards.
function RENDER_UTIL.Draw3DCursor(colorA, colorB)
	local omega = CurTime() * math.pi * 2 * 0.5

	local mat = Matrix()
	mat:Rotate(Angle(math.sin(omega*0.8)*180, math.sin(omega*0.7)*180, math.sin(omega*0.6)*180))

	cam.PushModelMatrix(mat, true)
	for i, mat in ipairs(matricesRot6Sided) do
		local even = i % 2 == 0
		local mat = Matrix(mat)

		mat:Scale(Vector(5, 1, 1))
		--mat:Translate(Vector(math.sin(omega*3)*0.5-0.5, 0, 0))

		cam.PushModelMatrix(mat, true)
		RENDER_UTIL.Draw3DArrow(even and colorA or colorB)
		cam.PopModelMatrix()
	end
	cam.PopModelMatrix()
end

-- Draws a spinning 3D cursor at given position.
-- This is basically 6 arrows pointing inwards.
function RENDER_UTIL.Draw3DCursorPos(pos, size, colorA, colorB)
	local omega = CurTime() * math.pi * 2 * 0.5

	local mat = Matrix()
	mat:Translate(pos)
	mat:Scale(Vector(size, size, size))
	mat:Rotate(Angle(math.sin(omega*0.8)*180, math.sin(omega*0.7)*180, math.sin(omega*0.6)*180))

	cam.PushModelMatrix(mat, true)
	for i, mat in ipairs(matricesRot6Sided) do
		local even = i % 2 == 0
		local mat = Matrix(mat)

		mat:Scale(Vector(5, 1, 1))
		--mat:Translate(Vector(math.sin(omega*3)*0.5-0.5, 0, 0))

		cam.PushModelMatrix(mat, true)
		RENDER_UTIL.Draw3DArrow(even and colorA or colorB)
		cam.PopModelMatrix()
	end
	cam.PopModelMatrix()
end