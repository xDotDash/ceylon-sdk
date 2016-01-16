import ceylon.buffer {
    CharacterBuffer,
    ByteBuffer,
    Buffer
}

Buf convertBuffer<Buf, To, From>(input, error, converter, ofSize, averageSize, maximumSize)
        given Buf satisfies Buffer<To> {
    {From*} input;
    ErrorStrategy error;
    PieceConvert<To,From>(ErrorStrategy) converter;
    Buf(Integer) ofSize;
    Integer(Integer) averageSize;
    Integer(Integer) maximumSize;
    
    value size = input.size;
    value into = ofSize(averageSize(size));
    void add(To element) {
        if (!into.hasAvailable) {
            into.resize(maximumSize(size), true);
        }
        into.put(element);
    }
    value pieceConverter = converter(error);
    input.each((From inputElement) => pieceConverter.more(inputElement).each(add));
    pieceConverter.done().each(add);
    into.flip();
    return into;
}

"Common interface for Codecs that convert between bytes and bytes. Examples:
 gzip, and base64."
shared interface ByteToByteCodec
        satisfies IncrementalCodec<ByteBuffer,Array<Byte>,Byte,ByteBuffer,Array<Byte>,Byte> {
    
    shared actual Array<Byte> encode({Byte*} input, ErrorStrategy error)
            => encodeBuffer(input, error).visibleArray;
    shared actual Array<Byte> decode({Byte*} input, ErrorStrategy error)
            => decodeBuffer(input, error).visibleArray;
    
    shared actual ByteBuffer encodeBuffer({Byte*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceEncoder, ByteBuffer.ofSize,
        averageEncodeSize, maximumEncodeSize);
    shared actual ByteBuffer decodeBuffer({Byte*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceDecoder, ByteBuffer.ofSize,
        averageDecodeSize, maximumDecodeSize);
    
    shared actual CumulativeConvert<ByteBuffer,{Byte*},Byte,Byte> cumulativeEncoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<ByteBuffer,{Byte*},Byte,Byte> {
        error = error;
        converter = pieceEncoder;
        inputSize = inputSize;
        averageSize = averageEncodeSize;
        sizeOf = ByteBuffer.ofSize;
        growthFactor = growthFactor;
    };
    shared actual CumulativeConvert<ByteBuffer,{Byte*},Byte,Byte> cumulativeDecoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<ByteBuffer,{Byte*},Byte,Byte> {
        error = error;
        converter = pieceDecoder;
        inputSize = inputSize;
        averageSize = averageDecodeSize;
        sizeOf = ByteBuffer.ofSize;
        growthFactor = growthFactor;
    };
}

"Common interface for Codecs that convert between bytes and characters.
 Examples: utf8, ascii."
shared interface ByteToCharacterCodec
        satisfies IncrementalCodec<ByteBuffer,Array<Byte>,Byte,CharacterBuffer,String,Character> {
    
    shared actual Array<Byte> encode({Character*} input, ErrorStrategy error)
            => encodeBuffer(input, error).visibleArray;
    shared actual String decode({Byte*} input, ErrorStrategy error)
            => decodeBuffer(input, error).string;
    
    shared actual ByteBuffer encodeBuffer({Character*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceEncoder, ByteBuffer.ofSize,
        averageEncodeSize, maximumEncodeSize);
    shared actual CharacterBuffer decodeBuffer({Byte*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceDecoder, CharacterBuffer.ofSize,
        averageDecodeSize, maximumDecodeSize);
    
    shared actual CumulativeConvert<ByteBuffer,{Character*},Byte,Character> cumulativeEncoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<ByteBuffer,{Character*},Byte,Character> {
        error = error;
        converter = pieceEncoder;
        inputSize = inputSize;
        averageSize = averageEncodeSize;
        sizeOf = ByteBuffer.ofSize;
        growthFactor = growthFactor;
    };
    shared actual CumulativeConvert<CharacterBuffer,{Byte*},Character,Byte> cumulativeDecoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<CharacterBuffer,{Byte*},Character,Byte> {
        error = error;
        converter = pieceDecoder;
        inputSize = inputSize;
        averageSize = averageDecodeSize;
        sizeOf = CharacterBuffer.ofSize;
        growthFactor = growthFactor;
    };
}

"Common interface for Codecs that convert between characters and bytes.
 Examples: base64."
shared interface CharacterToByteCodec
        satisfies IncrementalCodec<CharacterBuffer,String,Character,ByteBuffer,Array<Byte>,Byte> {
    
    shared actual String encode({Byte*} input, ErrorStrategy error)
            => encodeBuffer(input, error).string;
    shared actual Array<Byte> decode({Character*} input, ErrorStrategy error)
            => decodeBuffer(input, error).visibleArray;
    
    shared actual CharacterBuffer encodeBuffer({Byte*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceEncoder, CharacterBuffer.ofSize,
        averageEncodeSize, maximumEncodeSize);
    shared actual ByteBuffer decodeBuffer({Character*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceDecoder, ByteBuffer.ofSize,
        averageDecodeSize, maximumDecodeSize);
    
    shared actual CumulativeConvert<CharacterBuffer,{Byte*},Character,Byte> cumulativeEncoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<CharacterBuffer,{Byte*},Character,Byte> {
        error = error;
        converter = pieceEncoder;
        inputSize = inputSize;
        averageSize = averageEncodeSize;
        sizeOf = CharacterBuffer.ofSize;
        growthFactor = growthFactor;
    };
    shared actual CumulativeConvert<ByteBuffer,{Character*},Byte,Character> cumulativeDecoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<ByteBuffer,{Character*},Byte,Character> {
        error = error;
        converter = pieceDecoder;
        inputSize = inputSize;
        averageSize = averageDecodeSize;
        sizeOf = ByteBuffer.ofSize;
        growthFactor = growthFactor;
    };
}

"Common interface for Codecs that convert between characters and characters.
 Examples: rot13."
shared interface CharacterToCharacterCodec
        satisfies IncrementalCodec<CharacterBuffer,String,Character,CharacterBuffer,String,Character> {
    
    shared actual String encode({Character*} input, ErrorStrategy error)
            => encodeBuffer(input, error).string;
    shared actual String decode({Character*} input, ErrorStrategy error)
            => decodeBuffer(input, error).string;
    
    shared actual CharacterBuffer encodeBuffer({Character*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceEncoder, CharacterBuffer.ofSize,
        averageEncodeSize, maximumEncodeSize);
    shared actual CharacterBuffer decodeBuffer({Character*} input, ErrorStrategy error)
            => convertBuffer(input, error, pieceDecoder, CharacterBuffer.ofSize,
        averageDecodeSize, maximumDecodeSize);
    
    shared actual CumulativeConvert<CharacterBuffer,{Character*},Character,Character> cumulativeEncoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<CharacterBuffer,{Character*},Character,Character> {
        error = error;
        converter = pieceEncoder;
        inputSize = inputSize;
        averageSize = averageEncodeSize;
        sizeOf = CharacterBuffer.ofSize;
        growthFactor = growthFactor;
    };
    shared actual CumulativeConvert<CharacterBuffer,{Character*},Character,Character> cumulativeDecoder
            (Integer? inputSize, Float growthFactor, ErrorStrategy error)
            => CumulativeConvert<CharacterBuffer,{Character*},Character,Character> {
        error = error;
        converter = pieceDecoder;
        inputSize = inputSize;
        averageSize = averageDecodeSize;
        sizeOf = CharacterBuffer.ofSize;
        growthFactor = growthFactor;
    };
}