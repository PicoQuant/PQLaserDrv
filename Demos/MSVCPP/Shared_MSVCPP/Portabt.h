//-----------------------------------------------------------------------------
//
//      Portabt.h
//
//-----------------------------------------------------------------------------
//
//  sharable definitions, needful for most applications:
//
//-----------------------------------------------------------------------------
//

#ifndef   __PORTABT_H__
  #define __PORTABT_H__

  typedef unsigned char      byte;
  typedef unsigned short     word;
  typedef unsigned int       dword;
  typedef unsigned __int64   qword;

  #pragma pack (push, PREVIOUS_PACK_VALUE, 1)   // we need to pack the following structs byte by byte

  typedef
    union _T_ShortTypes                         // combining a short, a word and two bytes with the I²C data sending convention
    {
      short  i;
      word   w;
      struct
      {
        byte b0;                                // take care to put the LSB allways first in structure!
        byte b1;
      } bytes;
      byte   b[2];
    } T_ShortTypes;

  typedef
    union _T_LongTypes                          // combining a long, a dword and four bytes with the I²C data sending convention
    {
      long   l;
      dword  dw;
      struct
      {
        word w0;                                // take care to put the LSW allways first in structure!
        word w1;
      } words;
      word   w[2];
      struct
      {
        byte b0;                                // take care to put the LSB allways first in structure!
        byte b1;
        byte b2;
        byte b3;
      } bytes;
      byte   b[4];
      float  f;
    } T_LongTypes;

  typedef
    union _T_LongLongTypes                      // combining a double, a qword, a two dwords and eight bytes with the I²C data sending convention
    {
      qword  qw;
      struct
      {
        dword dw0;
        dword dw1;
      } dwords;
      dword   dw[2];
      struct
      {
        word w0;
        word w1;
        word w2;
        word w3;
      } words;
      word   w[4];
      struct
      {
        byte b0;
        byte b1;
        byte b2;
        byte b3;
        byte b4;
        byte b5;
        byte b6;
        byte b7;
      } bytes;
      byte   b[8];
      double  df;
    } T_LongLongTypes;

    #pragma pack (pop, PREVIOUS_PACK_VALUE)     // ...get back to where we once belonged

#endif // __PORTABT_H__

