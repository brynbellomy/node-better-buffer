Buffer = require("buffer").Buffer

class exports.BetterBuffer extends Buffer
  growSize: 512
  dataLength: 0

  constructor: (initialSize, _growSize) ->
    Buffer.call @, initialSize
    if _growSize? then @growSize = _growSize

  getNextSmallestBufferSize: (dataLengthToAccommodate) =>
    @growSize * (Math.floor((dataLengthToAccommodate) / @growSize) + 1)

  growToAccommodate: (dataLengthToAccommodate) =>
    if dataLengthToAccommodate > @length
      newSize = @getNextSmallestBufferSize dataLengthToAccommodate
      expandedBuffer = new BetterBuffer(newSize)
      @copy expandedBuffer
      BetterBuffer.call(@, newSize, @growSize)
      expandedBuffer.copy(@)
    return @

  pushBack: (sourceBuffer) =>
    sourceBuffer.copy @, @dataLength
    @dataLength = Math.min(@length, @dataLength + sourceBuffer.length)
    return @dataLength

  cloneDataIntoNewBuffer: =>
    outBuffer = new Buffer(@dataLength)
    @copy outBuffer, 0, 0, @dataLength
    return outBuffer

  popFront: (num) =>
    newSize = @length - num
    outBuffer = new Buffer(num)
    meBuffer = new Buffer(newSize)
    newDataLength = Math.max(0, @dataLength - num)
    @copy outBuffer, 0, 0, num
    @copy meBuffer, 0, num, @length
    BetterBuffer.call(@, newSize, @growSize)
    meBuffer.copy(@)
    @dataLength = newDataLength
    return outBuffer



