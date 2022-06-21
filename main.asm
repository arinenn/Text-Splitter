include console.inc

WordList struc
	aNext 		dd ?
	aPrev 		dd ?
	aStart 		dd ?
	wLength 	dd ?
	wCount 		dd ?
WordList ends

.data
	nil 		EQU 0
	List 		dd nil		; адрес на начало списка
	Lim_Len		dd 10		; предельная длина
	Flag_1 		db 0
	Flag_2 		db 0
	Flag_3 		db 0
	Flag_4 		db 0
	Flag_Slash  db 0
	Flag_Left 	db 0
	Flag_Right 	db 0

.code

 ; Расширение массива. EDX = адрес расширенного массива
AddLength proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edi
	push esi
	push edx
 ; Lim_Len - максимальная длина списка на данный момент
	mov esi, [ebp+12]		; адрес на начало массива
	mov ecx, [ebp+8]		; длина массива
 ; удваиваем предел по памяти
	mov edx, Lim_Len 		; для расширения
    mov ebx, Lim_Len
	add Lim_Len, ebx
	mov ebx, Lim_Len
 ; выделяем память под новый массив
	xor eax, eax
	push ecx
	push edx
	new ebx		 			; eax = адрес
	pop edx
	pop ecx
 ; переписываем массив
	mov ebx, edx			; ebx = старый предел
	mov edi, eax			; edi = eax = адрес
	xor ecx, ecx			; счётчик
	xor edx, edx			; символ
@Cycle:
	mov dl, byte ptr [esi+ecx]
	mov byte ptr [edi+ecx], dl
	inc ecx
	cmp ecx, ebx
	jne @Cycle
	dispose esi
	pop edx
	mov edx, edi
	pop esi
	pop edi
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 8
AddLength endp

 ; Ввод текста. EDX = адрес начало массива, EAX = длина массива
InputText proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	xor ebx, ebx			; символ
	xor eax, eax			; длина массива <=> счётчик
Vvod:
	inchar bl
L:	cmp bl, "\"
	je Check_Slash
	cmp bl, "@"
	je Check_Stop
	jmp Save
Check_Stop:
	inchar bl
	cmp bl, "%"
	je F1
	mov Flag_Slash, 0
	mov byte ptr [edx+eax], "@"
	inc eax
	cmp eax, Lim_Len
	jne L
	push edx
	push eax
	call AddLength
	jmp L
F1:	inchar bl
	cmp bl, "#"
	je F2
	mov Flag_Slash, 0
	mov byte ptr [edx+eax], "@"
	inc eax
	cmp eax, Lim_Len
	jne L0
	push edx
	push eax
	call AddLength
L0:	mov byte ptr [edx+eax], "%"
	inc eax
	cmp eax, Lim_Len
	jne L
	push edx
	push eax
	call AddLength
	jmp L
F2: inchar bl
	cmp bl, "%"
	je F3
	mov Flag_Slash, 0
	mov byte ptr [edx+eax], "@"
	inc eax
	cmp eax, Lim_Len
	jne L1
	push edx
	push eax
	call AddLength
L1:	mov byte ptr [edx+eax], "%"
	inc eax
	cmp eax, Lim_Len
	jne L2
	push edx
	push eax
	call AddLength
L2:	mov byte ptr [edx+eax], "#"
	inc eax
	cmp eax, Lim_Len
	jne L
	push edx
	push eax
	call AddLength
	jmp L
F3: inchar bl
	cmp bl, "@"
	je L6
	mov Flag_Slash, 0
	mov byte ptr [edx+eax], "@"
	inc eax
	cmp eax, Lim_Len
	jne L3
	push edx
	push eax
	call AddLength
L3:	mov byte ptr [edx+eax], "%"
	inc eax
	cmp eax, Lim_Len
	jne L4
	push edx
	push eax
	call AddLength
L4:	mov byte ptr [edx+eax], "#"
	inc eax
	cmp eax, Lim_Len
	jne L5
	push edx
	push eax
	call AddLength
L5:	mov byte ptr [edx+eax], "%"
	inc eax
	cmp eax, Lim_Len
	jne L
	push edx
	push eax
	call AddLength
	jmp L
