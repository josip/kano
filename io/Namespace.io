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
