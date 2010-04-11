Namespace := Object clone do(
  //doc Namespace task Alias for [[Object method]].
  task := getSlot("method")

  //doc Namespace option Alias for [[Object method]].
  option := getSlot("method")
  
  //doc Namespace sh(command) Runs command and returns true if the command exited with status different than 0.
  sh := method(command,
    System runCommand(command) exitStatus != 0)
  
  alias := method(original, alias,
    self setSlot(alias, self getSlot(original)))
)

//doc Block description Returns description of a method contained within first triquote.
Block description := method(
  firstMessage := getSlot("self") message name clone asMutable replaceSeq("\t", "") replaceSeq("  ", "")
  if(firstMessage containsSeq("\"\"\""),
    firstMessage exSlice(3, -3),
    ""))

/*doc Sequence colourize(colour[, option])
*Prints the string to stdout with bash colors.<br/>
Example: "#{sRed}Fire!!!#{eRed}"*/
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
Sequence printlnColours := method(
  System system("echo \"#{self}\"" interpolate)
  self)
