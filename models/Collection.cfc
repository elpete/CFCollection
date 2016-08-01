component {

    variables.collection = [];

    public Collection function init( any collection = [] ) {
        variables.collection = normalizeToArray( arguments.collection );
        return this;
    }

    public array function toArray() {
        return duplicate( collection );
    }

    // Imperative Methods

    public Collection function each( callback ) {
        collection.each( callback );

        return this;
    }

    // Functional Methods

    public Collection function map( callback ) {
        return collect( arrayMap( collection, callback ) );
    }

    public Collection function flatMap( callback ) {
        return this.map( callback ).flatten( 1 );
    }

    public Collection function pluck( required string field ) {
        return this.map( function( item ) {
            return item[ field ]
        } );
    }

    public Collection function flatten( depth = 0 ) {
        return collect( _flatten( this.toArray(), depth ) );
    }

    public Collection function filter( required predicate ) {
        var results = [];
        this.each( function( item ) {
            if ( predicate( item ) ) {
                arrayAppend( results, item );
            }
        } );
        return collect( results );
    }

    public Collection function reverse() {
        return collect( arrayReverse( collection ) );
    }

    public Collection function zip(
        required any newCollection,
        projection = function( item1, item2 ) {
            return [ item1, item2 ];
        }
    ) {
        newCollection = normalizeToArray( newCollection );

        if ( this.count() != arrayLen( newCollection ) ) {
            throw(
                type = "CollectionLengthMismatch",
                message = "The new collection does not have the same length as the current collection.  Collection length: [#this.count()#]. Argument length: [#arrayLen( newCollection )#]."
            );
        }

        return this.map( function( item, i ) {
            return projection( item, newCollection[ i ] );
        } );
    }

    public Collection function transpose() {
        return collect( arrayMap( collection[ 1 ], function( _, i ) {
            return arrayMap( collection, function( arr ) {
                return arr[ i ];
            } );
        } ) );
    }

    public Collection function sort(
        callback = function( itemA, itemB ) {
            return compare( itemA, itemB );
        }
    ) {
        if ( isSimpleValue( callback ) ) {
            local.key = callback;
            arguments.callback = function( itemA, itemB ) {
                return compare( itemA[ key ], itemB[ key ] );
            };
        }

        arraySort( collection, callback );
        
        return collect( collection );
    }

    public Collection function merge( required any newValues ) {
        var values = this.toArray();
        for ( var value in normalizeToArray( newValues ) ) {
            arrayAppend( values, value );
        }
        return collect( values );
    }

    public Collection function slice(
        required numeric position,
        numeric length = this.count() + 1 - position
    ) {
        return collect( arraySlice( this.duplicate().toArray(), position, length ) );
    }

    public Collection function chunk( required numeric length ) {
        var chunks = [];
        var count = 0;
        var thisChunk = [];
        this.each( function( item ) {
            arrayAppend( thisChunk, item );
            count++;
            if ( count == length ) {
                arrayAppend( chunks, thisChunk );
                count = 0;
                thisChunk = [];
            }
        } );
        if ( ! arrayIsEmpty( thisChunk ) ) {
            arrayAppend( chunks, thisChunk );
        }

        return collect( chunks );
    }

    public Collection function where( required string key, required any value ) {
        return this.filter( function( item ) {
            return listContainsNoCase( normalizeToList( value ), item[ key ] );
        } );
    }

    /* Returns a non-collection value */

    public boolean function empty() {
        return arrayIsEmpty( collection );
    }

    public any function first( predicate, default ) {
        if ( isNull( predicate ) ) {
            arguments.predicate = function() {
                return true;
            }
        }

        for ( var item in this.toArray() ) {
            if ( predicate( item ) ) {
                return item;
            }
        }

        if ( ! isNull( default ) ) {
            return defaultValue( default );
        }

        throw( type = "CollectionIsEmpty", message = "Cannot return the result because the collection is either empty or no value matched the predicate with no default value provided." );
    }

    public any function last( predicate, default ) {
        return this.duplicate().reverse().first( argumentCollection = arguments );
    }

    public numeric function count() {
        return arrayLen( collection );
    }

    public numeric function length() {
        return this.count();
    }

    public numeric function size() {
        return this.count();
    }

    public any function reduce( callback, accumulator = this.first() ) {
        this.each( function( item ) {
            accumulator = callback( accumulator, item );
        } );

        return accumulator;
    }

    public struct function groupBy( required string key ) {
        return this.reduce( function( acc, item ) {
            if ( ! structKeyExists( acc, item[ key ] ) ) {
                acc[ item[ key ] ] = [];
            }
            arrayAppend( acc[ item[ key ] ], item );
            return acc;
        }, {} );
    }

    public numeric function sum( string field ) {
        var collection = this;

        if ( ! isNull( field ) ) {
            collection = this.duplicate().pluck( field );
        }

        return collection.reduce( function( acc, item ) {
            return acc + item;
        }, 0 );
    }

    public numeric function avg( string field ) {
        return this.sum( argumentCollection = arguments ) / this.count();
    }

    public numeric function average( string field ) {
        return this.avg( argumentCollection = arguments );
    }

    public string function join( string delimiter = "," ) {
        return arrayToList( collection, delimiter );
    }

    public any function pipe( callback ) {
        return callback( this );
    }

    public boolean function contains( callback ) {
        return ! this.filter( callback ).empty();
    }

    public boolean function any( callback ) {
        return this.contains( callback );
    }

    public boolean function every( callback ) {
        return this.count() == this.filter( callback ).count();
    }

    /* Private Methods */

    private Collection function collect( any items = [] ) {
        return new Collection( items );
    }

    private Collection function duplicate() {
        var newCollection = new Collection( this.toArray() );
        return newCollection;
    }

    private array function normalizeToArray( required any collection = [] ) {
        if ( isInstanceOf( collection, "models.Collection" ) ) {
            return collection.toArray();
        }

        collection = duplicate( collection );

        if ( isArray( collection ) ) {
            return collection;
        }

        if ( isQuery( collection ) ) {
            return queryToArray( collection );
        }

        return listToArray( collection );
    }

    private string function normalizeToList( required any values ) {
        return arrayToList( normalizeToArray( values ) );
    }

    private array function queryToArray( required query q ) {
        var arr = [];
        for ( var row in q ) {
            arr.append( row );
        }
        return arr;
    }


    private function _flatten( arr, depth = 0 ) {
        var results = [];
        
        for ( var item in arr ) {
            if ( depth === 1 ) {
                results = arrayMerge( results, item );
                continue;
            }

            if ( isArray( item ) ) {
                results = arrayMerge( results, _flatten( item, depth - 1 ) );
                continue;
            }

            arrayAppend( results, item );
        }

        return results;
    }

    private array function arrayMerge( arr1, arr2 ) {
        var results = duplicate( arr1 );
        for ( var item in arr2 ) {
            arrayAppend( results, item );
        }
        return results;
    }

    private any function defaultValue( value ) {
        if ( isCustomFunction( value ) || isClosure( value ) ) {
            return value();
        }

        return value;
    }

}