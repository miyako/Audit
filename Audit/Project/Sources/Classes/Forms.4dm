property name : Text
property extension : Text
property fullName : Text
property eventConstantGroup : Text

Class constructor
	
	This:C1470.name:="form"
	This:C1470.extension:=".4DForm"
	This:C1470.eventConstantGroup:=":K2"
	
	This:C1470.fullName:=This:C1470.name+This:C1470.extension
	
Function formMethodEvents($form : Object) : Collection
	
	var $events : Collection
	$events:=[]
	
	If (Not:C34(OB Instance of:C1731($form.method; 4D:C1709.File)))
		return $events
	End if 
	
	var $method : Text
	$method:=$form.method.getText("utf-8"; Document with CR:K24:21)
	
	var $lines : Collection
	$lines:=Split string:C1554($method; "\r")
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $regex : Text
	$regex:="(\\w[\\w ]*\\w+)("+This:C1470.eventConstantGroup+":\\d+)"
	var $line; $constant; $token : Text
	For each ($line; $lines)
		$line:=Parse formula:C1576($line; Formula out with tokens:K88:3)
		If (Match regex:C1019($regex; $line; 1; $pos; $len))
			$constant:=Substring:C12($line; $pos{1}; $len{1})
			$token:=Substring:C12($line; $pos{2}; $len{2})
			$events.push({constant: $constant; token: $token})
		End if 
	End for each 
	
	return $events
	
Function formEvents($form : Object) : Collection
	
	var $events : Collection
	$events:=[]
	
	If ($form=Null:C1517)
		return $events
	End if 
	
	If (Value type:C1509($form.events)#Is collection:K8:32)
		return $events
	End if 
	
	var $eventName; $constant; $token : Text
	For each ($eventName; $form.events)
		$constant:=This:C1470.eventNameToConstant($eventName)
		$token:=This:C1470.eventConstantToToken($constant)
		$events.push({constant: $constant; token: $token})
	End for each 
	
	return $events
	
Function formDefinition($formName : Text; $tableNumber : Integer) : Object
	
	If ($formName="")
		return 
	End if 
	
	var $file : 4D:C1709.File
	If (Is table number valid:C999($tableNumber))
		$file:=Folder:C1567("/SOURCES/TableForms/"; *).folder(String:C10($tableNumber)).folder($formName).file(This:C1470.fullName)
	Else 
		$file:=Folder:C1567("/SOURCES/Forms/"; *).folder($formName).file(This:C1470.fullName)
	End if 
	
	If (Not:C34($file.exists))
		return 
	End if 
	
	var $form : Object
	$form:=JSON Parse:C1218($file.getText(); Is object:K8:27)
	
	If (Value type:C1509($form.method)=Is text:K8:3) && ($form.method#"")
		$file:=$file.parent.file($form.method)
		If ($file.exists)
			$form.method:=$file
		End if 
	End if 
	
	return $form
	
Function eventConstantToToken($eventToken : Text) : Text
	
	$eventToken:=Parse formula:C1576($eventToken; Formula out with tokens:K88:3)
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $regex : Text
	$regex:="("+This:C1470.eventConstantGroup+":\\d+)"
	
	If (Match regex:C1019($regex; $eventToken; 1; $pos; $len))
		return Substring:C12($eventToken; $pos{1}; $len{1})
	End if 
	
	return $eventToken
	
Function eventNameToConstant($camelCase : Text) : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $i : Integer
	$i:=1
	
	var $tokens : Collection
	var $token : Text
	$tokens:=[]
	$token:=""
	
	Case of 
		: ($camelCase="OnClick")
			return "On Clicked"
			
		: ($camelCase="onAlternateClick")
			return "On Alternative Click"
			
		: ($camelCase="onDoubleClick")
			return "On Double Clicked"
			
		: ($camelCase="onMenuSelect")
			return "On Menu Selected"
			
		: ($camelCase="onPluginArea")
			return "On Plug in Area"
			
		: ($camelCase="onColumnMove")
			return "On Column Moved"
			
		: ($camelCase="onRowMove")
			return "On Row Moved"
			
		Else 
			While (Match regex:C1019("(((?:^|[:uppercase:])[:lowercase:]+)|URL|VP)"; $camelCase; $i; $pos; $len))
				$token:=Substring:C12($camelCase; $pos{1}; $len{1})
				$token:=Change string:C234($token; Uppercase:C13($token[[1]]; *); 1)
				$tokens.push($token)
				$i:=$pos{1}+$len{1}
			End while 
	End case 
	
	return $tokens.join(" ")