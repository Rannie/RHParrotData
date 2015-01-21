# RHParrotData
CoreData management lib and quick query language. 


###Usage
---

####Install

Drag "RHParrotData" folder into your project, and import "RHParrotData.h".

####Setup Database

	  NSURL *momdURL = [[NSBundle mainBundle] URLForResource:$YOUR_MOMDFILENAME withExtension:@"momd"];
	  NSURL *appDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	  NSURL *storeURL = [appDocumentsDirectory URLByAppendingPathComponent:$YOUR_DBNAME];
	  [RHDataAgent setupAgentWithMomdFile:momdURL andStoreURL:storeURL];
	  


###TODO
---
- [ ] Podspec File
- [ ] Log Util
- [ ] Swift Version

###LICENSE
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