L6:	cmp Flag_Slash, 1
	jne EndVvod
	mov Flag_Slash, 0
	mov byte ptr [edx+eax], "@"
	inc eax
	cmp eax, Lim_Len
	jne L7
	push edx
	push eax
	call AddLength
L7:	mov byte ptr [edx+eax], "%"
	inc eax
	cmp eax, Lim_Len
	jne L8
	push edx
	push eax
	call AddLength
L8:	mov byte ptr [edx+eax], "#"
	inc eax
	cmp eax, Lim_Len
	jne L9
	push edx
	push eax
	call AddLength
L9:	mov byte ptr [edx+eax], "%"
	inc eax
	cmp eax, Lim_Len
	jne Save
	push edx
	push eax
	call AddLength
	jmp Save
Check_Slash:
	inc Flag_Slash
	cmp Flag_Slash, 2
	jne Vvod
Save:
	mov Flag_Slash, 0
	mov byte ptr [edx+eax], bl
	inc eax
	cmp eax, Lim_Len
	jne Vvod
	push edx
	push eax
	call AddLength
	jmp Vvod
EndVvod:
	mov Flag_1, 	0
	mov Flag_2, 	0
	mov Flag_3, 	0
	mov Flag_4, 	0
	mov Flag_Slash, 0
	pop ecx
	pop ebx
	pop ebp
	ret 0
InputText endp

 ; Вывод текста
OutputText proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
 ; Вывод текста
	mov edx, [ebp+12]		; адрес на начало массива
	mov eax, [ebp+8]		; длина массива
	xor ecx, ecx			; счётчик
	xor ebx, ebx			; символ
@C:	mov bl, byte ptr [edx+ecx]
	outchar bl
	inc ecx
	cmp ecx, eax
	jne @C
	outstrln
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 8
OutputText endp

InsertToList proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	mov esi, [ebp+16]			; длина слова
	mov ebx, [ebp+12]			; адрес первого символа нового слова
	mov edx, [ebp+8]			; адрес List	
 ; Сравниваем на принадлежность к списку
 ; => если есть, то wCount += 1
 ; => если нет,  то вставляем в начало
 ; Далее - сортировка
	mov edi, [edx]		; на edi находится значение List (адрес на первый узел)
Search:
	cmp edi, nil
	je Create
	; теперь сравниваем длину. Если длины совпали, то смотрим посимвольно.
	cmp [edi].WordList.wLength, esi
	jne Next
	; Значит, длины совпали
	xor edx, edx
	mov eax, [edi].WordList.aStart 		; Адрес начала старого слова
	xor ecx, ecx
K:	mov dl, [ebx+ecx]					; Старый символ
	cmp [eax], dl
	jne Next
	inc ecx
	inc eax
	cmp ecx, esi
	jne K
	; Слова совпадают!
	inc [edi].WordList.wCount
	jmp EndInsert
Next:
	mov edi, [edi].WordList.aNext
	jmp Search
Create:
	mov edx, [ebp+8]			; адрес List
	mov edi, [edx]; на edi находится значение List (адрес на первый узел)
	push ecx	
	push edx
	new sizeof WordList			; EAX := адрес нового узла. Портит ECX, EDX
	pop edx
	pop ecx
	mov [eax].WordList.wCount, 	1
	mov [eax].WordList.wLength, esi
	mov [eax].WordList.aStart, 	ebx
	mov [eax].WordList.aNext, 	edi ; ссылка на нач. списка
	mov [eax].WordList.aPrev,   nil
 ; Создали новый узел. Теперь присоединяем в начало списка
	cmp edi, nil
	je Join
	mov [edi].WordList.aPrev, eax ; List^.prev = eax
Join:
	mov [edx], eax ; List = eax = адрес нового узла
EndInsert:
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 12
InsertToList endp

MakeList proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	mov edi, [ebp+12] 			; Адрес Text[0]
	xor ecx, ecx 				; счётчик пробега по массиву
	xor esi, esi 				; счётчик длины слова
	xor eax, eax				; Элемент массива
	xor ebx, ebx				; Адрес первого символа слова
	mov Flag_2, 1				; Отвечает за отсутствие символов перед словом
 ; Считаем слово -> Создаём узел списка (адрес первого символа, длина слова)	
