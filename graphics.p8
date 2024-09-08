--- @module graphics
--- Drawing and sprite manipulation
-- @author by sparr


-- any function with a color parameter can add the following line
-- to make the color optional and use the pen color by default:
-- c = c or peek(24357) & 15


--- Draw a line connecting two points
-- uses Bresenham's line drawing algorithm
-- @tparam number x1 X coordinate of starting point of the line
-- @tparam number y1 Y coordinate of starting point of the line
-- @tparam number x2 X coordinate of ending point of the line
-- @tparam number y2 Y coordinate of ending point of the line
-- @tparam number c Color of the line
local function line_(x1, y1, x2, y2, c)
 local dx, dy, sx, sy = abs(x2 - x1), -abs(y2 - y1), x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
 local e = dx + dy
 pset(x1, y1, c)
 while x1 ~= x2 or y1 ~= y2 do
  local t = 2 * e
  if t > dy then
   e = e + dy
   x1 = x1 + sx
  end
  if t < dx then
   e = e + dx
   y1 = y1 + sy
  end
  pset(x1, y1, c)
 end
end


--- Draw a fat line connecting two points
-- uses Bresenham's line drawing algorithm and rectfill
-- @tparam number x1 x coordinate of starting point
-- @tparam number y1 y coordinate of starting point
-- @tparam number x2 x coordinate of ending point
-- @tparam number y2 y coordinate of ending point
-- @tparam number fx width of line pixels (east of the original line)
-- @tparam number fy height of line pixels (south of the original line)
-- @tparam number c color
local function line_fat(x1, y1, x2, y2, fx, fy, c)
 local dx, dy, sx, sy = abs(x2 - x1), -abs(y2 - y1), x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
 local e = dx + dy
 rectfill(x1, y1, x1 + fx - 1, y1 + fy - 1, c)
 while x1 ~= x2 or y1 ~= y2 do
  local t = 2 * e
  if t > dy then
   e = e + dy
   x1 = x1 + sx
  end
  if t < dx then
   e = e + dx
   y1 = y1 + sy
  end
  rectfill(x1, y1, x1 + fx - 1, y1 + fy - 1, c)
 end
end


--- Draw a line connecting two points using a custom draw function
-- uses Bresenham's line drawing algorithm and the custom function for each point on the line
-- line_func(...,pset) is equivalent to line_(...)
-- @tparam number x1 x coordinate of starting point
-- @tparam number y1 y coordinate of starting point
-- @tparam number x2 x coordinate of ending point
-- @tparam number y2 y coordinate of ending point
-- @tparam function f function to call for each pixel of the line
-- @tparam number c color
local function line_func(x1, y1, x2, y2, f, c)
 local dx, dy, sx, sy = abs(x2 - x1), -abs(y2 - y1), x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
 local p, e = 1, dx + dy
 f(x1, y1, c, p)
 while x1 ~= x2 or y1 ~= y2 do
  p += 1
  local t = 2 * e
  if t > dy then
   e = e + dy
   x1 = x1 + sx
  end
  if t < dx then
   e = e + dx
   y1 = y1 + sy
  end
  f(x1, y1, c, p)
 end
end


--- draw a 4x4 sprite
-- @tparam number s sprite index
-- @tparam number x x coordinate for sprite placement
-- @tparam number y y coordinate for sprite placement
local function spr4_fast(s, x, y)
 sspr(s % 32 * 4, flr(s / 32) * 4, 4, 4, x, y)
end

--- draw a 4x4 sprite with additional sspr() options
-- 2.5x the runtime of spr4_fast()
-- @tparam number s sprite index
-- @tparam number x x coordinate for sprite placement
-- @tparam number y y coordinate for sprite placement
-- @tparam[opt=4] number w width to scale the sprite
-- @tparam[opt=4] number h height to scale the sprite
-- @tparam[opt=false] bool flip_h flip the sprite horizontally
-- @tparam[opt=false] bool flip_v flip the sprite vertically
local function spr4(s, x, y, w, h, ...)
 sspr(s % 32 * 4, flr(s / 32) * 4, 4, 4, x, y, w or 4, h or 4, ...)
end


