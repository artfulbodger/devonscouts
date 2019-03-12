---
external help file: devonscouts-help.xml
Module Name: devonscouts
online version:
schema: 2.0.0
---

# New-dsMailContact

## SYNOPSIS
Creates an External Mail contact.

## SYNTAX

```
New-dsMailContact [-ExternalEmailAddress] <String> [-firstname] <String> [-lastname] <String>
 [-membership_number] <String> [[-location] <String>] [[-role] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates an External Mail contact, and assigns ROle and Location if supplied.

## EXAMPLES

### EXAMPLE 1
```
New-dsMailContact -ExternalEmailAddress john.doe@example.com -firstname John -lastname Doe -location Devon -role 'County Commissioner'
```

Creates a new contact for John Doe, setting the External Emai laddress to john.doe@example.com.
Also sets the Location to Devon and the Title to County Commissioner.

## PARAMETERS

### -ExternalEmailAddress
Personal EMail address to send Email to.

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

### -firstname
Contacts first name.

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

### -lastname
Contacts last name.

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

### -membership_number
{{ Fill membership_number Description }}

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

### -location
Location where primary role is active.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -role
Primary Role stored on Compass.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
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