@P: mov al, [edi+ecx]	
 ; A-65////Z-90  a-97////z-122
	cmp al, "A"
	jb Check
	cmp al, "z"
	ja Check
	cmp al, "a"
	jae Good
	cmp al, "Z"
	jbe Good
	jmp Check
Check: ; проверка на сохранённое слово
	cmp esi, 0
	je Continue0
 ; проверим на окаймление знаками препинания
	cmp Flag_2, 1
	je LeftCEnd
	mov dl, byte ptr [ebx-1]
	cmp dl, 9
	je LeftCEnd
	cmp dl, 10
	je LeftCEnd
	cmp dl, " "
	je LeftCEnd
	cmp dl, "?"
	je LeftCEnd
	cmp dl, "!"
	je LeftCEnd
	cmp dl, ","
	je LeftCEnd
	cmp dl, "."
	je LeftCEnd
	cmp dl, ";"
	je LeftCEnd
	cmp dl, ":"
	je LeftCEnd
	cmp dl, "-"
	je LeftCEnd
	cmp dl, "`"
	je LeftCEnd
	cmp dl, "("
	je LeftCEnd
	cmp dl, ")"
	je LeftCEnd
	jmp Continue0
LeftCEnd:
	mov dl, byte ptr [ebx+esi]
	cmp dl, 9
	je ToList
	cmp dl, 10
	je ToList
	cmp dl, " "
	je ToList
	cmp dl, "?"
	je ToList
	cmp dl, "!"
	je ToList
	cmp dl, ","
	je ToList
	cmp dl, "."
	je ToList
	cmp dl, ";"
	je ToList
	cmp dl, ":"
	je ToList
	cmp dl, "-"
	je ToList
	cmp dl, "`"
	je ToList
	cmp dl, "("
	je ToList
	cmp dl, ")"
	je ToList
	jmp Continue0
Good:
	cmp ebx, 0
	jne LL
	lea ebx, [edi+ecx] ; Запомнили адрес первого символа слова
LL:	inc esi
	jmp Continue
ToList:
 ; Имеется Длина слова (=> адрес первого символа), 
	cmp esi, 0 					; если подряд идущие знаки препинания
	je Continue0
	push esi					; длина слова
	push ebx					; адрес первого символа слова
	push offset List			; адрес List
	call InsertToList
Continue0:
	mov Flag_2, 0
	xor ebx, ebx
	xor esi, esi
Continue:
	inc ecx
	cmp ecx, [ebp+8]			; длина массива
	jne @P
	cmp esi, 0
	je EndMakeList
 ; посмотрим наличие знака препинания слева
	cmp Flag_2, 1
	je TL
	mov dl, byte ptr [ebx-1]
	cmp dl, 9
	je TL
	cmp dl, 10
	je TL
	cmp dl, " "
	je TL
	cmp dl, "?"
	je TL
	cmp dl, "!"
	je TL
	cmp dl, ","
	je TL
	cmp dl, "."
	je TL
	cmp dl, ";"
	je TL
	cmp dl, ":"
	je TL
	cmp dl, "-"
	je TL
	cmp dl, "`"
	je TL
	cmp dl, "("
	je TL
	cmp dl, ")"
	je TL
	jmp EndMakeList
 ; Обработали массив, внесём оставшуюся последовательность
TL:	push esi					; длина слова
	push ebx					; адрес первого символа слова
	push offset List			; адрес List
	call InsertToList
EndMakeList:
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 8
MakeList endp

OutputList proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push esi
	push edi
	mov edi, List						; значение List (как адреса)
Write:
	cmp edi, nil
	je EndOutput
	mov eax, [edi].WordList.aStart		; адрес начала
	mov esi, [edi].WordList.wLength		; длина слова
	xor ecx, ecx						; счётчик пробегаx
	xor ebx, ebx						; тут символ
	outstr "| wC: "
	outword [edi].WordList.wCount
	outstr " wL: "
	outword [edi].WordList.wLength
	outstr " "
T:	mov bl, [eax+ecx]
	outchar bl
	inc ecx
	cmp ecx, esi
	jne T
	outstrln " "
	mov edi, [edi].WordList.aNext
	jmp Write
