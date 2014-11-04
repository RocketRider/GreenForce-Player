***************************************
*** GreenForce Player *** GF-Player ***
*** http://GFP.RRSoftware.de **********
*** (c) 2009 - 2013 RocketRider *******
***************************************

With this litle tool you can automate encryption/decryption any video and audio files into the .gfp container.

/HELP             - shows this help text
/DECRYPT          - decrypt the declared file (default is encrypt)
/OUT              - output file
/PASSWORD         - password used to encrypt/decrypt file
/HINT             - hint for the password
/TITLE            - title (only encryption)
/ALBUM            - album (only encryption)
/INTERPRETER      - interpreter (only encryption)
/COMMENT          - comment (only encryption)
/LENGTH           - length (only encryption)
/DISALLOWRESTORE  - allow restore original file (only encryption)
/SNAPSHOT         - snapshot protection 0,1,2 (only encryption)
/COVER            - cover file (only encryption)
/USERDATA         - user data (only encryption)
/NOPASSWORD       - do not use a password
/READHEADER       - show information of header
/EXPIREDATE       - sets the expire date of the file 
/CODECNAME        - sets the name of the codec 
/CODECLINK        - sets the link of the codec
Example:
GFPCrypt.exe test.avi /PASSWORD "s3cret"