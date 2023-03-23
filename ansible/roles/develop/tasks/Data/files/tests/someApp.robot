*** Settings ***
Documentation     Smoketesting someApp.

Library        collections

*** Variables ***
${C_HOSTNAME}       ${NODE}

*** Tasks ***
Display calling arguments
    Show Arguments

Connect to node
    Do Something

Validate smoke


*** Keywords ***
Show arguments
    Log To Console    \n
    Log To Console    The node name is: ${NODE}
    Log To Console    The stage is: ${STAGE}
    Log To Console    \n

Do Something
    Log To Console    Hi there!

Validate smoke
    Log To Console    Ugh!