--- draw a circle of even diameter (2-16)
-- @tparam number s sprite index
-- @tparam number x x coordinate, top left corner of bounding box
-- @tparam number y y coordinate, top left corner of bounding box
-- @tparam number r radius (1-8)
-- @tparam number c color
-- necessary sprite:
-- 00000888
-- 00088077
-- 00807766
-- 08076655
-- 08760544
-- 80765433
-- 87654302
-- 87654321
local function circ_even(s, x, y, r, c)
 -- if (r < 1 or r > 8) return -- [optional] safety
 -- todo optional code to preserve pal/palt state
 palt(0xFFFF ^^ 1<<(15-r))
 pal(r, c)
 for i = 0, 1 do
  for j = 0, 1 do
   spr(s, x + i * 8 - 8 + r, y + j * 8 - 8 + r, 1, 1, i > 0, j > 0)
  end
 end
 pal() -- optional if other code makes no expectations about palette or transparency
end

--- draw a filled circle of even diameter (2-16)
-- @tparam number s sprite index
-- @tparam number x x coordinate, top left corner of bounding
-- @tparam number y y coordinate, top left corner of bounding
-- @tparam number r radius (1-8)
-- @tparam number c color
-- necessary sprite:
-- 00000888
-- 00088877
-- 00887766
-- 08876655
-- 08766544
-- 88765433
-- 87654332
-- 87654321
local function circfill_even(s, x, y, r, c)
 -- if (r < 1 or r > 8) return -- [optional] safety
 -- todo optional code to preserve pal/palt state
 for t = 1, 8 do
  palt(t, r < t)
  pal(t, c)
 end
 for i = 0, 1 do
  for j = 0, 1 do
   spr(s, x + i * 8 - 8 + r, y + j * 8 - 8 + r, 1, 1, i > 0, j > 0)
  end
 end
 pal() -- optional if other code makes no expectations about palette or transparency
end


--- draw a small circle of even diameter (2-8)
-- @tparam number s sprite index
-- @tparam number x x coordinate, top left corner of bounding
-- @tparam number y y coordinate, top left corner of bounding
-- @tparam number r radius (1-4)
-- @tparam number c color
-- necessary sprite:
-- 00444400
-- 04033040
-- 40322304
-- 43211234
-- 43211234
-- 40322304
-- 04033040
-- 00444400
local function circ_even_small(s, x, y, r, c)
 -- if (r < 1 or r > 4) return -- [optional] safety
 -- todo optional code to preserve pal/palt state
 palt(0xFFFF ^^ 1<<(15-r))
 pal(r, c)
 spr(s, x - 4 + r, y - 4 + r)
 pal() -- optional if other code makes no expectations about transparency
end


--- draw a small filled circle of even diameter (2-8)
-- @tparam number s sprite index
-- @tparam number x x coordinate, top left corner of bounding
-- @tparam number y y coordinate, top left corner of bounding
-- @tparam number r radius (1-4)
-- @tparam number c color
-- necessary sprite:
-- 00444400
-- 04433440
-- 44322344
-- 43211234
-- 43211234
-- 44322344
-- 04433440
-- 00444400
local function circfill_even_small(s, x, y, r, c)
 -- if (r < 1 or r > 4) return -- [optional] safety
 -- todo optional code to preserve pal/palt state
 for t = 1, 4 do
  palt(t, r < t)
  pal(t, c)
 end
 spr(s, x - 4 + r, y - 4 + r)
 pal() -- optional if other code makes no expectations about transparency
end


------------------------------------------------------------------------
local function flrceil(x, d) return d * flr(x*d) end
-- draws every pixel outside a given circle
-- fixme does not match circ/circfill boundary exactly
local function circinverse(x, y, r, c)
 -- -1 and 128 are rectangle bounds
 -- outside the screen so that we don't accidentally draw borders when the other coordinate is also outside
 for lrr = -1, 128, 129 do
  -- -1 and +1 are used to draw mirror images of the bounding rectangles
  local lr = sgn(lrr)
  rectfill(-1, lrr, 128, flrceil(y + (r + 1) * lr, -lr), c) -- big top/bottom rectangles
  -- flrceil from math.p8
  rectfill(flrceil(x + (r + 1) * lr, -lr), flrceil(y - r * lr, lr), lrr, flrceil(y + r * lr, -lr), c) -- smaller side rectangles
 end
 -- cx and cy are coordinates relative to the center that walk from east to southheast
 -- following the bresenham circle algorithm
 local cx, cy, rs = flrceil(r, -1), 0, (r + 0.5) * (r + 0.5)
 while cy <= cx do
  if cy * cy + cx * cx > rs then
   -- only draw lines and decrement cx when cy has moved enough to get outside the circle (bresenham algorithm)
   -- again -1 and +1 are used to draw mirror images
   for dx = -1, 1, 2 do
    for dy = -1, 1, 2 do
     -- todo switch to line() if it ever benchmarks faster than rectfill here
     rectfill(flrceil(x + cx * dx, dx), flrceil(y + cy * dy, dy), flrceil(x + cx * dx, dx), flrceil(y + r * dy - (r - cx) * dy, dy), c) -- vertical lines
     if (cy < cx) rectfill(flrceil(x + cy * dx, dx), flrceil(y + cx * dy, dy), flrceil(x + (cx - 1) * dx, dx), flrceil(y + cx * dy, dy), c) -- horizontal lines
    end
   end
   cx -= 1
  end
  cy += 1
 end
