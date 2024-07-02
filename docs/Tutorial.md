---
sidebar_position: 2
---

# Getting Started

I think it would be fun to encode information about a spaceship. Let's start with our spaceship type:
```lua
type Spaceship = {
    locked: boolean,
    occupied: boolean,
    underMaintenance: boolean,
    name: string,
    crew: { string },
    onlineDuration: number,
    hullIntegrity: number,
}

local function spaceshipToBuffer(spaceship: Spaceship): buffer
    -- todo
end

local function spaceshipFromBuffer(buf: buffer): Spaceship
    -- todo
end
```

## Encoding
First we'll create a new cursor instance that we eventually plan to trim back down into a buffer once we are done.
```lua
local Cursor = require(...)

local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()

    -- todo

    return cursor:tobuffer() -- or Cursor.tobuffer(cursor) if you perfer the procedural api
end
```

### Choosing The Right Type
Now let's push some data into the buffer and advance the cursor. To start, we'll push how long the ship has been online in whole seconds, implying we want an unsigned integer. The general rundown goes:
#### Numbers
- Need fractions? Use floats.
- Need negatives? Use signed integers.
- Else, use unsigned integers.
- Need Enums? Don't use strings or metadatas, assign each one a number and use a u8.
#### Strings
- Best for unique names, descriptions, titles, user inputs, or bodies of text.
#### Booleans
- Best for flags or other stateful yes/no information.
#### VLQs
- [Variable Length Quantities](https://en.wikipedia.org/wiki/Variable-length_quantity) are best for unsigned integer values that can span single bytes to many bytes in size.
- Typically used for sizes of runtime arrays and strings.

### Choosing The Right Size
To figure out the largest kinds of numbers we need to store, let's think of a spaceship that has been online the longest. How about we say the longest online spaceship lasted 3 months before scheduled maintenance. There are 60 seconds in a minute, 60 minutes in an hour, 24 hours in a day, 7 days in a week, 4 weeks in a month, and we want 3 months. `60 * 60 * 24 * 7 * 4 * 3 = 7257600`. That's a big number! To figure out how many bytes we'd need to represent that non-zero number, we can use `ceil(log256(1 + number))`. To calculate it: `ceil(log256(1 + 7,257,600)) = 3`.

Our worst case says we need at least 3 bytes to store how long the spaceship has been online. Now that we have 3 bytes, we can quickly calculate the maximum number we can represent to know if this choice will scale well past our expectations. We calculate that using `256^bytes - 1`. Doing so we get: `256^3 - 1 = 16,777,215`. That's more than twice the value we came up with, meaning we are more than safe to use `3 bytes`!
```lua
local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()

    -- If you want to avoid metatable overhead Cursor has a procedural api
    Cursor.pushu3(cursor, spaceship.onlineDuration) -- seconds

    return cursor:tobuffer()
end
```

Great. Now let's follow a similar procedure when choosing the current Hull Integrity, which is a percentage. Percentages are floating point numbers between 0 and 1. Because of this fine middleground we can store great precision using only `4 bytes`.
```lua
local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()

    -- If you want to avoid metatable overhead Cursor has a procedural api
    Cursor.pushu3(cursor, spaceship.onlineDuration) -- seconds
    --? Or you can save yourself some typing and use the : syntax with the object api
    cursor:pushf4(spaceship.hullIntegrity) -- % of structural integrity

    return cursor:tobuffer()
end
```

### Strings
Now we need to encode the name of the spaceship. This one is ironically the easiest to think about since the hard part of managing lengths is handled automatically for us.
```lua
local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()

    Cursor.pushu3(cursor, spaceship.onlineDuration)
    --? And with the object api you can chain pushes quite easily
    cursor:pushf4(spaceship.hullIntegrity):pushstr(spaceship.name)

    return cursor:tobuffer()
end
```

### Variable Length Quantities
Last but not least we need to encode the names of each crew member. This one we will have to manage the count on our own, but that's ok, we have all the tools to do it efficiently. To start, we want to iterate over every crew member's name and push them onto the cursor. Then we want to push how many crew members there are so we know how many crew members to pop off when reading the data.

If we can guarantee our spaceships will always have less than 256 crew members, then we can use a 1  byte unsigned integer. However, I think it would be more interesting if we had really big spaceships that could fit potentially thousands of people. That's two bytes, but some ships won't need that many. This is where we can use something called a [Variable Length Quantity](https://en.wikipedia.org/wiki/Variable-length_quantity) to store how many crew members we have. It will use 1 byte up to 127 members, then 2 bytes up to 16383 members, which is considerably more than we'll ever need.
```lua
local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()
        :pushu3(spaceship.onlineDuration)
        :pushf4(spaceship.hullIntegrity)
        :pushstr(spaceship.name)

    for _, name in spaceship.crew do
        cursor:pushstr(name)
    end
    cursor:pushvlq(#spaceship.crew)

    return cursor:tobuffer()
end
```
It is important that we put the VLQ *after* the strings because when we start popping off data, the cursor will first read what was pushed last. We need to know how many names there are before we can pop off each name.

### Bitpacking
Lastly we have three booleans in our spaceship type that keep track of its status: `locked`, `occupied`, and `underMaintenance`. Each one is either true or false, which is two values. A single bit can store two values, 1 or 0. A byte, which is the smallest unit we can work with, is 8 bits. We can store up to 8 booleans in a single byte!
```lua
local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()
        :pushbool(spaceship.locked, spaceship.occupied, spaceship.underMaintenance)
        :pushu3(spaceship.onlineDuration)
        :pushf4(spaceship.hullIntegrity)
        :pushstr(spaceship.name)

    for _, name in spaceship.crew do
        cursor:pushstr(name)
    end
    cursor:pushvlq(#spaceship.crew)

    return cursor:tobuffer()
end
```

### Results
We have now finished encoding our spaceship into a buffer using a Cursor! Let's use the pretty print cursor function to see what our results are for a given spaceship:
```lua
local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()
        :pushbool(spaceship.locked, spaceship.occupied, spaceship.underMaintenance)
        :pushu3(spaceship.onlineDuration)
        :pushf4(spaceship.hullIntegrity)
        :pushstr(spaceship.name)

    for _, name in spaceship.crew do
        cursor:pushstr(name)
    end
    cursor:pushvlq(#spaceship.crew):print()

    return cursor:tobuffer()
end

local buf = spaceshipToBuffer {
    locked = false,
    occupied = true,
    underMaintenance = false,
    onlineDuration = 1677726,
    hullIntegrity = 0.1,
    name = "Degasi",
    crew = { "Paul Torgal", "Bart Torgal", "Marguerit Maida" }
}
```
Our pretty printed output:
```
Len: 60
Pos: 56
Buf: { 2 158 153 25 205 204 204 61 68 101 103 97 115 105 134 80 97 117 108 32 84 111 114 103 97 108 139 66 97 114 116 32 84 111 114 103 97 108 139 77 97 114 103 117 101 114 105 116 32 77 97 105 100 97 143 131 0 0 0 0 }
                                                                                                                                                                                                                 ^
We can see exactly what we we pushed onto the cursor here in bytes! Let's analyze it.

flags
(2 = 01000000)    locked 0b1, occupied 0b01, undermaintenance 0b001

numbers
(158 153 25)        onlineDuration 1677726u8
(205 204 204 61)    hullIntegrity 0.1f

strings
(68 101 103 97 115 105 | 134)                                    name "Degasi" | vlq 6
(80 97 117 108 32 84 111 114 103 97 108 | 139)                   crew "Paul Torgal" | vlq 11
(66 97 114 116 32 84 111 114 103 97 108 | 139)                   crew "Bart Torgal" | vlq 11
(77 97 114 103 117 101 114 105 116 32 77 97 105 100 97 | 143)    crew "Marguerit Maida" | vlq 15 

crew count
(131)    vlq 3
```

## Decoding
Now that we know how to push data into the cursor and the mindset to do so, this part should be pretty easy! Let's start by creating a cursor from a buffer created by `spaceshipToBuffer`.
```lua
local function spaceshipFromBuffer(buf: buffer): Spaceship
    local cursor = Cursor.frombuffer(buf)

    return {
        -- todo
    }
end
```

Now the important thing here is that we pop our data in the opposite order we pushed it. For every push function there is a pop function, so the rest should be self explanatory. let's see the final results:
```lua
local function spaceshipFromBuffer(buf: buffer): Spaceship
    local cursor = Cursor.frombuffer(buf)

    local crewCount = cursor:popvlq()
    local crew = table.create(crewCount)
    for i = crewCount, 1, -1 do
        crew[i] = cursor:popstr()
    end

    local name = cursor:popstr()
    local hullIntegrity = cursor:popf4()
    local onlineDuration = cursor:popu3()

    local locked, occupied, underMaintenance = cursor:popbool()

    return {
        locked = locked,
        occupied = occupied,
        underMaintenance = underMaintenance,
        onlineDuration = onlineDuration,
        hullIntegrity = hullIntegrity,
        name = name,
        crew = crew,
    }
end
```

We can now bask in our spaceship serdes implementation!
```lua
type Spaceship = {
    locked: boolean,
    occupied: boolean,
    underMaintenance: boolean,
    name: string,
    crew: { string },
    onlineDuration: number,
    hullIntegrity: number,
}

local function spaceshipToBuffer(spaceship: Spaceship): buffer
    local cursor = Cursor.new()
        :pushbool(spaceship.locked, spaceship.occupied, spaceship.underMaintenance)
        :pushu3(spaceship.onlineDuration)
        :pushf4(spaceship.hullIntegrity)
        :pushstr(spaceship.name)

    for _, name in spaceship.crew do
        cursor:pushstr(name)
    end
    cursor:pushvlq(#spaceship.crew):print()

    return cursor:tobuffer()
end

local function spaceshipFromBuffer(buf: buffer): Spaceship
    local cursor = Cursor.frombuffer(buf)

    local crewCount = cursor:popvlq()
    local crew = table.create(crewCount)
    for i = crewCount, 1, -1 do
        crew[i] = cursor:popstr()
    end

    local name = cursor:popstr()
    local hullIntegrity = cursor:popf4()
    local onlineDuration = cursor:popu3()

    local locked, occupied, underMaintenance = cursor:popbool()

    return {
        locked = locked,
        occupied = occupied,
        underMaintenance = underMaintenance,
        onlineDuration = onlineDuration,
        hullIntegrity = hullIntegrity,
        name = name,
        crew = crew,
    }
end

local buf = spaceshipToBuffer {
    locked = false,
    occupied = true,
    underMaintenance = false,
    onlineDuration = 1677726,
    hullIntegrity = 0.1,
    name = "Degasi",
    crew = { "Paul Torgal", "Bart Torgal", "Marguerit Maida" }
} -- Into the byte buffer you go

local spaceship = spaceshipFromBuffer(buf) -- Tada! Back to normal