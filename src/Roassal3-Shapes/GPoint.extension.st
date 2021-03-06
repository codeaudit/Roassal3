Extension { #name : #GPoint }

{ #category : #'*Roassal3-Shapes' }
GPoint >> asPoint [
	^ self x @ self y
]

{ #category : #'*Roassal3-Shapes' }
GPoint >> center [
	^ self
]

{ #category : #'*Roassal3-Shapes' }
GPoint >> rsScaleWith: anAthensAffineTransform [
	^ (anAthensAffineTransform transform: self) asGPoint
]
