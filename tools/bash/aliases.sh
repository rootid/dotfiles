
function list_space() {
  du -sk * | sort -g | awk '{ numBytes = $1 * 1024; numUnits = split("B K M G T P", unit); num = numBytes; iUnit = 0; while(num >= 1024 && iUnit + 1 < numUnits) { num = num / 1024; iUnit++; } $1 = sprintf( ((num == 0) ? "%6d%s " : "%6.1f%s "), num, unit[iUnit + 1]); print $0; }'
}

### commands {
alias lr='ls -ltr'
alias vi='vim -u NONE'
### }


##### APPS {
alias vlc=/Applications/VLC.app/Contents/MacOS/VLC


### }

##### JAVA {
### }


##### tskwrr {
alias tcal='task calendar'
### }

# vim: ai ts=2 sw=2 et sts=2 ft=sh fdm=marker
