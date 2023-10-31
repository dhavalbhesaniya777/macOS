#!/bin/zsh
### by Dhaval Bhesaniya
#<<< Make sure to replace source links/ blob storage links wherever it needs in this script.
#<<< I have used Microsoft Azure BlobStorage in this case, but you can use your own, or direct source links.

userName=$(/usr/bin/stat -f%Su /dev/console)            #<<< Getting the username
OS_Version=$(sw_vers -productVersion)                   #<<< Getting the macOS version number
OS_Arc=$(uname -m)                                      #<<< Getting the processor type
PresentDIR="/opt/Avid_Media_Bundle"
sudo rm -rf /opt/Avid_Media_Bundle                      #<<< Remove old sources from disk
sudo mkdir -p /opt/Avid_Media_Bundle                    #<<< Create source & present working directory
cd /opt/Avid_Media_Bundle                               #<<< Moving to new created present working directory

# Function to log the process
AppLogName="Avid_Media_Bundle.log"                      #<<< Define Logfile name
sudo mkdir -p /Users/$userName/IntuneLogs               #<<< Create Logfile directory
touch "/Users/$userName/IntuneLogs/$AppLogName"         #<<< Create Logfile
LOGFILE="/Users/$userName/IntuneLogs/$AppLogName"       #<<< Define Logfile directory 

########################################################
################## Functions to log process#############
########################################################

function logcomment() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $1" >> "$LOGFILE"
}
function logresult()	{
	if [ $? = 0 ] ; then
	  date "+%Y-%m-%d %H:%M:%S	$1" >> "$LOGFILE"
	else
	  date "+%Y-%m-%d %H:%M:%S	$2" >> "$LOGFILE"
	fi
}
##################################################################
################## Functions to Install applications #############
##################################################################

