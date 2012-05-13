# // better-buffer

part of me wanted to call this module `node-miyagi`.

please god let someone get the joke.  preferably a girl.  preferably gorgeous.

# why

It blows my mind that these methods don't exist on the core node.js `Buffer`
object.  srsly guise?

# how

Install with npm.

```sh
npm install better-buffer
```

# what

## BetterBuffer (initialSize, growSize = 512)

Constructor is compatible with existing `Buffer` constructor, but also adds an
optional `growSize` parameter.  The only time that a `BetterBuffer` will grow
is when you call the `growToAccommodate()` method -- there's no auto-growing on
`BetterBuffer::pushBack()` or `Buffer::copy()` -- at least not yet.

## BetterBuffer::growToAccommodate (dataLengthToAccommodate)

Ensures that the buffer is at least big enough to store `dataLengthToAccommodate`
octets.  The buffer will grow in intervals defind by its `growSize` member, so
you may sometimes end up with a buffer that's slightly larger than necessary.

## BetterBuffer::pushBack (sourceBuffer)

Queue-like functionality for buffers. Appends `sourceBuffer` to the buffer at
the end of that buffer's actual data, as indicated by its `dataLength` member. So
for example, if you have:

```javascript
var myBuffer = new BetterBuffer(10, 5);
// myBuffer.length == 10
// myBuffer.dataLength == 0
```

...and you append, say, `secondBuffer`, the `length` of which is `6`:

```javascript
myBuffer.pushBack(secondBuffer);
// myBuffer.length == 10
// myBuffer.dataLength == 6
```

`myBuffer.dataLength` is now 6.  Now let's append `thirdBuffer`, the length of
which is `2`:

```javascript
myBuffer.pushBack(thirdBuffer);
// myBuffer.length == 10
// myBuffer.dataLength == 8
```

`myBuffer.dataLength` is now 8, and `thirdBuffer` was written into `myBuffer`
starting at position 6.

In combination with `BetterBuffer::popFront()`, this makes it much easier to
create queue- or stream-like behavior using simple buffer objects.

The buffer's `dataLength` property is incremented accordingly.

## BetterBuffer::popFront (num)

Just a simple `pop` function, like you'd find on a stack or queue.  Hacks off the
first `num` octets in the buffer, shifts everything in the buffer forward by the
same distance, and returns the popped octets in a new `BetterBuffer` object.

The buffer's `dataLength` property is decremented accordingly.

## BetterBuffer::cloneDataIntoNewBuffer ()

Creates a new `BetterBuffer` containing an exact copy of the contents of the
buffer.  __NOTE:__ the returned buffer's size is equal to the source buffer's
`dataLength` property, not its `length` property.

For example, let's say you have a buffer `myBuffer` of size `256`, and you've only
`pushBack`ed one buffer of size `100` into it.  This means that `myBuffer.length`
is `256`, but `myBuffer.dataLength` is `100`. So when you call
`cloneDataIntoNewBuffer`, it will return a buffer of size `100`, not `256`.

# tl;dr (for the hyperactive and/or distractible)

```javascript
var myBuf = new BetterBuffer(10, 5);
myBuf.fill(0x00);
// myBuf.length == 10
// myBuf.dataLength == 0
// myBuf = <Buffer 00 00 00 00 00 00 00 00 00 00>

var smallerBuffer = new BetterBuffer(8);
smallerBuffer.fill(0xff); 
// smallerBuffer.length == 8
// smallerBuffer.dataLength == 0
// smallerBuffer = <Buffer ff ff ff ff ff ff ff ff>

// now we explicitly set smallerBuffer.dataLength -- it's not necessary, but
// it makes things clearer conceptually
smallerBuffer.dataLength = smallerBuffer.length;

// what happens when we call growToAccommodate to ensure we have enough room?
myBuf.growToAccommodate(smallerBuffer.dataLength);
// smallerBuffer is smaller than myBuf, so myBuf.length is still 10

// go ahead and eat the smaller buffer
myBuf.pushBack(smallerBuffer); 
// myBuf = <Buffer ff ff ff ff ff ff ff ff 00 00>
// myBuf.length == 10
// myBuf.dataLength == 8

var anotherBuffer = new BetterBuffer(8);
anotherBuffer.fill(0xaa);
// anotherBuffer.length == 8
// anotherBuffer.dataLength == 0
// anotherBuffer = <Buffer aa aa aa aa aa aa aa aa>

// again, we explicitly set anotherBuffer.dataLength for the sake of code readability
anotherBuffer.dataLength = anotherBuffer.length;

// let's try calling growToAccommodate again and see if anything happens this time
myBuf.growToAccommodate(myBuf.dataLength + anotherBuffer.dataLength);
// now, myBuf.length == 20 because:
//     myBuf.dataLength == 8
//     anotherBuffer.dataLength == 8
// and myBuf.growSize == 5 (myBuf's initial size was 10, and 10 + 5 + 5 == 20)

// now we can pushBack() safely
myBuf.pushBack(anotherBuffer);
// myBuf = <Buffer ff ff ff ff ff ff ff ff aa aa aa aa aa aa aa aa 00 00 00 00>
// myBuf.length == 20
// myBuf.dataLength == 16

// and just for good measure let's tack on a shitty example of popFront()
var justAPiece = myBuf.popFront(5);
// justAPiece = <Buffer ff ff ff ff ff>
// myBuf = <Buffer ff ff ff aa aa aa aa aa aa aa aa 00 00 00 00>
```

# Authors and contributors
bryn austin bellomy < [bryn@signals.io](mailto:bryn@signals.io) >

# License (MIT license)
Copyright (c) 2012 bryn austin bellomy, [signalenvelope / signals.io »](http://signals.io)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

