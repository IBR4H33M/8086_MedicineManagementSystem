.MODEL SMALL
.STACK 100H

.DATA

; Main menu variables
main_menu      db 10,13,'MEDICINE MANAGEMENT SYSTEM',10,13,'$'
menu_opt       db 10,13,'1. Display Medicines List',10,13,'2. Find Medicine by First Letter',10,13,'3. Exit Program',10,13,'$'
prompt         db 10,13,'Enter your choice: $'
invalid        db 10,13,'Invalid option! Please try again.$'

; Medicine categories variables
cat_menu       db 10,13,'MEDICINE CATEGORIES:',10,13,'$'
cat_opt1       db 10,13,'1. Painkillers$',0
cat_opt2       db 10,13,'2. Antibiotics$',0
cat_opt3       db 10,13,'3. Return to Main Menu$',0

; Painkiller medicines
pain_title     db 10,13,'PAINKILLER MEDICINES:',10,13,'$'
pain_med1      db 10,13,'1. Aspirin - 50TK$',0
pain_med2      db 10,13,'2. Ibuprofen - 100TK$',0
pain_med3      db 10,13,'3. Paracetamol - 20TK$',0
pain_ret       db 10,13,'4. Return to Categories$',0

; Antibiotic medicines
anti_title     db 10,13,'ANTIBIOTIC MEDICINES:',10,13,'$'
anti_med1      db 10,13,'1. Amoxicillin - 200TK$',0
anti_med2      db 10,13,'2. Ciprofloxacin - 150TK$',0
anti_med3      db 10,13,'3. Doxycycline - 30TK$',0
anti_ret       db 10,13,'4. Return to Categories$',0

; Search by letter variables
search_prompt  db 10,13,'Enter the first letter to search for medicines: $'
search_result  db 10,13,'Medicines starting with the letter: $'
no_match       db 10,13,'No medicines found with that letter.$'

continue_msg   db 10,13,'Press any key to continue...$',0

; strings for Add to Cart and Discount Feature
qty_prompt       db 10,13,'Enter quantity (1-9): $',0
validate_qty     db 10,13,'Invalid quantity. Please enter a digit from 1 to 9.$',0
discount_prompt  db 10,13,'Enter discount option (0: None, 1:10%, 2:15%, 3:20%, 4:25%): $',0
discount_invalid db 10,13,'Invalid discount option. Try again.$',0
confirm_prompt   db 10,13,'Press 1 to confirm purchase, 2 to add another medicine, or any other key to discard cart: $',0

; Invoice-related strings
InvoiceTitle     db '*** INVOICE ***', '$'
ItemHeader       db 'Medicine             Quantity', '$'
ItemLineBreak    db '---------------------------------', '$'
receipt_total_msg    db 10,13,'Final Total (after discount): ', '$'
receipt_discount_msg db 10,13,'Discount Savings: ', '$'
cart_total_msg   db 10,13,'Current Cart Total: ', '$'

; A tab string for aligning column output in the invoice.
tab_str db '       ', '$'

; Totals, price, and discount variables
cart_total           dw 0      
cart_original_total  dw 0        
selected_price       dw 0         

; Invoice data variables
selected_med_code    db 0      
current_qty          db 0         
invoice_index        db 0         
invoice_table        db 20 dup(0) 

; Medicine names for invoice.
AspirinName       db 'Aspirin', '$'
IbuprofenName     db 'Ibuprofen', '$'
ParacetamolName   db 'Paracetamol', '$'
AmoxicillinName   db 'Amoxicillin', '$'
CiprofloxacinName db 'Ciprofloxacin', '$'
DoxycyclineName   db 'Doxycycline', '$'

; Medicine database
medicines      db 'Aspirin$', 'Ibuprofen$', 'Paracetamol$', 'Amoxicillin$', 'Ciprofloxacin$', 'Doxycycline$', 0

; Buffer for number conversion.
num_buffer db 6 dup(0)

.CODE

;-------------------------
; PressAnyKey Proc
;-------------------------------

PressAnyKey PROC
MOV AH,9
LEA DX, continue_msg
INT 21h
MOV AH,1
INT 21h
RET
PressAnyKey ENDP

;-------------------------
; PrintNumber Proc
;--------------------------------
PrintNumber PROC
push ax
push bx
push cx
push dx

mov bx,10         
lea di, num_buffer+5  
mov byte ptr [di], '$'
dec di

cmp ax,0
jne PN_Loop
mov byte ptr [di], '0'
dec di
jmp PN_Done

PN_Loop:
xor dx,dx
div bx  
add dl, '0'            
mov [di], dl
dec di
cmp ax,0
jne PN_Loop

PN_Done:
lea dx, [di+1]
mov ah, 9
int 21h

