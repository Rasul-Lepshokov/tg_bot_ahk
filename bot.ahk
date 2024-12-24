#Include Jxon.ahk ; JSON parser library: https://github.com/cocobelgica/AutoHotkey-JSON
;ну нехуй тебе в коде ковыряться, старина, давай съебался отсюда
; === Конфиг ===
IniRead, telegramToken, config.ini, Telegram, telegramToken
IniRead, chatID, config.ini, Telegram, chatID
telegramToken := "https://api.telegram.org/bot" . telegramToken
lastUpdateId := 0

; === Функции ===
SendTelegramMessage(message) {
    global telegramToken, chatID
    url := telegramToken . "/sendMessage"
    data := "chat_id=" . chatID . "&text=" . message
    HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HTTP.Open("POST", url, false)
    HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    HTTP.Send(data)
}

GetTelegramUpdates() {
    global telegramToken, lastUpdateId
    url := telegramToken . "/getUpdates?offset=" . (lastUpdateId + 1)
    HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HTTP.Open("GET", url, false)
    HTTP.Send()
    return HTTP.ResponseText
}



recon() {
    IniRead, password, config.ini, Settings, password
    WinActivate, ahk_exe GTA5.exe
    Sleep, 1000
    SendInput, {F1}
    Sleep, 3000
	
    if WaitForImage("images\server_name.png", 40000, x, y) {
        Click, %x%, %y%
    } else {
       SendTelegramMessage("Error. Target server_name.png not found")
        return
    }

	if WaitForImage("images\password_field.png", 90000, x, y) {
    x += 100
    y += 9
    Sleep, 2000
    Click, %x%, %y%
} else {
    SendTelegramMessage("Error. Target password_field.png not found")
    return
}
	
    Sleep, 2000
    if (password != "") {
        Send, %password%
    } else {
        SendTelegramMessage("Error. password in config.ini not found")
    }

    Sleep, 1000
	SendInput, {Enter}

	if !WaitForImage("images\characters.png", 30000, x, y) {
    SendTelegramMessage("Error. Target characters.png not found")
    return
}

	if WaitForImage("images\characters.png", 90000, x, y) {
    x -= 100
    y -= 10
    Sleep, 2000
    Click, %x%, %y%
} else {
    SendTelegramMessage("Error. Target server_name.png not found")
    return
}


    if WaitForImage("images\confirm_character.png", 30000, x, y) {
        Click, %x%, %y%
    } else {
        SendTelegramMessage("Error. Target confirm_character.png not found")
        return
    }

    Sleep, 3000

    Click, 815, 1000

    if WaitForImage("images\spawn_confirm.png", 30000, x, y) {
        Click, %x%, %y%
    } else {
       SendTelegramMessage("Error. Target spawn_confirm.png not found")
        return
    }
}

	ImageSearchCoord(ByRef x, ByRef y, imagePath) {
    ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, %imagePath%
    if (ErrorLevel = 0) {
        return true
    } else {
        return false
    }
}

	WaitForImage(imagePath, timeout, ByRef x, ByRef y) {
    startTime := A_TickCount
    while ((A_TickCount - startTime) < timeout) {
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, %imagePath%
        if (ErrorLevel = 0) {
            return true
        }
        Sleep, 100
    }
    return false
}

wheel() {
	WinActivate, ahk_exe GTA5.exe
    Sleep, 1000                     
	SendInput, {UP}
	Sleep, 1500
	
    if WaitForImage("images\casino_icon.png", 40000, x, y) {
        Click, %x%, %y%
    } else {
       SendTelegramMessage("Error. Target casino_icon.png not found")
        return
    }
	
	Sleep, 1000
	Sleep, 1000
	SendInput, {TAB}
	Sleep, 500
	SendInput, {TAB}
	Sleep, 500
	SendInput, {Enter}
	Sleep, 1000
	SendInput, {TAB}
	Sleep, 500
	SendInput, {TAB}
	Sleep, 500
	SendInput, {Enter}
	Sleep, 15500 					 ; Ожидание результата
	SendInput, {ESC}
	Sleep, 1000
	SendInput, {ESC}	
	Sleep, 1000
	SendInput, {Backspace}
	
	
}

lottery() {
    WinActivate, ahk_exe GTA5.exe
    Sleep, 1000
	SendInput, {UP}  
	Sleep, 1500
	
    if WaitForImage("images\lottery.png", 40000, x, y) {
		Sleep, 1000
        Click, %x%, %y%
    } else {
       SendTelegramMessage("Error. Target lottery.png not found")
        return
    }
	
    if WaitForImage("images\buy_ticket.png", 40000, x, y) {
		Sleep, 1000
        Click, %x%, %y%
    } else {
       SendTelegramMessage("Error. Target buy_ticket.png not found")
        return
    }
	SendInput, {Backspace}
	Sleep, 1500
	SendInput, {Backspace}
}

noafk() {
    WinActivate, ahk_exe GTA5.exe
    Sleep, 1000
      Send, {w down}{s down}
	return
}

offnoafk() {
    WinActivate, ahk_exe GTA5.exe
    Sleep, 1000
    Send, {w up}{s up}
	Sleep, 1000 
	SendInput, {w}
	Sleep, 1000 
	SendInput, {s}
	return
}


screen() {
        SendTelegramMessage("Error. Eshe ne sdelal eto, problema pizdec")  
}



SendTelegramMessage("The script has started on the computer. Commands: /recon | /wheel | /lottery | /noafk | /offnoafk")
SetTimer, CheckTelegramCommands, 5000  ; Check every 5 seconds


CheckTelegramCommands:
{
    updates := GetTelegramUpdates()
    if (updates = "") {
        return
    }

    json := Jxon_Load(updates)
    if !json.result || !IsObject(json.result) || json.result.Length() = 0 {
        return
    }

    for each, update in json.result {
        lastUpdateId := update.update_id
        command := update.message.text
        
        if (command == "/recon") {
            recon()
            SendTelegramMessage("Command executed: recon.")
        } else if (command == "/wheel") {
            wheel()
            SendTelegramMessage("Command executed: wheel.")
        } else if (command == "/lottery") {
            lottery()
            SendTelegramMessage("Command executed: lottery.")
        } else if (command == "/noafk") {
            noafk()
            SendTelegramMessage("Command executed: noafk.")
        } else if (command == "/offnoafk") {
            offnoafk()
            SendTelegramMessage("Command executed: offnoafk.")
        } else if (command == "/screen") {
            screen()
            SendTelegramMessage("Command executed: screen.")
        }
    }
    return
}

#Persistent
return
