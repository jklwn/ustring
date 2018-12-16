' changed [] operator
' removed some functions


' ****************************************************************************************
' This code is copied and adapted from WinFBX with explicit permission of José Roca 
' under the condition that the original copyright applies (see below). 
' All changes and additions are Copyright (c) 2018 Juergen Kuehlwein
' Freeware. Use at your own risk.
' THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
' EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
' MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
' ****************************************************************************************

' ########################################################################################
' Microsoft Windows
' Implements a dynamic data type for null terminated unicode strings.
' Compiler: Free Basic 32 & 64 bit
' Copyright (c) 2016 Paul Squires & José Roca, with the collaboration of Marc Pons.
' Freeware. Use at your own risk.
' THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
' EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
' MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
' ########################################################################################


const _WIN32_WINNT = &h0602

const crlf = !"\r\n"
const cr = !"\r"
const lf = !"\n"
'const tab = !"\t"
'const spc = " "
const dq = chr(34)

'***********************************************************************************************
' define constants for string helper functions
' convert $ to _, if space, comma or "(" follows  
'***********************************************************************************************


const path_ = 1                                       'path$
const any_ = 1                                        'any$
const name_ = 2                                       'name$
const namex_ = 3                                      'namex$
const extn_ = 4                                       'extn$
const case_ = 1                                       'case$



'***********************************************************************************************
' add USTRING as dynamc Unicode string type
'***********************************************************************************************
#pragma USTRING                                       'set compiler for dynamic wide string

#undef ustring
#define ustring jk.DWSTR                              'use replacement

#ifdef unicode   
  #ifndef dstr                                        'dynamic unicode string
    #define dstr ustring                              '(DWSTR)
  #endif  
  #ifndef zstr                                        'zero terminated unicode string (* bytes)
    #define zstr wstring
  #endif  
#ELSE
  #ifndef dstr                                        'dynamic ansi string
    #define dstr string
  #endif  
  #ifndef zstr                                        'zero terminated ansi string (* bytes)
    #define zstr zstring
  #endif  
#ENDIF



'#include str_inc                                      'STR_INC = filespec for "fb_str.inc"



'***********************************************************************************************
' replacement for José Roca´s CWstr, if WinFBX is not present or is not used.
' this is mostly a clone of his code with a "JK_" prefix
'***********************************************************************************************

common shared ustring_mtwc as function(BYVAL CodePage AS Ulong, BYVAL dwFlags AS Ulong, BYVAL lpMultiByteStr AS zstring ptr, _
              BYVAL cbMultiByte AS LONG, BYVAL lpWideCharStr AS wstring ptr, BYVAL cchWideChar AS LONG) AS long


common shared ustring_wctm as function(BYVAL CodePage AS Ulong, BYVAL dwFlags AS ulong, BYVAL lpWideCharStr AS wstring ptr, _
              BYVAL cchWideChar AS LONG, BYVAL lpMultiByteStr AS zstring ptr, BYVAL cbMultiByte AS LONG, BYVAL lpDefaultChar AS byte ptr, BYVAL lpUsedDefaultChar AS Long ptr) AS long


Dim As Any Ptr ustring_k_library = Dylibload("Kernel32.dll")
  ustring_mtwc = Dylibsymbol(ustring_k_library, "MultiByteToWideChar")
  ustring_wctm = Dylibsymbol(ustring_k_library, "WideCharToMultiByte")


CONST ustring_CP_UTF8 = 65001
CONST ustring_MB_PRECOMPOSED = &h00000001


#ifdef  __FB_64BIT__
private sub mcpy(dest as any ptr, src as any ptr, count as uinteger)
'***********************************************************************************************
' memcpy replacement
'***********************************************************************************************

asm
'  push rdi
'  push rsi

  push rcx

  mov rdi, [dest]                                     'destination
  mov rsi, [src]                                      'source
  mov rcx, [count]                                    '# of byte to copy

  shr rcx, 3                                          '/4
  cld
  
  rep movsq                                           'copy qwords

  mov rcx, [count]
  and rcx, 7                                          'mod 8

  rep movsb                                           'copy bytes
  
  pop rcx

'  pop rsi
'  pop rdi
end asm

end sub

#else

private sub ustring_mcpy(dest as any ptr, src as any ptr, count as Ulong)
'***********************************************************************************************
' memcpy replacement
'***********************************************************************************************

asm
'  push edi
'  push esi

  push ecx

  mov edi, [dest]                                     'destination
  mov esi, [src]                                      'source
  mov ecx, [count]                                    '# of byte to copy

  shr ecx, 2                                          '/4
  cld
  
  rep movsd                                           'copy dwords

  mov ecx, [count]
  and ecx, 3                                          'mod 4

  rep movsb                                           'copy bytes
  
  pop ecx

'  pop esi
'  pop edi
end asm

end sub

#endif


'***********************************************************************************************
'***********************************************************************************************


#pragma ONCE


NAMESPACE JK                                          'obviously i cannot use "AFX" here
TYPE DWSTR_ AS DWSTR                                  'Forward reference


'***********************************************************************************************
' Macro for debug
' To allow debugging, define _DWSTR_DEBUG_ 1 in your application before including this file.
'***********************************************************************************************
#ifndef _DWSTR_DEBUG_
   #define _DWSTR_DEBUG_ 0
#ENDIF
#ifndef _DWSTR_DP_
   #define _DWSTR_DP_ 1
   #MACRO DWSTR_DP(st)
      #IF (_DWSTR_DEBUG_ = 1)
         OutputDebugStringW(st)
      #ENDIF
   #ENDMACRO
#ENDIF


'***********************************************************************************************
' DWSTR CLASS
'***********************************************************************************************


TYPE DWSTR
  m_pBuffer AS UBYTE PTR                              'pointer to the buffer (in first place make strptr possible)

  Private:
    m_Capacity AS Ulong                               'the total size of the buffer
    m_GrowSize AS LONG = 260 * 2                      'how much to grow the buffer by when required
    m_CodePage AS ulong                               'unicode code page


  Public:
