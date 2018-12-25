' changed position of "m_pBuffer AS UBYTE PTR" (strptr)
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


 const path_  = 1                                      'path$
 const any_   = 1                                      'any$
 const name_  = 2                                      'name$
 const namex_ = 3                                      'namex$
 const extn_  = 4                                      'extn$
'***********************************************************************************************
' maybe can eliminate the above by special handling in compiler
'***********************************************************************************************



const case_  = 1                                      'case$

'#undef any_
'#define any_ 1,
 

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



'***********************************************************************************************
' replacement for José Roca´s DWSTR, if WinFBX is not present or is not used.
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
   m_pBuffer AS UBYTE PTR        ' Pointer to the buffer

   Private:
      m_Capacity AS UINT            ' The total size of the buffer
      m_GrowSize AS LONG = 260 * 2  ' How much to grow the buffer by when required

   Public:
'      m_pBuffer AS UBYTE PTR        ' Pointer to the buffer
      m_BufferLen AS UINT           ' Length in bytes of the current string in the buffer

      DECLARE CONSTRUCTOR
      DECLARE CONSTRUCTOR (BYVAL nChars AS UINT, BYVAL bClear AS BOOLEAN)
      DECLARE CONSTRUCTOR (BYVAL pwszStr AS WSTRING PTR)
      DECLARE CONSTRUCTOR (BYREF ansiStr AS STRING, BYVAL nCodePage AS UINT = 0)
      DECLARE CONSTRUCTOR (BYREF cws AS DWSTR)
      DECLARE CONSTRUCTOR (BYVAL n AS LONGINT)
      DECLARE CONSTRUCTOR (BYVAL n AS DOUBLE)

      DECLARE DESTRUCTOR

      DECLARE SUB ResizeBuffer (BYVAL nValue AS UINT, BYVAL bClear AS BOOLEAN = FALSE)
      DECLARE FUNCTION AppendBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nNumBytes AS UINT) AS BOOLEAN
      DECLARE FUNCTION InsertBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nIndex AS UINT, BYVAL nNumBytes AS UINT) AS BOOLEAN

'      DECLARE PROPERTY GrowSize () AS LONG
'      DECLARE PROPERTY GrowSize (BYVAL nValue AS LONG)
'      DECLARE PROPERTY Capacity () AS UINT
'      DECLARE PROPERTY Capacity (BYVAL nValue AS UINT)
'      DECLARE PROPERTY SizeAlloc (BYVAL nChars AS UINT)
'      DECLARE PROPERTY SizeOf () AS UINT

      DECLARE SUB Clear
      DECLARE SUB Resize (BYVAL nSize AS UINT, BYREF ch AS WSTRING = "")

      DECLARE SUB Add (BYREF cws AS DWSTR)
      DECLARE SUB Add (BYVAL pwszStr AS WSTRING PTR)
      DECLARE SUB Add (BYREF ansiStr AS STRING, BYVAL nCodePage AS UINT = 0)

'      DECLARE PROPERTY Char(BYVAL nIndex AS UINT) AS USHORT
'      DECLARE PROPERTY Char(BYVAL nIndex AS UINT, BYVAL nValue AS USHORT)

      DECLARE OPERATOR [] (BYVAL nIndex AS UINT) AS USHORT

'      DECLARE FUNCTION DelChars (BYVAL nIndex AS UINT, BYVAL nCount AS UINT) AS BOOLEAN


'      DECLARE FUNCTION Insert (BYREF cws AS DWSTR, BYVAL nIndex AS UINT) AS BOOLEAN
'      DECLARE FUNCTION Insert (BYVAL pwszStr AS WSTRING PTR, BYVAL nIndex AS UINT) AS BOOLEAN
'      DECLARE FUNCTION Insert (BYREF ansiStr AS STRING, BYVAL nIndex AS UINT, BYVAL nCodePage AS UINT = 0) AS BOOLEAN

      DECLARE OPERATOR CAST () BYREF AS CONST WSTRING
      DECLARE OPERATOR CAST () AS ANY PTR

      DECLARE OPERATOR LET (BYREF ansiStr AS STRING)
      DECLARE OPERATOR LET (BYREF wszStr AS CONST WSTRING)
      DECLARE OPERATOR LET (BYREF pwszStr AS WSTRING PTR)
      DECLARE OPERATOR LET (BYREF cws AS DWSTR)
      DECLARE OPERATOR LET (BYVAL n AS LONGINT)
      DECLARE OPERATOR LET (BYVAL n AS DOUBLE)

      DECLARE OPERATOR += (BYREF wszStr AS WSTRING)
      DECLARE OPERATOR += (BYREF cws AS DWSTR)
      DECLARE OPERATOR += (BYREF ansiStr AS STRING)
      DECLARE OPERATOR += (BYVAL n AS LONGINT)
      DECLARE OPERATOR += (BYVAL n AS DOUBLE)

      DECLARE OPERATOR &= (BYREF wszStr AS WSTRING)
      DECLARE OPERATOR &= (BYREF cws AS DWSTR)
      DECLARE OPERATOR &= (BYREF ansiStr AS STRING)
      DECLARE OPERATOR &= (BYVAL n AS LONGINT)
      DECLARE OPERATOR &= (BYVAL n AS DOUBLE)


'      DECLARE FUNCTION vptr () AS WSTRING PTR
'      DECLARE FUNCTION sptr () AS WSTRING PTR
'      DECLARE FUNCTION wstr () BYREF AS CONST WSTRING
'      DECLARE FUNCTION wchar () AS WSTRING PTR
'      DECLARE PROPERTY utf8 () AS STRING
'      DECLARE PROPERTY utf8 (BYREF ansiStr AS STRING)

'      DECLARE FUNCTION cbstr () AS CBSTR_
'      DECLARE FUNCTION bstr () AS AFX_BSTR
'      DECLARE FUNCTION LeftChars (BYVAL nChars AS LONG) AS DWSTR
'      DECLARE FUNCTION RightChars (BYVAL nChars AS LONG) AS DWSTR
'      DECLARE FUNCTION MidChars (BYVAL nStart AS LONG, BYVAL nChars AS LONG = 0) AS DWSTR
'      DECLARE FUNCTION ValLong () AS LONG
'      DECLARE FUNCTION ValInt () AS LONG
'      DECLARE FUNCTION ValULong () AS ULONG
'      DECLARE FUNCTION ValUInt () AS ULONG
'      DECLARE FUNCTION ValLongInt () AS LONGINT
'      DECLARE FUNCTION ValULongInt () AS ULONGINT
'      DECLARE FUNCTION ValDouble () AS DOUBLE
'      DECLARE FUNCTION Value () AS DOUBLE

END TYPE
' ########################################################################################

