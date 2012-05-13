Buffer = require("buffer").Buffer

###
# class BetterBuffer

`Buffer` subclass with some really obvious add-ons.  Made this while working on
an app for #Occupy, so maybe it really *is* a "better" `Buffer` (sigh).
###
class exports.BetterBuffer extends Buffer
  # ## Instance variables

  # ### *var* growSize
  # the increment by which to enlarge the buffer each time `growToAccommodate()` is called
  growSize: 512

  # ### *var* dataLength
  # the buffer's internal counter of how many octets have been copied in via `pushBack()`
  dataLength: 0



  # ## Constructor

  # ### *constructor* BetterBuffer
  ### Object constructor.  Calls core `Buffer` constructor.
   @param {(number)} initialSize: the initial size of the buffer, passed straight to the core node.js `Buffer` constructor.
   @param {(number)} _growSize
  ###
  constructor: (initialSize, _growSize) ->
    Buffer.call @, initialSize
    if _growSize? then @growSize = _growSize


  # ## Instance methods

  # ### *fn* getNextSmallestBufferSize()
  ### Finds the smallest possible capacity that can hold `dataLengthToAccommodate`
      and that is also a multiple of the buffer's `growSize` setting.
   @param {(number)} dataLengthToAccommodate: The number of octets the buffer must guarantee being able to accommodate.
  ###
  getNextSmallestBufferSize: (dataLengthToAccommodate) =>
    @growSize * (Math.floor((dataLengthToAccommodate) / @growSize) + 1)


  # ### *fn* growToAccommodate()
  ### Enlarge the buffer in increments specified by its `growSize` member.
   @param {(number)} dataLengthToAccommodate: The number of octets the buffer must guarantee being able to accommodate.
  ###
  growToAccommodate: (dataLengthToAccommodate) =>
    if dataLengthToAccommodate > @length
      newSize = @getNextSmallestBufferSize dataLengthToAccommodate
      expandedBuffer = new BetterBuffer(newSize)
      @copy expandedBuffer
      BetterBuffer.call(@, newSize, @growSize)
      expandedBuffer.copy(@)
    return @

  # ### *fn* pushBack()
  ### Append the contents of `sourceBuffer` to the buffer.  The insertion point is the
      "end" of the buffer, as defined by the buffer's `dataLength` parameter.  The buffer
      is not enlarged if the contents of `sourceBuffer` exceeds the current capacity.
   @param {(Buffer)} sourceBuffer: The buffer to append.
   @return {(number)} The new value of `this.dataLength`.
  ###
  pushBack: (sourceBuffer) =>
    sourceBuffer.copy @, @dataLength
    @dataLength = Math.min(@length, @dataLength + sourceBuffer.length)
    return @dataLength

  # ### *fn* cloneDataIntoNewBuffer()
  ### Creates a new `BetterBuffer` containing an exact copy of the contents of the
      buffer.  __NOTE:__ the returned buffer's size is equal to the source buffer's
      `dataLength` property, not its `length` property.
   @return {(BetterBuffer)} A new buffer containing the cloned octets.
  ###
  cloneDataIntoNewBuffer: =>
    outBuffer = new BetterBuffer(@dataLength, @growSize)
    @copy outBuffer, 0, 0, @dataLength
    return outBuffer

  # ### *fn* popFront()
  ### Just a simple `pop` function, like you'd find on a stack or queue.  Hacks off the
      first `num` octets in the buffer, shifts everything in the buffer forward by the
      same distance, and returns the popped octets in a new `BetterBuffer` object.

      The buffer's `dataLength` property is decremented accordingly.

   @param {(number)} num: The number of octets to pop and return.
   @return {(BetterBuffer)} A new buffer containing the popped octets.
  ###
  popFront: (num) =>
    newSize = @length - num
    outBuffer = new BetterBuffer(num)
    meBuffer = new BetterBuffer(newSize)
    newDataLength = Math.max(0, @dataLength - num)
    @copy outBuffer, 0, 0, num
    @copy meBuffer, 0, num, @length
    BetterBuffer.call(@, newSize, @growSize)
    meBuffer.copy(@)
    @dataLength = newDataLength
    return outBuffer