'      m_pBuffer AS UBYTE PTR        ' Pointer to the buffer

    m_BufferLen AS ulong                              'length in bytes of the current string in the buffer

    DECLARE CONSTRUCTOR
    DECLARE CONSTRUCTOR (BYVAL nChars AS ulong, BYVAL nCodePage AS ulong)
    DECLARE CONSTRUCTOR (BYVAL pwszStr AS WSTRING PTR)
    DECLARE CONSTRUCTOR (BYREF ansiStr AS STRING, BYVAL nCodePage AS ulong = 0)
    DECLARE CONSTRUCTOR (BYREF cws AS DWSTR)
    DECLARE CONSTRUCTOR (BYVAL n AS LONGINT)
    DECLARE CONSTRUCTOR (BYVAL n AS DOUBLE)

    DECLARE DESTRUCTOR

    DECLARE SUB ResizeBuffer (BYVAL nValue AS ulong)
    DECLARE FUNCTION AppendBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nNumBytes AS ulong) AS BOOLEAN
    DECLARE FUNCTION InsertBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nIndex AS ulong, BYVAL nNumBytes AS ulong) AS BOOLEAN
    DECLARE PROPERTY GrowSize () AS LONG
    DECLARE PROPERTY GrowSize (BYVAL nValue AS LONG)
    DECLARE PROPERTY Capacity () AS ulong
    DECLARE PROPERTY Capacity (BYVAL nValue AS ulong)
    DECLARE PROPERTY SizeAlloc (BYVAL nChars AS ulong)
    DECLARE PROPERTY SizeOf () AS ulong
    DECLARE PROPERTY CodePage () AS ulong
    DECLARE PROPERTY CodePage (BYVAL nCodePage AS ulong)
    DECLARE SUB Clear
'    DECLARE SUB Resize (BYVAL nSize AS ulong, BYREF ch AS WSTRING = "")
    DECLARE SUB Add (BYREF cws AS DWSTR)
    DECLARE SUB Add (BYVAL pwszStr AS WSTRING PTR)
    DECLARE SUB Add (BYREF ansiStr AS STRING, BYVAL nCodePage AS ulong = 0)

'    DECLARE PROPERTY Char(BYVAL nIndex AS ulong) AS USHORT
'    DECLARE PROPERTY Char(BYVAL nIndex AS ulong, BYVAL nValue AS USHORT)

    DECLARE OPERATOR [] (BYVAL nIndex AS ulong) AS USHORT

'    DECLARE FUNCTION DelChars (BYVAL nIndex AS ulong, BYVAL nCount AS ulong) AS BOOLEAN
'    DECLARE FUNCTION Insert (BYREF cws AS DWSTR, BYVAL nIndex AS ulong) AS BOOLEAN
'    DECLARE FUNCTION Insert (BYVAL pwszStr AS WSTRING PTR, BYVAL nIndex AS ulong) AS BOOLEAN
'    DECLARE FUNCTION Insert (BYREF ansiStr AS STRING, BYVAL nIndex AS ulong, BYVAL nCodePage AS ulong = 0) AS BOOLEAN

    DECLARE OPERATOR CAST () BYREF AS WSTRING
    DECLARE OPERATOR CAST () AS ANY PTR


    DECLARE OPERATOR LET (BYREF ansiStr AS STRING)
    DECLARE OPERATOR LET (BYREF wszStr AS CONST WSTRING)
    DECLARE OPERATOR LET (BYREF pwszStr AS WSTRING PTR)
    DECLARE OPERATOR LET (BYREF cws AS DWSTR)

'      DECLARE OPERATOR LET (BYVAL n AS LONGINT)
'      DECLARE OPERATOR LET (BYVAL n AS DOUBLE)

    DECLARE OPERATOR += (BYREF wszStr AS WSTRING)
    DECLARE OPERATOR += (BYREF cws AS DWSTR)
    DECLARE OPERATOR += (BYREF ansiStr AS STRING)

'      DECLARE OPERATOR += (BYVAL n AS LONGINT)
'      DECLARE OPERATOR += (BYVAL n AS DOUBLE)

    DECLARE OPERATOR &= (BYREF wszStr AS WSTRING)
    DECLARE OPERATOR &= (BYREF cws AS DWSTR)
    DECLARE OPERATOR &= (BYREF ansiStr AS STRING)
    DECLARE OPERATOR &= (BYVAL n AS LONGINT)
    DECLARE OPERATOR &= (BYVAL n AS DOUBLE)

'    DECLARE FUNCTION vptr () AS WSTRING PTR
'    DECLARE FUNCTION sptr () AS WSTRING PTR
'    DECLARE FUNCTION wstr () BYREF AS WSTRING
'    DECLARE FUNCTION wchar () AS WSTRING PTR
'    DECLARE PROPERTY utf8 () AS STRING
'    DECLARE PROPERTY utf8 (BYREF ansiStr AS STRING)
END TYPE


'***********************************************************************************************
' DWSTR constructors
'***********************************************************************************************


PRIVATE CONSTRUCTOR DWSTR
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR Default")
  this.ResizeBuffer(m_GrowSize)                       'Create the initial buffer
  DWSTR_DP("END DWSTR CONSTRUCTOR Default - " & .WSTR(m_pBuffer))
END CONSTRUCTOR

PRIVATE CONSTRUCTOR DWSTR (BYVAL nChars AS ulong, BYVAL nCodePage AS ulong)
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR nChars " & .WSTR(nChars))
  m_CodePage = nCodePage                              'Store the code page
  IF nChars = 0 THEN nChars = m_GrowSize \ 2
  this.ResizeBuffer(nChars * 2)                       'Create the initial buffer
  DWSTR_DP("-END- DWSTR CONSTRUCTOR nChars - " & .WSTR(m_pBuffer))
END CONSTRUCTOR

PRIVATE CONSTRUCTOR DWSTR (BYVAL pwszStr AS WSTRING PTR)
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR WSTRING - " & .WSTR(pwszStr))
  IF pwszStr = 0 THEN
     this.ResizeBuffer(m_GrowSize)                    'Create the initial buffer
  ELSE
     this.Add(pwszStr)                                'Add the passed WSTRING
  END IF
  DWSTR_DP("-END- DWSTR CONSTRUCTOR WSTRING - " & .WSTR(m_pBuffer))
END CONSTRUCTOR

PRIVATE CONSTRUCTOR DWSTR (BYREF ansiStr AS STRING, BYVAL nCodePage AS ulong = 0)
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR STRING - " & .WSTR(VARPTR(ansiStr)))
  m_CodePage = nCodePage                              'Store the code page
  IF .LEN(ansiStr) THEN
     this.Add(ansiStr, nCodePage)                     'Add the passed ansi string
  ELSE
     this.ResizeBuffer(m_GrowSize)                    'Create the initial buffer
  END IF
  DWSTR_DP("-END- DWSTR CONSTRUCTOR STRING - " & .WSTR(m_pBuffer))