' ========================================================================================
' DWSTR constructors
' ========================================================================================
' ========================================================================================
' Attempts to allocate, or reserve, m_GrowSize number of bytes from the free store (heap).
' The newly allocated memory is initialized.
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR Default")
   this.ResizeBuffer(m_GrowSize, TRUE)   ' Create the initial buffer
   DWSTR_DP("END DWSTR CONSTRUCTOR Default - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
' Attempts to allocate, or reserve, nChars number of bytes from the free store (heap).
' bClear = FALSE: The newly allocated memory is not initialized.
' bClear = TRUE: The newly allocated memory is initialized.
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR (BYVAL nChars AS UINT, BYVAL bClear AS BOOLEAN)
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR nChars " & .WSTR(nChars))
   IF nChars = 0 THEN nChars = m_GrowSize \ 2
   this.ResizeBuffer(nChars * 2, bClear)   ' Create the initial buffer
   DWSTR_DP("-END- DWSTR CONSTRUCTOR nChars - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR (BYVAL pwszStr AS WSTRING PTR)
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR WSTRING - " & .WSTR(pwszStr))
   IF pwszStr = NULL THEN
      this.ResizeBuffer(m_GrowSize)   ' Create the initial buffer
   ELSE
      this.Add(pwszStr)               ' Add the passed WSTRING
   END IF
   DWSTR_DP("-END- DWSTR CONSTRUCTOR WSTRING - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR (BYREF ansiStr AS STRING, BYVAL nCodePage AS UINT = 0)
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR STRING - " & .WSTR(VARPTR(ansiStr)))
   IF .LEN(ansiStr) THEN
      this.Add(ansiStr, nCodePage)    ' Add the passed ansi string
   ELSE
      this.ResizeBuffer(m_GrowSize)   ' Create the initial buffer
   END IF
   DWSTR_DP("-END- DWSTR CONSTRUCTOR STRING - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR (BYREF cws AS DWSTR)
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR DWSTR")
   IF cws.m_BufferLen THEN
      this.Add(cws)                   ' Add the passed DWSTR
   ELSE
      this.ResizeBuffer(m_GrowSize)   ' Create the initial buffer
   END IF
   DWSTR_DP("-END- DWSTR CONSTRUCTOR DWSTR - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
'PRIVATE CONSTRUCTOR DWSTR (BYREF cbs AS CBStr_)
'   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR CBSTR")
'   this.ResizeBuffer(m_GrowSize)   ' Create the initial buffer
'   ' Copy the string into the buffer and update the length
'   this.AppendBuffer(cast(ANY PTR, cbs.m_bstr), SysStringLen(cbs) * 2)
'   DWSTR_DP("-END- DWSTR CONSTRUCTOR CBSTR - " & .WSTR(m_pBuffer))
'END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR (BYVAL n AS LONGINT)
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR LONGINT")
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
   DWSTR_DP("-END- DWSTR CONSTRUCTOR LONGINT - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================
' ========================================================================================
PRIVATE CONSTRUCTOR DWSTR (BYVAL n AS DOUBLE)
   DWSTR_DP("+++BEGIN- DWSTR CONSTRUCTOR DOUBLE")
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
   DWSTR_DP("-END- DWSTR CONSTRUCTOR DOUBLE - " & .WSTR(m_pBuffer))
END CONSTRUCTOR
' ========================================================================================

' ========================================================================================
' Destructor
' ========================================================================================
PRIVATE DESTRUCTOR DWSTR
   DWSTR_DP("***DWSTR DESTRUCTOR - buffer: " & .WSTR(m_pBuffer))
   IF m_pBuffer THEN Deallocate(m_pBuffer)
   m_pBuffer = NULL
END DESTRUCTOR
' ========================================================================================

' ========================================================================================
' Returns the address of the DWSTR buffer.
' Removed to allow to use @ to get the address of the class.
' ========================================================================================
'PRIVATE OPERATOR DWSTR.@ () AS WSTRING PTR
'   DWSTR_DP("DWSTR OPERATOR @ - buffer: " & .WSTR(m_pBuffer))
'   OPERATOR = cast(WSTRING PTR, m_pBuffer)
'END OPERATOR
' ========================================================================================
' ========================================================================================
'PRIVATE FUNCTION DWSTR.vptr () AS WSTRING PTR
'   DWSTR_DP("DWSTR vptr - buffer: " & .WSTR(m_pBuffer))
'   RETURN cast(WSTRING PTR, m_pBuffer)
'END FUNCTION
' ========================================================================================

' ========================================================================================
' One * returns the address of the DWSTR buffer.
' Two ** deferences the string data.
' Needed because LEFT and RIGHT (cws) fail with an ambiguous call error.
' We have to use **cws (notice the double indirection) with these functions.
' ========================================================================================
PRIVATE OPERATOR * (BYREF cws AS DWSTR) AS WSTRING PTR
   DWSTR_DP("DWSTR OPERATOR * buffer: " & .WSTR(cws.m_pBuffer))
   OPERATOR = cast(WSTRING PTR, cws.m_pBuffer)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Returns the address of the DWSTR buffer.
' ========================================================================================
'PRIVATE FUNCTION DWSTR.sptr () AS WSTRING PTR
'   DWSTR_DP("DWSTR sptr - buffer: " & .WSTR(m_pBuffer))
'   RETURN cast(WSTRING PTR, m_pBuffer)
'END FUNCTION
' ========================================================================================

' ========================================================================================
' Returns the length, in characters, of the DWSTR.
' ========================================================================================
'PRIVATE OPERATOR LEN (BYREF cws AS DWSTR) AS UINT
'   DWSTR_DP("DWSTR OPERATOR LEN - len: " & .WSTR(.LEN(**cws)))
'   OPERATOR = .LEN(**cws)
'END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR LEN (BYREF cws AS DWSTR) AS UINT
   DWSTR_DP("DWSTR OPERATOR LEN - len: " & .WSTR(cws.m_BufferLen \ 2))
   OPERATOR = cws.m_BufferLen \ 2
END OPERATOR
' ========================================================================================

' ========================================================================================
' Returns a pointer to the DWSTR buffer.
' ========================================================================================
PRIVATE OPERATOR DWSTR.CAST () AS ANY PTR
   DWSTR_DP("DWSTR CAST ANY PTR - buffer: " & .WSTR(m_pBuffer))
   OPERATOR = cast(ANY PTR, m_pBuffer)
END OPERATOR
' ========================================================================================
' ========================================================================================
' Returns the string data (same as **).
' ========================================================================================
PRIVATE OPERATOR DWSTR.CAST () BYREF AS CONST WSTRING
   DWSTR_DP("DWSTR CAST BYREF AS WSTRING - buffer: " & .WSTR(m_pBuffer))
   OPERATOR = *cast(WSTRING PTR, m_pBuffer)
END OPERATOR
' ========================================================================================
' ========================================================================================
' Returns the string data (same as **).
' ========================================================================================
'PRIVATE FUNCTION DWSTR.wstr () BYREF AS CONST WSTRING
'   DWSTR_DP("DWSTR wstr - buffer: " & .WSTR(m_pBuffer))
'   RETURN *cast(WSTRING PTR, m_pBuffer)
'END FUNCTION
' ========================================================================================

' ========================================================================================
' Assigns new text to the DWSTR.
' ========================================================================================
PRIVATE OPERATOR DWSTR.Let (BYREF wszStr AS CONST WSTRING)
   DWSTR_DP("DWSTR LET WSTRING")
   this.Clear
   this.Add(wszStr)
END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.Let (BYREF ansiStr AS STRING)
   DWSTR_DP("DWSTR LET STRING")
   this.Clear
   this.Add(ansiStr)
END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.Let (BYREF pwszStr AS WSTRING PTR)
   DWSTR_DP("DWSTR LET WSTRING PTR = " & .WSTR(pwszStr))
   this.Clear
   IF pwszStr = NULL THEN EXIT OPERATOR
   this.Add(*pwszStr)
END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.Let (BYREF cws AS DWSTR)
   DWSTR_DP("DWSTR LET DWSTR - m_pBuffer = " & .WSTR(m_pBuffer) & " - IN buffer = " & .WSTR(cws.m_pBuffer))
   IF m_pBuffer = cws.m_pBuffer THEN EXIT OPERATOR   ' // Ignore cws = cws
   this.Clear
   this.Add(cws)
END OPERATOR
' ========================================================================================
' ========================================================================================
'PRIVATE OPERATOR DWSTR.Let (BYREF cbs AS CBStr_)
'   DWSTR_DP("DWSTR LET CBSTR")
'   this.Clear
'   DIM AS LONG nLenString = SysStringLen(cbs)
'   this.ResizeBuffer(nLenString)
'   ' Copy the string into the buffer and update the length
'   this.AppendBuffer(cast(ANY PTR, cbs.m_bstr), nLenString * 2)
'END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.Let (BYVAL n AS LONGINT)
   DWSTR_DP("DWSTR OPERATOR Let LONGINT")
   this.Clear
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.Let (BYVAL n AS DOUBLE)
   DWSTR_DP("DWSTR OPERATOR Let DOUBLE")
   this.Clear
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
END OPERATOR
' ========================================================================================

' ========================================================================================
' ResizeBuffer
' Increases the size of the internal buffer capacity
' ========================================================================================
PRIVATE SUB DWSTR.ResizeBuffer (BYVAL nValue AS UINT, BYVAL bClear AS BOOLEAN = FALSE)
   DWSTR_DP("DWSTR ResizeBuffer - Value = " & .WSTR(nValue))
   ' // If it is an odd value, make it even.
   IF (nValue MOD 2) <> 0 THEN nValue += 1
   ' Increase the size of the existing buffer by creating a new buffer copying
   ' the existing data into it and then finally deleting the original buffer.
   ' // +2 to make room for the double null terminator.
   DIM pNewBuffer AS UBYTE PTR = IIF(bClear, CAllocate(nValue + 2), Allocate(nValue + 2))
   DWSTR_DP("DWSTR ResizeBuffer - pNewBuffer = " & .WSTR(pNewBuffer) & " - old buffer = " & (.WSTR(m_pBuffer)))
   IF m_pBuffer THEN
      IF nValue < m_BufferLen THEN m_BufferLen = nValue
'      memcpy(pNewBuffer, m_pBuffer, m_BufferLen)
      mcpy(pNewBuffer, m_pBuffer, m_BufferLen)
      Deallocate m_pBuffer
   END IF
   m_pBuffer = pNewBuffer
   m_Capacity = nValue
   ' Mark the end of the string with a double null
   m_pBuffer[m_BufferLen] = 0
   m_pBuffer[m_BufferLen + 1] = 0
END SUB
' ========================================================================================

' ========================================================================================
' Appends the specified number of bytes from the specified memory address to the end of the buffer.
' ========================================================================================
PRIVATE FUNCTION DWSTR.AppendBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nNumBytes AS UINT) AS BOOLEAN
   DWSTR_DP("DWSTR AppendBuffer " & .WSTR(m_BufferLen) & " " & .WSTR(nNumBytes))
'   IF (m_BufferLen + nNumBytes) > m_Capacity THEN this.ResizeBuffer(m_BufferLen + nNumBytes)
   ' // Add extra capacity to minimize multiple allocations when doing multiple concatenations
'   IF (m_BufferLen + nNumBytes) > m_Capacity THEN this.ResizeBuffer((m_BufferLen + nNumBytes) * 2)
   IF m_GrowSize < 0 THEN
      IF (m_BufferLen + nNumBytes) > m_Capacity THEN this.ResizeBuffer((m_BufferLen + nNumBytes) * 2)
   ELSE
      IF (m_BufferLen + nNumBytes) > m_Capacity THEN this.ResizeBuffer(m_BufferLen + nNumBytes + m_GrowSize)
   END IF
   IF m_pBuffer = NULL THEN RETURN FALSE
'   memcpy(m_pBuffer + m_BufferLen, addrMemory, nNumBytes)
   mcpy(m_pBuffer + m_BufferLen, addrMemory, nNumBytes)
   m_BufferLen += nNumBytes
   ' Mark the end of the string with a double null
   m_pBuffer[m_BufferLen] = 0
   m_pBuffer[m_BufferLen + 1] = 0
   RETURN TRUE
   DWSTR_DP("--END - DWSTR AppendBuffer " & .WSTR(m_BufferLen))
END FUNCTION
' ========================================================================================

' ========================================================================================
' The string parameter is appended to the string held in the class. If the internal string
' buffer overflows, the class will automatically extend it to an appropriate size.
' ========================================================================================
PRIVATE SUB DWSTR.Add (BYREF cws AS DWSTR)
   DWSTR_DP("DWSTR Add DWSTR - buffer = " & .WSTR(cws.m_pBuffer) & " - LEN = " & .WSTR(cws.m_BufferLen \ 2))
   ' Incoming string is already in wide format, simply copy it to the buffer.
   DIM nLenString AS UINT = cws.m_BufferLen   ' // Length in bytes
   IF nLenString = 0 THEN RETURN
   ' Copy the string into the buffer and update the length
   this.AppendBuffer(cast(ANY PTR, cws.m_pBuffer), nLenString)
END SUB
' ========================================================================================
' ========================================================================================
'PRIVATE SUB DWSTR.Add (BYREF cbs AS CBSTR_)
'   DWSTR_DP("DWSTR Add CBSTR")
'   ' Incoming string is already in wide format, simply copy it to the buffer.
'   DIM AS LONG nLenString = SysStringLen(cbs)
'   IF nLenString = 0 THEN RETURN
'   ' Copy the string into the buffer and update the length
'   this.AppendBuffer(cast(ANY PTR, cbs.m_bstr), nLenString * 2)
'END SUB
' ========================================================================================
' ========================================================================================
PRIVATE SUB DWSTR.Add (BYVAL pwszStr AS WSTRING PTR)
   DWSTR_DP("DWSTR Add WSTRING")
   IF pwszStr = NULL THEN RETURN
   ' Incoming string is already in wide format
   DIM nLenString AS UINT = .LEN(*pwszStr)   ' // Length in characters
   IF nLenString = 0 THEN RETURN
   ' Copy the string into the buffer and update the length
   this.AppendBuffer(cast(ANY PTR, pwszStr), nLenString * 2)
END SUB
' ========================================================================================
' ========================================================================================
PRIVATE SUB DWSTR.Add (BYREF ansiStr AS STRING, BYVAL nCodePage AS UINT = 0)
   DWSTR_DP("DWSTR Add STRING Code page = " & .WSTR (nCodePage))
   IF LEN(ansiStr) = 0 THEN RETURN
   ' Create the wide string from the incoming ansi string
   DIM dwLen AS UINT, pbuffer AS ANY PTR
   IF nCodePage = CP_UTF8 THEN
      dwLen = MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), NULL, 0)
      IF dwLen = 0 THEN RETURN
      dwLen *= 2
      pbuffer = Allocate(dwLen)
      MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), pbuffer, dwLen)
   ELSE
'      dwLen = .LEN(ansiStr)
      dwLen = MultiByteToWideChar(nCodePage, MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), NULL, 0)
      IF dwLen = 0 THEN RETURN
      dwLen *= 2
      pbuffer = Allocate(dwLen)
      MultiByteToWideChar(nCodePage, MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), pbuffer, dwLen)
   END IF
   IF pbuffer THEN
      ' Copy the string into the buffer and update the length
      this.AppendBuffer(pbuffer, dwLen)
      Deallocate(pbuffer)
   END IF
END SUB
' ========================================================================================

' ========================================================================================
' Appends a string to the DWSTR
' ========================================================================================
PRIVATE OPERATOR DWSTR.+= (BYREF wszStr AS WSTRING)
   DWSTR_DP("DWSTR OPERATOR += WSTRING")
   this.Add(wszStr)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a string to the DWSTR
' ========================================================================================
PRIVATE OPERATOR DWSTR.+= (BYREF ansiStr AS STRING)
   DWSTR_DP("DWSTR OPERATOR += STRING")
   this.Add(ansiStr)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a DWSTR to the DWSTR
' ========================================================================================
PRIVATE OPERATOR DWSTR.+= (BYREF cws AS DWSTR)
   DWSTR_DP("DWSTR OPERATOR += DWSTR")
   this.Add(cws)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a CBSTR to the DWSTR.
' ========================================================================================
'PRIVATE OPERATOR DWSTR.+= (BYREF cbs AS CBStr_)
'   DWSTR_DP("DWSTR OPERATOR += CBSTR")
'   this.Add(cbs)
'END OPERATOR
' ========================================================================================

' ========================================================================================
PRIVATE OPERATOR DWSTR.+= (BYVAL n AS LONGINT)
   DWSTR_DP("DWSTR OPERATOR += LONGINT")
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.+= (BYVAL n AS DOUBLE)
   DWSTR_DP("DWSTR OPERATOR += DOUBLE")
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a WSTRING to the DWSTR
' ========================================================================================
PRIVATE OPERATOR DWSTR.&= (BYREF wszStr AS WSTRING)
   DWSTR_DP("DWSTR OPERATOR &= WSTRING")
   this.Add(wszStr)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a string to the DWSTR
' ========================================================================================
PRIVATE OPERATOR DWSTR.&= (BYREF ansiStr AS STRING)
   DWSTR_DP("DWSTR OPERATOR &= STRING")
   this.Add(ansiStr)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a DWSTR to the DWSTR
' ========================================================================================
PRIVATE OPERATOR DWSTR.&= (BYREF cws AS DWSTR)
   DWSTR_DP("DWSTR OPERATOR &= DWSTR")
   this.Add(cws)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Appends a CBSTR to the DWSTR.
' ========================================================================================
'PRIVATE OPERATOR DWSTR.&= (BYREF cbs AS CBStr_)
'   DWSTR_DP("DWSTR OPERATOR &= CBSTR")
'   this.Add(cbs)
'END OPERATOR
' ========================================================================================

' ========================================================================================
PRIVATE OPERATOR DWSTR.&= (BYVAL n AS LONGINT)
   DWSTR_DP("DWSTR OPERATOR &= LONGINT")
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
END OPERATOR
' ========================================================================================
' ========================================================================================
PRIVATE OPERATOR DWSTR.&= (BYVAL n AS DOUBLE)
   DWSTR_DP("DWSTR OPERATOR &= DOUBLE")
   DIM wsz AS WSTRING * 260 = .WSTR(n)
   this.Add(wsz)
END OPERATOR
' ========================================================================================

' ========================================================================================
' Number of characters to preallocate to minimize multiple allocations when doing multiple
' concatenations. A value of less than 0 indicates that it must double the capacity each
' time that the buffer needs to be resized.
' ========================================================================================
'PRIVATE PROPERTY DWSTR.GrowSize() AS LONG
'   DWSTR_DP("DWSTR PROPERTY GET GrowSize")
'   IF m_GrowSize > -1 THEN PROPERTY = m_GrowSize \ 2 ELSE PROPERTY = m_GrowSize
'END PROPERTY
'' ========================================================================================
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.GrowSize (BYVAL nChars AS LONG)
'   DWSTR_DP("DWSTR PROPERTY SET Growsize")
'   IF nChars > -1 THEN m_GrowSize = nChars * 2 ELSE m_GrowSize = -1
'END PROPERTY
'' ========================================================================================
'
'' ========================================================================================
'' The size of the internal string buffer is retrieved and returned to the caller. The size
'' is the number of bytes which can be stored without further expansion.
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.Capacity() AS UINT
'   DWSTR_DP("DWSTR PROPERTY GET Capacity")
'   PROPERTY = m_Capacity
'END PROPERTY
'' ========================================================================================
'' ========================================================================================
'' The internal string buffer is expanded to the specified number of bytes. If the new
'' capacity is smaller or equal to the current capacity, no operation is performed. If it is
'' smaller, the buffer is shortened and the contents that exceed the new capacity are lost.
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.Capacity (BYVAL nValue AS UINT)
'   DWSTR_DP("DWSTR PROPERTY SET Capacity")
'   ' // If the new capacity is the same that the current capacity, do nothing.
'   IF nValue = m_Capacity THEN EXIT PROPERTY
'   ' // Make sure that the number is odd (ResizeBuffer already does it)
''   IF (nValue MOD 2) <> 0 THEN nValue += 1
'   this.ResizeBuffer(nValue)
'END PROPERTY
'' ========================================================================================
'' ========================================================================================
'' The internal string buffer is expanded to the specified number of byyes.
'' Sets the capacity of the buffer in characters. If the new capacity is equal to the
'' current capacity, no operation is performed. If it is smaller, the buffer is shortened
'' and the contents that exceed the new capacity are lost.
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.SizeAlloc (BYVAL nChars AS UINT)
'   DWSTR_DP("DWSTR PROPERTY SET SizeAlloc")
'   ' // If the new capacity is the same that the current capacity, do nothing.
'   IF nChars = m_Capacity \ 2 THEN EXIT PROPERTY
'   this.ResizeBuffer(nChars * 2)
'END PROPERTY
'' ========================================================================================
'' ========================================================================================
'' Returns the capacity of the buffer in characters.
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.SizeOf() AS UINT
'   DWSTR_DP("DWSTR PROPERTY GET SizeOf")
'   PROPERTY = m_Capacity \ 2
'END PROPERTY
' ========================================================================================

