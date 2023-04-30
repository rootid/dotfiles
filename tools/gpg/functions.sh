## New syntax go_<tool>_<action>
# Create the key
function go_gpg_gen_key() {
  gpg --gen-key
}

# Create the key
function go_gpg_gen_key_full() {
  gpg --full-generate-key
}

# List the secret GPG keys
function go_gpg_list_secret_keys() {
  #gpg --list-secret-keys --with-colons | cut -d : -f 10 | sort -u | sed '/^$/d'
  gpg --list-secret-keys --keyid-format LONG
}

# List the GPG keys
function go_gpg_list_keys() {
  #gpg --list-secret-keys --with-colons | cut -d : -f 10 | sort -u | sed '/^$/d'
  gpg --list-keys
}

## Send key to Key Servers
## Usage - go_gpg_send_key_to_keyserver <fingerprint>
function go_gpg_send_key_to_keyserver() {
  #gpg --keyserver pgp.mit.edu --send-keys <fingerprint>
  gpg --keyserver pgp.mit.edu --send-keys $1
  gpg --keyserver hkps://keys.openpgp.org --send-keys $1
}

# Remove the secret key from the system
# Usage : go_gpg_rm_keys rootid
function go_gpg_rm_pvt_keys() {
  gpg --delete-secret-keys $1
}

# Usage : go_gpg_rm_keys Berlin
function go_gpg_rm_keys() {
  gpg --delete-secret-and-public-keys $1
}

# Usage: go_gpg_export_pvt_key rootid
function go_gpg_export_pvt_key() {
  gpg --export-secret-keys $1 > $1_pvt.key
}

# Usage: go_gpg_export_pub_key rootid
# Or go_gpg_export_pub_key finger_print
function go_gpg_export_pub_key() {
  gpg --armor --export $1 > $1_pub.key
}
