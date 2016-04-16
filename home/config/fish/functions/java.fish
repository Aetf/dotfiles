function java --description "silence 'Picked up _JAVA_OPTIONS' message" -w java
    command java "$_SILENT_JAVA_OPTIONS" $argv
end