' ========================================================================================
' Returns the corresponding unicode integer representation of the character at the position
' specified by the nIndex parameter (1 for the first character, 2 for the second, etc.).
' If nIndex is beyond the current length of the string, a 0 is returned.
' ========================================================================================
'PRIVATE PROPERTY DWSTR.Char (BYVAL nIndex AS UINT) AS USHORT
'   DWSTR_DP("DWSTR PROPERTY GET Char")
'   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN EXIT PROPERTY
'   ' Get the numeric character code at position nIndex
'   nIndex -= 1
'   PROPERTY = PEEK(USHORT, m_pBuffer + (nIndex * 2))
'END PROPERTY
'' ========================================================================================
'' ========================================================================================
'' Changes the corresponding unicode integer representation of the character at the position
'' specified by the nIndex parameter (1 for the first character, 2 for the second, etc.).
'' If nIndex is beyond the current length of the string, nothing is changed.
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.Char (BYVAL nIndex AS UINT, BYVAL nValue AS USHORT)
'   DWSTR_DP("DWSTR PROPERTY SET Char")
'   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN EXIT PROPERTY
'   ' Set the numeric character code at position nIndex (zero based)
'   nIndex -= 1
'   POKE USHORT, m_pBuffer + (nIndex * 2), nValue
'END PROPERTY
' ========================================================================================
' ========================================================================================
' Returns the corresponding ASCII or Unicode integer representation of the character at
' the zero-based position specified by the nIndex parameter (0 for the first character,
' 1 for the second, etc.), e.g. value = cws[1]. Can't be used to change a value.
' ========================================================================================
PRIVATE OPERATOR DWSTR.[] (BYVAL nIndex AS UINT) AS USHORT
   IF nIndex < 0 OR nIndex > (m_BufferLen \ 2) - 1 THEN EXIT OPERATOR
   ' Get the numeric character code at position nIndex
   OPERATOR = PEEK(USHORT, m_pBuffer + (nIndex * 2))
END OPERATOR
' ========================================================================================

' ========================================================================================
' All data in the class object is erased. Actually, we only set the buffer length to zero,
' indicating no string in the buffer. The allocated memory for the buffer is deallocated
' when the class is destroyed.
' ========================================================================================
PRIVATE SUB DWSTR.Clear
   DWSTR_DP("DWSTR Clear")
   m_BufferLen = 0
   ' Mark the end of the string with a double null
   m_pBuffer[m_BufferLen] = 0
   m_pBuffer[m_BufferLen + 1] = 0
END SUB
' ========================================================================================

' ========================================================================================
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
' ========================================================================================
PRIVATE SUB DWSTR.Resize (BYVAL nSize AS UINT, BYREF ch AS WSTRING = "")
   DWSTR_DP("DWSTR Resize")
   IF m_BufferLen \ 2 = nSize THEN EXIT SUB
   IF m_BufferLen \ 2 > nSize THEN
      m_BufferLen = nSize * 2
      m_Capacity = nSize * 2
      m_pBuffer[m_BufferLen] = 0
      m_pBuffer[m_BufferLen + 1] = 0
   ELSE
      IF LEN(ch) > 1 THEN ch = LEFT(ch, 1)
      DIM nChars AS UINT = ((nSize * 2) - m_BufferLen) \ 2
      DIM cws AS DWSTR = SPACE(nChars)
      IF ch <> "" THEN
         FOR i AS LONG = 1 TO nChars
            MID(**cws, i, 1) = ch
         NEXT
      END IF
      this.Add(cws)
   END IF
END SUB
' ========================================================================================

' ========================================================================================
' nCount characters are removed starting at the position given by nIndex.
' nIndex = 1 for the first character, 2 for the second, etc.
' Return value: If the function succeeds, it returns TRUE; otherwise, FALSE.
' Remarks: If nCount is bigger that the number of characters available to delete, the
' function deletes all the characters from nIndex to the end of the string.
' ========================================================================================
'PRIVATE FUNCTION DWSTR.DelChars (BYVAL nIndex AS UINT, BYVAL nCount AS UINT) AS BOOLEAN
'   DWSTR_DP("DWSTR DelChars")
'   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 OR nCount < 1 THEN RETURN FALSE
'   DIM numChars AS UINT = m_BufferLen \ 2
'   IF nCount > numChars - nIndex + 1 THEN nCount = numChars - nIndex + 1
'   DIM nOffset AS UINT = (nIndex - 1 + nCount) * 2
''   memcpy(m_pBuffer + (nOffset - nCount * 2), m_pBuffer + nOffset, m_BufferLen - (nCount * 2))
''   memcpy(m_pBuffer + (nOffset - nCount * 2), m_pBuffer + nOffset, m_BufferLen - nOffset)
'   mcpy(m_pBuffer + (nOffset - nCount * 2), m_pBuffer + nOffset, m_BufferLen - nOffset)
'   m_BufferLen -= (nCount * 2)
'   ' Mark the end of the string with a double null
'   m_pBuffer[m_BufferLen] = 0
'   m_pBuffer[m_BufferLen + 1] = 0
'   RETURN TRUE
'END FUNCTION
' ========================================================================================

' ========================================================================================
' Inserts the specified number of bytes from the specified memory address into the buffer.
' ========================================================================================
PRIVATE FUNCTION DWSTR.InsertBuffer (BYVAL addrMemory AS ANY PTR, BYVAL nIndex AS UINT, BYVAL nNumBytes AS UINT) AS BOOLEAN
   DWSTR_DP("DWSTR InsertBuffer")
   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN RETURN FALSE
   ' Determine the size of the new buffer
   IF m_BufferLen + nNumBytes > m_Capacity THEN m_Capacity = m_BufferLen + nNumBytes
   DIM pNewBuffer AS UBYTE PTR = Allocate((m_Capacity + 1) * 2)
   IF m_pBuffer THEN
      nIndex -= 1
      ' Copy the existing data into the new buffer
'      memcpy(pNewBuffer, m_pBuffer, nIndex * 2)
      mcpy(pNewBuffer, m_pBuffer, nIndex * 2)
      DIM nOffset AS UINT = nIndex * 2
'      memcpy(pNewBuffer + nOffset, addrMemory, nNumBytes)
      mcpy(pNewBuffer + nOffset, addrMemory, nNumBytes)
      nOffset += nNumBytes
'      memcpy(pNewBuffer + nOffset, m_pBuffer + (nIndex * 2), m_BufferLen - (nIndex * 2))
      mcpy(pNewBuffer + nOffset, m_pBuffer + (nIndex * 2), m_BufferLen - (nIndex * 2))
      Deallocate m_pBuffer
   END IF
   m_pBuffer = pNewBuffer
   m_BufferLen += nNumBytes
   ' Mark the end of the string with a double null
   m_pBuffer[m_BufferLen] = 0
   m_pBuffer[m_BufferLen + 1] = 0
   RETURN TRUE
END FUNCTION
' ========================================================================================

' ========================================================================================
' The incoming string parameter is inserted in the string starting at the position
' given by nIndex. nIndex = 1 for the first character, 2 For the second, etc.
' If nIndex is beyond the current length of the string + 1, no operation is performed.
' ========================================================================================
'PRIVATE FUNCTION DWSTR.Insert (BYREF cws AS DWSTR, BYVAL nIndex AS UINT) AS BOOLEAN
'   DWSTR_DP("DWSTR Insert DWSTR")
'   IF (nIndex < 1) OR nIndex > m_BufferLen \ 2 THEN RETURN FALSE
'   IF cws.m_BufferLen = 0 THEN RETURN FALSE
'   RETURN this.InsertBuffer(cast(ANY PTR,cws.m_pBuffer), nIndex, cws.m_BufferLen)
'END FUNCTION
' ========================================================================================
' ========================================================================================
'PRIVATE FUNCTION DWSTR.Insert (BYREF cbs AS CBSTR_, BYVAL nIndex AS LONG) AS BOOLEAN
'   DWSTR_DP("DWSTR Insert CBSTR")
'   IF (nIndex < 1) OR nIndex > m_BufferLen \ 2 THEN RETURN 0
'   DIM AS LONG nLenString = SysStringLen(cbs)
'   IF nLenString = 0 THEN RETURN 0
'   RETURN this.InsertBuffer(cast(ANY PTR, cbs.m_bstr), nIndex, nLenString * 2)
'END FUNCTION
' ========================================================================================
' ========================================================================================
'PRIVATE FUNCTION DWSTR.Insert (BYVAL pwszStr AS WSTRING PTR, BYVAL nIndex AS UINT) AS BOOLEAN
'   DWSTR_DP("DWSTR Insert WSTRING")
'   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 THEN RETURN FALSE
'   DIM nLenString AS UINT = .LEN(*pwszStr)
'   IF nLenString = 0 THEN RETURN FALSE
'   RETURN this.InsertBuffer(cast(ANY PTR, pwszStr), nIndex, nLenString * 2)
'END FUNCTION
'' ========================================================================================
'' ========================================================================================
'PRIVATE FUNCTION DWSTR.Insert (BYREF ansiStr AS STRING, BYVAL nIndex AS UINT, BYVAL nCodePage AS UINT = 0) AS BOOLEAN
'   DWSTR_DP("DWSTR Insert STRING")
'   IF nIndex < 1 OR nIndex > m_BufferLen \ 2 OR .LEN(ansiStr) = 0 THEN RETURN FALSE
'   ' Create the wide string from the incoming ansi string
'   DIM dwLen AS UINT, pbuffer AS ANY PTR
'   IF nCodePage = CP_UTF8 THEN
'      dwLen = MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), NULL, 0)
'      IF dwLen = 0 THEN RETURN FALSE
'      dwLen *= 2
'      pbuffer = Allocate(dwLen)
'      MultiByteToWideChar(CP_UTF8, 0, STRPTR(ansiStr), LEN(ansiStr), pbuffer, dwLen)
'   ELSE
''      dwLen = .LEN(ansiStr)
'      dwLen = MultiByteToWideChar(nCodePage, MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), NULL, 0)
'      IF dwLen = 0 THEN RETURN FALSE
'      dwLen *= 2
'      pbuffer = Allocate(dwLen)
'      MultiByteToWideChar(nCodePage, MB_PRECOMPOSED, STRPTR(ansiStr), .LEN(ansiStr), pbuffer, dwLen)
'   END IF
'   ' Copy the string into the buffer and update the length
'   FUNCTION = this.InsertBuffer(pbuffer, nIndex, dwLen)
'   Deallocate(pbuffer)
'END FUNCTION
' ========================================================================================

' ========================================================================================
' Converts the DWSTR to UTF8.
' ========================================================================================
'PRIVATE PROPERTY DWSTR.Utf8 () AS STRING
'   DWSTR_DP("DWSTR Utf8 GET PROPERTY")
'   DIM cbLen AS INTEGER
'   IF m_BufferLen = 0 THEN RETURN ""
'   DIM buffer AS STRING = STRING(m_BufferLen * 5 + 1, 0)
'   PROPERTY = *cast(ZSTRING PTR, WCharToUTF(1, cast(WSTRING PTR, m_pBuffer), m_BufferLen, STRPTR(buffer), @cbLen))
'END PROPERTY
'' ========================================================================================
'
'' ========================================================================================
'' Converts UTF8 to unicode and assigns it to the DWSTR.
'' ========================================================================================
'PRIVATE PROPERTY DWSTR.Utf8 (BYREF utf8String AS STRING)
'   DWSTR_DP("DWSTR Utf8 SET PROPERTY")
'   this.Clear
'   this.Add(utf8String, CP_UTF8)
'END PROPERTY
' ========================================================================================

