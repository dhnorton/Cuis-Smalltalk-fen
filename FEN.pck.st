'From Cuis 5.0 of 7 November 2016 [latest update: #3329] on 14 July 2018 at 6:28:19 pm'!
'Description Extract position records from a file and write an individual *.fen file for each group of records.'!
!provides: 'FEN' 1 12!
SystemOrganization addCategory: #FEN!


!classDefinition: #InFen category: #FEN!
Object subclass: #InFen
	instanceVariableNames: 'directory file ser total'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'FEN'!
!classDefinition: 'InFen class' category: #FEN!
InFen class
	instanceVariableNames: ''!

!classDefinition: #Progress category: #FEN!
Object subclass: #Progress
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'FEN'!
!classDefinition: 'Progress class' category: #FEN!
Progress class
	instanceVariableNames: ''!


!InFen commentStamp: 'dhn 6/19/2018 17:24:41' prior: 0!
Extract position records from a file and write an individual *.fen file for each group of records. The file is compatible with Xboard in that the first record defines the position of the pieces. The remaining records from the group follow in their original sequence.

"
(InFen new: 'chess/m8n/m8n2.txt') write.
"!

!Progress commentStamp: 'dhn 7/14/2018 18:27:08' prior: 0!
Compute percentage (as a decimal) of a series of win-loss pairs, as x / (x + y).

Run the following, as an example:

Progress new percent:  #(
1 0
1 1
2 1
2 2
3 2
).
!

!InFen methodsFor: 'I/O' stamp: 'dhn 6/23/2018 11:31:04'!
baseName
	"Answer the base name for output files"
	| dot |
	
	dot _ file indexOf: $. ifAbsent: [].
	^ (FillInTheBlankMorph
		request: 'Base name for output files?'
		initialAnswer: (file copyFrom: 1 to: dot - 1)
		centerAt: Display center
		onCancelReturn: ''
		acceptOnCR: true)! !

!InFen methodsFor: 'I/O' stamp: 'dhn 6/19/2018 21:43:41'!
outNameFor: base
	"Answer a file name, which includes base with a serial number appended plus the '.fen' extension"
	
	ser _ ser + 1.
	^ String streamContents: [:str |
		str  
			nextPutAll: base;
			nextPut: $-.
		ser printOn: str length: 3 zeroPadded: true.
		str nextPutAll: '.fen']! !

!InFen methodsFor: 'I/O' stamp: 'dhn 6/23/2018 12:00:04'!
write
	"Write a *fen file for each group of position records"
	| base outName ios line col nr ostr |

	base _ self baseName.
	ser _ 0.
	col _ OrderedCollection new.
	ios _ ReadStream on: (directory / file) asString asFileEntry fileContents.
	line _ ''.
	[line isNil ] whileFalse: [
		line _ ios nextLine.
		[line = '' or: [line isNil]] whileFalse: [
			nr _ (line select: [:a | a = $/]) size.
			(nr = 7)
				ifTrue: [
					outName _ self outNameFor: base.
					outName asFileEntry 	forceWriteStreamDo: [ :out | out nextPutAll: line; newLine]]
				ifFalse: [col add: line].
			line _ ios nextLine].
			(col isEmpty not) 
				ifTrue: [
					ostr _ String new writeStream.
					col do: [:n | ostr nextPutAll: n; newLine].
					outName asFileEntry appendContents: ostr contents.
					col _ OrderedCollection new]]! !

!InFen methodsFor: 'accessing' stamp: 'dhn 6/18/2018 22:03:03'!
directory: anObject
	"Set the value of directory to anObject"
	
	directory _ anObject! !

!InFen methodsFor: 'accessing' stamp: 'dhn 6/23/2018 11:31:39'!
file: anObject
	"Set the value of file to anObject"
	
	file _ anObject! !

!InFen methodsFor: 'accessing' stamp: 'dhn 6/23/2018 11:27:12'!
ser: anObject
	"Set the value of ser to anObject"
	
	ser _ anObject! !