END CONSTRUCTOR

PRIVATE CONSTRUCTOR DWSTR (BYREF cws AS DWSTR)
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR DWSTR")
  IF cws.m_BufferLen THEN
     this.Add(cws)                                    'Add the passed DWSTR
  ELSE
     this.ResizeBuffer(m_GrowSize)                    'Create the initial buffer
  END IF
  DWSTR_DP("-END- DWSTR CONSTRUCTOR DWSTR - " & .WSTR(m_pBuffer))
END CONSTRUCTOR

PRIVATE CONSTRUCTOR DWSTR (BYVAL n AS LONGINT)
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR LONGINT")
  DIM wsz AS WSTRING * 260 = .WSTR(n)
  this.Add(wsz)
  DWSTR_DP("-END- DWSTR CONSTRUCTOR LONGINT - " & .WSTR(m_pBuffer))
END CONSTRUCTOR

PRIVATE CONSTRUCTOR DWSTR (BYVAL n AS DOUBLE)
  DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR DOUBLE")
  DIM wsz AS WSTRING * 260 = .WSTR(n)
  this.Add(wsz)
  DWSTR_DP("-END- DWSTR CONSTRUCTOR DOUBLE - " & .WSTR(m_pBuffer))
END CONSTRUCTOR


'***********************************************************************************************
' Destructor
'***********************************************************************************************


PRIVATE DESTRUCTOR DWSTR
  DWSTR_DP("***DWSTR DESTRUCTOR - buffer: " & .WSTR(m_pBuffer))
  IF m_pBuffer THEN Deallocate(m_pBuffer)
  m_pBuffer = 0
END DESTRUCTOR


'***********************************************************************************************
' operators
'***********************************************************************************************


'***********************************************************************************************
' One * returns the address of the DWSTR buffer.
' Two ** deferences the string data.
' We have to use **cws (notice the double indirection) with these functions.
'***********************************************************************************************


PRIVATE OPERATOR * (BYREF cws AS DWSTR) AS WSTRING PTR
  DWSTR_DP("DWSTR OPERATOR * buffer: " & .WSTR(cws.m_pBuffer))
  OPERATOR = cast(WSTRING PTR, cws.m_pBuffer)
END OPERATOR


'***********************************************************************************************


PRIVATE OPERATOR LEN (BYREF cws AS DWSTR) AS ulong    'returns the length, in characters, of the DWSTR.
  DWSTR_DP("DWSTR OPERATOR LEN - len: " & .WSTR(cws.m_BufferLen \ 2))
  OPERATOR = cws.m_BufferLen \ 2
END OPERATOR

PRIVATE OPERATOR DWSTR.CAST () AS ANY PTR             'returns a pointer to the DWSTR buffer.
  DWSTR_DP("DWSTR CAST ANY PTR - buffer: " & .WSTR(m_pBuffer))
  OPERATOR = cast(ANY PTR, m_pBuffer)
END OPERATOR

PRIVATE OPERATOR DWSTR.CAST () BYREF AS WSTRING       'returns the string data (same as **).
  DWSTR_DP("DWSTR CAST BYREF AS WSTRING - buffer: " & .WSTR(m_pBuffer))
  OPERATOR = *cast(WSTRING PTR, m_pBuffer)
END OPERATOR

PRIVATE OPERATOR DWSTR.[] (BYVAL nIndex AS ulong) AS USHORT          
'***********************************************************************************************
' Returns the corresponding ASCII or Unicode integer representation of the character at
' the position specified by the nIndex parameter. Like the get Char property, but allowing
' to use the [] syntax, e.g. value = cws[1]. Can't be used to change a value.
'***********************************************************************************************
'   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN EXIT OPERATOR

  IF nIndex > m_BufferLen \ 2 THEN EXIT OPERATOR
'  nIndex -= 1                                         'must be removed !!!
  OPERATOR = PEEK(USHORT, m_pBuffer + (nIndex * 2))
END OPERATOR


'***********************************************************************************************
' Assigns new text to the DWSTR.
'***********************************************************************************************


