// MD5 Hash generator -- Copyright 2004 (c) Petr Jelinek -- Modified for UT99.
// Source: UnrealWiki: MD5 -- http://wiki.beyondunreal.com/wiki/MD5
class MD5Hash extends Object;

/** MD5 context */
struct MD5_CTX {
	/** state (ABCD) */
	var int state[64];
	/** number of bits, modulo 2^64 (lsb first) */
	var int count[64];
	/** input buffer */
	var byte buffer[64];
};

/** return the MD5 of the input string */
static function string MD5String (string str)
{
	local MD5_CTX context;
	local byte digest[64];
	local string Hex;
	local int i;

	MD5Init (context);
	MD5Update (context, str, Len(str));
	MD5Final (digest, context);

	for (i = 0; i < 16; i++)
		Hex = Hex $ DecToHex(digest[i], 1);

	return Hex;
}

/** initialize the MD5 context */
static final function MD5Init(out MD5_CTX context)
{
	context.count[0] = 0;
	context.count[1] = 0;
	context.state[0] = 0x67452301;
	context.state[1] = 0xefcdab89;
	context.state[2] = 0x98badcfe;
	context.state[3] = 0x10325476;
}

static final function MD5Transform(out int Buf[64], byte block[64])
{
	local int A,B,C,D;
	local int x[64];

	A = Buf[0];
	B = Buf[1];
	C = Buf[2];
	D = Buf[3];

	Decode (x, block, 64);

	/* Round 1 */
	FF (a, b, c, d, x[ 0],  7, 0xd76aa478); /* 1 */
	FF (d, a, b, c, x[ 1], 12, 0xe8c7b756); /* 2 */
	FF (c, d, a, b, x[ 2], 17, 0x242070db); /* 3 */
	FF (b, c, d, a, x[ 3], 22, 0xc1bdceee); /* 4 */
	FF (a, b, c, d, x[ 4],  7, 0xf57c0faf); /* 5 */
	FF (d, a, b, c, x[ 5], 12, 0x4787c62a); /* 6 */
	FF (c, d, a, b, x[ 6], 17, 0xa8304613); /* 7 */
	FF (b, c, d, a, x[ 7], 22, 0xfd469501); /* 8 */
	FF (a, b, c, d, x[ 8],  7, 0x698098d8); /* 9 */
	FF (d, a, b, c, x[ 9], 12, 0x8b44f7af); /* 10 */
	FF (c, d, a, b, x[10], 17, 0xffff5bb1); /* 11 */
	FF (b, c, d, a, x[11], 22, 0x895cd7be); /* 12 */
	FF (a, b, c, d, x[12],  7, 0x6b901122); /* 13 */
	FF (d, a, b, c, x[13], 12, 0xfd987193); /* 14 */
	FF (c, d, a, b, x[14], 17, 0xa679438e); /* 15 */
	FF (b, c, d, a, x[15], 22, 0x49b40821); /* 16 */

	/* Round 2 */
	GG (a, b, c, d, x[ 1],  5, 0xf61e2562); /* 17 */
	GG (d, a, b, c, x[ 6],  9, 0xc040b340); /* 18 */
	GG (c, d, a, b, x[11], 14, 0x265e5a51); /* 19 */
	GG (b, c, d, a, x[ 0], 20, 0xe9b6c7aa); /* 20 */
	GG (a, b, c, d, x[ 5],  5, 0xd62f105d); /* 21 */
	GG (d, a, b, c, x[10],  9,  0x2441453); /* 22 */
	GG (c, d, a, b, x[15], 14, 0xd8a1e681); /* 23 */
	GG (b, c, d, a, x[ 4], 20, 0xe7d3fbc8); /* 24 */
	GG (a, b, c, d, x[ 9],  5, 0x21e1cde6); /* 25 */
	GG (d, a, b, c, x[14],  9, 0xc33707d6); /* 26 */
	GG (c, d, a, b, x[ 3], 14, 0xf4d50d87); /* 27 */
	GG (b, c, d, a, x[ 8], 20, 0x455a14ed); /* 28 */
	GG (a, b, c, d, x[13],  5, 0xa9e3e905); /* 29 */
	GG (d, a, b, c, x[ 2],  9, 0xfcefa3f8); /* 30 */
	GG (c, d, a, b, x[ 7], 14, 0x676f02d9); /* 31 */
	GG (b, c, d, a, x[12], 20, 0x8d2a4c8a); /* 32 */

	/* Round 3 */
	HH (a, b, c, d, x[ 5],  4, 0xfffa3942); /* 33 */
	HH (d, a, b, c, x[ 8], 11, 0x8771f681); /* 34 */
	HH (c, d, a, b, x[11], 16, 0x6d9d6122); /* 35 */
	HH (b, c, d, a, x[14], 23, 0xfde5380c); /* 36 */
	HH (a, b, c, d, x[ 1],  4, 0xa4beea44); /* 37 */
	HH (d, a, b, c, x[ 4], 11, 0x4bdecfa9); /* 38 */
	HH (c, d, a, b, x[ 7], 16, 0xf6bb4b60); /* 39 */
	HH (b, c, d, a, x[10], 23, 0xbebfbc70); /* 40 */
	HH (a, b, c, d, x[13],  4, 0x289b7ec6); /* 41 */
	HH (d, a, b, c, x[ 0], 11, 0xeaa127fa); /* 42 */
	HH (c, d, a, b, x[ 3], 16, 0xd4ef3085); /* 43 */
	HH (b, c, d, a, x[ 6], 23,  0x4881d05); /* 44 */
	HH (a, b, c, d, x[ 9],  4, 0xd9d4d039); /* 45 */
	HH (d, a, b, c, x[12], 11, 0xe6db99e5); /* 46 */
	HH (c, d, a, b, x[15], 16, 0x1fa27cf8); /* 47 */
	HH (b, c, d, a, x[ 2], 23, 0xc4ac5665); /* 48 */

	/* Round 4 */
	II (a, b, c, d, x[ 0],  6, 0xf4292244); /* 49 */
	II (d, a, b, c, x[ 7], 10, 0x432aff97); /* 50 */
	II (c, d, a, b, x[14], 15, 0xab9423a7); /* 51 */
	II (b, c, d, a, x[ 5], 21, 0xfc93a039); /* 52 */
	II (a, b, c, d, x[12],  6, 0x655b59c3); /* 53 */
	II (d, a, b, c, x[ 3], 10, 0x8f0ccc92); /* 54 */
	II (c, d, a, b, x[10], 15, 0xffeff47d); /* 55 */
	II (b, c, d, a, x[ 1], 21, 0x85845dd1); /* 56 */
	II (a, b, c, d, x[ 8],  6, 0x6fa87e4f); /* 57 */
	II (d, a, b, c, x[15], 10, 0xfe2ce6e0); /* 58 */
	II (c, d, a, b, x[ 6], 15, 0xa3014314); /* 59 */
	II (b, c, d, a, x[13], 21, 0x4e0811a1); /* 60 */
	II (a, b, c, d, x[ 4],  6, 0xf7537e82); /* 61 */
	II (d, a, b, c, x[11], 10, 0xbd3af235); /* 62 */
	II (c, d, a, b, x[ 2], 15, 0x2ad7d2bb); /* 63 */
	II (b, c, d, a, x[ 9], 21, 0xeb86d391); /* 64 */

	Buf[0] += A;
	Buf[1] += B;
	Buf[2] += C;
	Buf[3] += D;
}

