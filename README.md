# RHParrotData

[![Platform](https://cocoapod-badges.herokuapp.com/p/RHParrotData/badge.png)](http://cocoadocs.org/docsets/RHParrotData)
[![Version](https://cocoapod-badges.herokuapp.com/v/RHParrotData/badge.png)](http://cocoadocs.org/docsets/RHParrotData)

CoreData stack management and quick query language library. 

[Swift Version](https://github.com/Rannie/CoreDataParrot)

### Usage
---

#### Install

Use CocoaPods

touch a Podfile and add:
	
	pod 'RHParrotData'

Or clone this repository

Drag "RHParrotData" folder into your project, and import "RHParrotData.h".

#### Setup Database

```objc
NSURL *momdURL = [[NSBundle mainBundle] URLForResource:$YOUR_MOMDFILENAME withExtension:@"momd"];
NSURL *appDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
NSURL *storeURL = [appDocumentsDirectory URLByAppendingPathComponent:$YOUR_DBNAME];
[RHDataAgent setupAgentWithMomdFile:momdURL andStoreURL:storeURL];
```
	  
Then u can retrieve the instance of RHDataAgent by class method '*agent*'.
	  
	  
#### Query 

##### Simple Operator Query:

```objc
RHQuery *query = [RHQuery queryWithEntity:@"Person"];
[query queryKey:@"name" op:RHEqual value:@"Kobe"];
id result = [query execute];
```

Result will be a name == "Kobe" person array.

##### Query and Sort:

```objc
RHQuery *sortQuery = [RHQuery queryWithEntity:@"Person"];
[sortQuery sort:@"age" ascending:NO];
id result = [sortQuery execute];
```
	
Age will sort descending.

##### Query with Function

```objc
RHQuery *queryAverageAge = [query same];
[queryAverageAge queryKey:@"age" function:RHAverage];
id result = [queryAverageAge execute];
```

*same* means query same entity.
Result will be the average number about age;

##### Compound Query

**RHQuery** also support compound query.

```objc
- (RHQuery *)OR:(RHQuery *)anoQuery;
- (RHQuery *)AND:(RHQuery *)anoQuery;
- (RHQuery *)NOT;
```

Sample:
	
```objc
RHQuery *orQuery = [queryStart OR:query];	//"name == Kobe" query above
id result = [orQuery execute];
```

Result will be a list contains "$QUERY_START_CONDITION" or "name == Kobe" objects.

#### Data Import

Need new a RHDataImportor instance, and use:

```objc
- (void)importEntity:(NSString *)entity
         primaryKey:(NSString *)primaryKey
               data:(NSArray *)data
      insertHandler:(RHObjectSerializeHandler)insertHandler
      updateHandler:(RHObjectSerializeHandler)updateHandler;
```

It will import data in a background managedObjectContext and merge changes to the main managedObjectContext.

#### NSFetchedResultController

The class 'RHQueryResultController' is a subclass of 'NSFetchedResultController'. <br>
Use it with RHQuery:

```objc
RHQuery *query = ...
RHQueryResultController *qrc = [RHQueryResultController queryResultControllerWithQuery:query];
[qrc performQuery];
```

Or use *queryResultControllerWithQuery:sectionNameKeyPath:cacheName:* method to support section or cache.

#### Data Agent

Agent is a singleton. It's Features:

* commit changes about managed objects
* cache queries
* undo management
* memory management

Insert and update:

```objc
[[RHDataAgent agent] commit];
```
	
Delete object or objects:
	
```objc
[[RHDataAgent agent] deleteObject:objToDelete];
[[RHDataAgent agent] deleteObjects:(NSArray *)objsToDelete];
```
	
execute RHQuery:

```objc
[[RHDataAgent agent] executeQuery:query];
```

Undo management:

```objc
- (void)undo;
- (void)redo;
- (void)rollback;
- (void)reset;
```

Reduce memory:

```objc
- (void)reduceMemory;
```
	
### Query Operators
---

| **Operator Enum**   | **Comparison**   |  **Example**               |
|---------------------|------------------|--------------------------  |
| RHEqual 			  | == 				  | "name == Hanran"           |
| RHGreaterThan 		  | > 				  | "age > 20"                 |
| RHLessThan 		  	  | < 				  | "age < 40"                 |
| RHGreaterOrEqual      | >= 				  | "price >= 100"             |
| RHLessOrEqual         | <= 				  | "price <= 1000"            |
| RHNot                 | != 				  | "sex != female"            |
| RHBetween             | < lhs < 	      | "price IN 100, 1000"       |
| RHBeginsWith         | lhs start with rhs| "Terry BEGINSWITH T"       |
| RHEndsWith           | lhs end with rhs  | "Terry ENDSWITH y"         |
| RHContains           | lhs contains rhs  | "Terry CONTAINS rr"        |
| RHLike               | lhs like rhs      | "name LIKE[c] next"        |
| RHMatches            | lhs matches rhs   | "name MATCHES ^A.+e$". [Regular Expressions][1]      |
| RHIn                 | lhs in rhs        | "name IN Ben, Melissa, Nick"|


### Query Functions
---
  
| **Function Enum** | **Meaning**  |
|-------------------|--------------|
| RHMax				| max number of the column |
| RHMin			    | min number of the column |
| RHAverage			| average number			|
| RHSum				| sum number				|
| RHCount		    | row count 				|


### TODO
---
~~Podspec File~~ <br>
~~Document~~ <br>
~~NSFetchResultController~~ <br>
Log Util <br>
~~Swift Version~~ ([CoreDataParrot](https://github.com/Rannie/CoreDataParrot)) <br>
Test <br>
Complete Example <br>
FMDB Version <br>
Base ManagedObject (Serialization) <br>

### LICENSE
---

The MIT License (MIT)

Copyright (c) 2015 Hanran Liu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



[1]:http://userguide.icu-project.org/strings/regexp