' ========================================================================================
' Returns the leftmost substring of the string.
' ========================================================================================
'PRIVATE FUNCTION DWSTR.LeftChars (BYVAL nChars AS LONG) AS DWSTR
'   DWSTR_DP("DWSTR LeftChars - buffer: " & .WSTR(m_pBuffer))
'   RETURN LEFT(*cast(WSTRING PTR, m_pBuffer), nChars)
'END FUNCTION
'' ========================================================================================
'
'' ========================================================================================
'' Returns the rightmost substring of the string.
'' ========================================================================================
'PRIVATE FUNCTION DWSTR.RightChars (BYVAL nChars AS LONG) AS DWSTR
'   DWSTR_DP("DWSTR RightChars - buffer: " & .WSTR(m_pBuffer))
'   RETURN RIGHT(*cast(WSTRING PTR, m_pBuffer), nChars)
'END FUNCTION
'' ========================================================================================
'
'' ========================================================================================
'' Returns a substring of the string.
'' ========================================================================================
'PRIVATE FUNCTION DWSTR.MidChars (BYVAL nStart AS LONG, BYVAL nChars AS LONG = 0) AS DWSTR
'   DWSTR_DP("DWSTR MidChars - buffer: " & .WSTR(m_pBuffer))
'   IF nChars = 0 THEN RETURN MID(*cast(WSTRING PTR, m_pBuffer), nStart)
'   RETURN MID(*cast(WSTRING PTR, m_pBuffer), nStart, nChars)
'END FUNCTION
' ========================================================================================

' =====================================================================================
' Converts the string to a 32bit integer
' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValLong () AS LONG
'   RETURN .ValInt(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValInt () AS LONG
'   RETURN .ValInt(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to an unsigned 32bit integer
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValULong () AS ULONG
'   RETURN .ValUInt(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValUInt () AS ULONG
'   RETURN .ValUInt(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to a 64bit integer
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValLongInt () AS LONGINT
'   RETURN .ValLng(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to an unsigned 64bit integer
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValULongInt () AS ULONGINT
'   RETURN .ValULng(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to a floating point number (DOUBLE)
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.ValDouble () AS DOUBLE
'   RETURN .VAL(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
'' =====================================================================================
'' =====================================================================================
'PRIVATE FUNCTION DWSTR.Value () AS DOUBLE
'   RETURN .VAL(*cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
' =====================================================================================

' =====================================================================================
' Returns the contents of the DWSTR as a CBSTR.
' Useful to pass a DWSTR to a function that expects a BYVAL IN BSTR parameter.
' =====================================================================================
'PRIVATE FUNCTION DWSTR.cbstr () AS CBStr_
'   RETURN SysAllocString(cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
' =====================================================================================

' =====================================================================================
' Returns the contents of the DWSTR as a BSTR.
' =====================================================================================
'PRIVATE FUNCTION DWSTR.bstr () AS AFX_BSTR
'   RETURN SysAllocString(cast(WSTRING PTR, m_pBuffer))
'END FUNCTION
' =====================================================================================

' =====================================================================================
' Returns the contents of the DWSTR as a WSTRING allocated with CoTaskMemAlloc.
' Free the returned string later with CoTaskMemFree.
' Note: This is useful when we need to pass a pointer to a null terminated wide string to a
' function or method that will release it. If we pass a WSTRING it will GPF.
' If the length of the input string is 0, CoTaskMemAlloc allocates a zero-length item and
' returns a valid pointer to that item. If there is insufficient memory available,
' CoTaskMemAlloc returns NULL.
' =====================================================================================
'PRIVATE FUNCTION DWSTR.wchar () AS WSTRING PTR
'   DIM pwchar AS WSTRING PTR
'   pwchar = CoTaskMemAlloc((m_BufferLen + 1) * 2)
'   IF pwchar = NULL THEN RETURN NULL
'   IF m_BufferLen THEN memcpy pwchar, m_pBuffer, m_BufferLen
'   IF m_BufferLen = 0 THEN *pwchar = CHR(0)
'   RETURN pwchar
'END FUNCTION
' =====================================================================================


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

'PRIVATE OPERATOR & (BYREF cws1 AS JK.DWSTR, BYREF cws2 as const wstring) AS JK.DWSTR
''PRIVATE OPERATOR & (BYREF cws1 AS JK.DWSTR, BYREF cws2 as wstring) AS JK.DWSTR
'DIM cwsRes AS JK.DWSTR = cws1
'  cwsRes.Add(cws2)
'  OPERATOR = cwsRes
'END OPERATOR


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
' José
'***********************************************************************************************
' =====================================================================================
' Converts the string to a 32bit integer
' =====================================================================================
'PRIVATE FUNCTION ValLng OVERLOAD (BYREF cws AS DWSTR) AS LONG
'   RETURN .ValLng(*cast(WSTRING PTR, cws.m_pBuffer))
'END FUNCTION
'' =====================================================================================
'' =====================================================================================
'PRIVATE FUNCTION ValInt OVERLOAD (BYREF cws AS DWSTR) AS LONG
'   RETURN .ValInt(*cast(WSTRING PTR, cws.m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to an unsigned 32bit integer
'' =====================================================================================
'PRIVATE FUNCTION ValULng OVERLOAD (BYREF cws AS DWSTR) AS ULONG
'   RETURN .ValULng(*cast(WSTRING PTR, cws.m_pBuffer))
'END FUNCTION
'' =====================================================================================
'PRIVATE FUNCTION ValUInt OVERLOAD (BYREF cws AS DWSTR) AS ULONG
'   RETURN .ValUInt(*cast(WSTRING PTR, cws.m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to a 64bit integer
'' =====================================================================================
'PRIVATE FUNCTION ValLongInt OVERLOAD (BYREF cws AS DWSTR) AS LONGINT
'   RETURN .ValLng(*cast(WSTRING PTR, cws.m_pBuffer))
'END FUNCTION
'' =====================================================================================
'
'' =====================================================================================
'' Converts the string to an unsigned 64bit integer
'' =====================================================================================
'PRIVATE FUNCTION ValULongInt OVERLOAD (BYREF cws AS DWSTR) AS ULONGINT
'   RETURN .ValULng(*cast(WSTRING PTR, cws.m_pBuffer))
'END FUNCTION
'' =====================================================================================

'***********************************************************************************************
'***********************************************************************************************
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
' File: AfxStr.inc
' Contents: String wrapper functions.
' Compiler: FreeBasic 32 & 64-bit, Unicode.
' Copyright (c) 2016 Paul Squires and José Roca. Freeware. Use at your own risk.
' THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
' EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
' MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
' ########################################################################################


'***********************************************************************************************
'***********************************************************************************************
' string helper functions (work for ZSTRING, WSTRING, STRING, USTRING, DWSTR and CBstr)
'***********************************************************************************************
'***********************************************************************************************


'***********************************************************************************************
'***********************************************************************************************
' 1.) wrappers for left/right/mid in order to enable a consistent syntax ($ suffix)
'***********************************************************************************************
'***********************************************************************************************


PRIVATE FUNCTION Left_ (BYREF w AS WSTRING, BYVAL n AS ULONG) AS ustring
'***********************************************************************************************
' return the n leftmost chars of w 
'***********************************************************************************************


  return left(w, n)
  
  
end function  


'***********************************************************************************************


PRIVATE FUNCTION right_ (BYREF w AS WSTRING, BYVAL n AS ULONG) AS ustring
'***********************************************************************************************
' return the n rightmost chars of w 
'***********************************************************************************************


  return right(w, n)
  
  
end function  


'***********************************************************************************************


PRIVATE FUNCTION mid_ (BYREF w AS WSTRING, BYVAL i AS ULONG, n AS ULONG = 0) AS ustring
'***********************************************************************************************
' return n chars of w, starting at i (one based)
'***********************************************************************************************


  if n = 0 then
    return mid(w, i)
  else
    return mid(w, i, n)
  end if
  
  
end function  


'***********************************************************************************************
'***********************************************************************************************
' 2.) new functions for string manipulation
'***********************************************************************************************
'***********************************************************************************************

'***********************************************************************************************
' UTF8 is a unicode encoding, which allows for zero terminated strings just as with ansi  
' encoding. Therefore it is widely implemented in places, where you don´t want to or cannot 
' make use of wide string types but nevertheless want to or must make use of unicode.

' The following two function are specialized functions for this conversion. Although you may 
' pass any type of string (USTRING, WSTRING, STRING or ZSTRING) to these function and store
' the return into any type of string as well, obviously not every combination makes sense.
' E.g. converting an UTF8 encode STRING into a ZTRING will lead to data loss, because a 
' ZSTRING cannot hold unicode data. 

' Typically you would use these function to create an ' UTF8 encoded STRING or ZSTRING from 
' any other string data type. This UTF8 encoded string can be converted to a wide string type 
' without any data loss, converting it to an ansi string will make all unicode characters not 
' present in the current codepage appear as "?" or similar.
'***********************************************************************************************


PRIVATE FUNCTION CHRTOUTF8_ overload (BYref u AS USTRING) AS STRING
'***********************************************************************************************
' convert a unicode string into an UTF8 encoded string, this is a lossless conversion
'***********************************************************************************************
DIM dwLen AS DWORD = pp__jk_wctm(pp__jk_CP_UTF8, 0, *u, LEN(u), NULL, 0, NULL, NULL)


  IF dwLen THEN
    DIM ansiStr AS STRING = SPACE(dwLen)
    dwLen = pp__jk_wctm(pp__jk_CP_UTF8, 0, *u, LEN(u), STRPTR(ansiStr), LEN(ansiStr), NULL, NULL)
    IF dwLen THEN RETURN ansiStr
  END IF


  return ""


end function


'***********************************************************************************************


PRIVATE FUNCTION UTF8TOCHR_ overload (BYREF ansiStr AS CONST STRING) AS ustring
'***********************************************************************************************
' convert an UTF8 encoded string into an unicode string, this is a lossless conversion as long
' as the receiving string type is a wide string (USTRING or WSTRING), if the receiving string
' is an ansi string (STRING or ZSTRING) unicode characters "outside" the current codepage are
' converted to "?" or similar.
'***********************************************************************************************
DIM dwLen AS DWORD = pp__jk_mtwc(CP_UTF8, 0, cptr(zstring ptr, STRPTR(ansiStr)), LEN(ansiStr), NULL, 0)


  IF dwLen THEN
     DIM u AS ustring = SPACE(dwLen)
     dwLen = pp__jk_mtwc(pp__jk_CP_UTF8, 0, cptr(zstring ptr, STRPTR(ansiStr)), LEN(ansiStr), *u, dwLen)
     IF dwLen THEN RETURN u
  END IF


  return ""


end function


'***********************************************************************************************
' Translates ansi bytes to unicode bytes. You need this function for conversions with a different
' codepage than the system default, which is used in automatic (implicit) conversions
' Parameters:
' - ansiStr   = an ansi string (STRING or ZSTRING).
' - nCodePage = The code page used in the conversion, e.g. 1251 for Russian.
'   If you don't pass an unicode page, the function will use CP_ACP (0), which is the
'   system default Windows ANSI code page.
' Return value: the converted string as a USTRING

' if you pass a negative value for nCodePage, no conversion takes place, the data is just
' copied. This is necessary to avoid automatic conversion when passing wide data in a 
' STRING to an unicode string.
'***********************************************************************************************


PRIVATE FUNCTION Ucode_ (BYREF ansiStr AS CONST STRING, BYVAL nCodePage AS LONG = 0) AS ustring
'***********************************************************************************************
' convert string to ustring using ncodepage, default is CP_ACP (0 = default Windows ANSI code page) 
'***********************************************************************************************
DIM u     AS ustring
DIM dwLen AS DWORD  


  if len(ansiStr) = 0 then return ""                  'nothing to do


  if nCodePage < 0 then                               'just pass data
    dwLen = LEN(ansiStr)
    u = SPACE(dwLen)
    mcpy(*u, cptr(any ptr, strptr(ansiStr)), dwLen)
    
  else                                                'ansi to unicode conversion
    u     = SPACE(LEN(ansiStr))
    dwLen = pp__jk_mtwc(nCodePage, pp__jk_MB_PRECOMPOSED, cptr(zstring ptr, STRPTR(ansiStr)), LEN(ansiStr), *u, LEN(ansiStr) * 2)
  end if


  IF dwLen THEN RETURN u
  RETURN ""


END FUNCTION


'***********************************************************************************************
' Translates unicode to ansi bytes. You need this function for conversions with a different
' codepage than the system default, which is used in automatic (implicit) conversions
' Parameters:
' - w         = an Unicode string (WSTRING, USTRING, DWSTR or CBstr)
' - nCodePage = The code page used in the conversion, e.g. 1251 for Russian.
'   If you don't pass an unicode page, the function will use CP_ACP (0), which is the
'   system default Windows ANSI code page.
' Return value: the converted string as a USTRING

' if you pass a negative value for nCodePage, no conversion takes place, the data is just
' copied. This is necessary to avoid automatic conversion when passing wide data in a 
' wide string to a STRING data type.
'***********************************************************************************************


PRIVATE FUNCTION Acode_ (BYref w AS USTRING, BYVAL nCodePage AS LONG = 0) AS STRING
'***********************************************************************************************
' convert ustring to string using nCodePage, if < 0 pass data without conversion
'***********************************************************************************************
DIM ansiStr AS STRING 
DIM dwLen   AS DWORD  


  if len(w) = 0 then return ""                        'nothing to do


  if nCodePage < 0 then                               'just pass data
    dwLen = LEN(w) * 2
    ansiStr = SPACE(dwLen)
    mcpy(cptr(any ptr, strptr(ansiStr)), cptr(any ptr, *w), dwLen)
    
  else                                                'unicode to ansi conversion
    ansiStr = SPACE(LEN(w))
    dwLen   = pp__jk_wctm(nCodePage, 0, *w, LEN(w), STRPTR(ansiStr), LEN(ansiStr), NULL, NULL)
  end if


  IF dwLen THEN RETURN ansiStr
  RETURN ""


