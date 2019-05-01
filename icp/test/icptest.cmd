;	**********************************************************
;	*                                                        *
;	*     Test for the RSX180 Indirect Command Processor     *
;	*                                                        *
;	**********************************************************
;
	.ENABLE SUBSTITUTION
;
; 1a) Simple .SETT, .SETF, .SETN, .SETL, .SETS
;
	.SETT LT
; LT = 'LT' (expected T)
	.SETF LF
; LF = 'LF' (expected F)
	.SETN N1 123
; N1 = 'N1' (expected 123)
	.SETN N2 -456
; N2 = 'N2%S' (expected -456)
	.SETL LL T
; LL = 'LL' (expected T)
	.SETL LL F
; LL = 'LL' (expected F)
	.SETS STR "A string"
; STR = "'STR'" (expected "A string")
;
; 1b) .SETN, .SETL and .SETS with expressions
;
	.SETN N1 2+3*5
; N1 = 'N1' (expected 17)
	.SETN N2 2*3+5
; N2 = 'N2' (expected 11)
	.SETN N3 (2+3)*5
; N3 = 'N3' (expected 25)
	.SETN N4 N1-N3/5+N2
; N4 = 'N4' (expected 23)
	.SETS STR STR+" with spaces"&"."
; STR = "'STR'" (expected "A string with spaces.")
	.SETS QS "String with embedded ""quotes"""
; QS = "'QS'" (expected "String with embedded "quotes"")
;
; 2a) .ASK, .ASKN and .ASKS without arguments
;
	.ASK L
; Answer: L = 'L'
	.ASKN N
; Answer: N = 'N'
	.ASKS S
; Answer: S = "'S'" <STRLEN>='<STRLEN>'
;
; 2b) .ASK, .ASKN and .ASKS with prompt string
;
	.ASK L Yes or No
; Answer: L = 'L'
	.ASKN N Enter a number
; Answer: N = 'N'
	.ASKS S Enter a string
; Answer: S = "'S'" <STRLEN>='<STRLEN>'
;
; 2c) .ASK, .ASKN and .ASKS with options
;
	.SETN TMO 10
;;	.ASK [L] L
;;	.ASK [<TRUE>:TMO] L Yes or No
; Answer: L = 'L'
	.SETN N 10
	.ASKN [N:N+10:5:5] N Enter a number
; Answer: N = 'N'
	.ASKN [:::5] N Enter another number
; Answer: N = 'N'
	.ASKN [1:10] N And another
; Answer: N = 'N'
	.SETS DEFS "Default string"
	.ASKS [10:20:DEFS:20] S Enter a string
; Answer: S = "'S'" <STRLEN>='<STRLEN>'
	.ASKS [::"Hello"] S Enter another string
; Answer: S = "'S'" <STRLEN>='<STRLEN>'
;
; 3a) .GOTO test (forward): skip comment lines, nothing should be printed
;     between the vvvv and ^^^^ lines.
; vvvv
	.GOTO skip
; THIS TEXT SHOULD NOT APPEAR
.skip:
; ^^^^
;
; 3b) .GOTO test (backwards): print in a loop numbers from 1 to 10
;
	.SETN i 1
.loop:
;	i = 'i'
	.INC i
	.IF i <= 10 .GOTO loop
;
; 4) .PARSE test
;
	.SETS cmd "TESTFILE IND,MCR,,LOA"
	.PARSE cmd " ," file a1 a2 a3 a4 a5
; "'cmd'" -> "'file'", "'a1'", "'a2'", "'a3'", "'a4'", "'a5'"  <STRLEN>='<STRLEN>'
	.PARSE "dy:[dir]myfile.ext;5" "[].;" dev dir file ext ver
; dy:[dir]myfile.ext;5 => 'dev'['dir']'file'.'ext';'ver'  <STRLEN>='<STRLEN>'
;   device    = 'dev'
;   directory = 'dir'
;   file name = 'file'
;   extension = 'ext'
;   version   = 'ver'
;
	.SETS TM "'<TIME>'"
	.PARSE TM ":" HH MM SS
;   current time = 'TM' -> 'HH' hours, 'MM' minutes, 'SS' seconds
;
; 5) .INC and .DEC test
;
	.ASKN n Enter a number
	.SETN n1 n
	.INC n
; After increment N='n'
	.SETN n n1
	.DEC n
; After decrement N='n'
;
; 6) .GOSUB and .RETURN
;
; 6a) Single call test
;
	.GOSUB sub1
;
; 6b) Nested call
;
	.GOSUB sub2
	.GOTO continue
.sub1:
; ***** on sub 1
	.RETURN
.sub2:
; ***** on sub 2 before call to sub 1
	.GOSUB sub1
; ***** on sub 2 after call to sub 1
	.RETURN
