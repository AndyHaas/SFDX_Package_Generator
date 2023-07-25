#Salesforce Package Version Creation and Promotion Script

This shell script automates the process of creating a new Salesforce package version and promoting it. It uses the Salesforce CLI (sfdx) to create the new package version, extracts the SubscriberPackageVersionId from the JSON response, and then promotes the package version using the extracted ID. Finally, it generates an install link for the package version.

Author: Andy Haas

Created Date: 2023-07-25
Last Modified Date: 2023-07-25

Expected Results:
- The script will create a new Salesforce package version.
- If the package version creation is successful, it will promote the package.
- It will display loading messages to keep the user informed about the progress.
- Upon completion, it will generate an install link for the package version.

Note: jq will need to be installed for this script to work.
jq is a lightweight and flexible command-line JSON processor.
It can be downloaded from https://stedolan.github.io/jq/download/.

For Ubuntu/Debian-based systems:

