# CFCollection

## An array wrapper for functional programming

[![Build Status](https://travis-ci.org/elpete/CFCollection.svg?branch=master)](https://travis-ci.org/elpete/CFCollection)

## WireBox Integration

If your CFML engine supports static methods (Lucee 5+), WireBox will return a method
with a static constructor and static macro support.

A few mappings are provided out-of-the-box:

#### `collection` & `collection@CFCollection`
Injecting this will give you access to an instance of Collection.  You can start with a new collection by using the `collect` function.

#### `collect` & `collect@CFCollection`
Injecting this will give you direct access to the `collect` method.

**Note:** If you are subclassing `Collection`, you will need to override this method to return your subclass.

#### `mixinLocations`
Utilizing WireBox, you can mix in arbitrary collection methods in to each of your collections.  The `mixinLocations` setting will take the contents of any `cfm` files included and mix them in to your collection.  This can be a single file, a list of files, or an array of files. (You do not need to include the extension.)

```cfc
// config/ColdBox.cfc
moduleSettings = {
    cfcollection = {
        mixinLocations = "/app/includes/macros/CFCollectionMacros"
    }
};
```

```cfm
<!--- includes/mixins/CFCollectionMixins --->
<cfscript>
function triple() {
    return this.map( function( item ) {
        return item * 3;
    } );
}
</cfscript>
```

```cfc
// handlers/main.cfc

property name="collect" inject="collect@CFCollection";

function index( event, rc, prc ) {
    var nums = collect( [ 1, 2, 3, 4, 5 ] );
    event.renderData( nums.triple().get() );
}
```

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
	name = "Collection",
	initArguments = { collection = [ 1, 2, 3, 4 ] }
);
```

### get
Returns the entire collection as an array, a specific index of the collection, or a default value if the specific index doesn't exist.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.get();

// [ 1, 2, 3, 4 ]

collection.get( 2 );

// 2

collection.get( 5, "whoops!" );

// "whoops!"
```

### toArray
Returns the value of the collection as an array.

```cfc
var collection = new Collection( [ 1, 2, 3, 4 ] );

collection.toArray();

// [ 1, 2, 3, 4 ]
```

### collect
Returns the values passed in as a new collection.  Useful in conjunction with DI containers.

```cfc
var collection = new Collection();

collection.collect(  [ 1, 2, 3, 4 ] );

collection.toArray();

// [ 1, 2, 3, 4 ]
```

### keys
Returns the keys of an object as a new collection.

```cfc
collection.keys( { "A" = 1, "B" = 2, "C" = 3 } );

// [ "A", "B", "C" ]
```

### values
Returns the values of an object as a new collection.

```cfc
collection.values( { "A" = 1, "B" = 2, "C" = 3 } );

// [ 1, 2, 3 ]
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
Shortuct for `map` to one or more keys on a struct or component.  Keys can be passed in as a comma-separated list or an array.

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

Pluck can also retrieve the values from objects with `accessors=true` in the exact same way.

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

### reject
Returns a new collection where the predicate function provided returns false.

```cfc
var collection = new Collection( [
    { label = "A", value = 1 },
    { label = "B", value = 2 },
    { label = "C", value = 3 },
    { label = "D", value = 4 }
] );

collection.reject( function( item ) {
    return item.value % 2 == 0;
} );

// [
//     { label = "A", value = 1 },
//     { label = "C", value = 3 }
// ]
```

### unique
Returns a new collection with only unique items.  The first unique item is used.  Key order is not guaranteed.
If no arguments are provided, a simple array is assumed.
If a string value is provided, the value of that column in each array item is used as the unique key.
A closure can be provided to have complete control over the unique key used.

```cfc
var collection = new Collection( [ 1, 2, 1, 1, 1, 5, 5, 3, 4 ] );

collection.unique();

// [ 1, 2, 5, 3, 4 ]
```

```cfc
var collection = new Collection( [
    { label = "A", value = 4 },
    { label = "B", value = 2 },
    { label = "A", value = 3 },
    { label = "A", value = 1 }
] );

collection.unique( "label" );
// SAME AS
collection.unique( function( item ) {
    return item.label;
} );

// [
//     { label = "A", value = 4 },
//     { label = "B", value = 2 }
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
```

### whereNot
Shortcut for `reject`.  Accepts a `[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors)
r", rank = "Captain", species = "Human" }
] );

collection.whereNot( "species", "Human" );

// [
//     { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
//     { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
// ];
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

### countWhere
Shortcut for `where` and `count`.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.countWhere( "species", "Vulcan" );

