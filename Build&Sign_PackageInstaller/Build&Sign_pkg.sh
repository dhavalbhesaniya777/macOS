#!/bin/bash
# By Dhaval Bhesaniya

credential_profile=FieldOpsSetup                #<<< Keychain Profile / Replace it as pe ryour requirement
identifier="com.Field.pkg.FieldOpsSetup"        #<<< Create an Identifier from your "Apple Developer Account"
password="gpod-doof-mbmr-zihp"                  #<<< Create a App specific password from your "Apple Developer Account"
version="1.1"                                   #<<< Specify required version name
pkg_name="FieldOps_Bundle"                      #<<< Specify .pkg file name
PKG_ROOT="Resource_en"                          #<<< Source directory name (This can not be empty, if no source needed then create simple txt file in this dir)
PKG_Script="Scripts"                            #<<< Preinstall or/and Postinstall scripts directory
cd ~/Desktop                                    #<<< Change your working directory wherever all above resources located, in this case I have used ~/Desktop/

###########################################  DO NOT CHANGE ANYTHING BELOW  #######################################################

# Building Package installer
sudo pkgbuild --identifier $identifier \
         --version $version \
         --root ~/Desktop/${PKG_ROOT}/ \
         --scripts ~/Desktop/${PKG_Script}/ \
         --install-location / \
         ~/Desktop/${pkg_name}.pkg

# Generating XML for package installer
sudo productbuild --synthesize --package ~/Desktop/${pkg_name}.pkg ~/Desktop/Distribution.xml
sudo productbuild --distribution ~/Desktop/Distribution.xml --package-path ~/Desktop/${pkg_name}.pkg ~/Desktop/${pkg_name}-xml.pkg

# Signing package installer (Replace your Developer ID Installer below)
productsign --sign "Developer ID Installer: XXXXXXXXXXXXXX" ${pkg_name}-xml.pkg ${pkg_name}-signed.pkg

# Notarization process (Replace your Developer Apple ID and Team-ID i.e 2S376Q6VV2 below)
xcrun notarytool store-credentials $credential_profile \
  --apple-id dhavalbhesaniya@gmail.com \
  --team-id 2S376Q6VJ2 \
  --password $password

xcrun notarytool submit ~/Desktop/${pkg_name}-signed.pkg \
  --keychain-profile "$credential_profile" \
  --wait

# Staple Notary ticket
xcrun stapler staple ${pkg_name}-signed.pkg
# Cleaning some unwanted files
rm -rf ~/Desktop/${pkg_name}.pkg
rm -rf ~/Desktop/${pkg_name}-xml.pkg
rm -rf ~/Desktop/Distribution.xml

exit 0
