syntax match todotxtHeaderSTA /STA/
syntax match todotxtHeaderDUE /DUE/
syntax match todotxtHeaderPRi /PRI/
syntax match todotxtHeaderCAT /CAT/
syntax match todotxtHeaderDO /DO/

syntax match todotxtStatusO /\%1co/
syntax match todotxtStatusX /^x.*$/

syntax match todotxtDueDate /\%6c\d\d-\d\d/

syntax match todotxtPriorityA /\%13cA/
syntax match todotxtPriorityB /\%13cB/
syntax match todotxtPriorityC /\%13cC/

syntax match todotxtCategory /\%18c[a-z]/

highlight link todotxtHeaderSTA Function
highlight link todotxtHeaderDUE Function
highlight link todotxtHeaderPRI Function
highlight link todotxtHeaderCAT Function
highlight link todotxtHeaderDO Function

highlight link todotxtStatusX Comment

highlight link todotxtDuedate Constant

highlight link todotxtPriorityA Keyword
highlight link todotxtPriorityB Keyword
highlight link todotxtPriorityC Keyword

highlight link todotxtCategory String
