# Locate specific dependecy for given input eg. mdi velocity:velocity
function mdi() {
  mvn dependency:tree -Dverbose -Dincludes=$1
}

# list the keystore/truststore to view certificate in the keystore
# keystore - Store private key entries, certificates with public keys or just secret keys
# truststore - Client look up the associated certificate in our truststore
# eg. keytool_list $file_path
function keytool_list() {
  keytool -v -list -keystore $1
}
