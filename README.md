# Guestlogix Take Home Test - Mobile



## 1. Relevant files

**\GuestlogixTest\ViewController.swift** - main viewcontroller, containing the route search logic

**\GuestlogixTest\DataManager.swift**  - contains data related methods parsing the CSV files

**\GuestlogixTest\LayoutConstraints.swift**- contains layout constraints added dynamatically

**\GuestlogixTest\Extensions.swift** - contains all other extensions added 



## 2. Overview

###   2.1. Search logic

Each possible route found will be stored a 3-d array \nextRoutesToBeTested\, starting with the origin.

Each row will represent a single level/depth of the route, e.g. [2][0][0] and [2][1][0] are the same level/depth. [3][1][0] would be the next route.

Along the search (done in \checkPath()\), starting from the origin:

  1. All existing routes will be added to the arrays on the next row
  2. A 2nd level array will be created for each origin, and all possible destinations on the 3rd level array within the same 2nd level array
  3. Repeat for all existing entries on the array

For example, for the following routes:

A,B
A,C
A,D
B,E
B,F
C,G
C,H
D,I
E,J
F,K
G,L
G,M
H,O
H,P
I,Q

and if we are looking for the path from A to P,
the array \nextRoutesToBeTested\ would be added as follows:

[0][0]["A"]
[1][0]["B","C","D"]
[2][0]["E","F"], [2][1]["G","H"], [2][2]["I"]
[3][0]["J"], [3][1]["K"], [3][2]["L,M"], [3][3]["O","P"], [3][4]["Q"]

Search will be done in a breadth first search manner rather than depth first, starting from the first row,
and each iteration of search will go through each entry, treating each entry as the temporary origin

Once the destination has been found, the traced back which is explained in \checkPath()\ before the traversal part


###  2.2 Displaying routes

- The routes are displayed on a Google Maps mapview (Google Maps API used), with all the airports along the path marked (with basic details available when tapped on the pins, such as the name of the airport, city and country), and the paths drawn with blue lines.



## 3. Assumptions

- The search will assume there won't be more than 7 stops in any routes.
- Search will stop if the destination has not been found after going over 7 levels in the search (realistically, and also to prevent infinite loops), and will alert the users as no possible routes existing

--------------------------------------------------
