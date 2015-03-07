# This imports all the layers for "demo" into demoLayers

thebackground = new BackgroundLayer backgroundColor:"rgba(255, 255, 255, 1.00)"
demoLayers = Framer.Importer.load "imported/demo"

# Layers
aBackground = demoLayers["Background"]
Card = demoLayers["Card"]
Grids = demoLayers["Grids"]
Topbar = demoLayers["Topbar"]
BackButton = demoLayers["BackButton"]
Toolbar1 = demoLayers["Toolbar1"]
Template = demoLayers["Template"]
TempBackground = demoLayers["TempBackground"]
SubGrids = demoLayers["SubGrids"]
GridsCells = []
for i in [0..5]
	GridsCellsName = ["One", "Two", "Three", "Four", "Five", "Six"]
	GridsCells[i] = demoLayers[GridsCellsName[i]]

# Animation LayerGroup
AniLayerGroup = [Topbar, Toolbar1, BackButton, Template, TempBackground, SubGrids]
templateCells = GridsCells

# Caculator
maxY = 800.0
midY = maxY / 2
minScale = 0.4   # The Card's minimum scale
minY = Card.minY
cardHeight = Card.height
cardminHeight = (cardHeight - cardHeight * minScale) / 2
gap = ((aBackground.height - maxY) - cardHeight * minScale) / 5

# States
inset = 50
statesShowAndHidden = show:{opacity: 1}, hidden:{opacity: 0}
statesScale = large:{x: -inset * 1.5, y: -inset * 3, width: TempBackground.width + inset * 2, height: TempBackground.height + inset * 2, blur: inset - 10 }
aniOptions =curve: "spring(500,40,0)"

aBackground.draggable.enabled = true
aBackground.draggable.speedX = 0
SubGrids.opacity = 0
BackButton.opacity = 0

for layer in AniLayerGroup
	layer.states.add statesShowAndHidden
	layer.states.animationOptions = aniOptions
	
for cell in templateCells
	cell.states.add  statesShowAndHidden
	cell.states.add  statesScale
	cell.states.animationOptions = aniOptions

Card.states.add
	up:{y: minY, scale: 1}
	down:{y: 0 - cardminHeight + gap, scale: minScale}

aBackground.states.add
	up: {y: 0}
	down:{y: maxY}

Card.states.animationOptions = aniOptions
aBackground.states.animationOptions = aniOptions

# Events
templateVC = (progress) ->
	Template.opacity = progress

aBackgroundDragMoveVC = (event, Layer) ->
 	Layer.y = if Layer.y > 0 then Layer.y else 0
 	Layer.y = if Layer.y < maxY then Layer.y else maxY
 	
 	progress = Layer.y / maxY
 	deltScale = (1 - minScale) * progress
 	Topbar.opacity = 1- progress
 	Toolbar1.opacity = 1 - progress
 	Card.scale = (1 - deltScale)
 	Card.y = minY - (minY + cardminHeight - gap ) * progress
 	templateVC(progress) # Template show or hidden by progress

aBackgroundDragEndVC = (event, Layer) ->
	state = if Layer.states.current isnt "down" then "down" else "up"
	opacityState = if state is "up" then "hidden" else "show"
	reverseopacityState = if state is "up" then "show" else "hidden"
	aBackground.states.switch(state)
	Card.states.switch(state)
	Toolbar1.states.switch(reverseopacityState)
	Topbar.states.switch(reverseopacityState)
	Template.states.switch(opacityState)

cellScaleVC = (event, cell) ->
	if cell.states.current isnt "large" 
	 cell.states.switch("large")
	 BackButton.states.switch("show")
	 SubGrids.states.switch("show")
	 for acell in templateCells
	  if acell isnt cell
	   acell.states.switch("hidden")
			
BackButtonClickVC = (event, button) ->
	button.states.switch("hidden")
	SubGrids.states.switch("hidden")
	for acell in templateCells
	  acell.states.switch("default")
	
aBackground.on Events.DragMove, aBackgroundDragMoveVC
aBackground.on Events.DragEnd, aBackgroundDragEndVC
BackButton.on Events.Click, BackButtonClickVC
for cell in templateCells
	cell.on Events.Click, cellScaleVC


	
	
	