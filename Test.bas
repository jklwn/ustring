#compiler freebasic
#compile console 32 exe /o "-R"

#define unicode
#include once "windows.bi"
#include "ustring.inc"



'***********************************************************************************************
' to do:                sadd        varptr/strptr    



'asc -> ok                    
'l/r/trim -> ok
' select case -> ok (compiler)
' left/right -> ok (overloaded functions needed)
' mid statement/function -> ok (compiler)
' lcase/ucase
'instr(rev) -> ok
'l/rset -> ok

'CBOOL -> ok
'CBYTE
'CSHORT
'CINT
'CLNG
'CLNGINT
'CUBYTE
'CUSHORT
'CUINT
'CULNG
'CULNGINT
'CSNG
'CDBL
'CPTR


' len

' MKD/I/L/LONGINT/S/SHORT  ?
' CVD/I/L/LONGINT/S/SHORT  ?

'***********************************************************************************************
'#undef any_
'#define any_ 1,


'***********************************************************************************************
'***********************************************************************************************


#macro hCheckString( U, w )
  r = 0                                               'reset flag

	scope
		if(len(u) <> len(w)) then
      r = 1                                           'signal error
		else
			for i as integer = 0 to len(u)
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

      i = 0
      n = 0
      select case w
        case y 
          i = 1
      end select

      select case u
        case y 
          n = 1
      end select

      if i <> n = 1 then
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

      i = 0
      n = 0
      select case left(w, 3)
        case left(y, 3) 
          i = 1
      end select

      select case left(u, 3)
        case left(y, 3) 
          n = 1
      end select

      if i <> n = 1 then
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
      dim u as ustring = w 'wstr(12345.6789)
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

    scope
      dim w as wstring * 50 = wstr(1)
      dim u as ustring = wstr(1)
      if CPTR(any ptr, @w) <> CPTR(any ptr, @u) + sizeof(u) then          'u is sizeof(u) further down in stack !
        x = 1
        print
        print "  ERROR (line#: " & __LINE__ & ") - CPTR"
        print "  u: -" & CPTR(any ptr, @u) & "-"
        print "  w: -" & CPTR(any ptr, @w) & "-"
      end if
    end scope

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


function conversiontest_2(byref u as ustring, byref s as string) as zstring ptr
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************
dim z as zstring * 128


  z = u + s
  function = @z


end function


'***********************************************************************************************


'function conversiontest_3(byref u as ustring, byref s as const string) as string



function conversiontest_3(byref u as ustring, byref s as string) as string
'function conversiontest_3(byref u as ustring, byval s as string) as string
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  function = u + s


end function


'***********************************************************************************************


function conversiontest_4(byref u as ustring, byref w as wstring) as wstring ptr
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************
dim w1 as wstring * 128


  w1 = u + w
  function = @w1


end function


'***********************************************************************************************


function conversiontest_5(byref u as ustring, byref s as string) as Ustring
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  function = u + s


end function


'***********************************************************************************************


function conversiontest_6(byref u as ustring, byref w as wstring) as Ustring
'***********************************************************************************************
' return conversion (out)
'***********************************************************************************************


  function = u + w


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


'  u1 = conversiontest_2(u, s)

  u1 = conversiontest_3(u, s)
  if u1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion USTRING receives a STRING"
    print u1
    print s + s
  end if

  u1 = conversiontest_4(u, w)
  if u1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion USTRING receives a WSTRING"
    print u1
    print w + w
  end if


'***********************************************************************************************

  z = conversiontest_5(u, s)
  if z <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion ZSTRING receives a USTRING"
    print u1
    print s + s
  end if


  s1 = conversiontest_5(u, s)
  if s1 <> s + s then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion STRING receives a USTRING"
    print s1
    print s + s
  end if


  w1 = conversiontest_6(u, w)
  if w1 <> w + w then
    x = 1
    print
    print "ERROR (line#: " & __LINE__ & ") - Return Conversion WSTRING receives a USTRING"
    print w1
    print w + w
  end if


  u1 = conversiontest_6(u, w)
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


function helpertest as long
'***********************************************************************************************
'
'***********************************************************************************************
dim x as long

'dim i as long
'dim n as long
'
'dim s  as string        = "12345" 
'dim z  as zstring * 64  = "12345"      
'
'dim w  as Wstring * 64  = "ФЫВАПР"
'dim w1 as Wstring * 64  
'dim u  as Ustring       = "ФЫВАПР"
'dim u1 as Ustring     
dim u  as Ustring       = "12345"
'
'
' s = x
' print s
'
''***********************************************************************************************
'
' u = extract$(u, any "54")
''' x = extract$(x, 1, "54")
' print "u: " + u
' sleep
  


  if x = 0 then
    print "Ok!"
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
dim y0  as wstring * 64 = !"ABCDEF"                    'wide string
dim y1 as wstring * 64 = !"wstring\u4644"             'wide string
'dim y2 as wstring * 64 = "ФЫВАПР"                     'Russian
dim y2 as wstring * 64 = "фывапр" '"ФЫВАПР"                     'Russian
dim y3 as wstring * 64 = "1234567"                    'numbers
                                                      


  print "********** lcase string **********"
  print
  z =  typetest(y)                                    'do initial tests (type specific)
  z += rtltest(y)                                     'test the rtl string functions
  z += paramtest(y)                                   'test parameter passing + conversion


  print "********** ucase string **********"
  print
  z =  typetest(y0)                                   'do initial tests (type specific)
  z += rtltest(y0)                                    'test the rtl string functions
  z += paramtest(y0)                                  'test parameter passing + conversion

'goto ende

  print "********** wide string **********"
  print
  z =  typetest(y1)                                   'do initial tests (type specific)
  z += rtltest(y1)                                    'test the rtl string functions
  z += paramtest(y3)                                  'test parameter passing + conversion


'  z += helpertest(y1)                                 'test helper functions



  print "********** Russian string **********"
  print
  z += typetest(y2)                                   'do initial tests (type specific)
  z += rtltest(y2)                                    'test the rtl string functions
  z += paramtest(y2)                                  'test parameter passing + conversion


ende:
  print
  
  if z > 0 then
    print "There were errors !!!"
  else
    print "Test ok !!!"
  end if


  sleep


  function = 0


end function


