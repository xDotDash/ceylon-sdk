import ceylon.buffer {
    Buffer,
    ByteBuffer,
    CharacterBuffer
}
import ceylon.buffer.codec {
    IncrementalCodec,
    ByteToByteCodec,
    CharacterToByteCodec,
    ErrorStrategy,
    PieceConvert,
    strict,
    ignore,
    DecodeException
}

Byte[] base16DecodeTableRight = { 255 }.repeat(48) // invalid range
    .chain(0..9) // 0..9
    .chain({ 255 }.repeat(7)) // invalid range
    .chain(10..15) // A..F
    .chain({ 255 }.repeat(26)) // invalid range
    .chain(10..15) // a..f
    *.byte.sequence(); // anything beyond f is invalid

Byte[] base16DecodeTableLeft = { 255 }.repeat(48) // invalid range
    .chain((0..9)*.leftLogicalShift(4)) // 0..9
    .chain({ 255 }.repeat(7)) // invalid range
    .chain((10..15)*.leftLogicalShift(4)) // A..F
    .chain({ 255 }.repeat(26)) // invalid range
    .chain((10..15)*.leftLogicalShift(4)) // a..f
    *.byte.sequence(); // anything beyond f is invalid

// ceylon.math is JVM only...
Integer ceiling(Integer x, Float y) {
    value xf = x.float;
    return ((xf + y - 1) / y).integer;
}

shared sealed abstract class Base16<ToMutable, ToImmutable, ToSingle>()
        satisfies IncrementalCodec<ToMutable,ToImmutable,ToSingle,ByteBuffer,Array<Byte>,Byte>
        given ToMutable satisfies Buffer<ToSingle>
        given ToImmutable satisfies {ToSingle*}
        given ToSingle satisfies Object {
    
    shared actual Integer averageDecodeSize(Integer inputSize) => ceiling(inputSize, 2.0);
    shared actual Integer maximumDecodeSize(Integer inputSize) => ceiling(inputSize, 2.0);
    shared actual Integer averageEncodeSize(Integer inputSize) => inputSize * 2;
    shared actual Integer maximumEncodeSize(Integer inputSize) => inputSize * 2;
    
    shared formal ToSingle[][] encodeTable;
    shared actual PieceConvert<ToSingle,Byte> pieceEncoder(ErrorStrategy error)
            => object satisfies PieceConvert<ToSingle,Byte> {
                shared actual {ToSingle*} more(Byte input) {
                    value r = encodeTable[input.unsigned];
                    "Base16 encode table is invalid. Internal error."
                    assert (exists r);
                    return r;
                }
            };
    
    shared formal Integer decodeToIndex(ToSingle input);
    shared actual PieceConvert<Byte,ToSingle> pieceDecoder(ErrorStrategy error)
            => object satisfies PieceConvert<Byte,ToSingle> {
                variable Byte? leftwardNibble = null;
                
                shared actual {Byte*} more(ToSingle input) {
                    if (exists left = leftwardNibble) {
                        value right = base16DecodeTableRight[decodeToIndex(input)];
                        if (exists right, right != 255) {
                            leftwardNibble = null;
                            return { left.or(right) };
                        }
                    } else {
                        value left = base16DecodeTableLeft[decodeToIndex(input)];
                        if (exists left, left != 255) {
                            leftwardNibble = left;
                            return empty;
                        }
                    }
                    switch (error)
                    case (strict) {
                        throw DecodeException {
                            "Input element ``input`` is not valid ASCII hex";
                        };
                    }
                    case (ignore) {
                        return empty;
                    }
                }
                
                shared actual {Byte*} done() {
                    if (exists left = leftwardNibble) {
                        leftwardNibble = null;
                        return { left };
                    } else {
                        return empty;
                    }
                }
            };
}

{Character+} hexDigits = ('0'..'9').chain('a'..'f');
Character[][] base16StringEncodeTable = {
    for (a in hexDigits)
        for (b in hexDigits) { a, b }.sequence()
}.sequence();
shared abstract class Base16String()
        extends Base16<CharacterBuffer,String,Character>()
        satisfies CharacterToByteCodec {
    shared actual Character[][] encodeTable = base16StringEncodeTable;
    
    shared actual Integer decodeBid({Character*} sample) {
        if (sample.every((s) => s in hexDigits)) {
            return 10;
        } else {
            return 0;
        }
    }
    
    shared actual Integer decodeToIndex(Character input) => input.integer;
}

{Byte+} hexDigitsByte = hexDigits*.integer*.byte;
Byte[][] base16ByteEncodeTable = {
    for (a in hexDigitsByte)
        for (b in hexDigitsByte) { a, b }.sequence()
}.sequence();
shared abstract class Base16Byte()
        extends Base16<ByteBuffer,Array<Byte>,Byte>()
        satisfies ByteToByteCodec {
    shared actual Byte[][] encodeTable = base16ByteEncodeTable;
    
    shared actual Integer decodeBid({Byte*} sample) {
        if (sample.every((s) => s in hexDigitsByte)) {
            return 10;
        } else {
            return 0;
        }
    }
    
    shared actual Integer decodeToIndex(Byte input) => input.unsigned;
}

shared object base16String extends Base16String() {
    shared actual [String+] aliases = ["base16", "base-16", "base_16"];
    shared actual Integer encodeBid({Byte*} sample) => 5;
}

shared object base16Byte extends Base16Byte() {
    shared actual [String+] aliases = ["base16", "base-16", "base_16"];
    shared actual Integer encodeBid({Byte*} sample) => 5;
}