END FUNCTION


'***********************************************************************************************
' Inserts a string at a specified position within another string expression.
' Returns a string consisting of w with the string i inserted at position n. 
' If is greater than the length of w or <= zero then  i is appended to w. 
' The first character in the string is position 1

' Syntax: Insert_(string to insert in. string to insert, position)
'***********************************************************************************************


PRIVATE FUNCTION Insert_ (BYREF w AS WSTRING, BYREF i AS WSTRING, BYVAL n AS LONG) AS ustring
'***********************************************************************************************
' return w with i inserted at position n
'***********************************************************************************************
DIM u AS ustring = w


  IF n <= 0 THEN RETURN u                             'nothing to do

  IF n > LEN(w) THEN                                  'just append
    u += i

  ELSEIF n = 1 THEN                                   'prepend
    u = i + MID(w, 1)

  ELSE                                                'insert
    u = MID(w, 1, n - 1) + i + MID(w, n)
  END IF


  RETURN u


END FUNCTION


'***********************************************************************************************
' Within w replace all occurrences of one string with another string or all occurrences of 
' any of the individual characters specified in the m string with r
' The replacement can cause w to grow or condense in size. When a match is found, the 
' scan for the next match begins at the position immediately following the prior match.
' r can be a single character or a word. This function can be made case insensitive.
' The default is case sensitive and no "ANY" -> m is handled "as string"

' Syntax: Replace_(string to replace in, [any$,] char(s) to be replaced, replacement string [, case in/sensitive])
'***********************************************************************************************