pop dx
pop cx
pop bx
pop ax
ret
PrintNumber ENDP

;-----------------
; PrintMedicineName Proc
;-----------------------------
PrintMedicineName PROC
CMP AL,1
JE PrintAspirin
CMP AL,2
JE PrintIbuprofen
CMP AL,3
JE PrintParacetamol
CMP AL,4
JE PrintAmoxicillin
CMP AL,5
JE PrintCiprofloxacin
CMP AL,6
JE PrintDoxycycline
RET
PrintAspirin:
MOV AH,9
LEA DX, AspirinName
INT 21h
RET
PrintIbuprofen:
MOV AH,9
LEA DX, IbuprofenName
INT 21h
RET
PrintParacetamol:
MOV AH,9
LEA DX, ParacetamolName
INT 21h
RET
PrintAmoxicillin:
MOV AH,9
LEA DX, AmoxicillinName
INT 21h
RET
PrintCiprofloxacin:
MOV AH,9
LEA DX, CiprofloxacinName
INT 21h
RET
PrintDoxycycline:
MOV AH,9
LEA DX, DoxycyclineName
INT 21h
RET
PrintMedicineName ENDP

;-----------------------
; GenerateInvoice proc
;-------------------------------
GenerateInvoice PROC
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h
MOV DL,13
INT 21h
MOV DL,10
INT 21h

MOV AH,9
LEA DX, InvoiceTitle
INT 21h
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h

MOV AH,9
LEA DX, ItemHeader
INT 21h
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h

MOV AH,9
LEA DX, ItemLineBreak
INT 21h
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h

MOV SI, offset invoice_table
MOV BL, invoice_index
InvoiceLoop:
CMP BL,0
JE InvoiceDone
MOV AL, [SI]        
CALL PrintMedicineName    
MOV AH,9
LEA DX, tab_str
INT 21h
MOV AL, [SI+1]
MOV AH,0
MOV AX,0
MOV AL, [SI+1]
CALL PrintNumber
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h

ADD SI,2
SUB BL,2
JMP InvoiceLoop
InvoiceDone:
MOV AH,9
LEA DX, receipt_total_msg
INT 21h
MOV AX, [cart_total]
CALL PrintNumber
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h

MOV AH,9
LEA DX, receipt_discount_msg
INT 21h
MOV AX, [cart_original_total]
SUB AX, [cart_total] 
CALL PrintNumber
MOV AH,2
MOV DL,13
INT 21h
MOV DL,10
INT 21h

RET
GenerateInvoice ENDP

;---------------------
; Main Program and Menus
;--------------------------------
MAIN PROC
MOV AX, @DATA
MOV DS, AX

MainMenu:
MOV AH,9
LEA DX, main_menu
INT 21h
LEA DX, menu_opt
INT 21h
LEA DX, prompt
INT 21h

MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,1
JE DisplayCategories
CMP AL,2
JE SearchByLetter
CMP AL,3
JE ExitProgram

MOV AH,9
LEA DX, invalid
INT 21h
CALL PressAnyKey
JMP MainMenu

;--------------------
; DisplayCategories
;--------------------------------
DisplayCategories:
MOV AH,9
LEA DX, cat_menu
INT 21h
LEA DX, cat_opt1
INT 21h
LEA DX, cat_opt2
INT 21h
LEA DX, cat_opt3
INT 21h
LEA DX, prompt
INT 21h

MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,1
JE PainkillerList
CMP AL,2
JE AntibioticList
CMP AL,3
JE MainMenu

MOV AH,9
LEA DX, invalid
INT 21h
CALL PressAnyKey
JMP DisplayCategories

;-------------------------------
; PainkillerList
;----------------------
PainkillerList:
MOV AH,9
LEA DX, pain_title
INT 21h
LEA DX, pain_med1
INT 21h
LEA DX, pain_med2
INT 21h
LEA DX, pain_med3
INT 21h
LEA DX, pain_ret
INT 21h
LEA DX, prompt
INT 21h

MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,4
JE DisplayCategories

CMP AL,1
JE Painkiller_Select1
CMP AL,2
JE Painkiller_Select2
CMP AL,3
JE Painkiller_Select3

InvalidPain:
MOV AH,9
LEA DX, invalid
INT 21h
CALL PressAnyKey
JMP PainkillerList

Painkiller_Select1:
MOV word ptr [selected_price], 50 
MOV selected_med_code, 1             
JMP AddQuantity

Painkiller_Select2:
MOV word ptr [selected_price], 100   
MOV selected_med_code, 2               
JMP AddQuantity

Painkiller_Select3:
MOV word ptr [selected_price], 20    
MOV selected_med_code, 3              
JMP AddQuantity

