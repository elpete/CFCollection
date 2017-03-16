component accessors="true" {
    
    property name="label";
    property name="value";

    function init( required label, required value ) {
        variables.label = arguments.label;
        variables.value = arguments.value;
        return this;
    }

}