/** update MD5 context */
static final function MD5Update(out MD5_CTX Context, string Data, int inputLen)
{
	local int i, index, partlen;
	local byte tmpbuf[64];

	index = ((context.count[0] >>> 3) & 0x3F);
	if ((context.count[0] += (inputLen << 3)) < (inputLen << 3))
		context.count[1]++;
	context.count[1] += (inputLen >>> 29);
	partLen = 64 - index;

	if (inputLen >= partLen)
	{
		MD5Move(Data, 0, context.buffer, index, partLen);
		MD5Transform (context.state, context.buffer);
		for (i = partLen; i + 63 < inputLen; i += 64)
		{
			MD5Move(Data, i, tmpbuf, 0, 64);
			MD5Transform (context.state, tmpbuf);
		}
		index = 0;
	}
	else
		i = 0;

	MD5Move(Data, i, context.buffer, index, inputLen-i);
}

/** finalize the MD5 context */
static final function MD5Final (out byte digest[64], out MD5_CTX context)
{
	local byte bits[64];
	local int i, index, padLen;
	local string strbits;
	local string PADDING;

	PADDING = chr(0x80);
	for (i = 1; i < 64; i++)
		PADDING = PADDING$chr(0);

	Encode (bits, context.count, 8);

	index = ((context.count[0] >>> 3) & 0x3f);
	if (index < 56)
		padLen = (56 - index);
	else
		padLen = (120 - index);
	MD5Update (context, PADDING, padLen);
	strbits = "";
	for (i=0;i<8;i++)
		strbits = strbits$Chr(bits[i]);
	MD5Update (context, strbits, 8);
	Encode (digest, context.state, 16);

	for (i = 0; i < 64; i++)
	{
		context.buffer[i] = 0;
	}
}

