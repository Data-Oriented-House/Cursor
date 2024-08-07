---
sidebar_position: 1
---

# Installation

## Source
1. Go to the [github](https://github.com/Data-Oriented-House/Cursor/blob/main/src/init.luau).
2. Copy the raw contents.
3. Paste in your project.

## Wally
1. Go to the [wally website](https://wally.run/package/data-oriented-house/cursor).
2. Select the most recent or your preferred version.
3. Click and copy the version link.
4. Go to your `wally.toml` file under `[Dependencies]` and paste it.

## Why Cursor?
To utilize Cursor, you must understand what problem it tries to solve, and what alternatives exist. To begin, the [buffer](https://luau-lang.org/library#buffer-library) library allows Luau users to manipulate arrays of bytes with the `buffer` type. These arrays of bytes are called Buffers. These are the old-school definitions of arrays, allocated with a fixed size that doesn't change after creation. As a user of the buffer library you are provided with useful methods such as `buffer.writeu8(buffer, offset, value)`, which will write into the `given buffer` an `8 bit unsigned integer` with the `given value` at the `given offset` or "index." This api is great at providing low-level access to managing memory formats and sizes, which is crucial for applications requiring optimizing the size of data like networking or data storage. However, the api is not very forgiving when it comes to day-to-day use of packing data whenever you feel like it.

### Non Powers Of 2
To start, if you only need a 3 byte unsigned integer, you have to mentally convert that 3 bytes to 24 bits, then learn there is no `buffer.writeu24`. You then go "fine" and do both a `buffer.writeu8` and `buffer.write16` right after, but now have to remember arithmetic bitshifting to write the correct bytes in the correct order. Cool, let's say you did this. Now the code somewhere completely different that needs to read this data needs to do it all over again but in reverse. Not appealing to say the least.

### Offsets And Variable Size
Another cause of concern is needing to manually keep track of offsets if you plan to store multiple values into a buffer. Ok write a u8 at 0. Now write a f64 at 1. Now write an i32 at 2 and you get an access error because that 2 is supposed to be a 9. Ok, sure, you can do arithmetic, but now you need to write a string or other variable-sized data. How do you know how many bytes to offset or how how many bytes to allocate the buffer if you don't know the string? Ok we can first get the length of the string, write that as a u8 at 9, then write the string after. Awesome, out of bounds access error. The string was longer than 255 characters so let's use a u16 to store the length instead. That works, but yet another out of bounds access error. Our buffer is too small and we used all our space. Let's wait until we run out of space and then make a bigger buffer and copy it over. How much bigger? That's a lot going on now. Say we figured it all out, now I need to serialize another data packet and this string is only 3 characters long meaning a u16 is wasting a byte of space. The problems don't seem to stop!

## Alternatives
Do you see the issues? [buffer](https://luau-lang.org/library#buffer-library) is a wonderful but tedious and low-level library meant to be built upon. So we did. We are not the only ones to do this though, our friends at [Redblox](https://github.com/red-blox) made a utility called [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) that takes a stab at solving the previously stated problems with practical type coverage and runtime serdes implementations. Both Cursor and [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) use a "Cursor" object and push / pop data from the cursor. Another is [Squash](https://data-oriented-house.github.io/Squash/), which is much larger and more comprehensive focusing on compressing any kind of Luau and Roblox data into buffers as small as possible. Version 2 is rewritten on top of an inlined version of this library, Cursor, demonstrating its efficiency and practicality.

| Category       | Least  | Less   | More   | Most   |
| :------------: | :----: | :----: | :----: | :----: |
| API Complexity | [buffer](https://luau-lang.org/library#buffer-library) | Cursor | [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) | [Squash](https://data-oriented-house.github.io/Squash/) |
| Size Coverage  | [buffer](https://luau-lang.org/library#buffer-library) | [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) | Cursor | [Squash](https://data-oriented-house.github.io/Squash/) |
| Type Coverage  | [buffer](https://luau-lang.org/library#buffer-library) | Cursor | [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) | [Squash](https://data-oriented-house.github.io/Squash/) |
| Overhead       | [buffer](https://luau-lang.org/library#buffer-library) | Cursor | [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) | [Squash](https://data-oriented-house.github.io/Squash/) |
| File Size      | [buffer](https://luau-lang.org/library#buffer-library) | [Buffit](https://github.com/red-blox/Util/blob/main/libs/Buffit/Buffit.luau) | Cursor | [Squash](https://data-oriented-house.github.io/Squash/) |