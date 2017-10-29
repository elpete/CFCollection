component {

    include "../modules/normalizeToArray/functions/normalizeToArray.cfm";

    variables.collection = [];

    public Collection function init( any collection = [] ) {
        variables.collection = normalizeToArray( arguments.collection );
        return this;
    }

    public Collection function collect( any items = [] ) {
        if ( structKeyExists( application, "wirebox" ) ) {
            return application.wirebox.getInstance(
                name = "Collection@CFCollection",
                initArguments = { collection = arguments.items }
            );
        }
        return new Collection( items );
    }

    public any function getCollectFunction() {
        return collect;
    }

    public Collection function keys( required struct obj ) {
        return collect( structKeyArray( obj ) );
    }

    public Collection function values( required struct obj ) {
        var arr = [];
        for ( var key in obj ) {
            arrayAppend( arr, obj[ key ] );
        }
        return collect( arr );
    }

    public Collection function range( numeric start, numeric end, numeric step ) {
        if ( isNull( end ) ) {
            end = start;
            start = 0;
        }
        step = isNull( step ) ? (start < end ? 1 : -1) : step;
        var length = max( ceiling( ( abs( end ) - start ) / ( abs( step ) == 0 ? 1 : abs( step ) ) ), 0 );
        var collection = [];
        while ( length-- ) {
            arrayAppend( collection, start );
            start = ( sgn( end ) == -1 ) ? start - abs( step ) : start + step;
        }
        return collect( collection );
    }

    /*==========================================
    =            Imperative Methods            =
    ==========================================*/

    public Collection function each( callback ) {
        arrayEach( collection.toArray(), callback );

        return this;
    }

    // Functional Methods

    public Collection function map( callback ) {
        var mapped = [];
        for ( var i = 1; i <= arrayLen( collection ); i++ ) {
            arrayAppend( mapped, callback( collection[ i ], i ) );
        }
        return collect( mapped );
    }

    public Collection function flatMap( callback ) {
        return this.map( callback ).flatten( 1 );
    }

    public Collection function pluck( required any field ) {
        var keys = normalizeToArray( arguments.field );
        return this.map( function( item ) {
            if ( arrayLen( keys ) == 1 ) {
                if ( isObject( item ) && structKeyExists( item, "get#keys[ 1 ]#" ) ) {
                    return invoke( item, "get#keys[ 1 ]#" );
                }
                return item[ keys[ 1 ] ];
            }

            // CF10 doesn't have arrayReduce
            var obj = {};
            for ( var key in keys ) {
                if ( isObject( item ) && structKeyExists( item, "get#key#" ) ) {
                    obj[ key ] = invoke( item, "get#key#" );
                }
                else {
                    obj[ key ] = item[ key ];
                }
            }
            return obj;
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

    public Collection function reject( required predicate ) {
        return this.filter( function( item ) {
            return ! predicate( item );
        } );
    }

    public Collection function unique( any column = "" ) {
        var autoColumn = false;
        if ( isSimpleValue( column ) && column == "" ) {
            autoColumn = true;
            variables.collection = this.map( function( item ) {
                return { "item" = item };
            } );
            column = "item";
        }

        var func = column;
        if ( ! isCustomFunction( func ) && ! isClosure( func ) ) {
            func = function( item ) {
                return item[ column ];
            };
        }

        var result = values( reduce( function( memo, obj ) {
            var columnVal = func( obj );
            if ( ! structKeyExists( memo, columnVal ) ) {
                memo[ columnVal ] = obj;
            }
            return memo;
        }, {} ) );

        if ( autoColumn ) {
            return result.pluck( "item" );
        }

        return result;
    }

    public Collection function reverse() {
        var reversed = [];
        for ( var i = arrayLen( collection ); i > 0; i-- ) {
            arrayAppend( reversed, collection[ i ] );
        }
        return collect( reversed );
    }

    public Collection function zip(
        required any newCollection,
        projection
    ) {
        if ( isNull( arguments.projection ) ) {
            arguments.projection = function( item1, item2 ) {
                return [ item1, item2 ];
            };
        }
        newCollection = normalizeToArray( newCollection.toArray() );

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
        return collect(
            collect( collection[ 1 ] ).map( function( _, i ) {
                return collect( collection ).map( function( arr ) {
                    return arr[ i ];
                } ).toArray();
            } ).toArray()
        );
    }

    public Collection function sort( callback ) {
        if ( isNull( arguments.callback ) ) {
            arguments.callback = function( itemA, itemB ) {
                return compare( itemA, itemB );
            };
        }
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
        if ( isInstanceOf( newValues, "Collection" ) ) {
            newValues = newValues.toArray();
        }
        for ( var value in normalizeToArray( newValues ) ) {
            arrayAppend( values, value );
        }
        return collect( values );
    }

    public Collection function slice(
        required numeric position,
        numeric length = this.count() + 1 - position
    ) {
        return collect( arraySlice( clone().toArray(), position, length ) );
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
            return collect( normalizeToArray( value ) ).has( function( val ) {
                return val == item[ key ];
            } );
        } );
    }

    public Collection function whereNot( required string key, required any value ) {
        return this.reject( function( item ) {
            return collect( normalizeToArray( value ) ).has( function( val ) {
                return val == item[ key ];
            } );
        } );
    }

    public Collection function tap( callback ) {
        callback( this );
        return this;
    }

    public Collection function append( required any item ) {
        arrayAppend( variables.collection, item );
        return this;
    }

    public Collection function prepend( required any item ) {
        arrayPrepend( variables.collection, item );
        return this;
    }

    /* Returns a Pipeline function */

    public any function when( required boolean condition, required any callback, any defaultCallback ) {
        if ( condition ) {
            return callback( this );
        }
        else if ( ! isNull( defaultCallback ) ) {
            return defaultCallback( this );
        }
        else {
            return this;
        }
    }

    /*======================================================
    =            Returns a non-collection value            =
    ======================================================*/

    public any function get( index, defaultValue ) {
        if ( isNull( index ) ) {
            return toArray();
        }

        try {
            return collection[ index ];
        }
        catch ( any e ) {
            if ( ! isNull( defaultValue ) ) {
                return defaultValue;
            }
            rethrow;
        }
    }

    public array function toArray() {
        return duplicate( collection );
    }

    public boolean function empty() {
        return arrayIsEmpty( collection );
    }

    public any function first( predicate, defaultValue ) {
        if ( isNull( predicate ) ) {
            arguments.predicate = function() {
                return true;
            };
        }

        for ( var item in this.toArray() ) {
            if ( predicate( item ) ) {
                return item;
            }
        }

        if ( ! isNull( defaultValue ) ) {
            return getDefaultValue( defaultValue );
        }

        throw( type = "CollectionIsEmpty", message = "Cannot return the result because the collection is either empty or no value matched the predicate with no default value provided." );
    }

    public any function last( predicate, defaultValue ) {
        return clone().reverse().first( argumentCollection = arguments );
    }

    public numeric function count() {
        return arrayLen( collection );
    }

    public numeric function countWhere( required string key, required any value ) {
        return this.where( argumentCollection = arguments ).count();
    }

    public numeric function countWhereNot( required string key, required any value ) {
        return this.whereNot( argumentCollection = arguments ).count();
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

    public struct function groupBy( required string key, boolean forceLookup = false ) {
        return this.reduce( function( acc, item ) {
            if ( ( isObject( item ) && structKeyExists( item, "get#key#" ) ) || forceLookup ) {
                var value = invoke( item, "get#key#" );
            }
            else {
                var value = item[ key ];
            }
            if ( ! structKeyExists( acc, value ) ) {
                acc[ value ] = [];
            }
            arrayAppend( acc[ value ], item );
            return acc;
        }, {} );
    }

    public numeric function sum( string field ) {
        var collection = this;

        if ( ! isNull( field ) ) {
            collection = clone().pluck( field );
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

    public boolean function has( callback, value ) {
        if ( isSimpleValue( callback ) ) {
            var key = callback;
            callback = function( item ) {
                return item[ key ] == value;
            };
        }
        return ! this.filter( callback ).empty();
    }

    public boolean function any( callback, value ) {
        return this.has( argumentCollection = arguments );
    }

    public boolean function every( callback ) {
        return this.count() == this.filter( callback ).count();
    }

    public string function serialize( any fields ) {
        var thisCollection = isNull( fields ) ? this : this.pluck( fields );
        return serializeJSON( thisCollection.toArray() );
    }

    public any function pop() {
        var result = this.last();
        arrayDeleteAt( variables.collection, this.count() );
        return result;
    }

    public any function shift() {
        var result = this.first();
        arrayDeleteAt( variables.collection, 1 );
        return result;
    }

    /* Private Methods */

    private Collection function clone() {
        var newCollection = collect( this.toArray() );
        return newCollection;
    }

    private string function normalizeToList( required any values ) {
        return arrayToList( normalizeToArray( values ) );
    }

    private function _flatten( arr, depth = 0 ) {
        var results = [];

        for ( var item in arr ) {
            if ( depth == 1 ) {
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

    private any function getDefaultValue( value ) {
        if ( isCustomFunction( value ) || isClosure( value ) ) {
            return value();
        }

        return value;
    }

}
