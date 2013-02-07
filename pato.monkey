Strict
Import mojo
Import cache
Import css
Import color
Import error
Import vector


'--------------------------------------------------------------------------
' * This is the class you can use to easily load in a Particle Effect from a file
' * After calling New(..) call Update() and Render() from your App
'--------------------------------------------------------------------------
Class ParticleEffect
	
	Field emitters:ParticleEmitter[]
	
	Method New (effectPath:String, x:Float, y:Float, start:Bool = True)
		Local file:CssFile = New CssFile
		file.Load (effectPath)
		LoadEmitters(file)
		Self.SetPosition (x, y)
		If start
			Self.Start()
		End
	End
	
	Method SetPosition:Void (x:Float, y:Float)
		For Local i:Int = 0 Until emitters.Length
			emitters[i].position.Set(x, y)
		Next
	End
	
	Method Start:Void()
		For Local i:Int = 0 Until emitters.Length
			emitters[i].Start()
		Next
	End
	
	Method Stop:Void()
		For Local i:Int = 0 Until emitters.Length
			emitters[i].Stop()
		Next
	End
	
	Method LoadEmitters:Void (file:CssFile)
		PatoException.Assert (file, "ParticleEmitter.LoadEmitters: Passed file is Null.")
		Local emitterString:String[] = file.Get ("Effect", "emitters").Split (" ")
		
		If (emitterString.Length = 1) And (emitterString[0] = "")
			PatoException.Create ("ParticleEmitter.LoadEmitters: The emitter " + file.path + " contains no emitters.")
			Return
		End
		emitters = New ParticleEmitter[emitterString.Length]
		For Local i:Int = 0 Until emitters.Length
			emitters[i] = New ParticleEmitter()
			emitters[i].LoadFromFile (file, emitterString[i])
		Next
	End
	
	Method Update:Void()
		For Local i:Int = 0 Until emitters.Length
			emitters[i].Update()
		Next
	End
	
	Method Render:Void()
		For Local i:Int = 0 Until emitters.Length
			emitters[i].Render()
		Next
	End
	
End



