# seems to be perfect fodder for a hashtable
# record keeping is required, therefore in memory storgae seems innapropriate
# if ($names.count % 2 -ne 0) {two names to a pairing}


function Create-NameObject
{
Input: a csv file
Output: an array of name obects
}

Function ImportHistory
{
param ($path = "path to files store")
Input: $path
Output: hashtable
}

function ExportHistory
{
PAram ($path = "path to files store")
input: hastable
output: file to disk
#name should include date
}

function splitNames
{
input: [array]
Output: two [array] , key and value
}

function Randomizelists
{
input: two arrays
Output: two ordered lists ### potentialy one hashtable - this would eliminate the need for assignpairs
}

function testhistory
{
input: two ordered lists
Output: two ordered lists
# the two ordered lists would be cleared against the history according to variable criteria
}

function AssignPairs
{
input: Two ordered lists
Output: [hashtable]
}

function notifyteams
{
input: Hashtable
Output: Emails to all members with team information
}