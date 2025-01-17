Require Import Coq.ZArith.BinInt Coq.Lists.List.
Require Coq.Init.Byte Coq.Strings.Byte Coq.Strings.String.
Declare Scope bytedump_scope.
Delimit Scope bytedump_scope with bytedump.

(* see COQBUG(9741), COQBUG(9744) before using for caveats *)
(* example output and usage is in the bottom of the file *)

(* This definition uses some one-character tokens, so we have to put it before the Notations
   which erroneously create keywords for all one-character tokens, COQBUG(9741) *)
Definition allBytes: list Byte.byte :=
  map (fun nn => match Byte.of_N (BinNat.N.of_nat nn) with
                 | Some b => b
                 | None => Byte.x00 (* won't happen *)
                 end)
      (seq 0 256).

Fixpoint byte_list_of_string (s : String.string): list Byte.byte :=
  match s with
  | String.EmptyString => nil
  | String.String c s => cons (Ascii.byte_of_ascii c) (byte_list_of_string s)
  end.

Notation "a b" :=
  (@cons Byte.byte a%bytedump b%bytedump)
  (only printing, right associativity, at level 3, format "a b")
  : bytedump_scope.
Undelimit Scope bytedump_scope.

Notation "  " := Byte.x20 (only printing) : bytedump_scope. (* WHY does this line need to be before the next one? *)
Notation "" := (@nil Byte.byte) (only printing, right associativity, at level 3, format "") : bytedump_scope.
Notation "a" := (@cons Byte.byte a nil) (only printing, at level 3) : bytedump_scope. (* WHY COQBUG(9744) *)

Notation "' '" := (Byte.x00) (only printing) : bytedump_scope.
Notation "''" := (Byte.x01) (only printing) : bytedump_scope.
Notation "''" := (Byte.x02) (only printing) : bytedump_scope.
Notation "''" := (Byte.x03) (only printing) : bytedump_scope.
Notation "''" := (Byte.x04) (only printing) : bytedump_scope.
Notation "''" := (Byte.x05) (only printing) : bytedump_scope.
Notation "''" := (Byte.x06) (only printing) : bytedump_scope.
Notation "''" := (Byte.x07) (only printing) : bytedump_scope.
Notation "''" := (Byte.x08) (only printing) : bytedump_scope.
Notation "'	'" := (Byte.x09) (only printing) : bytedump_scope.
Notation "'
'" := (Byte.x0a) (only printing) : bytedump_scope.
Notation "''" := (Byte.x0b) (only printing) : bytedump_scope.
Notation "''" := (Byte.x0c) (only printing) : bytedump_scope.
Notation "''" := (Byte.x0d) (only printing) : bytedump_scope.
Notation "''" := (Byte.x0e) (only printing) : bytedump_scope.
Notation "''" := (Byte.x0f) (only printing) : bytedump_scope.
Notation "''" := (Byte.x10) (only printing) : bytedump_scope.
Notation "''" := (Byte.x11) (only printing) : bytedump_scope.
Notation "''" := (Byte.x12) (only printing) : bytedump_scope.
Notation "''" := (Byte.x13) (only printing) : bytedump_scope.
Notation "''" := (Byte.x14) (only printing) : bytedump_scope.
Notation "''" := (Byte.x15) (only printing) : bytedump_scope.
Notation "''" := (Byte.x16) (only printing) : bytedump_scope.
Notation "''" := (Byte.x17) (only printing) : bytedump_scope.
Notation "''" := (Byte.x18) (only printing) : bytedump_scope.
Notation "''" := (Byte.x19) (only printing) : bytedump_scope.
Notation "''" := (Byte.x1a) (only printing) : bytedump_scope.
Notation "''" := (Byte.x1b) (only printing) : bytedump_scope.
Notation "''" := (Byte.x1c) (only printing) : bytedump_scope.
Notation "''" := (Byte.x1d) (only printing) : bytedump_scope.
Notation "''" := (Byte.x1e) (only printing) : bytedump_scope.
Notation "''" := (Byte.x1f) (only printing) : bytedump_scope.
Notation "  " := (Byte.x20) (only printing) : bytedump_scope. (* WHY is the seemingly duplicate line above necessary? *)
Notation "'!'" := (Byte.x21) (only printing) : bytedump_scope.
Notation "'""'" := (Byte.x22) (only printing) : bytedump_scope.
Notation "'#'" := (Byte.x23) (only printing) : bytedump_scope.
Notation "'$'" := (Byte.x24) (only printing) : bytedump_scope.
Notation "'%'" := (Byte.x25) (only printing) : bytedump_scope.
Notation "'&'" := (Byte.x26) (only printing) : bytedump_scope.
Notation "'''" := (Byte.x27) (only printing) : bytedump_scope.
Notation "'('" := (Byte.x28) (only printing) : bytedump_scope.
Notation "')'" := (Byte.x29) (only printing) : bytedump_scope.
Notation "'*'" := (Byte.x2a) (only printing) : bytedump_scope.
Notation "'+'" := (Byte.x2b) (only printing) : bytedump_scope.
Notation "','" := (Byte.x2c) (only printing) : bytedump_scope.
Notation "'-'" := (Byte.x2d) (only printing) : bytedump_scope.
Notation "'.'" := (Byte.x2e) (only printing) : bytedump_scope.
Notation "'/'" := (Byte.x2f) (only printing) : bytedump_scope.
Notation "'0'" := (Byte.x30) (only printing) : bytedump_scope.
Notation "'1'" := (Byte.x31) (only printing) : bytedump_scope.
Notation "'2'" := (Byte.x32) (only printing) : bytedump_scope.
Notation "'3'" := (Byte.x33) (only printing) : bytedump_scope.
Notation "'4'" := (Byte.x34) (only printing) : bytedump_scope.
Notation "'5'" := (Byte.x35) (only printing) : bytedump_scope.
Notation "'6'" := (Byte.x36) (only printing) : bytedump_scope.
Notation "'7'" := (Byte.x37) (only printing) : bytedump_scope.
Notation "'8'" := (Byte.x38) (only printing) : bytedump_scope.
Notation "'9'" := (Byte.x39) (only printing) : bytedump_scope.
Notation "':'" := (Byte.x3a) (only printing) : bytedump_scope.
Notation "';'" := (Byte.x3b) (only printing) : bytedump_scope.
Notation "'<'" := (Byte.x3c) (only printing) : bytedump_scope.
Notation "'='" := (Byte.x3d) (only printing) : bytedump_scope.
Notation "'>'" := (Byte.x3e) (only printing) : bytedump_scope.
Notation "'?'" := (Byte.x3f) (only printing) : bytedump_scope.
Notation "'@'" := (Byte.x40) (only printing) : bytedump_scope.
Notation "'A'" := (Byte.x41) (only printing) : bytedump_scope.
Notation "'B'" := (Byte.x42) (only printing) : bytedump_scope.
Notation "'C'" := (Byte.x43) (only printing) : bytedump_scope.
Notation "'D'" := (Byte.x44) (only printing) : bytedump_scope.
Notation "'E'" := (Byte.x45) (only printing) : bytedump_scope.
Notation "'F'" := (Byte.x46) (only printing) : bytedump_scope.
Notation "'G'" := (Byte.x47) (only printing) : bytedump_scope.
Notation "'H'" := (Byte.x48) (only printing) : bytedump_scope.
Notation "'I'" := (Byte.x49) (only printing) : bytedump_scope.
Notation "'J'" := (Byte.x4a) (only printing) : bytedump_scope.
Notation "'K'" := (Byte.x4b) (only printing) : bytedump_scope.
Notation "'L'" := (Byte.x4c) (only printing) : bytedump_scope.
Notation "'M'" := (Byte.x4d) (only printing) : bytedump_scope.
Notation "'N'" := (Byte.x4e) (only printing) : bytedump_scope.
Notation "'O'" := (Byte.x4f) (only printing) : bytedump_scope.
Notation "'P'" := (Byte.x50) (only printing) : bytedump_scope.
Notation "'Q'" := (Byte.x51) (only printing) : bytedump_scope.
Notation "'R'" := (Byte.x52) (only printing) : bytedump_scope.
Notation "'S'" := (Byte.x53) (only printing) : bytedump_scope.
Notation "'T'" := (Byte.x54) (only printing) : bytedump_scope.
Notation "'U'" := (Byte.x55) (only printing) : bytedump_scope.
Notation "'V'" := (Byte.x56) (only printing) : bytedump_scope.
Notation "'W'" := (Byte.x57) (only printing) : bytedump_scope.
Notation "'X'" := (Byte.x58) (only printing) : bytedump_scope.
Notation "'Y'" := (Byte.x59) (only printing) : bytedump_scope.
Notation "'Z'" := (Byte.x5a) (only printing) : bytedump_scope.
Notation "'['" := (Byte.x5b) (only printing) : bytedump_scope.
Notation "'\'" := (Byte.x5c) (only printing) : bytedump_scope.
Notation "']'" := (Byte.x5d) (only printing) : bytedump_scope.
Notation "'^'" := (Byte.x5e) (only printing) : bytedump_scope.
Notation "'_'" := (Byte.x5f) (only printing) : bytedump_scope.
Notation "'`'" := (Byte.x60) (only printing) : bytedump_scope.
Notation "'a'" := (Byte.x61) (only printing) : bytedump_scope.
Notation "'b'" := (Byte.x62) (only printing) : bytedump_scope.
Notation "'c'" := (Byte.x63) (only printing) : bytedump_scope.
Notation "'d'" := (Byte.x64) (only printing) : bytedump_scope.
Notation "'e'" := (Byte.x65) (only printing) : bytedump_scope.
Notation "'f'" := (Byte.x66) (only printing) : bytedump_scope.
Notation "'g'" := (Byte.x67) (only printing) : bytedump_scope.
Notation "'h'" := (Byte.x68) (only printing) : bytedump_scope.
Notation "'i'" := (Byte.x69) (only printing) : bytedump_scope.
Notation "'j'" := (Byte.x6a) (only printing) : bytedump_scope.
Notation "'k'" := (Byte.x6b) (only printing) : bytedump_scope.
Notation "'l'" := (Byte.x6c) (only printing) : bytedump_scope.
Notation "'m'" := (Byte.x6d) (only printing) : bytedump_scope.
Notation "'n'" := (Byte.x6e) (only printing) : bytedump_scope.
Notation "'o'" := (Byte.x6f) (only printing) : bytedump_scope.
Notation "'p'" := (Byte.x70) (only printing) : bytedump_scope.
Notation "'q'" := (Byte.x71) (only printing) : bytedump_scope.
Notation "'r'" := (Byte.x72) (only printing) : bytedump_scope.
Notation "'s'" := (Byte.x73) (only printing) : bytedump_scope.
Notation "'t'" := (Byte.x74) (only printing) : bytedump_scope.
Notation "'u'" := (Byte.x75) (only printing) : bytedump_scope.
Notation "'v'" := (Byte.x76) (only printing) : bytedump_scope.
Notation "'w'" := (Byte.x77) (only printing) : bytedump_scope.
Notation "'x'" := (Byte.x78) (only printing) : bytedump_scope.
Notation "'y'" := (Byte.x79) (only printing) : bytedump_scope.
Notation "'z'" := (Byte.x7a) (only printing) : bytedump_scope.
Notation "'{'" := (Byte.x7b) (only printing) : bytedump_scope.
Notation "'|'" := (Byte.x7c) (only printing) : bytedump_scope.
Notation "'}'" := (Byte.x7d) (only printing) : bytedump_scope.
Notation "'~'" := (Byte.x7e) (only printing) : bytedump_scope.
Notation "''" := (Byte.x7f) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x80) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x81) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x82) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x83) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x84) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x85) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x86) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x87) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x88) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x89) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x8a) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x8b) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x8c) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x8d) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x8e) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x8f) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x90) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x91) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x92) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x93) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x94) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x95) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x96) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x97) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x98) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x99) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x9a) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x9b) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x9c) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x9d) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x9e) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.x9f) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa0) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa1) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa2) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa3) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa4) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa5) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa6) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa7) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa8) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xa9) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xaa) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xab) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xac) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xad) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xae) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xaf) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb0) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb1) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb2) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb3) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb4) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb5) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb6) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb7) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb8) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xb9) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xba) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xbb) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xbc) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xbd) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xbe) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xbf) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc0) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc1) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc2) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc3) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc4) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc5) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc6) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc7) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc8) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xc9) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xca) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xcb) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xcc) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xcd) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xce) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xcf) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd0) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd1) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd2) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd3) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd4) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd5) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd6) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd7) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd8) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xd9) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xda) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xdb) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xdc) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xdd) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xde) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xdf) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe0) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe1) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe2) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe3) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe4) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe5) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe6) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe7) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe8) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xe9) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xea) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xeb) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xec) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xed) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xee) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xef) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf0) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf1) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf2) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf3) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf4) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf5) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf6) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf7) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf8) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xf9) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xfa) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xfb) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xfc) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xfd) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xfe) (only printing) : bytedump_scope.
Notation "'�'" := (Byte.xff) (only printing) : bytedump_scope.

