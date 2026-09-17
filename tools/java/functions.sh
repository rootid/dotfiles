#!/usr/bin/env zsh

# Locate specific dependecy for given input eg. go_java_dep_find velocity:velocity
function go_java_dep_find() {
  mvn dependency:tree -Dverbose -Dincludes=$1
}

# list the keystore/truststore to view certificate in the keystore
# keystore - Store private key entries, certificates with public keys or just secret keys
# truststore - Client look up the associated certificate in our truststore
# eg. go_java_keytool_list $file_path
function go_java_keytool_list() {
  keytool -v -list -keystore $1
}
