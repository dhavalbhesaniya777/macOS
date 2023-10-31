#!/bin/zsh
### by Dhaval Bhesaniya

function createlocaladmin ()
{
   # new user account details
   username="SupportAdmin"
   displayName="IT Admin Support Account"
   password="m4c"
   admin="yes"
   hidden="yes"

   # determine next available UID
   highestUID=$( dscl . -list /Users UniqueID | /usr/bin/awk '$2>m {m=$2} END { print m }' )
   nextUID=$(( highestUID+1 ))

   # create the account
   /usr/bin/dscl . create "/Users/$username"
   /usr/bin/dscl . create "/Users/$username" UserShell /bin/zsh
   /usr/bin/dscl . create "/Users/$username" RealName "$displayName" 
   /usr/bin/dscl . create "/Users/$username" UniqueID "$nextUID"
   /usr/bin/dscl . create "/Users/$username" PrimaryGroupID 20
   /usr/bin/dscl . passwd "/Users/$username" "$password"

   # make the account admin, if specified
   if [[ "$admin" = "yes" ]]; then
      /usr/bin/dscl . append /Groups/admin GroupMembership "$username"
   fi

   # hide the account, if specified
   if [[ "$hidden" = "yes" ]]; then
      /usr/bin/dscl . create "/Users/$username" IsHidden 1
      /usr/bin/dscl . create "/Users/$username" NFSHomeDirectory "/private/var/$username"
   else
      /usr/bin/dscl . create "/Users/$username" NFSHomeDirectory "/Users/$username"
   fi
}

LOCAL_ADMIN_SHORTNAME="SupportAdmin"
if id "$LOCAL_ADMIN_SHORTNAME" >/dev/null 2>&1; then
      echo "user exists"
      # Enable FileVault SecureToken for this account
      sudo sysadminctl interactive -secureTokenOn SupportAdmin -password m4c

else
      echo "user does not exist | creating admin account"
      createlocaladmin
      # Enable FileVault SecureToken for this account
      sudo sysadminctl interactive -secureTokenOn SupportAdmin -password m4c

fi

exit 0
