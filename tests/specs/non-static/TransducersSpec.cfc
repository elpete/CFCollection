component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "interop", function() {
            it( "returns a collection from calling transduce", function() {
                var collection = new models.TransducerCollection( [ 1, 2, 3, 4 ] );

                expect( collection.transduce() ).toBeInstanceOf( "Collection" );
            } );

            it( "can create a transducer collection from a normal collection", function() {
                var collection = new models.Collection( [ 1, 2, 3, 4 ] );
                expect( collection.transducer() ).toBeInstanceOf( "TransducerCollection" );
                expect( collection.transducer().transduce().get() ).toBe( [ 1, 2, 3, 4 ] );
            } );

            it( "performs a no-op when calling transduce with no transducers defined", function() {
                var collection = new models.TransducerCollection( [ 1, 2, 3, 4 ] );

                expect( collection.transduce().get() ).toBe( [1, 2, 3, 4 ] );
            } );
        } );

        describe( "transducer functions", function() {
            it( "map", function() {
                var collection = new models.TransducerCollection( [ 1, 2, 3, 4 ] );

                var double = function( num ) {
                    return num * 2;
                };

                var actual = collection
                    .map( double )
                    .transduce()
                    .get();

                expect( actual ).toBe( [ 2, 4, 6, 8 ] );
            } );

            it( "filter", function() {
                var collection = new models.TransducerCollection( [ 1, 2, 3, 4 ] );

                var isEven = function( num ) {
                    return num % 2 == 0;
                };

                var actual = collection
                    .filter( isEven )
                    .transduce()
                    .get();

                expect( actual ).toBe( [ 2, 4 ] );
            } );

            it( "unique", function() {
                var collection = new models.TransducerCollection( [ 1, 4, 1, 1, 2, 4, 4, 2 ] );

                var actual = collection.unique().transduce().get();

                expect( actual ).toBe( [ 1, 4, 2 ] );
            } );

            it( "reverse", function() {
                var collection = new models.TransducerCollection( [ 1, 2, 3, 4 ] );

                var actual = collection.reverse().transduce().get();

                expect( actual ).toBe( [ 4, 3, 2, 1 ] );
            } );

            it( "can define on the fly transducers using reduce", function() {
                var collection = new models.TransducerCollection( [ 1, 4, 1, 1, 2, 4, 4, 2 ] );

                var actual = collection
                    .reduce( function( innerReducer ) {
                        return function( accumulator, value, index, items ) {
                            if ( arrayContains( accumulator, value ) == 0 ) {
                                accumulator = innerReducer( accumulator, value, index, items );
                            }
                            return accumulator;
                        };
                    } )
                    .transduce()
                    .get();

                expect( actual ).toBe( [ 1, 4, 2 ] );
            } );
        } );

        describe( "composing transducers", function() {
            it( "composes transducers with a builder pattern", function() {
                var collection = new models.TransducerCollection( [ 1, 2, 3, 4 ] );

                var isEven = function( num ) {
                    return num % 2 == 0;
                };

                var double = function( num ) {
                    return num * 2;
                };

                var actual = collection
                    .filter( isEven )
                    .map( double )
                    .transduce()
                    .get();

                expect( actual ).toBe( [ 4, 8 ] );
            } );

            it( "composes reverse and map and unique calls", function() {
                var collection = new models.TransducerCollection( [ 1, 4, 1, 1, 2, 4, 4, 2 ] );

                var square = function( num ) {
                    return num * num;
                };

                var actual = collection
                    .reverse()
                    .map( square )
                    .unique()
                    .transduce()
                    .get();

                expect( actual ).toBe( [ 4, 16, 1 ] );
            } );
        } );

        describe( "performance of transducers", function() {
            it( "performs better than collection pipelines on large arrays", function() {
                var arrayOfThousand = arrayOfRandoms(100, 1000000);
                var normalActual = "";
                var transducerActual = "";
                debug( timeIt( function() {
                    var collection = new models.Collection( arrayOfThousand );

                    var double = function( num ) {
                        return num * 2;
                    };

                    normalActual = collection
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .get();
                } ), "normal collection" );

                debug( timeIt( function() {
                    var collection = new models.TransducerCollection( arrayOfThousand );

                    var double = function( num ) {
                        return num * 2;
                    };

                    transducerActual = collection
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .map( double )
                        .transduce()
                        .get();
                } ), "transduced collection" );

                expect( normalActual ).toBe( transducerActual );
            } );
        } );
    }

    private function arrayOfRandoms( ceiling, length ) {
        var items = [];
        arraySet( items, 1, 100, 1 );
        return items;
    }

    private function timeIt( callback ) {
        var start = getTickCount();
        callback();
        return getTickCount() - start;
    }

}
