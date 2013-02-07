Strict
Import mojo

'--------------------------------------------------------------------------
' * Cache functions ensure ressources are only loaded once
'--------------------------------------------------------------------------
Class PatoCache
	
	Function LoadImage:Image (path:String, frames:Int = 1, flags:Int = Image.DefaultFlags)
		If ImageCache.Contains (path)
			Return ImageCache.Get (path)
		Else
			Local image:Image = mojo.LoadImage (path, frames, flags)
			If (Not image) Return Null
			ImageCache.Set (path, image)
			Return image
		End
	End

	Function LoadImage:Image (path:String, frameWidth:Int, frameHeight:Int, frameCount:Int, flags:Int = Image.DefaultFlags)
		If ImageCache.Contains (path)
			Return ImageCache.Get (path)
		Else
			Local image:Image = mojo.LoadImage (path, frameWidth, frameHeight, frameCount, flags)
			If (Not image) Return Null
			ImageCache.Set (path, image)
			Return image
		End
	End
	
	Function SetCachedImage:Void (path:String, image:Image)
		ImageCache.Set (path, image)
	End
	
	Function ClearImageCache:Void()
		For Local img:Image = Eachin ImageCache.Values()
			img.Discard()
		Next
		ImageCache.Clear()
	End

	Private
	Global ImageCache:StringMap<Image> = New StringMap<Image>
	
End