PRIVATE OPERATOR DWSTR.Let (BYREF wszStr AS CONST WSTRING)
  DWSTR_DP("DWSTR LET WSTRING")
  this.Clear
  this.Add(wszStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.Let (BYREF ansiStr AS STRING)
  DWSTR_DP("DWSTR LET STRING")
  this.Clear
  this.Add(ansiStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.Let (BYREF pwszStr AS WSTRING PTR)
  DWSTR_DP("DWSTR LET WSTRING PTR = " & .WSTR(pwszStr))
  IF pwszStr = 0 THEN EXIT OPERATOR
  this.Clear
  this.Add(*pwszStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.Let (BYREF cws AS DWSTR)
  DWSTR_DP("DWSTR LET DWSTR - m_pBuffer = " & .WSTR(m_pBuffer) & " - IN buffer = " & .WSTR(cws.m_pBuffer))
  IF m_pBuffer = cws.m_pBuffer THEN EXIT OPERATOR   ' // Ignore cws = cws
  this.Clear
  this.Add(cws)
END OPERATOR


'***********************************************************************************************
' Appends a string to the DWSTR
'***********************************************************************************************


PRIVATE OPERATOR DWSTR.+= (BYREF wszStr AS WSTRING)   'appends a wstring to the DWSTR
  DWSTR_DP("DWSTR OPERATOR += WSTRING")
  this.Add(wszStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.+= (BYREF ansiStr AS STRING)   'appends a string to the DWSTR
  DWSTR_DP("DWSTR OPERATOR += STRING")
  this.Add(ansiStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.+= (BYREF cws AS DWSTR)        'appends a DWSTR to the DWSTR
  DWSTR_DP("DWSTR OPERATOR += DWSTR")
  this.Add(cws)
END OPERATOR

'***********************************************************************************************
'PRIVATE OPERATOR DWSTR.+= (BYVAL n AS LONGINT)
'   DWSTR_DP("DWSTR OPERATOR += LONGINT")
'   DIM wsz AS WSTRING * 260 = .WSTR(n)
'   this.Add(wsz)
'END OPERATOR

'PRIVATE OPERATOR DWSTR.+= (BYVAL n AS DOUBLE)
'   DWSTR_DP("DWSTR OPERATOR += DOUBLE")
'   DIM wsz AS WSTRING * 260 = .WSTR(n)
'   this.Add(wsz)
'END OPERATOR
'***********************************************************************************************


PRIVATE OPERATOR DWSTR.&= (BYREF wszStr AS WSTRING)   'appends a wstring to the DWSTR
  DWSTR_DP("DWSTR OPERATOR &= WSTRING")
  this.Add(wszStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.&= (BYREF ansiStr AS STRING)   'appends a string to the DWSTR
  DWSTR_DP("DWSTR OPERATOR &= STRING")
  this.Add(ansiStr)
END OPERATOR

PRIVATE OPERATOR DWSTR.&= (BYREF cws AS DWSTR)        'appends a DWSTR to the DWSTR
  DWSTR_DP("DWSTR OPERATOR &= DWSTR")
  this.Add(cws)
END OPERATOR


'***********************************************************************************************


PRIVATE OPERATOR DWSTR.&= (BYVAL n AS LONGINT)
  DWSTR_DP("DWSTR OPERATOR &= LONGINT")
  DIM wsz AS WSTRING * 260 = .WSTR(n)
  this.Add(wsz)
END OPERATOR

PRIVATE OPERATOR DWSTR.&= (BYVAL n AS DOUBLE)
  DWSTR_DP("DWSTR OPERATOR &= DOUBLE")
  DIM wsz AS WSTRING * 260 = .WSTR(n)
  this.Add(wsz)
END OPERATOR


'***********************************************************************************************
'PRIVATE OPERATOR DWSTR.Let (BYVAL n AS LONGINT)
'   DWSTR_DP("DWSTR OPERATOR Let LONGINT")
'   this.Clear
'   DIM wsz AS WSTRING * 260 = .WSTR(n)
'   this.Add(wsz)
'END OPERATOR

'PRIVATE OPERATOR DWSTR.Let (BYVAL n AS DOUBLE)
'   DWSTR_DP("DWSTR OPERATOR Let DOUBLE")
'   this.Clear
'   DIM wsz AS WSTRING * 260 = .WSTR(n)
'   this.Add(wsz)
'END OPERATOR
'***********************************************************************************************


'***********************************************************************************************
' ResizeBuffer
' Increases the size of the internal buffer capacity
'***********************************************************************************************


PRIVATE SUB DWSTR.ResizeBuffer (BYVAL nValue AS ulong)
  DWSTR_DP("DWSTR ResizeBuffer - Value = " & .WSTR(nValue))
  ' // If it is an odd value, make it even.
  IF (nValue MOD 2) <> 0 THEN nValue += 1
  ' Increase the size of the existing buffer by creating a new buffer copying
  ' the existing data into it and then finally deleting the original buffer.
  DIM pNewBuffer AS UBYTE PTR = Allocate(nValue + 2)   ' // +2 to make room for the double null terminator.
  DWSTR_DP("DWSTR ResizeBuffer - pNewBuffer = " & .WSTR(pNewBuffer) & " - old buffer = " & (.WSTR(m_pBuffer)))
  IF m_pBuffer THEN
     IF nValue < m_BufferLen THEN m_BufferLen = nValue
'      memcpy(pNewBuffer, m_pBuffer, m_BufferLen)
     ustring_mcpy(pNewBuffer, m_pBuffer, m_BufferLen)
     Deallocate m_pBuffer
  END IF
  m_pBuffer = pNewBuffer
  m_Capacity = nValue

  m_pBuffer[m_BufferLen] = 0                          'mark the end of the string with a double null
  m_pBuffer[m_BufferLen + 1] = 0


END SUB


'***********************************************************************************************
' Appends the specified number of bytes from the specified memory address to the end of the buffer.
'***********************************************************************************************


PRIVATE FUNCTION DWSTR.AppendBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nNumBytes AS ulong) AS BOOLEAN
  DWSTR_DP("DWSTR AppendBuffer " & .WSTR(m_BufferLen) & " " & .WSTR(nNumBytes))

  IF m_GrowSize < 0 THEN
     IF (m_BufferLen + nNumBytes) > m_Capacity THEN this.ResizeBuffer((m_BufferLen + nNumBytes) * 2)
  ELSE
     IF (m_BufferLen + nNumBytes) > m_Capacity THEN this.ResizeBuffer(m_BufferLen + nNumBytes + m_GrowSize)
  END IF
  IF m_pBuffer = 0 THEN RETURN FALSE
'   memcpy(m_pBuffer + m_BufferLen, addrMemory, nNumBytes)
  ustring_mcpy(m_pBuffer + m_BufferLen, addrMemory, nNumBytes)
  m_BufferLen += nNumBytes

  m_pBuffer[m_BufferLen] = 0                          'mark the end of the string with a double null
  m_pBuffer[m_BufferLen + 1] = 0
  RETURN TRUE
  DWSTR_DP("--END - DWSTR AppendBuffer " & .WSTR(m_BufferLen))


END FUNCTION


'***********************************************************************************************
' The string parameter is appended to the string held in the class. If the internal string
' buffer overflows, the class will automatically extend it to an appropriate size.
'***********************************************************************************************


PRIVATE SUB DWSTR.Add (BYREF cws AS DWSTR)
  DWSTR_DP("DWSTR Add DWSTR - buffer = " & .WSTR(cws.m_pBuffer) & " - LEN = " & .WSTR(LEN(*cast(WSTRING PTR, @cws))))

  ' Incoming string is already in wide format, simply copy it to the buffer.
  DIM nLenString AS ulong = cws.m_BufferLen   ' // Length in bytes
  IF nLenString = 0 THEN RETURN

  this.AppendBuffer(cast(ANY PTR, cws), nLenString)   'copy the string into the buffer and update the length


END SUB

PRIVATE SUB DWSTR.Add (BYVAL pwszStr AS WSTRING PTR)
  DWSTR_DP("DWSTR Add WSTRING")

  IF pwszStr = 0 THEN RETURN
  ' Incoming string is already in wide format
  DIM nLenString AS ulong = .LEN(*pwszStr)   ' // Length in characters
  IF nLenString = 0 THEN RETURN

  this.AppendBuffer(cast(ANY PTR, pwszStr), nLenString * 2)              'copy the string into the buffer and update the length


END SUB

PRIVATE SUB DWSTR.Add (BYREF ansiStr AS STRING, BYVAL nCodePage AS ulong = 0)
  DWSTR_DP("DWSTR Add STRING Code page = " & .WSTR (nCodePage))

  IF LEN(ansiStr) = 0 THEN RETURN
  ' Create the wide string from the incoming ansi string
  DIM dwLen AS ulong, pbuffer AS ANY PTR
  IF nCodePage = 0 THEN nCodePage = m_CodePage
  IF nCodePage = ustring_CP_UTF8 THEN
'      dwLen = MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), NULL, 0)
    dwLen = ustring_mtwc(ustring_CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), 0, 0)
    IF dwLen = 0 THEN RETURN
    dwLen *= 2
    pbuffer = Allocate(dwLen)
'      MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), pbuffer, dwLen)
    ustring_mtwc(ustring_CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), pbuffer, dwLen)

  ELSE
    dwLen = .LEN(ansiStr)
    dwLen *= 2
    pbuffer = Allocate(dwLen)
'      MultiByteToWideChar(m_CodePage, MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), pbuffer, dwLen)
    ustring_mtwc(m_CodePage, ustring_MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), pbuffer, dwLen)
  END IF
  IF pbuffer THEN

    this.AppendBuffer(pbuffer, dwLen)                 'copy the string into the buffer and update the length
    Deallocate(pbuffer)
  END IF


END SUB


'***********************************************************************************************
' All data in the class object is erased. Actually, we only set the buffer length to zero,
' indicating no string in the buffer. The allocated memory for the buffer is deallocated
' when the class is destroyed.
'***********************************************************************************************


PRIVATE SUB DWSTR.Clear
  DWSTR_DP("DWSTR Clear")
  m_BufferLen = 0

  m_pBuffer[m_BufferLen] = 0                         'mark the end of the string with a double null
  m_pBuffer[m_BufferLen + 1] = 0
END SUB


'***********************************************************************************************
' properties
'***********************************************************************************************

'***********************************************************************************************
' Number of characters to preallocate to minimize multiple allocations when doing multiple
' concatenations. A value of less than 0 indicates that it must double the capacity each
' time that the buffer needs to be resized.
'***********************************************************************************************


PRIVATE PROPERTY DWSTR.GrowSize() AS LONG
  DWSTR_DP("DWSTR PROPERTY GET GrowSize")
  IF m_GrowSize > -1 THEN PROPERTY = m_GrowSize \ 2 ELSE PROPERTY = m_GrowSize
END PROPERTY

PRIVATE PROPERTY DWSTR.GrowSize (BYVAL nChars AS LONG)
  DWSTR_DP("DWSTR PROPERTY SET Growsize")
  IF nChars > -1 THEN m_GrowSize = nChars * 2 ELSE m_GrowSize = -1
END PROPERTY


'***********************************************************************************************
' The size of the internal string buffer is retrieved and returned to the caller. The size
' is the number of bytes which can be stored without further expansion.
'***********************************************************************************************


PRIVATE PROPERTY DWSTR.Capacity() AS ulong
  DWSTR_DP("DWSTR PROPERTY GET Capacity")
  PROPERTY = m_Capacity
END PROPERTY


'***********************************************************************************************
' The internal string buffer is expanded to the specified number of bytes. If the new
' capacity is smaller or equal to the current capacity, no operation is performed. If it is
' smaller, the buffer is shortened and the contents that exceed the new capacity are lost.
'***********************************************************************************************


PRIVATE PROPERTY DWSTR.Capacity (BYVAL nValue AS ulong)
  DWSTR_DP("DWSTR PROPERTY SET Capacity")
  ' // If the new capacity is the same that the current capacity, do nothing.
  IF nValue = m_Capacity THEN EXIT PROPERTY
  ' // Make sure that the number is odd (ResizeBuffer already does it)
'   IF (nValue MOD 2) <> 0 THEN nValue += 1
  this.ResizeBuffer(nValue)
END PROPERTY


'***********************************************************************************************
' The internal string buffer is expanded to the specified number of byyes.
' Sets the capacity of the buffer in characters. If the new capacity is equal to the
' current capacity, no operation is performed. If it is smaller, the buffer is shortened
' and the contents that exceed the new capacity are lost.
'***********************************************************************************************


PRIVATE PROPERTY DWSTR.SizeAlloc (BYVAL nChars AS ulong)
  DWSTR_DP("DWSTR PROPERTY SET SizeAlloc")
  ' // If the new capacity is the same that the current capacity, do nothing.
  IF nChars = m_Capacity \ 2 THEN EXIT PROPERTY
  this.ResizeBuffer(nChars * 2)
END PROPERTY

PRIVATE PROPERTY DWSTR.SizeOf() AS ulong              'returns the capacity of the buffer in characters.
  DWSTR_DP("DWSTR PROPERTY GET SizeOf")
  PROPERTY = m_Capacity \ 2
END PROPERTY


'***********************************************************************************************
' Gets/sets the code page used to ansi to unicode translations
'***********************************************************************************************


PRIVATE PROPERTY DWSTR.CodePage () AS ulong
  DWSTR_DP("DWSTR PROPERTY GET CodePage - " & .WSTR(m_CodePage))
  PROPERTY = m_CodePage
END PROPERTY

PRIVATE PROPERTY DWSTR.CodePage (BYVAL nCodePage AS ulong)
  DWSTR_DP("DWSTR PROPERTY SET CodePage - " & .WSTR(nCodePage))
  m_CodePage = nCodePage
END PROPERTY


'***********************************************************************************************
' Resizes the string to a length of n characters.
' Parameters:
' nSize : New string length, expressed in number of characters.
' ch: Character used to fill the new character space added to the string (in case the
' string is expanded).
' If nSize is smaller than the current string length, the current value is shortened to
' its first nSize characters.
' If nSize is greater than the current string length, the current content is extended by
' inserting at the end as many characters as needed to reach a size of nSize. If ch is
' specified, the new elements are initialized as copies of ch, otherwise, spaces are added.
'***********************************************************************************************


'PRIVATE SUB DWSTR.Resize (BYVAL nSize AS ulong, BYREF ch AS WSTRING = "")
'  DWSTR_DP("DWSTR Resize")
'
'  IF m_BufferLen \ 2 = nSize THEN EXIT SUB
'  IF m_BufferLen \ 2 > nSize THEN
'     m_BufferLen = nSize * 2
'     m_Capacity = nSize * 2
'     m_pBuffer[m_BufferLen] = 0
'     m_pBuffer[m_BufferLen + 1] = 0
'  ELSE
'     IF LEN(ch) > 1 THEN ch = LEFT(ch, 1)
'     DIM nChars AS ulong = ((nSize * 2) - m_BufferLen) \ 2
'     DIM cws AS DWSTR = SPACE(nChars)
'     IF ch <> "" THEN
'        FOR i AS LONG = 1 TO nChars
'           MID(**cws, i, 1) = ch
'        NEXT
'     END IF
'     this.Add(cws)
'  END IF
'
'
'END SUB


'***********************************************************************************************
' nCount characters are removed starting at the position given by nIndex.
' nIndex = 1 for the first character, 2 for the second, etc.
' Return value: If the function succeeds, it returns TRUE; otherwise, FALSE.
' Remarks: If nCount is bigger that the number of characters available to delete, the
' function deletes all the characters from nIndex to the end of the string.
'***********************************************************************************************


'PRIVATE FUNCTION DWSTR.DelChars (BYVAL nIndex AS ulong, BYVAL nCount AS ulong) AS BOOLEAN
'  DWSTR_DP("DWSTR DelChars")
'  IF nIndex < 1 OR nIndex > m_BufferLen \ 2 OR nCount < 1 THEN RETURN FALSE
'  DIM numChars AS ulong = m_BufferLen \ 2
'  IF nCount > numChars - nIndex + 1 THEN nCount = numChars - nIndex + 1
'  DIM nOffset AS ulong = (nIndex - 1 + nCount) * 2
''   memcpy(m_pBuffer + (nOffset - nCount * 2), m_pBuffer + nOffset, m_BufferLen - (nCount * 2))
'  ustring_mcpy(m_pBuffer + (nOffset - nCount * 2), m_pBuffer + nOffset, m_BufferLen - (nCount * 2))
'  m_BufferLen -= (nCount * 2)
'  ' Mark the end of the string with a double null
'  m_pBuffer[m_BufferLen] = 0
'  m_pBuffer[m_BufferLen + 1] = 0
'
'  RETURN TRUE
'
'
'END FUNCTION


'***********************************************************************************************
' Inserts the specified number of bytes from the specified memory address into the buffer.
'***********************************************************************************************


'PRIVATE FUNCTION DWSTR.InsertBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nIndex AS ulong, BYVAL nNumBytes AS ulong) AS BOOLEAN
'  DWSTR_DP("DWSTR InsertBuffer")
'
'  IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN RETURN FALSE
'  ' Determine the size of the new buffer
'  IF m_BufferLen + nNumBytes > m_Capacity THEN m_Capacity = m_BufferLen + nNumBytes
'  DIM pNewBuffer AS UBYTE PTR = Allocate((m_Capacity + 1) * 2)
'  IF m_pBuffer THEN
'     nIndex -= 1
'     ' Copy the existing data into the new buffer
''      memcpy(pNewBuffer, m_pBuffer, nIndex * 2)
'     ustring_mcpy(pNewBuffer, m_pBuffer, nIndex * 2)
'     DIM nOffset AS ulong = nIndex * 2
''      memcpy(pNewBuffer + nOffset, addrMemory, nNumBytes)
'     ustring_mcpy(pNewBuffer + nOffset, addrMemory, nNumBytes)
'     nOffset += nNumBytes
''      memcpy(pNewBuffer + nOffset, m_pBuffer + (nIndex * 2), m_BufferLen - (nIndex * 2))
'     ustring_mcpy(pNewBuffer + nOffset, m_pBuffer + (nIndex * 2), m_BufferLen - (nIndex * 2))
'     Deallocate m_pBuffer
'  END IF
'  m_pBuffer = pNewBuffer
'  m_BufferLen += nNumBytes
'
'  m_pBuffer[m_BufferLen] = 0                          'mark the end of the string with a double null
'  m_pBuffer[m_BufferLen + 1] = 0
'
'  RETURN TRUE
'
'
'END FUNCTION
'
'
''***********************************************************************************************
'' The incoming string parameter is inserted in the string starting at the position
'' given by nIndex. nIndex = 1 for the first character, 2 For the second, etc.
'' If nIndex is beyond the current length of the string + 1, no operation is performed.
''***********************************************************************************************
'
'
'PRIVATE FUNCTION DWSTR.Insert (BYREF cws AS DWSTR, BYVAL nIndex AS ulong) AS BOOLEAN
'  DWSTR_DP("DWSTR Insert DWSTR")
'
'  IF (nIndex < 1) OR nIndex > m_BufferLen \ 2 THEN RETURN FALSE
'  IF cws.m_BufferLen = 0 THEN RETURN FALSE
'  RETURN this.InsertBuffer(cast(ANY PTR,cws.m_pBuffer), nIndex, cws.m_BufferLen)
'
'
'END FUNCTION
'
'PRIVATE FUNCTION DWSTR.Insert (BYVAL pwszStr AS WSTRING PTR, BYVAL nIndex AS ulong) AS BOOLEAN
'  DWSTR_DP("DWSTR Insert WSTRING")
'
'  IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN RETURN FALSE
'  DIM nLenString AS ulong = .LEN(*pwszStr)
'  IF nLenString = 0 THEN RETURN FALSE
'  RETURN this.InsertBuffer(cast(ANY PTR, pwszStr), nIndex, nLenString * 2)
'
'
'END FUNCTION
'
'PRIVATE FUNCTION DWSTR.Insert (BYREF ansiStr AS STRING, BYVAL nIndex AS ulong, BYVAL nCodePage AS ulong = 0) AS BOOLEAN
'  DWSTR_DP("DWSTR Insert STRING")
'
'  IF nIndex < 1 OR nIndex > m_BufferLen \ 2 OR .LEN(ansiStr) = 0 THEN RETURN FALSE
'  ' Create the wide string from the incoming ansi string
'  DIM dwLen AS ulong, pbuffer AS ANY PTR
'  IF nCodePage = 0 THEN nCodePage = m_CodePage
'  IF nCodePage = ustring_CP_UTF8 THEN
''      dwLen = MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), NULL, 0)
'     dwLen = ustring_mtwc(ustring_CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), 0, 0)
'     IF dwLen = 0 THEN RETURN FALSE
'     dwLen *= 2
'     pbuffer = Allocate(dwLen)
''      MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), pbuffer, dwLen)
'     ustring_mtwc(ustring_CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), pbuffer, dwLen)
'  ELSE
'     dwLen = .LEN(ansiStr)
'     dwLen *= 2
'     pbuffer = Allocate(dwLen)
''      MultiByteToWideChar(m_CodePage, MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), pbuffer, dwLen)
'     ustring_mtwc(m_CodePage, ustring_MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), pbuffer, dwLen)
'  END IF
'
'  FUNCTION = this.InsertBuffer(pbuffer, nIndex, dwLen)'copy the string into the buffer and update the length
'  Deallocate(pbuffer)                                 
'
'
'END FUNCTION