function install_vlc() {
  # define app name and name of DMG after downloading
  dmgFile="VLC.dmg"
  appName="VLC.app"
  downloadURL="https://download.videolan.org/pub/videolan/vlc/last/macosx/"

  # get the latest version of software available from website
  downloadFileName=$( curl --silent "$downloadURL" | grep "$OS_Arc" | awk -F "(>|<)" '/.*.dmg</{ print $3 }' )
  latestVersion=$( sed -e 's/vlc-//g' -e "s/-$OS_Arc.dmg//g" <<< "$downloadFileName" )

  # downloading software
  curl --silent --output "$dmgFile" "${downloadURL}${downloadFileName}"
  logresult "Downloaded $dmgFile." "Failed to download $dmgFile."

  # mounting DMG
  appVolume=$( hdiutil attach -nobrowse "$dmgFile" | grep /Volumes | sed -e 's/^.*\/Volumes\///g' )
  logresult "Mounted $appVolume DMG." "Failed to mount $appVolume DMG."

  # install software
  ditto -rsrc "/Volumes/$appVolume/$appName" "/Applications/$appName"
  logresult "Installed software." "Failed to install software."

  # unmount DMG
  umount "/Volumes/$appVolume"
  logresult "Unmounting $appVolume DMG." "Failed to unmount $appVolume DMG."
}
function install_AvidComposer() {
  dmgFile="Media_Composer_x_Mac.dmg"
  downloadURL="InsertLinkforSource/blobStorage"
  curl --silent --output "$dmgFile" "${downloadURL}"
  logresult "Downloaded $dmgFile." "Failed to download $dmgFile."
  appVolume=$( hdiutil attach -nobrowse "$dmgFile" | grep /Volumes | sed -e 's/^.*\/Volumes\///g' )
  logresult "Mounted $appVolume DMG." "Failed to mount $appVolume DMG."
  sudo installer -pkg "/Volumes/$appVolume/Install Media Composer.pkg"  -target /
  logcomment "App 'AvidComposer pack' is installed..."
  wait
}
function install_AvidLegacyComp() {
  zipFile="MediaComposerLegacyComponents.zip"
  downloadURL="InsertLinkforSource/blobStorage"
  curl --silent --output "$zipFile" "${downloadURL}"
  logresult "Downloaded zip." "Failed to download zip."
  unzip "${zipFile}"
  sudo installer -pkg "MediaComposerLegacyComponents.pkg"  -target /
  logcomment "App 'AvidLegacy Components' are installed..."
  wait
}
function install_CatalystBrowser() {
  # define app name and name of DMG after downloading
  appName1="Catalyst Browse.app"
  appName2="Catalyst Prepare.app"
  downloadURL="http://download.sonymediasoftware.com/current/"

  # get the latest version of software available from website
  downloadFileName=$( curl --silent "$downloadURL" | grep "catalystbrowse_" | awk -F "(>|<)" '/.*.dmg</{ print $6 }' | cut -d\" -f8 | tail -n 1)

  # downloading software
  curl --silent --output "$downloadFileName" "${downloadURL}${downloadFileName}"
  logresult "Downloaded Catalyst.dmg." "Failed to download Catalyst.dmg."

  # mounting DMG
  appVolume=$( hdiutil attach -nobrowse "$downloadFileName" | grep /Volumes | sed -e 's/^.*\/Volumes\///g' )
  logresult "Mounted $appVolume DMG." "Failed to mount $appVolume DMG."

  # install software
  ditto -rsrc "/Volumes/$appVolume/$appName1" "/Applications/$appName1"
  ditto -rsrc "/Volumes/$appVolume/$appName2" "/Applications/$appName2"
  logresult "Installed software." "Failed to install software."

  # unmount DMG
  umount "/Volumes/$appVolume"
  logresult "Unmounting $appVolume DMG." "Failed to unmount $appVolume DMG."
}
function install_CanonXF() {
  appName="XUMInstaller.app"
  zipFile="xum.dmg.gz"
  downloadFileName="xum.dmg"
  downloadURL="InsertLinkforSource/blobStorage"
  sudo curl -L -o "$zipFile" "${downloadURL}"
  logresult "Downloaded $downloadFileName." "Failed to download $downloadFileName."
  sudo gunzip "${zipFile}" | tar xvf -
  appVolume=$( hdiutil attach -nobrowse "$downloadFileName" | grep /Volumes | sed -e 's/^.*\/Volumes\///g' )
  sudo open -a "/Volumes/$appVolume/$appName"
  wait
  app_path="/Applications/Canon Utilities/Canon XF Utility/XFUtility3.app"
  until [[ -d "$app_path" ]]; do
    sleep 1  # Adding a short delay to avoid busy-waiting and reduce CPU usage
  done
  logcomment "App 'XFUtility3.app' is installed..."
}
function install_ShutterEncoder() {
  appNameSilicon="Shutter Encoder 17.3 Apple Silicon.pkg"
  appNameIntel="Shutter Encoder 17.3 Mac 64bits.pkg"
  downloadURL1="https://www.shutterencoder.com/Shutter%20Encoder%2017.3%20Apple%20Silicon.pkg"     # For Silicon
  downloadURL2="https://www.shutterencoder.com/Shutter%20Encoder%2017.3%20Mac%2064bits.pkg"        # For Intel
  
  if [[ ${OS_Arc} == "x86_64" ]]; then
      sudo curl -L -o "$appNameIntel" "${downloadURL2}"
      sudo installer -pkg "$PresentDIR/$appNameIntel"  -target /
      wait
  elif [[ ${OS_Arc} == "arm64" ]]; then
      sudo curl -L -o "$appNameSilicon" "${downloadURL1}"
      sudo installer -pkg "$PresentDIR/$appNameSilicon"  -target /
      wait
  else
      log_process "Operating System version is not compatible with ShutterEncoder"
  fi
  sleep 5
  sudo osascript -e 'tell application "Shutter Encoder" to quit'
}
function install_AsperaConnectExt() {

  INSTALL_PATH="/Library/Application Support/Google/Chrome/External Extensions"
  EXT_ID="kpoecbkildamnnchnlgoboipnblgikpn"

  sudo mkdir -p "$INSTALL_PATH"
  sudo chmod -R a-w "$INSTALL_PATH"

  cat <<JSON > "$INSTALL_PATH/$EXT_ID.json"
  {
    "external_update_url": "https://clients2.google.com/service/update2/crx"
  }
JSON

  sudo chown root:admin "$INSTALL_PATH/$EXT_ID.json"
  sudo chmod 644 "$INSTALL_PATH/$EXT_ID.json"

  # Prompt user to open Chrome and check the extensions page
  echo "The policy file has been created. Please open Chrome and visit chrome://extensions to see the added extension."
}
function install_AsperaConnect() {
  pkgFile="10_IBMAsperaConnectInstallerSystemWide.pkg"
  downloadURL="InsertLinkforSource/blobStorage"
  curl --silent --output "$pkgFile" "${downloadURL}"
  logresult "Downloaded $pkgFile." "Failed to download $pkgFile."
  sudo installer -pkg "$pkgFile" -target /
  logcomment "App 'Aspera Connect.app' is installed..."
  wait
}
function install_FileZilla() {
  appName="FileZilla.app"
  zipFile="FileZilla_3.65.0_macosx-x86.app.tar.bz2"
  downloadURL="InsertLinkforSource/blobStorage"
  sudo curl -L -o "$zipFile" "${downloadURL}"
  sudo tar -xvf "$zipFile"
  logresult "Downloaded $zipFile. & Extracted" "Failed to download $zipFile."
  ditto -rsrc "$appName" "/Applications/$appName"
  logcomment "App 'FileZilla.app' is installed..."
  wait
}
function install_Sony_Device_Dvr() {
  pkgFile="3_SxSDeviceDriver5.0.0.20.pkg"
  downloadURL="InsertLinkforSource/blobStorage"
  sudo curl --silent --output "$pkgFile" "${downloadURL}"
  logresult "Downloaded $pkgFile. & Extracted" "Failed to download $pkgFile."  
  sudo installer -pkg "$pkgFile" -target /
  logcomment "App 'Sony SxS Device driver' is installed..."
  wait
}
function install_Sony_Fam_Dvr() {
  pkgFile="4_FAM_Installer.pkg"
  downloadURL="InsertLinkforSource/blobStorage"
  sudo curl --silent --output "$pkgFile" "${downloadURL}"
  logresult "Downloaded $pkgFile. & Extracted" "Failed to download $pkgFile."  
  sudo installer -pkg "$pkgFile" -target /
  logcomment "App 'Sony Fam driver' is installed..."
  wait
}
function install_Sony_UDF_Dvr() {
  pkgFile="2_SxS_UDF_Driver_Software.pkg"
  downloadURL="InsertLinkforSource/blobStorage"
  sudo curl --silent --output "$pkgFile" "${downloadURL}"
  logresult "Downloaded $pkgFile. & Extracted" "Failed to download $pkgFile."  
  sudo installer -pkg "$pkgFile" -target /
  logcomment "App 'Sony Sxs UDF driver' is installed..."
  wait
}
function install_Bomgar() {
  dmgFile="bomgar-scc-w0eec305xi57zif....dmg"
  downloadURL="InsertLinkforSource/blobStorage"
  curl --silent --output "$dmgFile" "${downloadURL}"
  logresult "Downloaded $dmgFile." "Failed to download $dmgFile."
  appVolume=$( hdiutil attach -nobrowse "$dmgFile" | grep /Volumes | sed -e 's/^.*\/Volumes\///g' )
  logresult "Mounted $appVolume DMG." "Failed to mount $appVolume DMG."
  sudo open -a /Volumes/bomgar-scc/Double-Click\ To\ Start\ Support\ Session.app/Contents/MacOS/sdcust
  logcomment "App 'Bomgar' is installed..."
  wait
}

#################################################
################## Main Script Body #############
#################################################

install_CanonXF

install_Bomgar

install_vlc

install_FileZilla

install_AvidComposer

install_AvidLegacyComp

install_CatalystBrowser

install_ShutterEncoder

install_AsperaConnectExt

install_AsperaConnect

install_Sony_Device_Dvr

install_Sony_UDF_Dvr

install_Sony_Fam_Dvr

exit 0
