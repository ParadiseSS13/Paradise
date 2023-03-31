//*******************************
//
//	Library System Breakdown
//
//*******************************
/*
 * The Library
 * ------------
 * A place for the crew to go, relax, and enjoy a good book.
 * Aspiring authors can even self publish and submit it to the Archives
 * to be chronicled in history forever - some say even persisting
 * through alternate dimensions.
*/

/* DB Notes:
-We have three seperate categories columns because in a relation database you can either store things as a JSON list
or you can be able to search them. You can't have both, which is why we have a primary, secondary, and tertiary column
*/
// CONTAINS:

// Objects:
//  - bookcase
//  - book
//  - barcode scanner
// Machinery:
//  - library computer
//  - book binder
// Datum:
//	- borrowbook
//  - CachedBook
//  - Library Catalog


// Ideas for the future
// ---------------------
//  - Make library equipment emaggable
//  - Books shouldn't print straight from the library computer. Make it synch with a machine like the book binder to print instead. This should consume some sort of resource.
//  - Consider porting All wiki/iframe manuals to using MediaWiki API Calls and display using TGUI
//  - DB: put in checks to automatically prevent duplicate books from being uploaded to the Database
//  - Fully implement book fining system
