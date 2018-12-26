#compiler freebasic
'#compile console 32 exe /o "-R"
'#compile console 32 exe /o "-gen gcc -R"
'#compile console 32 exe /o "-gen gcc -R -exx"       
'#compile console 32 exe /o "-R -w pedantic -exx"

'#compile console 64 exe /o "-gen gcc -Wc -O3 -R"
#compile console 32 exe /o "-gen gcc -Wc -O3 -R"
'#compile console 64 exe /o "-R"


'***********************************************************************************************
' end JK-IDE specific
'***********************************************************************************************


#define unicode
'#include once "windows.bi"
'#include once "crt\mem.bi"


#define jklw                                          'use "ustring.inc" alone
#define jose                                          'use José´s type for USTRING


#define marc                                          'future extension


#ifdef jklw
  #include "ustring.inc"

#else
  #ifdef jose
    #include once "afx\afxstr.inc"
    #include "ustring.inc"

  #else
    #ifdef marc
      #include "D:\PBwin10\IDE\Projects\FreeBASIC\DWString\dwstr.inc"
      #include "ustring.inc"

    #else
      #include "ustring.inc"                          'fallback
    #endif
  #endif
#endif



'***********************************************************************************************

' MKD/I/L/LONGINT/S/SHORT  ?
' CVD/I/L/LONGINT/S/SHORT  ?

'***********************************************************************************************
'***********************************************************************************************


#macro hCheckString( U, w )
  r = 0                                               'reset flag

	scope
		if(len(u) <> len(w)) then
      r = 1                                           'signal error
		else
'      if u <> w then
'        r = 1
'      end if

			for i as integer = 1 to len(u)
				if(u[i] <> w[i]) then
          r = 1                                       'signal error
					exit for
				end if
			next
		end if
	end scope
#endmacro


declare function FB_MAIN as long
END FB_MAIN


'***********************************************************************************************
'***********************************************************************************************


function typetest(byref y as wstring) as long
'***********************************************************************************************
' test initialisation, assignment and concatenation of this dynamic wide string type
'***********************************************************************************************
dim i as long
dim r as long
dim x as long
dim z as long


'***********************************************************************************************
' initialization
'***********************************************************************************************
  print "Initialization: ",,
  x = 0


  scope

    '' declare constructor()
    scope
      dim u as ustring
      dim w as wstring * 50
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - empty constructor"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' declare constructor( byref rhs as const wstring )
    scope
      dim w as wstring * 50 = !"wstring\u4644"
      dim u as ustring = !"wstring\u4644"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' declare constructor( byref rhs as wstring )
    scope
      dim w as wstring * 50 = y
      dim u as ustring = w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' declare constructor( byref rhs as Ustring )
    scope
      dim w as wstring * 50 = y
      dim u1 as ustring = w
      dim u as ustring = u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as USTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' declare constructor( byref rhs as string )
    scope
      dim s as string = "ansi string"
      dim w as wstring * 50 = s
      dim u as ustring = s
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as STRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' declare constructor( byref rhs as zstring )
    scope
      dim z as Zstring * 50 = "z string"
      dim w as wstring * 50 = z
      dim u as ustring = z
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as ZSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' declare constructor( byval rhs as const wstring const ptr )
    scope
      dim w as wstring * 50 = y
      dim u as ustring = @w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING PTR"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


'***********************************************************************************************
' is this necessary ??? it isn´t allowed for all other string type too (invalid assignment/conversion)
'dim w as wstring * 4
'  w = 2  => (invalid assignment/conversion)

 ' u = wchr(<numeric data type>) -> works
'***********************************************************************************************
	'' declare constructor( byval rhs as longint )
  
'    scope
'      dim w as wstring * 50 = Wstr(123)
'      dim u as ustring = 123
'      hCheckString(u, w)
'
'      if r = 1 then
'        x = 1
'        print
'        print "  ERROR (line#: " & __LINE__ & ") - as LONGINT"
'        print "  u: -" + u + "-"
'        print "  w: -" + w + "-"
'      end if
'    end scope
'
'    '' declare constructor( byval rhs as double )
'    scope
'      dim w as wstring * 50 = Wstr(3.14)
'      dim u as ustring = 3.14
'      hCheckString(u, w)
'
'      if r = 1 then
'        x = 1
'        print
'        print "  ERROR (line#: " & __LINE__ & ") - as DOUBLE"
'        print "  u: -" + u + "-"
'        print "  w: -" + w + "-"
'      end if
'    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


'***********************************************************************************************
' assignment
'***********************************************************************************************
  print "Assignment: ",,,
  x = 0


  scope

    '' assignment( byref rhs as const wstring )
    scope
      dim w as wstring * 50 = !"wstring\u4644"
      dim u as ustring 
      u = !"wstring\u4644"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' assignment( byref rhs as wstring )
    scope
      dim w as wstring * 50 = y
      dim u as ustring 
      u = w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' assignment( byref rhs as Ustring )
    scope
      dim w as wstring * 50 = y
      dim u1 as ustring = w
      dim u as ustring 
      u = u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as USTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' assignment( byref rhs as string )
    scope
      dim s as string = "ansi string"
      dim w as wstring * 50 = s
      dim u as ustring 
      u = s
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as STRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' assignment( byref rhs as zstring )
    scope
      dim z as Zstring * 50 = "z string"
      dim w as wstring * 50 = z
      dim u as ustring 
      u = z
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as ZSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' assignment( byval rhs as const wstring const ptr )
    scope
      dim w as wstring * 50 = y
      dim u as ustring 
      u = @w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING PTR"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


'***********************************************************************************************
' is this necessary ??? it isn´t allowed for all other string type too (invalid assignment/conversion)
'dim w as wstring * 4
'  w = 2  => (invalid assignment/conversion)

 ' u = wchr(<numeric data type>) -> works
'***********************************************************************************************
	'' assignment( byval rhs as longint )
  
'    scope
'      dim w as wstring * 50 = Wstr(123)
'      dim u as ustring 
'      u = 123
'      hCheckString(u, w)
'
'      if r = 1 then
'        x = 1
'        print
'        print "  ERROR (line#: " & __LINE__ & ") - as LONGINT"
'        print "  u: -" + u + "-"
'        print "  w: -" + w + "-"
'      end if
'    end scope
'
'    '' assignment( byval rhs as double )
'    scope
'      dim w as wstring * 50 = Wstr(3.14)
'      dim u as ustring 
'      u = 3.14
'      hCheckString(u, w)
'
'      if r = 1 then
'        x = 1
'        print
'        print "  ERROR (line#: " & __LINE__ & ") - as DOUBLE"
'        print "  u: -" + u + "-"
'        print "  w: -" + w + "-"
'      end if
'    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


'***********************************************************************************************
' concatenation
'***********************************************************************************************
  print "Concatenation 1: (+ operator) ",
  x = 0


  scope

    '' concatenation( byref rhs as const wstring )
    scope
      dim w as wstring * 50 = !"wstring\u4644"
      dim u as ustring = !"wstring\u4644"
      w = w + !"wstring\u4644"
      u = u + !"wstring\u4644"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as wstring )
    scope
      dim w as wstring * 50 = y
      dim u as ustring = w
      u = u + w
      w = w + w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as Ustring )
    scope
      dim w as wstring * 50 = y
      dim u1 as ustring = w
      dim u as ustring = u1
      w = w + u1
      u = u + u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as USTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as string )
    scope
      dim s as string = "ansi string"
      dim w as wstring * 50 = s
      dim u as ustring = s
      w = w + s
      u = u + s
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as STRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as zstring )
    scope
      dim z as Zstring * 50 = "z string"
      dim w as wstring * 50 = z
      dim u as ustring = z
      w = w + z
      u = u + z
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as ZSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


'***********************************************************************************************
' is this necessary ??? it isn´t allowed for all other string type too (invalid assignment/conversion)
'dim w as wstring * 4
'  w = 2  => (invalid assignment/conversion)

 ' u = wchr(<numeric data type>) -> works
'***********************************************************************************************
	'' concatenation( byval rhs as longint )
  
    scope
      dim w as wstring * 50 = Wstr(123)
      dim u as ustring = wstr(123)
      w = w + wstr(123)
'      u = u + 123                                     'wrong
      u = u + wstr(123)                               'correct

      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as LONGINT"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byval rhs as double )
    scope
      dim w as wstring * 50 = Wstr(3.14)
      dim u as ustring = wstr(3.14)
      w = w + wstr(3.14)
'      u = u + 3.14                                    'wrong
      u = u + wstr(3.14)                              'correct
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as DOUBLE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


  print "Concatenation 2: (& operator) ",
  x = 0


  scope

    '' concatenation( byref rhs as const wstring )
    scope
      dim w as wstring * 50 = !"wstring\u4644"
      dim u as ustring = !"wstring\u4644"
      w = w & !"wstring\u4644"
      u = u & !"wstring\u4644"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as wstring )
    scope
      dim w as wstring * 50 = y
      dim u as ustring = w
      u = u & w
      w = w & w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as Ustring )
    scope
      dim w as wstring * 50 = y
      dim u1 as ustring = w
      dim u as ustring = u1
      w = w & u1
      u = u & u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as USTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as string )
    scope
      dim s as string = "ansi string"
      dim w as wstring * 50 = s
      dim u as ustring = s
      w = w & s
      u = u & s
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as STRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as zstring )
    scope
      dim z as Zstring * 50 = "z string"
      dim w as wstring * 50 = z
      dim u as ustring = z
      w = w & z
      u = u & z
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as ZSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


'***********************************************************************************************
' is this necessary ??? it isn´t allowed for all other string type too (invalid assignment/conversion)
'dim w as wstring * 4
'  w = 2  => (invalid assignment/conversion)

 ' u = wchr(<numeric data type>) -> works
'***********************************************************************************************
	'' concatenation( byval rhs as longint )
  
    scope
      dim w as wstring * 50 = Wstr(123)
      dim u as ustring = wstr(123)
      w = w & 123
      u = u & 123
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as LONGINT"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byval rhs as double )
    scope
      dim w as wstring * 50 = Wstr(3.14)
      dim u as ustring = wstr(3.14)
      w = w & 3.14
      u = u & 3.14                       
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as DOUBLE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


  print "Concatenation 3: (+= operator) ",
  x = 0


  scope

    '' concatenation( byref rhs as const wstring )
    scope
      dim w as wstring * 50 = !"wstring\u4644"
      dim u as ustring = !"wstring\u4644"
      w += !"wstring\u4644"
      u += !"wstring\u4644"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as wstring )
    scope
      dim w as wstring * 50 = y
      dim u as ustring = w
      u += w
      w += w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as Ustring )
    scope
      dim w as wstring * 50 = y
      dim u1 as ustring = w
      dim u as ustring = u1
      w += u1
      u += u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as USTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as string )
    scope
      dim s as string = "ansi string"
      dim w as wstring * 50 = s
      dim u as ustring = s
      w += s
      u += s
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as STRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as zstring )
    scope
      dim z as Zstring * 50 = "z string"
      dim w as wstring * 50 = z
      dim u as ustring = z
      w += z
      u += z
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as ZSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


'***********************************************************************************************
' is this necessary ??? it isn´t allowed for all other string type too (invalid assignment/conversion)
'dim w as wstring * 4
'  w = 2  => (invalid assignment/conversion)

 ' u = wchr(<numeric data type>) -> works
'***********************************************************************************************
	'' concatenation( byval rhs as longint )
  
    scope
      dim w as wstring * 50 = Wstr(123)
      dim u as ustring = 123
      w += wstr(123)
      u += 123
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as LONGINT"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byval rhs as double )
    scope
      dim w as wstring * 50 = Wstr(3.14)
      dim u as ustring = 3.14
      w += wstr(3.14)
      u += wstr(3.14)
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as DOUBLE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


  print "Concatenation 4: (&= operator) ",
  x = 0


  scope

    '' concatenation( byref rhs as const wstring )
    scope
      dim w as wstring * 50 = !"wstring\u4644"
      dim u as ustring = !"wstring\u4644"
      w &= !"wstring\u4644"
      u &= !"wstring\u4644"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as const WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as wstring )
    scope
      dim w as wstring * 50 = y
      dim u as ustring = w
      u &= w
      w &= w
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as Ustring )
    scope
      dim w as wstring * 50 = y
      dim u1 as ustring = w
      dim u as ustring = u1
      w &= u1
      u &= u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as USTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as string )
    scope
      dim s as string = "ansi string"
      dim w as wstring * 50 = s
      dim u as ustring = s
      w &= s
      u &= s
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as STRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byref rhs as zstring )
    scope
      dim z as Zstring * 50 = "z string"
      dim w as wstring * 50 = z
      dim u as ustring = z
      w &= z
      u &= z
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as ZSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


