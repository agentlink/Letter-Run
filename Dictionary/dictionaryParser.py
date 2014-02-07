fileR = open('scrabbleDictionary1.txt', 'r+')
print("Finished opening file...")

min = 3
max = 7
minLength = 5 # includes two for new line char
maxLength = 9 # includes two for new line char

# Create the empty word lists
wordLists = []
for n in range (min, max + 1):
	wordLists.append([])

for line in fileR:
	wordLength = len(line) 
	#The +2 accounts for the \n character
	if wordLength >= minLength and wordLength <= maxLength:
		currentList = wordLists[wordLength - minLength]
		currentList.append(line)
	else:
		quLen = wordLength - line.count("QU")
		if quLen <= maxLength and wordLength >= minLength and wordLength == maxLength + 2:		
			#currentList = wordLists[wordLength - (minLength + endCharLen)]
			#currentList.append(line)
			print line 
fileR.close()
print("Finished loading words into arrays...")

fileW = open('organizedDict_temp.txt', 'w')
for list in wordLists:
	for word in list:
		fileW.write(word)
fileW.close()
print("Finished writing new file")