:syntax case match

:syntax keyword lstsKeyword let interface implements self for while if then else match import type fragment macro λ as zero in
:syntax keyword lstsType Bool U8 U16 U32 U64 I8 I16 I32 I64 F32 F64 Nil
:syntax keyword lstsTODO TODO contained
:syntax match   lstsOperator /==\|!=\|<=\|>=\|<\|>\|=\|=>\|\:\:\|\.\|+\|-\|\*\|\/\|&\||\|\'&/ 
:syntax match   lstsIdentifier /\'\?\.\?\<[a-zA-Z_][a-zA-Z0-9_\-]*\>/
:syntax match   lstsAdvIdentifier /\$"[^"\n]*"/ contains=lstsEscape
:syntax match   lstsComment /#.*$/ contains=lstsTODO
:syntax match   lstsNumber /\<\d\+\(\.\d\+\)\?\(_u64\|_u32\|_u16\|_u8\|_i64\|_i32\|_i16\|_i8\|_f32\|_f64\)\?\>/
:syntax match   lstsBraces /[{}()\[\]]/
:syntax match   lstsEscape /\\[nrt\\"']/ contained
:syntax match   lstsString /\(c\|r\)\?"[^"\n]*"/ contains=lstsEscape
:syntax match   lstsPath /\<\([a-zA-Z_][a-zA-Z0-9_\-]*\/\)*[a-zA-Z_][a-zA-Z0-9_\-]*\.\(lsts\|lm\|h\)\>/
:syntax match   lstsPunctuation /[,;\:]/

:highlight link lstsKeyword Keyword
:highlight link lstsType Type
:highlight link lstsOperator Operator
:highlight link lstsFunction Function
:highlight link lstsComment Comment
:highlight link lstsNumber Number
:highlight link lstsBraces Delimiter
:highlight link lstsString String
:highlight link lstsPath String
:highlight link lstsEscape SpecialChar
:highlight link lstsTODO SpecialChar
:highlight link lstsPunctuation Delimiter
:highlight link lstsIdentifier Identifier
:highlight link lstsAdvIdentifier Identifier
