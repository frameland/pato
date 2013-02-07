Strict

Class PatoColor

	Field red:Float = 255
	Field green:Float = 255
	Field blue:Float = 255
	Field alpha:Float = 1.0

	Method New (setRed:Float, setGreen:Float, setBlue:Float, setAlpha:Float=1.0)
		Self.Set (setRed, setGreen, setBlue, setAlpha)
	End
	
	Method Set:Void (color:PatoColor)
		Self.Set (color.red, color.green, color.blue, color.alpha)
	End
	
	Method Set:Void (setRed:Float, setGreen:Float, setBlue:Float, setAlpha:Float=1.0)
		red   = setRed
		green = setGreen
		blue  = setBlue
		alpha = setAlpha
	End
	
End

Global PATO_COLOR_WHITE:PatoColor = New PatoColor (255, 255, 255, 1.0)
Global PATO_COLOR_BLACK:PatoColor = New PatoColor (0, 0, 0, 1.0)
Global PATO_COLOR_RED:PatoColor   = New PatoColor (255, 0, 0, 1.0)
Global PATO_COLOR_GREEN:PatoColor = New PatoColor (0, 255, 0, 1.0)
Global PATO_COLOR_BLUE:PatoColor  = New PatoColor (0, 0, 255, 1.0)