component {

    variables.collection = [];

    public Collection function init( any collection = [] ) {
        variables.collection = normalizeToArray( arguments.collection );
        return this;
    }

    public Collection function collect( any items = [] ) {
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

    public array function toArray() {
        return duplicate( collection );
    }

    // Imperative Methods

    public Collection function each( callback ) {
        ArrayEach( collection.toArray(), callback );

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
            return listContainsNoCase( normalizeToList( value ), item[ key ] );
        } );
    }

    public Collection function whereNot( required string key, required any value ) {
        return this.reject( function( item ) {
            return listContainsNoCase( normalizeToList( value ), item[ key ] );
        } );
    }

    /* Returns a non-collection value */

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

    public boolean function has( callback ) {
        return ! this.filter( callback ).empty();
    }

    public boolean function any( callback ) {
        return this.has( callback );
    }

    public boolean function every( callback ) {
        return this.count() == this.filter( callback ).count();
    }

    public string function serialize( any fields ) {
        var thisCollection = isNull( fields ) ? this : this.pluck( fields );
        return serializeJSON( thisCollection.toArray() );
    }

    /* Private Methods */

    private Collection function clone() {
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
            arrayAppend( arr, row );
        }
        return arr;
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