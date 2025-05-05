# Check if the ExchangeOnlineManagement module is installed and install it if it is
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    # If not, install it
    Install-Module -Name ExchangeOnlineManagement -AllowClobber -Force -SkipPublisherCheck
}

# Import the Exchange Online module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline

#
# ONLY FOR TESTING
#
# Delete the journaling rule
# Remove-JournalRule -Identity "BullhornEmailTracking" -Confirm:$false
# Delete the distribution group
# Remove-DistributionGroup -Identity "BullhornEmailTracking" -Confirm:$false

# Prompt for domain name
$domain = Read-Host -Prompt "Enter the domain name"

# Prompt for tracking email with a default value
$trackingEmail = Read-Host -Prompt "Enter the tracking email (default is abc.123@slXtracker.bullhornstaffing.com)"
if ([string]::IsNullOrWhiteSpace($trackingEmail)) {
    $trackingEmail = "abc.123@slXtracker.bullhornstaffing.com"
}

# Create an empty distribution group
New-DistributionGroup -Name "BullhornEmailTracking" -DisplayName "Bullhorn Email Tracking Users" -PrimarySmtpAddress "bhtracking@$domain"

# Hide the group from address lists
Set-DistributionGroup -Identity "BullhornEmailTracking" -HiddenFromAddressListsEnabled $true

# Create a disabled journaling rule
New-JournalRule -Name "BullhornEmailTracking" -JournalEmailAddress $trackingEmail -Recipient "bhtracking@$domain" -Scope External -Enabled $false

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

# To update the Group, go to:
# https://admin.microsoft.com/Adminportal/Home?#/groups

# To update the Journaling rule, go to:
# https://compliance.microsoft.com/exchangeinformationgovernance?viewid=exoJournalRule