PRIVATE FUNCTION Replace_ OVERLOAD (BYREF w AS WSTRING, byval anyflag as long = 0, BYREF m AS WSTRING, _
                                    BYREF r AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' return a string (originally w) and replace m by r, any -> chars in m individually, as string otherwise
' iflag -> make it case insensitive
'***********************************************************************************************
DIM u AS ustring = w
DIM lr AS LONG = LEN(r)
DIM lm AS LONG = LEN(m)
DIM nPos AS LONG = 1
DIM wu AS USTRING
DIM mu AS wstring ptr


  if lm = 0 then return u
  if len(w) = 0 then return ""


  if anyflag = 0 then
    if iflag = 0 then
      DO
        nPos = INSTR(nPos, u, m)
        IF nPos = 0 THEN EXIT DO

        u = MID(u, 1, nPos - 1) + r + MID(u, nPos + lm)    'replace m with r (as string, case sensitive)

        nPos += lr
      LOOP

    else
      mu = allocate(len(m) * 2 + 4) 

      wu = ucase(w)
      *mu = ucase(m)

      DO
        nPos = INSTR(npos, wu, *mu)
        IF nPos = 0 THEN EXIT DO

        wu = MID(wu, 1, nPos - 1) + r + MID(wu, nPos + lm) 'must do this in parallel to the original
        u = MID(u, 1, nPos - 1) + r + MID(u, nPos + lm)    'replace m with r (as string, case insensitive)

        nPos += lr
      LOOP

      deallocate mu
    end if

  else
    if iflag = 0 then
      DO
        nPos = INSTR(nPos, u, any m)
        IF nPos = 0 THEN EXIT DO
        u = MID(u, 1, nPos - 1) + r + MID(u, nPos + 1)     'replace any char of m in w individually with r as string

        nPos += lr
      LOOP

    else
      mu = allocate(len(m) * 2 + 4) 

      wu = ucase(w)
      *mu = ucase(m)

      DO
        nPos = INSTR(npos, wu, any *mu)
        IF nPos = 0 THEN EXIT DO

        wu = MID(wu, 1, nPos - 1) + r + MID(wu, nPos + 1)  'must do this in parallel to the original
        u = MID(u, 1, nPos - 1) + r + MID(u, nPos + 1)     'replace any char of m in w individually with r as string

        nPos += lr
      LOOP

      deallocate mu
    end if
  end if  


  RETURN u


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION Replace_ OVERLOAD (BYREF w AS WSTRING, BYREF m AS WSTRING, _
                                    BYREF r AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no any
'***********************************************************************************************


  function = Replace_(w, 0, m, r, iflag)


end function


PRIVATE FUNCTION Replace_ OVERLOAD (BYREF w AS uSTRING, BYREF m AS uSTRING, _
                                    BYREF r AS uSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no any
'***********************************************************************************************


  function = Replace_(w, 0, m, r, iflag)


end function


'***********************************************************************************************
' Reverses the contents of a string expression.

' Syntax: Reverse_("xyz")
'***********************************************************************************************


PRIVATE FUNCTION StrReverse_ overload (BYREF w AS WSTRING) AS ustring
'***********************************************************************************************
' reverse char order in w
'***********************************************************************************************
dim i        as Ulong
DIM r        AS ustring
DIM wszChar  AS WSTRING * 2
DIM wszChar2 AS WSTRING * 2
DIM nLen     AS LONG = LEN(w)


  r = wspace(nlen)

  FOR i = 1 TO nLen 
    wszChar = MID(w, i, 1)

    if (asc(wszchar) >= &HD800) and (asc(wszchar) <= &HDBFF) then         'surrogate first char ?
      wszChar2 = MID(w, i+1, 1)

      if (asc(wszchar2) >= &HDC00) and (asc(wszchar2) <= &HDFFF) then     'surrogate second char ?
        MID(**r, nlen - i, 2) = wszchar + wszChar2    'keep byte order for surrogate
        i = i + 1

      else
        MID(**r, nlen - i + 1, 1) = wszchar
      end if

    else
      MID(**r, nlen - i + 1, 1) = wszchar
    end if  
  NEXT i


  RETURN r


END FUNCTION


'***********************************************************************************************
' Returns a string consisting of multiple copies of the specified string.
' This function is similar to STRING/WSTRING (which makes multiple copies of a single character).

' Syntax: Repeat_(5, "xyz")
'***********************************************************************************************


PRIVATE FUNCTION Repeat_ (BYVAL n AS LONG, BYREF w AS WSTRING) AS ustring
'***********************************************************************************************
' return w concatenated n times
'***********************************************************************************************
DIM u    AS ustring
DIM nLen AS LONG = LEN(w)


  IF n <= 0 THEN RETURN ""                            'nothing to do
  u = SPACE(n * nLen)                                 'create a buffer and insert the strings into it

  FOR i AS LONG = 0 TO n - 1
    MID(**u, (i * nLen) + 1, nLen) = w                'this avoids pysical concatenation
  NEXT


  RETURN u


END FUNCTION


'***********************************************************************************************
' Complement to the Remain_ function. Extracts characters from a string up to a character
' or group of characters. Returns a substring of w starting with its first character 
' (or the character specified by nStart) and up to (but not including) the first occurrence
' of m. If m is not present in w (or is null) then all of w is returned from the nStart position.
' nStart is an optional starting position to begin searching and extracting. If nStart is not 
' specified, position 1 will be used. If nStart is zero, a nul string is returned. If nStart is 
' negative, ' the starting position is counted from right to left: if -1, the search begins at the
' last character; if -2, the second to last, and so forth. This function can be made case insensitive.
' The default is case sensitive and no "ANY" -> m is handled "as string"

' Syntax: Extract_([nStart,] string to be searched, [any$,] char(s) to be searched for [, case in/sensitive])
'***********************************************************************************************


'PRIVATE FUNCTION Extract_ overload (BYVAL nStart AS LONG = 1, BYREF w AS WSTRING, byval anyflag as const long = 0, _
PRIVATE FUNCTION Extract_ overload (BYVAL nStart AS LONG = 1, BYREF w AS WSTRING, byval anyflag as const boolean = 0, _
                                    BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' return all of w before m (not including m), any -> chars in m individually, as string otherwise
' iflag -> make it case insensitive
'***********************************************************************************************
DIM nPos AS LONG


  IF LEN(w) = 0 THEN RETURN ""
  IF nStart = 0 OR nStart > LEN(w) THEN RETURN ""
  IF nStart < 0 THEN nStart = LEN(w) + nStart + 1


  if anyflag = 0 then
    if iflag = 0 then
      nPos = INSTR(nStart, w, m)
    else
      nPos = INSTR(nStart, UCASE(w), UCASE(m))
    end if

    IF nPos THEN RETURN MID(w, nStart, nPos - nStart )
    RETURN MID(w, nStart)

  else
    if iflag = 0 then
      nPos = INSTR(nStart, w, any m)
    else
      nPos = INSTR(nStart, UCASE(w), any UCASE(m))
    end if

    IF nPos THEN RETURN MID(w, nStart, nPos - nStart )
    RETURN MID(w, nStart)
  end if


END FUNCTION


'***********************************************************************************************


'***********************************************************************************************


PRIVATE FUNCTION Extract_ overload (BYREF w AS WSTRING, byval anyflag as const boolean = 0, BYREF m AS WSTRING, _
                                   byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no nStart
'***********************************************************************************************


  function = Extract_ (1, w, anyflag, m, iflag)


end function


'***********************************************************************************************


PRIVATE FUNCTION Extract_ overload (BYREF w AS WSTRING, BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no nStart, no any
'***********************************************************************************************


  function = Extract_ (1, w, 0, m, iflag)


end function


'***********************************************************************************************


PRIVATE FUNCTION Extract_ overload (BYVAL nStart AS LONG, BYREF w AS WSTRING, BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no any
'***********************************************************************************************


  function = Extract_ (nStart, w, 0, m, iflag)


end function


'***********************************************************************************************
' Complement to the Extract_ function. Returns the portion of a string following the
' first occurrence of a character or group of characters.
' w is searched for the string specified in m If found, all characters
' after m are returned. If m is not present in w (or is null) then
' a zero-length empty string is returned.
' nStart is an optional starting position to begin searching. If nStart is not specified,
' position 1 will be used. If nStart is zero, a nul string is returned. If nStart is negative,
' the starting position is counted from right to left: if -1, the search begins at the last
' character; if -2, the second to last, and so forth. This function can be made case insensitive.
' The default is case sensitive and no "ANY" -> m is handled "as string"

' Syntax: Remain_([nStart,] string to be searched, [any$,] char(s) to be searched for [, case in/sensitive])
'***********************************************************************************************


PRIVATE FUNCTION Remain_ overload (BYVAL nStart AS LONG = 1, BYREF w AS WSTRING, byval anyflag as long = 0, _
                                   BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' return all of w after m (not including m), any -> chars in m individually, as string otherwise
' iflag -> make it case insensitive
'***********************************************************************************************
DIM nPos AS LONG


  IF LEN(w) = 0 OR LEN(m) = 0 THEN RETURN ""
  IF nStart = 0 OR nStart > LEN(w) THEN RETURN ""
  IF nStart < 0 THEN nStart = LEN(w) + nStart + 1


  if anyflag = 0 then
    if iflag = 0 then
      nPos = INSTR(nStart, w, m)
    else
      nPos = INSTR(nStart, UCASE(w), UCASE(m))
    end if


    IF nPos THEN RETURN MID(w, nPos + LEN(m))
    RETURN ""

'    IF nPos = 0 THEN RETURN ""
'    u = w
'    u = MID(**u, nPos + LEN(m))

  else
    if iflag = 0 then
      nPos = INSTR(nStart, w, any m)
    else
      nPos = INSTR(nStart, UCASE(w), any UCASE(m))
    end if

    IF nPos THEN RETURN MID(w, nPos + 1)
    RETURN ""
  end if


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION Remain_ overload (BYREF w AS WSTRING, byval anyflag as long = 0, BYREF m AS WSTRING, _
                                   byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no nStart
'***********************************************************************************************


  function = Remain_ (1, w, anyflag, m, iflag)


end function


'***********************************************************************************************


PRIVATE FUNCTION Remain_ overload (BYREF w AS WSTRING, BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no nStart, no any
'***********************************************************************************************


  function = Remain_ (1, w, 0, m, iflag)


end function


'***********************************************************************************************


PRIVATE FUNCTION Remain_ overload (BYVAL nStart AS LONG, BYREF w AS WSTRING, BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no any
'***********************************************************************************************


  function = Remain_ (nStart, w, 0, m, iflag)


end function


'***********************************************************************************************
' Returns a copy of string w with substrings m removed individually or in total.
' If m is not present in w, all of w is returned intact. This function can be made case insensitive.
' The default is case sensitive and no "ANY" -> m is handled "as string"

' Syntax: Remove_(string to remove from [,[any$,] string to remove] [, case in/sensitive])
'***********************************************************************************************


PRIVATE FUNCTION Remove_ overload (BYREF w AS WSTRING, byval anyflag as long = 0, BYREF m AS WSTRING, _
                                   byval iflag as long = 0) AS ustring
'***********************************************************************************************
' return w with m removed, any -> remove chars in m individually, as string otherwise
' iflag -> make it case insensitive
'***********************************************************************************************
DIM u    AS ustring = w
DIM nLen AS LONG = LEN(m)
DIM nPos AS LONG = 1
dim wu   as wstring ptr
dim mu   as wstring ptr


  if anyflag = 0 then
    if iflag = 0 then
      if w = m then 
        u = ""
        return u
      end if

      DO
        nPos = INSTR(npos, **u, m)
        IF nPos = 0 THEN EXIT DO

        u = mid(**u, 1, npos-1) + mid(**u, npos+nlen)
      LOOP

    else
      wu = allocate(len(w) * 2 + 4) 
      mu = allocate(len(m) * 2 + 4) 

      *wu = ucase(w)
      *mu = ucase(m)

      if *wu = *mu then
        deallocate wu
        deallocate mu

        u = ""
        return u
      end if

      DO
        nPos = INSTR(npos, *wu, *mu)
        IF nPos = 0 THEN EXIT DO

        *wu = mid(*wu, 1, npos-1) + mid(*wu, npos+nlen)                   'must do this in parallel
        u = mid(**u, 1, npos-1) + mid(**u, npos+nlen)                     'to the original
      LOOP

      deallocate wu
      deallocate mu
      
    end if  

  else                                                'any
    if iflag = 0 then
      DO
        nPos = INSTR(npos, **u, any m)
        IF nPos = 0 THEN
          EXIT DO

        elseif nPos = 1 then
          if len(u) = 1 then
            u = ""
            exit do
          else
            u = mid(**u, 2)
          end if  

        else
          u = mid(**u, 1, npos-1) + mid(**u, npos+1)
        end if  
      LOOP

    else
      wu = allocate(len(w) * 2 + 4) 
      mu = allocate(len(m) * 2 + 4) 

      *wu = ucase(w)
      *mu = ucase(m)

      DO
        nPos = INSTR(npos, *wu, any *mu)
        IF nPos = 0 then
          EXIT DO

        elseif nPos = 1 then
          if len(u) = 1 then
            u = ""
            exit do
          else
            *wu = mid(*wu, 2)
            u = mid(**u, 2)
          end if  
        else
          *wu = mid(*wu, 1, npos-1) + mid(*wu, npos+1)
          u = mid(**u, 1, npos-1) + mid(**u, npos+1)
        end if  
      LOOP
      
      deallocate wu
      deallocate mu
      
    end if  
    
  end if  


  return u


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION Remove_ overload (BYREF w AS WSTRING, BYREF m AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no any
'***********************************************************************************************


  function = Remove_(w, 0, m, iflag)


end function


'***********************************************************************************************


PRIVATE FUNCTION Remove_ overload (BYREF w AS WSTRING, byval iflag as long = 0) AS ustring
'***********************************************************************************************
' no any
'***********************************************************************************************


  function = Remove_(w, 0, " ", iflag)


end function


'***********************************************************************************************
' Returns a delimited field from a string expression.
' m contains a string of one or more characters that must be individually or fully matched to 
' be successful dependig on "IsAny". If n evaluates to zero or is outside of the actual field 
' count, an empty string is returned. If n is negative then fields are searched from the right 
' to left in w. M is case-sensitive.

' Syntax: dim u as ustring = parse_(string to parse, [[any,] delimiter string,] position)
'***********************************************************************************************


PRIVATE FUNCTION Parse_ OVERLOAD (BYREF w AS WSTRING, BYVAL IsAny AS long = 0, BYREF m AS WSTRING = ",", BYVAL n AS LONG) AS ustring
'***********************************************************************************************
' returns the n-th substring (one based) in w with m as delimiter (one or more char)
'***********************************************************************************************
DIM nCount   AS LONG
dim nStart   AS LONG
DIM nPos     AS LONG = 1
DIM fReverse AS BOOLEAN = IIF(n < 0, TRUE, FALSE)
n = ABS(n)
DIM u        AS ustring = ""
dim l        as long


  IF IsAny THEN
    l = 1                                             'chars one by one
  ELSE
    l = len(m)                                        'entire string
  END IF


  IF fReverse THEN                                    'reverse search
    IF IsAny THEN
      nPos = InstrRev(w, ANY m)
    ELSE
      nPos = InstrRev(w, m)
    END IF

    DO WHILE nPos > 0                                'if not found loop will be skipped
      nStart = nPos + l
      nCount += 1
      nPos = nPos - l
      IF nCount = n THEN EXIT DO
      IF IsAny THEN
        nPos = InStrRev(w, ANY m, nPos)
      ELSE
        nPos = InStrRev(w, m, nPos)
      END IF
    LOOP

    IF nPos = 0 THEN nStart = 1                       'now continue forward to get the end of the token

    IF IsAny THEN
      nPos = INSTR(nStart, w, ANY m)
    ELSE
      nPos = INSTR(nStart, w, m)
    END IF

    IF nPos > 0 OR nCount = n THEN
      IF nPos = 0 THEN
        u = MID(w, nStart)
      ELSE
        u = MID(w, nStart, nPos - nStart)
      END IF
    END IF

  ELSE                                                'forward search
    DO
      nStart = nPos
      IF IsAny THEN
        nPos = INSTR(nPos, w, ANY m)
      ELSE
        nPos = INSTR(nPos, w, m)
      END IF

      IF nPos THEN
        nCount += 1
        nPos += l
      END IF
    LOOP UNTIL nPos = 0 OR nCount = n

    IF nPos > 0 OR nCount = n - 1 THEN
      IF nPos = 0 THEN
        u = MID(w, nStart)
      ELSE
        u = MID(w, nStart, nPos - l - nStart)
      END IF
    END IF
  END IF


  RETURN u


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION Parse_ OVERLOAD (BYREF w AS WSTRING, BYREF m AS WSTRING = ",", BYVAL n AS LONG) AS ustring
'***********************************************************************************************
' overload - no any
'***********************************************************************************************


  RETURN Parse_(w, 0, m, n)


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION Parse_ OVERLOAD (BYREF w AS WSTRING, BYVAL n AS LONG) AS ustring
'***********************************************************************************************
' overload - no any, no delimiter
'***********************************************************************************************


  RETURN Parse_(w, 0, ",", n)


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION LSet_ (BYREF w AS WSTRING, BYVAL n AS ULONG, BYref pad AS WSTRING = " ") AS ustring
'***********************************************************************************************
' return the n leftmost chars of w padded to the right with spaces the first char of pad
'***********************************************************************************************
dim u as ustring
dim l as ulong = len(w)


  if l >= n then                                      'no need to pad
    u = left(w, n)

  else  
    if len(pad) then
      u = wstring(n, pad)
    else                                              'if an empty string is passed -> use the default
      u = wstring(n, wchr(32))
    end if

    MID(**u, 1, l) = w                                'mid is faster than conctenation + left
  end if


  RETURN u

                  
END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION RSet_ (BYREF w AS WSTRING, BYVAL n AS ULONG, BYref pad AS WSTRING = " ") AS ustring
'***********************************************************************************************
' return the n right chars of w padded to the left with spaces or the first char of pad
'***********************************************************************************************
dim u as ustring
dim l as ulong = len(w)


  if l >= n then                                      'no need to pad
    u = right(w, n)

  else
    if len(pad) then
      u = wstring(n, pad)
    else                                              'if an empty string is passed -> use the default
      u = wstring(n, wchr(32)) 
    end if

    MID(**u, n-l+1, l) = w                            'mid is faster than conctenation + right
  end if


  RETURN u


END FUNCTION


'***********************************************************************************************
' Parses a path/file name to extract component parts.
' This function evaluates a text path/file text name, and returns a requested part of the
' name. The functionality is strictly one of string parsing alone.
' Oflag is one of the following options which is used to specify the requested part:
' PATH$   Returns the path portion of the path/file Name. That is the text up to and
'         including the last backslash (\) or colon (:).
'
' NAME$   Returns the name portion of the path/file Name. That is the text to the right
'         of the last backslash (\) or colon (:), ending just before the last period (.).
'
' EXTN$   Returns the extension portion of the path/file name. That is the last
'         period (.) in the string plus the text to the right of it.
'
' NAMEX$  Returns the name and the EXTN parts combined.

' Syntax: Pathname_(PATH$|NAME$|NAMEX$|EXTN$, filespec)
'***********************************************************************************************


PRIVATE FUNCTION PathName_ (BYval oflag AS long, BYREF w AS WSTRING) AS ustring
'***********************************************************************************************
' return requestet portion of a filespec
'***********************************************************************************************
DIM u  AS ustring = ""
DIM nPos AS LONG


  IF LEN(w) = 0 THEN RETURN u                         'nothing to do


  nPos = InstrRev(w, ANY ":/\")
  SELECT CASE oflag
    CASE PATH_                                        'returns the path portion of file spec
      IF nPos THEN u = MID(w, 1, nPos)

    CASE NAME_                                        'retrieve the full filename
       u = w
       IF nPos THEN u = MID(w, nPos + 1)              'get the filename
       nPos = InstrRev(u, ".")
       IF nPos THEN u = MID(u, 1, nPos - 1)

    CASE NAMEX_                                       'retrieve the name and extension combined '
       IF nPos THEN u = MID(w, nPos + 1) ELSE u = w

    CASE EXTN_                                        'retrieve the name and extension combined '
       IF nPos THEN u = MID(w, nPos + 1) ELSE u = w   'get the extension
       nPos = InStrRev(u, ".")
       IF nPos THEN u = MID(u, nPos) ELSE u = ""
   END SELECT


   RETURN u


END FUNCTION


'***********************************************************************************************
' Shrinks a string to be able to use a consistent single character delimiter.
' The purpose of this function is to create a string with consecutive data items (words)
' separated by a consistent single character. This makes it very straightforward to parse
' the results as needed.
' If m is not defined then all leading spaces and trailing spaces are removed entirely.
' All occurrences of two or more spaces are changed to a single space. Therefore, the new
' string returned consists of zero or more words, each separated by a single space character.
' If m is specified, it defines one or more delimiter characters to shrink. All leading
' and trailing mask characters are removed entirely. All occurrences of one or more mask
' characters are replaced with the first character of wszMask The new string returned consists
' of zero or more words, each separated by the character found in the first position of m.
' WhiteSpace is generally defined as the four common non-printing characters:
' Space, Tab, Carriage-Return, and Line-Feed. m = (W)Chr(32,9,13,10)

' Syntax: Shrink_(string to shrink, char to stay + chars to remove)
'***********************************************************************************************


PRIVATE FUNCTION Shrink_ (BYREF w AS WSTRING, BYREF m AS WSTRING = " ") AS ustring
'***********************************************************************************************
' replace all chars of m in w, by the first char of m, remove leading and trailing m chars in w
'***********************************************************************************************
DIM u AS ustring 


  IF LEN(w) = 0 THEN RETURN w                         'nothing to do
  IF LEN(m) = 0 THEN RETURN w                         'no mask, no shrink 
   
  u = TRIM(w, ANY m)                                  'Eliminate all leading and trailing mask characters

  DIM wReplace AS WSTRING * 2 = MID(m, 1, 1)          'first char of mask = replacement char
  DIM wdouble AS WSTRING * 3
  DIM nMaskLen AS LONG = LEN(m)
  DIM nPos AS LONG

'odx(wreplace)

  FOR i AS LONG = 1 TO nMaskLen                       'replace all double mask characters with wReplace
     wdouble = MID(m, i, 1) + MID(m, i, 1)            '(usually double spaces)

'odx(wdouble)
     nPos = 1
     DO
        nPos = INSTR(nPos, **u, wdouble)
'odx(npos)
        IF nPos = 0 THEN EXIT DO
        u = MID(**u, 1, nPos - 1) + wReplace + MID(**u, nPos + LEN(wdouble))
     LOOP
  NEXT

'odx(u)
  nPos = 1                                            'Replace all single mask chars with wReplace
  DO
     nPos = INSTR(nPos, **u, ANY m)
     IF nPos = 0 THEN EXIT DO                       
     
     IF MID(u, nPos, 1) <> wReplace  THEN             'do the replace if the character at the position found is
                                                      'different than the character we need to replace it with.
                                                      'this helps avoiding unneeded string concatenations.
        u = MID(**u, 1, nPos - 1) + wReplace + MID(**u, nPos + 1)
     END IF
     nPos += 1
  LOOP


  wdouble = MID(m, 1, 1) + MID(m, 1, 1)               'replace all double occurances of wReplace
  nPos = 1                                         
  DO
     nPos = INSTR(npos, **u, wdouble)
     IF nPos = 0 THEN EXIT DO
     u = MID(**u, 1, nPos - 1) + wReplace + MID(**u, nPos + LEN(wdouble))
  LOOP
  RETURN u


END FUNCTION


'***********************************************************************************************
' Count the number of occurrences of specified characters strings within a string.
' W is the string expression in which to count characters. M is a list of single characters 
' to be searched for individually or in total. A match on any one of which  or a match in total
' will cause the count to be incremented for each occurrence.Note that repeated characters in m 
' will not increase the count, if characters a searched individually. If m is not present in w, 
' zero is returned.

' Syntax: n = tally(string to count in, [any$,] string to find [, case in/sensitive]
' default: anyflag = 0 -> count entire string, iflag = 0 -> count case sensitive
'***********************************************************************************************


PRIVATE FUNCTION Tally overload (BYREF w AS WSTRING, byval anyflag as const boolean = 0, BYREF m AS WSTRING = " ", byval iflag as long = 0) AS ULONG
'***********************************************************************************************
' return count of m in w, anyflag = 1/0 chars in m individually/as string 
' iflag = 1/0 case in/sensitive, default is: "as string" and ""case sensitive""
'***********************************************************************************************
DIM n AS LONG = 0
DIM nPos AS LONG = 1
dim wu as wstring ptr
dim mu as wstring ptr


  if iflag = 0 then                                   'count case sensitive
    if anyflag = 0 then                               'match string as string
      DO
         nPos = INSTR(nPos, w, m)
         IF nPos = 0 THEN EXIT DO
         n += 1
         nPos += LEN(m)
      LOOP

    else

      DO
         nPos = INSTR(nPos, w, any m)
         IF nPos = 0 THEN EXIT DO
         n += 1
         nPos += 1
      LOOP
    end if
      
  else    
    wu = allocate(len(w) * 2 + 4) 
    mu = allocate(len(m) * 2 + 4) 

    *wu = ucase(w)
    *mu = ucase(m)

    if anyflag = 0 then                               'match string as string
      DO
         nPos = INSTR(nPos, *wu, *mu)
         IF nPos = 0 THEN EXIT DO
         n += 1
         nPos += LEN(m)
      LOOP

    else
      DO
         nPos = INSTR(nPos, *wu, any *mu)
         IF nPos = 0 THEN EXIT DO
         n += 1
         nPos += 1
      LOOP
    end if  

    deallocate wu
    deallocate mu
  end if  
      

  RETURN n


END FUNCTION


'***********************************************************************************************


PRIVATE FUNCTION Tally overload (BYREF w AS WSTRING, BYREF m AS WSTRING = " ", byval iflag as long = 0) AS ULONG
'***********************************************************************************************
' return count of m in w, iflag = 1/0 case in/sensitive, default is: "case sensitive"
'***********************************************************************************************
DIM n AS LONG = 0
DIM nPos AS LONG = 1
dim wu as wstring ptr
dim mu as wstring ptr


  function = tally(w, 0, m, iflag)


end function


'***********************************************************************************************
' Returns the count of delimited fields from a string expression.
' If w is empty (a null string) or contains no delimiter character(s), the string
' is considered to contain exactly one sub-field. In this case, ParseCount returns the value 1.
' m contains a string (one or more characters) that are seached individually or must be fully 
' matched.

' Syntax: n = parsecount(string to count in, [any$,] separating string [, case in/sensitive]
' default: anyflag = 0 -> separator = entire string, iflag = 0 -> case sensitive
'***********************************************************************************************


'PRIVATE FUNCTION parsecount overload (BYREF w AS WSTRING, byval anyflag as long = 0, BYREF m AS WSTRING = " ", byval iflag as long = 0) AS ULONG
PRIVATE FUNCTION parsecount overload (BYREF w AS WSTRING, byval anyflag as const boolean = 0, BYREF m AS WSTRING = " ", byval iflag as long = 0) AS ULONG
'***********************************************************************************************
' return count of portions of w sparated by m, anyflag = 1/0 chars in m individually/as string 
' iflag = 1/0 case in/sensitive, default is: "as string" and ""case sensitive""
'***********************************************************************************************


  FUNCTION = Tally (w, anyflag, m, iflag) + 1


end function


'***********************************************************************************************


PRIVATE FUNCTION parsecount overload (BYREF w AS WSTRING, BYREF m AS WSTRING = " ", byval iflag as long = 0) AS ULONG
'***********************************************************************************************
' return count of portions of w sparated by m, iflag = 1/0 case in/sensitive, 
' default is: "as string"
'***********************************************************************************************


  FUNCTION = Tally (w, m, iflag) + 1


end function


'***********************************************************************************************
' test, if w is a number (+-.0123456789)
'***********************************************************************************************


PRIVATE FUNCTION IsNumeric (BYREF w AS WSTRING) AS long
'***********************************************************************************************
' return -1, if w holds only number characters (+-.0123456789), 0 otherwise
'***********************************************************************************************
dim i  as long
dim n  as Ulong


  n = tally(w, any_, "+-.0123456789") 
  if n = len(w) then return -1                        'only numbers -> ok
  return 0


END FUNCTION


'***********************************************************************************************
' test, if w is a valid number (+-.0123456789E), scientific notation allowed
'***********************************************************************************************


PRIVATE FUNCTION IsValidNumber (BYREF w AS WSTRING) AS long
'***********************************************************************************************
' return -1, if w is a valid number with correct format (+-.0123456789E), 0 otherwise
'***********************************************************************************************
dim i  as long
dim n  as Ulong
dim p1 as USTRING
dim p2 as USTRING


  n = tally(w, any_, "+-.0123456789") 
  if n <> len(w) then                                 'not only numbers
    if n = len(w) - 1 then                            'one additional character
      i = tally(ucase(w), "E")
      if i <> 1 then return 0                         'not an "e" -> fail
      if mid(ucase(w), 1, 1) = "E" then return 0      'e in first place -> fail
      if right(ucase(w), 1) = "E" then return 0       'e in last place -> fail

      p1 = extract_(w, "e", case_)                    'all before exponent 
      p2 = remain_(w, "e", case_)                     'all after exponent

      i = instr(p1, any "+-")
      if i > 1 then return 0

      i = instr(p2, any "+-")
      if i > 1 then return 0

      if right(**p1, 1) = "." then return 0
      
      if tally(p1, any_, "+_") > 1 then return 0
      if tally(p1, "+") > 1 then return 0
      if tally(p1, "-") > 1 then return 0
      if tally(p1, ".") > 1 then return 0

      if tally(p2, any_, "+_") > 1 then return 0
      if tally(p2, "+") > 1 then return 0
      if tally(p2, "-") > 1 then return 0
      if tally(p2, ".") >= 1 then return 0

      return -1                                       'is a number with valid exponent -> ok

    else
      return 0                                        'more than one additional characters -> fail
    end if  

  else
    i = instr(w, any "+-")
    if i > 1 then return 0

    if tally(w, any_, "+_") > 1 then return 0
    if tally(w, "+") > 1 then return 0
    if tally(w, "-") > 1 then return 0
    if tally(w, ".") > 1 then return 0

    return -1
  end if

END FUNCTION


'***********************************************************************************************
'***********************************************************************************************
'***********************************************************************************************


''' ========================================================================================
''' Returns an uppercase version of a string.
''' - pwszStr [in]:
'''      The string to convert. Cannot have a size of 0.
''' - pwszLocaleName [in, optional]:
'''      Pointer to a locale name or one of these pre-defined values:
'''         LOCALE_NAME_INVARIANT
'''         LOCALE_NAME_SYSTEM_DEFAULT
'''         LOCALE_NAME_USER_DEFAULT
'''      For a table of language culture names see:
'''         https://msdn.microsoft.com/es-es/library/ee825488(v=cs.20).aspx
''' - dwMapFlags [in, optional]:
'''      Flag specifying the type of transformation to use during string mapping or the type
'''      of sort key to generate. This parameter can have the following values
'''      For a complete list see:
'''      https://msdn.microsoft.com/en-us/library/windows/desktop/dd318702(v=vs.85).aspx
''' Return value:
'''   The uppercased string.
''' ========================================================================================
''PRIVATE FUNCTION AfxStrUCase (BYVAL pwszStr AS WSTRING PTR, _
''   BYVAL pwszLocaleName AS WSTRING PTR = LOCALE_NAME_USER_DEFAULT, _
''   BYVAL dwMapFlags AS DWORD = 0) AS ustring
''
''   ' // Check the vailidy of the passed parameters
''   IF pwszStr = NULL THEN RETURN ""
''   IF LEN(*pwszStr) = 0 THEN RETURN ""
''   DIM cwsOut AS ustring = *pwszStr
''   ' // Make sure that LCMAP_LOWERCASE is not being used
''   dwMapFlags = dwMapFlags AND (NOT LCMAP_LOWERCASE)
''   ' // Make sure that LCMAP_LINGUISTIC_CASING OR LCMAP_UPPERCASE is being used
''   dwMapFlags OR= LCMAP_LINGUISTIC_CASING OR LCMAP_UPPERCASE
''   ' // Ususally, the length of the converted string will be the same that the one of
''   ' // the input string, so let's try it
''   DIM cbLen AS LONG = LCMapStringEx(pwszLocaleName, dwMapFlags, pwszStr, LEN(*pwszStr), _
''       cwsOut.vptr, LEN(cwsOut), NULL, NULL, 0)
''   ' // If the output length is bigger than the input one, request the needed length,
''   ' // make the buffer bigger and try it again
''   IF cbLen = 0 AND GetLastError = ERROR_INSUFFICIENT_BUFFER THEN
''      cbLen = LCMapStringEx(pwszLocaleName, dwMapFlags, pwszStr, LEN(*pwszStr), NULL, 0, NULL, NULL, 0)
''      IF cbLen THEN
''         cwsOut += SPACE(cbLen)
''         cbLen = LCMapStringEx(pwszLocaleName, dwMapFlags, pwszStr, LEN(*pwszStr), _
''                 cwsOut.vptr, LEN(cwsOut), NULL, NULL, 0)
''      END IF
''   END IF
''   RETURN cwsOut
''
''END FUNCTION
''' ========================================================================================
''
''' ========================================================================================
''' Returns a lowercase version of a string.
''' - pwszStr [in]:
'''      The string to convert. Cannot have a size of 0.
''' - pwszLocaleName [in, optional]:
'''      Pointer to a locale name or one of these pre-defined values:
'''         LOCALE_NAME_INVARIANT
'''         LOCALE_NAME_SYSTEM_DEFAULT
'''         LOCALE_NAME_USER_DEFAULT
'''      For a table of language culture names see:
'''         https://msdn.microsoft.com/es-es/library/ee825488(v=cs.20).aspx
''' - dwMapFlags [in, optional]:
'''      Flag specifying the type of transformation to use during string mapping or the type
'''      of sort key to generate. This parameter can have the following values
'''      For a complete list see:
'''      https://msdn.microsoft.com/en-us/library/windows/desktop/dd318702(v=vs.85).aspx
''' Return value:
'''   The lowercased string.
''' ========================================================================================
''PRIVATE FUNCTION AfxStrLCase (BYVAL pwszStr AS WSTRING PTR, _
''   BYVAL pwszLocaleName AS WSTRING PTR = LOCALE_NAME_USER_DEFAULT, _
''   BYVAL dwMapFlags AS DWORD = 0) AS ustring
''
''   ' // Check the vailidy of the passed parameters
''   IF pwszStr = NULL THEN RETURN ""
''   IF LEN(*pwszStr) = 0 THEN RETURN ""
''   DIM cwsOut AS ustring = *pwszStr
''   ' // Make sure that LCMAP_UPPERCASE is not being used
''   dwMapFlags = dwMapFlags AND (NOT LCMAP_UPPERCASE)
''   ' // Make sure that LCMAP_LINGUISTIC_CASING OR LCMAP_LOWERCASE is being used
''   dwMapFlags OR= LCMAP_LINGUISTIC_CASING OR LCMAP_LOWERCASE
''   ' // Ususally, the length of the converted string will be the same that the one of
''   ' // the input string, so let's try it
''   DIM cbLen AS LONG = LCMapStringEx(pwszLocaleName, dwMapFlags, pwszStr, LEN(*pwszStr), _
''       cwsOut.vptr, LEN(cwsOut), NULL, NULL, 0)
''   ' // If the output length is bigger than the input one, request the needed length,
''   ' // make the buffer bigger and try it again
''   IF cbLen = 0 AND GetLastError = ERROR_INSUFFICIENT_BUFFER THEN
''      cbLen = LCMapStringEx(pwszLocaleName, dwMapFlags, pwszStr, LEN(*pwszStr), NULL, 0, NULL, NULL, 0)
''      IF cbLen THEN
''         cwsOut += SPACE(cbLen)
''         cbLen = LCMapStringEx(pwszLocaleName, dwMapFlags, pwszStr, LEN(*pwszStr), _
''                 cwsOut.vptr, LEN(cwsOut), NULL, NULL, 0)
''      END IF
''   END IF
''   RETURN cwsOut
''
''END FUNCTION
''' ========================================================================================
''#endif
'

'
'' ========================================================================================
'' * Returns a string containing only the characters contained in a specified match string.
'' All other characters are removed. If wszMatchStr is an empty string the function returns
'' an empty string. This function is case-sensitive.
'' Example: DIM cws AS ustring = AfxStrRetain("abacadabra","b")   ' -> "bb"
'' ========================================================================================
'PRIVATE FUNCTION AfxStrRetain (BYREF w AS WSTRING, BYREF wszMatchStr AS WSTRING) AS ustring
'   DIM cws AS ustring = ""
'   IF LEN(w) = 0 OR LEN(wszMatchStr) = 0 THEN RETURN cws
'   DIM nLen AS LONG = LEN(wszMatchStr)
'   DIM nPos AS LONG = 1
'   DO
'      nPos = INSTR(nPos, w, wszMatchStr)
'      IF nPos = 0 THEN EXIT DO
'      cws += MID(w, nPos, nLen)
'      nPos += nLen
'   LOOP
'   RETURN cws
'END FUNCTION
'' ========================================================================================
'' ========================================================================================
'' * Case insensitive version of AfxStrRetain.
'' Example: DIM cws AS ustring = AfxStrRetainI("abacadabra","B")   ' -> "bb"
'' ========================================================================================
'PRIVATE FUNCTION AfxStrRetainI (BYREF w AS WSTRING, BYREF wszMatchStr AS WSTRING) AS ustring
'   DIM cws AS ustring = ""
'   IF LEN(w) = 0 OR LEN(wszMatchStr) = 0 THEN RETURN cws
'   DIM cwsMainStr AS ustring = UCASE(w)
'   DIM wu AS ustring = UCASE(wszMatchStr)
'   DIM nLen AS LONG = LEN(wszMatchStr)
'   DIM nPos AS LONG = 1
'   DO
'      nPos = INSTR(nPos, cwsMainStr, wu)
'      IF nPos = 0 THEN EXIT DO
'      cws += MID(w, nPos, nLen)
'      nPos += nLen
'   LOOP
'   RETURN cws
'END FUNCTION
'' ========================================================================================
'
'' ========================================================================================
'' * Returns a string containing only the characters contained in a specified match string.
'' All other characters are removed.
'' If wszMatchStr is an empty string the function returns an empty string.
'' wszMatchStr specifies a list of single characters to be searched for individually.
'' A match on any one of which will cause that character to be removed from the result.
'' This function is case-sensitive.
'' Example: AfxStrRetainAny("<p>1234567890<ak;lk;l>1234567890</p>", "<;/p>")
'' ========================================================================================
'PRIVATE FUNCTION AfxStrRetainAny (BYREF w AS WSTRING, BYREF wszMatchStr AS WSTRING) AS ustring
'   DIM cws AS ustring = ""
'   DIM nLen AS LONG = LEN(w)
'   IF nLen = 0 OR LEN(wszMatchStr) = 0 THEN RETURN cws
'   DIM nPos AS LONG
'   FOR i AS LONG = 1 TO nLen
'      nPos = INSTR(wszMatchStr, MID(w, i, 1))
'      IF nPos THEN cws += MID(w, i, 1)
'   NEXT
'   RETURN cws
'END FUNCTION
'' ========================================================================================
'' ========================================================================================
'' * Case insensitive version of AfxStrRetainAny.
'' Example: AfxStrRetainAnyI("<p>1234567890<ak;lk;l>1234567890</p>", "<;/P>")
'' ========================================================================================
'PRIVATE FUNCTION AfxStrRetainAnyI (BYREF w AS WSTRING, BYREF wszMatchStr AS WSTRING) AS ustring
'   DIM cws AS ustring = ""
'   DIM nLen AS LONG = LEN(w)
'   IF nLen = 0 OR LEN(wszMatchStr) = 0 THEN RETURN cws
'   DIM cwsMainStr AS ustring = UCASE(w)
'   DIM cwsMatchStr AS ustring = UCASE(wszMatchStr)
'   DIM nPos AS LONG
'   FOR i AS LONG = 1 TO nLen
'      nPos = INSTR(cwsMatchStr, MID(cwsMainStr, i, 1))
'      IF nPos THEN cws += MID(w, i, 1)
'   NEXT
'   RETURN cws
'END FUNCTION
'' ========================================================================================


''' ========================================================================================
''' Converts a numeric value into a string that represents the number expressed as a size
''' value in bytes, kilobytes, megabytes, or gigabytes, depending on the size.
''' ========================================================================================
''PRIVATE FUNCTION AfxStrFormatByteSize (BYVAL ull AS ULONGLONG) AS ustring
''   DIM cws AS ustring = SPACE(260)
''   StrFormatByteSizeW(ull, cws.vptr, 260)
''   RETURN cws
''END FUNCTION
''' ========================================================================================
''
''' ========================================================================================
''' Converts a numeric value into a string that represents the number expressed as a size
''' value in kilobytes.
''' ========================================================================================
''PRIVATE FUNCTION AfxStrFormatKBSize (BYVAL ull AS ULONGLONG) AS ustring
''   DIM cws AS ustring = SPACE(260)
''   StrFormatKBSizeW(ull, cws.vptr, 260)
''   RETURN cws
''END FUNCTION
'' ========================================================================================


'' ========================================================================================
'' Converts a time interval, specified in milliseconds, to a string.
'' Parameters:
'' - dwTimeMS: The time interval, in milliseconds.
'' - digits  : The maximum number of significant digits to be represented in the output
''             string. Some examples are:
''             dwTimeMS digits   cwsOut
''             -------- ------ -----------
''                34000    3        34 sec
''                34000    2        34 sec
''                34000    1        30 sec
''                74000    3  1 min 14 sec
''                74000    2  1 min 10 sec
''                74000    1  1 min
'' ========================================================================================
''PRIVATE FUNCTION AfxStrFromTimeInterval (BYVAL dwTimeMS AS DWORD, BYVAL digits AS LONG) AS ustring
''   DIM cws AS ustring = SPACE(260)
''   StrFromTimeIntervalW(cws.vptr, 260, dwTimeMS, digits)
''   RETURN cws
''END FUNCTION
'' ========================================================================================


'' ========================================================================================
'' Base64 is a group of similar encoding schemes that represent binary data in an ASCII
'' string format by translating it into a radix-64 representation. The Base64 term
'' originates from a specific MIME content transfer encoding.
'' Base64 encoding schemes are commonly used when there is a need to encode binary data
'' that needs be stored and transferred over media that are designed to deal with textual
'' data. This is to ensure that the data remains intact without modification during
'' transport. Base64 is used commonly in a number of applications including email via MIME,
'' and storing complex data in XML.
'' ========================================================================================
'
'' ========================================================================================
'' Converts an array of bytes into a formatted string.
'' Note: Wrapped because, at the time of writing, it is not supported by the provided
'' FreeBasic crypt32 import library.
'' ========================================================================================
''PRIVATE FUNCTION AfxCryptBinaryToStringA (BYVAL pbBinary AS CONST UBYTE PTR, BYVAL cbBinary AS DWORD, _
''BYVAL dwFlags AS DWORD, BYVAL pszString AS LPSTR, BYVAL pcchString AS DWORD PTR) AS WINBOOL
''   DIM AS ANY PTR pLib = DyLibLoad("crypt32.dll")
''   IF pLib = NULL THEN EXIT FUNCTION
''   DIM pCryptBinaryToStringA AS FUNCTION (BYVAL pbBinary AS CONST UBYTE PTR, BYVAL cbBinary AS DWORD, _
''       BYVAL dwFlags AS DWORD, BYVAL pszString AS LPSTR, BYVAL pcchString AS DWORD PTR) AS WINBOOL
''   pCryptBinaryToStringA = DyLibSymbol(pLib, "CryptBinaryToStringA")
''   IF pCryptBinaryToStringA THEN FUNCTION = pCryptBinaryToStringA(pbBinary, cbBinary, dwFlags, pszString, pcchString)
''   DyLibFree(pLib)
''END FUNCTION
''' ========================================================================================
''' ========================================================================================
''PRIVATE FUNCTION AfxCryptBinaryToStringW (BYVAL pbBinary AS CONST UBYTE PTR, BYVAL cbBinary AS DWORD, _
''BYVAL dwFlags AS DWORD, BYVAL pszString AS LPWSTR, BYVAL pcchString AS DWORD PTR) AS WINBOOL
''   DIM AS ANY PTR pLib = DyLibLoad("crypt32.dll")
''   IF pLib = NULL THEN EXIT FUNCTION
''   DIM pCryptBinaryToStringW AS FUNCTION (BYVAL pbBinary AS CONST UBYTE PTR, BYVAL cbBinary AS DWORD, _
''       BYVAL dwFlags AS DWORD, BYVAL pszString AS LPWSTR, BYVAL pcchString AS DWORD PTR) AS WINBOOL
''   pCryptBinaryToStringW = DyLibSymbol(pLib, "CryptBinaryToStringW")
''   IF pCryptBinaryToStringW THEN FUNCTION = pCryptBinaryToStringW(pbBinary, cbBinary, dwFlags, pszString, pcchString)
''   DyLibFree(pLib)
''END FUNCTION
''' ========================================================================================
''#ifndef UNICODE
''   #define AfxCryptBinaryToString(p1, p2, p3, p4, p5) AfxCryptBinaryToStringA(p1, p2, p3, p4, p5)
''#else
''   #define AfxCryptBinaryToString(p1, p2, p3, p4, p5) AfxCryptBinaryToStringW(p1, p2, p3, p4, p5)
''#endif
''
''' ========================================================================================
''PRIVATE FUNCTION AfxBase64Encode (BYREF strData AS STRING) AS STRING
''   DIM cchStr AS DWORD, strOut AS STRING
''   DIM bRes AS LONG = AfxCryptBinaryToStringA(STRPTR(strData), LEN(strData), CRYPT_STRING_BASE64, NULL, @cchStr)
''   IF bRes = 0 OR cchStr = 0 THEN EXIT FUNCTION
''   strOut = SPACE(cchStr)
''   bRes = AfxCryptBinaryToStringA(STRPTR(strData), LEN(strData), CRYPT_STRING_BASE64, STRPTR(strOut), @cchStr)
''   FUNCTION = strOut
''END FUNCTION
''' ========================================================================================
''   
''' ========================================================================================
''' Converts a formatted string into an array of bytes.
''' ========================================================================================
''PRIVATE FUNCTION AfxCryptStringToBinaryA (BYVAL pszString AS LPCSTR, BYVAL cchString AS DWORD, _
''BYVAL dwFlags AS DWORD, BYVAL pbBinary AS UBYTE PTR, BYVAL pcbBinary AS DWORD PTR, _
''BYVAL pdwSkip AS DWORD PTR, BYVAL pdwFlags AS DWORD PTR) AS WINBOOL
''   DIM AS ANY PTR pLib = DyLibLoad("crypt32.dll")
''   IF pLib = NULL THEN EXIT FUNCTION
''   DIM pCryptStringToBinaryA AS FUNCTION (BYVAL pszString AS LPCSTR, BYVAL cchString AS DWORD, _
''       BYVAL dwFlags AS DWORD, BYVAL pbBinary AS UBYTE PTR, BYVAL pcbBinary AS DWORD PTR, _
''       BYVAL pdwSkip AS DWORD PTR, BYVAL pdwFlags AS DWORD PTR) AS WINBOOL
''   pCryptStringToBinaryA = DyLibSymbol(pLib, "CryptStringToBinaryA")
''   IF pCryptStringToBinaryA THEN FUNCTION = pCryptStringToBinaryA(pszString, cchString, dwFlags, pbBinary, pcbBinary, pdwSkip, pdwFLags)
''   DyLibFree(pLib)
''END FUNCTION
''' ========================================================================================
''' ========================================================================================
''PRIVATE FUNCTION AfxCryptStringToBinaryW (BYVAL pwszString AS LPDWSTR, BYVAL cchString AS DWORD, _
''BYVAL dwFlags AS DWORD, BYVAL pbBinary AS UBYTE PTR, BYVAL pcbBinary AS DWORD PTR, _
''BYVAL pdwSkip AS DWORD PTR, BYVAL pdwFlags AS DWORD PTR) AS WINBOOL
''   DIM AS ANY PTR pLib = DyLibLoad("crypt32.dll")
''   IF pLib = NULL THEN EXIT FUNCTION
''   DIM pCryptStringToBinaryW AS FUNCTION (BYVAL pwszString AS LPDWSTR, BYVAL cchString AS DWORD, _
''       BYVAL dwFlags AS DWORD, BYVAL pbBinary AS UBYTE PTR, BYVAL pcbBinary AS DWORD PTR, _
''       BYVAL pdwSkip AS DWORD PTR, BYVAL pdwFlags AS DWORD PTR) AS WINBOOL
''   pCryptStringToBinaryW = DyLibSymbol(pLib, "CryptStringToBinaryW")
''   IF pCryptStringToBinaryW THEN FUNCTION = pCryptStringToBinaryW(pwszString, cchString, dwFlags, pbBinary, pcbBinary, pdwSkip, pdwFLags)
''   DyLibFree(pLib)
''END FUNCTION
''' ========================================================================================
''#ifndef UNICODE
''   #define AfxCryptStringToBinary(p1, p2, p3, p4, p5, p6, p7) AfxCryptStringToBinaryA(p1, p2, p3, p4, p5, p6, p7)
''#else
''   #define AfxCryptStringToBinary(p1, p2, p3, p4, p5, p6, p7) AfxCryptStringToBinaryW(p1, p2, p3, p4, p5, p6, p7)
''#endif
''
''' ========================================================================================
''PRIVATE FUNCTION AfxBase64Decode (BYREF strData AS STRING) AS STRING
''   DIM cbBinary AS DWORD, strOut AS STRING
''   DIM bRes AS LONG = AfxCryptStringToBinaryA(STRPTR(strData), LEN(strData), CRYPT_STRING_BASE64, NULL, @cbBinary, NULL, NULL)
''   IF bRes = 0 OR cbBinary = 0 THEN EXIT FUNCTION
''   strOut = SPACE(cbBinary)
''   bRes = AfxCryptStringToBinaryA(STRPTR(strData), LEN(strData), CRYPT_STRING_BASE64, STRPTR(strOut), @cbBinary, NULL, NULL)
''   FUNCTION = strOut
''END FUNCTION
''' ========================================================================================

'***********************************************************************************************
'***********************************************************************************************


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