'***********************************************************************************************
' is this necessary ??? it isn´t allowed for all other string type too (invalid assignment/conversion)
'dim w as wstring * 4
'  w = 2  => (invalid assignment/conversion)

 ' u = wchr(<numeric data type>) -> works
'***********************************************************************************************
	'' concatenation( byval rhs as longint )
  
    scope
      dim w as wstring * 50 = Wstr(123)
      dim u as ustring = 123
      w &= 123
      u &= 123
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as LONGINT"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' concatenation( byval rhs as double )
    scope
      dim w as wstring * 50 = Wstr(3.14)
      dim u as ustring = 3.14
      w &= 3.14
      u &= 3.14
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - as DOUBLE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


  if z = 0 then
    function = 0
  else
    function = 1
  end if


end function


'***********************************************************************************************


function rtltest(byref y as wstring) as long
'***********************************************************************************************
' test the rtl string functions
' dim u  as Ustring       = "ФЫВАПР"     (Russian letters)
'***********************************************************************************************
' strptr: direkt im code ändern ?

'ggf. cv... ????
'***********************************************************************************************
dim i as long
dim n as long
dim r as long
dim x as long
dim z as long


  print "RTL functions: ",,
  x = 0


  scope
    
    '' strptr
    scope
      dim w as wstring * 50 = y
      dim u as ustring = y
      dim w1 as wstring * 50
      dim u1 as ustring 
      dim p1 as wstring ptr
      dim p2 as wstring ptr

      p1 = strptr(w)
      p2 = strptr(u)

      w1 = *p1
      u1 = *p2

      hCheckString(u1, w1)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - STRPTR (WSTRING/USTRING)"
        print "  u1: -" + u1 + "-"
        print "  w1: -" + w1 + "-"
      end if
    end scope

    scope
      dim z as zstring * 50 = y
      dim s as string = y
      dim z1 as zstring * 50
      dim s1 as string 
      dim p1 as zstring ptr
      dim p2 as zstring ptr

      p1 = strptr(z)
      p2 = strptr(s)

      z1 = *p1
      s1 = *p2

      hCheckString(s1, z1)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - STRPTR (STRING/ZSTRING)"
        print "  s: -" + hex(strptr(s), 8) + "-"
        print "  z: -" + hex(strptr(z), 8) + "-"
      end if
    end scope

    '' wchr
    scope
      dim w as wstring * 50 = wchr( 1234 )
      dim u as ustring = wchr( 1234 )
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - WCHR"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope
    
    '' wstr
    scope
      dim w as wstring * 50 = wchr( 1234 )
      dim u as ustring = wchr( 1234 )
      w = wstr(w)
      u = wstr(u)
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - WSTR"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' wspace
    scope
      dim w as wstring * 50 = wspace( 10 )
      dim u as ustring = wspace( 10 )
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - WSPACE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' wstring
    scope
      dim w as wstring * 50 = wstring( 10, 1234 )
      dim u as ustring = wstring( 10, 1234 )
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - WSTRING"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' ucase
    scope
      dim w as wstring * 50 = y & wspace(5)
      dim u as ustring = w

'ods("  u: -" + u + "-")
'ods("  u: -" + ucase(u) + "-")
'ods("  w: -" + w + "-")
'ods("  w: -" + ucase(w) + "-")

      w = "'" & ucase(w) & "'"
      u = "'" & ucase(u) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - UCASE"
        print "  u: -" + ucase(u) + "-"
        print "  w: -" + ucase(w) + "-"
      end if
    end scope

    '' lcase
    scope
      dim w as wstring * 50 = y & wspace(5)
      dim u as ustring = w

