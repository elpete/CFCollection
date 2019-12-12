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

                expect( collection.get() ).toBeEmpty( "Collection should be empty by default." );
            } );

            it( "can be instantiated with an array", function() {
                var data = [ 1, 2, 3, 4 ];

                var collection = new models.Collection( data );

                expect( collection.get() ).toBe( data );
            } );

            it( "can return a new collection from the `collect` function", function() {
                var data = [ 1, 2, 3, 4 ];
                var collection = createObject( "component", "models.Collection" ).collect( data );

                expect( collection.get() ).toBe( data );
            } );

            it( "returns the passed in value untouched if it is already a collection", function() {
                var data = [ 1, 2, 3, 4 ];
                var originalCollection = new models.Collection( data );

                var newCollection = new models.Collection( originalCollection );

                debug( newCollection );
                expect( newCollection ).toBe( originalCollection );
            } );

            describe( "keys", function() {
                it( "returns the keys of a struct as a collection", function() {
                    var obj = { "A" = 1, "B" = 2, "C" = 3 };
                    var expected = [ "A", "B", "C" ];

                    var collection = new models.Collection();
                    collection = collection.keys( obj );

                    expect( collection.sort().get() ).toBe( expected );
                } );
            } );

            describe( "values", function() {
                it( "returns the values of a struct as a collection", function() {
                    var obj = { "A" = 1, "B" = 2, "C" = 3 };
                    var expected = [ 1, 2, 3 ];

                    var collection = new models.Collection();
                    collection = collection.values( obj );

                    expect( collection.sort().get() ).toBe( expected );
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

                expect( collection.get() ).toBe( data, "Collection should have been converted from a query to an array." );
            } );

            it( "duplicates the original structure passed in", function() {
                var data = [ 1, 2, 3, 4 ];

                var collection = new models.Collection( data );
                data = [ 2, 3, 4, 5 ];

                expect( collection.get() ).notToBe( data );
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

                    expect( collection.get() ).toBe( expected );
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

                    expect( collection.pluck( "value" ).get() ).toBe( expected );
                } );

                it( "plucks values out of objects with accessor methods", function() {
                    var data = [
                        new tests.resources.PluckComponent( label = "A", value = 1 ),
                        new tests.resources.PluckComponent( label = "B", value = 2 ),
                        new tests.resources.PluckComponent( label = "C", value = 3 ),
                        new tests.resources.PluckComponent( label = "D", value = 4 )
                    ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );

                    expect( collection.pluck( "value" ).get() ).toBe( expected );
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

                    expect( collection.pluck( "value,importance" ).get() ).toBe( expected );
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

                    expect( collection.pluck( [ "value", "importance" ] ).get() ).toBe( expected );
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

                    expect( collection.flatten().get() ).toBe( expected );
                } );

                it( "can specify how many layers to flatten", function() {
                    var data = [
                        [ 1, 2, 3 ],
                        [ 4, [ 5, 6 ] ],
                        [ 7 ]
                    ];
                    var expected = [ 1, 2, 3, 4, [ 5, 6 ], 7 ];

                    var collection = new models.Collection( data );

                    expect( collection.flatten( 1 ).get() ).toBe( expected );
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

                expect( collection.get() ).toBe( expected );
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
                expect( collection.get() ).toBe( expected );
            } );

            describe( "reject", function() {
                it( "returns a collection of values that did NOT pass the predicate function", function() {
                    var data = [
                        { label = "A", value = 1 },
                        { label = "B", value = 2 },
                        { label = "C", value = 3 },
                        { label = "D", value = 4 }
                    ];
                    var expected = [
                        { label = "A", value = 1 },
                        { label = "C", value = 3 }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.reject( function( item ) {
                        return item.value % 2 == 0;
                    } );
                    expect( collection.get() ).toBe( expected );
                } );
            } );

            describe( "unique", function() {
                it( "filters out duplicate items", function() {
                    var data = [ 1, 2, 1, 1, 1, 4, 3, 4 ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection = collection.unique();

                    expect( collection.sort().get() ).toBe( expected );
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
                    expect( collection.sort( "label" ).get() ).toBe( expected );
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
                    expect( collection.sort( "label" ).get() ).toBe( expected );
                } );
            } );

            it( "reverse", function() {
                var data = [ 1, 2, 3, 4 ];
                var expected = [ 4, 3, 2, 1];

                var collection = new models.Collection( data );
                expect( collection.reverse().get() ).toBe( expected );
            } );

            describe( "zip", function() {
                it( "zips together two arrays", function() {
                    var data = [ 1, 2, 3 ];
                    var zipWith = [ 4, 5, 6 ];
                    var expected = [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ];

                    var collection = new models.Collection( data );
                    collection = collection.zip( zipWith );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "can accept a projection function to influence the return result", function() {
                    var data = [ 1, 2, 3 ];
                    var zipWith = [ 4, 5, 6 ];
                    var expected = [ 5, 7, 9 ];

                    var collection = new models.Collection( data );
                    collection = collection.zip( zipWith, function( item1, item2 ) {
                        return item1 + item2;
                    } );

                    expect( collection.get() ).toBe( expected );
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
                it( "can group values by a given key and return a unique struct for each key", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = {
                        "1" = { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        "2" = { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        "3" = { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        "4" = { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    };

                    var collection = new models.Collection( data );
                    var actual = collection.groupByUnique( "id" );

                    expect( actual ).toBe( expected );
                } );
                it( "can group values by a given key and unique or throw error", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];

                    var collection = new models.Collection( data );

                    expect( function() {
                                var actual = collection.groupByUnique("species" );
                            }  ).toThrow( "KeyIsNotUnique" );
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

                expect( collection.transpose().get() ).toBe( expected );
            } );

            describe( "sort", function() {
                it( "sorts using a text sort type by default", function() {
                    var data = [ 2, 4, 3, 1 ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );

                    expect( collection.sort().get() ).toBe( expected );
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

                    expect( collection.get() ).toBe( expected );
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

                    expect( collection.sort( "value" ).get() ).toBe( expected );
                } );
            } );

            describe( "merge", function() {
                it( "can merge in another array", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var dataToAdd = [ 5, 6, 7, 8 ];
                    var expected = [ 1, 2, 3, 4, 5, 6, 7, 8 ];

                    var collection = new models.Collection( data );
                    collection = collection.merge( dataToAdd );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "can merge in another collection", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var dataToAdd = [ 5, 6, 7, 8 ];
                    var expected = [ 1, 2, 3, 4, 5, 6, 7, 8 ];

                    var collection = new models.Collection( data );
                    var otherCollection = new models.Collection( dataToAdd );
                    collection = collection.merge( otherCollection );

                    expect( collection.get() ).toBe( expected );
                } );
            } );

            describe( "slice", function() {
                it( "can slice from a position for a given length", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = [ 2, 3 ];

                    var collection = new models.Collection( data );
                    collection = collection.slice( 2, 2 );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "slices to the end if no length is given", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expected = [ 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection = collection.slice( 2 );

                    expect( collection.get() ).toBe( expected );
                } );
            } );

            describe( "chunk", function() {
                it( "chunks an array given a size", function() {
                    var data = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ];
                    var expected = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ];

                    var collection = new models.Collection( data );
                    collection = collection.chunk( 3 );

                    expect( collection.get() ).toBeArray();
                    expect( collection.get() ).toHaveLength( 3 );
                    expect( collection.get()[1] ).toHaveLength( 3 );
                    expect( collection.get()[2] ).toHaveLength( 3 );
                    expect( collection.get()[3] ).toHaveLength( 3 );
                } );

                it( "adds the remaining values to the last chunk even if it is not the chunk size", function() {
                    var data = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ];
                    var expected = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10, 11 ] ];

                    var collection = new models.Collection( data );
                    collection = collection.chunk( 3 );

                    expect( collection.get() ).toBeArray();
                    expect( collection.get() ).toHaveLength( 4 );
                    expect( collection.get()[1] ).toHaveLength( 3 );
                    expect( collection.get()[2] ).toHaveLength( 3 );
                    expect( collection.get()[3] ).toHaveLength( 3 );
                    expect( collection.get()[4] ).toHaveLength( 2 );
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

                    expect( collection.get() ).toBe( expected );
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

                    expect( collection.get() ).toBe( expected );
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
                    collection = collection.where( "species", "Human,Vulcan" );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "can check against an empty string", function() {
                    var data = [
                        { id = 1, active = "" },
                        { id = 2, active = "N" },
                        { id = 3, active = "N" },
                        { id = 4, active = "" }
                    ];
                    var expected = [
                        { id = 1, active = "" },
                        { id = 4, active = "" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.where( "active", "" );

                    expect( collection.get() ).toBe( expected );
                } );
            } );

            describe( "whereNot", function() {
                it( "is a shortcut for reject for a key and value pair", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = [
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.whereNot( "species", "Human" );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "can accept an array of values to check against ( like an IN statement)", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = [
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.whereNot( "species", [ "Human", "Vulcan" ] );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "can also accept a list instead of an array of values", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];
                    var expected = [
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" }
                    ];

                    var collection = new models.Collection( data );
                    collection = collection.whereNot( "species", "Human,Vulcan" );

                    expect( collection.get() ).toBe( expected );
                } );
            } );

            it( "range", function() {
                var collection = new models.Collection();

                expect( collection.range( 4 ).get() ).toBe( [ 0, 1, 2, 3 ] );
                expect( collection.range( -4 ).get() ).toBe( [ 0, -1, -2, -3 ] );
                expect( collection.range( -0, 4 ).get() ).toBe( [ -0, 1, 2, 3 ] );
                expect( collection.range( 1, 5 ).get() ).toBe( [ 1, 2, 3, 4 ] );
                expect( collection.range( 0, 20, 5 ).get() ).toBe( [ 0, 5, 10, 15 ] );
                expect( collection.range( 0, -4, -1 ).get() ).toBe( [ 0, -1, -2, -3 ] );
                expect( collection.range( 1, 4, 0 ).get() ).toBe( [ 1, 1, 1 ] );
                expect( collection.range( -4, 0, 0 ).get() ).toBe( [ -4, -4, -4, -4 ] );
                expect( collection.range( -4, 0 ).get() ).toBe( [ -4, -3, -2, -1 ] );
                expect( collection.range( 0 ).get() ).toBe( [] );
            } );


        } );

        describe( "pipeline functions", function() {
            describe( "when", function() {
                it( "runs the callback function only when the condition is true", function() {
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
                    collection = collection.when(
                        condition = true,
                        callback = function( c ) {
                            return c.where( "species", "Human" );
                        }
                    );

                    expect( collection.get() ).toBe( expected );
                } );

                it( "does not run the callback function when the condition is false", function() {
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
                    collection = collection.when( false, function( c ) {
                        return c.where( "species", "Human" );
                    } );

                    expect( collection.get() ).toBe( data );
                } );

                it( "runs the defaultCallback (if exists) when the condition is false", function() {
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
                    collection = collection.when(
                        condition = false,
                        callback = function( c ) {
                            return c.where( "species", "Vulcan" );
                        },
                        defaultCallback = function( c ) {
                            return c.where( "species", "Human" );
                        }
                    );

                    expect( collection.get() ).toBe( expected );
                } );
            } );

            describe( "tap", function() {
                it( "returns the collection unchanged no matter what code is ran inside the callback", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var debugged = [];

                    var collection = new models.Collection( data );
                    var actual = collection.tap( function( c ) {
                        arrayAppend( debugged, c.get() );
                        var doubled = c.map( function( item ) {
                            // This code runs, but should not change the collection.
                            return item * 2;
                        } );
                        arrayAppend( debugged, doubled.get() );
                        return doubled;
                    } );

                    expect( actual ).toBeInstanceOf( "models.Collection", "A collection should be returned" );
                    expect( actual ).toBe( collection, "The same collection should be returned" );
                    expect( actual.get() ).toBe( data );
                    expect( debugged ).toHaveLength( 2, "The callback should have called the debug method twice." );
                    expect( debugged[ 1 ] ).toBe( [ 1, 2, 3, 4 ] );
                    expect( debugged[ 2 ] ).toBe( [ 2, 4, 6, 8 ] );
                } );
            } );
        } );

        describe( "functions that return a non-collection value", function() {
            describe( "get", function() {
                it( "returns the collection as an array when called with no parameters", function() {
                    var data = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    var actual = collection.get();

                    expect( actual ).toBe( data );
                } );

                it( "returns the value at the specific index when passed an index", function() {
                    var data = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    var actual = collection.get( 2 );

                    expect( actual ).toBe( 2 );
                } );

                it( "it returns the default value if the specified index does not exist", function() {
                    var data = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    var actual = collection.get( 5, "foo" );

                    expect( actual ).toBe( "foo" );
                } );
            } );

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

                describe( "where derivitives", function() {
                    describe( "countWhere", function() {
                            it( "is a shortcut for where and count", function() {
                            var data = [
                                { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                                { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                                { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                                { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                            ];

                            var collection = new models.Collection( data );
                            var result = collection.countWhere( "species", "Human" );

                            expect( result ).toBe( 2 );
                        } );

                        it( "can accept an array of values to check against ( like an IN statement)", function() {
                            var data = [
                                { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                                { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                                { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                                { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                            ];

                            var collection = new models.Collection( data );
                            var result = collection.countWhere( "species", [ "Human", "Vulcan" ] );

                            expect( result ).toBe( 3 );
                        } );

                        it( "can also accept a list instead of an array of values", function() {
                            var data = [
                                { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                                { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                                { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                                { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                            ];

                            var collection = new models.Collection( data );
                            var result = collection.countWhere( "species", "Human,Vulcan" );

                            expect( result ).toBe( 3 );
                        } );
                    } );

                    describe( "countWhereNot", function() {
                            it( "is a shortcut for whereNot and count", function() {
                            var data = [
                                { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                                { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                                { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                                { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                            ];

                            var collection = new models.Collection( data );
                            var result = collection.countWhereNot( "species", "Human" );

                            expect( result ).toBe( 2 );
                        } );

                        it( "can accept an array of values to check against ( like an IN statement)", function() {
                            var data = [
                                { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                                { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                                { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                                { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                            ];

                            var collection = new models.Collection( data );
                            var result = collection.countWhereNot( "species", [ "Human", "Vulcan" ] );

                            expect( result ).toBe( 1 );
                        } );

                        it( "can also accept a list instead of an array of values", function() {
                            var data = [
                                { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                                { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                                { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                                { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                            ];

                            var collection = new models.Collection( data );
                            var result = collection.countWhereNot( "species", "Human,Vulcan" );

                            expect( result ).toBe( 1 );
                        } );
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
                    expect( collection.get() ).toBe( data );
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
                    expect( collection.get() ).toBe( data );
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

            describe( "has", function() {
                it( "accepts a callback to determine if any record in the collection matches the predicate", function() {
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

                it( "can accept a simple key and value to check instead of a callback", function() {
                    var data = [
                        { id = 1, name = "James T. Kirk", rank = "Captain", species = "Human" },
                        { id = 2, name = "Spock", rank = "Commander", species = "Vulcan" },
                        { id = 3, name = "Odo", rank = "Constable", species = "Changeling" },
                        { id = 4, name = "Jonathan Archer", rank = "Captain", species = "Human" }
                    ];

                    var collection = new models.Collection( data );

                    expect( collection.has( "species", "Vulcan" ) ).toBeTrue();
                    expect( collection.has( "species", "Trill" ) ).toBeFalse();
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

            describe( "append", function() {
                it( "add an item to the end of the collection", function() {
                    var data = [ 1, 2, 3 ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection.append( 4 );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can add multiple items at once", function() {
                    var data = [ 1, 2, 3 ];
                    var expected = [ 1, 2, 3, 4, 5 ];

                    var collection = new models.Collection( data );
                    collection.append( 4, 5 );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "push", function() {
                it( "adds the arguments to the end of the collection", function() {
                    var data = [ 3, 2, 1 ];
                    var collection = new models.Collection( data );

                    collection.push( "lift off!" );

                    expect( collection.get() ).toBe( [ 3, 2, 1, "lift off!" ] );
                } );

                it( "can add multiple items at once", function() {
                    var data = [ 1, 2, 3 ];
                    var expected = [ 1, 2, 3, 4, 5 ];

                    var collection = new models.Collection( data );
                    collection.push( 4, 5 );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "prepend", function() {
                it( "add an item to the beginning of the collection", function() {
                    var data = [ 2, 3, 4 ];
                    var expected = [ 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection.prepend( 1 );

                    expect( collection.toArray() ).toBe( expected );
                } );

                it( "can add multiple items at once", function() {
                    var data = [ 2, 3, 4 ];
                    var expected = [ 0, 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection.prepend( 0, 1 );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "unshift", function() {
                it( "adds the arguments to the beginning of the collection", function() {
                    var data = [ "kiwi", "orange", "banana" ];
                    var collection = new models.Collection( data );

                    collection.unshift( "apple" );

                    expect( collection.get() ).toBe( [ "apple", "kiwi", "orange", "banana" ] );
                } );

                it( "can add multiple items at once", function() {
                    var data = [ 2, 3, 4 ];
                    var expected = [ 0, 1, 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    collection.unshift( 0, 1 );

                    expect( collection.toArray() ).toBe( expected );
                } );
            } );

            describe( "pop", function() {
                it( "remove an item from the end of the collection and return it", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expectedReturn = 4;
                    var expectedCollection = [ 1, 2, 3 ];

                    var collection = new models.Collection( data );
                    var pop = collection.pop();

                    expect( pop ).toBe( expectedReturn );
                    expect( collection.toArray() ).toBe( expectedCollection );
                } );
            } );

            describe( "shift", function() {
                it( "remove an item from the beginning of the collection and return it", function() {
                    var data = [ 1, 2, 3, 4 ];
                    var expectedReturn = 1;
                    var expectedCollection = [ 2, 3, 4 ];

                    var collection = new models.Collection( data );
                    var shift = collection.shift();

                    expect( shift ).toBe( expectedReturn );
                    expect( collection.toArray() ).toBe( expectedCollection );
                } );
            } );

            describe( "splice", function() {
                it( "insert items at a given index", function() {
                    var data = [ "Frodo", "Sam", "Merry", "Pippin" ];
                    var collection = new models.Collection( data );

                    var result = collection.splice( 2, 0, "Bilbo" );

                    expect( result ).toBe( [] );
                    expect( collection.get() ).toBe( [ "Frodo", "Bilbo", "Sam", "Merry", "Pippin" ] );
                } );

                it( "remove items at given index", function() {
                    var data = [ "Thorin", "Dwalin", "Balin", "Gloin" ];
                    var collection1 = new models.Collection( data );
                    var collection2 = new models.Collection( data );
                    var collection3 = new models.Collection( data );

                    var result1 = collection1.splice( 2, 1 );
                    var result2 = collection2.splice( -2, 1 );
                    var result3 = collection3.splice( -1, 1 );

                    expect( result1 ).toBe( [ "Dwalin" ] );
                    expect( collection1.get() ).toBe( [ "Thorin", "Balin", "Gloin" ] );

                    expect( result2 ).toBe( [ "Balin" ] );
                    expect( collection2.get() ).toBe( [ "Thorin", "Dwalin", "Gloin" ] );

                    expect( result3 ).toBe( [ "Gloin" ] );
                    expect( collection3.get() ).toBe( [ "Thorin", "Dwalin", "Balin" ] );
                } );

                it( "remove items and insert at given index", function() {
                    var data = [ "Aragorn", "Boromir", "Gimli", "Legolas" ];
                    var collection1 = new models.Collection( data );
                    var collection2 = new models.Collection( data );

                    var result1 = collection1.splice( 2, 1, "Gandalf" );
                    var result2 = collection2.splice( 0, 2, "Gandalf", "Elrond" );

                    expect( result1 ).toBe( [ "Boromir" ] );
                    expect( collection1.get() ).toBe( [ "Aragorn", "Gandalf", "Gimli", "Legolas" ] );

                    expect( result2 ).toBe( [ "Aragorn", "Boromir" ] );
                    expect( collection2.get() ).toBe( [ "Gandalf", "Elrond", "Gimli", "Legolas" ] );
                } );

                it( "remove items to the right of [start] when [count] is ommitted or greater than [length - start]", function() {
                    var data = [ "Hobbit", "Elf", "Dwarf", "Human" ];
                    var collection1 = new models.Collection( data );
                    var collection2 = new models.Collection( data );
                    var collection3 = new models.Collection( data );

                    var result1 = collection1.splice( 2 );
                    var result2 = collection2.splice( 2, 7 );
                    var result3 = collection3.splice( 2, 7, "Ent" );

                    expect( result1 ).toBe( [ "Dwarf", "Human" ] );
                    expect( collection1.get() ).toBe( [ "Hobbit", "Elf" ] );

                    expect( result2 ).toBe( [ "Dwarf", "Human" ] );
                    expect( collection2.get() ).toBe( [ "Hobbit", "Elf" ] );

                    expect( result3 ).toBe( [ "Dwarf", "Human" ] );
                    expect( collection3.get() ).toBe( [ "Hobbit", "Elf", "Ent" ] );
                    debug( collection3 );
                } );
            } );
        } );
    }

}
