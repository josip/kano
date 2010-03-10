ObjectDescriber := Object clone do(
  namespace     ::= nil
  targetObj     ::= nil
  tasks         := nil
  defaults      := nil
  requiresClone := nil

  init := method(
    self targetObj = nil
    self tasks = List clone
    self defaults = Task clone
    self requiresClone = false)

  with := method(obj,
    self clone setTargetObj(obj))

  task := method(name,
    target_ := if(self requiresClone, self createClone, self targetObj)
    t := Task with(name, target_, self requiresClone)
    self tasks append(t)
    t)

  createClone := method(
    self targetObj clone)

  done := method(
    self namespace isNil ifTrue(
      self namespace = Namespaces setSlot(self targetObj type, Namespace clone)
      self namespace type = self targetObj type)

    self tasks foreach(build(self namespace))
    self)

  Task := Object clone do(
    name              ::= nil
    slotName          ::= nil
    description       ::= nil
    formatResult      ::= nil
    printResult       ::= nil
    returnType        ::= nil
    formatterOptions  ::= nil
    targetObj         ::= nil
    requiresClone     ::= nil
    beforeMethod      ::= nil
    afterMethod       ::= nil

    callsSlot         := getSlot("setSlotName")
    describe          := getSlot("setDescription")
    dontFormatResult  := method(self setFormatResult(false))
    dontPrintResult   := method(self setPrintResult(false))
    leaveOutput       := method(self dontFormatResult dontPrintResult)
    returns           := method(rtype, options,
      self setReturnType(rtype) setFormatterOptions(options))

    before := method(
      self getSlot("beforeMethod")\
        setArgumentNames(list(call argAt(0) name))\
        setMessage(call argAt(1))
      self)

    after := doString(getSlot("before") code asMutable replaceSeq("beforeMethod", "afterMethod"))

    init := method(
      name              = nil
      slotName          = nil
      description       = nil
      formatResult      = true
      printResult       = true
      returnType        = nil
      formatterOptions  = nil
      targetObj         = nil
      requiresClone     = false
      beforeMethod      = method(args, args)
      afterMethod       = method(result, result))

    with := method(name_, targetObj_, requiresClone_,
      self clone setName(name_) setTargetObj(targetObj_) setRequiresClone(requiresClone_))

    build := method(namespace,
      self slotName isNil ifTrue(
        self slotName = self name)

      taskBlock := block(
        args := self beforeMethod(call evalArgs)

        result := self targetObj performWithArgList(self slotName, args)
        result = self afterMethod(result)

        self formatResult ifTrue(
          formatter := if(self returnType isNil, result type asMutable makeFirstCharacterLowercase, self returnType)
          formatter = OutputFormatters getSlot(formatter .. "Formatter")
          getSlot("formatter") isNil ifFalse(
            result = formatter(result, self formatterOptions)))

        self printResult ifTrue(
          result println)
        result)

      getSlot("taskBlock") description = self description
      namespace setSlot(self name, taskBlock)

      self)

    OutputFormatters := Object clone do(
      listFormatter := method(obj, options,
        joinWith := options ?at("joinWith")
        joinWith isNil ifTrue(joinWith = ", ")

        obj join(joinWith))

      mapFormatter := method(obj, options,
        maxKeySize := obj keys map(size) max
        obj map(k, v,
          kAligned := k alignLeft(maxKeySize + 2, " ")
          "#{kAligned}#{v}" interpolate) join("\n"))
    )
  )
)

Object describe := method(
  ObjectDescriber with(self))


Example := Object clone do(
  names := method(
    list(1, 2, 3, 4) append(call evalArgs) flatten)
  
  bands := method(
    Map with("Keane", 5,
      "Coldplay", 4,
      "Delphic", 4,
      "Marina & The Diamonds", 3.8))
  
  time := method(
    Date now)
)
