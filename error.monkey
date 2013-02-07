Strict

'--------------------------------------------------------------------------
' * This class will throw exceptions when something goes terribly wrong
' * e.g. when a file couldn't be loaded
' * You can turn that behaviour off by calling PatoException.TurnOff()
'--------------------------------------------------------------------------
Class PatoException Extends Throwable
	
	Method New (message:String)
		Error ("Error in pato.~n" + message)
	End
	
	Method Info:String() Property
		Return message
	End
	
	Function Create:Void (message:String)
		If isOn
			Throw New PatoException (message)
		End
	End
	
	Function Assert:Void (obj:Object, errorMessage:String)
		If (obj = Null)
			PatoException.Create (errorMessage)
		End
	End
	
	Function TurnOn:Void()
		isOn = True
	End
	
	Function TurnOff:Void()
		isOn = False
	End
	
	Private
	Field message:String
	Global isOn:Bool = True
	
End