.continue:
;
; 7) .IF test
;
	.SETN n1 10
	.SETN n2 20
	.IF n1 = n2 ; 'n1' = 'n2'
	.IF n1 < n2 ; 'n1' < 'n2'
	.IF n1 > n2 ; 'n1' > 'n2'
	.IF n1 <= n2 ; 'n1' <= 'n2'
	.IF n1 >= n2 ; 'n1' >= 'n2'
	.IF n1 <> n2 ; 'n1' <> 'n2'
;
; 7a) .IFT/.IFF
;
	.IFT LT ; 'LT' is True
	.IFF LT ; 'LT' is False
;
; 7b) .IFDF/IFNDF
;
	.IFDF n1 ; n1 is defined as 'n1'
	.IFNDF n1 ; n1 is undefined
	.IFDF n8 ; n8 is defined as 'n8'
	.IFNDF n8 ; n8 is undefined
;
; 7c) .IFENABLED/.IFDISABLED
;
	.IFENABLED SUBSTITUTION	; SUBSTITUTION is enabled
	.IFDISABLED SUBSTITUTION; SUBSTITUTION is disabled
	.ENABLE GLOBAL
	.IFENABLED GLOBAL .DISABLE GLOBAL
	.IFENABLED GLOBAL	; GLOBAL is enabled (wrong)
	.IFDISABLED GLOBAL	; GLOBAL is disabled (correct)
;
; 7d) .IFINS/.IFNINS
;
	.IFINS  ...RMD ; Task ...RMD is installed
	.IFNINS ...RMD ; Task ...RMD is not installed
;
; 7e) .IFACT/.IFNACT
;
	.SETS TASK "...RMD"
	.IFACT  'TASK' ; Task 'TASK' is active
	.IFNACT 'TASK' ; Task 'TASK' is inactive
;
; 8) Substitution test
;
	.SETS str "This is a test string"
	.SETN num -10
; 8a) Numeric output
;
;     Decimal (default):              >'num'<
;     Decimal signed:                 >'num%S'<
;     Hexadecimal:                    >'num%H'<
;     Octal:                          >'num%O'<
;     Left-justified:                 >'num%L10'<
;     Right-justified:                >'num%R10'<
;     Left-justified with zero fill:  >'num%DZR10'<
;
; 8b) String output
;
;     Default:                        >'str'<
;     Left-justified:                 >'str%L30'<
;     Right-justified:                >'str%R30'<
;     Truncated:                      >'str%L10'<
;     Condensed:                      >'str%C'<
;
; 8c) Numeric as char output
;
	.SETN esc 27
	.SETN nc 65
;     ASCII value of 'nc' corresponds to char 'nc%V'
;     'esc%V'[1mBold 'esc%V'[0mNormal
;
; 8d) String char output as numeric
;
	.SETS sc "A"
;     Char 'sc' has an ASCII value of 'sc%V'
;
; 9) .TEST
;
	; Testing 'L'
	.TEST L
	.GOSUB tstvar
	; Testing 'N'
	.TEST N
	.GOSUB tstvar
	; Testing 'S'
	.TEST S
	.GOSUB tstvar
	.GOTO tstskip
.tstvar:
	.IF <SYMTYP> = 0 ; variable is logical
	.IF <SYMTYP> = 2 ; variable is numeric
	.IF <SYMTYP> = 4 ; variable is string
	.IF <SYMTYP> <> 4 .GOTO tstret
	.IFT <ALPHAN> ; * string contains alphanumeric characters
	.IFT <NUMBER> ; * string contains only numeric characters
	              ; * string length is '<STRLEN>'
.tstret:
	.RETURN
.tstskip:
;
; 9a) substring search with .TEST
;
	.SETS S1 "ABCDEF"
	.SETS S2 "DE"
	.TEST S1 S2
	.IF <STRLEN> NE 0 ; "'S1'" contains "'S2'" at position '<STRLEN>'
	.IF <STRLEN> EQ 0 ; "'S2'" was not found in "'S1'"
;
; 10) File I/O test
;
; 10a) .OPEN and .DATA
;
	.OPEN #1 TEST
	.SETS S1 "Hello, world!"
	; Writing "'S1'" to file '<FILSPC>'
	.DATA #1 'S1'
	.CLOSE #1
;
; 10b) .OPENA and .ENABLE DATA
;
	.OPENA #1 TEST
	.SETS S1 "Test from AT."
	; Appending "'S1'" to file '<FILSPC>'
.ENABLE DATA #1
'S1'
.DISABLE DATA
	.CLOSE #1
;
; 10c) .OPENR and .READ
;
	.OPENR #1 TEST
	.READ #1 S2
	; "'S2'" read from file '<FILSPC>'
	.READ #1 S2
	; "'S2'" read from file '<FILSPC>'
	.CLOSE #1
;
.DEBUG
.ERASE
.ENABLE SUBSTITUTION,DISPLAY
.ONERR
.TESTFILE
.TESTDEVICE
.CHAIN
.BEGIN
.END
.EXIT
.STOP
.DELAY
.PAUSE
.WAIT
.XQT 1 2 3
