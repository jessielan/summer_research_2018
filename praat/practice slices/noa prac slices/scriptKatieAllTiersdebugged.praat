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
# Modified 4/9/2015 by Nic Schrum for Phonetics 451

form Get F0, F1, F2, F3, intensity and duration
	# must change directory here to match where your files are
	#	using the directory field in the form will just append to this directory path
	#	i.e., C:/Users/Gwen/Praat/Practice Files/C:/Users/Gwen/Praat/Practice Files/ (won't work!)
	sentence Directory C:/Users/Gwen/Dropbox/School/TA/Summer 2015/351-H2/Lectures/
	comment If you want to analyze all the files, leave this blank
	word Base_file_name
	comment The name of result file
	text textfile result.txt
endform

# Write-out the header (copy if necessary)

fileappend "'textfile$'" tierNumber'tab$'onset'tab$'offset'tab$'midpoint'tab$'midbottom'tab$'midtop'tab$'soundname'tab$'intervalname'tab$'F0_Max'tab$'F0_Average'tab$'midF0_max'tab$'midF0_avg'tab$'First_Formant'tab$'First_Formant_mid'tab$'Second_Formant'tab$'Second_Formant_mid'tab$'Third_Formant'tab$'Third_Formant_mid'tab$'Intensity_Max'tab$'Intensity_Max_mid'tab$'Intensity_Average'tab$'Intensity_Average_mid'tab$'Mid_Duration'tab$'Duration
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
	
		# Process data from multiple tiers
	
		# We now read grid files and extract all intervals in them

		select Strings gridlist
		gridname$ = Get string... i
		appendInfoLine: "Now processing file: ",gridname$ 
		Read from file... 'directory$'/'gridname$'
		numberOfTiers = Get number of tiers
		for tierNumber from 1 to numberOfTiers
			int = Get number of intervals... 'tierNumber'
			tierName = Get tier name... 'tierNumber'	
			appendInfoLine: "Tier: ", tierNumber," Tier Count: ", numberOfTiers," Interval Count: ", int
	
			# We then calculate the acoustic properties

			for k from 1 to 'int'
				appendInfoLine: "Interval Number: ", k
				select TextGrid 'soundname$'
				label$ = Get label of interval... 'tierNumber' 'k'
				if label$ <> ""			
	
					# calculates the onset, offset and midpoint
			
					onset = Get starting point... 'tierNumber' 'k'
					offset = Get end point... 'tierNumber' 'k'
					midpoint = onset + ((offset - onset) / 2)
					midtwothirdsbottom = onset + ((offset - onset) / 6)
					midtwothirdstop = offset - ((offset - onset) / 6)

					# calculates F0

					select Pitch 'soundname$'
					fzeromax = Get maximum... onset offset Hertz Parabolic
					fzeroaverage = Get mean... onset offset Hertz
					midfzeromax = Get maximum... midtwothirdsbottom midtwothirdstop Hertz Parabolic
					midfzeroavg = Get mean... midtwothirdsbottom midtwothirdstop Hertz

					# calculates F1 and F2

					select Formant 'soundname$'
					fone = Get value at time... 1 'midpoint' Hertz Linear
					ftwo = Get value at time... 2 'midpoint' Hertz Linear
					fthree = Get value at time... 3 'midpoint' Hertz Linear

					foneavg = Get mean... 1 midtwothirdsbottom midtwothirdstop Hertz
					ftwoavg = Get mean... 2 midtwothirdsbottom midtwothirdstop Hertz
					fthreeavg = Get mean... 3 midtwothirdsbottom midtwothirdstop Hertz


					# calculates intensity

					select Intensity 'soundname$'
					intensitymax = Get maximum... onset offset Parabolic
					intensityaverage = Get mean... onset offset dB
					midintensitymax = Get maximum... midtwothirdsbottom midtwothirdstop Parabolic
					midintensityaverage = Get mean... midtwothirdsbottom midtwothirdstop dB

					# calculates duration

					dur = offset-onset
					middur = midtwothirdstop-midtwothirdsbottom

					resultline$ = "'tierNumber''tab$''onset''tab$''offset''tab$''midpoint''tab$''midtwothirdsbottom''tab$''midtwothirdstop''tab$''soundname$''tab$''label$''tab$''fzeromax''tab$''fzeroaverage''tab$''midfzeromax''tab$''midfzeroavg''tab$''fone''tab$''foneavg''tab$''ftwo''tab$''ftwoavg''tab$''fthree''tab$''fthreeavg''tab$''intensitymax''tab$''midintensitymax''tab$''intensityaverage''tab$''midintensityaverage''tab$''middur''tab$''dur''newline$'"
					fileappend "'textfile$'" 'resultline$'
				endif
			endfor	
		endfor
		fileappend "'textfile$'" 'newline$'

	
endfor

# clean up

select all
Remove
