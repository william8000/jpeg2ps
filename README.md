jpeg2ps
=======
jpeg2ps converts JPEG files to PostScript Level 2 or 3 EPS. In fact, jpeg2ps
is not really a converter but a "wrapper": it reads the image parameters
(width, height, number of color components) in a JPEG file, writes the
corresponding EPS header and then copies the compressed JPEG data to the output
file. Decompression is done by the PostScript interpreter (only PostScript
Level 2 and 3 interpreters support JPEG compression and decompression).
If you have a slow communication channel and a fast printer, sending
compressed image data is a big win.

Usage Details
=============
jpeg2ps [options] file.jpg > file.eps

| option    | description |
|-----------|-------------|
| `-a`      | auto rotate feature |
| `-b`      | binary mode |
| `-h`      | hex mode (ASCIIHex encoding) |
| `-m size` | margin in points (default 20) |
| `-o name` | output file name (as an alternative to output redirection) |
| `-p size` | page size name. Known names are: a0, a1, a2, a3, a4, a5, a6, b5, letter, legal, ledger, p11x17, eps |
| `-q`      | quiet mode: suppress all informational messages |
| `-r dpi`  | resolution value (0 = read from file if possible) |
| `-v`      | show version |

Mirror of a library once available at [this link](http://www.pdflib.com/fileadmin/pdflib/products/more/jpeg2ps/jpeg2ps-1.9.tar.gz) but it seems to have been removed.