END NAMESPACE

'***********************************************************************************************
' GLOBAL OPERATORS (Outside a namespace because they are global)
'***********************************************************************************************

'using JK

'***********************************************************************************************
PRIVATE OPERATOR & (BYREF cws1 AS JK.DWSTR, BYREF cws2 AS JK.DWSTR) AS JK.DWSTR
DIM cwsRes AS JK.DWSTR = cws1
  cwsRes.Add(cws2)
  OPERATOR = cwsRes
END OPERATOR


'***********************************************************************************************
' overloaded LEFT, RIGHT
'***********************************************************************************************


PRIVATE FUNCTION Left OVERLOAD (BYREF cws AS JK.DWSTR, BYVAL nChars AS INTEGER) AS JK.DWSTR
  RETURN LEFT(*cast(WSTRING PTR, cws.m_pBuffer), nChars)
END FUNCTION

PRIVATE FUNCTION Right OVERLOAD (BYREF cws AS JK.DWSTR, BYVAL nChars AS INTEGER) AS JK.DWSTR
  RETURN RIGHT(*cast(WSTRING PTR, cws.m_pBuffer), nChars)
END FUNCTION


'***********************************************************************************************
' overloaded VAL... functions
'***********************************************************************************************


PRIVATE FUNCTION Val OVERLOAD (BYREF cws AS JK.DWSTR) AS DOUBLE
  RETURN .VAL(*cast(WSTRING PTR, cws.m_pBuffer))