'ods("  u: -" + u + "-")
'ods("  u: -" + lcase(u) + "-")
'ods("  w: -" + w + "-")
'ods("  w: -" + lcase(w) + "-")

      w = "'" & lcase(w) & "'"
      u = "'" & lcase(u) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - LCASE"
        print "  u: -" + lcase(u) + "-"
        print "  w: -" + lcase(w) + "-"
      end if
    end scope

    '' left
    scope
      dim w as wstring * 50 = y & wspace(5)
      dim u as ustring = w
      w = "'" & left(w, 3) & "'"
      u = "'" & left(u, 3) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - LEFT"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' right
    scope
      dim w as wstring * 50 = y & wspace(5)
      dim u as ustring = w
      w = "'" & RIGHT(w, 3) & "'"
      u = "'" & RIGHT(u, 3) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - RIGHT"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' trim
    scope
      dim w as wstring * 50 = wspace(5) & y & wspace(5)
      dim u as ustring = w
      w = "'" & trim(w) & "'"
      u = "'" & trim(u) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - TRIM"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' trim any
    scope
      dim w as wstring * 50 = "12345" & y & "12345"
      dim u as ustring = w
      w = "'" & trim(w, any "1245") & "'"
      u = "'" & trim(u, any "1245") & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - TRIM"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' ltrim
    scope
      dim w as wstring * 50 = wspace(5) & y & wspace(5)
      dim u as ustring = w
      w = "'" & ltrim(w) & "'"
      u = "'" & ltrim(u) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - LTRIM"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' rtrim
    scope
      dim w as wstring * 50 = wspace(5) & y & wspace(5)
      dim u as ustring = w
      w = "'" & rtrim(w) & "'"
      u = "'" & rtrim(u) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - RTRIM"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' mid (function)
    scope
      dim w as wstring * 50 = wspace(5) & y & wspace(5)
      dim u as ustring = w
      w = "'" & mid(w, 2, 2) & "'"
      u = "'" & mid(u, 2, 2) & "'"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - MID(function)"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' mid (statement)
    scope
      dim w as wstring * 50 = wspace(5) & y & wspace(5)
      dim u as ustring = w
      mid(w, 2, 2) = "ab"
      mid(u, 2, 2) = "ab"
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - MID(statement)"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' instr
    scope
      dim w as wstring * 50 = wspace(5) & !"wstring\u4644" & wspace(5)
      dim u as ustring = w
      i = instr(w, any "gn")
      n = instr(u, any "gn")

      if i <> n then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - INSTR (look for ANY ""gn"" -> wstring:" & i & "  ustring:" & n
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' instrrev
    scope
      dim w as wstring * 50 = wspace(5) & !"wstring\u4644" & wspace(5)
      dim u as ustring = w
      i = instrrev(w, any "ri")
      n = instrrev(u, any "ri")

      if i <> n then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - INSTRREV (look for ANY ""ri"" -> wstring:" & i & "  ustring:" & n
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' lset
    scope
      dim w1 as wstring * 50 = wspace(5) & y
      dim u1 as ustring = w1
      dim w  as Wstring * 50 = wspace(25) 
      dim u  as ustring      = wspace(25) 
      lset w, w1
      lset u, u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - LSET (USTRING to USTRING)"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' lset
    scope
      dim w1 as wstring * 50 = wspace(5) & y
      dim u1 as ustring = w1
      dim w  as Wstring * 50 = wspace(25) 
      dim u  as ustring      = wspace(25) 
      lset u, w1
      lset w, u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - LSET (USTRING to WSTRING and vice versa)"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' rset
    scope
      dim w1 as wstring * 50 = y
      dim u1 as ustring = w1
      dim w  as Wstring * 50 = wspace(25) 
      dim u  as ustring      = wspace(25) 
      rset w, w1
      rset u, u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - RSET (USTRING TO USTRING)"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' rset
    scope
      dim w1 as wstring * 50 = y
      dim u1 as ustring = w1
      dim w  as Wstring * 50 = wspace(25) 
      dim u  as ustring      = wspace(25) 
      rset u, w1
      rset w, u1
      hCheckString(u, w)

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - RSET (USTRING TO WSTRING and vice versa)"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' select case
    scope
      dim w as wstring * 50 = y
      dim u as ustring = w

      i = 10
      n = 20
      select case w
        case y 
          i = 1
      end select

      select case u
        case y 
          n = 1
      end select

      if i <> n then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - SELECT CASE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = y 
      dim u as ustring = w

      i = 10
      n = 20
      select case left(w, 3)
        case left(y, 3) 
          i = 1
      end select

      select case left(u, 3)                
'      select case mid(u, 3)                
'      select case val(u)                   
'      select case right(u, 3)              
'      select case right(w, 3)              
        case left(y, 3) 
'        case mid(y, 3) 
'        case val(y)
'        case right(y, 3)
'        case right(u, 3)
          n = 1
      end select

      if i <> n then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - SELECT CASE"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' asc
    scope
      dim w as wstring * 50 = y'!"wstring\u4644"
      dim u as ustring      = y'!"wstring\u4644"

      r = 0
      for i = 1 to len(u)
        if asc(w, i) <> asc(u, i) then
          r = 1 
          exit for
        end if
      next i  

      if r = 1 then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - ASC"
        print "  u: -" + u + "-"
        print "  w: -" + w + "-"
      end if
    end scope

    '' c... conversion functions
    scope
      dim w as wstring * 50 = wstr(1)
      dim u as ustring = wstr(1)

      if cbool(w) <> cbool(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CBOOL"
        print "  u: -" & cbool(u) & "-"
        print "  w: -" & cbool(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(13)
      dim u as ustring = wstr(13)

      if cBYTE(w) <> cbYTE(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CBYTE"
        print "  u: -" & cbYTE(u) & "-"
        print "  w: -" & cbYTE(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(1357)
      dim u as ustring = wstr(1357)

      if cshort(w) <> cshort(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CSHORT"
        print "  u: -" & cshort(u) & "-"
        print "  w: -" & cshort(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(70000)
      dim u as ustring = wstr(70000)

      if CINT(w) <> CINT(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CINT"
        print "  u: -" & CINT(u) & "-"
        print "  w: -" & CINT(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(70001)
      dim u as ustring = wstr(70001)

      if CLNG(w) <> CLNG(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CLNG"
        print "  u: -" & CLNG(u) & "-"
        print "  w: -" & CLNG(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(70000000001)
      dim u as ustring = wstr(70000000001)

      if CLNGINT(w) <> CLNGINT(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CLNGINT"
        print "  u: -" & CLNGINT(u) & "-"
        print "  w: -" & CLNGINT(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(17)
      dim u as ustring = wstr(17)

      if CUBYTE(w) <> CUBYTE(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CUBYTE"
        print "  u: -" & CUBYTE(u) & "-"
        print "  w: -" & CUBYTE(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(30001)
      dim u as ustring = wstr(30001)

      if CUSHORT(w) <> CUSHORT(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CUSHORT"
        print "  u: -" & CUSHORT(u) & "-"
        print "  w: -" & CUSHORT(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(70001)
      dim u as ustring = wstr(70001)

      if CUINT(w) <> CUINT(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CUINT"
        print "  u: -" & CUINT(u) & "-"
        print "  w: -" & CUINT(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(50001)
      dim u as ustring = wstr(50001)

      if CULNG(w) <> CULNG(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CULNG"
        print "  u: -" & CULNG(u) & "-"
        print "  w: -" & CULNG(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(50000000001)
      dim u as ustring = wstr(50000000001)

      if CULNGINT(w) <> CULNGINT(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CULNGINT"
        print "  u: -" & CULNGINT(u) & "-"
        print "  w: -" & CULNGINT(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(12345.67)
      dim u as ustring = w 'wstr(12345.67)
      dim sg as single

      if CSNG(w) <> CSNG(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CSNG"
        sg = CSNG(u)
        print "  u: -" & sg & "-"
        sg = CSNG(w)
        print "  w: -" & sg & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(12345.6789)
      dim u as ustring = w 
      dim d  as double

      if CDBL(w) <> CDBL(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CDBL"
        d  = CDBL(u) 
        print "  u: -" & d & "-"
        d  = CDBL(w) 
        print "  w: -" & d & "-"
      end if
    end scope

'    scope
'      dim w as wstring * 50 = wstr(1)
'      dim u as ustring = wstr(1)
'      if CPTR(any ptr, @w) <> CPTR(any ptr, @u) + sizeof(u) then          'u is sizeof(u) further down in stack !
''***********************************************************************************************
'' test works in gas, but doesn´t apply for gcc, because u isn´t necessarily near w in stack
''***********************************************************************************************
'
'        x = 1
'        print
'        print "  ERROR (line#: " & __LINE__ & ") - CPTR"
'        print "  u: -" & CPTR(any ptr, @u) & "-"
'        print "  w: -" & CPTR(any ptr, @w) & "-"
'        print "  d: -" & sizeof(u) & "-"
'      end if
'    end scope


    scope
      dim w as wstring * 50 = wstr(12345)
      dim u as ustring = wstr(12345)

      if val(w) <> val(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - VAL"
        print "  u: -" & val(u) & "-"
        print "  w: -" & val(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(12345)
      dim u as ustring = wstr(12345)

      if valint(w) <> valint(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - valint"
        print "  u: -" & valint(u) & "-"
        print "  w: -" & valint(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(12345)
      dim u as ustring = wstr(12345)

      if vallng(w) <> vallng(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - vallng"
        print "  u: -" & vallng(u) & "-"
        print "  w: -" & vallng(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(12345)
      dim u as ustring = wstr(12345)

      if valuint(w) <> valuint(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - valuint"
        print "  u: -" & valuint(u) & "-"
        print "  w: -" & valuint(w) & "-"
      end if
    end scope

    scope
      dim w as wstring * 50 = wstr(12345)
      dim u as ustring = wstr(12345)

      if valulng(w) <> valulng(u) then
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - valulng"
        print "  u: -" & valulng(u) & "-"
        print "  w: -" & valulng(w) & "-"
      end if
    end scope


    if x = 0 then
      print "Ok!"
    else
      z = 1
    end if
  end scope


  if z = 1 then
    function = 1
  else
    function = 0
  end if
  

end function


'***********************************************************************************************


function paramtest_1(byref u as USTRING, byref w as wstring) as ustring
'***********************************************************************************************
' parameter test
'***********************************************************************************************


  function = u + w


end function


'***********************************************************************************************


function paramtest_2(byref u as USTRING, byref w as const wstring) as ustring
'***********************************************************************************************
' parameter test
'***********************************************************************************************


  function = u + w


end function


'***********************************************************************************************


function paramtest_3(byval u as USTRING, byref w as wstring) as ustring
'***********************************************************************************************
' parameter test
'***********************************************************************************************


  function = u + w


end function


'***********************************************************************************************


function paramtest_4(byval u as USTRING, byref w as const wstring) as ustring 
'***********************************************************************************************
' parameter test
'***********************************************************************************************


  function = u + w
'  function = u & w


end function


'***********************************************************************************************


function conversiontest_1(byref u as ustring, byref w as wstring) as long
'***********************************************************************************************
' parameter conversion (in)
'***********************************************************************************************
'local i as long


  if u <> w then
    function = 1
  else
    function = 0
  end if


end function


'***********************************************************************************************


function conversiontest_2(byref u as ustring, byref s as const string, byval flag as long = 0) as string
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************
dim s1 as string

  s1 = s

  if flag then
    function = u & s1
  else
    function = u + s
  end if
  

end function


'***********************************************************************************************


function conversiontest_3(byref u as ustring, byval s as string, byval flag as long = 0) as string
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  if flag then
    function = u & s
  else
    function = u + s
  end if
  

end function


'***********************************************************************************************



function conversiontest_4(byref u as ustring, byref s as string, byval flag as long = 0) as string
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  if flag then
    function = u & s
  else
    function = u + s
  end if


end function


'***********************************************************************************************


function conversiontest_5(byref u as ustring, byref w as wstring, byval flag as long = 0) as wstring ptr
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************
dim w1 as wstring * 260


  if flag then
    w1 = u & w
    function = @w1
  else
    w1 = u + w
    function = @w1
  end if


end function


'***********************************************************************************************


function conversiontest_6(byref u as ustring, byref s as string, byval flag as long = 0) as Ustring
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  if flag then
    function = u & s
  else
    function = u + s
  end if


end function


'***********************************************************************************************


function conversiontest_7(byref u as ustring, byref w as wstring, byval flag as long = 0) as Ustring
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  if flag then
    function = u & w
  else
    function = u + w
  end if


end function


'***********************************************************************************************


function paramtest(byref y as wstring) as long
'***********************************************************************************************
' test parameter passing + conversion
'***********************************************************************************************
dim n  as long
dim x  as integer
dim s  as string = y '"12345"
dim s1 as string 
dim z  as Zstring * 64 = y '"12345"
dim w  as Wstring * 64 = y '"12345"
dim w1 as Wstring * 64 
dim u  as ustring = y '"12345"
dim u1 as ustring 


  print "Parameter: ",,,
  x = 0


  u1 = paramtest_1(u, w)
  if u1 <> u + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter passing (byref, byref)"
    print u1
    print u
    print w
  end if

  u1 = paramtest_2(u, w)
  if u1 <> u + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter passing (byref, byref const)"
    print u1
    print u
    print w
  end if

  u1 = paramtest_3(u, w)
  if u1 <> u + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter passing (byval, byref)"
    print u1
    print u
    print w
  end if

  u1 = paramtest_4(u, w)
  if u1 <> u + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter passing (byval, byref const)"
    print u1
    print u
    print w
  end if


  if conversiontest_1(z, s) = 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter Conversion ZSTRING USTRING"
  end if

  if conversiontest_1(s, s) = 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter Conversion STRING USTRING"
  end if

  if conversiontest_1(w, w) = 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parameter Conversion WSTRING USTRING"
  end if

  u1 = conversiontest_2(u, s)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in: Const - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_2(u, s, 1)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in: Const - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_3(u, s)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in Byval: - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_3(u, s, 1)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in Byval: - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_4(u, s)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in Byref: - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_4(u, s, 1)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in Byref: - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_5(u, w)
  if u1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in Byref: - Return Conversion USTRING receives a WSTRING PTR"
    print u1
    print w + w
  end if

  u1 = conversiontest_5(u, w, 1)
  if u1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - in Byref: - Return Conversion USTRING receives a WSTRING PTR"
    print u1
    print w + w
  end if


  z = conversiontest_6(u, s)
  if z <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion ZSTRING receives a USTRING"
    print u1
    print s + s
  end if

  z = conversiontest_6(u, s, 1)
  if z <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion ZSTRING receives a USTRING"
    print u1
    print s + s
  end if

  s1 = conversiontest_6(u, s)
  if s1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion STRING receives a USTRING"
    print s1
    print s + s
  end if

  s1 = conversiontest_6(u, s, 1)
  if s1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion STRING receives a USTRING"
    print s1
    print s + s
  end if


  w1 = conversiontest_7(u, w)
  if w1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion WSTRING receives a USTRING"
    print w1
    print w + w
  end if

  w1 = conversiontest_7(u, w, 1)
  if w1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion WSTRING receives a USTRING"
    print w1
    print w + w
  end if


  u1 = conversiontest_7(u, w)
  if u1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion USTRING receives a USTRING"
    print u1
    print w + w
  end if

  u1 = conversiontest_7(u, w, 1)
  if u1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion USTRING receives a USTRING"
    print u1
    print w + w
  end if


  if x = 0 then
    print "Ok!"
    function = 0

  else
    function = 1
  end if


end function


'***********************************************************************************************


function helpertest(byref y as wstring, byval cc as ulong = 1, byval uflag as long = 0) as long
'***********************************************************************************************
' do exhaustive tests with all available string types (ZSTRING, STRING, WSTRING and USTRING)
' fencepost on both sides + variations in the middle, covering all options
'***********************************************************************************************
dim x as long

dim i as long
dim n as long

dim st as string

dim z  as zstring * 260 = y
dim s  as string        = y
dim w  as Wstring * 260 = y
dim u  as Ustring       = y

dim z1 as zstring * 260 
dim s1 as string        
dim w1 as Wstring * 260  
dim u1 as Ustring      



'***********************************************************************************************
' tally
'***********************************************************************************************

  print
  print "Test: " + y
  print "Tally: ",,,
  x = 0


  if uflag then goto do_wide_only
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if tally(z, ",") <> 0 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " nothing"
    print "0 - " & tally(z, ",")
  end if

  if tally(z, z) <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all"
    print "1 - " & tally(z, z)
  end if

  if tally(z, any z) <> len(z) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all any"
    print str(len(z)) & " - " & tally(z, any z)
  end if

  if tally(z, left(z, 2)) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st 
    print str(cc) & " - " & tally(z, left(z, 2))
  end if

  if tally(z, right(z, 2), 1) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (caseinsensitive)"
    print str(cc) & " - " & tally(z, right(z, 2), 1)
  end if

  if tally(z, any_, mid(z, 2, 3)) <> 3 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any)"
    print str(3 * cc) & " - " & tally(z, any_, mid(z, 2, 3))
  end if

  if tally(z, any mid(z, 2, 3)) <> 3 * cc then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any new)"
    print str(3 * cc) & " - " & tally(z, any mid(z, 2, 3))
  end if

  if tally(z, any_, mid(z, 3, 4), 1) <> 4 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any, caseinsensitive)"
    print str(4 * cc) & " - " & tally(z, any_, mid(z, 3, 4), 1)
  end if

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if tally(s, ",") <> 0 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " nothing"
    print "0 - " & tally(s, ",")
  end if

  if tally(s, s) <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all"
    print "1 - " & tally(s, s)
  end if

  if tally(s, any s) <> len(s) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all any"
    print str(len(s)) & " - " & tally(s, any s)
  end if

  if tally(s, left(s, 2)) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st 
    print str(cc) & " - " & tally(s, left(s, 2))
  end if

  if tally(s, right(s, 2), 1) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (caseinsensitive)"
    print str(cc) & " - " & tally(s, right(s, 2), 1)
  end if

  if tally(s, any_, mid(s, 2, 3)) <> 3 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any)"
    print str(3 * cc) & " - " & tally(s, any_, mid(s, 2, 3))
  end if

  if tally(s, any mid(s, 2, 3)) <> 3 * cc then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any new)"
    print str(3 * cc) & " - " & tally(s, any mid(s, 2, 3))
  end if

  if tally(s, any_, mid(s, 3, 4), 1) <> 4 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any, caseinsensitive)"
    print str(4 * cc) & " - " & tally(s, any_, mid(s, 3, 4), 1)
  end if


do_wide_only:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if tally(w, ",") <> 0 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " nothing"
    print "0 - " & tally(w, ",")
  end if

  if tally(w, w) <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all"
    print "1 - " & tally(w, w)
  end if

  if tally(w, any w) <> len(w) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all any"
    print str(len(w)) & " - " & tally(w, any w)
  end if

  if tally(w, left(w, 2)) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st 
    print str(cc) & " - " & tally(w, left(w, 2))
  end if

  if tally(w, right(w, 2), 1) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (caseinsensitive)"
    print str(cc) & " - " & tally(w, right(w, 2), 1)
  end if

  if tally(w, any_, mid(w, 2, 3)) <> 3 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any)"
    print str(3 * cc) & " - " & tally(w, any_, mid(w, 2, 3))
  end if

  if tally(w, any mid(w, 2, 3)) <> 3 * cc then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any new)"
    print str(3 * cc) & " - " & tally(w, any mid(w, 2, 3))
  end if

  if tally(w, any_, mid(w, 3, 4), 1) <> 4 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any, caseinsensitive)"
    print str(4 * cc) & " - " & tally(w, any_, mid(w, 3, 4), 1)
  end if

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if tally(u, ",") <> 0 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " nothing"
    print "0 - " & tally(u, ",")
  end if

  if tally(u, u) <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all"
    print "1 - " & tally(u, u)
  end if

  if tally(u, any u) <> len(u) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " all any"
    print str(len(u)) & " - " & tally(u, any u)
  end if

  if tally(u, left(u, 2)) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st 
    print str(cc) & " - " & tally(u, left(u, 2))
  end if

  if tally(u, right(u, 2), 1) <> 1 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (caseinsensitive)"
    print str(cc) & " - " & tally(u, right(u, 2), 1)
  end if

  if tally(u, any_, mid(u, 2, 3)) <> 3 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any)"
    print str(3 * cc) & " - " & tally(u, any_, mid(u, 2, 3))
  end if

  if tally(u, any mid(u, 2, 3)) <> 3 * cc then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any new)"
    print str(3 * cc) & " - " & tally(u, any mid(u, 2, 3))
  end if

  if tally(u, any_, mid(u, 3, 4), 1) <> 4 * cc then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Tally " & st & " (any, caseinsensitive)"
    print str(4 * cc) & " - " & tally(u, any_, mid(u, 3, 4), 1)
  end if


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' parsecount
'***********************************************************************************************


  print "Parsecount: ",,,
  x = 0


  if uflag then goto do_wide_only2
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if parsecount(z, ",") <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " nothing"
    print "1 - " & parsecount(z, ",")
  end if

  if parsecount(z, z) <> 2 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all"
    print "2 - " & parsecount(z, z)
  end if

  if parsecount(z, any z) <> len(z) + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all any"
    print str(len(z) + 1) & " - " & parsecount(z, any z)
  end if

  if parsecount(z, left(z, 2)) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st 
    print str(cc + 1) & " - " & parsecount(z, left(z, 2))
  end if

  if parsecount(z, right(z, 2), 1) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (caseinsensitive)"
    print str(cc + 1) & " - " & parsecount(z, right(z, 2), 1)
  end if

  if parsecount(z, any_, mid(z, 2, 3)) <> 3 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any)"
    print str(3 * cc + 1) & " - " & parsecount(z, any_, mid(z, 2, 3))
  end if

  if parsecount(z, any mid(z, 2, 3)) <> 3 * cc + 1 then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any new)"
    print str(3 * cc + 1) & " - " & parsecount(z, any mid(z, 2, 3))
  end if

  if parsecount(z, any_, mid(z, 3, 4), 1) <> 4 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any, caseinsensitive)"
    print str(4 * cc + 1) & " - " & parsecount(z, any_, mid(z, 3, 4), 1)
  end if

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if parsecount(s, ",") <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " nothing"
    print "1 - " & parsecount(s, ",")
  end if

  if parsecount(s, s) <> 2 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all"
    print "2 - " & parsecount(s, s)
  end if

  if parsecount(s, any s) <> len(s) + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all any"
    print str(len(s) + 1) & " - " & parsecount(s, any s)
  end if

  if parsecount(s, left(s, 2)) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st 
    print str(cc + 1) & " - " & parsecount(s, left(s, 2))
  end if

  if parsecount(s, right(s, 2), 1) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (caseinsensitive)"
    print str(cc + 1) & " - " & parsecount(s, right(s, 2), 1)
  end if

  if parsecount(s, any_, mid(s, 2, 3)) <> 3 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any)"
    print str(3 * cc + 1) & " - " & parsecount(s, any_, mid(s, 2, 3))
  end if

  if parsecount(s, any mid(s, 2, 3)) <> 3 * cc + 1 then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any new)"
    print str(3 * cc + 1) & " - " & parsecount(s, any mid(s, 2, 3))
  end if

  if parsecount(s, any_, mid(s, 3, 4), 1) <> 4 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any, caseinsensitive)"
    print str(4 * cc + 1) & " - " & parsecount(s, any_, mid(s, 3, 4), 1)
  end if

do_wide_only2:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if parsecount(w, ",") <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " nothing"
    print "1 - " & parsecount(w, ",")
  end if

  if parsecount(w, w) <> 2 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all"
    print "2 - " & parsecount(w, w)
  end if

  if parsecount(w, any w) <> len(w) + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all any"
    print str(len(w) + 1) & " - " & parsecount(w, any w)
  end if

  if parsecount(w, left(w, 2)) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st 
    print str(cc + 1) & " - " & parsecount(w, left(w, 2))
  end if

  if parsecount(w, right(w, 2), 1) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (caseinsensitive)"
    print str(cc + 1) & " - " & parsecount(w, right(w, 2), 1)
  end if

  if parsecount(w, any_, mid(w, 2, 3)) <> 3 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any)"
    print str(3 * cc + 1) & " - " & parsecount(w, any_, mid(w, 2, 3))
  end if

  if parsecount(w, any mid(w, 2, 3)) <> 3 * cc + 1 then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any new)"
    print str(3 * cc + 1) & " - " & parsecount(w, any mid(w, 2, 3))
  end if

  if parsecount(w, any_, mid(w, 3, 4), 1) <> 4 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any, caseinsensitive)"
    print str(4 * cc + 1) & " - " & parsecount(w, any_, mid(w, 3, 4), 1)
  end if

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if parsecount(u, ",") <> 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " nothing"
    print "1 - " & parsecount(u, ",")
  end if

  if parsecount(u, u) <> 2 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all"
    print "2 - " & parsecount(u, u)
  end if

  if parsecount(u, any u) <> len(u) + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parsecount " & st & " all any"
    print str(len(u) + 1) & " - " & parsecount(u, any u)
  end if

  if parsecount(u, left(u, 2)) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st 
    print str(cc + 1) & " - " & parsecount(u, left(u, 2))
  end if

  if parsecount(u, right(u, 2), 1) <> 1 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (caseinsensitive)"
    print str(cc + 1) & " - " & parsecount(u, right(u, 2), 1)
  end if

  if parsecount(u, any_, mid(u, 2, 3)) <> 3 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any)"
    print str(3 * cc + 1) & " - " & parsecount(u, any_, mid(u, 2, 3))
  end if

  if parsecount(u, any mid(u, 2, 3)) <> 3 * cc + 1 then      'future extension "any"
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any new)"
    print str(3 * cc + 1) & " - " & parsecount(u, any mid(u, 2, 3))
  end if

  if parsecount(u, any_, mid(u, 3, 4), 1) <> 4 * cc + 1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Parsecount " & st & " (any, caseinsensitive)"
    print str(4 * cc + 1) & " - " & parsecount(u, any_, mid(u, 3, 4), 1)
  end if


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' Repeat
'***********************************************************************************************


  print "Repeat_: ",,,
  x = 0


  if repeat_(0, z) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (zstring) nothing"
    print " - " & repeat_(0, z)
  end if

  if repeat_(3, z) <> z + z + z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (zstring)"
    print z & z & z & " - " & repeat_(3, z)
  end if

  if repeat_(0, s) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (string) nothing"
    print " - " & repeat_(0, s)
  end if

  if repeat_(3, s) <> s + s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (string)"
    print s & s & s & " - " & repeat_(3, s)
  end if

  if repeat_(0, w) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (wstring) nothing"
    print " - " & repeat_(0, w)
  end if

  if repeat_(3, w) <> w + w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (wstring)"
    print w & w & w & " - " & repeat_(3, w)
  end if

  if repeat_(0, u) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (ustring) nothing"
    print " - " & repeat_(0, u)
  end if

  if repeat_(3, u) <> u + u + u then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Repeat (ustring)"
    print u & u & u & " - " & repeat_(3, u)
  end if



  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if



'***********************************************************************************************
' Insert
'***********************************************************************************************


  print "Insert_: ",,,
  x = 0

  if insert_(z, "", 5) <>  z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (zstring) nothing"
    print z & " - " & insert_(z, "", 5)
  end if

  if insert_(z, "q", 1) <>  "q" + z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (zstring) start"
    print "q" + z & " - " & insert_(z, "q", 1)
  end if

  if insert_(z, "q", len(z) + 1) <>  z + "q" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (zstring) end"
    print z + "q" & " - " & insert_(z, "q", len(z) + 1)
  end if

  if insert_(z, left(z, 3), 5) <>  MID(z, 1, 4) + left(z, 3) + MID(z, 5) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (zstring)"
    print MID(z, 1, 4) + left(z, 3) + MID(z, 5) & " - " & insert_(z, left(z, 3), 5)
  end if

  if insert_(s, left(s, 3), 5) <>  MID(s, 1, 4) + left(s, 3) + MID(s, 5) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (string)"
    print MID(s, 1, 4) + left(s, 3) + MID(s, 5) & " - " & insert_(s, left(s, 3), 5)
  end if

  if insert_(w, left(w, 3), 5) <>  MID(w, 1, 4) + left(w, 3) + MID(w, 5) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (wstring)"
    print MID(w, 1, 4) + left(w, 3) + MID(w, 5) & " - " & insert_(w, left(w, 3), 5)
  end if

  if insert_(u, left(u, 3), 5) <>  MID(u, 1, 4) + left(u, 3) + MID(u, 5) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Insert (ustring)"
    print MID(u, 1, 4) + left(u, 3) + MID(u, 5) & " - " & insert_(u, left(u, 3), 5)
  end if


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' StrReverse
'***********************************************************************************************


  print "StrReverse_: ",,,
  x = 0

  if strreverse_(strreverse_(z)) <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - StrReverse (zstring)"
    print z & " - " & strreverse_(strreverse_(z))
  end if

  if strreverse_(strreverse_(s)) <> s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - StrReverse (string)"
    print s & " - " & strreverse_(strreverse_(z))
  end if

  if strreverse_(strreverse_(w)) <> w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - StrReverse (wstring)"
    print w & " - " & strreverse_(strreverse_(z))
  end if

  if strreverse_(strreverse_(u)) <> u then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - StrReverse (ustring)"
    print w & " - " & strreverse_(strreverse_(z))
  end if



  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' extract
'***********************************************************************************************


  print "Extract_: ",,,
  x = 0


  if uflag then goto do_wide_only3
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if extract_(z, "") <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " nothing"
    print z & " - " & extract_(z, "")
  end if

  if extract_(z, ",") <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " ,"
    print z & " - " & extract_(z, ",")
  end if

  if extract_(z, z) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " all"
    print " - " & extract_(z, z)
  end if

  if extract_(z, any z) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " all any"
    print " - " & extract_(z, any z)
  end if



  for i = 2 to len(z)
    if extract_(z, Mid(z, i, 1)) <> left(z, instr(z, mid(z, i, 1)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st 
      print "i: " & str(i) & "  " & left(z, instr(z, mid(z, i, 1)) - 1) & " - " & extract_(z, Mid(z, i, 1))
    end if
  next i

  for i = 1 to 7
    if extract_(z, right(z, i), 1) <> left(z, instr(ucase(z), right(ucase(z), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  left(z, instr(ucase(z), right(ucase(z), i)) - 1) & " - " & extract_(z, right(z, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(i, z, right(z, i), 1) <> mid(left(z, instr(ucase(z), right(ucase(z), i)) - 1), i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(left(z, instr(ucase(z), right(ucase(z), i)) - 1), i) & " - " & extract_(i, z, right(z, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(z, any right(z, i)) <> left(z, instr(z, any right(z, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any new)" 
      print "i: " & str(i) & "  " &  left(z, instr(z, any right(z, i)) - 1) & " - " & extract_(z, any right(z, i))
    end if
  next i

  for i = 1 to 7
    if extract_(z, any_, right(z, i)) <> left(z, instr(z, any right(z, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any)" 
      print "i: " & str(i) & "  " &  left(z, instr(z, any right(z, i)) - 1) & " - " & extract_(z, any_, right(z, i))
    end if
  next i

  for i = 1 to 7
    if extract_(z, any_, right(z, i), 1) <> left(z, instr(ucase(z), any right(ucase(z), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  left(z, instr(ucase(z), any right(ucase(z), i)) - 1) & " - " & extract_(z, any_, right(z, i), 1)
    end if
  next i


'***********************************************************************************************
st = "string"
'***********************************************************************************************

  for i = 2 to len(s)
    if extract_(s, Mid(s, i, 1)) <> left(s, instr(s, mid(s, i, 1)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st 
      print "i: " & str(i) & "  " & left(s, instr(s, mid(s, i, 1)) - 1) & " - " & extract_(s, Mid(s, i, 1))
    end if
  next i

  for i = 1 to 7
    if extract_(s, right(s, i), 1) <> left(s, instr(ucase(s), right(ucase(s), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  left(s, instr(ucase(s), right(ucase(s), i)) - 1) & " - " & extract_(s, right(s, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(i, s, right(s, i), 1) <> mid(left(s, instr(ucase(s), right(ucase(s), i)) - 1), i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(left(s, instr(ucase(s), right(ucase(s), i)) - 1), i) & " - " & extract_(i, s, right(s, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(s, any right(s, i)) <> left(s, instr(s, any right(s, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any new)" 
      print "i: " & str(i) & "  " &  left(s, instr(s, any right(s, i)) - 1) & " - " & extract_(s, any right(s, i))
    end if
  next i

  for i = 1 to 7
    if extract_(s, any_, right(s, i)) <> left(s, instr(s, any right(s, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any)" 
      print "i: " & str(i) & "  " &  left(s, instr(s, any right(s, i)) - 1) & " - " & extract_(s, any_, right(s, i))
    end if
  next i

  for i = 1 to 7
    if extract_(s, any_, right(s, i), 1) <> left(s, instr(ucase(s), any right(ucase(s), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  left(s, instr(ucase(s), any right(ucase(s), i)) - 1) & " - " & extract_(s, any_, right(s, i), 1)
    end if
  next i


do_wide_only3:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  for i = 2 to len(w)
    if extract_(w, Mid(w, i, 1)) <> left(w, instr(w, mid(w, i, 1)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st 
      print "i: " & str(i) & "  " & left(w, instr(w, mid(w, i, 1)) - 1) & " - " & extract_(w, Mid(w, i, 1))
    end if
  next i

  for i = 1 to 7
    if extract_(w, right(w, i), 1) <> left(w, instr(ucase(w), right(ucase(w), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  left(w, instr(ucase(w), right(ucase(w), i)) - 1) & " - " & extract_(w, right(w, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(i, w, right(w, i), 1) <> mid(left(w, instr(ucase(w), right(ucase(w), i)) - 1), i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(left(w, instr(ucase(w), right(ucase(w), i)) - 1), i) & " - " & extract_(i, w, right(w, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(w, any right(w, i)) <> left(w, instr(w, any right(w, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any new)" 
      print "i: " & str(i) & "  " &  left(w, instr(w, any right(w, i)) - 1) & " - " & extract_(w, any right(w, i))
    end if
  next i

  for i = 1 to 7
    if extract_(w, any_, right(w, i)) <> left(w, instr(w, any right(w, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any)" 
      print "i: " & str(i) & "  " &  left(w, instr(w, any right(w, i)) - 1) & " - " & extract_(w, any_, right(w, i))
    end if
  next i

  for i = 1 to 7
    if extract_(w, any_, right(w, i), 1) <> left(w, instr(ucase(w), any right(ucase(w), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  left(w, instr(ucase(w), any right(ucase(w), i)) - 1) & " - " & extract_(w, any_, right(w, i), 1)
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  for i = 2 to len(u)
    if extract_(u, Mid(u, i, 1)) <> left(u, instr(u, mid(u, i, 1)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st 
      print "i: " & str(i) & "  " & left(u, instr(u, mid(u, i, 1)) - 1) & " - " & extract_(u, Mid(u, i, 1))
    end if
  next i

  for i = 1 to 7
    if extract_(u, right(u, i), 1) <> left(u, instr(ucase(u), right(ucase(u), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  left(u, instr(ucase(u), right(ucase(u), i)) - 1) & " - " & extract_(u, right(u, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(i, u, right(u, i), 1) <> mid(left(u, instr(ucase(u), right(ucase(u), i)) - 1), i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(left(u, instr(ucase(u), right(ucase(u), i)) - 1), i) & " - " & extract_(i, u, right(u, i), 1)
    end if
  next i

  for i = 1 to 7
    if extract_(u, any right(u, i)) <> left(u, instr(u, any right(u, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any new)" 
      print "i: " & str(i) & "  " &  left(u, instr(u, any right(u, i)) - 1) & " - " & extract_(u, any right(u, i))
    end if
  next i

  for i = 1 to 7
    if extract_(u, any_, right(u, i)) <> left(u, instr(u, any right(u, i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (any)" 
      print "i: " & str(i) & "  " &  left(u, instr(u, any right(u, i)) - 1) & " - " & extract_(u, any_, right(u, i))
    end if
  next i

  for i = 1 to 7
    if extract_(u, any_, right(u, i), 1) <> left(u, instr(ucase(u), any right(ucase(u), i)) - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Extract " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  left(u, instr(ucase(u), any right(ucase(u), i)) - 1) & " - " & extract_(u, any_, right(u, i), 1)
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' remain
'***********************************************************************************************


  print "Remain_: ",,,
  x = 0


  if uflag then goto do_wide_only4
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if remain_(z, "") <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " nothing"
    print " - " & remain_(z, "")
  end if

  if remain_(z, z) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " all" 
    print " - " & remain_(z, z)
  end if

  if remain_(z, any z) <> mid(z, 2) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " all any" 
    print mid(z, 2) & " - " & remain_(z, any z)
  end if

  if remain_(z, any strreverse_(z)) <> mid(z, 2) then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " all any" 
    print mid(z, 2) & " - " & remain_(z, any strreverse_(z))
  end if


  for i = 2 to len(z)
    if remain_(z, Mid(z, i, 1)) <> mid(z, instr(z, mid(z, i, 1)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st 
      print "i: " & str(i) & "  " & mid(z, instr(z, mid(z, i, 1)) + 1) & " - " & remain_(z, Mid(z, i, 1))
    end if
  next i

  for i = 1 to 7
    if remain_(z, left(z, i), 1) <> mid(z, instr(ucase(z), left(ucase(z), i)) + i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(z, instr(ucase(z), left(ucase(z), i)) + i) & " - " & remain_(z, left(z, i), 1)
    end if
  next i

  for i = 4 to 7                                                                      
    if remain_(i-2, z, mid(ucase(z), i, 2), 1) <> mid(z, instr(i-2, ucase(z), mid(ucase(z), i, 2)) + 2) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(z, instr(i-2, ucase(z), mid(ucase(z), i, 2)) + 2) & " - " & remain_(i-2, z, mid(ucase(z), i, 2), 1)
    end if
  next i

  for i = 1 to 7
    if remain_(z, any strreverse_(left(z, i))) <> mid(z, instr(z, any left(z, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any new)" 
      print "i: " & str(i) & "  " &  mid(z, instr(z, any left(z, i)) + 1) & " - " & remain_(z, any strreverse_(left(z, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(z, any_, strreverse_(left(z, i))) <> mid(z, instr(z, any left(z, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any)" 
      print "i: " & str(i) & "  " &  mid(z, instr(z, any left(z, i)) + 1) & " - " & remain_(z, any_, strreverse_(left(z, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(z, any_, strreverse_(mid(z, i, 2)), 1) <> mid(z, instr(ucase(z), any mid(ucase(z), i, 2)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive any)"
      print "i: " & str(i) & "  " &  mid(z, instr(ucase(z), any mid(ucase(z), i, 2)) + 1) & " - " & remain_(z, any_, strreverse_(mid(z, i, 2)), 1)
    end if
  next i


'***********************************************************************************************
st = "string"
'***********************************************************************************************

  for i = 2 to len(s)
    if remain_(s, Mid(s, i, 1)) <> mid(s, instr(s, mid(s, i, 1)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st 
      print "i: " & str(i) & "  " & mid(s, instr(s, mid(s, i, 1)) + 1) & " - " & remain_(s, Mid(s, i, 1))
    end if
  next i

  for i = 1 to 7
    if remain_(s, left(s, i), 1) <> mid(s, instr(ucase(s), left(ucase(s), i)) + i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(s, instr(ucase(s), left(ucase(s), i)) + i) & " - " & remain_(s, left(s, i), 1)
    end if
  next i

  for i = 4 to 7                                                                      
    if remain_(i-2, s, mid(ucase(s), i, 2), 1) <> mid(s, instr(i-2, ucase(s), mid(ucase(s), i, 2)) + 2) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(s, instr(i-2, ucase(s), mid(ucase(s), i, 2)) + 2) & " - " & remain_(i-2, s, mid(ucase(s), i, 2), 1)
    end if
  next i

  for i = 1 to 7
    if remain_(s, any strreverse_(left(s, i))) <> mid(s, instr(s, any left(s, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any new)" 
      print "i: " & str(i) & "  " &  mid(s, instr(s, any left(s, i)) + 1) & " - " & remain_(s, any strreverse_(left(s, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(s, any_, strreverse_(left(s, i))) <> mid(s, instr(s, any left(s, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any)" 
      print "i: " & str(i) & "  " &  mid(s, instr(s, any left(s, i)) + 1) & " - " & remain_(s, any_, strreverse_(left(s, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(s, any_, strreverse_(mid(s, i, 2)), 1) <> mid(s, instr(ucase(s), any mid(ucase(s), i, 2)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive any)"
      print "i: " & str(i) & "  " &  mid(s, instr(ucase(s), any mid(ucase(s), i, 2)) + 1) & " - " & remain_(s, any_, strreverse_(mid(s, i, 2)), 1)
    end if
  next i


do_wide_only4:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  for i = 2 to len(w)
    if remain_(w, Mid(w, i, 1)) <> mid(w, instr(w, mid(w, i, 1)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st 
      print "i: " & str(i) & "  " & mid(w, instr(w, mid(w, i, 1)) + 1) & " - " & remain_(w, Mid(w, i, 1))
    end if
  next i

  for i = 1 to 7
    if remain_(w, left(w, i), 1) <> mid(w, instr(ucase(w), left(ucase(w), i)) + i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(w, instr(ucase(w), left(ucase(w), i)) + i) & " - " & remain_(w, left(w, i), 1)
    end if
  next i

  for i = 4 to 7                                                                      
    if remain_(i-2, w, mid(ucase(w), i, 2), 1) <> mid(w, instr(i-2, ucase(w), mid(ucase(w), i, 2)) + 2) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(w, instr(i-2, ucase(w), mid(ucase(w), i, 2)) + 2) & " - " & remain_(i-2, w, mid(ucase(w), i, 2), 1)
    end if
  next i

  for i = 1 to 7
    if remain_(w, any strreverse_(left(w, i))) <> mid(w, instr(w, any left(w, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any new)" 
      print "i: " & str(i) & "  " &  mid(w, instr(w, any left(w, i)) + 1) & " - " & remain_(w, any strreverse_(left(w, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(w, any_, strreverse_(left(w, i))) <> mid(w, instr(w, any left(w, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any)" 
      print "i: " & str(i) & "  " &  mid(w, instr(w, any left(w, i)) + 1) & " - " & remain_(w, any_, strreverse_(left(w, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(w, any_, strreverse_(mid(w, i, 2)), 1) <> mid(w, instr(ucase(w), any mid(ucase(w), i, 2)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive any)"
      print "i: " & str(i) & "  " &  mid(w, instr(ucase(w), any mid(ucase(w), i, 2)) + 1) & " - " & remain_(w, any_, strreverse_(mid(w, i, 2)), 1)
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  for i = 2 to len(u)
    if remain_(u, Mid(u, i, 1)) <> mid(u, instr(u, mid(u, i, 1)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st 
      print "i: " & str(i) & "  " & mid(u, instr(u, mid(u, i, 1)) + 1) & " - " & remain_(u, Mid(u, i, 1))
    end if
  next i

  for i = 1 to 7
    if remain_(u, left(u, i), 1) <> mid(u, instr(ucase(u), left(ucase(u), i)) + i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(u, instr(ucase(u), left(ucase(u), i)) + i) & " - " & remain_(u, left(u, i), 1)
    end if
  next i

  for i = 4 to 7                                                                      
    if remain_(i-2, u, mid(ucase(u), i, 2), 1) <> mid(u, instr(i-2, ucase(u), mid(ucase(u), i, 2)) + 2) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (start caseinsensitive)" 
      print "i: " & str(i) & "  " &  mid(u, instr(i-2, ucase(u), mid(ucase(u), i, 2)) + 2) & " - " & remain_(i-2, u, mid(ucase(u), i, 2), 1)
    end if
  next i

  for i = 1 to 7
    if remain_(u, any strreverse_(left(u, i))) <> mid(u, instr(u, any left(u, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any new)" 
      print "i: " & str(i) & "  " &  mid(u, instr(u, any left(u, i)) + 1) & " - " & remain_(u, any strreverse_(left(u, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(u, any_, strreverse_(left(u, i))) <> mid(u, instr(u, any left(u, i)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (any)" 
      print "i: " & str(i) & "  " &  mid(u, instr(u, any left(u, i)) + 1) & " - " & remain_(u, any_, strreverse_(left(u, i)))
    end if
  next i

  for i = 1 to 7
    if remain_(u, any_, strreverse_(mid(u, i, 2)), 1) <> mid(u, instr(ucase(u), any mid(ucase(u), i, 2)) + 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - Remain " & st & " (caseinsensitive any)"
      print "i: " & str(i) & "  " &  mid(u, instr(ucase(u), any mid(ucase(u), i, 2)) + 1) & " - " & remain_(u, any_, strreverse_(mid(u, i, 2)), 1)
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' remove
'***********************************************************************************************


  print "Remove_: ",,,
  x = 0


  if uflag then goto do_wide_only5
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if remove_(z, "") <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - remove nothing " & st 
    print z & " - " & remove_(z, "")
  end if

  if remove_(z, z) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - remove all " & st 
    print "" & " - " & remove_(z, z)
  end if

  if remove_(z, any z) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - remove all any " & st 
    print "" & " - " & remove_(z, any z)
  end if

  for i = 2 to len(z)/2 - 2
    if remove_(z, Mid(z, i, len(z) - i*2)) <> mid(z, 1, i-1) & mid(z, len(z) - i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st 
      print "i: " & str(i) & "  " & mid(z, 1, i-1) & mid(z, len(z) - i) & " - " & remove_(z, Mid(z, i, len(z) - i*2))
    end if
  next i


  for i = 1 to 7
    if len(remove_(z, left(z, i))) <> len(z) - tally(z, left(z, i)) * len(left(z, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st
      print "i: " & str(i) & "  " &  z & " - remove " & left(z, i) & " - result: " & remove_(z, left(z, i))
    end if
  next i

  for i = 1 to 7
    if len(remove_(z, left(z, i), 1)) <> len(z) - tally(z, left(z, i), 1) * len(left(z, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  z & " - remove " & ucase(left(z, i)) & " - result: " & remove_(z, left(z, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(z, any left(z, i), 1)) <> len(z) - tally(z, any left(z, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  z & " - remove any " & ucase(left(z, i)) & " - result: " & remove_(z, any left(z, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(z, any strreverse_(left(z, i)), 1)) <> len(z) - tally(z, any left(z, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  z & " - remove any " & strreverse_(ucase(left(z, i))) & " - result: " & remove_(z, any left(z, i), 1)
    end if
  next i

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  for i = 2 to len(s)/2 - 2
    if remove_(s, Mid(s, i, len(s) - i*2)) <> mid(s, 1, i-1) & mid(s, len(s) - i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st 
      print "i: " & str(i) & "  " & mid(s, 1, i-1) & mid(s, len(s) - i) & " - " & remove_(s, Mid(s, i, len(s) - i*2))
    end if
  next i


  for i = 1 to 7
    if len(remove_(s, left(s, i))) <> len(s) - tally(s, left(s, i)) * len(left(s, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st
      print "i: " & str(i) & "  " &  s & " - remove " & left(s, i) & " - result: " & remove_(s, left(s, i))
    end if
  next i

  for i = 1 to 7
    if len(remove_(s, left(s, i), 1)) <> len(s) - tally(s, left(s, i), 1) * len(left(s, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  s & " - remove " & ucase(left(s, i)) & " - result: " & remove_(s, left(s, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(s, any left(s, i), 1)) <> len(s) - tally(s, any left(s, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  s & " - remove any " & ucase(left(s, i)) & " - result: " & remove_(s, any left(s, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(s, any strreverse_(left(s, i)), 1)) <> len(s) - tally(s, any left(s, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  s & " - remove any " & strreverse_(ucase(left(s, i))) & " - result: " & remove_(s, any left(s, i), 1)
    end if
  next i

do_wide_only5:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  for i = 2 to len(w)/2 - 2
    if remove_(w, Mid(w, i, len(w) - i*2)) <> mid(w, 1, i-1) & mid(w, len(w) - i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st 
      print "i: " & str(i) & "  " & mid(w, 1, i-1) & mid(w, len(w) - i) & " - " & remove_(w, Mid(w, i, len(w) - i*2))
    end if
  next i


  for i = 1 to 7
    if len(remove_(w, left(w, i))) <> len(w) - tally(w, left(w, i)) * len(left(w, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st
      print "i: " & str(i) & "  " &  w & " - remove " & left(w, i) & " - result: " & remove_(w, left(w, i))
    end if
  next i

  for i = 1 to 7
    if len(remove_(w, left(w, i), 1)) <> len(w) - tally(w, left(w, i), 1) * len(left(w, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  w & " - remove " & ucase(left(w, i)) & " - result: " & remove_(w, left(w, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(w, any left(w, i), 1)) <> len(w) - tally(w, any left(w, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  w & " - remove any " & ucase(left(w, i)) & " - result: " & remove_(w, any left(w, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(w, any strreverse_(left(w, i)), 1)) <> len(w) - tally(w, any left(w, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  w & " - remove any " & strreverse_(ucase(left(w, i))) & " - result: " & remove_(w, any left(w, i), 1)
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  for i = 2 to len(u)/2 - 2
    if remove_(u, Mid(u, i, len(u) - i*2)) <> mid(u, 1, i-1) & mid(u, len(u) - i) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st 
      print "i: " & str(i) & "  " & mid(u, 1, i-1) & mid(u, len(u) - i) & " - " & remove_(u, Mid(u, i, len(u) - i*2))
    end if
  next i


  for i = 1 to 7
    if len(remove_(u, left(u, i))) <> len(u) - tally(u, left(u, i)) * len(left(u, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st
      print "i: " & str(i) & "  " &  u & " - remove " & left(u, i) & " - result: " & remove_(u, left(u, i))
    end if
  next i

  for i = 1 to 7
    if len(remove_(u, left(u, i), 1)) <> len(u) - tally(u, left(u, i), 1) * len(left(u, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive)" 
      print "i: " & str(i) & "  " &  u & " - remove " & ucase(left(u, i)) & " - result: " & remove_(u, left(u, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(u, any left(u, i), 1)) <> len(u) - tally(u, any left(u, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  u & " - remove any " & ucase(left(u, i)) & " - result: " & remove_(u, any left(u, i), 1)
    end if
  next i

  for i = 1 to 7
    if len(remove_(u, any strreverse_(left(u, i)), 1)) <> len(u) - tally(u, any left(u, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - remove " & st & " (caseinsensitive any)" 
      print "i: " & str(i) & "  " &  u & " - remove any " & strreverse_(ucase(left(u, i))) & " - result: " & remove_(u, any left(u, i), 1)
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' replace
'***********************************************************************************************


  print "Replace_: ",,,
  x = 0


  if uflag then goto do_wide_only6
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if replace_(z, z, "") <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with nothing " & st 
    print " - " & replace_(z, z, "")
  end if

  if replace_(z, "", "asdf") <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace nothing " & st 
    print z & " - " & replace_(z, z, "")
  end if

  if replace_(z, z, z) <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with all " & st 
    print z & " - " & replace_(z, z, z)
  end if

  z1 = left(z, 4)
  if replace_(z1, any z1, z1) <> z1 + z1 + z1 + z1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all any with all " & st 
    print z1 + z1 + z1 + z1 & " - " & replace_(z1, any z1, z1)
  end if

  for i = 1 to 7
    if replace_(z, left(z, i), "") <> remove_(z, left(z, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing " & st
      print "i: " & str(i) & "  " &  remove_(z, left(z, i)) & " - " & replace_(z, left(z, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(z, any left(z, i), "") <> remove_(z, any left(z, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any " & st
      print "i: " & str(i) & "  " &  remove_(z, any left(z, i)) & " - " & replace_(z, any left(z, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(z, any left(z, i), "", 1) <> remove_(z, any left(z, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any caseinsensitive " & st
      print "i: " & str(i) & "  " &  remove_(z, any left(z, i), 1) & " - " & replace_(z, any left(z, i), "",1)
    end if
  next i

  for i = 1 to 7
    if replace_(z, "," "asdf", 1) <> z then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with not found " & st
      print "i: " & str(i) & "  " &  z & " - " & replace_(z, any left(z, i), "",1)
    end if
  next i

  for i = 1 to 7
    if len(replace_(z, mid(z, i, 3), "x", 1)) <> len(z) - tally(z, mid(z, i, 3)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> " & st
      print "i: " & str(i) & "  " &  len(z) - tally(z, mid(z, i, 3)) * 2 & " - " & len(replace_(z, mid(z, i, 3), "x", 1))
    end if
  next i

  for i = 1 to 17
    if len(replace_(z, mid(z, i, 4), "xx", 1)) <> len(z) - tally(z, mid(z, i, 4)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <xx> " & st
      print "i: " & str(i) & "  " &  len(z) - tally(z, mid(z, i, 4)) * 2 & " - " & len(replace_(z, mid(z, i, 4), "xx", 1))
    end if
  next i

  for i = 1 to 7
    if len(replace_(z, any mid(z, i, 4), "xx", 1)) <> len(z) + tally(ucase(z), any mid(ucase(z), i, 4)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> any caseinsensitive " & st
      print "i: " & str(i) & "  " &  len(z) + tally(ucase(z), any mid(ucase(z), i, 4)) & " - " & len(replace_(z, any mid(z, i, 4), "xx", 1))
    end if
  next i

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if replace_(s, s, "") <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with nothing " & st 
    print " - " & replace_(s, s, "")
  end if

  if replace_(s, "", "asdf") <> s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace nothing " & st 
    print s & " - " & replace_(s, s, "")
  end if

  if replace_(s, s, s) <> s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with all " & st 
    print s & " - " & replace_(s, s, s)
  end if

  s1 = left(s, 4)
  if replace_(s1, any s1, s1) <> s1 + s1 + s1 + s1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all any with all " & st 
    print s1 + s1 + s1 + s1 & " - " & replace_(s1, any s1, s1)
  end if

  for i = 1 to 7
    if replace_(s, left(s, i), "") <> remove_(s, left(s, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing " & st
      print "i: " & str(i) & "  " &  remove_(s, left(s, i)) & " - " & replace_(s, left(s, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(s, any left(s, i), "") <> remove_(s, any left(s, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any " & st
      print "i: " & str(i) & "  " &  remove_(s, any left(s, i)) & " - " & replace_(s, any left(s, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(s, any left(s, i), "", 1) <> remove_(s, any left(s, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any caseinsensitive " & st
      print "i: " & str(i) & "  " &  remove_(s, any left(s, i), 1) & " - " & replace_(s, any left(s, i), "",1)
    end if
  next i

  for i = 1 to 7
    if replace_(s, "," "asdf", 1) <> s then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with not found " & st
      print "i: " & str(i) & "  " &  s & " - " & replace_(s, any left(s, i), "",1)
    end if
  next i

  for i = 1 to 7
    if len(replace_(s, mid(s, i, 3), "x", 1)) <> len(s) - tally(s, mid(s, i, 3)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> " & st
      print "i: " & str(i) & "  " &  len(s) - tally(s, mid(s, i, 3)) * 2 & " - " & len(replace_(s, mid(s, i, 3), "x", 1))
    end if
  next i

  for i = 1 to 17
    if len(replace_(s, mid(s, i, 4), "xx", 1)) <> len(s) - tally(s, mid(s, i, 4)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <xx> " & st
      print "i: " & str(i) & "  " &  len(s) - tally(s, mid(s, i, 4)) * 2 & " - " & len(replace_(s, mid(s, i, 4), "xx", 1))
    end if
  next i

  for i = 1 to 7
    if len(replace_(s, any mid(s, i, 4), "xx", 1)) <> len(s) + tally(ucase(s), any mid(ucase(s), i, 4)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> any caseinsensitive " & st
      print "i: " & str(i) & "  " &  len(s) + tally(ucase(s), any mid(ucase(s), i, 4)) & " - " & len(replace_(s, any mid(s, i, 4), "xx", 1))
    end if
  next i

do_wide_only6:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if replace_(w, w, "") <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with nothing " & st 
    print " - " & replace_(w, w, "")
  end if

  if replace_(w, "", "asdf") <> w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace nothing " & st 
    print w & " - " & replace_(w, w, "")
  end if

  if replace_(w, w, w) <> w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with all " & st 
    print w & " - " & replace_(w, w, w)
  end if

  w1 = left(w, 4)
  if replace_(w1, any w1, w1) <> w1 + w1 + w1 + w1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all any with all " & st 
    print w1 + w1 + w1 + w1 & " - " & replace_(w1, any w1, w1)
  end if

  for i = 1 to 7
    if replace_(w, left(w, i), "") <> remove_(w, left(w, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing " & st
      print "i: " & str(i) & "  " &  remove_(w, left(w, i)) & " - " & replace_(w, left(w, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(w, any left(w, i), "") <> remove_(w, any left(w, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any " & st
      print "i: " & str(i) & "  " &  remove_(w, any left(w, i)) & " - " & replace_(w, any left(w, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(w, any left(w, i), "", 1) <> remove_(w, any left(w, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any caseinsensitive " & st
      print "i: " & str(i) & "  " &  remove_(w, any left(w, i), 1) & " - " & replace_(w, any left(w, i), "",1)
    end if
  next i

  for i = 1 to 7
    if replace_(w, "," "asdf", 1) <> w then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with not found " & st
      print "i: " & str(i) & "  " &  w & " - " & replace_(w, any left(w, i), "",1)
    end if
  next i

  for i = 1 to 7
    if len(replace_(w, mid(w, i, 3), "x", 1)) <> len(w) - tally(w, mid(w, i, 3)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> " & st
      print "i: " & str(i) & "  " &  len(w) - tally(w, mid(w, i, 3)) * 2 & " - " & len(replace_(w, mid(w, i, 3), "x", 1))
    end if
  next i

  for i = 1 to 17
    if len(replace_(w, mid(w, i, 4), "xx", 1)) <> len(w) - tally(w, mid(w, i, 4)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <xx> " & st
      print "i: " & str(i) & "  " &  len(w) - tally(w, mid(w, i, 4)) * 2 & " - " & len(replace_(w, mid(w, i, 4), "xx", 1))
    end if
  next i

  for i = 1 to 7
    if len(replace_(w, any mid(w, i, 4), "xx", 1)) <> len(w) + tally(ucase(w), any mid(ucase(w), i, 4)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> any caseinsensitive " & st
      print "i: " & str(i) & "  " &  len(w) + tally(ucase(w), any mid(ucase(w), i, 4)) & " - " & len(replace_(w, any mid(w, i, 4), "xx", 1))
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if replace_(u, u, "") <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with nothing " & st 
    print " - " & replace_(u, u, "")
  end if

  if replace_(u, "", "asdf") <> u then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace nothing " & st 
    print u & " - " & replace_(u, u, "")
  end if

  if replace_(u, u, u) <> u then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all with all " & st 
    print u & " - " & replace_(u, u, u)
  end if

  u1 = left(u, 4)
  if replace_(u1, any u1, u1) <> u1 + u1 + u1 + u1 then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - replace all any with all " & st 
    print u1 + u1 + u1 + u1 & " - " & replace_(u1, any u1, u1)
  end if

  for i = 1 to 7
    if replace_(u, left(u, i), "") <> remove_(u, left(u, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing " & st
      print "i: " & str(i) & "  " &  remove_(u, left(u, i)) & " - " & replace_(u, left(u, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(u, any left(u, i), "") <> remove_(u, any left(u, i)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any " & st
      print "i: " & str(i) & "  " &  remove_(u, any left(u, i)) & " - " & replace_(u, any left(u, i), "")
    end if
  next i

  for i = 1 to 7
    if replace_(u, any left(u, i), "", 1) <> remove_(u, any left(u, i), 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with nothing any caseinsensitive " & st
      print "i: " & str(i) & "  " &  remove_(u, any left(u, i), 1) & " - " & replace_(u, any left(u, i), "",1)
    end if
  next i

  for i = 1 to 7
    if replace_(u, "," "asdf", 1) <> u then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with not found " & st
      print "i: " & str(i) & "  " &  u & " - " & replace_(u, any left(u, i), "",1)
    end if
  next i

  for i = 1 to 7
    if len(replace_(u, mid(u, i, 3), "x", 1)) <> len(u) - tally(u, mid(u, i, 3)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> " & st
      print "i: " & str(i) & "  " &  len(u) - tally(u, mid(u, i, 3)) * 2 & " - " & len(replace_(u, mid(u, i, 3), "x", 1))
    end if
  next i

  for i = 1 to 17
    if len(replace_(u, mid(u, i, 4), "xx", 1)) <> len(u) - tally(u, mid(u, i, 4)) * 2 then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <xx> " & st
      print "i: " & str(i) & "  " &  len(u) - tally(u, mid(u, i, 4)) * 2 & " - " & len(replace_(u, mid(u, i, 4), "xx", 1))
    end if
  next i

  for i = 1 to 7
    if len(replace_(u, any mid(u, i, 4), "xx", 1)) <> len(u) + tally(ucase(u), any mid(ucase(u), i, 4)) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - replace with <x> any caseinsensitive " & st
      print "i: " & str(i) & "  " &  len(u) + tally(ucase(u), any mid(ucase(u), i, 4)) & " - " & len(replace_(u, any mid(u, i, 4), "xx", 1))
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' parse
'***********************************************************************************************


  print "parse_: ",,,
  x = 0


  if uflag then goto do_wide_only7
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if parse_(z, 0) <> "" then                          'outside -> must return ""
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 0, delimiter not present " & st 
    print " - " & parse_(z, 0)
  end if

  if parse_(z, 1) <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print z & " - " & parse_(z, 1)
  end if

  if parse_(z, 2) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter not present " & st 
    print " - " & parse_(z, 2)
  end if

  if parse_(z, "", 1) <> z then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print z & " - " & parse_(z, 1)
  end if

  for i = 1 to 7
    if parse_(z, left(z, i), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(z, left(z, i), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(z, any strreverse_(left(z, i)), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse any 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(z, any strreverse_(left(z, i)), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(z, left(z, i), 2) <> mid(z, i+1, instr(i+1, z, left(z, i)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(z, i+1, instr(i+1, z, left(z, i)) - i - 1) & " - " & parse_(z, left(z, i), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(z, mid(z, i, 1), 2) <> mid(z, i+1, instr(i+1, z, mid(z, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(z, i+1, instr(i+1, z, mid(z, i, 1)) - i - 1) & " - " & parse_(z, mid(z, i, 1), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(z, any strreverse_(mid(z, i, 1)), 2) <> mid(z, i+1, instr(i+1, z, mid(z, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(z, i+1, instr(i+1, z, mid(z, i, 1)) - i - 1) & " - " & parse_(z, any strreverse_(mid(z, i, 1)), 2)
    end if
  next i

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if parse_(s, 0) <> "" then                          'outside -> must return ""
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 0, delimiter not present " & st 
    print " - " & parse_(s, 0)
  end if

  if parse_(s, 1) <> s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print s & " - " & parse_(s, 1)
  end if

  if parse_(s, 2) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter not present " & st 
    print " - " & parse_(s, 2)
  end if

  if parse_(s, "", 1) <> s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print s & " - " & parse_(s, 1)
  end if

  for i = 1 to 7
    if parse_(s, left(s, i), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(s, left(s, i), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(s, any strreverse_(left(s, i)), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse any 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(s, any strreverse_(left(s, i)), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(s, left(s, i), 2) <> mid(s, i+1, instr(i+1, s, left(s, i)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(s, i+1, instr(i+1, s, left(s, i)) - i - 1) & " - " & parse_(s, left(s, i), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(s, mid(s, i, 1), 2) <> mid(s, i+1, instr(i+1, s, mid(s, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(s, i+1, instr(i+1, s, mid(s, i, 1)) - i - 1) & " - " & parse_(s, mid(s, i, 1), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(s, any strreverse_(mid(s, i, 1)), 2) <> mid(s, i+1, instr(i+1, s, mid(s, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(s, i+1, instr(i+1, s, mid(s, i, 1)) - i - 1) & " - " & parse_(s, any strreverse_(mid(s, i, 1)), 2)
    end if
  next i

do_wide_only7:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if parse_(w, 0) <> "" then                          'outside -> must return ""
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 0, delimiter not present " & st 
    print " - " & parse_(w, 0)
  end if

  if parse_(w, 1) <> w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print w & " - " & parse_(w, 1)
  end if

  if parse_(w, 2) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter not present " & st 
    print " - " & parse_(w, 2)
  end if

  if parse_(w, "", 1) <> w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print w & " - " & parse_(w, 1)
  end if

  for i = 1 to 7
    if parse_(w, left(w, i), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(w, left(w, i), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(w, any strreverse_(left(w, i)), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse any 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(w, any strreverse_(left(w, i)), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(w, left(w, i), 2) <> mid(w, i+1, instr(i+1, w, left(w, i)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(w, i+1, instr(i+1, w, left(w, i)) - i - 1) & " - " & parse_(w, left(w, i), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(w, mid(w, i, 1), 2) <> mid(w, i+1, instr(i+1, w, mid(w, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(w, i+1, instr(i+1, w, mid(w, i, 1)) - i - 1) & " - " & parse_(w, mid(w, i, 1), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(w, any strreverse_(mid(w, i, 1)), 2) <> mid(w, i+1, instr(i+1, w, mid(w, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(w, i+1, instr(i+1, w, mid(w, i, 1)) - i - 1) & " - " & parse_(w, any strreverse_(mid(w, i, 1)), 2)
    end if
  next i


'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if parse_(u, 0) <> "" then                          'outside -> must return ""
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 0, delimiter not present " & st 
    print " - " & parse_(u, 0)
  end if

  if parse_(u, 1) <> u then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print u & " - " & parse_(u, 1)
  end if

  if parse_(u, 2) <> "" then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter not present " & st 
    print " - " & parse_(u, 2)
  end if

  if parse_(u, "", 1) <> u then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter not present " & st 
    print u & " - " & parse_(u, 1)
  end if

  for i = 1 to 7
    if parse_(u, left(u, i), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(u, left(u, i), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(u, any strreverse_(left(u, i)), 1) <> "" then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse any 1, delimiter = start " & st 
      print "i: " & str(i) & "  " & " - " & parse_(u, any strreverse_(left(u, i)), 1)
    end if
  next i

  for i = 1 to 7
    if parse_(u, left(u, i), 2) <> mid(u, i+1, instr(i+1, u, left(u, i)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(u, i+1, instr(i+1, u, left(u, i)) - i - 1) & " - " & parse_(u, left(u, i), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(u, mid(u, i, 1), 2) <> mid(u, i+1, instr(i+1, u, mid(u, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(u, i+1, instr(i+1, u, mid(u, i, 1)) - i - 1) & " - " & parse_(u, mid(u, i, 1), 2)
    end if
  next i

  for i = 2 to 7
    if parse_(u, any strreverse_(mid(u, i, 1)), 2) <> mid(u, i+1, instr(i+1, u, mid(u, i, 1)) - i - 1) then
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - parse 2, delimiter = start " & st 
      print "i: " & str(i) & "  " & mid(u, i+1, instr(i+1, u, mid(u, i, 1)) - i - 1) & " - " & parse_(u, any strreverse_(mid(u, i, 1)), 2)
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' rset
'***********************************************************************************************


  print "rset_: ",,,
  x = 0


  if uflag then goto do_wide_only8
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if rset_(z, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 0 " & st 
    print " - " & rset_(z, 0)
  end if

  if rset_(z, 25) <> right(space(25) + z, 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 25 " & st 
    print right(space(25) + z, 25) & " - " & rset_(z, 25)
  end if

  for i = 1 to 80
    if rset_(z, i) <> right(space(i) + z, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(space(i) + z, i) & " - " & rset_(z, i)
    end if
  next i

  for i = 1 to 80
    if Rset_(z, i, "x") <> right(string(i, asc("x")) + z, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(z + string(i, asc("x")) + z, i) & " - " & rset_(z, i, "x")
    end if
  next i

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if rset_(s, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 0 " & st 
    print " - " & rset_(s, 0)
  end if

  if rset_(s, 25) <> right(space(25) + s, 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 25 " & st 
    print right(space(25) + s, 25) & " - " & rset_(s, 25)
  end if

  for i = 1 to 80
    if rset_(s, i) <> right(space(i) + s, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(space(i) + s, i) & " - " & rset_(s, i)
    end if
  next i

  for i = 1 to 80
    if Rset_(s, i, "x") <> right(string(i, asc("x")) + s, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(s + string(i, asc("x")) + s, i) & " - " & rset_(s, i, "x")
    end if
  next i


do_wide_only8:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if rset_(w, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 0 " & st 
    print " - " & rset_(w, 0)
  end if

  if rset_(w, 25) <> right(space(25) + w, 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 25 " & st 
    print right(space(25) + w, 25) & " - " & rset_(w, 25)
  end if

  for i = 1 to 80
    if rset_(w, i) <> right(space(i) + w, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(space(i) + w, i) & " - " & rset_(w, i)
    end if
  next i

  for i = 1 to 80
    if Rset_(w, i, "x") <> right(string(i, asc("x")) + w, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(w + string(i, asc("x")) + w, i) & " - " & rset_(w, i, "x")
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if rset_(u, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 0 " & st 
    print " - " & rset_(u, 0)
  end if

  if rset_(u, 25) <> right(space(25) + u, 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - rset 25 " & st 
    print right(space(25) + u, 25) & " - " & rset_(u, 25)
  end if

  for i = 1 to 80
    if rset_(u, i) <> right(space(i) + u, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(space(i) + u, i) & " - " & rset_(u, i)
    end if
  next i

  for i = 1 to 80
    if Rset_(u, i, "x") <> right(string(i, asc("x")) + u, i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - rset " & st 
      print "i: " & str(i) & "  " & right(u + string(i, asc("x")) + u, i) & " - " & rset_(u, i, "x")
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' lset
'***********************************************************************************************


  print "lset_: ",,,
  x = 0


  if uflag then goto do_wide_only9
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if lset_(z, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 0 " & st 
    print " - " & lset_(z, 0)
  end if

  if lset_(z, 25) <> left(z + space(25), 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 25 " & st 
    print left(z + space(25), 25) & " - " & lset_(z, 25)
  end if

  for i = 1 to 80
    if lset_(z, i) <> left(z + space(i), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(z + space(i), i) & " - " & lset_(z, i)
    end if
  next i

  for i = 1 to 80
    if lset_(z, i, "x") <> left(z + string(i, asc("x")), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(z + string(i, asc("x")), i) & " - " & lset_(z, i, "x")
    end if
  next i

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if lset_(s, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 0 " & st 
    print " - " & lset_(s, 0)
  end if

  if lset_(s, 25) <> left(s + space(25), 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 25 " & st 
    print left(s + space(25), 25) & " - " & lset_(s, 25)
  end if

  for i = 1 to 80
    if lset_(s, i) <> left(s + space(i), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(s + space(i), i) & " - " & lset_(s, i)
    end if
  next i

  for i = 1 to 80
    if lset_(s, i, "x") <> left(s + string(i, asc("x")), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(s + string(i, asc("x")), i) & " - " & lset_(s, i, "x")
    end if
  next i

do_wide_only9:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if lset_(z, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 0 " & st 
    print " - " & lset_(z, 0)
  end if

  if lset_(z, 25) <> left(z + space(25), 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 25 " & st 
    print left(z + space(25), 25) & " - " & lset_(z, 25)
  end if

  for i = 1 to 80
    if lset_(z, i) <> left(z + space(i), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(z + space(i), i) & " - " & lset_(z, i)
    end if
  next i

  for i = 1 to 80
    if lset_(z, i, "x") <> left(z + string(i, asc("x")), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(z + string(i, asc("x")), i) & " - " & lset_(z, i, "x")
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if lset_(u, 0) <> "" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 0 " & st 
    print " - " & lset_(u, 0)
  end if

  if lset_(u, 25) <> left(u + space(25), 25) then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - lset 25 " & st 
    print left(u + space(25), 25) & " - " & lset_(u, 25)
  end if

  for i = 1 to 80
    if lset_(u, i) <> left(u + space(i), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(u + space(i), i) & " - " & lset_(u, i)
    end if
  next i

  for i = 1 to 80
    if lset_(u, i, "x") <> left(u + string(i, asc("x")), i) then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - lset " & st 
      print "i: " & str(i) & "  " & left(u + string(i, asc("x")), i) & " - " & lset_(u, i, "x")
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' shrink
'***********************************************************************************************


  print "shrink_: ",,,
  x = 0


  if uflag then goto do_wide_only10
'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  if shrink_(z) <> z then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink nothing " & st 
    print " - " & shrink_(z)
  end if

  if shrink_(z + space(25)) <> z then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 spaces trailing " & st 
    print z & " - " & shrink_(z, space(25))
  end if

  if shrink_(space(25) + z) <> z then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading spaces " & st 
    print z & " - " & shrink_(space(25) +z)
  end if

  if shrink_(space(25) + z + space(25)) <> z then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading and trailing spaces " & st 
    print z & " - " & shrink_(space(25) +z + space(25))
  end if

  for i = 2 to 7
    z1= left(z, i) + space(3) + mid(z, i+1)
    
    if tally(shrink_(z1), " ") <> tally(z, " ") + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink spaces inside " & st 
      print "i: " & str(i) & "  " & tally(z, " ") + 1 & " - " & tally(shrink_(z1), " ")
    end if
  next i

  for i = 2 to 7
    z1= left(z, 2) + string(i, 88) + mid(z, 3)
    
    if len(shrink_(z1, "X")) <> len(z) + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(z) + 1 & " - " & len(shrink_(z1, "X"))
    end if
  next i

  for i = 2 to 7
    z1= left(z, 2) + string(i, 88) + mid(z, 3, 2) + string(4, 88) + mid(z, 5)
    
    if len(shrink_(z1, "X")) <> len(z) + 2 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(z) + 2 & " - " & len(shrink_(z1, "X"))
    end if
  next i


'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if shrink_(s) <> s then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink nothing " & st 
    print " - " & shrink_(s)
  end if

  if shrink_(s + space(25)) <> s then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 spaces trailing " & st 
    print s & " - " & shrink_(s, space(25))
  end if

  if shrink_(space(25) + s) <> s then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading spaces " & st 
    print s & " - " & shrink_(space(25) +s)
  end if

  if shrink_(space(25) + s + space(25)) <> s then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading and trailing spaces " & st 
    print s & " - " & shrink_(space(25) +s + space(25))
  end if

  for i = 2 to 7
    s1= left(s, i) + space(3) + mid(s, i+1)
    
    if tally(shrink_(s1), " ") <> tally(s, " ") + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink spaces inside " & st 
      print "i: " & str(i) & "  " & tally(s, " ") + 1 & " - " & tally(shrink_(s1), " ")
    end if
  next i

  for i = 2 to 7
    s1= left(s, 2) + string(i, 88) + mid(s, 3)
    
    if len(shrink_(s1, "X")) <> len(s) + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(s) + 1 & " - " & len(shrink_(s1, "X"))
    end if
  next i

  for i = 2 to 7
    s1= left(s, 2) + string(i, 88) + mid(s, 3, 2) + string(4, 88) + mid(s, 5)
    
    if len(shrink_(s1, "X")) <> len(s) + 2 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(s) + 2 & " - " & len(shrink_(s1, "X"))
    end if
  next i


do_wide_only10:
'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if shrink_(w) <> w then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink nothing " & st 
    print " - " & shrink_(w)
  end if

  if shrink_(w + space(25)) <> w then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 spaces trailing " & st 
    print w & " - " & shrink_(w, space(25))
  end if

  if shrink_(space(25) + w) <> w then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading spaces " & st 
    print w & " - " & shrink_(space(25) +w)
  end if

  if shrink_(space(25) + w + space(25)) <> w then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading and trailing spaces " & st 
    print w & " - " & shrink_(space(25) +w + space(25))
  end if

  for i = 2 to 7
    w1= left(w, i) + space(3) + mid(w, i+1)
    
    if tally(shrink_(w1), " ") <> tally(w, " ") + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink spaces inside " & st 
      print "i: " & str(i) & "  " & tally(w, " ") + 1 & " - " & tally(shrink_(w1), " ")
    end if
  next i

  for i = 2 to 7
    w1= left(w, 2) + string(i, 88) + mid(w, 3)
    
    if len(shrink_(w1, "X")) <> len(w) + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(w) + 1 & " - " & len(shrink_(w1, "X"))
    end if
  next i

  for i = 2 to 7
    w1= left(w, 2) + string(i, 88) + mid(w, 3, 2) + string(4, 88) + mid(w, 5)
    
    if len(shrink_(w1, "X")) <> len(w) + 2 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(w) + 2 & " - " & len(shrink_(w1, "X"))
    end if
  next i

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if shrink_(u) <> u then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink nothing " & st 
    print " - " & shrink_(u)
  end if

  if shrink_(u + space(25)) <> u then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 spaces trailing " & st 
    print u & " - " & shrink_(u, space(25))
  end if

  if shrink_(space(25) + u) <> u then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading spaces " & st 
    print u & " - " & shrink_(space(25) +u)
  end if

  if shrink_(space(25) + u + space(25)) <> u then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - shrink 25 leading and trailing spaces " & st 
    print u & " - " & shrink_(space(25) +u + space(25))
  end if

  for i = 2 to 7
    u1= left(u, i) + space(3) + mid(u, i+1)
    
    if tally(shrink_(u1), " ") <> tally(u, " ") + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink spaces inside " & st 
      print "i: " & str(i) & "  " & tally(u, " ") + 1 & " - " & tally(shrink_(u1), " ")
    end if
  next i

  for i = 2 to 7
    u1= left(u, 2) + string(i, 88) + mid(u, 3)
    
    if len(shrink_(u1, "X")) <> len(u) + 1 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(u) + 1 & " - " & len(shrink_(u1, "X"))
    end if
  next i

  for i = 2 to 7
    u1= left(u, 2) + string(i, 88) + mid(u, 3, 2) + string(4, 88) + mid(u, 5)
    
    if len(shrink_(u1, "X")) <> len(u) + 2 then    
      x = 1
      print
      print "ERROR (line#: " & __LINE__ & ") - shrink X inside " & st 
      print "i: " & str(i) & "  " & len(u) + 2 & " - " & len(shrink_(u1, "X"))
    end if
  next i


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
' pathname
'***********************************************************************************************goto ende


  print "pathname_: ",,,
  x = 0


'***********************************************************************************************
st = "zstring"
'***********************************************************************************************

  z = "c:\test test test\very_strange name.asdf.txt"
  s = "c:\test test test\very_strange name.asdf.txt"
  w = "c:\test test test\very_strange name.asdf.txt"
  u = "c:\test test test\very_strange name.asdf.txt"


  if pathname_(path, z) <> "c:\test test test\" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "c:\test test test\" & " - " & pathname_(path, z)
  end if

  if pathname_(name, z) <> "very_strange name.asdf" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "very_strange name.asdf" & " - " & pathname_(name, z)
  end if

  if pathname_(namex, z) <> "very_strange name.asdf.txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name + extension " & st 
    print "very_strange name.asdf.txt" & " - " & pathname_(namex, z)
  end if

  if pathname_(extn, z) <> ".txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname extension " & st 
    print ".txt" & " - " & pathname_(extn, z)
  end if

'***********************************************************************************************
st = "string"
'***********************************************************************************************

  if pathname_(path, s) <> "c:\test test test\" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "c:\test test test\" & " - " & pathname_(path, s)
  end if

  if pathname_(name, s) <> "very_strange name.asdf" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "very_strange name.asdf" & " - " & pathname_(name, s)
  end if

  if pathname_(namex, s) <> "very_strange name.asdf.txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name + extension " & st 
    print "very_strange name.asdf.txt" & " - " & pathname_(namex, s)
  end if

  if pathname_(extn, s) <> ".txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname extension " & st 
    print ".txt" & " - " & pathname_(extn, s)
  end if

'***********************************************************************************************
st = "wstring"
'***********************************************************************************************

  if pathname_(path, w) <> "c:\test test test\" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "c:\test test test\" & " - " & pathname_(path, w)
  end if

  if pathname_(name, w) <> "very_strange name.asdf" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "very_strange name.asdf" & " - " & pathname_(name, w)
  end if

  if pathname_(namex, w) <> "very_strange name.asdf.txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name + extension " & st 
    print "very_strange name.asdf.txt" & " - " & pathname_(namex, w)
  end if

  if pathname_(extn, w) <> ".txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname extension " & st 
    print ".txt" & " - " & pathname_(extn, w)
  end if

'***********************************************************************************************
st = "ustring"
'***********************************************************************************************

  if pathname_(path, u) <> "c:\test test test\" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "c:\test test test\" & " - " & pathname_(path, u)
  end if

  if pathname_(name, u) <> "very_strange name.asdf" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name " & st 
    print "very_strange name.asdf" & " - " & pathname_(name, u)
  end if

  if pathname_(namex, u) <> "very_strange name.asdf.txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname name + extension " & st 
    print "very_strange name.asdf.txt" & " - " & pathname_(namex, u)
  end if

  if pathname_(extn, u) <> ".txt" then    
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - pathname extension " & st 
    print ".txt" & " - " & pathname_(extn, u)
  end if


  if x = 0 then
    print "Ok!"
  else
    n = 1
  end if


'***********************************************************************************************
'***********************************************************************************************
'      insert
'      repeat
'      remove        any
'      replace       any
'      streverse
'      extract       any
'      remain        any
'      parse         any
'      parsecount    any
'      tally         any

'      rset_
'      lset_

'      pathname_
'      Shrink_

'   isnumeric ?
'   
'***********************************************************************************************
ende:

  if n = 0 then
    function = 0

  else
    function = 1
  end if


end function

  
'***********************************************************************************************
'***********************************************************************************************


FUNCTION FB_MAIN AS long
'***********************************************************************************************
' main
'***********************************************************************************************
dim z  as long
dim y  as wstring * 64 = !"abcdef"                    'wide string
dim y0  as wstring * 64 = !"ABCDEF"                   'wide string
dim y1 as wstring * 64 = !"wstring\u4644"             'wide string
dim y2 as wstring * 64 = "фывапр"                     '"ФЫВАПР" - Russian
dim y3 as wstring * 64 = "1234567"                    'numbers
                                                      

  print "********** lcase string **********"
  z =  typetest(y)                                    'do initial tests (type specific)
  z += rtltest(y)                                     'test the rtl string functions
  z += paramtest(y)                                   'test parameter passing + conversion


  print
  print "********** ucase string **********"
  z =  typetest(y0)                                   'do initial tests (type specific)
  z += rtltest(y0)                                    'test the rtl string functions
  z += paramtest(y0)                                  'test parameter passing + conversion


  print
  print "********** wide string **********"
  z =  typetest(y1)                                   'do initial tests (type specific)
  z += rtltest(y1)                                    'test the rtl string functions
  z += paramtest(y3)                                  'test parameter passing + conversion


  print
  print "********** Russian string **********"
  z += typetest(y2)                                   'do initial tests (type specific)
  z += rtltest(y2)                                    'test the rtl string functions
  z += paramtest(y2)                                  'test parameter passing + conversion


  print
  print "********** Helper Functions **********"


'***********************************************************************************************
' please don´t change the following strings passed, othwise test would probably fail
'***********************************************************************************************

  y = "1234567890 + abcdefghij"

  z += helpertest(y)                                  'test helper functions
  z += helpertest(y+y, 2)                             'test helper functions


  y = "aAbBcCdDeE + vVwWxXyYzZ"

  z += helpertest(y)                                  'test helper functions
  z += helpertest(y+y, 2)                             'test helper functions


  y = "фФиИсСвВуУаА + мМцЦчЧяЯнН"

  z += helpertest(y, 1, 1)                            'test helper functions
  z += helpertest(y+y, 2, 1)                          'test helper functions


  print
  
  if z > 0 then
    print "There were errors !!!"
  else
    print "Test ok !!!"
  end if


  sleep


  function = 0


end function


'***********************************************************************************************
'***********************************************************************************************
'***********************************************************************************************