end


------------------------------------------------------------------------
-- draws every pixel outside a given rectangle
local function rectinverse(x, y, i, j, c)
 if (x > i) x, i = i, x
 if (y > j) y, j = j, y
 rectfill(-1, -1, 128, y - 1, c)
 rectfill(-1, 128, 128, j + 1, c)
 rectfill(-1, y, x - 1, j, c)
 rectfill(128, y, i + 1, j, c)
end


------------------------------------------------------------------------
-- fillp with support for x/y offsets to shift the mask
-- original algorithm from https://www.lexaloffle.com/bbs/?tid=30518
local _fillp = fillp
local function fillp(p, x, y)
 local p, x, y = p or 0, x or 0, y or 0 -- remove[13,36] backward compatibility with fillp(p)
 local p16, x = flr(p), x & 3
 local f, p32 = flr(shr(15, x)) * 0x1111, rotr(p16 + lshr(p16, 16), (y & 3) * 4 + x)
 return _fillp(p - p16 + flr(p32 & f) + (rotl(p32, 4) & (0xffff - f)))
end


------------------------------------------------------------------------
-- draw a filled ellipse
-- by @freds72
-- https://www.lexaloffle.com/bbs/?tid=35124
-- permission to share from freds72 on discord
-- find roots of a rotated ellipse
-- and use that to rectfill interior
-- x0/y0: ellipse center
-- h/w: height/width
-- angle
-- c: color
local function ellipsefill(x0, y0, w, h, angle, c)
 local asq, bsq = w * w, h * h

 -- max. extent
 local ab = max(w, h)

 local cc, ss = cos(angle), sin(angle)
 local csq , ssq = cc * cc, ss * ss
 local rb0 = shl(cc * ss * (1 / asq - 1 / bsq), 1)
 local rc0 = ssq / asq + csq / bsq
 local ra = shl(csq / asq + ssq / bsq, 1)

 for y = max(y0 - ab, 0), min(y0 + ab, 127) do
  -- roots
  local yy = y - y0 + 0.5
  local rb, rc = rb0 * yy, yy * yy * rc0 - 1

  local r = rb * rb - shl(ra * rc, 1)
  if r == 0 then
   pset(x0 - rb / ra, y, c)
  elseif r > 0 then
   r = r ^ 0.5
   rectfill(x0 + (-rb + r) / ra, y, x0 + (-rb - r) / ra, y, c)
  end
 end
end


------------------------------------------------------------------------
-- "green screen" function
-- replaces pixels of color c in rectangle x1,y1,x2,y2 with output of drawfunc
-- initial version from https://www.lexaloffle.com/bbs/?tid=36813
-- todo version that uses peek/poke for faster handling of large contiguous "green" pixels
function chromakey(drawfunc, x1, y1, x2, y2, c)
    -- -- c defaults to 3
    -- c = c or 3
    -- load prior clip state
    local clip_x1, clip_y1, clip_x2, clip_y2 = peek(0x5f20), peek(0x5f21), peek(0x5f22), peek(0x5f23)

    -- squeeze chromakey rectangle into clipping region
    x1, y1, x2, y2 = max(x1, clip_x1), max(y1, clip_y1), min(x2, clip_x2 + x1), min(y2, clip_y2 + y1)

    for ys = y1, y2 do
        local x0, chroma = x1
        for xs = x1, x2 do
            if pget(xs, ys) == c then
                if not chroma then
                    -- start detecting
                    chroma = 1
                    x0 = xs
                end
            elseif chroma then
                -- stop detecting and draw rectangle
                clip(x0, ys, xs - x0, 1)
                drawfunc(x0, ys, xs - 1, ys)
                chroma = nil
                clip()
            end
        end
        if chroma then
            -- c extended to end of row
            clip(x0, ys, x2 - x1 - x0, 1)
            drawfunc(x0, ys, x2, ys)
            clip()
        end

    end

    -- reset clipping region
    clip(clip_x1, clip_y1, clip_x2 - clip_x1, clip_y2 - clip_y1)
