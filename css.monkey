Strict
Import mojo.app
Import error

#Rem
---------------------------------------------------------------------------
	CssFile: Load css files and access their data through a Map
---------------------------------------------------------------------------
	How to use:
	1) Local file:CssFile = New CssFile
	2) file.Load ("myFile.css")
	3) Local name:String = file.Get ("Dragon", "Name")
---------------------------------------------------------------------------
#End
Class CssFile
	
	Field Blocks:StringMap<CssBlock>
	Field path:String
	
	Method New()
		checkingProperties = False
		Blocks = New StringMap<CssBlock>
	End
	
	Method Load:Void (path:String, useString:String = "")
		Local file:String
		If useString <> ""
			file = useString
		Else
			file = app.LoadString (path)
		End
		
		If file = ""
			PatoException.Create ("FileHandler: CssFileHandler.Load: File " + path + " could not be loaded!")
		End
		Self.path = path
		
		Local startIndex:Int
		Local endIndex:Int = -1
		Local name:String
		Local props:String
		Local match:Int

		Local prop:String
		Local value:String
		Local block:CssBlock
		
		While True
			startIndex = MatchChar (file, START_BRACKET, endIndex)
			name = file[endIndex+1..startIndex].Trim()
			endIndex = MatchChar (file, END_BRACKET, startIndex)
			
			If startIndex = -1
				Exit
			End
			
			block = New CssBlock (name)
			Blocks.Add (name, block)
			props = TrimDown (file[startIndex+1..endIndex])
			
			Local lastIndex:Int = 0
			While True
				match = MatchChar (props, COLON, lastIndex)
				If match = -1
					Exit
				End
				prop = props[lastIndex..match]
				lastIndex = match + 1
				
				match = MatchChar (props, SEMICOLON, lastIndex)
				If match = -1
					Exit
				End
				value = props[lastIndex..match]
				lastIndex = match + 1
				block.SetKeyAndValue (prop, value)
			End
		End
		
	End
	
	Method Get:String (selector:String, prop:String)
		Local block:CssBlock = Blocks.Get (selector)
		If block
			Return block.Properties.Get (prop)
		End
		Return ""
	End
	
	Method Exists:Bool (selector:String)
		Return Blocks.Contains (selector)
	End
	
	Method GetBlock:CssBlock (selector:String)
		Return Blocks.Get (selector)
	End
	
	Private
	Field checkingProperties:Bool
	
	Const START_BRACKET:Int = 123
	Const END_BRACKET:Int   = 125
	Const SEMICOLON:Int     = 59
	Const NEWLINE:Int       = 10
	Const WHITESPACE:Int    = 32
	Const TAB:Int           = 9
	Const COLON:Int         = 58
	
End



'--------------------------------------------------------------------------
' * An element of a Css File
'--------------------------------------------------------------------------
Class CssBlock
	
	Field id:String
	Field Properties:StringMap<String>
	
	Method New (id:String)
		Self.id = id
		Properties = New StringMap<String>
	End
	
	Method SetKeyAndValue:Void (key:String, value:String)
		Properties.Add (key, value)
	End
	
	Method Get:String (propName:String)
		Return Properties.Get (propName)
	End
	
	Method GetInt:Int (propName:String, defaultValue:Int = 0)
		Local value:String = Properties.Get (propName)
		If (value.Length = 0)
			Return defaultValue
		End
		Return Int(value)
	End
	
	Method GetFloat:Float (propName:String, defaultValue:Float = 0.0)
		Local value:String = Properties.Get (propName)
		If (value.Length = 0)
			Return defaultValue
		End
		Return Float(value)
	End
	
	Method GetArray:String[] (propName:String, delimiter:String = ",", defaultValue:String[] = [""])
		Local value:String = Properties.Get (propName)
		If (value.Length = 0)
			Return defaultValue
		End
		Local arr:String[] = value.Split (delimiter)
		For Local i:Int = 0 Until arr.Length
			arr[i] = arr[i].Trim()
		Next
		Return arr
	End
	
	Method Contains:Bool (propName:String)
		Return Properties.Contains (propName)
	End
	
End



'--------------------------------------------------------------------------
' * Helper Functions
'--------------------------------------------------------------------------
Function TrimDown:String (text:String)
	Local newText:String
	Local char:Int
	For Local i:Int = 0 Until text.Length
		char = text[i]
		If (char <> CssFile.TAB) And (char <> CssFile.NEWLINE)
			newText += String.FromChar (char)
		End
	End
	Return newText
End

Function MatchChar:Int (text:String, char:Int, startPos:Int)
	For Local i:Int = startPos Until text.Length
		If text[i] = char
			Return i
		End
	End
	Return -1
End

