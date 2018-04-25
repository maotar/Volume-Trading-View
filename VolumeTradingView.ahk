#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent ; Keep the script running until the user exits it.
#SingleInstance
#Include Jxon.ahk ; Autohotkey JSON library, Credit https://github.com/cocobelgica
SetTitleMatchMode, 2
SetKeyDelay, 0

; Get monitor size
SysGet, Mon, MonitorWorkArea

; Calculate 2x2 tile size

BoxHeight := Floor(MonBottom / 2) -5
BoxWidth := Floor(MonRight / 2) -5

; Set tile x/y positions

BoxX := BoxWidth + 5
BoxY := BoxHeight + 5

; Make sure ActiveX control functions in latest IE mode

Prev := FixIE()

; Create GUI

Gui, Add, ActiveX, x0 y0 w%BoxWidth% h%BoxHeight% HwndhTV1 vTV1, Shell.Explorer
Gui, Add, ActiveX, x0 y%BoxY% w%BoxWidth% h%BoxHeight% HwndhTV2 vTV2, Shell.Explorer
Gui, Add, ActiveX, x%BoxX% y0 w%BoxWidth% h%BoxHeight% HwndhTV3 vTV3, Shell.Explorer
Gui, Add, ActiveX, x%BoxX% y%BoxY% w%BoxWidth% h%BoxHeight% HwndhTV4 vTV4, Shell.Explorer

Gui, Show

; Query Binance API for top volume coins, then set timer for re-check every 5 minutes
firstrun = 1
Gosub, GetVolume
SetTimer, GetVolume, 300000

return

GuiClose:
ExitApp

; Function for IE version mode, credit https://gist.github.com/G33kDude

FixIE(Version=0, ExeName="")
{
	static Key := "Software\Microsoft\Internet Explorer"
	. "\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	, Versions := {7:7000, 8:8888, 9:9999, 10:10001, 11:11001}
	
	if Versions.HasKey(Version)
		Version := Versions[Version]
	
	if !ExeName
	{
		if A_IsCompiled
			ExeName := A_ScriptName
		else
			SplitPath, A_AhkPath, ExeName
	}
	
	RegRead, PreviousValue, HKCU, %Key%, %ExeName%
	if (Version = "")
		RegDelete, HKCU, %Key%, %ExeName%
	else
		RegWrite, REG_DWORD, HKCU, %Key%, %ExeName%, %Version%
	return PreviousValue
}



