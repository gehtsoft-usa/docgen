@echo off
del docgen.zip
if not exist .\bin mkdir bin
copy ..\source\app\bin\Release\net45\*.exe .\bin
copy ..\source\app\bin\Release\net45\*.dll .\bin
if not exist .\doc mkdir doc
copy ..\doc\Reference.doc .\doc
if not exist .\template mkdir template
copy .\template\templates.doc .\template
if not exist .\template\alias mkdir template\alias
copy ..\template\alias\*.* .\template\alias
if not exist .\template\cs2ds mkdir template\cs2ds
copy ..\template\cs2ds\*.* .\template\cs2ds
if not exist .\template\doxygen2ds mkdir template\doxygen2ds
copy ..\template\doxygen2ds\*.* .\template\doxygen2ds
if not exist .\template\jetdoclet2ds mkdir template\jetdoclet2ds
copy ..\template\jetdoclet2ds\*.* .\template\jetdoclet2ds
if not exist .\template\python2define mkdir template\python2define
copy ..\template\python2define\*.* .\template\python2define
if not exist .\template\python2ds mkdir template\python2ds
copy ..\template\python2ds\*.* .\template\python2ds
if not exist .\template\sandcastle2ds mkdir template\sandcastle2ds
copy ..\template\sandcastle2ds\*.* .\template\sandcastle2ds
if not exist .\template\null mkdir template\null
copy ..\template\null\*.* .\template\null
if not exist .\template\sql2ds mkdir template\sql2ds
copy ..\template\sql2ds\*.* .\template\sql2ds
if not exist .\template\xmldoc mkdir template\xmldoc
copy ..\template\xmldoc\*.* .\template\xmldoc
if not exist .\template\html mkdir template\html
if not exist .\template\html\declaration mkdir template\html\declaration
if not exist .\template\html\dictionary mkdir template\html\dictionary
if not exist .\template\html\highlighter mkdir template\html\highlighter
if not exist .\template\html\menu mkdir template\html\menu
if not exist .\template\html\pageImages mkdir template\html\pageImages
if not exist .\template\html\res mkdir template\html\res
copy ..\template\html  template\html
copy ..\template\html\declaration  template\html\declaration
copy ..\template\html\dictionary  template\html\dictionary
copy ..\template\html\highlighter  template\html\highlighter
copy ..\template\html\menu  template\html\menu
copy ..\template\html\pageImages  template\html\pageImages
copy ..\template\html\res  template\html\res
7z a -r -tzip docgen.zip bin\*.* doc\*.* template\*.*