'--------------------------------------------------------------------------
' * Particle Emitter
' * Use LoadFromFile to easily setup the values
'--------------------------------------------------------------------------
Class ParticleEmitter
	
	Field Particles:Particle[]
	
	Field inUse:Bool
	Field mirrored:Bool
	
	Field id:String
	Field texture:Image
	Field texturePath:String
	
	Field position:PatoVector, positionVariance:PatoVector
	
	Field speed:Float, speedVariance:Float
	Field radialAcceleration:Float, tangentialAcceleration:Float
    Field radialAccelVariance:Float, tangentialAccelVariance:Float

	Field size:PatoVector, sizeVariance:PatoVector
	Field endSize:PatoVector, endSizeVariance:PatoVector
	Field scaleUniform:Bool
	
	Field angle:Float, angleVariance:Float
	Field rotationStart:Float, rotationStartVariance:Float
    Field rotationEnd:Float, rotationEndVariance:Float
	
	Field startColor:PatoColor, startColorVariance:PatoColor
	Field endColor:PatoColor, endColorVariance:PatoColor
	
	Field gravity:PatoVector
	
	Field particleLifeSpan:Float, particleLifeSpanVariance:Float
	
	'Only used when maxRadius value is provided (spinning portal effect)
	Field maxRadius:Float		
	Field maxRadiusVariance:Float
	Field minRadius:Float					
	Field rotatePerSecond:Float
	Field rotatePerSecondVariance:Float
	
	Field additiveBlend:Bool
	Field oneShot:Bool
	Field active:Bool
	
	Field duration:Float
	Field emitDelay:Float
	Field emissionRate:Int
	
	Field emitterType:Int
	Const TYPE_GRAVITY:Int = 1
	Const TYPE_RADIAL:Int = 2
	
	
	Method New()
		position = New PatoVector()
		positionVariance = New PatoVector()
		size = New PatoVector (1.0, 1.0)
		sizeVariance = New PatoVector()
		endSize = New PatoVector (1.0, 1.0)
		endSizeVariance = New PatoVector()
		gravity = New PatoVector()
		startColor = New PatoColor()
		startColorVariance = New PatoColor (0, 0, 0, 0)
		endColor = New PatoColor()
		endColorVariance = New PatoColor (0, 0, 0, 0)
		duration = 0.01
		emitterType = TYPE_GRAVITY
	End
	
	Method LoadFromFile:Void (file:CssFile, id:String, loadFromEditor:Bool = False)
		PatoException.Assert (file, "ParticleEmitter.LoadFromFile: Passed file is Null.")
		Local block:CssBlock = file.GetBlock (id)
		PatoException.Assert (block, "ParticleEmitter: Couldn't load effect: " + file.path)
		
		id = block.Get ("id")
		If loadFromEditor
			Local path:String = block.Get("image")
			texture = PatoCache.LoadImage ("./images/" + path)
			texturePath = path
		Else
			SetTexture (block.Get ("image"))
		End
		PatoException.Assert (texture, "ParticleEmitter: Image does not exist in effect: " + file.path)
		
		'Lifespan
		particleLifeSpan = block.GetFloat ("life", 1.0)
		particleLifeSpanVariance = block.GetFloat ("lifeVariance")
		
		'Emission + Duration
		emissionRate = block.GetInt ("emissionRate", 10)
		duration = block.GetFloat ("duration", 0.01)
		
		'Determinate how big our array should be
		Local arraySize:Int = (particleLifeSpan + particleLifeSpanVariance * 0.75) * emissionRate
		Self.InitWithSize (arraySize)
		
		'Booleans
		Local bools:Int[2]
		bools[0] = block.GetInt ("additiveBlend")
		bools[1] = block.GetInt ("oneShot")
		additiveBlend = Bool (bools[0])
		oneShot       = Bool (bools[1])
		
		'Emit Delay
		emitDelay = block.GetFloat ("emitDelay")
		
		'Type
		If block.Get ("type") = "radial"
			emitterType = TYPE_RADIAL
			maxRadius = block.GetFloat ("maxRadius")
			maxRadiusVariance = block.GetFloat ("maxRadiusVariance")
			minRadius = block.GetFloat ("minRadius")
			rotatePerSecond = block.GetFloat ("rotatePerSecond")
			rotatePerSecondVariance = block.GetFloat ("rotatePerSecondVariance")
		Else
			emitterType = TYPE_GRAVITY
			gravity.x = block.GetFloat ("gravityX")
			gravity.y = block.GetFloat ("gravityY")
			radialAcceleration = block.GetFloat ("radialAcceleration")
			radialAccelVariance = block.GetFloat ("radialAccelVariance")
			tangentialAcceleration = block.GetFloat ("tangentialAcceleration")
			tangentialAccelVariance = block.GetFloat ("tangentialAccelVariance")
			speed = block.GetFloat ("speed")
			speedVariance = block.GetFloat ("speedVariance")
		End
		
		'Position
		position.x = block.GetInt ("positionX")
		position.y = block.GetInt ("positionY")
		positionVariance.x = block.GetInt ("positionVarianceX")
		positionVariance.y = block.GetInt ("positionVarianceY")
		
		'Size
		size.x = block.GetFloat ("sizeX")
		size.y = block.GetFloat ("sizeY")
		sizeVariance.x = block.GetFloat ("sizeVarianceX")
		sizeVariance.y = block.GetFloat ("sizeVarianceY")
		endSize.x = block.GetFloat ("endSizeX")
		endSize.y = block.GetFloat ("endSizeY")
		endSizeVariance.x = block.GetFloat ("endSizeVarianceX")
		endSizeVariance.y = block.GetFloat ("endSizeVarianceY")
		scaleUniform = Bool(block.GetInt ("scaleUniform"))
		
		'Angle
		angle = block.GetInt ("angle")
		angleVariance = block.GetInt ("angleVariance")
		rotationStart = block.GetInt ("rotationStart")
		rotationStartVariance = block.GetInt ("rotationStartVariance")
		rotationEnd = block.GetInt ("rotationEnd")
		rotationEndVariance = block.GetInt ("rotationEndVariance")
		
		'Color
		Local c:String[] = block.GetArray ("color", " ")
		If c And c.Length = 8
			startColor.Set (Float(c[0]), Float(c[1]), Float(c[2]), Float(c[3]))
			startColorVariance.Set (Float(c[4]), Float(c[5]), Float(c[6]), Float(c[7]))
		Else
			startColor.Set (255, 255, 255, 1.0)
			startColorVariance.Set (0.0, 0.0, 0.0, 0.0)
		End
		
		'End Color
		Local c2:String[] = block.GetArray ("endColor", " ")
		If c2 And c2.Length = 8
			endColor.Set (Float(c2[0]), Float(c2[1]), Float(c2[2]), Float(c2[3]))
			endColorVariance.Set (Float(c2[4]), Float(c2[5]), Float(c2[6]), Float(c2[7]))
		Else
			endColor.Set (startColor)
			endColorVariance.Set (0.0, 0.0, 0.0, 0.0)
		End
		
		If mirrored
			position.x = -position.x
			angle = 360 - angle
			gravity.x = -gravity.x
		End
		
	End
	
	Method InitWithSize:Void (maxParticles:Int)
		Particles = New Particle[maxParticles]
		For Local i:Int = 0 Until maxParticles
			Particles[i] = New Particle
		Next
		Self.maxParticles = maxParticles
	End
	
	Method SetTexture:Void (path:String)
		texture = LoadBitmap (path)
		texturePath = path
		MidHandleImage (texture)
	End
	
	Method InitParticle:Void (particle:Particle)
		'Lifetime
		particle.timeToLive = particleLifeSpan + particleLifeSpanVariance * Rand1ToMinus1()
		
		'Position
		particle.position.x = position.x + positionVariance.x * Rand1ToMinus1()
		particle.position.y = position.y + positionVariance.y * Rand1ToMinus1()
		particle.startPosition.x = position.x
		particle.startPosition.y = position.y
		
		'Direction
		Local newAngle:Float = angle + angleVariance * Rand1ToMinus1()
		Local vectorSpeed:Float = speed + speedVariance * Rand1ToMinus1()
		particle.direction.Set (Cos(newAngle), Sin(newAngle))
		particle.direction.Mul (vectorSpeed)
		particle.angle = angle + angleVariance * Rand1ToMinus1()
		
		'Diameter from source position
		particle.radius = maxRadius + maxRadiusVariance * Rand1ToMinus1()
		particle.radiusDelta = (maxRadius / particleLifeSpan) * (1.0 / UpdateRate())
		particle.angle = angle + angleVariance * Rand1ToMinus1()
		particle.degreesPerSecond = rotatePerSecond + rotatePerSecondVariance * Rand1ToMinus1()
	    particle.radialAcceleration = radialAcceleration
	    particle.tangentialAcceleration = tangentialAcceleration
		
		'Size
		particle.size.x = size.x + sizeVariance.x * Rand1ToMinus1()
		particle.size.y = size.y + sizeVariance.y * Rand1ToMinus1()
		Local endX:Float = endSize.x + endSizeVariance.x * Rand1ToMinus1()
		Local endY:Float = endSize.y + endSizeVariance.y * Rand1ToMinus1()
		particle.deltaSize.x = (endX - particle.size.x)/particle.timeToLive
		particle.deltaSize.y = (endY - particle.size.y)/particle.timeToLive
		If scaleUniform
			particle.size.y = particle.size.x
			particle.deltaSize.y = particle.deltaSize.x
		End
		
		'Rotation
	    Local startAngle:Float = rotationStart + rotationStartVariance * Rand1ToMinus1()
	    Local endAngle:Float = rotationEnd + rotationEndVariance * Rand1ToMinus1()
	    particle.rotation = startAngle
	    particle.deltaRotation = (endAngle - startAngle) / particle.timeToLive;

		'Start Color
		Local r:Float = startColor.red + startColorVariance.red * Rand1ToMinus1()
		Local g:Float = startColor.green + startColorVariance.green * Rand1ToMinus1()
		Local b:Float = startColor.blue + startColorVariance.blue * Rand1ToMinus1()
		Local a:Float = startColor.alpha + startColorVariance.alpha * Rand1ToMinus1()
		r = Max (0.0, r)
		g = Max (0.0, g)
		b = Max (0.0, b)
		a = Max (0.0, a)
		r = Min (255.0, r)
		g = Min (255.0, g)
		b = Min (255.0, b)
		a = Min (1.0, a)
		particle.color.Set (r, g, b, a)
		
		'End Color
		Local endR:Float = endColor.red + endColorVariance.red * Rand1ToMinus1()
		Local endG:Float = endColor.green + endColorVariance.green * Rand1ToMinus1()
		Local endB:Float = endColor.blue + endColorVariance.blue * Rand1ToMinus1()
		Local endA:Float = endColor.alpha + endColorVariance.alpha * Rand1ToMinus1()
		endR = Max (0.0, endR)
		endG = Max (0.0, endG)
		endB = Max (0.0, endB)
		endA = Max (0.0, endA)
		endR = Min (255.0, endR)
		endG = Min (255.0, endG)
		endB = Min (255.0, endB)
		endA = Min (1.0, endA)
		
		'Delta Color
		particle.deltaColor.red   = (endR - r) / Float (particle.timeToLive)
		particle.deltaColor.green = (endG - g) / Float (particle.timeToLive)
		particle.deltaColor.blue  = (endB - b) / Float (particle.timeToLive)
		particle.deltaColor.alpha = (endA - a) / Float (particle.timeToLive)
	End
	
	Method AddParticle:Bool()
		If particleCount >= maxParticles
			Return False
		End
		Local particle:Particle = Particles[particleCount]
		InitParticle (particle)
		particleCount += 1
		Return True
	End
	
	Method Start:Void()
		active = True
		lastTime = Millisecs()
	End
	
	Method Stop:Void()
		active = False
		elapsedTime = 0.0
		emitCounter = 0
	End
	
	Method Halt:Void()
		Stop()
		particleCount = 0
	End
	
	Method Update:Void()
		Local now:Int = Millisecs()
		Local delta:Float = (now - lastTime)/1000.0
		lastTime = now

		'Create Particles
		If active And (emissionRate > 0)
			elapsedTime += delta
			If elapsedTime < emitDelay Return
			If oneShot
				Local shootNr:Int = Min (maxParticles, emissionRate)
				While (particleCount < shootNr)
					AddParticle()
				Wend
				If duration <> -1
					Stop()
				End
			Else
				Local rate:Float = 1.0/emissionRate
				emitCounter += delta
				While (particleCount < maxParticles And emitCounter > rate)
					AddParticle()
					emitCounter -= rate
				Wend
				If (duration <> -1) And (elapsedTime > duration + emitDelay)
					Stop()
				End
			End
		ElseIf (active = False) And (elapsedTime = 0)
			If particleCount = 0
				inUse = False
			End
		End

		Local i:Int = 0
		Local currentParticle:Particle

		'Update All Particles
		While (i < particleCount)
			currentParticle = Particles[i]
			
			'Lifetime
			currentParticle.timeToLive -= delta
			
			If currentParticle.timeToLive > 0
				
				Local tmp:PatoVector = _tmp
				tmp.Set (0, 0)
				
				If (emitterType = TYPE_RADIAL)
					currentParticle.angle += currentParticle.degreesPerSecond * delta
					currentParticle.radius -= currentParticle.radiusDelta

					tmp.x = position.x - Cos(currentParticle.angle) * currentParticle.radius
					tmp.y = position.y - Sin(currentParticle.angle) * currentParticle.radius
					currentParticle.position.Set (tmp)

					If (currentParticle.radius < minRadius)
						currentParticle.timeToLive = 0
					End
					
				Else 'TYPE_GRAVITY
					Local radial:PatoVector = _radial
					Local tangential:PatoVector = _tangential
					radial.Set (0, 0)
					tangential.Set (0, 0)
					
	                If (currentParticle.position.x Or currentParticle.position.y)
	                    radial.Set (currentParticle.position)
						radial.Normalize()
					End
					
	                tangential.x = radial.x
	                tangential.y = radial.y
	                radial.Mul (currentParticle.radialAcceleration)

	                Local newy:Float = tangential.x
	                tangential.x = -tangential.y
	                tangential.y = newy
	                tangential.Mul (currentParticle.tangentialAcceleration)
					
					tmp.Add (gravity)
					tmp.Add (radial)
					tmp.Add (tangential)
	                tmp.Mul (delta)
					currentParticle.direction.Add (tmp)
					tmp.Set (currentParticle.direction)
					tmp.Mul (delta)
					currentParticle.position.Add (tmp)
				End
				
				'Size
				currentParticle.size.x += currentParticle.deltaSize.x * delta
				currentParticle.size.y += currentParticle.deltaSize.y * delta
				
				'Angle
				currentParticle.rotation += currentParticle.deltaRotation * delta

				'Color
				currentParticle.color.red   += currentParticle.deltaColor.red * delta
				currentParticle.color.green += currentParticle.deltaColor.green * delta
				currentParticle.color.blue  += currentParticle.deltaColor.blue * delta
				currentParticle.color.alpha += currentParticle.deltaColor.alpha * delta
				currentParticle.color.alpha = Max (0.0, currentParticle.color.alpha)
				
				'Increase Particle Counter
				i += 1
				
			'Particle dies + last particle replaces it's position in the array
			'This way the active particles are always at the beginning of the array
			Else
				If (i <> particleCount-1)
					Local tmp:Particle = Particles[i];
					Particles[i] = Particles[particleCount-1];
					Particles[particleCount-1] = tmp;
				End
				particleCount -= 1
			End
		End
		
	End
	
	Method Render:Void()
		If additiveBlend
			SetBlend (LIGHTBLEND)
		Else
			SetBlend (ALPHABLEND)
		End
		
		Local i:Int
		Local currentParticle:Particle
		For i = 0 Until particleCount
			PushMatrix()
			currentParticle = Particles[i]
			Translate (currentParticle.position.x, currentParticle.position.y)
			If currentParticle.rotation Or currentParticle.angle
				Rotate (currentParticle.rotation)
			End
			Scale (currentParticle.size.x, currentParticle.size.y)
			'#If TARGET <> "html5"
				SetColor (currentParticle.color.red, currentParticle.color.green, currentParticle.color.blue)
			'#End
			SetAlpha (currentParticle.color.alpha)
			DrawImage (texture, 0, 0)
			PopMatrix()
		Next
	End
	
	Method RenderDebugInfo:Void()
		ResetColor()
		DrawText ("Particle Nr: " + particleCount, 2, 2)
		DrawText ("Max Particles: " + maxParticles, 2, 16)
	End
	
	Private
	Field emitCounter:Float
	Field lastTime:Int
	Field elapsedTime:Float
	
	Field maxParticles:Int
	Field particleCount:Int
	
	'Temporary Vectors so nothing is allocated at runtime
	Global _radial:PatoVector = New PatoVector
	Global _tangential:PatoVector = New PatoVector
	Global _tmp:PatoVector = New PatoVector