;----------------
; AntibioticList
;--------------------------
AntibioticList:
MOV AH,9
LEA DX, anti_title
INT 21h
LEA DX, anti_med1
INT 21h
LEA DX, anti_med2
INT 21h
LEA DX, anti_med3
INT 21h
LEA DX, anti_ret
INT 21h
LEA DX, prompt
INT 21h

MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,4
JE DisplayCategories

CMP AL,1
JE Antibiotic_Select1
CMP AL,2
JE Antibiotic_Select2
CMP AL,3
JE Antibiotic_Select3

InvalidAnti:
MOV AH,9
LEA DX, invalid
INT 21h
CALL PressAnyKey
JMP AntibioticList

Antibiotic_Select1:
MOV word ptr [selected_price], 200 
MOV selected_med_code, 4           
JMP AddQuantity

Antibiotic_Select2:
MOV word ptr [selected_price], 150 
MOV selected_med_code, 5            
JMP AddQuantity

Antibiotic_Select3:
MOV word ptr [selected_price], 30 
MOV selected_med_code, 6          
JMP AddQuantity

;-------------
; AddQuantity
;------------------
AddQuantity:
MOV AH,9
LEA DX, qty_prompt
INT 21h
MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,1
JB InvalidQuantity
CMP AL,9
JA InvalidQuantity
MOV current_qty, AL   


MOV BL, AL                
MOV AX, [selected_price]
MUL BL                    
MOV BX, AX               


ADD [cart_original_total], BX

MOV AH,9
LEA DX, discount_prompt
INT 21h

DiscountInput:
MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,0
JB InvalidDiscount
CMP AL,4
JA InvalidDiscount
CMP AL,0
JE NoDiscount
CMP AL,1
JE Discount10
CMP AL,2
JE Discount15
CMP AL,3
JE Discount20
Discount25:
MOV CX,75
JMP CalculateDiscount

Discount20:
MOV CX,80
JMP CalculateDiscount

Discount15:
MOV CX,85
JMP CalculateDiscount

Discount10:
MOV CX,90
JMP CalculateDiscount

NoDiscount:
MOV CX,100

CalculateDiscount:
MOV AX, BX
MUL CX
MOV DX,0
MOV BX,100
DIV BX    

ADD [cart_total], AX

MOV AL, invoice_index     
MOV AH, 0
MOV DI, offset invoice_table
ADD DI, AX                  
MOV AL, selected_med_code
MOV [DI], AL        
INC DI
MOV AL, current_qty
MOV [DI], AL                

MOV AL, invoice_index
ADD AL, 2
MOV invoice_index, AL

MOV AH,9
LEA DX, cart_total_msg
INT 21h
MOV AX, [cart_total]
CALL PrintNumber

MOV AH,9
LEA DX, confirm_prompt
INT 21h
MOV AH,1
INT 21h
SUB AL, '0'
CMP AL,1
JE ConfirmPurchase
CMP AL,2
JE AddAnotherMedicine

MOV word ptr [cart_total], 0
MOV word ptr [cart_original_total], 0
MOV invoice_index, 0
JMP DisplayCategories

InvalidDiscount:
MOV AH,9
LEA DX, discount_invalid
INT 21h
JMP DiscountInput

InvalidQuantity:
MOV AH,9
LEA DX, validate_qty
INT 21h
JMP AddQuantity

;--------------
; ConfirmPurchase
;--------------------
ConfirmPurchase:
CALL GenerateInvoice
MOV word ptr [cart_total], 0
MOV word ptr [cart_original_total], 0
MOV invoice_index, 0
CALL PressAnyKey
JMP MainMenu

AddAnotherMedicine:
JMP DisplayCategories

;---------------------
;SearchByLetter
;------------------------
SearchByLetter:
MOV AH,9
LEA DX, search_prompt
INT 21h
MOV AH,1
INT 21h
MOV BL, AL          
MOV AH,9
LEA DX, search_result
INT 21h
MOV DL, BL
MOV AH,2
INT 21h
MOV AH,2
MOV DL,10
INT 21h
MOV DL,13
INT 21h

LEA SI, medicines
MOV CX,0

NextMedicine:
MOV AL, [SI]
CMP AL,0
JE EndSearch
CMP AL,BL
JNE SkipMedicine
MOV DX, SI
MOV AH,9
INT 21h
INC CX
SkipMedicine:
MOV AL, [SI]
SkipLoop:
INC SI
MOV AL, [SI]
CMP AL,'$'
JNE SkipLoop
INC SI
JMP NextMedicine

EndSearch:
CMP CX,0
JNE SearchDone
MOV AH,9
LEA DX, no_match
INT 21h
SearchDone:
CALL PressAnyKey
JMP MainMenu

ExitProgram:
MOV AH,4Ch
INT 21h

MAIN ENDP
END MAIN