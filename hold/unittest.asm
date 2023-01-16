.function test_runTests
  .namespace "test_runTests"
    .data          
      sTestName1  .textz "--- Delete First ---\r"                  
      sTestName2  .textz "--- Delete Last ---\r"                  
      sTestName3  .textz "--- Delete Middle ---\r"                  
      sTestName4  .textz "--- Delete Final ---\r"                                      
    .code
      
      ; Confirms that add, first, and delete of first element works
      print1_macro(sTestName1)
      test_addFive()
      test_deleteFirst()
      test_printList()      

      ; Confirms that add, last, and delete of first element works
      print1_macro(sTestName2)
      test_addFive()
      test_deleteLast()
      test_printList()

      ; Confirms that add, first, next and delete of first element works
      print1_macro(sTestName3)
      test_addFive()
      test_deleteSecond()
      test_printList()

      ; Confirms that add, first, next and delete of all elements
      print1_macro(sTestName4)
      test_addFive()
      test_deleteAll()
      test_printList()
            
  .namespace    
.endfunction

.function test_addFive
  .namespace "test_addFive"
    .data          
      sNewNode  .textz "newNode: "      
      sTemp     .textz "        "
      sCRLF     .textz "\r"
      nodeType  .byte $00
      tempPtr   .word $0000
      wDummy    .word $0000
      bDummy    .byte $00
    .code

      ; Initialize Heap (Deallocates everything)
      mempool_init()

      ; Initialize the list
      list_init_macro(l)      

      ; Prime nodeType
      lda #$05
      sta nodeType

      @addloop

        ; Add NodeType to list l
        ;list_Add_Macro(result, pList, nodeType, originX, originY, theta, r, width, height, palette, spriteImage)  
        list_Add_macro (tempPtr, l, PLAYER, wDummy, wDummy, bDummy, wDummy, SPRITEW16, SPRITEH16, PALPLAYSHIP, IMGPLAYSHIP00)        
                
        ; Display the results
        wordToString_macro(sTemp, tempPtr)
        print3_macro(sNewNode, sTemp, sCRLF)              

        dec nodeType        

      bne @addloop
  .namespace    
.endfunction

.function test_deleteFirst
  .namespace "test_deleteFirst"
    .data                
      tempPtr   .word $0000
      sRemove   .textz "Removing:"      
      sTemp     .textz "        "
      sCRLF     .textz "\r"
    .code

      ; Move First
      list_First_macro(tempPtr, l)  

      wordToString_macro(sTemp, tempPtr)
      print3_macro(sRemove, sTemp, sCRLF)              

      ; Delete this record
      list_Remove_macro(l, tempPtr)
      
  .namespace    
.endfunction

.function test_deleteLast
  .namespace "test_deleteLast"
    .data                
      tempPtr   .word $0000
      sRemove   .textz "Removing:"      
      sTemp     .textz "        "
      sCRLF     .byte $0d $00
    .code

      ; Move First
      list_Last_macro(tempPtr, l)  

      wordToString_macro(sTemp, tempPtr)
      print3_macro(sRemove, sTemp, sCRLF) 

      ; Delete this record
      list_Remove_macro(l, tempPtr)
      
  .namespace    
.endfunction

.function test_deleteSecond
  .namespace "test_deleteSecond"
    .data                
      tempPtr   .word $0000
      sRemove   .textz "Removing:"      
      sTemp     .textz "        "
      sCRLF     .textz "\r"
    .code

      ; Move First
      list_First_macro(tempPtr, l)  
      list_Next_macro(tempPtr, tempPtr)  

      ; Delete this record
      list_Remove_macro(l, tempPtr)
      
  .namespace    
.endfunction

.function test_deleteAll
  .namespace "test_deleteAll"
    .data      
      sRemove   .textz "Removing:"      
      sTemp     .textz "        "
      sTemp2    .textz "        "
      sSpace    .textz " "
      sCRLF     .textz "\r"
      tempPtr   .word $0000
    .code
          
      @nextLoop

        ; Move First
        list_First_macro(ptr1, l)      

        ; Continue until the list is empty
        cpwai(ptr1, $0000)
        beq @done

        wordToString_macro(sTemp, ptr1)
        byteToString_ofs_macro(sTemp2, ptr1, node_sprite)	
        print5_macro(sRemove, sTemp, sSpace, sTemp2, sCRLF)         

        ; Delete this record
        list_Remove_macro(l, ptr1)
        
      jmp @nextLoop
      @done
  .namespace
.endfunction

.function test_printList
  .namespace "test_printList"
    .data      
      sFirst    .textz "first:   "
      sNext     .textz "next:    "
      sTemp     .textz "        "
      sCRLF     .textz "\r"      
      tempPtr   .word $0000
    .code

      ; Move First
      list_First_macro(tempPtr, l)      

      ; Display the results
      wordToString_macro(sTemp, tempPtr)
      print3_macro(sFirst, sTemp, sCRLF)      
      
      ; Only continue if tempPtr != null
      cpwai(tempPtr, $0000)
      beq @done

      @nextLoop

        ; Move Next
        list_Next_macro(tempPtr, tempPtr)        

        ; Display the results
        wordToString_macro(sTemp, tempPtr)
        print3_macro(sNext, sTemp, sCRLF)      

        ; Continue until the list is empty
        cpwai(tempPtr, $0000)

      bne @nextLoop
      @done
  .namespace
.endfunction