END FUNCTION

PRIVATE FUNCTION Valint OVERLOAD (BYREF cws AS jk.DWSTR) AS long 'integer
   RETURN .VALINT(*cast(WSTRING PTR, cws.m_pBuffer))
END FUNCTION

PRIVATE FUNCTION ValLNG OVERLOAD (BYREF cws AS jk.DWSTR) AS longint 'long
   RETURN .VALLNG(*cast(WSTRING PTR, cws.m_pBuffer))
END FUNCTION

PRIVATE FUNCTION ValUint OVERLOAD (BYREF cws as jk.DWSTR) AS ulong 'Uinteger
   RETURN .VALUINT(*cast(WSTRING PTR, cws.m_pBuffer))
END FUNCTION

PRIVATE FUNCTION ValULNG OVERLOAD (BYREF cws AS jk.DWSTR) AS ulongint 'ulong
   RETURN .VALULNG(*cast(WSTRING PTR, cws.m_pBuffer))
END FUNCTION



'***********************************************************************************************
' later extension          *** HELPER FUNCTIONS ***
'***********************************************************************************************
'
''***********************************************************************************************
'' qsort DWSTR comparison function
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayCompare CDECL (BYVAL a AS DWSTR PTR, BYVAL b AS DWSTR PTR) AS LONG
'   FUNCTION = wcscmp(cast(WSTRING PTR, a->m_pBuffer), cast(WSTRING PTR, b->m_pBuffer))
'END FUNCTION
''***********************************************************************************************
''***********************************************************************************************
'' Reverse qsort DWSTR comparison function
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayReverseCompare CDECL (BYVAL a AS DWSTR PTR, BYVAL b AS DWSTR PTR) AS LONG
'   DIM r AS LONG = wcscmp(cast(WSTRING PTR, a->m_pBuffer), cast(WSTRING PTR, b->m_pBuffer))
'   IF r = 1 THEN r = -1 ELSE IF r = -1 THEN r = 1
'   RETURN r
'END FUNCTION
''***********************************************************************************************
'
''***********************************************************************************************
'' Sorts a one-dimensional DWSTR array calling the C qsort function.
'' Parameters:
'' - rgwstr : Start of target array.
'' - numElm : Number of elements in the array.
'' - bAscend: TRUE for sorting in ascending order; FALSE for sorting in descending order.
'' Example:
'' DIM rg(1 TO 10) AS DWSTR
'' FOR i AS LONG = 1 TO 10
''    rg(i) = "string " & i
'' NEXT
'' FOR i AS LONG = 1 TO 10
''   print rg(i)
'' NEXT
'' print "---- after sorting ----"
'' AfxDWSTRSort @rg(1), 10, TRUE
'' FOR i AS LONG = 1 TO 10
''    print rg(i)
'' NEXT
''***********************************************************************************************
'PRIVATE SUB AfxDWSTRSort (BYREF rgwstr AS ANY PTR, BYVAL numElm AS LONG, BYVAL bAscend AS BOOLEAN = TRUE)
'   IF rgwstr = NULL OR numElm < 2 THEN EXIT SUB
'   IF bAscend THEN
'      qsort rgwstr, numElm, SIZEOF(DWSTR), CPTR(ANY PTR, @AfxDWSTRArrayCompare)
'   ELSE
'      qsort rgwstr, numElm, SIZEOF(DWSTR) , CPTR(ANY PTR, @AfxDWSTRArrayReverseCompare)
'   END IF
'END SUB
''***********************************************************************************************
''***********************************************************************************************
'PRIVATE SUB AfxDWSTRArraySort (rgwstr() AS DWSTR, BYVAL bAscend AS BOOLEAN = TRUE)
'   DIM numElm AS LONG = UBOUND(rgwstr) - LBOUND(rgwstr) + 1
'   AfxDWSTRSort @rgwstr(LBOUND(rgwstr)), numElm, bAscend
'END SUB
''***********************************************************************************************
'
''***********************************************************************************************
'' Appends a DWSTR at the end of a one-dimensional DWSTR array.
'' Parameters:
'' - rgwstr(): The DWSTR array
'' - cws: The DWSTR to append
'' Return value:
''   TRUE or FALSE
'' Example:
'' #INCLUDE ONCE "Afx/DWSTR.inc"
'' USING Afx
'' REDIM rg(1 TO 10) AS DWSTR
'' FOR i AS LONG = 1 TO 10
''    rg(i) = "string " & i
'' NEXT
'' AfxDWSTRArrayAppend(rg(), "string 11")
'' FOR i AS LONG = LBOUND(rg) TO UBOUND(rg)
''    print rg(i)
'' NEXT
'' Note: REDIM PRESERVE cannot be used on fixed-size arrays - i.e. arrays with constant bounds
'' made with DIM. If after calling REDIM PRESERVE the upper bound has not changed, it means
'' that it is a fixed string.
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayAppend (rgwstr() AS DWSTR, BYREF cws AS DWSTR) AS BOOLEAN
'   DIM upperBound AS LONG = UBOUND(rgwstr)
'   REDIM PRESERVE rgwstr(LBOUND(rgwstr) TO upperBound + 1) AS DWSTR
'   IF UBOUND(rgwstr) > upperBound THEN rgwstr(UBOUND(rgwstr)) = cws : RETURN TRUE
'   RETURN FALSE
'END FUNCTION
''***********************************************************************************************
'
''***********************************************************************************************
'' Inserts a new DWSTR element before the specified position in a one-dimensional DWSTR array.
'' Parameters:
'' - rgwstr(): The DWSTR array
'' - nPos: The position in the array where the new element will be added.
''         This position is relative to the lower bound of the array.
'' - cws: The DWSTR to append
'' Return value:
''   TRUE or FALSE
'' Example:
'' #INCLUDE ONCE "Afx/DWSTR.inc"
'' USING Afx
'' REDIM rg(1 TO 10) AS DWSTR
'' FOR i AS LONG = 1 TO 10
''    rg(i) = "string " & i
'' NEXT
'' AfxDWSTRArrayInsert(rg(), 3, "Inserted element")
'' FOR i AS LONG = LBOUND(rg) TO UBOUND(rg)
''    print rg(i)
'' NEXT
'' Note: REDIM PRESERVE cannot be used on fixed-size arrays - i.e. arrays with constant bounds
'' made with DIM. If after calling REDIM PRESERVE the upper bound has not changed, it means
'' that it is a fixed string.
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayInsert (rgwstr() AS DWSTR, BYVAL nPos AS LONG, BYREF cws AS DWSTR) AS BOOLEAN
'   DIM lowerBound AS LONG = LBOUND(rgwstr)
'   DIM upperBound AS LONG = UBOUND(rgwstr)
'   nPos = nPos - 1 + lowerBound
'   IF nPos < lowerBound OR nPos > upperBound THEN RETURN FALSE
'   REDIM PRESERVE rgwstr(lowerBound TO upperBound + 1) AS DWSTR
'   IF UBOUND(rgwstr) = upperBound THEN RETURN FALSE
'   ' // Move all the elements down
'   FOR i AS LONG = UBOUND(rgwstr) TO nPos + 1 STEP - 1
'      rgwstr(i) = rgwstr(i - 1)
'   NEXT
'   rgwstr(nPos) = cws
'   RETURN TRUE
'END FUNCTION
''***********************************************************************************************
'
''***********************************************************************************************
'' Removes the specified element of a one-dimensional DWSTR array.
'' Parameters:
'' - rgwstr(): The DWSTR array
'' - nPos: The position in the array of the element to remove.
''         This position is relative to the lower bound of the array.
'' - cws: The DWSTR to append
'' Return value:
''   TRUE or FALSE
'' Example:
'' #INCLUDE ONCE "Afx/DWSTR.inc"
'' USING Afx
'' REDIM rg(1 TO 10) AS DWSTR
'' FOR i AS LONG = 1 TO 10
''    rg(i) = "string " & i
'' NEXT
'' AfxDWSTRArrayRemove(rg(), 3)
'' FOR i AS LONG = LBOUND(rg) TO UBOUND(rg)
''    print rg(i)
'' NEXT
'' Note: REDIM PRESERVE cannot be used on fixed-size arrays - i.e. arrays with constant bounds
'' made with DIM. If after calling REDIM PRESERVE the upper bound has not changed, it means
'' that it is a fixed string.
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayRemove (rgwstr() AS DWSTR, BYVAL nPos AS LONG) AS BOOLEAN
'   DIM lowerBound AS LONG = LBOUND(rgwstr)
'   DIM upperBound AS LONG = UBOUND(rgwstr)
'   nPos = nPos - 1 + lowerBound
'   IF nPos < lowerBound OR nPos > upperBound THEN RETURN FALSE
'   FOR i AS LONG = nPos TO upperBound - 1
'      rgwstr(i) = rgwstr(i + 1)
'   NEXT
'   REDIM PRESERVE rgwstr(lowerBound TO upperBound - 1) AS DWSTR
'   IF UBOUND(rgwstr) = upperBound THEN RETURN FALSE
'   RETURN TRUE
'END FUNCTION
''***********************************************************************************************
'
''***********************************************************************************************
'' Removes the first element of a one-dimensional DWSTR array.
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayRemoveFirst (rgwstr() AS DWSTR) AS BOOLEAN
'   DIM lowerBound AS LONG = LBOUND(rgwstr)
'   DIM upperBound AS LONG = UBOUND(rgwstr)
'   DIM nPos AS LONG = lowerBound
'   FOR i AS LONG = nPos TO upperBound - 1
'      rgwstr(i) = rgwstr(i + 1)
'   NEXT
'   REDIM PRESERVE rgwstr(lowerBound TO upperBound - 1) AS DWSTR
'   IF UBOUND(rgwstr) = upperBound THEN RETURN FALSE
'   RETURN TRUE
'END FUNCTION
''***********************************************************************************************
'
''***********************************************************************************************
'' Removes the last element of a one-dimensional DWSTR array.
''***********************************************************************************************
'PRIVATE FUNCTION AfxDWSTRArrayRemoveLast (rgwstr() AS DWSTR) AS BOOLEAN
'   DIM lowerBound AS LONG = LBOUND(rgwstr)
'   DIM upperBound AS LONG = UBOUND(rgwstr)
'   REDIM PRESERVE rgwstr(lowerBound TO upperBound - 1) AS DWSTR
'   IF UBOUND(rgwstr) = upperBound THEN RETURN FALSE
'   RETURN TRUE
'END FUNCTION
''***********************************************************************************************