EndOutput:
	pop edi
	pop esi
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 0
OutputList endp

LengthList proc
	push ebp
	mov ebp, esp
	push edi
 ; Длина списка. Ответ на EAX
	mov edi, List 			; edi := List
	xor eax, eax			; тут ответ
@V: cmp edi, nil
	je EndCount
	inc eax
	mov edi, [edi].WordList.aNext
	jmp @V
EndCount:
	pop edi
	pop ebp
	ret 0
LengthList endp

SwapValues proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
 ; Подаём переменные без offset
	mov esi, [ebp+12]			; Адрес Первого слова
	mov edi, [ebp+8]			; Адрес Второго слова
 ; Запоминаем первое слово
	mov eax, [esi].WordList.aStart
	mov ebx, [esi].WordList.wLength
	mov ecx, [esi].WordList.wCount
 ; Меняем первое на второе
	mov edx, [edi].WordList.aStart
	mov [esi].WordList.aStart, edx
	mov edx, [edi].WordList.wLength
	mov [esi].WordList.wLength, edx
	mov edx, [edi].WordList.wCount
	mov [esi].WordList.wCount, edx
 ; Меняем второе на первое
	mov [edi].WordList.aStart, eax
	mov [edi].WordList.wLength, ebx
	mov [edi].WordList.wCount, ecx
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 8
SwapValues endp

InsertionSort proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	mov edx, List					; Значение List
	mov ebx, [edx].WordList.aNext 	; ebx := head := List^.Next
	call LengthList					; eax := len_list
	outstr "Length of list equals to "
	outword eax
	outstrln "."
	mov esi, 1
L1:	inc esi							; co_1 := 2
	cmp eax, esi
	jb	EndSort
	mov ecx, ebx					; ecx := buf := head
	mov edi, esi					; edi := co_2 := co_1 =: esi
L2: cmp edi, 1						; 		while (co_2 > 1) and 
	jbe L3
	mov edx, [ebx].WordList.aPrev	; edx := head^.prev
	mov edx, [edx].WordList.wCount	; edx := head^.prev^.count
	cmp [ebx].WordList.wCount, edx	; 	 	(head^.count > head^.prev^.count) do
	jb  L3
	je  L9
	mov edx, [ebx].WordList.aPrev	; edx := head^.prev
	push ebx	; head
	push edx	; head^.prev
	call SwapValues					; swap(head, head^.prev)
	jmp L4
L9:	 
 ; проверка по длине
	mov edx, [ebx].WordList.aPrev	; edx := head^.prev
	mov edx, [edx].WordList.wLength
	cmp [ebx].WordList.wLength, edx
	jb 	L4
	je	L5
 ; т.е. [ebx].WordList.wLength > edx
	mov edx, [ebx].WordList.aPrev
	push ebx
	push edx
	call SwapValues
	jmp L4
L5:
 ; т.е. [ebx].WordList.wLength = edx
	mov edx, [ebx].WordList.aPrev	; edx := head^.prev
	push eax
	push ecx
	xor eax, eax
	xor ecx, ecx
	mov eax, [edx].WordList.aStart
	mov ecx, [ebx].WordList.aStart
 ; al < cl  => меняем местами и оканчиваем
 ; al = cl  => продолжаем
 ; al > cl  => оканчиваем
L6:	push eax
	push ecx
	mov al, [eax]
	mov cl, [ecx]
	cmp al, cl
	pop ecx
	pop eax
	je L8
	ja L7
	mov Flag_1, 1
	jmp L7
L8:	inc eax
	inc ecx
	jmp L6	
L7: pop ecx
	pop eax
	cmp Flag_1, 1
	jne L4
	mov Flag_1, 0
	push edx
	push ebx
	call SwapValues
L4:	mov edx, [ebx].WordList.aPrev
	mov ebx, edx					; head := head^.prev
	dec edi							; co_2 -= 1
	jmp L2
L3:	mov ebx, [ecx].WordList.aNext	; head := buf^.next
	cmp esi, eax					; for co_1:=2 to len_list
	jne L1
