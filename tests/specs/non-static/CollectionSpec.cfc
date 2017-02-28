component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "interop with native structures", function() {
            it( "can cast back to a native array", function() {
                var collection = new models.Collection();

                expect( collection.toArray() ).toBeArray( "Result of [toArray] should be an array." );
            } );
        } );

        describe( "instantiation", function() {
            it( "creates an empty collection by default", function() {
                var collection = new models.Collection();

                expect( collection.toArray() ).toBeEmpty( "Collection should be empty by default." );
            } );

            it( "can be instantiated with an array", function() {
                var data = [ 1, 2, 3, 4 ];

                var collection = new models.Collection( data );

                expect( collection.toArray() ).toBe( data );
            } );

            describe( "keys", function() {
                it( "returns the keys of a struct as a collection", function() {
                    var obj = { "A" = 1, "B" = 2, "C" = 3 };
                    var expected = [ "A", "B", "C" ];

                    var collection = new models.Collection();
                    collection = collection.keys( obj );

                    expect( collection.sort().toArray() ).toBe( expected );
                } );
            } );

            describe( "values", function() {
                it( "returns the values of a struct as a collection", function() {
                    var obj = { "A" = 1, "B" = 2, "C" = 3 };
                    var expected = [ 1, 2, 3 ];

                    var collection = new models.Collection();
                    collection = collection.values( obj );

                    expect( collection.sort().toArray() ).toBe( expected );
                } );
            } );

            it( "can be instantiated with a query (which it converts to an array of structs)", function() {
                var data = [
                    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
                ];
                var qry = queryNew( "id,name,rank,species", "cf_sql_integer,cf_sql_varchar,cf_sql_varchar,cf_sql_varchar", data );

                var collection = new models.Collection( qry );

                expect( collection.toArray() ).toBe( data, "Collection should have been converted from a query to an array." );
            } );

            it( "duplicates the original structure passed in", function() {
                var data = [ 1, 2, 3, 4 ];

                var collection = new models.Collection( data );
                data = [ 2, 3, 4, 5 ];

                expect( collection.toArray() ).notToBe( data );
            } );
        } );

        describe( "collection functions", function() {
            it( "each", function() {
                var data = [ 1, 2, 3, 4 ];

                var collection = new models.Collection( data );
                var executed = [];
                collection.each( function( num ) { 
                    arrayAppend( executed, num );
                } );

                expect( executed ).toHaveLength( 4, "Each number should have been called." );
            } );

            describe( "map", function() {
                it( "maps over a collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = [ 2, 4, 6, 8 ];

                    var collection = new models.Collection( data );
                    collection = collection.map( function( num ) {
                        return num * 2;
                    } );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "provides the current index in the loop", function() {
                    var data = [ "hi", "hello", "howdy", "hey" ];
                    var expected = [ 1, 2, 3, 4 ];

                    var indexes = [];
                    var collection = new models.Collection( data );
                    collection.map( function( item, i ) {
                        arrayAppend( indexes, i );
                        return item;
                    } );

                    expect( indexes ).toBe( expected );
                } );
            } );

            describe( "pluck", function() {
                it( "plucks a single value from a collection", function() {
                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    
                    expect( collection.pluck( "value" ).toArray() ).toBe( expected );
                } );

                it( "can pluck a list of values from a collection", function() {
                    var data = [
                        { label = "A", value = 1, importance = "10" },
                        { label = "B", value = 2, importance = "20" },
                        { label = "C", value = 3, importance = "50" },
                        { label = "D", value = 4, importance = "20" }
                    ];
                    var expected = [
                        { value = 1, importance = "10" },
                        { value = 2, importance = "20" },
                        { value = 3, importance = "50" },
                        { value = 4, importance = "20" }
                    ];

                    var collection = new models.Collection( data );
                    
                    expect( collection.pluck( "value,importance" ).toArray() ).toBe( expected );
                } );

                it( "can pluck an array of values from a collection", function() {
                    var data = [
                        { label = "A", value = 1, importance = "10" },
                        { label = "B", value = 2, importance = "20" },
                        { label = "C", value = 3, importance = "50" },
                        { label = "D", value = 4, importance = "20" }
                    ];
                    var expected = [
                        { value = 1, importance = "10" },
                        { value = 2, importance = "20" },
                        { value = 3, importance = "50" },
                        { value = 4, importance = "20" }
                    ];

                    var collection = new models.Collection( data );
                    
                    expect( collection.pluck( [ "value", "importance" ] ).toArray() ).toBe( expected );
                } );
            } );

            describe( "flatten", function() {
                it( "flattens infinite layers by default", function() {
                    var data = [
                        [ 1, 2, 3 ],
                        [ 4, [ 5, 6 ] ],
                        [ 7 ]
                    ];
                    var expected = [ 1, 2, 3, 4, 5, 6, 7 ];

                    var collection = new models.Collection( data );

                    expect( collection.flatten().toArray() ).toBe( expected );
                } );

                it( "can specify how many layers to flatten", function() {
                    var data = [
                        [ 1, 2, 3 ],
                        [ 4, [ 5, 6 ] ],
                        [ 7 ]
                    ];
                    var expected = [ 1, 2, 3, 4, [ 5, 6 ], 7 ];

                    var collection = new models.Collection( data );

                    expect( collection.flatten( 1 ).toArray() ).toBe( expected );
                } );
            } );

            it( "flatMap", function() {
                var data = [
                    { x = 1, y = 2 },
                    { x = 3, y = 4 },
                    { x = 5, y = 6 }
                ];
                var expected = [ 1, 2, 3, 4, 5, 6 ];

                var collection = new models.Collection( data );
                collection = collection.flatMap( function( point ) {
                    return [ point.x, point.y ];
                } );

                expect( collection.toArray() ).toBe( expected );  
            } );

            it( "filter", function() {
                var data = [
                    { label = "A", value = 1 },
                    { label = "B", value = 2 },
                    { label = "C", value = 3 },
                    { label = "D", value = 4 }
                ];
                var expected = [
                    { label = "B", value = 2 },
                    { label = "D", value = 4 }
                ];

                var collection = new models.Collection( data );
                collection = collection.filter( function( item ) {
                    return item.value % 2 == 0;
                } );
                expect( collection.toArray() ).toBe( expected );
            } );

            describe( "unique", function() {
                it( "filters out duplicate items", function() {
                    var data = [ 1, 2, 1, 1, 1, 4, 3, 4 ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection = collection.unique();

                    expect( collection.sort().toArray() ).toBe( expected );
                } );

                it( "can return unique items based on a key", function() {
                    var data = [
                        { label = "A", value = 4 },
                        { label = "B", value = 2 },
                        { label = "A", value = 3 },
                        { label = "A", value = 4 }
                    ];
                    var expected = [
                        { label = "A", value = 4 },
                        { label = "B", value = 2 }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.unique( "label" );
                    expect( collection.sort( "label" ).toArray() ).toBe( expected );
                } );

                it( "can return unique items based on the return value of a closure", function() {
                    var data = [
                        { label = "A", value = 4 },
                        { label = "B", value = 2 },
                        { label = "A", value = 3 },
                        { label = "A", value = 4 }
                    ];
                    var expected = [
                        { label = "A", value = 4 },
                        { label = "B", value = 2 }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.unique( function( row ) {
                        return row.label;
                    } );
                    expect( collection.sort( "label" ).toArray() ).toBe( expected );
                } );
            } );

            it( "reverse", function() {
                var data = [ 1, 2, 3, 4 ];
                var expected = [ 4, 3, 2, 1];

                var collection = new models.Collection( data );
                expect( collection.reverse().toArray() ).toBe( expected );
            } );

            describe( "zip", function() {
                it( "zips together two arrays", function() {
                    var data = [ 1, 2, 3 ];
                    var zipWith = [ 4, 5, 6 ];
                    var expected = [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ];

                    var collection = new models.Collection( data );
                    collection = collection.zip( zipWith );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can accept a projection function to influence the return result", function() {
                    var data = [ 1, 2, 3 ];
                    var zipWith = [ 4, 5, 6 ];
                    var expected = [ 5, 7, 9 ];

                    var collection = new models.Collection( data );
                    collection = collection.zip( zipWith, function( item1, item2 ) {
                        return item1 + item2;
                    } );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "throws an exception if the arrays are different lengths", function() {
                    var data = [ 1, 2, 3 ];
                    var zipWith = [ 4, 5 ];

                    var collection = new models.Collection( data );

                    expect( function() {
                        collection.zip( zipWith );
                    } ).toThrow( "CollectionLengthMismatch" );
                } );
            } );

            describe( "groupBy", function() {
                it( "can group values by a given key", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = {
                        "Captain" = [
                            { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                            { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                        ],
                        "Commander" = [
                            { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" }
                        ],
                        "Constable" = [
                            { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
                        ]
                    };

                    var collection = new models.Collection( data );
                    var actual = collection.groupBy( "rank" );

                    expect( actual ).toBe( expected );
                } );
            } );

            it( "transpose", function() {
                var data = [
                    [ "James T. Kirk", "Spock", "Odo", "Jonathan Archer" ],
                    [ "Captain", "Commander", "Constable", "Captain" ],
                    [ "Human", "Vulcan", "Changeling", "Human" ]
                ];
                var expected = [
                    [ "James T. Kirk", "Captain", "Human" ],
                    [ "Spock", "Commander", "Vulcan" ],
                    [ "Odo", "Constable", "Changeling" ],
                    [ "Jonathan Archer", "Captain", "Human" ]
                ];

                var collection = new models.Collection( data );

                expect( collection.transpose().toArray() ).toBe( expected );
            } );

            describe( "sort", function() {
                it( "sorts using a text sort type by default", function() {
                    var data = [ 2, 4, 3, 1 ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );

                    expect( collection.sort().toArray() ).toBe( expected );
                } );

                it( "can accept a callback function that sorts", function() {
                    var data = [
                        { label = "B", value = 2 },
                        { label = "D", value = 4 },
                        { label = "C", value = 3 },
                        { label = "A", value = 1 }
                    ];

                    var expected = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.sort( function( itemA, itemB ) {
                        return compare( itemA.value, itemB.value );
                    } );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can sort based on a key", function() {
                    var data = [
                        { label = "B", value = 2 },
                        { label = "D", value = 4 },
                        { label = "C", value = 3 },
                        { label = "A", value = 1 }
                    ];

                    var expected = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];

                    var collection = new models.Collection( data );

                    expect( collection.sort( "value" ).toArray() ).toBe( expected );
                } );
            } );

            describe( "merge", function() {
                it( "can merge in another array", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var dataToAdd = [ 5, 6, 7, 8 ];
                    var expected = [ 1, 2, 3, 4, 5, 6, 7, 8 ];

                    var collection = new models.Collection( data );
                    collection = collection.merge( dataToAdd );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can merge in another collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var dataToAdd = [ 5, 6, 7, 8 ];
                    var expected = [ 1, 2, 3, 4, 5, 6, 7, 8 ];

                    var collection = new models.Collection( data );
                    var otherCollection = new models.Collection( dataToAdd );
                    collection = collection.merge( otherCollection );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "slice", function() {
                it( "can slice from a position for a given length", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = [ 2, 3 ];

                    var collection = new models.Collection( data );
                    collection = collection.slice( 2, 2 );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "slices to the end if no length is given", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = [ 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection = collection.slice( 2 );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "chunk", function() {
                it( "chunks an array given a size", function() {
                    var data = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];
                    var expected = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ];

                    var collection = new models.Collection( data );
                    collection = collection.chunk( 3 );

                    expect( collection.toArray() ).toBeArray();
                    expect( collection.toArray() ).toHaveLength( 3 );
                    expect( collection.toArray()[1] ).toHaveLength( 3 );
                    expect( collection.toArray()[2] ).toHaveLength( 3 );
                    expect( collection.toArray()[3] ).toHaveLength( 3 );
                } );

                it( "adds the remaining values to the last chunk even if it is not the chunk size", function() {
                    var data = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ];
                    var expected = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10, 11 ] ];

                    var collection = new models.Collection( data );
                    collection = collection.chunk( 3 );

                    expect( collection.toArray() ).toBeArray();
                    expect( collection.toArray() ).toHaveLength( 4 );
                    expect( collection.toArray()[1] ).toHaveLength( 3 );
                    expect( collection.toArray()[2] ).toHaveLength( 3 );
                    expect( collection.toArray()[3] ).toHaveLength( 3 );
                    expect( collection.toArray()[4] ).toHaveLength( 2 );
                } );
            } );

            describe( "where", function() {
                it( "is a shortcut for filter for a key and value pair", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.where( "species", "Human" );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can accept an array of values to check against ( like an IN statement)", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.where( "species", [ "Human", "Vulcan" ] );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can also accept a list instead of an array of values", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.where( "species", "Human, Vulcan" );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "tap", function() {
                it( "returns the collection unchanged no matter what code is ran inside the callback", function() {
                    var data = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    var actual = collection.tap( function( c ) {
                        debug( c.toArray() );
                        var doubled = c.map( function( item ) {
                            // This code runs, but should not change the collection.
                            return item * 2;
                        } );
                        debug( doubled.toArray() );
                        return doubled;
                    } );

                    expect( actual ).toBeInstanceOf( "models.Collection", "A collection should be returned" );
                    expect( actual ).toBe( collection, "The same collection should be returned" );
                    expect( actual.toArray() ).toBe( data );
                    expect( getDebugBuffer() ).toHaveLength( 2, "The callback should have called the debug method twice." );
                    expect( getDebugBuffer()[ 1 ].data ).toBe( [ 1, 2, 3, 4 ] );
                    expect( getDebugBuffer()[ 2 ].data ).toBe( [ 2, 4, 6, 8 ] );
                } );
            } );
        } );

        describe( "functions that return a non-collection value", function() {
            it( "reduce", function() {
                var data = [ 1, 2, 3, 4 ];
                var expected = 10;

                var collection = new models.Collection( data );
                var actual = collection.reduce( function( acc, num ) {
                    return acc + num;
                }, 0 );

                expect( actual ).toBe( expected );
            } );

            describe( "serialize", function() {
                it( "serializes the collection in to JSON", function() {
                    var data = [
                        { label = "A", value = 1, importance = "10" },
                        { label = "B", value = 2, importance = "20" },
                        { label = "C", value = 3, importance = "50" },
                        { label = "D", value = 4, importance = "20" }
                    ];
                    var expected = '[{"IMPORTANCE":10,"LABEL":"A","VALUE":1},{"IMPORTANCE":20,"LABEL":"B","VALUE":2},{"IMPORTANCE":50,"LABEL":"C","VALUE":3},{"IMPORTANCE":20,"LABEL":"D","VALUE":4}]';

                    var collection = new models.Collection( data );
                    
                    expect( deserializeJSON( collection.serialize() ) )
                        .toBe( deserializeJSON( expected ) );
                } );

                it( "can limit serialization to one or more columns passed in as a list or an array", function() {
                    var data = [
                        { label = "A", value = 1, importance = "10" },
                        { label = "B", value = 2, importance = "20" },
                        { label = "C", value = 3, importance = "50" },
                        { label = "D", value = 4, importance = "20" }
                    ];
                    var expected = '[{"IMPORTANCE":10,"VALUE":1},{"IMPORTANCE":20,"VALUE":2},{"IMPORTANCE":50,"VALUE":3},{"IMPORTANCE":20,"VALUE":4}]';

                    var collection = new models.Collection( data );
                    
                    expect( deserializeJSON( collection.serialize( [ "value", "importance" ] ) ) )
                        .toBe( deserializeJSON( expected ) );
                } );
            } );

            describe( "count methods", function() {
                it( "count", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 4;

                    var collection = new models.Collection( data );
                    var actual = collection.count();

                    expect( actual ).toBe( expected );
                } );

                describe( "aliases", function() {
                    it( "length", function() {
                        var data = [ 1, 2, 3, 4 ];
                        var expected = 4;

                        var collection = new models.Collection( data );
                        var actual = collection.length();

                        expect( actual ).toBe( expected );
                    } );

                    it( "size", function() {
                        var data = [ 1, 2, 3, 4 ];
                        var expected = 4;

                        var collection = new models.Collection( data );
                        var actual = collection.size();

                        expect( actual ).toBe( expected );
                    } );
                } );
            } );

            describe( "first", function() {
                it( "returns the first element of the collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 1;

                    var collection = new models.Collection( data );
                    var actual = collection.first();

                    expect( actual ).toBe( expected );
                } );

                it( "can return a default value if the collection is empty", function() {
                    var collection = new models.Collection();
                    var expected = 5;
                    
                    var actual = collection.first( defaultValue = 5 );
                    expect( actual ).toBe( expected );
                } );

                it( "can return a default value if no items match the predicate", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 5;

                    var collection = new models.Collection( data );
                    var actual = collection.first( function( num ) {
                        return num > 4;
                    }, 5 );

                    expect( actual ).toBe( expected );
                } );

                it( "can accept a function for the default value", function() {
                    var collection = new models.Collection();
                    var expected = "Hello World!";
                    
                    var actual = collection.first( defaultValue = function() {
                        return "Hello World!";
                    } );
                    expect( actual ).toBe( expected );
                } );

                it( "throws an exception if the collection is empty", function() {
                    var collection = new models.Collection();
                    
                    expect( function() {
                        var actual = collection.first();
                    } ).toThrow( "CollectionIsEmpty" );
                } );

                it( "can accept a predicate and returns the first value to return true from the predicate", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 3;

                    var collection = new models.Collection( data );
                    var actual = collection.first( function( num ) {
                        return num > 2;
                    } );

                    expect( actual ).toBe( expected );
                } );
            } );

            describe( "last", function() {
                it( "returns the last element of the collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 4;

                    var collection = new models.Collection( data );
                    var actual = collection.last();

                    expect( actual ).toBe( expected );
                } );

                it( "can return a default value if the collection is empty", function() {
                    var collection = new models.Collection();
                    var expected = 5;
                    
                    var actual = collection.last( defaultValue = 5 );
                    expect( actual ).toBe( expected );
                } );

                it( "can return a default value if no items match the predicate", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 5;

                    var collection = new models.Collection( data );
                    var actual = collection.last( function( num ) {
                        return num > 4;
                    }, 5 );

                    expect( actual ).toBe( expected );
                } );

                it( "can accept a function for the default value", function() {
                    var collection = new models.Collection();
                    var expected = "Hello World!";
                    
                    var actual = collection.last( defaultValue = function() {
                        return "Hello World!";
                    } );
                    expect( actual ).toBe( expected );
                } );

                it( "throws an exception if the collection is empty", function() {
                    var collection = new models.Collection();
                    
                    expect( function() {
                        var actual = collection.last();
                    } ).toThrow( "CollectionIsEmpty" );
                } );

                it( "can accept a closure and returns the last value to return true from the closure", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 2;

                    var collection = new models.Collection( data );
                    var actual = collection.last( function( num ) {
                        return num < 3;
                    } );

                    expect( actual ).toBe( expected );
                } );
            } );

            describe( "sum", function() {
                it( "sums the values of the collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 10;

                    var collection = new models.Collection( data );
                    var actual = collection.sum();

                    expect( actual ).toBe( expected );
                } );

                it( "can accept an optional field to sum by", function() {
                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = 10;

                    var collection = new models.Collection( data );
                    var actual = collection.sum( "value" );
                    expect( actual ).toBe( expected );  
                } );

                it( "doesn't modify the original collection when summing", function() {
                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = 10;

                    var collection = new models.Collection( data );
                    var sum = collection.sum( "value" );
                    expect( sum ).toBe( expected );
                    expect( collection.toArray() ).toBe( data );
                } );
            } );

            describe( "avg (average)", function() {
                it( "averages the values of the collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = 2.5;

                    var collection = new models.Collection( data );

                    expect( collection.avg() ).toBe( expected );
                    expect( collection.average() ).toBe( expected );
                } );

                it( "can accept an optional field to average by", function() {
                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = 2.5;

                    var collection = new models.Collection( data );
                    var actual = collection.avg( "value" );
                    expect( actual ).toBe( expected );  
                } );

                it( "doesn't modify the original collection when averaging", function() {
                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = 2.5;

                    var collection = new models.Collection( data );
                    var avg = collection.avg( "value" );
                    expect( avg ).toBe( expected );
                    expect( collection.toArray() ).toBe( data );
                } );
            } );

            it( "join", function() {
                var data = [ "Hello", "world" ];
                var expected = "Hello, world";

                var collection = new models.Collection( data );
                var actual = collection.join( ", " );

                expect( actual ).toBe( expected );
            } );

            it( "pipe", function() {
                var data = [ "Hello", "world" ];

                var isCollection = false;
                var collection = new models.Collection( data );
                var actual = collection.pipe( function( greetings ) {
                    isCollection = isInstanceOf( greetings, "models.Collection" );
                } );

                expect( isCollection ).toBeTrue( "The value passed in to the pipe callback should be a Collection." );
            } );

            it( "has", function() {
                var data = [
                    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                ];

                var collection = new models.Collection( data );
                var actual = collection.has( function( crewMember ) {
                    return crewMember.species == "Vulcan";
                } );

                expect( actual ).toBeTrue();
            } );

            it( "any (alias for has)", function() {
                var data = [
                    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                ];

                var collection = new models.Collection( data );
                var actual = collection.any( function( crewMember ) {
                    return crewMember.species == "Vulcan";
                } );

                expect( actual ).toBeTrue();
            } );

            it( "every", function() {
                var data = [
                    { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                    { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                    { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                    { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                ];

                var collection = new models.Collection( data );
                var actual = collection.every( function( crewMember ) {
                    return crewMember.species == "Human";
                } );

                expect( actual ).toBeFalse();

                collection = collection.filter( function( crewMember ) {
                    return crewMember.species == "Human";
                } );
                actual = collection.every( function( crewMember ) {
                    return crewMember.species == "Human";
                } );

                expect( actual ).toBeTrue();
            } );
        } );
    }

}