!InFen methodsFor: 'accessing' stamp: 'dhn 6/23/2018 12:26:47'!
total: anObject
	"Set the value of total to anObject"
	
	total _ anObject! !

!InFen methodsFor: 'checklist' stamp: 'dhn 6/24/2018 12:03:35'!
checkList
	"Answer a checklist of file serial numbers, in columns 'self class columnDepth' long"
	| depth cols arr ix mbrs part1 part2 element |

	depth _ self class columnDepth.
	cols _ (total / depth) ceiling.
	arr _ Array new: cols.
	ix _ (0 to: cols -1) asArray.
	mbrs _ (1 to: depth) asArray.
	1 to: cols do: [:n | | delta |
		delta _ depth * (ix at: n).
		arr at: n put: (mbrs collect: [:a | a + delta])].
	
	part1 _ arr last select: [:n | n <= total].
	part2 _ #().
	depth - part1 size timesRepeat: [part2 _ part2, {self columnPad}].
	arr at: arr size put: part1, part2.
	
	(file, '.ckl') asFileEntry forceWriteStreamDo: [:string |
		string nextPutAll: (file, '.ckl'); newLine; newLine.
		1 to: depth do: [:row |
			1 to: cols do: [:col |
				string nextPutAll: self class columnSpacer.
				(element _ (arr at: col) at: row) isNumber
					ifTrue: [element printOn: string length: self columnPad size zeroPadded: true]
					ifFalse: [string nextPutAll: element]].
			string newLine]]
! !

!InFen methodsFor: 'checklist' stamp: 'dhn 6/24/2018 11:59:57'!
columnPad
	"Answer the replacement for numbers > total in the last column"
	"The receiver's size will determine the length of every column element"
	
	^ '   '! !

!InFen class methodsFor: 'instance creation' stamp: 'dhn 6/23/2018 12:10:28'!
columnDepth
	"Answer the column length for the checklist"
	
	^ 60! !

!InFen class methodsFor: 'instance creation' stamp: 'dhn 6/23/2018 13:12:02'!
columnSpacer
	"Answer the space between columns for the checklist"
	
	^ '    '! !

!InFen class methodsFor: 'instance creation' stamp: 'dhn 6/23/2018 12:08:26'!
new: aString
	"Answer an instance of this class, initialized with the name of a relative path/file named aString.
	Example:
	
		(InFen new: 'chess/m8n/m8n2.txt') write.
	"
	| inst |
	
	inst _ self setup.
	inst file: aString.  "relative: where input and output will be"
	^ inst! !

!InFen class methodsFor: 'instance creation' stamp: 'dhn 6/23/2018 12:46:06'!
new: aString for: aNum
	"Answer an instance of this class, initialized with the name of a relative path/file named aString.
	Example:
	
		(InFen new: 'chess/m8n/m8n2' for: 221) checkList.
	"
	| inst |
	
	inst _ self setup.
	inst file: aString.  "relative: where input and output will be"

	inst total: aNum.
	^ inst! !

!InFen class methodsFor: 'instance creation' stamp: 'dhn 6/23/2018 11:55:15'!
setup
	"Establish an instance of this class"
	| x |
	
	x _ self new.
	DirectoryEntry roots.  "take no chances: ensure the base directory is '/' "
	x directory: DirectoryEntry currentDirectory.  "now at /home/<user>"
	^ x! !

!Progress methodsFor: 'operating' stamp: 'dhn 7/13/2018 19:43:12'!
percent: arr
	"Answer the 'percent' progression, computed from pairs of points in array arr"
	| odd even col ix |
	
	col _ OrderedCollection new.
	ix _ 0.
	arr do: [:ea |
		ix _ ix + 1.
		ix even
			ifTrue: [
				even _ ea.
				col addLast: (odd / (odd + even))]
			ifFalse: [odd _ ea].
		].
	^ String streamContents: [ :str |
		col do: [:p | 
			str 
				nextPutAll: (p printStringFractionDigits: 2);
				nextPut: $ ]
		]! !