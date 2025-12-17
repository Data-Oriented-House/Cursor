--!strict

--[=[
	@class Cursor
	The root namespace to access the procedural api and create Cursor objects.
]=]

local OFFSET_SIZE = 4

local function getbuf(cursor: Cursor): buffer
	return cursor[1]
end

local function setbuf(cursor: Cursor, to: buffer): ()
	cursor[1] = to
end

local function getpos(buf: buffer): number
	return buffer.readu32(buf, 0)
end

local function setpos(buf: buffer, to: number): ()
	buffer.writeu32(buf, 0, to)
end

--[=[
	@within Cursor
	Checks if the cursor needs to be reallocated after adding `bytes` bytes. If so, it reallocates 2x the size and swaps out the buffer.
]=]
local function tryrealloc(cursor: Cursor, bytes: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	local len = buffer.len(buf)
	local targetlen = pos + bytes
	if len < targetlen then
		repeat
			len *= 2
		until len > targetlen
		local oldbuf = buf
		buf = buffer.create(len)
		buffer.copy(buf, 0, oldbuf, 0, pos)
		setbuf(cursor, buf)
	end
end

--[=[
	@within Cursor
]=]
local function pushu1(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 1)
	buffer.writeu8(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popu1(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 1
	setpos(buf, pos)
	return buffer.readu8(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushu2(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 2)
	buffer.writeu16(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popu2(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 2
	setpos(buf, pos)
	return buffer.readu16(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushu3(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 3)
	buffer.writeu8(buf, pos, x)
	buffer.writeu16(buf, pos + 1, x // 256)
end

--[=[
	@within Cursor
]=]
local function popu3(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 3
	local x1 = buffer.readu8(buf, pos)
	local x2 = buffer.readu16(buf, pos + 1)
	setpos(buf, pos)
	return x1 + x2 * 256
end

--[=[
	@within Cursor
]=]
local function pushu4(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 4)
	buffer.writeu32(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popu4(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 4
	setpos(buf, pos)
	return buffer.readu32(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushu5(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 5)
	buffer.writeu8(buf, pos, x)
	buffer.writeu32(buf, pos + 1, x // 256)
end

--[=[
	@within Cursor
]=]
local function popu5(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 5
	local x1 = buffer.readu8(buf, pos)
	local x2 = buffer.readu32(buf, pos + 1)
	setpos(buf, pos)
	return x1 + x2 * 256
end

--[=[
	@within Cursor
]=]
local function pushu6(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 6)
	buffer.writeu16(buf, pos, x)
	buffer.writeu32(buf, pos + 2, x // (256 ^ 2))
end

--[=[
	@within Cursor
]=]
local function popu6(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 6
	local x1 = buffer.readu16(buf, pos)
	local x2 = buffer.readu32(buf, pos + 2)
	setpos(buf, pos)
	return x1 + x2 * (256 ^ 2)
end

--[=[
	@within Cursor
]=]
local function pushu7(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 7)
	buffer.writeu8(buf, pos, x)
	buffer.writeu16(buf, pos + 1, x // 256)
	buffer.writeu32(buf, pos + 3, x // (256 ^ 3))
end

--[=[
	@within Cursor
]=]
local function popu7(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 7
	local x1 = buffer.readu8(buf, pos)
	local x2 = buffer.readu16(buf, pos + 1)
	local x3 = buffer.readu32(buf, pos + 3)
	setpos(buf, pos)
	return x1 + x2 * 256 + x3 * (256 ^ 3)
end

--[=[
	@within Cursor
]=]
local function pushu8(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 8)
	buffer.writeu32(buf, pos, x)
	buffer.writeu32(buf, pos + 4, x // (256 ^ 4))
end

--[=[
	@within Cursor
]=]
local function popu8(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 8
	local x1 = buffer.readu32(buf, pos)
	local x2 = buffer.readu32(buf, pos + 4)
	setpos(buf, pos)
	return x1 + x2 * (256 ^ 4)
end

--[=[
	@within Cursor
]=]
local function pushi1(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 1)
	buffer.writei8(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popi1(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 1
	setpos(buf, pos)
	return buffer.readi8(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushi2(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 2)
	buffer.writei16(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popi2(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 2
	setpos(buf, pos)
	return buffer.readi16(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushi3(cursor: Cursor, x: number): ()
	x %= 2 ^ 24
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 3)
	buffer.writeu8(buf, pos, x % 256)
	buffer.writeu16(buf, pos + 1, x / 256)
end

--[=[
	@within Cursor
]=]
local function popi3(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 3
	local x1 = buffer.readu8(buf, pos)
	local x2 = buffer.readu16(buf, pos + 1)
	setpos(buf, pos)
	local x = x1 + x2 * 256
	return if x >= 2 ^ 23 then x - (2 ^ 24) else x
end

--[=[
	@within Cursor
]=]
local function pushi4(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 4)
	buffer.writei32(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popi4(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 4
	setpos(buf, pos)
	return buffer.readi32(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushi5(cursor: Cursor, x: number): ()
	x %= 2 ^ 40
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 5)
	buffer.writeu8(buf, pos, x)
	buffer.writeu32(buf, pos + 1, x / 256)
end

--[=[
	@within Cursor
]=]
local function popi5(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 5
	setpos(buf, pos)
	local x1 = buffer.readu8(buf, pos)
	local x2 = buffer.readu32(buf, pos + 1)
	local x = x1 + x2 * 256
	return if x >= 2 ^ 39 then x - (2 ^ 40) else x
end

--[=[
	@within Cursor
]=]
local function pushi6(cursor: Cursor, x: number): ()
	x %= 2 ^ 48
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 6)
	buffer.writeu16(buf, pos, x)
	buffer.writeu32(buf, pos + 2, x / (256 ^ 2))
end

--[=[
	@within Cursor
]=]
local function popi6(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 6
	setpos(buf, pos)
	local x1 = buffer.readu16(buf, pos)
	local x2 = buffer.readu32(buf, pos + 2)
	local x = x1 + x2 * (256 ^ 2)
	return if x >= 2 ^ 47 then x - (2 ^ 48) else x
end

--[=[
	@within Cursor
]=]
local function pushi7(cursor: Cursor, x: number): ()
	x %= 2 ^ 56
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 7)
	buffer.writeu8(buf, pos, x)
	buffer.writeu16(buf, pos + 1, x / 256)
	buffer.writeu32(buf, pos + 3, x / (256 ^ 3))
end

--[=[
	@within Cursor
]=]
local function popi7(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 7
	setpos(buf, pos)
	local x1 = buffer.readu8(buf, pos)
	local x2 = buffer.readu16(buf, pos + 1)
	local x3 = buffer.readu32(buf, pos + 3)
	local x = x1 + x2 * 256 + x3 * (256 ^ 3)
	return if x >= 2 ^ 55 then x - (2 ^ 56) else x
end

--[=[
	@within Cursor
]=]
local function pushi8(cursor: Cursor, x: number): ()
	x %= 2 ^ 64
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 8)
	buffer.writeu32(buf, pos, x)
	buffer.writeu32(buf, pos + 4, x / (256 ^ 4))
end

--[=[
	@within Cursor
]=]
local function popi8(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 8
	setpos(buf, pos)
	local x1 = buffer.readu32(buf, pos)
	local x2 = buffer.readu32(buf, pos + 4)
	local x = x1 + x2 * (256 ^ 4)
	return if x >= 2 ^ 63 then x - (2 ^ 64) else x
end

--[=[
	@within Cursor
]=]
local function pushf4(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 4)
	buffer.writef32(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popf4(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 4
	setpos(buf, pos)
	return buffer.readf32(buf, pos)
end

--[=[
	@within Cursor
]=]
local function pushf8(cursor: Cursor, x: number): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	setpos(buf, pos + 8)
	buffer.writef64(buf, pos, x)
end

--[=[
	@within Cursor
]=]
local function popf8(cursor: Cursor): number
	local buf = getbuf(cursor)
	local pos = getpos(buf) - 8
	setpos(buf, pos)
	return buffer.readf64(buf, pos)
end

--[=[
	@within Cursor
	Packs up to 8 booleans in a single byte to make bitpacking and bitmasking trivial.
]=]
local function pushbool(
	cursor: Cursor,
	a: boolean,
	b: boolean?,
	c: boolean?,
	d: boolean?,
	e: boolean?,
	f: boolean?,
	g: boolean?,
	h: boolean?
): ()
	local y = if a then 1 else 0
	if b then
		y += 2
	end
	if c then
		y += 4
	end
	if d then
		y += 8
	end
	if e then
		y += 16
	end
	if f then
		y += 32
	end
	if g then
		y += 64
	end
	if h then
		y += 128
	end
	pushu1(cursor, y)
end

--[=[
	@within Cursor
	Pops a byte and unpacks the 8 bits as booleans.
]=]
local function popbool(cursor: Cursor): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local x = popu1(cursor)
	return x % 2 >= 1, x % 4 >= 2, x % 8 >= 4, x % 16 >= 8, x % 32 >= 16, x % 64 >= 32, x % 128 >= 64, x % 256 >= 128
end

local pushvlq, popvlq
do
	local SHIFT32 = 2 ^ 32
	local SHIFT25 = 2 ^ 25
	local BASE = 2 ^ 7

	--[=[
		@within Cursor
		A V.L.Q. is a [Variable-Length-Quantity](https://en.wikipedia.org/wiki/Variable-length_quantity). Because this is pushed onto the stack, the bytes are ordered in reverse and the finished flag is on the "first" byte.
	]=]
	function pushvlq(cursor: Cursor, x: number): ()
		local count = 1
		if x >= 2 ^ 49 then
			count = 8
		elseif x >= 2 ^ 42 then
			count = 7
		elseif x >= 2 ^ 35 then
			count = 6
		elseif x >= 2 ^ 28 then
			count = 5
		elseif x >= 2 ^ 21 then
			count = 4
		elseif x >= 2 ^ 14 then
			count = 3
		elseif x >= 2 ^ 7 then
			count = 2
		end

		tryrealloc(cursor, count)

		local hi = x // SHIFT32
		local lo = x - hi * SHIFT32

		pushu1(cursor, lo % BASE)

		if count >= 2 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			local newHi = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 3 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			local newHi = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 4 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			local newHi = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 5 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			local newHi = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 6 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			local newHi = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count >= 7 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			local newHi = prevHi // BASE
			pushu1(cursor, (newLo % BASE) + BASE)
			lo, hi = newLo, newHi
		end

		if count == 8 then
			local prevHi = hi
			local rem = prevHi % BASE
			local newLo = rem * SHIFT25 + (lo // BASE)
			pushu1(cursor, (newLo % BASE) + BASE)
		end
	end

	--[=[
		@within Cursor
		A V.L.Q. is a [Variable-Length-Quantity](https://en.wikipedia.org/wiki/Variable-length_quantity). Because this is pushed onto the stack, the bytes are ordered in reverse and the finished flag is on the "first" byte. This is how the pop function can read the bytes in sequence from the head to know when to stop.
	]=]
	function popvlq(cursor: Cursor): number
		local b1: number = popu1(cursor)
		local v1 = b1 % BASE
		if b1 < BASE then
			return v1
		end

		local b2 = popu1(cursor)
		local v2 = v1 * BASE + (b2 % BASE)
		if b2 < BASE then
			return v2
		end

		local b3 = popu1(cursor)
		local v3 = v2 * BASE + (b3 % BASE)
		if b3 < BASE then
			return v3
		end

		local b4 = popu1(cursor)
		local v4 = v3 * BASE + (b4 % BASE)
		if b4 < BASE then
			return v4
		end

		local b5 = popu1(cursor)
		local v5 = v4 * BASE + (b5 % BASE)
		if b5 < BASE then
			return v5
		end

		local b6 = popu1(cursor)
		local v6 = v5 * BASE + (b6 % BASE)
		if b6 < BASE then
			return v6
		end

		local b7 = popu1(cursor)
		local v7 = v6 * BASE + (b7 % BASE)
		if b7 < BASE then
			return v7
		end

		local b8 = popu1(cursor)
		local v8 = v7 * BASE + (b8 % BASE)
		return v8
	end
end

--[=[
	@within Cursor
	Pushes the entire string byte-per-character, then if no length is provided, pushes a [V.L.Q.](https://en.wikipedia.org/wiki/Variable-length_quantity) after so `popstr` knows how many characters to pop.
]=]
local function pushstr(cursor: Cursor, x: string, length: number?): ()
	local len = length or #x
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	buffer.writestring(buf, pos, x)
	setpos(buf, pos + len)

	if not length then
		pushvlq(cursor, len)
	end
end

--[=[
	@within Cursor
	If no length is provided it pops off a [V.L.Q.](https://en.wikipedia.org/wiki/Variable-length_quantity) representing the length, to then pop off and return all characters.
]=]
local function popstr(cursor: Cursor, length: number?): string
	local len = length or popvlq(cursor)
	local buf = getbuf(cursor)
	local pos = getpos(buf) - len
	setpos(buf, pos)
	return buffer.readstring(buf, pos, len)
end

--[=[
	@within Cursor
]=]
local function pushbuf(cursor: Cursor, x: buffer, length: number?): ()
	local len = length or buffer.len(x)
	tryrealloc(cursor, len)

	local buf = getbuf(cursor)
	local pos = getpos(buf)
	buffer.copy(buf, pos, x, 0, len)
	setpos(buf, pos + len)

	if not length then
		pushvlq(cursor, len)
	end
end

--[=[
	@within Cursor
]=]
local function popbuf(cursor: Cursor, length: number?): buffer
	local len = length or popvlq(cursor)
	local buf = getbuf(cursor)
	local pos = getpos(buf) - len
	setpos(buf, pos)

	local new = buffer.create(len)
	buffer.copy(new, 0, buf, pos, len)
	return new
end

--[=[
	@within Cursor
	Pretty prints a cursor.
]=]
local function printcursor(cursor: Cursor): ()
	local buf = getbuf(cursor)
	local pos = getpos(buf) - OFFSET_SIZE

	local bytes = { string.byte(buffer.tostring(buf), OFFSET_SIZE + 1, -1) }
	local offset = 7
	for i = 1, pos do
		local byte = bytes[i]
		local digits = if byte == 0 then 1 else math.ceil(math.log10(1 + byte))
		offset += digits + 1
	end

	local lastByte = bytes[pos + 1]
	if lastByte then
		local lastDigits = if lastByte == 0 then 1 else math.ceil(math.log10(1 + lastByte))
		offset += lastDigits // 2
	end

	if #bytes == 0 or pos == buffer.len(buf) - OFFSET_SIZE then
		table.insert(bytes, " " :: any)
	end

	print(
		`Pos: {pos} / {buffer.len(buf) - OFFSET_SIZE}\nBuf: \{ {table.concat(bytes, " ")} \}\n{string.rep(" ", offset)}^`
	)
end

--[=[
	@within Cursor
]=]
local function pushvector2f4(cursor: Cursor, x: vector): ()
	pushf4(cursor, x.y)
	pushf4(cursor, x.x)
end

--[=[
	@within Cursor
]=]
local function popvector2f4(cursor: Cursor): vector
	return vector.create(popf4(cursor), popf4(cursor))
end

--[=[
	@within Cursor
]=]
local function pushvector3f4(cursor: Cursor, x: vector): ()
	pushf4(cursor, x.z)
	pushf4(cursor, x.y)
	pushf4(cursor, x.x)
end

--[=[
	@within Cursor
]=]
local function popvector3f4(cursor: Cursor): vector
	return vector.create(popf4(cursor), popf4(cursor), popf4(cursor))
end

--[=[
	@within Cursor
	Only available when Luau's 4-wide vectors are enabled.
]=]
local function pushvector4f4(cursor: Cursor, x: vector): ()
	pushf4(cursor, x.w)
	pushf4(cursor, x.z)
	pushf4(cursor, x.y)
	pushf4(cursor, x.x)
end

--[=[
	@within Cursor
	Only available when Luau's 4-wide vectors are enabled.
]=]
local function popvector4f4(cursor: Cursor): vector
	return vector.create(popf4(cursor), popf4(cursor), popf4(cursor), popf4(cursor))
end

--[=[
	@within Cursor
	Trims the cursor's whitespace down to a dense buffer. Use this for sending over the network or storing in a database.
]=]
local function tobuffer(cursor: Cursor): buffer
	local buf = getbuf(cursor)
	local pos = getpos(buf)
	local newbuf = buffer.create(pos - OFFSET_SIZE)
	buffer.copy(newbuf, 0, buf, OFFSET_SIZE, pos - OFFSET_SIZE)
	return newbuf
end

local methods = {
	tobuffer = tobuffer,
	print = printcursor,

	tryrealloc = tryrealloc,

	pushu1 = pushu1,
	pushu2 = pushu2,
	pushu3 = pushu3,
	pushu4 = pushu4,
	pushu5 = pushu5,
	pushu6 = pushu6,
	pushu7 = pushu7,
	pushu8 = pushu8,
	popu1 = popu1,
	popu2 = popu2,
	popu3 = popu3,
	popu4 = popu4,
	popu5 = popu5,
	popu6 = popu6,
	popu7 = popu7,
	popu8 = popu8,

	pushi1 = pushi1,
	pushi2 = pushi2,
	pushi3 = pushi3,
	pushi4 = pushi4,
	pushi5 = pushi5,
	pushi6 = pushi6,
	pushi7 = pushi7,
	pushi8 = pushi8,
	popi1 = popi1,
	popi2 = popi2,
	popi3 = popi3,
	popi4 = popi4,
	popi5 = popi5,
	popi6 = popi6,
	popi7 = popi7,
	popi8 = popi8,

	pushf4 = pushf4,
	pushf8 = pushf8,
	popf4 = popf4,
	popf8 = popf8,

	pushbool = pushbool,
	popbool = popbool,

	pushvector2f4 = pushvector2f4,
	popvector2f4 = popvector2f4,

	pushvector3f4 = pushvector3f4,
	popvector3f4 = popvector3f4,

	pushvector4f4 = pushvector4f4,
	popvector4f4 = popvector4f4,

	pushstr = pushstr,
	popstr = popstr,

	pushvlq = pushvlq,
	popvlq = popvlq,

	pushbuf = pushbuf,
	popbuf = popbuf,
}
local meta = { __index = methods }

--[=[
	@within Cursor
	@function new
	@param size number? = 8 -- How many bytes to initialize the buffer with.
	@param position number? = 0 -- What byte to set the position to.

	Used in conjunction with `frombuffer`.

	Create a new Cursor object with an optional size and optional position. A Cursor object acts like a dynamic stack you can push and pop from, serialzing data into and out of a buffer. If the Cursor's buffer runs out of space, it will allocate a new buffer with 2x the size and copy the contents to that buffer. This means Cursors' buffer sizes only automatically grow, never shrink.

	```lua
	-- Defaulting to size = 8, position = 0
	local cursor = Cursor.new()
	Cursor.pushu1(cursor, 8)
	cursor:pushvlq(65938579356)

	-- Setting size and position
	local premadeCursor = Cursor.new(100, 50)
	print(premadeCursor:popf8())
	```
]=]
local function new(size: number?, pos: number?): Cursor
	local buf = buffer.create((size or 8) + OFFSET_SIZE)
	buffer.writeu32(buf, 0, (pos or 0) + OFFSET_SIZE)
	return setmetatable({ buf }, meta)
end

--[=[
	@within Cursor
	@function frombuffer
	@param buf buffer -- The buffer to initialize with
	@param position number? -- What byte to set the position to.

	Used in conjunction with `tobuffer`.

	Create a new Cursor object from a buffer stored by reference.

	```lua
	local cursor = Cursor.frombuffer(buf)
	Cursor.pushu1(cursor, 8)
	cursor:pushvlq(659386590836579356)
	```
	Here's an example using Roblox's RemoteEvent api to send data over the network.
	```lua
	-- Server Example
	local buf = Cursor.new()
		:pushu3(792)
		:pushf4(74958.38373)
		:pushstr("Systems Online!")
		:tobuffer()
	Remote:FireAllClients(buf)

	-- Client Example
	Remote.OnClientEvent:Connect(function(data: buffer)
		local cursor = Cursor.frombuffer(data)
		print(Cursor.popstr(cursor))
		print(cursor:popf4(), cursor:popu3())
	end)
	```
]=]
local function frombuffer(buf: buffer, pos: number?): Cursor
	local newlen = buffer.len(buf)
	local newbuf = buffer.create(newlen + OFFSET_SIZE)
	local pos = (pos or newlen) + OFFSET_SIZE
	buffer.writeu32(newbuf, 0, pos)
	buffer.copy(newbuf, OFFSET_SIZE, buf, 0, newlen)
	return setmetatable({ newbuf }, meta)
end

--[=[
	@within Cursor
	@type Cursor { buffer }
	Has a metatable to allow for optional syntax sugar, which can be avoided using the procedural api for performance reasons.
]=]
export type Cursor = typeof(new(...))

return {
	new = new,
	frombuffer = frombuffer,
	tobuffer = tobuffer,

	print = printcursor,
	tryrealloc = tryrealloc,

	pushu1 = pushu1,
	pushu2 = pushu2,
	pushu3 = pushu3,
	pushu4 = pushu4,
	pushu5 = pushu5,
	pushu6 = pushu6,
	pushu7 = pushu7,
	pushu8 = pushu8,
	popu1 = popu1,
	popu2 = popu2,
	popu3 = popu3,
	popu4 = popu4,
	popu5 = popu5,
	popu6 = popu6,
	popu7 = popu7,
	popu8 = popu8,

	pushi1 = pushi1,
	pushi2 = pushi2,
	pushi3 = pushi3,
	pushi4 = pushi4,
	pushi5 = pushi5,
	pushi6 = pushi6,
	pushi7 = pushi7,
	pushi8 = pushi8,
	popi1 = popi1,
	popi2 = popi2,
	popi3 = popi3,
	popi4 = popi4,
	popi5 = popi5,
	popi6 = popi6,
	popi7 = popi7,
	popi8 = popi8,

	pushf4 = pushf4,
	pushf8 = pushf8,
	popf4 = popf4,
	popf8 = popf8,

	pushbool = pushbool,
	popbool = popbool,

	pushvector2f4 = pushvector2f4,
	popvector2f4 = popvector2f4,

	pushvector3f4 = pushvector3f4,
	popvector3f4 = popvector3f4,

	pushvector4f4 = pushvector4f4,
	popvector4f4 = popvector4f4,

	pushstr = pushstr,
	popstr = popstr,

	pushvlq = pushvlq,
	popvlq = popvlq,

	pushbuf = pushbuf,
	popbuf = popbuf,
}
