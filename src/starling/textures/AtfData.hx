// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.textures;

import openfl.display3D.Context3DTextureFormat;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.utils.ByteArray;

/** A parser for the ATF data format. */
class AtfData
{
	private var mFormat:Dynamic;
	private var mWidth:Int;
	private var mHeight:Int;
	private var mNumTextures:Int;
	private var mIsCubeMap:Bool;
	private var mData:ByteArray;
	
	public var format(get, null):Dynamic;
	public var width(get, null):Int;
	public var height(get, null):Int;
	public var numTextures(get, null):Int;
	public var isCubeMap(get, null):Bool;
	public var data(get, null):ByteArray;
	
	/** Create a new instance by parsing the given byte array. */
    public function new(data:ByteArray)
    {
        if (!isAtfData(data)) throw new ArgumentError("Invalid ATF data");
        
        if (data[6] == 255) data.position = 12; // new file version
        else                data.position =  6; // old file version

        var format:UInt = data.readUnsignedByte();
        switch (format & 0x7f)
        {
            case  0, 1: mFormat = Context3DTextureFormat.BGRA;
            case 12, 2, 3: mFormat = Context3DTextureFormat.COMPRESSED;
            case 13, 4, 5: mFormat = Context3DTextureFormat.COMPRESSED_ALPHA; // explicit string for compatibility
            default: throw new Error("Invalid ATF format");
        }
        
        mWidth = Std.int(Math.pow(2, data.readUnsignedByte())); 
        mHeight = Std.int(Math.pow(2, data.readUnsignedByte()));
        mNumTextures = data.readUnsignedByte();
        mIsCubeMap = (format & 0x80) != 0;
        mData = data;
        
        // version 2 of the new file format contains information about
        // the "-e" and "-n" parameters of png2atf
        
        if (data[5] != 0 && data[6] == 255)
        {
            var emptyMipmaps:Bool = (data[5] & 0x01) == 1;
            var numTextures:Int  = data[5] >> 1 & 0x7f;
            mNumTextures = emptyMipmaps ? 1 : numTextures;
        }
    }

	/** Checks the first 3 bytes of the data for the 'ATF' signature. */
	public static function isAtfData(data:ByteArray):Bool
	{
		if (data.length < 3) {
			return false;
		}
		else
		{
			data.position = 0;
			var charCodeStr:String = String.fromCharCode(Std.parseInt(cast data.readByte()));
			charCodeStr += String.fromCharCode(Std.parseInt(cast data.readByte()));
			charCodeStr += String.fromCharCode(Std.parseInt(cast data.readByte()));
			var signature:String = charCodeStr;
			return signature == "ATF";
		}
	}

	/** The texture format. @see flash.display3D.textures.Context3DTextureFormat */
	private function get_format():Dynamic { return mFormat; }

	/** The width of the texture in pixels. */
	private function get_width():Int { return mWidth; }

	/** The height of the texture in pixels. */
	private function get_height():Int { return mHeight; }

	/** The number of encoded textures. '1' means that there are no mip maps. */
	private function get_numTextures():Int { return mNumTextures; }

	/** Indicates if the ATF data encodes a cube map. Not supported by Starling! */
	private function get_isCubeMap():Bool { return mIsCubeMap; }

	/** The actual byte data, including header. */
	private function get_data():ByteArray { return mData; }
}