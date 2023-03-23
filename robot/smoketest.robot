*** Settings ***
Library            collections
Library           SeleniumLibrary
Library           OperatingSystem
Documentation     Smoketesting someApp.
*** Variables ***
${BROWSER1}         headlessfirefox
${DELAY}            0
${WEBSITE URL}      http://frontendserver-0.sscict.vforge.net/

*** Tasks ***
Validate smoke
    See if the server is running

*** Keywords ***

See if the server is running
    Open Browser                ${WEBSITE URL}       ${BROWSER1}
    Maximize Browser Window
    Set Selenium Speed          ${DELAY}
    Home Page Should Be Open
    Close Browser

Home page should be Open
    Sleep                       1
    Location Should Contain     ${WEBSITE URL}
    Page Should Contain         Gallery
    Title Should Be             Meow!
