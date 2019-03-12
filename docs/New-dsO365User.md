---
external help file: devonscouts-help.xml
Module Name: devonscouts
online version:
schema: 2.0.0
---

# New-dsO365User

## SYNOPSIS
Creates a new Office 365 user and licenses for base services.

## SYNTAX

```
New-dsO365User [-firstname] <String> [-lastname] <String> [-role] <String> [-membershipnumber] <String>
 [-credential] <PSCredential> [-noteamscard] [<CommonParameters>]
```

## DESCRIPTION
Creates a new Office 365 user and grants a new E2 license with unrequire services disabled.

## EXAMPLES

### EXAMPLE 1
```
New-dsO365User -firstname 'John' -lastname 'Doe' -role 'County Commissioner'
```

Creates a new User Called John Doe with an alias of john.doe@devonscouts.org.uk

## PARAMETERS

### -firstname
Users Firstname as defined on Compass.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -lastname
Users Lastname as defined on Compass.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -role
Users primary role as defined on Compass.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -membershipnumber
Compass Membership Number

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -credential
{{ Fill credential Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -noteamscard
{{ Fill noteamscard Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Int32
## NOTES

## RELATED LINKS
