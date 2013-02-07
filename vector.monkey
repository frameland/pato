Class PatoVector Final

	Field x:Float
	Field y:Float
	
	Method New (setX:Float, setY:Float)
		x = setX
		y = setY
	End
	
	Method Set:Void (setX:Float, setY:Float)
		x = setX
		y = setY
	End
	
	Method Set:Void (vector:PatoVector)
		x = vector.x
		y = vector.y
	End
	
	Method Add:Void (vector:PatoVector)
		x += vector.x
		y += vector.y
	End
	
	Method Add:Void (addX:Float, addY:Float)
		x += addX
		y += addY
	End
	
	Method Sub:Void (vector:PatoVector)
		x -= vector.x
		y -= vector.y
	End
	
	Method Sub:Void (subX:Float, subY:Float)
		x -= subX
		y -= subY
	End
	
	Method Mul:Void (scalar:Float)
		x *= scalar
		y *= scalar
	End
	
	Method Dot:Float (vector:PatoVector)
		Return (x * vector.x + y * vector.y)
	End
	
	Method Length:Float() Property
		Return Sqrt (x * x + y * y)
	End
	
	Method Normalize:Void()
		Local length:Float = Self.Length
		If Length = 0 
			Return
		Endif
		Set (x/length, y/length)
	End
	
	Method Inverse:Void()
		x = -x
		y = -y
	End
	
	Method InverseX:Void()
		x = -x
	End
	
	Method InverseY:Void()
		y = -y
	End
	
	Method Copy:PatoVector()
		Return New PatoVector (x, y)
	End
	
	Method Equals:Bool (vector:PatoVector)
		Return (x = vector.x) And (y = vector.y)
	End
	
End