end


------------------------------------------------------------------------
-- takes a string and width describing a map, two hex digits per tile
-- draws the map, with other parameters same as map()
-- example "0123456789abcdef",4 represents this 4x2 map:
-- [[0x01,0x23,0x45,0x67],[0x89,0xab,0xcd,0xef]]
function mapstring(mapstr, mapw, celx, cely, sx, sy, celw, celh, layer)
 -- remove[] to save tokens by making parameters mandatory
 mapstr, celx, cely, sx, sy, celw, celh, layer =
 mapstr or "", celx or 0, cely or 0, sx or 0, sy or 0, celw or 1, celh or 1, layer or 0
 for y = cely, cely + celh - 1 do
  for x = celx, celx + celw - 1 do
   local sprnum = tonum("0x" .. sub(mapstr, (y * mapw + x) * 2 + 1, (y * mapw + x) * 2 + 2))
   if sprnum > 0 and layer & fget(sprnum) == layer then
    spr(sprnum, sx + (x - celx) * 8, sy + (y - cely) * 8)
   end
  end
 end
end


------------------------------------------------------------------------
-- takes a string and width describing a map, two hex digits per tile
-- replaces existing map data, starting at celx,cely in the main map space
-- example: string_to_map("0123456789ab",3,2,1) will do the following:
-- mset(2,1,0x01) mset(3,1,0x23) mset(4,1,0x45)
-- mset(2,2,0x56) mset(3,2,0x89) mset(4,2,0xab)
function string_to_map(mapstr, mapw, celx, cely)
 -- remove[] to save tokens by making parameters mandatory
 mapstr, mapw, celx, cely = mapstr or "", mapw or #mapstr/2, celx or 0, cely or 0
 for y = 0, #mapstr/mapw/2-1 do
  for x = 0, mapw-1 do
   mset(celx + x, cely + y, tonum("0x" .. sub(mapstr, (y * mapw + x) * 2 + 1, (y * mapw + x) * 2 + 2)))
  end
 end
end


------------------------------------------------------------------------
-- print string with a shadow
-- constant one pixel southeast shadow
function print_shadow(string, x, y, col, bcol)
 ?string, x + 1, y + 1, bcol
 ?string, x, y, col
end
-- optional dx, dy for shadow placement
function print_shadow(string, x, y, col, bcol, dx, dy)
 ?string, x + (dx or 1), y + (dy or 1), bcol
 ?string, x, y, col
end


------------------------------------------------------------------------
-- print string with an outline
-- originally by cbmakes
-- 4-direction outline
function print_border_4(string, x, y, col, bcol)
 for d = -1, 1, 2 do
  ?string, x + d, y, bcol
  ?string, x, y + d, bcol
 end
 ?string, x, y, col
end
-- 8-direction outline
function print_border_8(string, x, y, col, bcol)
 for j = -1, 1 do
  -- 10% faster, costs 8 tokens
  -- for i = -1, 1, j == 0 and 2 or 1 do
  for i = -1, 1 do
   ?string, x + i, y + j, bcol
  end
 end
 ?string, x, y, col
end


------------------------------------------------------------------------
-- wrap any drawing function in a fillp()
-- replace this:
-- fillp(1234)rect(5,6,7,8,9)fillp()
-- with this:
-- drawp(1234,rect,5,6,7,8,9)
-- saves 3 tokens, 7-11 bytes per call
-- function is 14-17 tokens, 55-61 bytes
-- break even after 5-9 calls
function drawp(p,func,...)
 -- fillp(p) save three tokens by not saving and restoring the previous pattern
 p = fillp(p)
 func(...)
 -- fillp()
 fillp(p)
end

__gfx__
0000000000000888000008880044440000444400
0000000000088077000888770433334004333340
0000000000807766008877664302203443322334
0000000008076655088766554321123443211234
0000000008760544087665444321123443211234
0000000080765433887654334302203443322334
0000000087654302876543320433334004333340
0000000087654321876543210044440000444400
