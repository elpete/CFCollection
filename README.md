# CFCollection

## An array wrapper for functional programming

[![Build Status](https://travis-ci.org/elpete/CFCollection.svg?branch=master)](https://travis-ci.org/elpete/CFCollection)

## WireBox Integration

If your CFML engine supports static methods (Lucee 5+), WireBox will return a method
with a static constructor and static macro support. 👍

## Methods

### init
Create a new collection.
Can accept a list, array, or query.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );
// OR
var collection = Collection::make( [ 1, 2, 3, 4 ] );
// OR
var collection = wirebox.getInstance(
	dsl = "Collection",
	initArgs = { collection = [ 1, 2, 3, 4 ] }
);
```

### toArray
Returns the value of the collection as an array.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.toArray();

// [ 1, 2, 3, 4 ]
```

### each
Loops over each value in the collection.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.each( function( item ) {
	writeOutput( "Item is #item#. " );
} );

// Item is 1. Item is 2. Item is 3. Item is 4.
```

### map
Creates a new collection by applying a projection function to each item in the collection.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.map( function( item ) {
	return item * 2
} );

// [ 2, 4, 6, 8 ]
```

### flatMap
Creates a new collection by applying a projection function to each item in the collection
and then flattening the collection by one level.

```cfc
var collection = new Collection( [ { x = 1, y = 2 }, { x = 1, y = 3 } ] );

collection.flatMap( function( point ) {
	return [ point.x, point.y ];
} );

// [ 1, 2, 1, 3 ]
```

### flatten
Flattens a multi-dimensional array.  It can accept a number of levels to flatten, or it flattens all levels by default.

```cfc
var collection = new Collection( [ [ 1, 2, 3 ], [ 4, [ 5, 6 ] ], [ 7 ] ] );

collection.flatten();

// [ 1, 2, 3, 4, 5, 6, 7 ]
```

### pluck
Shortuct for `map` to a specific key on a struct.

```cfc
var collection = new Collection( [
    { label = "A", value = 1 },
    { label = "B", value = 2 },
    { label = "C", value = 3 },
    { label = "D", value = 4 }
] );

collection.pluck( "value" );

// [ 1, 2, 3, 4 ]
```

### filter
Returns a new collection where the predicate function provided returns true.

```cfc
var collection = new Collection( [
    { label = "A", value = 1 },
    { label = "B", value = 2 },
    { label = "C", value = 3 },
    { label = "D", value = 4 }
] );

collection.filter( function( item ) {
    return item.value % 2 == 0;
} );

// [
//     { label = "B", value = 2 },
//     { label = "D", value = 4 }
// ]
```

### reverse
Reverses the order of the collection.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.reverse();

// [ 4, 3, 2, 1 ]
```

### zip
Combines the values from two arrays in to a tuple.  It can optionally accept a projection function to influence the result returned.

```cfc
var collection = new Collection( [ 1, 2, 3 ] );

collection.zip( [ 4, 5, 6 ] );

// [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ];
```

### transpose
Transposes the values in a multi-dimensional array.  Useful for array form inputs (like `name[]`).

```cfc
var collection = new Collection( [
    [ "James T. Kirk", "Spock", "Odo", "Jonathan Archer" ],
    [ "Captain", "Commander", "Constable", "Captain" ],
    [ "Human", "Vulcan", "Changeling", "Human" ]
] );

collection.transpose();

// [
//     [ "James T. Kirk", "Captain", "Human" ],
//     [ "Spock", "Commander", "Vulcan" ],
//     [ "Odo", "Constable", "Changeling" ],
//     [ "Jonathan Archer", "Captain", "Human" ]
// ]
```

### sort
Sorts the collection.  Uses a simple `compare` if no callback function is provided.  Can also accept a single string `key` to compare simple structs.

```cfc
var collection = new Collection( [
    { label = "B", value = 2 },
    { label = "D", value = 4 },
    { label = "C", value = 3 },
    { label = "A", value = 1 }
] );

collection.sort( function( item1, item2 ) {
	return compare( item1.value, item2.value );
} );
// SAME AS
collection.sort( "value" );

// [
//     { label = "A", value = 1 },
//     { label = "B", value = 2 },
//     { label = "C", value = 3 },
//     { label = "D", value = 4 }
// ]
```

### merge
Returns a new collection with the values of another array or Collection added to it.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );
var anotherCollection = new Collection( [ 5, 6, 7, 8 ] );

collection.merge( anotherCollection );

// [ 1, 2, 3, 4, 5, 6, 7, 8 ]
```

### slice
Returns a subset of the collection, starting at the given index and going either to the end of the collection or for the specified number of items.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.slice( 2, 3 );
// SAME AS
collection.slice( 2 );

// [ 2, 3, 4 ]
```

### chunk
Breaks a collection up in to chunks with the specified length.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ] );

collection.chunk( 3 );

// [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]
```

### where
Shortcut for `filter`.  Accepts a `key` and `value` to filter down the collection by.
`value` can be a single value, a list, or an array of values where the collection value can match any of the values provided.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.where( "species", "Human" );

// [
//     { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
//     { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
// ];

var collection = new models.Collection( data );

expect( collection.toArray() ).toBe( expected );
```


### empty
Returns whether the collection is empty.

```cfc
var collection = new models.Collection();

collection.empty();

// true
```

### first
Returns the first element in the collection.
Can optionally accept a predicate function which will then return the first element that returns true from the predicate function.
Can also accept a default value to use when the collection is either empty or no element satisfies the predicate function.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.first();

// 1
```

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.first( function( num ) {
    return num > 4;
}, 5 );

// 5
```

### last
Returns the last element in the collection.
Can optionally accept a predicate function which will then return the last element that returns true from the predicate function.
Can also accept a default value to use when the collection is either empty or no element satisfies the predicate function.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.last();

// 4
```

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.last( function( num ) {
    return num > 2;
}, 5 );

// 4
```

### count
Returns the number of elements in the collection.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.count();

// 4
```

### length
Alias for `count`.  Returns the number of elements in the collection.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.length();

// 4
```

### size
Alias for `count`.  Returns the number of elements in the collection.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.size();

// 4
```

### reduce
Applies a function against an accumulator and each value of the collection.  The default value of the accumulator is the first value of the collection.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.reduce( function( acc, num ) {
    return acc + num;
}, 0 );

// 10
```


### groupBy
Returns a struct where the keys are the value of the field passed in and the values are collection items that share the same value of the given key.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.groupBy( "rank" );

// {
//     "Captain" = [
//         { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
//         { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
//     ],
//     "Commander" = [
//         { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
//     ],
//     "Constable" = [
//         { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
//     ]
// }
```


### sum
Sums the values of a collection.  Can accept an optional field to sum by.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.sum();

// 10
```

```cfc
var collection = new models.Collection( [
    { label = "A", value = 1 },
    { label = "B", value = 2 },
    { label = "C", value = 3 },
    { label = "D", value = 4 }
] );

collection.sum( "value" );

// 10
```

### avg
Averages the values of a collection.  Can accept an optional field to average by.

```cfc
var collection = new models.Collection( [ 1, 2, 3, 4 ] );

collection.sum();

// 2.5
```

```cfc
var collection = new models.Collection( [
    { label = "A", value = 1 },
    { label = "B", value = 2 },
    { label = "C", value = 3 },
    { label = "D", value = 4 }
] );

collection.sum( "value" );

// 2.5
```

### average
Alias for `avg`.  Averages the values of a collection.  Can accept an optional field to average by.


### join
Joins the elements of a collection in to a string with a given delimiter.

```cfc
var collection = new models.Collection( [ "Hello", "world" ] );

collection.join( ", " );

// "Hello, world"
```

### pipe
Passes the collection in to the callback specified and returns the result returned from the callback.
Allows for easier chaining of non-collection methods.

```cfc
var scores = [ 96, 94, 85, 67, 55, 98, 72 ];
var collection = new models.Collection( scores );

function mapScoresToGrades( scores ) {
    return scores.map( function( score ) {
        if ( score >= 90 ) { return "A"; }
        else if ( score >= 80 ) { return "B"; }
        else if ( score >= 70 ) { return "C"; }
        else if ( score >= 66 ) { return "D"; }
        else { return "F"; }
    } );
}

collection.pipe( function( collection ) {
    return mapScoresToGrades( collection );
} );

// [ "A", "A", "B", "D", "F", "A", "C" ]
```

### contains
Returns true if any item in the collection returns true from the predicate function.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.contains( function( crewMember ) {
    return crewMember.species == "Vulcan";
} );

// true
```

### any
Alias for `contains`. Returns true if any item in the collection returns true from the predicate function.


### every
Returns true if every item in the collection returns true from the predicate function.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.every( function( crewMember ) {
    return crewMember.species == "Human";
} );

// false
```

## Static Support

If your CFML engine supports static scopes and functions, you have some additional functionality available to you in the `MacroableCollection` component.  This component will be returned by default if you are using WireBox.

### make
Returns a new instance of the component.  Syntactic sugar for `new Collection`

```cfc
var collection = Collection::make( [ 1, 2, 3, 4 ] );

// [ 1, 2, 3, 4 ]
```

### macro
Extends the functionality of every Collection instance with the new method.  You have access to the current collection using the `this` keyword as well as any arguments passed in the function.

```cfc
Collection::macro( "max", function() {
	if ( this.empty() ) {
		return 0;
	}

	var max = this.first();

	this.each( function( item ) {
		if ( item > max ) {
			max = item;
		}
	} );

	return max;
} );

var collection = Collection::make( [ 4, 4, 2, 6, 1, 3, 1 ] );

collection.max();

// 6
```