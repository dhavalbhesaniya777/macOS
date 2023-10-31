#!/bin/sh
### by Dhaval Bhesaniya
# Function to log the process
log_process() {
    userName=$(/usr/bin/stat -f%Su /dev/console)
    AppLogName="NamingConvention.log"
    mkdir -p /Users/$userName/IntuneLogs
    touch "/Users/$userName/IntuneLogs/$AppLogName"
    LOGFILE="/Users/$userName/IntuneLogs/$AppLogName"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOGFILE"
}

# get currently logged in user
currentUser=$( /usr/bin/stat -f "%Su" /dev/console )
log_process "Current user is $currentUser"

# Detect Laguage/Locale
LanguageCheck=$(locale | grep LANG | cut -d\" -f2 | cut -d_ -f1)
if [[ "$LanguageCheck" == "en" ]]; then
	Lang="E"
else
	Lang="F"
fi

# Variables for asset tag
assetTag=$( /usr/sbin/system_profiler SPHardwareDataType | grep "Serial Number" | awk -F: '{print $2}'| tail -c 9  )
log_process "Asset tag is \"$assetTag\""


# Variables to prompt current user to choose a Sector
theCommand_Sector='choose from list {"President Office (PO)", "Corporate Development (CD)", "English Services (ES)", "French Services (FS)", "T & I (TI)", "Finance (FN)", "Legal Services (LS)", "People and Culture (PC)"} with title "CBC Devices Naming Convention" with prompt "CBC/Radio-Canada required the name of this macOS device to be modified to allign with the naming convention policies.

You can refer to the communication on iO you have received for more information.

Please choose the appropriate Sector &

Follow the next steps to complete the process.

"multiple selections allowed false empty selection allowed false'
# Variables to prompt current user to choose a Province
theCommand_Province='choose from list {"Alberta", "British Columbia", "FR-Paris", "Manitoba", "New Brunswick", "Newfoundland and Labrador", "Northwest Territories", "Nova Scotia", "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "UK-London", "United States", "Yukon"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
# Variables to prompt current user to choose a City
theCommand_Alberta='choose from list {"Calgary (CGY)", "Edmonton (EDM)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_BC='choose from list {"Burnaby (BRY)", "Kamloops (KLP)", "Kelowna (KEL)", "Nelson (NEL)", "PrinceGeorge (PRG)", "PrinceRupert (PRU)", "Vancouver (VCR)", "Victoria (VIC)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Paris='choose from list {"Paris (PAR)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Manitoba='choose from list {"Winnipeg (WPG)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_NB='choose from list {"Fredericton (FRD)", "Moncton (MCT)", "Saint-John (SNB)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_NFL='choose from list {"Corner Brook (COR)", "Gander (GND)", "Goose Bay (GBA)", "Saint-Jonhs (SNF)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_NT='choose from list {"Inuvik (INK)", "Yellowknife (YKN)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_NS='choose from list {"Halifax (HAL)", "Sydney (SYD)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Nunavut='choose from list {"Iqaluit (IQA)", "Rankin Inlet (RKI)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Ontario='choose from list {"Kitchener (KIT)", "London-ON (LON)", "Ottawa (OTT)", "Sudbury (SBY)", "Thunderbay (TBA)", "Toronto (TOR)", "Windsor (WDR)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_PEI='choose from list {"Charlottetown (CHR)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Quebec='choose from list {"Gaspe (GSP)", "Kuujjuaq (KUU)", "Matane (MAT)", "Montreal (MTL)", "Quebec City (QQU)", "Rimouski (RIM)", "Rouyn (RYN)", "Saguenay (SAG)", "Sept-Iles (SIL)", "Sherbrooke (SHB)", "Trois-Rivieres (TRS)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Saskatchewan='choose from list {"Regina (REG)", "Saskatoon (SKN)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_UK='choose from list {"London-UK (LDN)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_US='choose from list {"Washington (WAS)", "New York (NYC)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'
theCommand_Yukon='choose from list {"Whitehorse (WHS)"} with title "CBC Devices Naming Convention" with prompt "Choose a City/Site..." multiple selections allowed false empty selection allowed false'

function NamePrompt() {
	chosenSector=$(sudo osascript -e "$theCommand_Sector" )
	if [[ "$chosenSector" == "President Office (PO)" || "$chosenSector" == "Corporate Development (CD)" || "$chosenSector" == "English Services (ES)" || "$chosenSector" == "French Services (FS)" || "$chosenSector" == "T & I (TI)" || "$chosenSector" == "Finance (FN)" || "$chosenSector" == "Legal Services (LS)" || "$chosenSector" == "People and Culture (PC)" ]]; then
		SectorCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosenSector" )
		log_process "Choosing Sector \"$SectorCode\""
		chosenProvince=$(osascript -e "$theCommand_Province" )
		if [ "$chosenProvince" = "Alberta" ]; then
			chosensite=$(osascript -e "$theCommand_Alberta" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "British Columbia" ]; then
			chosensite=$(osascript -e "$theCommand_BC" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "FR-Paris" ]; then
			chosensite=$(osascript -e "$theCommand_Paris" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Manitoba" ]; then
			chosensite=$(osascript -e "$theCommand_Manitoba" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "New Brunswick" ]; then
			chosensite=$(osascript -e "$theCommand_NB" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Newfoundland and Labrador" ]; then
			chosensite=$(osascript -e "$theCommand_NFL" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Northwest Territories" ]; then
			chosensite=$(osascript -e "$theCommand_NT" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Nova Scotia" ]; then
			chosensite=$(osascript -e "$theCommand_NS" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Nunavut" ]; then
			chosensite=$(osascript -e "$theCommand_Nunavut" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Ontario" ]; then
			chosensite=$(osascript -e "$theCommand_Ontario" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Quebec" ]; then
			chosensite=$(osascript -e "$theCommand_Quebec" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Saskatchewan" ]; then
			chosensite=$(osascript -e "$theCommand_Saskatchewan" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "UK-London" ]; then
			chosensite=$(osascript -e "$theCommand_UK" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "United States" ]; then
			chosensite=$(osascript -e "$theCommand_US" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Prince Edward Island" ]; then
			chosensite=$(osascript -e "$theCommand_PEI" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		elif [ "$chosenProvince" = "Yukon" ]; then
			chosensite=$(osascript -e "$theCommand_Yukon" )
			siteCode=$( /usr/bin/awk -F "[()]" '{ print $2 } ' <<< "$chosensite" )
			log_process "Choosing Site \"$siteCode\""
		else
			log_process "Invalid option"
		fi
	else
		log_process "User cancelled the process"
	fi
}

# Looping condition until device name meets the conditions.
CurrentMachineName=$(hostname)
while [[ "$CurrentMachineName" != ???"A"??"${assetTag}${Lang}" ]]; do
	# Function to prompt a location selecation for user
	NamePrompt
	Wait
	# set the three computer names
	/usr/sbin/scutil --set ComputerName "${siteCode}A${SectorCode}${assetTag}${Lang}"
	/usr/sbin/scutil --set HostName "${siteCode}A${SectorCode}${assetTag}${Lang}"
	/usr/sbin/scutil --set LocalHostName "${siteCode}A${SectorCode}${assetTag}${Lang}"
    # Check if the condition has been matched
	CurrentMachineName=$(hostname)
    if [[ "$CurrentMachineName" == ???"A"??"${assetTag}${Lang}" ]]; then
		log_process "Device has been renamed with correct naming convention $CurrentMachineName"
        exit 0
    fi
done

log_process "Device already has correct naming convention $CurrentMachineName"

exit 0

