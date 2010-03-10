Namespaces := Object clone do(
  //doc Namespaces Default The default namespace.
  Default := Namespace clone do(
    _default := task()
  )

  /*doc Namespaces Options
  Tasks from this namespace are called only if their name is prepended with an dash. They can't take arguments.<br/>
  <code>kano -verbose -version</code>*/
  Options := Namespace clone do(
    tasks := option(
      """Lists all available tasks and options."""

      allTasks := Kano allTasks
      maxNameSize := allTasks map(n, v, n size) max
      maxNameSize = if(maxNameSize isNil, 0, maxNameSize + 2)

      allTasks keys sort foreach(key,
        ((key alignLeft(maxNameSize, " ")) .. (allTasks at(key))) println))

    ns := option(
      """Lists all namespaces."""
      Namespaces slotNames sort join(", ") println)

    v := option(
      """Prints Kano version."""
      kanoPkg := File with((Eerie activeEnv path) .. "/addons/Kano/package.json")
      pkgInfo := Yajl parseJson(kanoPkg openForReading contents)
      ("Kano v" .. (pkgInfo at("version"))) println)

    h := option(
      """Quick usage notes."""

      options := self slotNames remove("type") sort join("|")
      "Usage: kano [-#{options}] [namespace:]taskName arg1 arg2..." interpolate println)
  )
)
