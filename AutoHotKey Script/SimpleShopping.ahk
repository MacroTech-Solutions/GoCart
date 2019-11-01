CoordMode, Pixel, Screen
count = 0
test2 := 1
count2 = 0
while(count<20)
{
MouseClick, left, 1590, 727
MouseClick, left, 1590, 727
;MouseClick, left, 1590, 727

Sleep, 250

Send ^x
literal_quote = "
arr := [literal_quote, Clipboard, literal_quote]
outputVar := Format("{1}{2}{3}", arr*)
Sleep, 200
Run C:\Users\joshr\Documents\GitHub\GoCart\NodeJS\run.bat %outputVar%
Sleep, 1000
Send ^c
Sleep, 100
Send y
Sleep, 100
Send {Enter}
FileReadLine, test_b, C:\Users\joshr\Documents\GitHub\GoCart\NodeJS\output.txt, 1
Sleep, 100
test := test_b
if (test == "Not purchased"){
while (count2<100){
  SoundBeep, 750, 250
  count2++
}
count2 = 0
}
count++
}
Esc::ExitApp