GetVolume:
	
	; Get ticker statistic JSON from Binance API

	url = https://api.binance.com/api/v1/ticker/24hr	
	Try 
	{
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	      WebRequest.Open("GET", url, false)
	      WebRequest.Send()	      
	      contents := WebRequest.ResponseText	

	      contentsJSON := Jxon_Load(contents)
	      items:=contentsJSON.Length()
	 }     	    
	    
	    ; Get top 4 volume coins

	    max = 0
	    Needle = BTC
		loop % contentsJSON.Length()
		{
		    i := A_Index
		    vol:=contentsJSON[i].quoteVolume
		    sym:=contentsJSON[i].symbol
		    if (sym = "BTCUSDT")
		    	continue
		    if(vol>max){
		    	IfInString, sym, %Needle%
		    	{
			    	max:= vol
			    	symbol1:=sym
		    	}
		    }		    
		}

		max = 0
	    Needle = BTC
		loop % contentsJSON.Length()
		{
		    i := A_Index
		    vol:=contentsJSON[i].quoteVolume
		    sym:=contentsJSON[i].symbol
		    if (sym = "BTCUSDT")
		    	continue
		    if(vol>max){
		    	IfInString, sym, %Needle%
		    	{
		    		if (sym != symbol1)
		    		{
				    	max:= vol
				    	symbol2:=sym
			    	}
		    	}
		    }		    
		}

		max = 0
	    Needle = BTC
		loop % contentsJSON.Length()
		{
		    i := A_Index
		    vol:=contentsJSON[i].quoteVolume
		    sym:=contentsJSON[i].symbol
		    if (sym = "BTCUSDT")
		    	continue
		    if(vol>max){
		    	IfInString, sym, %Needle%
		    	{
			    	if (sym != symbol1) and (sym != symbol2)
		    		{
				    	max:= vol
				    	symbol3:=sym
			    	}
		    	}
		    }		    
		}

		max = 0
	    Needle = BTC
		loop % contentsJSON.Length()
		{
		    i := A_Index
		    vol:=contentsJSON[i].quoteVolume
		    sym:=contentsJSON[i].symbol
		    if (sym = "BTCUSDT")
		    	continue
		    if(vol>max){
		    	IfInString, sym, %Needle%
		    	{
			    	if (sym != symbol1) and (sym != symbol2) and (sym != symbol3)
		    		{
				    	max:= vol
				    	symbol4:=sym
			    	}
		    	}
		    }		    
		}	

		; Set tradingview url's	

		url1 = http://tradingview.com/chart/?symbol=BINANCE:%symbol1%
		url2 = http://tradingview.com/chart/?symbol=BINANCE:%symbol2%
		url3 = http://tradingview.com/chart/?symbol=BINANCE:%symbol3%
		url4 = http://tradingview.com/chart/?symbol=BINANCE:%symbol4%

		if (firstrun=1){


			TV1.Navigate(url1)
			Sleep, 1000
			TV2.Navigate(url2) 
			Sleep, 1000
			TV3.Navigate(url3) 
			Sleep, 1000
			TV4.Navigate(url4)
			
			orgurl1 := url1
			orgurl2 := url2
			orgurl3 := url3
			orgurl4 := url4
		}

		; If refresh only refresh changed url's

		if (firstrun=0){			

			if(url1 != orgurl1)
			{
				TV1.Navigate(url1)
				Sleep, 1000
			}
			if(url2 != orgurl2)
			{
				TV2.Navigate(url2)
				Sleep, 1000
			}
			if(url3 != orgurl3)
			{
				TV3.Navigate(url3)
				Sleep, 1000
			}
			if(url4 != orgurl4)
				TV4.Navigate(url4)

			orgurl1 := url1
			orgurl2 := url2
			orgurl3 := url3
			orgurl4 := url4

		}


		firstrun = 0
		

	      return

; Fullscreen url hotkeys, esc key returns to 2x2

#IfWinActive, VolumeTradingView.ahk

$1::
Send, 1
GuiControl, Move, TV1, x0 y0 w%MonRight% h%MonBottom% 
Guicontrol, Show, TV1
Guicontrol, Hide, TV2
Guicontrol, Hide, TV3
Guicontrol, Hide, TV4



return

$2::
Send, 2
GuiControl, Move, TV2, x0 y0 w%MonRight% h%MonBottom% 
Guicontrol, Hide, TV1
Guicontrol, Show, TV2
Guicontrol, Hide, TV3
Guicontrol, Hide, TV4


return

$3::
Send, 3
GuiControl, Move, TV3, x0 y0 w%MonRight% h%MonBottom%
Guicontrol, Hide, TV1
Guicontrol, Hide, TV2
Guicontrol, Show, TV3
Guicontrol, Hide, TV4


return

$4::
Send, 4
GuiControl, Move, TV4, x0 y0 w%MonRight% h%MonBottom%
Guicontrol, Hide, TV1
Guicontrol, Hide, TV2
Guicontrol, Hide, TV3
Guicontrol, Show, TV4


return

$Esc::
Send {Esc}
GuiControl, Move, TV1, w%BoxWidth% h%BoxHeight%
GuiControl, Move, TV2, x0 y%BoxY% w%BoxWidth% h%BoxHeight%
GuiControl, Move, TV3, x%BoxX% y0 w%BoxWidth% h%BoxHeight%
GuiControl, Move, TV4, x%BoxX% y%BoxY% w%BoxWidth%

Guicontrol, Show, TV1
Guicontrol, Show, TV2
Guicontrol, Show, TV3
Guicontrol, Show, TV4
return

#IfWinActive