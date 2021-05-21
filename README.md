# Daily-InfoSec-News
A quick and dirty PowerShell script to lookup daily InfoSec news from a variety of sources and email to user(s)

## Overview
I wrote this script to automate the process of checking daily InfoSec news articles from a variety of online sources:

* The Register: Security
* ZDNet Security
* KrebsOnSecurity
* TheHackerNews
* ThreatPost

## Usage
Script can be run daily via a scheduled task.

`To/From/SmtpServer` fields need to be set in the script before use.

## Known Issues
* Blank emails occasionally sent (usually a Sunday/Monday), instead of email to say *"Nothing reported, check back tomorrow"* (I need to find time to look at this, sorry!)
