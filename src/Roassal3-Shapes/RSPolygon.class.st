"
TODO
"
Class {
	#name : #RSPolygon,
	#superclass : #RSBoundingShape,
	#instVars : [
		'points',
		'radius'
	],
	#category : #'Roassal3-Shapes-Bounding'
}

{ #category : #utilities }
RSPolygon class >> fitPolygonToSquare: points [
	| maxx minx maxy miny sx sy x y |
	minx := maxx :=  points first x.
	miny := maxy :=  points first y.
	points do: [ :p | 
		minx := minx min: p x.
		miny := miny min: p y.
		maxx := maxx max: p x.
		maxy := maxy max: p y ].
	"stretch factors"
	sx := 2/(maxx - minx).
	sy := 2/(maxy - miny).
	points doWithIndex: [ :p :i|
		x := p x * sx.
		y := p y * sy.
		points at: i put: x@y.
		minx := minx min: x.
		miny := miny min: y.
		maxx := maxx max: x.
		maxy := maxy max: y ].
	miny < -1 ifTrue: [ 
		points doWithIndex: [ :p :i |
			points at: i put: p x @ ( p y - 1 - miny ) ] ].
	^ points.
]

{ #category : #utilities }
RSPolygon class >> generatePointsFitSquare: sides [
	| points |
	points := self generateUnitNgonPoints: sides rotation: 0.
	points := self fitPolygonToSquare: points.
	^ points
]

{ #category : #utilities }
RSPolygon class >> generateUnitNgonPoints: sides rotation: rotationAngle [
	
	^ self generateUnitNgonPoints: sides  rotation: rotationAngle
		angle: [ :a :i | a negated ] 
		radius: [ :a :i | 1 ]
]

{ #category : #utilities }
RSPolygon class >> generateUnitNgonPoints: sides rotation: rotationAngle angle: angleBloc radius: radiusBloc [
	"sides a Number
	rotation is a number in radians
	angle is a function of 2 args(current angle and index of angle) this return an angle
	radius is a function of 2 args (current angle and index of angle) this retunr a number "
	| increment startAngle points currentAngle currentRadius |
	increment := 1.0 / sides * 2 * Float pi.
	startAngle := sides even
		ifTrue: [ (Float pi / 2) + (increment / 2) ]
		ifFalse: [ Float pi / 2 ].
	startAngle := startAngle + rotationAngle.
	points := Array new: sides.
	0 to: sides - 1 do: [ :i | 
		currentAngle := i * increment + startAngle.
		currentAngle := angleBloc value: currentAngle value: i.
		currentRadius := radiusBloc value: currentAngle value: i.
		points at: i+1 put: (currentAngle cos @ currentAngle sin) * currentRadius ].
	^ points
]

{ #category : #visiting }
RSPolygon >> buildPathOn: visitor [
	visitor buildPolygonPath: self.
]

{ #category : #public }
RSPolygon >> centerPoints [
	| r center |
	r := Rectangle encompassing: points.
	center := r rsCenter.
	points doWithIndex: [ :p :i | 
		points at: i put: p - center.
		 ].
	^ r.
]

{ #category : #accessing }
RSPolygon >> cornerRadii [ 
	^ radius ifNil: [ 0 ]
]

{ #category : #accessing }
RSPolygon >> cornerRadii: aNumber [
	radius := aNumber abs.
]

{ #category : #private }
RSPolygon >> extent: newExtent [
	| min max s extent |
	extent := baseRectangle extent.
	extent = newExtent
		ifTrue: [ ^ self ].
	min := points min.
	max := points max.
	s := newExtent / (max - min).
	points := points collect: [ :p | p * s ].
	super extent: newExtent
]

{ #category : #testing }
RSPolygon >> includesPoint: aPoint [
	| invertedPoint |
	invertedPoint := matrix inverseTransform: aPoint.
	^ (self baseRectangle containsPoint: invertedPoint)
		ifFalse: [ ^ false ]
		ifTrue: [(AthensPolygonTester new polygon: points) includesPoint: invertedPoint]
]

{ #category : #initialization }
RSPolygon >> initialize [
	super initialize.
	points := #().
]

{ #category : #accessing }
RSPolygon >> points [
	^ points
]

{ #category : #accessing }
RSPolygon >> points: anArray [
	| rec |
	self privatePoints: anArray.
	rec := self centerPoints.
	self translateTo: rec rsCenter.
	super extent: rec extent
]

{ #category : #private }
RSPolygon >> privatePoints: anArray [
	points := anArray
]