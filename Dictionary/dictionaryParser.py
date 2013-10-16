fileR = open('scrabbleDictionary1.txt', 'r+')
print("Finished opening file...")

minLength = 3
maxLength = 7

# Create the empty word lists
wordLists = []
for n in range (minLength, maxLength + 1):
	wordLists.append([])

for line in fileR:
	wordLength = len(line)
	#The +2 accounts for the \n character
	if wordLength >= minLength + 2 and wordLength <= maxLength + 2:
		currentList = wordLists[wordLength - (minLength + 2)]
		currentList.append(line)
fileR.close()
print("Finished loading words into arrays...")

fileW = open('organizedDict.txt', 'w')
for list in wordLists:
	for word in list:
		fileW.write(word)
fileW.close()
print("Finished writing new file")