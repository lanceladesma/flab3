BITS 32

%define SYS_EXIT  1
%define SYS_READ  3
%define SYS_WRITE 4
%define STDIN     0
%define STDOUT    1

; -----------------------------
; Macros
; -----------------------------

; Prints a zero-terminated string.
%macro PRINT 1
    mov ecx, %1
    call print_string
%endmacro

; Prints a new line.
%macro NEWLINE 0
    PRINT newline
%endmacro

; Prints a label followed by a number and a new line.
%macro PRINT_AMOUNT 2
    PRINT %1
    mov eax, %2
    call print_number
    NEWLINE
%endmacro

section .data
    title       db 10, '==================== TUITION ASSESSMENT ====================', 10, 0
    promptStatus db 'Enrollment status: ', 0
    promptID    db 'Student number: ', 0
    promptName  db 'Student name: ', 0
    promptPhone db 'Phone number: ', 0
    promptCollege db 'College: ', 0
    promptProgram db 'Program: ', 0
    promptYearTerm db 'Year level and term: ', 0
    promptAddress db 'Address: ', 0
    promptUnits db 'Total units: ', 0
    newline     db 10, 0

    header      db 10, '-------------------------------- SCHEDULE --------------------------------', 10, 0
    courseHead  db 'CODE     | COURSE TITLE                          | SEC  | UNIT | DAYS | TIME                         | ROOM', 10, 0
    courseLine  db '---------+---------------------------------------+------+------+------+-----------------------------+-------------', 10, 0
    course1     db 'CCS0021  | Information Management (LEC)          | TN24 |  2   | T    | 16:00:00-18:40:00           | ONLINE', 10, 0
    course2     db 'CCS0021L | Information Management (LAB)          | TN24 |  1   | F    | 16:00:00-18:50:00           | ONLINE', 10, 0
    course3     db 'CS0001   | Discrete Structures 1                 | TN24 |  3   | S/W  | 15:00:00-16:50:00           | F710/F710', 10, 0
    course4     db 'CS0003   | Computer Systems & Architecture      | TN24 |  2   | F    | 10:00:00-12:40:00           | ONLINE', 10, 0
    course5     db 'CS0003L  | Computer Systems & Architecture (LAB) | TN24 |  1   | TH   | 10:00:00-12:50:00           | E610', 10, 0
    course6     db 'CS0070   | Object Oriented Programming           | TN26 |  2   | F    | 13:00:00-15:40:00           | ONLINE', 10, 0
    course7     db 'CS0070L  | Object Oriented Programming-LAB        | TN26 |  1   | M    | 13:00:00-15:50:00           | E609', 10, 0
    course8     db 'GED0021  | Specialized English Program           | TN24 |  3   | S/W  | 11:00:00-12:50:00           | F607/F607', 10, 0
    course9     db 'GED0055  | Mathematical Analysis                 | M553 |  3   | S/W  | 09:00:00-10:50:00           | F712/F712', 10, 0
    course10    db 'GED0081  | College Physics 1 Lecture             | TS21 |  2   | T    | 10:00:00-12:40:00           | ONLINE', 10, 0
    course11    db 'GED0081L | College Physics 1 Laboratory          | TS21 |  1   | M    | 10:00:00-12:50:00           | F1003', 10, 0
    courseTotal db 'TOTAL UNITS: ', 0

    feesTitle   db 10, '----------------------------- FEES -----------------------------', 10, 0
    tuitionLbl  db 'Tuition Fee: ', 0
    miscLbl     db 'Miscellaneous Fee: ', 0
    idLbl       db 'ID Validation Fee: ', 0
    lab1Lbl     db 'ITE Computer Laboratory Fee (CCS0021): ', 0
    lab2Lbl     db 'ITE Computer Laboratory Fee (CS0003): ', 0
    lab3Lbl     db 'ITE Computer Laboratory Fee (CS0070): ', 0
    scienceLbl  db 'Science Lab Fee (GED0081): ', 0
    totalLbl    db 'TOTAL ASSESSMENT: ', 0
    pesoLbl     db ' pesos', 0

    studentLbl  db 10, '------------------------- STUDENT DETAILS -------------------------', 10, 0
    statusOutput db 'Enrollment status: ', 0
    idOutput    db 'Student number: ', 0
    nameOutput  db 'Student name: ', 0
    phoneOutput db 'Phone number: ', 0
    collegeOutput db 'College: ', 0
    programOutput db 'Program: ', 0
    yearTermOutput db 'Year level and term: ', 0
    addressOutput db 'Address: ', 0
    classOutput db 'Classification: ', 0
    unitsOutput db 'Total units: ', 0

    ; Fixed fees from the reference assessment.
    miscFee     equ 12305
    idFee       equ 80
    labFee      equ 4008
    scienceFee  equ 4104
    ratePerUnit equ 2108
    fixedFees   equ miscFee + idFee + (labFee * 3) + scienceFee

section .bss
    enrollmentStatus resb 64
    studentID   resb 64
    studentName resb 128
    phone       resb 64
    college     resb 64
    program     resb 64
    yearTerm    resb 64
    address     resb 128
    unitsText   resb 32
    numChar     resb 1

section .text
    global _start

