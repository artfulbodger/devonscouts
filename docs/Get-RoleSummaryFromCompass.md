---
external help file: devonscouts-help.xml
Module Name: devonscouts
online version: https://github.com/artfulbodger/devonscouts/wiki/Get-RoleSummaryFromCompass
schema: 2.0.0
---

# Get-RoleSummaryFromCompass

## SYNOPSIS
Generates a grouped summary of all roles from the Compass County Appointments Report.

## SYNTAX

```
Get-RoleSummaryFromCompass [[-csvfile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Generates a grouped summary of all roles with totals for each role sorted alphabetically by role. 
THe data is sourced from teh Comapss County APpointments Report.

## EXAMPLES

### EXAMPLE 1
```
Get-RoleSummaryFromCompass -csvfile 'C:\County Appointments Report %28Beta%29.csv'
```

## PARAMETERS

### -csvfile
Path to a local copy of the Compass Area/Region/County Appointments Report (usually named 'County Appointments Report %28Beta%29.csv')

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### List of input types that are accepted by this function.
## OUTPUTS

### List of output types produced by this function.
## NOTES
Place additional notes here.

## RELATED LINKS

[https://github.com/artfulbodger/devonscouts/wiki/Get-RoleSummaryFromCompass](https://github.com/artfulbodger/devonscouts/wiki/Get-RoleSummaryFromCompass)

