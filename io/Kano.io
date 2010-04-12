Kano := Object clone do(
  namespaceSeparator  := ":"
  useExternalFile    ::= true
  supportedFiles      := list("make.io", "Kanofile", "kanofile", "Kanofile.io", "kanofile.io")

  run := method(
    self useExternalFile ifTrue(
      self findKanofiles(Directory with(System launchPath)) foreach(f,
        Namespaces doFile(f path)))

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
      if(ns getSlot(taskName) type == "Block",
        ns getSlot(taskName) performWithArgList("call", taskArgs)),
      Exception raise("Unknown task: " .. taskName)))

  findKanofiles := method(dir,
    dir isNil ifTrue(return(list()))

    files := list(self supportedFiles map(name,
      File with((dir path) .. name)) detect(exists))

    tasksDir := dir directoryNamed("tasks")
    tasksDir exists ifTrue(
      files = files union(tasksDir filesWithExtension("io") map(path)))

    files = files select(!= nil)
    if(files isEmpty, self findKanofiles(dir parentDirectory), files))
)