_start:
    ; Read all requested information from the top part.
    ; Classification is intentionally not requested as user input.
    PRINT promptStatus
    mov ecx, enrollmentStatus
    mov edx, 64
    call read_line

    PRINT promptID
    mov ecx, studentID
    mov edx, 64
    call read_line

    PRINT promptName
    mov ecx, studentName
    mov edx, 128
    call read_line

    PRINT promptPhone
    mov ecx, phone
    mov edx, 64
    call read_line

    PRINT promptCollege
    mov ecx, college
    mov edx, 64
    call read_line

    PRINT promptProgram
    mov ecx, program
    mov edx, 64
    call read_line

    PRINT promptYearTerm
    mov ecx, yearTerm
    mov edx, 64
    call read_line

    PRINT promptAddress
    mov ecx, address
    mov edx, 128
    call read_line

    PRINT promptUnits
    mov ecx, unitsText
    mov edx, 32
    call read_line

    ; Convert the units text into a number.
    mov esi, unitsText
    call parse_number
    mov ebp, eax                    ; save total units

    ; Compute tuition and total assessment.
    mov eax, ebp
    call calculate_tuition          ; EAX = tuition fee
    mov edi, eax                    ; save tuition fee
    add eax, fixedFees              ; EAX = total assessment
    mov ebx, eax                    ; save total assessment

    ; -----------------------------
    ; Display the completed assessment
    ; -----------------------------
    PRINT title
    PRINT studentLbl

    PRINT statusOutput
    PRINT enrollmentStatus
    NEWLINE
    PRINT idOutput
    PRINT studentID
    NEWLINE
    PRINT nameOutput
    PRINT studentName
    NEWLINE
    PRINT phoneOutput
    PRINT phone
    NEWLINE
    PRINT collegeOutput
    PRINT college
    NEWLINE
    PRINT programOutput
    PRINT program
    NEWLINE
    PRINT yearTermOutput
    PRINT yearTerm
    NEWLINE
    PRINT addressOutput
    PRINT address
    NEWLINE
    PRINT classOutput
    NEWLINE
    NEWLINE
    ; Courses are pre-printed. No course input is requested.
    PRINT header
    PRINT courseHead
    PRINT courseLine
    PRINT course1
    PRINT course2
    PRINT course3
    PRINT course4
    PRINT course5
    PRINT course6
    PRINT course7
    PRINT course8
    PRINT course9
    PRINT course10
    PRINT course11
    PRINT courseTotal
    mov eax, ebp
    call print_number
    NEWLINE

    PRINT feesTitle
    PRINT_AMOUNT tuitionLbl, edi
    PRINT_AMOUNT miscLbl, miscFee
    PRINT_AMOUNT idLbl, idFee
    PRINT_AMOUNT lab1Lbl, labFee
    PRINT_AMOUNT lab2Lbl, labFee
    PRINT_AMOUNT lab3Lbl, labFee
    PRINT_AMOUNT scienceLbl, scienceFee
    PRINT_AMOUNT totalLbl, ebx
    PRINT pesoLbl
    NEWLINE

    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

; ------------------------------------------------------------
; Procedure: print_string
; Input: ECX = address of a zero-terminated string
; ------------------------------------------------------------
print_string:
    push eax
    push ebx
    push edx
    push edi

    mov edi, ecx
    xor edx, edx
.length:
    cmp byte [edi + edx], 0
    je .write
    inc edx
    jmp .length
.write:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    int 0x80

    pop edi
    pop edx
    pop ebx
    pop eax
    ret

; ------------------------------------------------------------
; Procedure: read_line
; Input: ECX = buffer address, EDX = buffer size
; Removes the Enter key from the input.
; ------------------------------------------------------------
read_line:
    push ebx
    push esi
    push edi

    mov esi, ecx
    mov edi, edx
    mov eax, SYS_READ
    mov ebx, STDIN
    int 0x80
    test eax, eax
    jle .empty

    xor edx, edx
.scan:
    cmp edx, eax
    jae .terminate
    cmp byte [esi + edx], 10
    je .terminate
    inc edx
    jmp .scan
.terminate:
    mov byte [esi + edx], 0
    jmp .done
.empty:
    mov byte [esi], 0
.done:
    pop edi
    pop esi
    pop ebx
    ret

; ------------------------------------------------------------
; Procedure: parse_number
; Input: ESI = address of decimal text
; Output: EAX = converted unsigned integer
; ------------------------------------------------------------
parse_number:
    xor eax, eax
.next_digit:
    mov bl, [esi]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done
    imul eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx
    inc esi
    jmp .next_digit
.done:
    ret

; ------------------------------------------------------------
; Procedure: calculate_tuition
; Input: EAX = total units
; Output: EAX = total tuition fee
; ------------------------------------------------------------
calculate_tuition:
    imul eax, ratePerUnit
    ret

; ------------------------------------------------------------
; Procedure: print_number
; Input: EAX = unsigned integer
; ------------------------------------------------------------
print_number:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    cmp eax, 0
    jne .convert
    mov byte [numChar], '0'
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, numChar
    mov edx, 1
    int 0x80
    jmp .finish

.convert:
    xor esi, esi
    mov ebx, 10
.divide:
    xor edx, edx
    div ebx
    push edx
    inc esi
    test eax, eax
    jnz .divide

.display:
    pop edx
    add dl, '0'
    mov [numChar], dl
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, numChar
    mov edx, 1
    int 0x80
    dec esi
    jnz .display

.finish:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret