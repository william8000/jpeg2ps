/* ASCII85 and Hex encoding for PostScript Level 2 and PDF */
/* (C) Thomas Merz 1994-2002 */

#include <stdio.h>
#include <fcntl.h>

/* try to identify Mac compilers */
#ifdef __MWERKS__
#if __POWERPC__ || __CFM68K__ || __MC68K_
#define MAC
#else
#define DOS
#endif
#endif /* __MWERKS__ */

#ifdef DOS
#include <io.h>
#endif

#if defined(DOS) || defined(__STDC__)
#include <stdlib.h>
#endif

#include "psimage.h"

typedef unsigned char byte;

static unsigned char buf[4];
static const unsigned long power85[5] = { 1L, 85L, 85L*85, 85L*85*85, 85L*85*85*85};
static int outbytes;		/* Number of characters in an output line */

/* read 0-4 Bytes. result: number of bytes read */
static int
ReadSomeBytes(FILE * in)
{
#if 1
  return (int) fread(buf, 1, 4, in);
#else
  register int count, i;

  for (count = 0; count < 4; count++) {
    if ((i = getc(in)) == EOF)
      break;
    else
      buf[count] = (byte) i;
  }
  return count;
#endif
}

/* Two percent characters at the start of a line will cause trouble
 * with some post-processing software. In order to avoid this, we
 * simply insert a line break if we encounter a percent character
 * at the start of the line. Of course, this rather simplistic
 * algorithm may lead to a large line count in pathological cases,
 * but the chance for hitting such a case is very small, and even
 * so it's only a cosmetic flaw and not a functional restriction.
 */

static void
outbyte(byte c, FILE * out)
{    /* output one byte */

  if (putc(c, out) == EOF) {
    fprintf(stderr, "jpeg2ps: write error - exit!\n");
    exit(1);
  }

  if (++outbytes > 63 ||		/* line limit reached */
    (outbytes == 1 && c == '%') ) {	/* caution: percent character at start of line */
    fputc('\n', out);			/* insert line feed */
    outbytes = 0;
  }
}

int
ASCII85Encode(FILE * in, FILE * out)
{
  register int i, count;
  unsigned long word, v;

  outbytes = 0;

  /* 4 bytes read ==> output 5 bytes */
  while ((count = ReadSomeBytes(in)) == 4) {
    word = ((unsigned long)(((unsigned int)buf[0] << 8) + buf[1]) << 16) +
                   (((unsigned int)buf[2] << 8) + buf[3]);
    if (word == 0)
      outbyte('z', out);       /* shortcut for 0 */
    else
      /* calculate 5 ASCII85 bytes and output them */
      for (i = 4; i >= 0; i--) {
	v = word / power85[i];
	outbyte((byte) (v + '!'), out);
	word -= v * power85[i];
      }
  }

  word = 0;

  if (count > 0) {   /* 1-3 bytes left */
    for (i = count-1; i >= 0; i--)   /* accumulate bytes */
      word += (unsigned long)buf[i] << 8 * (3-i);

    /* encoding as above, but output only count+1 bytes */
    for (i = 4; i >= 4-count; i--) {
      v = word / power85[i];
      outbyte((byte) (v + '!'), out);
      word -= v * power85[i];
    }
  }

  fputc('~', out);	/* EOD marker */
  fputc('>', out);
  return 0;
}

void
ASCIIHexEncode(FILE *in, FILE * out) {
  static char buffer[512];
  static char BinToHex[] = "0123456789ABCDEF";
  int CharsPerLine;
  size_t i, n;
  unsigned char *p;

  CharsPerLine = 0;
  fputc('\n', out);

  while ((n = fread(buffer, 1, sizeof(buffer), in)) != 0)
    for (i = 0, p = (unsigned char *) buffer; i < n; i++, p++) {
      fputc(BinToHex[*p>>4], out);           /* first nibble  */
      fputc(BinToHex[*p & 0x0F], out);       /* second nibble */
      if ((CharsPerLine += 2) >= 64) {
        fputc('\n', out);
        CharsPerLine = 0;
      }
    }

  fputc('>', out);         /* EOD marker for PostScript hex strings */
}