// 1
```

### countWhereNot
Shortcut for `whereNot` and `count`.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.countWhereNot( "species", "Vulcan" );

// 3
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

The key can be the name of a property. The accessor will be called behind the scenes.

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
### groupByUnique
Returns a struct similar to the groupBy() but different in that the values are expected to have a one-to-one relationship to the  key value. Items are therefore structs, not arrays of structs.

The key can be the name of any property. The key values must be unique or it will throw an exception.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.groupByUnique( "id" );

//{
// 	"1" = { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
// 	"2" = { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
// 	"3" = { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
// 	"4" = { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
//}
```
### serialize
Returns the underlying collection serialized to JSON.  Can limit the serialized properties to a passed in comma-separated list or array of keys.

```
var collection = new models.Collection( [
    { label = "A", value = 1, importance = "10" },
    { label = "B", value = 2, importance = "20" },
    { label = "C", value = 3, importance = "50" },
    { label = "D", value = 4, importance = "20" }
] );

collection.serialize( [ "value", "importance" ] );

// [{"IMPORTANCE":10,"VALUE":1},{"IMPORTANCE":20,"VALUE":2},{"IMPORTANCE":50,"VALUE":3},{"IMPORTANCE":20,"VALUE":4}]
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

### has
Returns true if any item in the collection returns true from the predicate function.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.has( function( crewMember ) {
    return crewMember.species == "Vulcan";
} );

// true
```

Can also accept a key / value pair as arguments to search.

```cfc
var collection = new models.Collection( [
    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
] );

collection.has( "species", "Vulcan" );

// true
```

### any
Alias for `has`. Returns true if any item in the collection returns true from the predicate function.


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

### range
Returns an array of numbers progressing from start up to, but not including, end. A step of -1 will be used if a negative value is specified in start and the value of end or step is undefined. If end is undefined, it's set to start with start then set to 0.

```cfc
var collection = new models.Collection();

collection.range( 4 );
// [ 0, 1, 2, 3 ]

collection.range( -4 );
// [ 0, -1, -2, -3 ]

collection.range( 1, 4 );
// [ 1, 2, 3, 4 ]

collection.range(0, 40, 10);
// [ 0, 10, 20, 30 ]

collection.range( 0, -4, -1 );
// [ 0, -1, -2, -3 ]

collection.range( 1, 4, 0 );
// [ 1, 1, 1 ]

collection.range( 0 );
// []
```

### tap
Provides a way to have side effects for collections without modifying the actual collection.

```cfc
collect( [ 1, 2, 3, 4 ] )
    .tap( function( c ) {
        writeDump( c.get() );
    } )
    .map( function( item ) {
        return item * 2;
    } )
    .tap( function( c ) {
        writeDump( c.get() );
    } )
    .filter( function( item ) {
        return item % 4 == 0;
    } )
    .tap( function( c ) {
        writeDump( c.get() );
    } );

// This would dump out:
// [ 1, 2, 3, 4 ]
// [ 2, 4, 6, 8 ]
// [ 4, 8 ]
```

### append
Adds one or more items to the end of the collection.
(Adding more than one item must be done as variadic parameters.)

```cfc
var collection = new models.Collection( [ 1, 2, 3 ] );
collection.append( 4 );
collection.append( 5, 6 );

writeDump( collection.toArray() );
// [ 1, 2, 3, 4, 5, 6 ]
```

### prepend
Adds one or more items to the beginning of the collection.
(Adding more than one item must be done as variadic parameters.)

```cfc
var collection = new models.Collection( [ 2, 3, 4 ] );
collection.prepend( 1 );

writeDump( collection.toArray() );
// [ 1, 2, 3, 4 ]
```

### pop
Removes an item from the end of the collection and return it.

```cfc
var collection = new models.Collection( [ "A", "B", "C", "D" ] );
var pop = collection.pop();

writeDump( pop );
// D
writeDump( collection.toArray() );
// [ "A", "B", "C" ]
```

### push
Add one or more items to the end of a collection.
(Alias for `append`)

```cfc
var collection = new models.Collection( [ 3, 2, 1 ] );
collection.push( "lift off!" );

writeDump( collection.get() );
// [ 3, 2, 1, "lift off!" ]
```

### shift
Removes an item from the beginning of the collection and return it.

```cfc
var collection = new models.Collection( [ "A", "B", "C", "D" ] );
var shift = collection.shift();

writeDump( shift );
// A
writeDump( collection.toArray() );
// [ "B", "C", "D" ]
```

### unshift
Add one or more items to the beginning of a collection.
(Alias for `prepend`)

```cfc
var collection = new models.Collection( [ "kiwi", "orange", "banana" ] );
collection.unshift( "apple" );

writeDump( collection.get() );
// [ "apple", "kiwi", "orange", "banana" ]
```

### splice
Modifies the contents of a collection by removing existing items and/or adding new items. Returns an array containing the removed items.

```cfc
var collection = new models.Collection( [ "Aragorn", "Boromir", "Gimli", "Legolas" ] );
var result = collection.splice( 2, 1, "Gandalf" );

writeDump( result );
// [ "Boromir" ]
writeDump( collection.get() );
// [ "Aragorn", "Gandalf", "Gimli", "Legolas" ]
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
