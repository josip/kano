Kano := Object clone do(
  namespaceSeparator  := ":"
  useExternalFile    ::= true
  supportedFiles      := list("Kanofile", "make.io")

  run := method(
    if(self useExternalFile != false,
      kanofile := self supportedFiles detect(name,
        File with(name) exists)
      kanofile isNil ifTrue(
        Exception raise("Kanofile (or make.io) file is missing."))

      Namespaces doFile(kanofile))

    allArgs := System args exSlice(1) select(exSlice(0, 1) != "-")
    task := allArgs first
    taskArgs := allArgs exSlice(1)
    options := System args select(exSlice(0, 1) == "-")

    options foreach(option,
      option = option exSlice(1)
      if(Namespaces Options hasSlot(option),
        Namespaces Options getSlot(option) call,
        Exception raise("Unknown option: -" .. option)))

    taskParts := task ?split(self namespaceSeparator)
    if(taskParts isNil,
      namespace := "Default"
      taskName  := "_default"
    ,
      namespace := if(taskParts size == 1, "Default", taskParts first)
      taskName  := taskParts last)

    nsName := namespace asMutable makeFirstCharacterUppercase
    ns := Namespaces getSlot(nsName)
    ns isNil ifTrue(
      Exception raise("Unknown namespace: " .. nsName))
    if(ns hasSlot(taskName),
      ns getSlot(taskName) performWithArgList("call", taskArgs),
      Exception raise("Unknown task: " .. taskName)))

  allTasks := method(
    result := Map clone

    Namespaces foreachSlot(nsName, ns,
      ns slotNames sort foreach(slotName,
        ((slotName exSlice(0, 1) != "_") and (ns getLocalSlot(slotName) type == "Block")) ifTrue(
          prettyNsName := if(ns type == "Default",    "",   (ns type) .. (self namespaceSeparator))
          prettyNsName  = if(ns type == "Options",    "-",  prettyNsName asMutable makeFirstCharacterLowercase)

          result atPut(prettyNsName .. slotName, ns getLocalSlot(slotName) description))))
    result)
)
