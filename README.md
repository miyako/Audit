![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/Audit)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/Audit/total)

# Audit
Tools to audit 4D project sanity (namespace: `Audit`)

## usage

```4d
var $forms : cs.Forms
$forms:=cs.Forms.new()

var $form : Object
$form:=$forms.formDefinition("Form1"; Table(->[Table_1]))
$events:=$forms.formEvents($form)
$eventsInMethod:=$forms.formMethodEvents($form)

$form:=$forms.formDefinition("Form1")
$events:=$forms.formEvents($form)
$eventsInMethod:=$forms.formMethodEvents($form)

/*
	find events that are activated in form but not used in method
*/

var $notUsedInMethod : Collection
$notUsedInMethod:=[]
For each ($event; $events)
	If ($eventsInMethod.query("constant == :1 and token == :2"; $event.constant; $event.token).length=0)
		$notUsedInMethod.push($event)
	End if 
End for each 

/*
	find events that are not activated form but used in method
*/

var $notActivatedInForm : Collection
$notActivatedInForm:=[]
For each ($event; $eventsInMethod)
	If ($events.query("constant == :1 and token == :2"; $event.constant; $event.token).length=0)
		$notActivatedInForm.push($events)
	End if 
End for each
```
