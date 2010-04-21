/*doc Sequence colourize(colour[, option])
Prints the string to stdout with bash colors.<br/>
Example: "Fire!!!" colourize("red", "bold") printlnColours
*/
Sequence colours := list("black", "red", "green", "yellow", "blue", "purple", "cyan", "white")
Sequence colourize := method(colour, option,
  out := "\\e[" asMutable
  if(colour isNil,            out appendSeq("0;3"))
  if(option == "bold",        out appendSeq("1;3"))
  if(option == "underline",   out appendSeq("4;3"))
  if(option == "background",  out appendSeq("4"))

  out appendSeq(self colours indexOf(colour) .. "m")
  out appendSeq(self)
  out appendSeq("\\e[0m")

  out)

(System platform asLowercase == "darwin") ifFalse(
  Sequence colourize = method(self))

Sequence printlnColours := method(
  System system("echo \"#{self}\"" interpolate)
  self)

