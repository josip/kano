ObjectDescriber := Object clone do(
  namespace     ::= nil
  targetObj     ::= nil
  requiresClone ::= nil
  tasks         := nil

  init := method(
    self targetObj = nil
    self requiresClone = false
    self tasks = List clone)

  with := method(obj,
    self clone setTargetObj(obj))

  task := method(name,
    t := Task clone\
      setName(name)\
      setTargetObj(self targetObj)\
      setRequiresClone(self requiresClone)\
      setCreateClone(self getSlot("createClone"))

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
    createClone       ::= nil
    beforeMethod      ::= nil
    afterMethod       ::= nil

    callsSlot         := getSlot("setSlotName")
    describe          := getSlot("setDescription")
    dontFormatResult  := method(self setFormatResult(false))
    dontPrintResult   := method(self setPrintResult(false))
    leaveOutput       := method(self dontFormatResult dontPrintResult)
    returns           := method(typeProto, options,
      self setReturnType(typeProto type asMutable makeFirstCharacterLowercase) setFormatterOptions(options))

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
      createClone       = false
      beforeMethod      = method(args, args)
      afterMethod       = method(result, result))

    build := method(namespace,
      self slotName isNil ifTrue(
        self slotName = self name)

      taskBlock := block(
        args := self beforeMethod(call evalArgs)
        
        self requiresClone ifTrue(
          self targetObj = self createClone(args))

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