static final function Encode (out byte output[64], int input[64], int len)
{
	local int i, j;

	i = 0;
	for (j = 0; j < len; j += 4)
	{
		output[j] = (input[i] & 0xff);
		output[j+1] = ((input[i] >> 8) & 0xff);
		output[j+2] = ((input[i] >> 16) & 0xff);
		output[j+3] = ((input[i] >> 24) & 0xff);
		i++;
	}
}


static final function Decode(out int output[64], byte input[64], int len)
{
	local int i, j;

	i = 0;
	for (j = 0; j < len; j += 4)
	{
		output[i] = ((input[j]) | (int(input[j+1]) << 8) | (int(input[j+2]) << 16) | (int(input[j+3]) << 24));
		i++;
	}
}


static final function MD5Move(string src, int srcindex, out byte buffer[64], int bufindex, int len)
{
	local int i,j;

	j = bufindex;
	for (i = srcindex; i < srcindex+len; i++)
	{
		buffer[j] = Asc(Mid(src, i, 1));
		j++;
		if (j == 64)
			break;
	}
}


static final function int ROTATE_LEFT (int x, int n)
{
	return (((x) << (n)) | ((x) >>> (32-(n))));
}

static final function int F (int x, int y, int z)
{
	return (((x) & (y)) | ((~x) & (z)));
}

static final function int G (int x, int y, int z)
{
	return ((x & z) | (y & (~z)));
}

static final function int H (int x, int y, int z)
{
	return (x ^ y ^ z);
}

static final function int I (int x, int y, int z)
{
	return (y ^ (x | (~z)));
}

static final function FF(out int a, int b, int c, int d, int x, int s, int ac)
{
	a += F(b, c, d) + x + ac;
	a = ROTATE_LEFT (a, s);
	a += b;
}

static final function GG(out int a, int b, int c, int d, int x, int s, int ac)
{
	a += G(b, c, d) + x + ac;
	a = rotate_left (a, s) +b;
}

static final function HH(out int a, int b, int c, int d, int x, int s, int ac)
{
	a += H(b, c, d) + x + ac;
	a = rotate_left (a, s) +b;
}

static final function II(out int a, int b, int c, int d, int x, int s, int ac)
{
	a += I(b, c, d) + x + ac;
	a = rotate_left (a, s) +b;
}

static final function string DecToHex(int dec, int size)
{
	const hex = "0123456789ABCDEF";
	local string s;
	local int i;

	for (i = 0; i < size*2; i++)
	{
		s = mid(hex, dec & 0xf, 1) $ s;
		dec = dec >>> 4;
	}

	return s;
}