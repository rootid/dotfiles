function go_create_ssh_key() {
 ssh-keygen -t rsa -b 4096 -C "$1"
}
