# Ensure ExchangeOnlineManagement is installed
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module -Name ExchangeOnlineManagement -AllowClobber -Force -SkipPublisherCheck
}

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Prompt for input
$domain = Read-Host -Prompt "Enter the domain name"
$trackingEmail = Read-Host -Prompt "Enter the tracking email (default is abc.123@slXtracker.bullhornstaffing.com)"
if ([string]::IsNullOrWhiteSpace($trackingEmail)) {
    $trackingEmail = "abc.123@slXtracker.bullhornstaffing.com"
}

# Group name setup
$groupName = "BullhornEmailTracking"
$groupEmail = "bhtracking@$domain"

# Create the group
$group = New-DistributionGroup -Name $groupName -DisplayName "Bullhorn Email Tracking Users" -PrimarySmtpAddress $groupEmail

# Wait for provisioning
Start-Sleep -Seconds 5

# Detect group type
$groupDetails = Get-Recipient -Identity $groupName

switch ($groupDetails.RecipientTypeDetails) {
    "GroupMailbox" {
        # It's a Unified Group (Microsoft 365 Group)
        Set-UnifiedGroup -Identity $groupName -HiddenFromAddressListsEnabled $true
        Write-Host "✅ Group is a Unified Group. Hidden from address lists."
    }
    "MailUniversalDistributionGroup" {
        # It's a classic DG
        Set-DistributionGroup -Identity $groupName -HiddenGroupMembershipEnabled $true
        Write-Host "✅ Group is a Distribution Group. Membership hidden from address book."
    }
    default {
        Write-Warning "⚠️ Group type '$($groupDetails.RecipientTypeDetails)' is not explicitly handled."
    }
}

# Inform user about journaling rule
Write-Warning "⚠️ Journaling rules must now be created manually in the Microsoft Purview Compliance portal:"
Write-Host "   https://compliance.microsoft.com/exchangeinformationgovernance?viewid=exoJournalRule"

Disconnect-ExchangeOnline -Confirm:$false
