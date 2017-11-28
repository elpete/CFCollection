component {

    include "../modules/normalizeToArray/functions/normalizeToArray.cfm";

    variables.collection = [];
    variables.transducers = new Collection();

    public TransducerCollection function init( any collection = [] ) {
        variables.collection = normalizeToArray( arguments.collection );
        variables.transducers = new Collection();
        return this;
    }

    public Collection function transduce() {
        var transducedCollection = _arrayReduce( variables.collection, composeTransducers(), [] );
        if ( structKeyExists( application, "wirebox" ) ) {
            return application.wirebox.getInstance(
                name = "Collection@CFCollection",
                initArguments = { collection = transducedCollection }
            );
        }
        return new Collection( transducedCollection );
    }

    public TransducerCollection function map( transformFunction ) {
        variables.transducers.prepend(
            function( innerReducer ) {
                return function( accumulator, value, index, items ) {
                    accumulator = innerReducer( accumulator, transformFunction( value ), index, items );
                    return accumulator;
                };
            }
        );
        return this;
    }

    public TransducerCollection function filter( predicateFunction ) {
        variables.transducers.prepend(
            function( innerReducer ) {
                return function( accumulator, value, index, items ) {
                    if ( predicateFunction( value ) ) {
                        accumulator = innerReducer( accumulator, value, index, items );
                    }
                    return accumulator;
                };
            }
        );
        return this;
    }

    public TransducerCollection function unique() {
        variables.transducers.prepend(
            function( innerReducer ) {
                var uniqueValues = [];
                return function( accumulator, value, index, items ) {
                    if ( arrayContains( uniqueValues, value ) == 0 ) {
                        arrayAppend( uniqueValues, value );
                        accumulator = innerReducer( accumulator, value, index, items );
                    }
                    return accumulator;
                };
            }
        );
        return this;
    }

    public TransducerCollection function reverse() {
        variables.transducers.prepend(
            function( innerReducer ) {
                return function( accumulator, value, index, items ) {
                    accumulator = innerReducer( accumulator, value, index, items );
                    if ( arrayLen( items ) == index ) {
                        return _arrayReverse( accumulator );
                    }
                    return accumulator;
                };
            }
        );
        return this;
    }

    public TransducerCollection function reduce( reducerFunction ) {
        variables.transducers.prepend( reducerFunction );
        return this;
    }

    private function _arrayReverse( items ) {
        var reversedItems = [];
        for ( var i = arrayLen( items ); i > 0; i-- ) {
            arrayAppend( reversedItems, items[ i ] );
        }
        return reversedItems;
    }

    private function _arrayReduce( source, reducerFunction, initialValue ) {
        var accumulator = initialValue;
        for ( var i = 1; i <= arrayLen( source ); i++ ) {
            accumulator = reducerFunction( accumulator, source[ i ], i, source );
        }
        return accumulator;
    }

    private function composeTransducers() {
        return variables.transducers.reduce( function( composedTransducer, transducer ) {
            return transducer( composedTransducer );
        }, generateAppendTransducer() );
    }

    private function generateAppendTransducer() {
        return function( accumulator, value, index, items ) {
            arrayAppend( accumulator, value );
            return accumulator;
        };
    }

}