EndSort:
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 0
InsertionSort endp

 ; Функция. Flag_1 := 1, если следующие (n) символов - самое частое слово, 0 - иначе.
CompareStrAdr proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
 ; [ebp+16] - адрес частого слова
 ; [ebp+12] - длина частого слова
 ; [ebp+8]  - адрес начала проверяемого слова
	mov Flag_1, 0
	mov esi, [ebp+16]
	mov ecx, [ebp+12]
	mov edi, [ebp+8]
	xor edx, edx
	cmp Flag_2, 1
	je CEnd
	dec edi
	mov al, [edi]					; тут символ перед словом
	cmp al, 9
	je CEnd
	cmp al, 10
	je CEnd
	cmp al, " "
	je CEnd
	cmp al, "?"
	je CEnd
	cmp al, "!"
	je CEnd
	cmp al, ","
	je CEnd
	cmp al, "."
	je CEnd
	cmp al, ";"
	je CEnd
	cmp al, ":"
	je CEnd
	cmp al, "-"
	je CEnd
	cmp al, "`"
	je CEnd
	cmp al, "("
	je CEnd
	cmp al, ")"
	je CEnd
	jmp EndCompare
CEnd:
	cmp Flag_3, 1
	je KK
	mov edi, [ebp+8]
	mov al, [edi+ecx]				; тут символ после слова
	cmp al, 9
	je KK
	cmp al, 10
	je KK
	cmp al, " "
	je KK
	cmp al, "?"
	je KK
	cmp al, "!"
	je KK
	cmp al, ","
	je KK
	cmp al, "."
	je KK
	cmp al, ";"
	je KK
	cmp al, ":"
	je KK
	cmp al, "-"
	je KK
	cmp al, "`"
	je KK
	cmp al, "("
	je KK
	cmp al, ")"
	je KK
	jmp EndCompare			
KK:	mov edi, [ebp+8]				; начинаем сравнивать
@J:	mov al, [edi+edx]
	mov bl, [esi+edx]
	cmp al, bl
	jne EndCompare
	inc edx
	cmp edx, ecx
	jne @J
	inc Flag_1
EndCompare:
	mov Flag_2, 0
	mov Flag_3, 0
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 12
CompareStrAdr endp

TaskOutputText proc
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi
	sub esp, 4
 ; Информация по самому частому слову
	mov edx, List
	mov edi, [edx].WordList.aStart
	mov esi, [edx].WordList.wLength
 ; Вывод текста
	mov ebx, [ebp+8]		; Длина массива
	xor ecx, ecx			; Счётчик
	mov edx, [ebp+12]  		; Адрес начала массива
 ; Flag_2 отвечает за отсутствие символов перед словом
 ; Flag_3 отвечает за отсутствие символов после слова
	mov [ebp-28], ebx
	sub [ebp-28], esi
	mov Flag_2, 1
	mov Flag_3, 0
BB:	cmp ecx, [ebp-28]
	ja @L
	jne @K
	mov Flag_3, 1
@K:	push edi
	push esi
	lea eax, [edx+ecx]
	push eax
	call CompareStrAdr		; Flag_1 := 0 (или 1)
	cmp Flag_1, 1
	jne @L
 ; т.е. Flag_1 = 1
	add ecx, esi
@L:	mov al, [edx+ecx]
	outchar al
	inc ecx
	cmp ecx, ebx
	jb BB
	mov Flag_1, 0
	mov Flag_2, 0
	mov Flag_3, 0
	add esp, 4
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 8
TaskOutputText endp

Start:
 ; edx = адрес на начало массива
 ; eax = длина массива
	mov ebx, Lim_Len
	push edx
	push ecx
	new ebx
	pop ecx
	pop edx
	mov edx, eax
	call InputText
	cmp eax, 0
	jne Go1
	outstrln "Empty Text!"
	exit
Go1:
	push edx
	push eax
	call MakeList
	cmp List, nil
	jne Go2
	outstrln "No Words! But Here's the Text:"
	push edx
	push eax
	call OutputText
	exit
Go2:
	call InsertionSort
	call OutputList
	;push edx
	;push eax
	;call OutputText
	push edx
	push eax
	call TaskOutputText
	exit
end Start