Global Set Printing Width 2147483647.

(*
Local Open Scope bytedump_scope.
Goal False.
  let cc := eval cbv in allBytes in idtac cc.
Abort.
*)

(*
00000000  00 01 02 03 04 05 06 07  08 09 0a 0b 0c 0d 0e 0f  |................|
00000010  10 11 12 13 14 15 16 17  18 19 1a 1b 1c 1d 1e 1f  |................|
00000020  20 21 22 23 24 25 26 27  28 29 2a 2b 2c 2d 2e 2f  | !X#$%&'()*+,-./| (* X means doublequote here *)
00000030  30 31 32 33 34 35 36 37  38 39 3a 3b 3c 3d 3e 3f  |0123456789:;<=>?|
00000040  40 41 42 43 44 45 46 47  48 49 4a 4b 4c 4d 4e 4f  |@ABCDEFGHIJKLMNO|
00000050  50 51 52 53 54 55 56 57  58 59 5a 5b 5c 5d 5e 5f  |PQRSTUVWXYZ[\]^_|
00000060  60 61 62 63 64 65 66 67  68 69 6a 6b 6c 6d 6e 6f  |`abcdefghijklmno|
00000070  70 71 72 73 74 75 76 77  78 79 7a 7b 7c 7d 7e 7f  |pqrstuvwxyz{|}~.|
00000080  80 81 82 83 84 85 86 87  88 89 8a 8b 8c 8d 8e 8f  |................|
00000090  90 91 92 93 94 95 96 97  98 99 9a 9b 9c 9d 9e 9f  |................|
000000a0  a0 a1 a2 a3 a4 a5 a6 a7  a8 a9 aa ab ac ad ae af  |................|
000000b0  b0 b1 b2 b3 b4 b5 b6 b7  b8 b9 ba bb bc bd be bf  |................|
000000c0  c0 c1 c2 c3 c4 c5 c6 c7  c8 c9 ca cb cc cd ce cf  |................|
000000d0  d0 d1 d2 d3 d4 d5 d6 d7  d8 d9 da db dc dd de df  |................|
000000e0  e0 e1 e2 e3 e4 e5 e6 e7  e8 e9 ea eb ec ed ee ef  |................|
000000f0  f0 f1 f2 f3 f4 f5 f6 f7  f8 f9 fa fb fc fd fe ff  |................|
00000100  0a                                                |.|
00000101
*)