End



'--------------------------------------------------------------------------
' * A single Particle
'--------------------------------------------------------------------------
Class Particle
	Field position:PatoVector
	Field startPosition:PatoVector
	Field direction:PatoVector
	Field size:PatoVector
	Field deltaSize:PatoVector
	
	Field angle:Float
	Field radialAcceleration:Float
    Field tangentialAcceleration:Float
	Field radius:Float
	Field radiusDelta:Float
	Field degreesPerSecond:Float
	Field rotation:Float
	Field deltaRotation:Float
	
	Field color:PatoColor
	Field deltaColor:PatoColor
	Field timeToLive:Float
	
	Method New()
		position = New PatoVector()
		startPosition = New PatoVector()
		direction = New PatoVector()
		size = New PatoVector()
		deltaSize = New PatoVector()
		color = New PatoColor()
		deltaColor = New PatoColor()
	End
	
End



Private
'--------------------------------------------------------------------------
' * Helper Functions
'--------------------------------------------------------------------------
Function ResetColor:Void() 
	SetAlpha (1.0)
	SetColor (255, 255, 255)
	If GetBlend() <> ALPHABLEND
		SetBlend (ALPHABLEND)
	End
End

Function LoadBitmap:Image (path:String, flags:Int = Image.MidHandle|Image.XYPadding)
	Local image:Image
	image = PatoCache.LoadImage (path, 1, flags)
	If Not image
		PatoException.Create ("LoadBitmap: Failed to load image: " + path)
	End
	Return image
End

Function MidHandleImage:Void (image:Image)
	If Not image Return
	image.SetHandle( Floor(image.Width() * 0.5), Floor(image.Height() * 0.5) )
End

Function Rand:Int (n1:Int, n2:Int)
	Return Int (Rnd (n1, n2))
End

Function Rand1ToMinus1:Float()
	Return Rnd (-1.0, 1.0)
End

Const ALPHABLEND:Int = 0
Const LIGHTBLEND:Int = 1