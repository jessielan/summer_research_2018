# This script will get various acoustic properties of
# all intervals of all files in the specified folder.
# The acoustic properties measured include:
# maximum F0, average F0, F1 at midpoint, F2 at midpoint,
# maximum intensity, average intensity, and duration
# Version: 10 Feb 2010
# Author: Shigeto Kawahara
# Input: TextGrid and wav in the same directory.
# They must have the same name.
# Modified 7/21/2014 by Gwen Rehrig for LALP REU 2014

form Get F0, F1, F2, intensity and duration
	# must change directory here to match where your files are
	#	using the directory field in the form will just append to this directory path
	#	i.e., C:/Users/Gwen/Praat/Practice Files/C:/Users/Gwen/Praat/Practice Files/ (won't work!)
	sentence Directory C:/Users/lalp/Documents/practice slices
	comment If you want to analyze all the files, leave this blank
	word Base_file_name
	comment The name of result file
	text textfile result.txt
endform

# Write-out the header (copy if necessary)

fileappend "'textfile$'" soundname'tab$'intervalname'tab$'F0_Max'tab$'F0_Average'tab$'First_Formant'tab$'Second_Formant'tab$'Intensity_Max'tab$'Intensity_Average'tab$'Duration
fileappend "'textfile$'" 'newline$'

#Read all files in a folder

Create Strings as file list... wavlist 'directory$'/'base_file_name$'*.wav
Create Strings as file list... gridlist 'directory$'/'base_file_name$'*.TextGrid
n = Get number of strings

for i to n
	clearinfo

	# We first extract a pitch tier, a formant tier, and an intensity tier.
	# This is the new part.

	select Strings wavlist
	filename$ = Get string... i
	Read from file... 'directory$'/'filename$'
	soundname$ = selected$ ("Sound")
	To Formant (burg)... 0 5 6000 0.025 50
	select Sound 'soundname$'
	To Pitch... 0 75 600
	select Sound 'soundname$'
	To Intensity... 100 0

	# We now read grid files and extract all intervals in them

	select Strings gridlist
	gridname$ = Get string... i
	Read from file... 'directory$'/'gridname$'
	int=Get number of intervals... 1

	# We then calculate the acoustic properties

	for k from 1 to 'int'
		select TextGrid 'soundname$'
		label$ = Get label of interval... 1 'k'
		if label$ <> ""			

			# calculates the onset, offset and midpoint
	
			onset = Get starting point... 1 'k'
			offset = Get end point... 1 'k'
			midpoint = onset + ((offset - onset) / 2)

			# calculates F0

			select Pitch 'soundname$'
			fzeromax = Get maximum... onset offset Hertz Parabolic
			fzeroaverage = Get mean... onset offset Hertz

			# calculates F1 and F2

			select Formant 'soundname$'
			fone = Get value at time... 1 'midpoint' Hertz Linear
			ftwo = Get value at time... 2 'midpoint' Hertz Linear

			# calculates intensity

			select Intensity 'soundname$'
			intensitymax = Get maximum... onset offset Parabolic
			intensityaverage = Get mean... onset offset dB

			# calculates duration

			dur = offset-onset
			resultline$ = "'soundname$''tab$''label$''tab$''fzeromax''tab$''fzeroaverage''tab$''fone''tab$''ftwo''tab$''intensitymax''tab$''intensityaverage''tab$''dur''newline$'"
			fileappend "'textfile$'" 'resultline$'
		endif
	endfor
	fileappend "'textfile$'" 'newline$'
endfor

# clean up

select all
Remove
